#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_wait_available tshoot-k03 api 60 || fail "api is not available"
pw=$(kubectl -n tshoot-k03 exec deploy/api -- printenv DB_PASSWORD 2>/dev/null)
[ "$pw" = "s3cr3t-from-dba" ] || fail "DB_PASSWORD is not the value stored in the secret"
[ "$(kubectl -n tshoot-k03 get secret db-credentials -o jsonpath='{.data.password}' | base64 -d)" = "s3cr3t-from-dba" ] \
  || fail "the secret was modified"
pass "api started with credentials from db-credentials"
