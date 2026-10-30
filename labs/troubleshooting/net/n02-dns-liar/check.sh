#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"

resolved=$(getent hosts example.com | awk '{print $1}' | head -1)
[ -n "$resolved" ] || fail "example.com does not resolve at all now (getent hosts example.com is empty — removed too much, or no DNS/internet in WSL?)"
[ "$resolved" != "192.0.2.10" ] || fail "applications still resolve example.com to 192.0.2.10"
grep -q '^127.0.0.1' /etc/hosts || fail "/etc/hosts lost its localhost line — you removed too much"
curl -s -o /dev/null --max-time 5 http://example.com \
  && pass "example.com resolves to $resolved and answers" \
  || pass "example.com resolves to $resolved (HTTP not reachable: no internet?)"
