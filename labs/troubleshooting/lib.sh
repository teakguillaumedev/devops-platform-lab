# Shared helpers for troubleshooting scenarios. Sourced by break.sh / check.sh / reset.sh.
# shellcheck shell=bash

TSHOOT_STATE=/tmp/tshoot          # runtime files (pid files, generated launch scripts)
NETNS=tshoot-client               # network namespace used as "another machine"
HOST_IP=10.200.0.1
CLIENT_IP=10.200.0.2

pass() { printf '\033[32mPASS\033[0m %s\n' "$*"; exit 0; }
fail() { printf '\033[31mFAIL\033[0m %s\n' "$*"; exit 1; }
info() { printf '\033[36m>>\033[0m %s\n' "$*"; }

need_root() {
  [ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0" >&2; exit 1; }
}

need() {
  for c in "$@"; do
    command -v "$c" >/dev/null || { echo "Missing command: $c" >&2; exit 1; }
  done
}

# ---------- network lab: a second "machine" = a network namespace linked by a veth pair ----------
#   host (root namespace)  tsh-host 10.200.0.1/24  <══ veth ══>  tsh-client 10.200.0.2/24  (namespace tshoot-client)
netlab_up() {
  ip netns list | grep -qw "$NETNS" && return 0
  ip netns add "$NETNS"
  ip link add tsh-host type veth peer name tsh-client
  ip link set tsh-client netns "$NETNS"
  ip addr add "$HOST_IP/24" dev tsh-host
  ip link set tsh-host up
  ip netns exec "$NETNS" ip addr add "$CLIENT_IP/24" dev tsh-client
  ip netns exec "$NETNS" ip link set tsh-client up
  ip netns exec "$NETNS" ip link set lo up
}

netlab_down() {
  ip netns del "$NETNS" 2>/dev/null || true
  ip link del tsh-host 2>/dev/null || true   # deleting one end of a veth deletes both
}

# Start a tiny HTTP server in the background. Usage: start_http <name> <bind-address> <port>
# It serves a directory containing health.txt. PID saved in $TSHOOT_STATE/<name>.pid
start_http() {
  local name=$1 addr=$2 port=$3 dir="$TSHOOT_STATE/$1-www"
  mkdir -p "$dir"
  echo "$name OK" > "$dir/health.txt"
  nohup python3 -m http.server "$port" --bind "$addr" --directory "$dir" >"$TSHOOT_STATE/$name.log" 2>&1 &
  echo $! > "$TSHOOT_STATE/$name.pid"
  sleep 0.5
}

stop_pidfile() {
  local f="$TSHOOT_STATE/$1.pid"
  [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null || true
  rm -f "$f"
}

# ---------- kubernetes ----------
# Run a throwaway busybox pod in a namespace and fetch a URL. Usage: k_fetch <namespace> <url>
k_fetch() {
  kubectl -n "$1" run "tshoot-probe-$RANDOM" --rm -i --restart=Never --quiet \
    --image=busybox:1.36 --command -- wget -qO- -T 3 "$2" 2>/dev/null
}

# Wait until a deployment has all replicas available. Usage: k_wait_available <ns> <deploy> [seconds]
k_wait_available() {
  kubectl -n "$1" rollout status "deploy/$2" --timeout="${3:-60}s" >/dev/null 2>&1
}
