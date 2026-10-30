# D01 — Solution

**Root cause:** `start.sh` runs `python` as a **child**. PID 1 is `/bin/sh`. `docker stop` sends SIGTERM to PID 1 only;
`sh` installed no handler and the kernel ignores unhandled signals for PID 1 → nothing happens → after 10 s Docker sends
SIGKILL → exit **137**, the worker never ran its handler.

**Diagnosis**
```bash
docker exec tshoot-d01 ps -o pid,args    # 1 /bin/sh /app/start.sh ; 7 python /app/worker.py
```

**Fix (preferred):** last line of `start.sh` → `exec python /app/worker.py` (python replaces the shell and becomes PID 1).
Alternatives: `docker run --init` / `tini` as entrypoint (forwards signals, reaps zombies), or `trap` + forward in the script.

**Debrief**
1. 10 s = default `--stop-timeout`. 137 = 128 + 9 (SIGKILL). 143 = 128 + 15: the process died of an unhandled SIGTERM.
   Exit 0 = it handled it and exited cleanly.
2. `exec`: simplest, no extra process. `tini`: when you can't touch the script, or the app spawns children (zombie reaping).
3. `terminationGracePeriodSeconds` (default 30 s), then SIGKILL. Plus `preStop` hooks.
