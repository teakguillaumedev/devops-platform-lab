#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root; need ip iptables python3
mkdir -p "$TSHOOT_STATE"

netlab_up
start_http billing 0.0.0.0 8084
# reports (8085) is intentionally NOT started.
iptables -C INPUT -i tsh-host -p tcp --dport 8084 -m comment --comment "hardening-2024" -j DROP 2>/dev/null \
  || iptables -I INPUT -i tsh-host -p tcp --dport 8084 -m comment --comment "hardening-2024" -j DROP
info "Incident ready. Test from the client: sudo ip netns exec $NETNS curl -v --max-time 5 http://$HOST_IP:8084/health.txt"
