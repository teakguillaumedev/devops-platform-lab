#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
cd "$(dirname "$0")"
docker rm -f tshoot-d05 tshoot-d05-check >/dev/null 2>&1
docker rmi tshoot/d05 >/dev/null 2>&1
git checkout -- app 2>/dev/null
info "D05 cleaned"
