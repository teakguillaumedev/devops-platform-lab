#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root
sed -i '/legacy-proxy-setup/d' /etc/hosts
rm -f /etc/hosts.tshoot-n02.bak
info "N02 cleaned"
