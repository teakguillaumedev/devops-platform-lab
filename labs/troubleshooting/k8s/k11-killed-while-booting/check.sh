#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
info "waiting up to 2 minutes for legacy to boot..."
k_wait_available tshoot-k11 legacy 120 || fail "legacy did not become Ready"
live=$(kubectl -n tshoot-k11 get deploy legacy -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.periodSeconds}/{.spec.template.spec.containers[0].livenessProbe.failureThreshold}/{.spec.template.spec.containers[0].livenessProbe.initialDelaySeconds}')
[ "$live" = "5/3/5" ] || fail "the liveness probe was changed ($live): leave it as it is"
restarts=$(kubectl -n tshoot-k11 get pods -l app=legacy -o jsonpath='{range .items[?(@.status.containerStatuses[0].ready==true)]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' | head -1)
[ "$restarts" = 0 ] || fail "the pod restarted $restarts time(s) while booting"
pass "legacy booted without restarts, liveness untouched"
