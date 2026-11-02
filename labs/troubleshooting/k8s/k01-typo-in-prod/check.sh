#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k01 web 90 || fail "deployment web is not available yet"
img=$(kubectl -n tshoot-k01 get deploy web -o jsonpath='{.spec.template.spec.containers[0].image}')
case "$img" in *:latest|*nginx) fail "image $img: pin a real version, no latest" ;; esac
pass "web runs 2 replicas with $img"
