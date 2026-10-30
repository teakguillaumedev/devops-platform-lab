# K11 — Solution

**Root cause:** Liveness gives the app 5 + 5×3 ≈ 20 s, but it needs 45 s: it is killed before being healthy, forever.

**Diagnosis**
```bash
kubectl -n tshoot-k11 describe pod -l app=legacy | grep -E 'Liveness|Killing'   # failed liveness probe, will be restarted
```

**Fix**
```bash
Add a startupProbe to the container (kubectl edit deploy legacy -n tshoot-k11):
  startupProbe:
    exec: {command: ["cat", "/tmp/healthy"]}
    periodSeconds: 5
    failureThreshold: 18     # up to 90 s to boot
# liveness/readiness only start after the startupProbe succeeds
```

**Debrief**
1. A hung app would wait 60 s before its first check, after every restart; and boot time varies (cold cache, slow node).
2. startup (until success, then stops) → readiness (all the time, controls traffic) + liveness (all the time, controls restarts).
3. No: if the DB is down, every pod restarts, which doesn't fix the DB and amplifies the outage. Liveness = 'is this process stuck?'.
