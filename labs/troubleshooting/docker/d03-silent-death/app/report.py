"""Nightly report: counts the ERROR lines in a big access log.

The log is generated at startup to simulate a 200 MB file mounted from the host.
"""
import os

LOG = "/tmp/access.log"
SIZE_MB = int(os.environ.get("LOG_SIZE_MB", "200"))

print(f"report: generating a {SIZE_MB} MB log file...", flush=True)
line = b"2026-10-30T02:00:00Z GET /api/products 200 12ms\n"
error = b"2026-10-30T02:00:01Z GET /api/orders ERROR 502 3001ms\n"
with open(LOG, "wb") as f:
    written, n = 0, 0
    while written < SIZE_MB * 1024 * 1024:
        chunk = error if n % 1000 == 0 else line
        f.write(chunk)
        written += len(chunk)
        n += 1

print("report: analysing...", flush=True)
with open(LOG, "rb") as f:
    content = f.read()            # load the whole file in memory
lines = content.splitlines()      # ...and a second copy, split in lines
errors = sum(1 for l in lines if b" ERROR " in l)

print(f"report: {len(lines)} lines, {errors} errors", flush=True)
print("report: done", flush=True)
