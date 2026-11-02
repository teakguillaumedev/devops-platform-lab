#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_fetch tshoot-k05 http://api:80 | grep -qi nginx || fail "http://api:80 does not answer"
pass "http://api answers on port 80"
