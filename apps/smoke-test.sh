#!/usr/bin/env bash
# End-to-end smoke test of ministore through the gateway.
# Usage: ./apps/smoke-test.sh [gateway_url]      (default http://localhost:8080)
# Exit code 0 = everything works. Reuse it later in CI and after each deployment.
set -euo pipefail

GW="${1:-http://localhost:8080}"
fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "ok   $*"; }

code=$(curl -s -o /tmp/smoke.json -w '%{http_code}' "$GW/readyz") || fail "gateway unreachable at $GW"
[ "$code" = 200 ] || fail "/readyz returned $code: $(cat /tmp/smoke.json)"
pass "gateway ready (catalog + orders ready)"

count=$(curl -sf "$GW/api/products" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))') \
  || fail "GET /api/products"
[ "$count" -ge 1 ] || fail "no products returned"
pass "catalog returns $count products"

id=$(curl -sf -X POST "$GW/api/orders" -H 'Content-Type: application/json' -d '{"product_id":1,"quantity":2}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])') || fail "POST /api/orders"
pass "order #$id created"

curl -sf "$GW/api/orders" | grep -q "\"id\": *$id\b" || fail "order #$id not listed"
pass "order #$id listed"

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$GW/api/orders" -H 'Content-Type: application/json' -d '{"product_id":9999,"quantity":1}')
[ "$code" = 404 ] || fail "unknown product should give 404, got $code"
pass "unknown product -> 404"

curl -sf "$GW/metrics" | grep -q '^http_requests_total' || fail "gateway /metrics"
pass "metrics exposed"

echo "SMOKE TEST PASSED"
