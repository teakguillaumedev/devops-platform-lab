# D01 — Ten seconds to die

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Docker | ★★☆ | Nov 6 – 12 | PID 1, signals, `exec`, exit codes 137/143 (Day 02) |

## Story
A job worker runs in a container. Its code handles SIGTERM perfectly: it finishes the current job, then exits.
Yet every deployment, `docker stop` hangs for 10 seconds and the job in progress is lost.
The developer: "My signal handler works, I tested it with `kill` on my laptop."

## Symptoms
```bash
time docker stop tshoot-d01                        # ~10 s
docker inspect -f '{{.State.ExitCode}}' tshoot-d01  # 137
docker logs tshoot-d01 | tail -3                    # no "graceful shutdown" line
```

## Your mission
Fix `app/` (Dockerfile and/or start.sh) so that `docker stop` is near-instant, the worker logs its graceful
shutdown and exits with 0. **Keep `start.sh`** (in real life it does useful setup).

## Commands
```bash
./break.sh   |   ./check.sh (rebuilds from app/)   |   ./reset.sh (also restores app/)
```

<details><summary>Hint 1</summary><code>docker exec tshoot-d01 ps -o pid,args</code> — who is PID 1?</details>
<details><summary>Hint 2</summary>The kernel protects PID 1: a signal with no handler installed is ignored. Does <code>sh</code> install a SIGTERM handler?</details>

## Debrief
1. Why 10 seconds, and why exactly 137? What would 143 have meant?
2. Two different fixes are possible. Which one would you choose and why? What does `tini` / `docker run --init` solve?
3. Same question in Kubernetes: which field replaces the 10 s, and what happens when it expires?
