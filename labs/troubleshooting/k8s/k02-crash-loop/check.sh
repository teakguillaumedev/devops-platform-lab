#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k02 worker 60 || fail "worker is not available"
kubectl -n tshoot-k02 logs -l app=worker --tail=20 2>/dev/null | grep -q "started in production mode" \
  || fail "worker runs, but not in production mode"
pass "worker started in production mode"
