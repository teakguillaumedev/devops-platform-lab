#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root
systemctl stop legacy-metrics 2>/dev/null || true
systemctl reset-failed legacy-metrics 2>/dev/null || true
rm -rf "$TSHOOT_STATE/orders-www"
info "N03 cleaned (stop ./start-orders.sh yourself with Ctrl+C if it still runs)"
