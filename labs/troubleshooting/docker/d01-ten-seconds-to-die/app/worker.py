"""A background worker that processes jobs and MUST finish its current job before exiting."""
import signal
import sys
import time

running = True


def on_sigterm(signum, _frame):
    global running
    print(f"worker: received signal {signum}, finishing current job then exiting", flush=True)
    running = False


signal.signal(signal.SIGTERM, on_sigterm)

print("worker: started", flush=True)
job = 0
while running:
    job += 1
    print(f"worker: processing job {job}", flush=True)
    time.sleep(1)

print("worker: graceful shutdown complete, bye", flush=True)
sys.exit(0)
