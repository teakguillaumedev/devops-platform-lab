#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
docker rm -f tshoot-d04-redis tshoot-d04-app >/dev/null 2>&1
docker rmi tshoot/d04 >/dev/null 2>&1
for n in $(docker network ls --filter name=tshoot -q); do docker network rm "$n" >/dev/null; done
info "D04 cleaned (networks named *tshoot* removed too)"
