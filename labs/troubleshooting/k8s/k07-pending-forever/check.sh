#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k07 pdf-renderer 60 || fail "pdf-renderer is not running"
mem=$(kubectl -n tshoot-k07 get deploy pdf-renderer -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')
[ -n "$mem" ] || fail "keep a memory limit"
pass "pdf-renderer scheduled (memory limit: $mem)"
