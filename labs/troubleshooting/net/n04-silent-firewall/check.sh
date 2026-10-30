#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root

ip netns exec "$NETNS" curl -sf --max-time 3 "http://$HOST_IP:8084/health.txt" | grep -q "billing OK" \
  || fail "billing still unreachable from the client"
ss -ltn | grep -q ':8085\b' && fail "something listens on 8085: reports was supposed to stay decommissioned"
pass "billing reachable from the client, reports still down (as intended)"
