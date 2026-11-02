# K03 — CreateContainerConfigError

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 13 – 26 | Secrets, `secretKeyRef`, `kubectl describe`, `kubectl get secret -o jsonpath` |

## Story
The `api` pod never starts: no logs at all, `kubectl logs` returns an error. The secret `db-credentials` exists, the DBA created it this morning.

## Symptoms
```bash
kubectl -n tshoot-k03 get pods
kubectl -n tshoot-k03 logs deploy/api
```

## Your mission
Start `api` with `DB_USER` and `DB_PASSWORD` coming from the existing secret. **Don't modify the secret.**

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

Why are there no logs? Has the container ever been created? `kubectl describe pod` → Events.

</details>
<details><summary>Hint 2</summary>

List the keys of the secret: `kubectl -n tshoot-k03 get secret db-credentials -o jsonpath='{.data}'`.

</details>

## Debrief (answer in your notes)
1. Why doesn't this error produce any container logs?
2. base64 is not encryption: how do you read a secret value, and how do you protect secrets for real (Vault, SOPS, External Secrets)?
3. What does `optional: true` on a `secretKeyRef` do, and why is it dangerous here?
