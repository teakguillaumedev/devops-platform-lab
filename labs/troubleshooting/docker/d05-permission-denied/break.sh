#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d05 >/dev/null 2>&1 || true
docker build -q -t tshoot/d05 app >/dev/null
docker run --name tshoot-d05 tshoot/d05 || true
info "Incident ready. Security review says: the container must NOT run as root."
