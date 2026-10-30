#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
kubectl delete namespace tshoot-k10-app tshoot-k10-data --ignore-not-found --wait=false >/dev/null
info "K10 cleaned (namespace deletion runs in the background)"
