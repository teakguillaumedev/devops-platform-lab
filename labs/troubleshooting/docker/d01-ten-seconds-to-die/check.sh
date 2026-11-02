#!/usr/bin/env bash
# Rebuilds the image from app/ (your fixed version), runs it, stops it and measures.
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d01-check >/dev/null 2>&1
docker build -q -t tshoot/d01 app >/dev/null || fail "image does not build"
docker run -d --name tshoot-d01-check tshoot/d01 >/dev/null
sleep 3
start=$(date +%s%N)
docker stop tshoot-d01-check >/dev/null
ms=$(( ($(date +%s%N) - start) / 1000000 )); elapsed="$((ms / 1000)).$(printf %03d $((ms % 1000)))"
code=$(docker inspect -f '{{.State.ExitCode}}' tshoot-d01-check)
logs=$(docker logs tshoot-d01-check 2>&1)
docker rm tshoot-d01-check >/dev/null

echo "$logs" | grep -q "graceful shutdown complete" || fail "the worker never logged its graceful shutdown (stop took ${elapsed}s, exit code $code)"
[ "$code" = 0 ] || fail "exit code $code (expected 0)"
(( ms < 4000 )) || fail "docker stop took ${elapsed}s"
pass "docker stop took ${elapsed}s, worker finished its job, exit code 0"
