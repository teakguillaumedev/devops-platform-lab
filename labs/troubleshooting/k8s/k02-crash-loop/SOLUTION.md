# K02 — Solution

**Root cause:** The env var is named `APP_MOD` instead of `APP_MODE`: the app exits 1 at start, Kubernetes restarts it with growing backoff.

**Diagnosis**
```bash
kubectl -n tshoot-k02 logs deploy/worker --previous     # FATAL: APP_MODE is not set
kubectl -n tshoot-k02 get deploy worker -o jsonpath='{.spec.template.spec.containers[0].env}'
```

**Fix**
```bash
kubectl -n tshoot-k02 set env deploy/worker APP_MOD- APP_MODE=production
```

**Debrief**
1. `logs` = current container; `--previous` = the last terminated one (often the only useful one in a crash loop).
2. 1 = the app chose to exit (error). 137 = SIGKILL (OOM or grace period expired). 143 = SIGTERM not handled.
3. Keys in a ConfigMap reviewed once, injected with `envFrom`; plus schema validation in CI (kubeconform, policies).
