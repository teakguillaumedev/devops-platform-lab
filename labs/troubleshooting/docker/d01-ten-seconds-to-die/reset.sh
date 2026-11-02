#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
cd "$(dirname "$0")"
docker rm -f tshoot-d01 tshoot-d01-check >/dev/null 2>&1
docker rmi tshoot/d01 >/dev/null 2>&1
git checkout -- app 2>/dev/null && info "app/ restored to its broken version"
info "D01 cleaned"
