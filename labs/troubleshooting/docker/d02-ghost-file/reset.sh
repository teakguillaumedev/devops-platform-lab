#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
cd "$(dirname "$0")"
docker rm -f tshoot-d02 >/dev/null 2>&1
docker rmi tshoot/d02 >/dev/null 2>&1
git checkout -- app 2>/dev/null
info "D02 cleaned (run break.sh again to re-create the incident)"
