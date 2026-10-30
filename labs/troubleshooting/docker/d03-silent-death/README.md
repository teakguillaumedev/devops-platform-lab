# D03 — Silent death

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Docker | ★★☆ | Nov 6 – 12 | cgroups memory (Day 02), `docker inspect`, OOMKilled, `docker stats`, `dmesg` |

## Story
The nightly report job dies every night. The logs stop at `report: analysing...`: no Python error, no stack trace.
The platform team runs every batch job with a **96 MB** memory limit, and they will **not** raise it.

## Symptoms
```bash
docker logs tshoot-d03                               # stops after "analysing..."
docker inspect -f '{{.State.ExitCode}}' tshoot-d03    # ?
```

## Your mission
1. **Prove** what killed the job (two independent pieces of evidence).
2. Change `app/report.py` so the job completes with the **same result** inside the 96 MB limit,
   whatever the size of the log.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh
```

<details><summary>Hint 1</summary>137 = 128 + 9. Who sends SIGKILL to a process without asking? <code>docker inspect -f '{{.State.OOMKilled}}'</code></details>
<details><summary>Hint 2</summary>How much memory does <code>f.read()</code> on a 200 MB file take? And <code>splitlines()</code> right after? A file object is iterable line by line.</details>

## Debrief
1. Why can't the Python program print an error before dying?
2. CPU limit vs memory limit: what happens when each is exceeded? (Day 02: compressible vs incompressible)
3. In Kubernetes, where do you read `OOMKilled`, and what is the difference between `requests` and `limits`?
