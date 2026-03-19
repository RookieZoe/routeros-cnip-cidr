#! /bin/bash
set -euo pipefail
WORK_DIR=$(cd $(dirname $0); pwd)

if [ ! -d "$WORK_DIR/tmp" ];then
  mkdir -p $WORK_DIR/tmp
fi

TMP_CIDR_V4="$WORK_DIR/tmp/all_cn.txt"
TMP_CIDR_V6="$WORK_DIR/tmp/all_cn_ipv6.txt"

curl --max-time 60 -sL https://raw.githubusercontent.com/soffchen/GeoIP2-CN/release/CN-ip-cidr.txt -o "$TMP_CIDR_V4" || { echo "Failed to download IPv4 list"; exit 1; }
curl --max-time 60 -sL https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt -o "$TMP_CIDR_V6" || { echo "Failed to download IPv6 list"; exit 1; }

validate_ip_cidr() {
    local file=$1
    local valid_count=0
    local invalid_count=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]] || [[ "$line" =~ ^([0-9a-fA-F:]+)/[0-9]{1,3}$ ]]; then
            ((valid_count++)) || true
        else
            ((invalid_count++)) || true
        fi
    done < "$file"
    echo "Valid: $valid_count, Invalid: $invalid_count"
    [[ $invalid_count -lt $valid_count ]]
}

echo "Validating IPv4 list..."
validate_ip_cidr "$TMP_CIDR_V4"
echo "Validating IPv6 list..."
validate_ip_cidr "$TMP_CIDR_V6"
cat > $WORK_DIR/dist/cn_ip_cidr.rsc << 'EOF'
/log info "Import cn ipv4 cidr list..."
/ip firewall address-list remove [/ip firewall address-list find list=cn_ip_cidr]
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=cn_ip_cidr]
/ip firewall address-list
EOF

awk '{ printf(":do {add address=%s list=cn_ip_cidr} on-error={}\n",$0) }' "$TMP_CIDR_V4" >> $WORK_DIR/dist/cn_ip_cidr.rsc

cat >> $WORK_DIR/dist/cn_ip_cidr.rsc << 'EOF'
:global hasIPv6 false
:if ([:len [/system package find where name="routeros" and version>7]] > 0) do={
    :global hasIPv6 true
    /log info "Import cn ipv6 cidr list..."
    /ipv6 firewall address-list
}
EOF

awk '{ printf(":do {add address=%s list=cn_ip_cidr} on-error={}\n",$0) }' "$TMP_CIDR_V6" >> $WORK_DIR/dist/cn_ip_cidr.rsc
echo "}" >> $WORK_DIR/dist/cn_ip_cidr.rsc

echo "Generation completed: $WORK_DIR/dist/cn_ip_cidr.rsc"
