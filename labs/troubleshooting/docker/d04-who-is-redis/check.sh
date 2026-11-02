#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker

for c in tshoot-d04-redis tshoot-d04-app; do
  [ "$(docker inspect -f '{{.State.Running}}' $c 2>/dev/null)" = true ] || fail "container $c is not running"
done
host=$(docker exec tshoot-d04-app printenv REDIS_HOST)
case "$host" in
  [0-9]*.[0-9]*.[0-9]*.[0-9]*) fail "REDIS_HOST=$host is an IP address: it will change at the next restart. Use a name." ;;
  localhost|127.0.0.1) fail "REDIS_HOST=localhost: inside a container, localhost is the container itself" ;;
esac
out=$(docker exec tshoot-d04-app python app.py --once 2>&1) || fail "$out"
docker inspect -f '{{json .HostConfig.Links}}' tshoot-d04-app | grep -q tshoot-d04-redis \
  && fail "--link is deprecated: find the modern way"
pass "$out"
