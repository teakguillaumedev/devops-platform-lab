#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root

if systemctl is-active --quiet legacy-metrics; then
  fail "legacy-metrics.service is still active: it will keep taking the port back"
fi
curl -sf --max-time 2 http://127.0.0.1:8002/health.txt | grep -q "orders OK" \
  || fail "legacy service is gone, now start ./start-orders.sh (in another terminal) and run check again"
pass "port 8002 belongs to orders, and the squatter will not come back"
