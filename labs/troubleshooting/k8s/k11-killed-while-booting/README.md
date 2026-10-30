# K11 — Killed while booting

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★★ | Nov 27 – Dec 3 | liveness vs startup probes, `Liveness probe failed`, restart loops |

## Story
The `legacy` app needs ~45 seconds to warm up before it is healthy. It was given a liveness probe to restart it if it hangs. It now restarts forever and never becomes Ready.

## Symptoms
```bash
kubectl -n tshoot-k11 get pods -w
kubectl -n tshoot-k11 describe pod -l app=legacy | tail -15
```

## Your mission
Let `legacy` boot, **keeping the liveness probe as it is** (it is still needed once the app is up).

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

Count: `initialDelaySeconds + periodSeconds × failureThreshold`. How long does the app have to start?

</details>
<details><summary>Hint 2</summary>

There is a probe made exactly for slow starters, which disables liveness until it succeeds.

</details>

## Debrief (answer in your notes)
1. What would happen in production if you simply set `initialDelaySeconds: 60` on the liveness?
2. Startup, readiness, liveness: draw the timeline of a pod and when each probe runs.
3. Should a liveness probe check the database? (think about cascading restarts)
