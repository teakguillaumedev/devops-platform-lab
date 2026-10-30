# K03 — Solution

**Root cause:** The Deployment references key `db-password` but the secret has `password`. The kubelet cannot build the container config, so the container is never created.

**Diagnosis**
```bash
kubectl -n tshoot-k03 describe pod -l app=api | tail -5   # couldn't find key db-password in Secret
kubectl -n tshoot-k03 get secret db-credentials -o jsonpath='{.data}'
```

**Fix**
```bash
kubectl -n tshoot-k03 edit deploy api     # secretKeyRef key: db-password  →  key: password
```

**Debrief**
1. No container = no process = no logs; the info is in the pod Events.
2. `kubectl get secret x -o jsonpath='{.data.password}' | base64 -d`. Real protection: encryption at rest, RBAC, external secret stores (Vault + External Secrets Operator), SOPS for GitOps.
3. `optional: true` would start the app with an empty password: a silent failure later instead of a loud one now.
