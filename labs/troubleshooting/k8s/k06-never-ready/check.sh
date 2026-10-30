#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k06 shop 60 || fail "shop pods are not Ready"
kubectl -n tshoot-k06 get deploy shop -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' | grep -q . \
  || fail "the HTTP readiness probe was removed: keep one"
pass "shop is Ready with an HTTP readiness probe"
