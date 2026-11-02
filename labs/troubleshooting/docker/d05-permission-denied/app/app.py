"""Stores its state in /data/state.json at startup, then serves forever (simulated)."""
import json
import os
import time

print(f"app: running as uid={os.getuid()} gid={os.getgid()}", flush=True)
with open("/data/state.json", "w") as f:
    json.dump({"started_at": time.time()}, f)
print("app: state saved to /data/state.json — ready", flush=True)
while True:
    time.sleep(3600)
