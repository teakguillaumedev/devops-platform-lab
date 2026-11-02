#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker rm -f tshoot-d03-check >/dev/null 2>&1
docker build -q -t tshoot/d03 app >/dev/null || fail "image does not build"
docker run --name tshoot-d03-check --memory 96m --memory-swap 96m tshoot/d03 >/tmp/tshoot-d03.out 2>&1
code=$(docker inspect -f '{{.State.ExitCode}}' tshoot-d03-check)
oom=$(docker inspect -f '{{.State.OOMKilled}}' tshoot-d03-check)
docker rm tshoot-d03-check >/dev/null

[ "$oom" = false ] || fail "still OOMKilled (exit $code) with the 96 MB limit"
[ "$code" = 0 ] || fail "exit code $code: $(tail -3 /tmp/tshoot-d03.out)"
grep -q "errors" /tmp/tshoot-d03.out || fail "no report printed"
result=$(grep "lines," /tmp/tshoot-d03.out)
echo "$result" | grep -qE '[0-9]+ lines, [1-9][0-9]* errors' || fail "unexpected report: $result"
pass "job finished inside 96 MB: $result"
