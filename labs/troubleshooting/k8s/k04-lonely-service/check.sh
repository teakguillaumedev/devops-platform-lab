#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need kubectl
k_fetch tshoot-k04 http://web | grep -qi nginx || fail "http://web does not answer"
pass "http://web answers"
