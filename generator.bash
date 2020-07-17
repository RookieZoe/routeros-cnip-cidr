#! /bin/bash
WORK_DIR=$(cd $(dirname $0); pwd);

if [ ! -d "$WORK_DIR/tmp" ];then
  mkdir $WORK_DIR/tmp
fi

curl -s https://ispip.clang.cn/all_cn.txt -o $WORK_DIR/tmp/all_cn.txt && \
curl -s https://ispip.clang.cn/all_cn_ipv6.txt -o $WORK_DIR/tmp/all_cn_ipv6.txt && \
cat > $WORK_DIR/dist/cn_ip_cidr.rsc << EOF
/log info "Import cn ipv4 cidr list..."
/ip firewall address-list remove [/ip firewall address-list find list=cn_ip_cidr]
/ip firewall address-list
EOF
cat $WORK_DIR/tmp/all_cn.txt | awk '{ printf(":do {add address=%s list=cn_ip_cidr} on-error={}\n",$0) }' >> $WORK_DIR/dist/cn_ip_cidr.rsc && \
cat >> $WORK_DIR/dist/cn_ip_cidr.rsc << EOF
:if ([:len [/system package find where name="ipv6" and disabled=no]] > 0) do={
/log info "Import cn ipv6 cidr list..."
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=cn_ip_cidr]
/ipv6 firewall address-list
EOF
cat $WORK_DIR/tmp/all_cn_ipv6.txt | awk '{ printf(":do {add address=%s list=cn_ip_cidr} on-error={}\n",$0) }' >> $WORK_DIR/dist/cn_ip_cidr.rsc && \
echo "}" >> $WORK_DIR/dist/cn_ip_cidr.rsc
