# D03 — Solution

**Root cause:** `f.read()` loads 200 MB, then `splitlines()` makes a second copy: far above the 96 MB cgroup limit.
The kernel OOM killer sends SIGKILL: no Python exception, no log → exit 137.

**Evidence**
```bash
docker inspect -f '{{.State.ExitCode}} {{.State.OOMKilled}}' tshoot-d03   # 137 true
docker stats   (while it runs)  /  sudo dmesg | grep -i oom              # "Memory cgroup out of memory: Killed process ..."
```

**Fix:** stream the file line by line, constant memory:
```python
count = errors = 0
with open(LOG, "rb") as f:
    for l in f:
        count += 1
        if b" ERROR " in l:
            errors += 1
print(f"report: {count} lines, {errors} errors", flush=True)
```

**Debrief**
1. SIGKILL cannot be caught: the process is gone before it can write anything.
2. CPU over limit → throttled (slower). Memory over limit → killed.
3. `kubectl describe pod` → *Last State: Terminated, Reason: OOMKilled*. Requests = scheduling guarantee, limits = hard cap.
