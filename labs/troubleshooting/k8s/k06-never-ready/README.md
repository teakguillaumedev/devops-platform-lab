# K06 — Running but never Ready

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 13 – 26 | readiness probes, `READY 0/1`, Events `Readiness probe failed` |

## Story
The new `shop` pods are `Running` but stuck at `0/1`. The rollout never finishes. The app itself is fine: a port-forward shows the page.

## Symptoms
```bash
kubectl -n tshoot-k06 get pods
kubectl -n tshoot-k06 port-forward deploy/shop 8080:80   # then curl localhost:8080 → works!
```

## Your mission
Make the pods Ready **while keeping a meaningful readiness probe** (an HTTP check on nginx).

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

`kubectl describe pod` → Events: `Readiness probe failed: HTTP probe failed with statuscode: ...`

</details>
<details><summary>Hint 2</summary>

Which paths does a default nginx serve? Try them with the port-forward and curl.

</details>

## Debrief (answer in your notes)
1. Readiness vs liveness: what happens to the pod when each one fails?
2. Why does a failing readiness probe block a rolling update (`maxUnavailable`)?
3. Look at `apps/`: which endpoint of ministore is made for readiness, and why does it check the database?
