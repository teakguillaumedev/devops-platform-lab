# K01 — The typo that stops production

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★☆☆ | Nov 13 – 26 | `kubectl get pods`, `kubectl describe`, Events, ImagePullBackOff |

## Story
A new version of the `web` frontend was deployed 5 minutes ago. Users see nothing changed, and the pods look odd.

## Symptoms
```bash
kubectl -n tshoot-k01 get pods
kubectl -n tshoot-k01 rollout status deploy/web --timeout=10s
```

## Your mission
Get the 2 replicas of `web` running with **nginx 1.27 on Alpine**. Do not use the `latest` tag.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

`kubectl describe pod` and read the **Events** at the bottom, from the oldest to the newest.

</details>
<details><summary>Hint 2</summary>

ErrImagePull → ImagePullBackOff: the kubelet waits longer and longer between attempts. Compare the image name with what exists on Docker Hub, letter by letter.

</details>

## Debrief (answer in your notes)
1. What is the difference between `ErrImagePull` and `ImagePullBackOff`?
2. Give 3 other root causes of ImagePullBackOff (think private registry).
3. Why is `:latest` forbidden in production? What is an image digest?
