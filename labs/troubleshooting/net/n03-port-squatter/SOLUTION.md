# N03 — Solution

**Root cause:** a transient systemd unit `legacy-metrics.service` with `Restart=always` holds port 8002.
`kill <PID>` changes the *actual* state; systemd still has the *desired* state "running" and restarts it 1 s later.

**Diagnosis**
```bash
sudo ss -ltnp 'sport = :8002'     # users:(("python3",pid=1234,...))
sudo kill 1234; sleep 2; sudo ss -ltnp 'sport = :8002'    # new PID!
systemctl status 1234             # → legacy-metrics.service
systemctl cat legacy-metrics      # Restart=always, under /run/systemd/transient/
```

**Fix:** `sudo systemctl stop legacy-metrics` (and `systemctl disable` for a real unit), then `./start-orders.sh`.

**Debrief**
1. `kill` sends a signal to a process. `systemctl stop` changes the desired state of the unit, then stops it.
2. A ReplicaSet (via a Deployment): delete a pod and the controller recreates it. Scale to 0 or delete the Deployment instead.
3. A *transient* unit, defined in `/run/systemd/transient/` (gone at reboot).
