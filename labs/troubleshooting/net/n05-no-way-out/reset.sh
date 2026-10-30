#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/../../lib.sh"
need_root
stop_pidfile pricing
rm -rf "$TSHOOT_STATE/pricing-www" "$TSHOOT_STATE/pricing.log"
netlab_down
info "N05 cleaned"
