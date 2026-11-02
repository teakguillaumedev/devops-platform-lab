#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k09 frontend 60 && k_wait_available tshoot-k09 backend 60 || fail "pods not available"
kubectl -n tshoot-k09 get networkpolicy default-deny-ingress >/dev/null 2>&1 || fail "default-deny-ingress was deleted"
kubectl -n tshoot-k09 exec deploy/frontend -- wget -qO- -T 3 http://backend 2>/dev/null | grep -qi nginx \
  || fail "frontend still cannot reach backend"
k_fetch tshoot-k09 http://backend | grep -qi nginx && fail "a random pod can reach backend too: the policy is too open"
pass "frontend reaches backend, other pods are still blocked"
