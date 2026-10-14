# Day 01 — Processes & systemd

## Key ideas
- Orphan: parent dies, child keeps running, adopted by PID 1 (systemd).
- Zombie: child is dead but parent never called wait(); can't be killed, fix the parent.
- systemd guarantees a *desired state*, not a process: a killed service comes back with a NEW PID.
- `Restart=always` + `RestartSec=3` → restart after ~3s. With `on-failure`, SIGTERM counts as clean → no restart.
- `kill` = change actual state → systemd reconciles. `systemctl stop` = change desired state → nothing to reconcile.
- Same pattern as Kubernetes: delete pod vs scale to 0.

## Commands
pstree -p · /proc/<pid>/status · ps -o pid,ppid,stat,cmd · journalctl -u <unit> -f · systemctl status/stop/enable --now
