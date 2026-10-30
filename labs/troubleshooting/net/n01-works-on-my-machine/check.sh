#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root

ss -ltn | grep -q ':8081\b' || fail "nothing listens on port 8081 any more"
ip netns exec "$NETNS" curl -sf --max-time 3 "http://$HOST_IP:8081/health.txt" | grep -q "inventory OK" \
  || fail "the client still cannot reach http://$HOST_IP:8081/health.txt"
pass "inventory is reachable from the client on port 8081"
