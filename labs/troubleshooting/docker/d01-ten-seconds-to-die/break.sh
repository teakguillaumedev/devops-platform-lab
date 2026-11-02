#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d01 >/dev/null 2>&1 || true
docker build -q -t tshoot/d01 app >/dev/null
docker run -d --name tshoot-d01 tshoot/d01 >/dev/null
info "Incident ready. Try: time docker stop tshoot-d01 ; docker inspect -f '{{.State.ExitCode}}' tshoot-d01 ; docker logs tshoot-d01 | tail"
