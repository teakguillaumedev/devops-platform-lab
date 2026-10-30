#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root
stop_pidfile inventory
rm -rf "$TSHOOT_STATE/start-inventory.sh" "$TSHOOT_STATE/inventory-www" "$TSHOOT_STATE/inventory.log"
netlab_down
info "N01 cleaned"
