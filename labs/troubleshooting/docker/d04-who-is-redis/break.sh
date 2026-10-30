#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d04-redis tshoot-d04-app >/dev/null 2>&1 || true
docker build -q -t tshoot/d04 app >/dev/null
# Both containers are started "the simple way", without any --network option.
docker run -d --name tshoot-d04-redis redis:7-alpine >/dev/null
docker run -d --name tshoot-d04-app -e REDIS_HOST=tshoot-d04-redis tshoot/d04 >/dev/null
sleep 3
docker logs --tail 2 tshoot-d04-app
info "Incident ready. Redis is up (docker ps). Why can't the app find it?"
