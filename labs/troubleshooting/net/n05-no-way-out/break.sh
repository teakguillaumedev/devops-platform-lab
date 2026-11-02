#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root; need ip python3
mkdir -p "$TSHOOT_STATE"

netlab_up
# The "other network": a second address on the host, in another subnet.
ip addr show dev tsh-host | grep -q 10.201.0.1 || ip addr add 10.201.0.1/24 dev tsh-host
# Make sure the client has no default route (that's the incident).
ip netns exec "$NETNS" ip route del default 2>/dev/null || true
start_http pricing 0.0.0.0 8086
info "Incident ready. Try: sudo ip netns exec $NETNS curl --max-time 3 http://10.201.0.1:8086/health.txt"
