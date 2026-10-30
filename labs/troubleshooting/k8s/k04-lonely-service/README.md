# K04 — The lonely Service

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 13 – 26 | Service selectors, labels, EndpointSlices, `kubectl get endpointslices` |

## Story
Pods of `web` are Running and Ready. The Service `web` exists. Yet nothing answers on `http://web`.

## Symptoms
```bash
kubectl -n tshoot-k04 get pods,svc
kubectl -n tshoot-k04 run tmp --rm -it --image=busybox:1.36 --restart=Never -- wget -qO- -T 3 http://web
```

## Your mission
Make `http://web` answer inside the namespace.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

A Service doesn't know pods: it knows a **label selector**. Who matches it? `kubectl get endpointslices -n tshoot-k04`

</details>
<details><summary>Hint 2</summary>

`kubectl -n tshoot-k04 get pods --show-labels` vs `kubectl -n tshoot-k04 get svc web -o jsonpath='{.spec.selector}'`

</details>

## Debrief (answer in your notes)
1. What is an EndpointSlice and who maintains it?
2. The Deployment has its own selector too: why couldn't the same typo happen there?
3. Which single command would you run first next time a Service 'does not work'?
