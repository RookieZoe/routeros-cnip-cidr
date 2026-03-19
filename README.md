# RouterOS CN IP List

CN IP CIDR list generator for MikroTik RouterOS, support IPv4/IPv6 dual stack.

[![status](https://img.shields.io/github/workflow/status/upbeat-backbone-bose/routeros-cnip-cidr/cnip-cidr-gen?color=34d058&label=cnip-cidr-gen&logo=github&logoColor=fff)](https://github.com/upbeat-backbone-bose/routeros-cnip-cidr/actions/workflows/cnip-cidr-gen.yml)
[![Validate](https://img.shields.io/github/actions/workflow/status/upbeat-backbone-bose/routeros-cnip-cidr/cnip-cidr-gen.yml?label=validate)](https://github.com/upbeat-backbone-bose/routeros-cnip-cidr/actions)

## Features

- IPv4 and IPv6 dual stack support (RouterOS 7+)
- Automatic IP format validation
- Bulk import with error tolerance
- Scheduled automatic updates (every 15 days)
- Chinese IP ranges from multiple data sources

## Data Sources

- [soffchen/GeoIP2-CN](https://github.com/soffchen/GeoIP2-CN) - IPv4 CIDR
- [gaoyifan/china-operator-ip](https://github.com/gaoyifan/china-operator-ip) - IPv6 CIDR

## Quick Start

### One-line Import

```RouterOS
# Via CDN (recommended)
/tool fetch url="https://cdn.jsdelivr.net/gh/upbeat-backbone-bose/routeros-cnip-cidr/dist/cn_ip_cidr.rsc" dst-path=cn.rsc;
/import file-name=cn.rsc;

/# Via GitHub Raw (fallback)
/tool fetch url="https://raw.githubusercontent.com/upbeat-backbone-bose/routeros-cnip-cidr/master/dist/cn_ip_cidr.rsc" dst-path=cn.rsc;
/import file-name=cn.rsc;
```

### Manual Build

```bash
git clone https://github.com/upbeat-backbone-bose/routeros-cnip-cidr.git
cd routeros-cnip-cidr
bash generator.bash
```

The generated script will be at `dist/cn_ip_cidr.rsc`.

## Test

### Local Test

```bash
# Run the generator
bash generator.bash

# Check output
head -20 dist/cn_ip_cidr.rsc

# Validate IP count
grep -c "add address=" dist/cn_ip_cidr.rsc
```

### Expected Output

```
Validating IPv4 list...
Valid: 3913, Invalid: 0
Validating IPv6 list...
Valid: 1680, Invalid: 0
Generation completed: dist/cn_ip_cidr.rsc
```

## Auto Update

This repository uses GitHub Actions to automatically update the IP list:

- Schedule: Every 15 days at 16:00 UTC
- Trigger: Push any tag
- Manual: Workflow dispatch available

## Project Structure

```
.
├── generator.bash          # Main generator script
├── dist/
│   └── cn_ip_cidr.rsc     # Generated RouterOS script
└── .github/
    └── workflows/
        └── cnip-cidr-gen.yml
```

## Thanks to

- [RookieZoe](https://github.com/RookieZoe/routeros-cnip-cidr) - Original project
- [ispip.clang.cn](https://ispip.clang.cn/) - IP data source
- [IceCodeNew](https://github.com/IceCodeNew/4Share) - IP data source
- [gaoyifan](https://github.com/gaoyifan/china-operator-ip) - IPv6 data source
- [soffchen/GeoIP2-CN](https://github.com/soffchen/GeoIP2-CN) - IPv4 data source
