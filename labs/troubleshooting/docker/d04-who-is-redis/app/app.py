"""Talks to Redis every 2 seconds with a raw PING (no library needed).

  python app.py          loop forever (the service)
  python app.py --once   one attempt, exit 0 on success (used by check.sh)
"""
import os
import socket
import sys
import time

HOST = os.environ.get("REDIS_HOST", "localhost")
PORT = int(os.environ.get("REDIS_PORT", "6379"))


def ping() -> str:
    try:
        ip = socket.gethostbyname(HOST)
    except socket.gaierror as exc:
        raise RuntimeError(f"cannot resolve '{HOST}': {exc}") from None
    with socket.create_connection((ip, PORT), timeout=2) as s:
        s.sendall(b"*1\r\n$4\r\nPING\r\n")
        return f"{HOST} ({ip}) answered {s.recv(64).strip().decode()}"


once = "--once" in sys.argv
while True:
    try:
        print("app: " + ping(), flush=True)
        if once:
            sys.exit(0)
    except Exception as exc:
        print(f"app: ERROR {exc}", flush=True)
        if once:
            sys.exit(1)
    time.sleep(2)
