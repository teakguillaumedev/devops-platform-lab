#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
cd "$(dirname "$0")"
kubectl apply -f broken.yaml >/dev/null
info "Incident ready in namespace(s): tshoot-k05"
