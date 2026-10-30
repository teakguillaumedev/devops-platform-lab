#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k08 cache 90 || fail "cache is not available"
sleep 5
kubectl -n tshoot-k08 logs deploy/cache | grep -q "cache warmed" || fail "cache did not finish warming"
lim=$(kubectl -n tshoot-k08 get deploy cache -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')
[ -n "$lim" ] || fail "keep a memory limit"
case "$lim" in *Gi|*G) n=${lim%%G*}; n=${n%i}; [ "$n" -le 1 ] || fail "limit $lim is far too generous for a 150 MB need" ;; esac
pass "cache runs with limits.memory=$lim"
