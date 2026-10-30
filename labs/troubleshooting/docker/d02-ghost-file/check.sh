#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need docker
cd "$(dirname "$0")"

docker build -q -t tshoot/d02 app >/dev/null || fail "image does not build"
out=$(docker run --rm tshoot/d02 2>&1)
echo "$out" | grep -q "app: ready" || fail "container output: $out"
echo "$out" | grep -q "config ready" || fail "the entrypoint was bypassed: it must still run"
pass "entrypoint runs and the app starts"
