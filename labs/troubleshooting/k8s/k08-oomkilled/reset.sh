#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
kubectl delete namespace tshoot-k08 --ignore-not-found --wait=false >/dev/null
info "K08 cleaned (namespace deletion runs in the background)"
