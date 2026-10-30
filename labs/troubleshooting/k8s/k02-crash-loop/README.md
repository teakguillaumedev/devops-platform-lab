# K02 — CrashLoopBackOff

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★☆☆ | Nov 13 – 26 | `kubectl logs`, `kubectl logs --previous`, restart count, env vars |

## Story
The `worker` pod restarts endlessly. The image is the same one that works in staging.

## Symptoms
```bash
kubectl -n tshoot-k02 get pods -w        # RESTARTS keeps growing
```

## Your mission
Make `worker` start in **production** mode and stay up.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

A container that exits is restarted, then the kubelet waits 10 s, 20 s, 40 s... up to 5 min: that's the *BackOff*.

</details>
<details><summary>Hint 2</summary>

`kubectl -n tshoot-k02 logs deploy/worker --previous` shows the logs of the container that just died. Then compare with `kubectl get deploy worker -o yaml`.

</details>

## Debrief (answer in your notes)
1. `kubectl logs` vs `kubectl logs --previous`: when do you need each one?
2. Exit code 1 vs 137 vs 143 in `kubectl describe pod` → *Last State*: what does each tell you?
3. How could a ConfigMap + `envFrom` have avoided this kind of typo?
