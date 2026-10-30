#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root; need ip python3 curl
mkdir -p "$TSHOOT_STATE"

netlab_up
cat > "$TSHOOT_STATE/start-inventory.sh" <<'EOF'
#!/usr/bin/env bash
# inventory API launcher — edit me, then run me again
BIND_ADDRESS=127.0.0.1
PORT=8081
mkdir -p /tmp/tshoot/inventory-www && echo "inventory OK" > /tmp/tshoot/inventory-www/health.txt
[ -f /tmp/tshoot/inventory.pid ] && kill "$(cat /tmp/tshoot/inventory.pid)" 2>/dev/null && sleep 0.5
nohup python3 -m http.server "$PORT" --bind "$BIND_ADDRESS" --directory /tmp/tshoot/inventory-www >/tmp/tshoot/inventory.log 2>&1 &
echo $! > /tmp/tshoot/inventory.pid
echo "inventory started (pid $!)"
EOF
chmod +x "$TSHOOT_STATE/start-inventory.sh"
"$TSHOOT_STATE/start-inventory.sh" >/dev/null
sleep 0.5
info "Incident ready. Client namespace: $NETNS ($CLIENT_IP). Server: $HOST_IP:8081"
