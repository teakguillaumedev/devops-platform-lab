# N03 — The port squatter

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Network + systemd | ★★☆ | Oct 30 – Nov 5 | `ss -ltnp`, `systemctl status <PID>`, kill vs stop (Day 01) |

## Story
You want to start the new `orders` service on port **8002** (here simulated by `./start-orders.sh`).
It refuses to start. Someone on the team already "killed the process that was in the way"… and it is back.

## Symptoms
```bash
./start-orders.sh      # OSError: [Errno 98] Address already in use
```

## Your mission
1. Find **which process** holds port 8002, and **who keeps restarting it**.
2. Get rid of it properly (so it does not come back) and start `./start-orders.sh` successfully.

## Commands
```bash
sudo ./break.sh   |   ./start-orders.sh   |   sudo ./check.sh   |   sudo ./reset.sh
```
(needs systemd in WSL: `ps -p 1 -o comm=` must print `systemd`)

<details><summary>Hint 1</summary><code>sudo ss -ltnp 'sport = :8002'</code> gives the PID. Kill it, wait 2 seconds, look again: same PID?</details>
<details><summary>Hint 2</summary><code>systemctl status &lt;PID&gt;</code> tells you which unit owns a process. Day 01: desired state vs actual state.</details>

## Debrief
1. Why did `kill` not solve the problem? What is the difference between `kill` and `systemctl stop`?
2. Which Kubernetes object plays exactly the same role as `Restart=always` for a pod you delete by hand?
3. What does `systemd-run` create, and where is that unit defined (`systemctl cat`)?
