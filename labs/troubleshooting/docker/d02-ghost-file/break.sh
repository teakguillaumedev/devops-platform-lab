#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

# Simulates a colleague who edited entrypoint.sh with a Windows editor and committed it.
sed -i 's/\r*$/\r/' app/entrypoint.sh
docker rm -f tshoot-d02 >/dev/null 2>&1 || true
docker build -q -t tshoot/d02 app >/dev/null
docker run --name tshoot-d02 tshoot/d02 || true
info "Incident ready. The file is right there in the image... isn't it?  docker run --rm --entrypoint ls tshoot/d02 -l /entrypoint.sh"
