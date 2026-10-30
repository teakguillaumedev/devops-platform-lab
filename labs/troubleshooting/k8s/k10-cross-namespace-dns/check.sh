#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k10-app frontend 60 || fail "frontend not available"
kubectl -n tshoot-k10-data get svc api >/dev/null 2>&1 || fail "api must stay in tshoot-k10-data"
kubectl -n tshoot-k10-app exec deploy/frontend -- sh -c 'wget -qO- -T 3 "$BACKEND_URL"' 2>/dev/null | grep -qi nginx \
  || fail "frontend still cannot reach api"
pass "frontend reaches api across namespaces"
