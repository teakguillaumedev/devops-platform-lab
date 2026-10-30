#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root; need systemd-run python3
[ "$(ps -p 1 -o comm=)" = systemd ] || { echo "systemd is not PID 1 — enable it in /etc/wsl.conf ([boot] systemd=true)" >&2; exit 1; }

systemctl stop legacy-metrics 2>/dev/null || true
systemctl reset-failed legacy-metrics 2>/dev/null || true
# A transient service with Restart=always: killing its process is not enough.
systemd-run --quiet --unit=legacy-metrics --description="Legacy metrics exporter (deprecated)" \
  -p Restart=always -p RestartSec=1 \
  python3 -m http.server 8002 --bind 0.0.0.0 --directory /tmp
sleep 1
info "Incident ready. Now run ./start-orders.sh"
