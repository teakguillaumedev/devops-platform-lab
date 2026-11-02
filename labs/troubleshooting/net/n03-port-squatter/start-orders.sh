#!/usr/bin/env bash
# Simulates the orders service starting on port 8002 (runs in the foreground: Ctrl+C to stop).
mkdir -p /tmp/tshoot/orders-www && echo "orders OK" > /tmp/tshoot/orders-www/health.txt
echo "starting orders on :8002 ..."
exec python3 -m http.server 8002 --bind 0.0.0.0 --directory /tmp/tshoot/orders-www
