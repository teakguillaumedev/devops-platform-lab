# K01 — Solution

**Root cause:** Image `nginx:1.27-alpne` does not exist (typo). The kubelet fails to pull (`ErrImagePull`) then backs off (`ImagePullBackOff`).

**Diagnosis**
```bash
kubectl -n tshoot-k01 describe pod -l app=web | grep -A2 Failed   # manifest for nginx:1.27-alpne not found
```

**Fix**
```bash
kubectl -n tshoot-k01 set image deploy/web nginx=nginx:1.27-alpine
kubectl -n tshoot-k01 rollout status deploy/web
```

**Debrief**
1. ErrImagePull = the attempt that just failed; ImagePullBackOff = waiting (exponential) before the next attempt.
2. Private registry without `imagePullSecrets`, wrong registry/auth, rate limit (Docker Hub), wrong architecture, network/proxy.
3. `latest` moves: two pods of the same Deployment can run different code, no rollback. A digest (`@sha256:...`) is immutable.
