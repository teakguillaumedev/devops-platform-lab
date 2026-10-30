# K05 — Knocking on the wrong door

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 13 – 26 | `port` vs `targetPort` vs `containerPort`, `kubectl port-forward`, connection refused |

## Story
This time the Service `api` **has** endpoints. But calls to `http://api` fail instantly.

## Symptoms
```bash
kubectl -n tshoot-k05 get endpointslices
kubectl -n tshoot-k05 run tmp --rm -it --image=busybox:1.36 --restart=Never -- wget -qO- -T 3 http://api
```

## Your mission
Make `http://api` (port 80) answer.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

Fails *instantly* = refused = the packet reaches the pod but nobody listens on that port (see net/N04).

</details>
<details><summary>Hint 2</summary>

Which port does nginx listen on in the pod? `kubectl -n tshoot-k05 exec deploy/api -- netstat -ltn` (or `ss`). Compare with the Service `targetPort`.

</details>

## Debrief (answer in your notes)
1. Explain `port`, `targetPort`, `containerPort` and `nodePort` in one sentence each.
2. Is `containerPort` required for traffic to work? What is it for?
3. How would `targetPort: http` (a named port) have made this mistake less likely?
