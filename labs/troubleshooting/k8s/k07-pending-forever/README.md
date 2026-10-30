# K07 — Pending forever

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 13 – 26 | scheduler, requests, `kubectl describe node`, `Insufficient cpu` |

## Story
A developer copied the resource settings of a big Java app from another cluster into the tiny `pdf-renderer` service. The pod stays `Pending`.

## Symptoms
```bash
kubectl -n tshoot-k07 get pods
kubectl get nodes
```

## Your mission
Schedule `pdf-renderer` with **sensible** requests and limits (it really uses ~50m CPU and ~30Mi of memory).

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

Pending = the scheduler found no node. `kubectl describe pod` → Events: `0/3 nodes are available: ...`

</details>
<details><summary>Hint 2</summary>

Compare the requests with `kubectl describe node` → *Allocatable* and *Allocated resources*.

</details>

## Debrief (answer in your notes)
1. Requests are used by whom, limits by whom?
2. What is a QoS class (Guaranteed / Burstable / BestEffort)? Which one do you get here?
3. Pending can have other causes: name 3 (taints, affinity, PVC...).
