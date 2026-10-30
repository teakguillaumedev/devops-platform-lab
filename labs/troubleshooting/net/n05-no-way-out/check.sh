#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root

ip netns exec "$NETNS" curl -sf --max-time 3 http://10.201.0.1:8086/health.txt | grep -q "pricing OK" \
  || fail "pricing still unreachable from the client"
pass "client reaches pricing on 10.201.0.1 (route: $(ip netns exec "$NETNS" ip route get 10.201.0.1 | head -1 | xargs))"
