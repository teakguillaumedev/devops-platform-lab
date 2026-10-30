#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k12 notes 90 || fail "notes is not running"
claim=$(kubectl -n tshoot-k12 get deploy notes -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}')
[ -n "$claim" ] || fail "notes must keep using a PVC (no emptyDir)"
[ "$(kubectl -n tshoot-k12 get pvc "$claim" -o jsonpath='{.status.phase}')" = Bound ] || fail "PVC $claim is not Bound"
size=$(kubectl -n tshoot-k12 get pvc "$claim" -o jsonpath='{.spec.resources.requests.storage}')
[ "$size" = 1Gi ] || fail "PVC size is $size, expected 1Gi"
pass "notes runs on PVC $claim ($size, $(kubectl -n tshoot-k12 get pvc "$claim" -o jsonpath='{.spec.storageClassName}'))"
