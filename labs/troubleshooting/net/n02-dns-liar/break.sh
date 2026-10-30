#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root

grep -q 'legacy-proxy-setup' /etc/hosts || {
  cp /etc/hosts /etc/hosts.tshoot-n02.bak
  # 192.0.2.0/24 is TEST-NET-1 (RFC 5737): never routed on the internet -> packets vanish -> timeout
  printf '192.0.2.10\texample.com www.example.com\t# legacy-proxy-setup\n' >> /etc/hosts
}
info "Incident ready. Try: curl -v --max-time 5 http://example.com   and   dig +short example.com"
