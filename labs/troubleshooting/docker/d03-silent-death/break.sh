#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d03 >/dev/null 2>&1 || true
docker build -q -t tshoot/d03 app >/dev/null
# The platform team imposes this limit on every batch job. It is NOT negotiable.
docker run --name tshoot-d03 --memory 96m --memory-swap 96m tshoot/d03 || true
info "Incident ready. The job died. No stack trace. Why?  docker inspect tshoot-d03 --format '{{json .State}}'"
