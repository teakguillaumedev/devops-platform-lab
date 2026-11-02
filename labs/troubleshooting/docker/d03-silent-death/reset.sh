#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
cd "$(dirname "$0")"
docker rm -f tshoot-d03 tshoot-d03-check >/dev/null 2>&1
docker rmi tshoot/d03 >/dev/null 2>&1
rm -f /tmp/tshoot-d03.out
git checkout -- app 2>/dev/null
info "D03 cleaned"
