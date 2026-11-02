#!/usr/bin/env bash
# Run ministore WITHOUT containers, directly on Ubuntu (WSL2) — to understand the app before containerizing it.
#
# One-time setup:
#   sudo apt install -y postgresql redis-server golang-go nodejs npm python3-venv
#   sudo -u postgres psql -c "CREATE USER ministore PASSWORD 'ministore';" -c "CREATE DATABASE ministore OWNER ministore;"
#
# Usage:  ./apps/run-local.sh start | stop | status
set -euo pipefail
cd "$(dirname "$0")"
RUN=/tmp/ministore; mkdir -p "$RUN"

start() {
  sudo systemctl start postgresql redis-server

  [ -d "$RUN/venv" ] || python3 -m venv "$RUN/venv"
  "$RUN/venv/bin/pip" install -q -r catalog/requirements.txt
  (cd gateway && npm install --no-audit --no-fund --silent)
  (cd orders && go build -o "$RUN/orders" .)

  (cd catalog && DATABASE_URL=postgresql://ministore:ministore@localhost:5432/ministore \
     nohup "$RUN/venv/bin/uvicorn" app.main:app --host 0.0.0.0 --port 8001 --no-access-log > "$RUN/catalog.log" 2>&1 & echo $! > "$RUN/catalog.pid")
  (REDIS_ADDR=localhost:6379 CATALOG_URL=http://localhost:8001 \
     nohup "$RUN/orders" > "$RUN/orders.log" 2>&1 & echo $! > "$RUN/orders.pid")
  (cd gateway && CATALOG_URL=http://localhost:8001 ORDERS_URL=http://localhost:8002 \
     nohup node server.js > "$RUN/gateway.log" 2>&1 & echo $! > "$RUN/gateway.pid")

  sleep 3
  echo "ministore: http://localhost:8080   logs: $RUN/*.log"
}

stop() {
  for s in gateway orders catalog; do
    [ -f "$RUN/$s.pid" ] && kill -TERM "$(cat "$RUN/$s.pid")" 2>/dev/null && echo "SIGTERM -> $s"
    rm -f "$RUN/$s.pid"
  done
}

status() { ss -ltnp | grep -E ':(8080|8001|8002|5432|6379)\b' || echo "nothing listening"; }

"${1:-status}"
