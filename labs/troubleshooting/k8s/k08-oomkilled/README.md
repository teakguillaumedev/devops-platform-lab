# K08 — OOMKilled

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 27 – Dec 3 | limits, `Last State: Terminated, Reason: OOMKilled`, exit 137, `kubectl top` |

## Story
The `cache` service loads 150 MB of reference data in memory at startup, by design. It restarts in a loop.

## Symptoms
```bash
kubectl -n tshoot-k08 get pods
kubectl -n tshoot-k08 describe pod -l app=cache | grep -A5 'Last State'
```

## Your mission
Make `cache` run stably. Its real need is ~150 MB: size requests and limits accordingly (not 4 GB).

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

`Last State` → `Reason: OOMKilled`, `Exit Code: 137`. Same mechanism as docker/D03 and Day 02.

</details>
<details><summary>Hint 2</summary>

Set `requests.memory` close to the real usage and `limits.memory` with a margin.

</details>

## Debrief (answer in your notes)
1. Who kills the container: the kubelet or the kernel?
2. What happens on a node when the sum of the limits is greater than its memory, and pods really use it?
3. D03 fixed the code, K08 fixes the limit: how do you decide which one is right?
