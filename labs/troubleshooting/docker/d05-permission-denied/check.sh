#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d05-check >/dev/null 2>&1
docker build -q -t tshoot/d05 app >/dev/null || fail "image does not build"
docker run -d --name tshoot-d05-check tshoot/d05 >/dev/null
sleep 2
logs=$(docker logs tshoot-d05-check 2>&1)
uid=$(docker exec tshoot-d05-check id -u 2>/dev/null)
perms=$(docker exec tshoot-d05-check stat -c '%a' /data 2>/dev/null)
docker rm -f tshoot-d05-check >/dev/null

echo "$logs" | grep -q "ready" || fail "app did not start: $(echo "$logs" | tail -1)"
[ -n "$uid" ] && [ "$uid" != 0 ] || fail "the container runs as root (uid=$uid): not allowed"
case "$perms" in *7) fail "/data is world-writable ($perms): chmod 777 is not a fix" ;; esac
pass "app runs as uid $uid and writes to /data (mode $perms)"
