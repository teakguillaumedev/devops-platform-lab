#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root
while iptables -D INPUT -i tsh-host -p tcp --dport 8084 -m comment --comment "hardening-2024" -j DROP 2>/dev/null; do :; done
stop_pidfile billing
rm -rf "$TSHOOT_STATE/billing-www" "$TSHOOT_STATE/billing.log"
netlab_down
info "N04 cleaned"
