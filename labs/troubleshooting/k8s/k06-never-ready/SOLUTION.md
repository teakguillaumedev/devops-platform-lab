# K06 — Solution

**Root cause:** The readiness probe checks `/healthz`, which default nginx doesn't serve (404). Pod never Ready → removed from endpoints, rollout blocked.

**Diagnosis**
```bash
kubectl -n tshoot-k06 describe pod -l app=shop | grep Readiness   # statuscode: 404
```

**Fix**
```bash
kubectl -n tshoot-k06 patch deploy shop --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'
```

**Debrief**
1. Readiness fails → pod removed from Service endpoints (not restarted). Liveness fails → container restarted.
2. New pods never count as available, so the old ones are never scaled down past `maxUnavailable`.
3. `/readyz`: it fails when PostgreSQL/Redis is down, so traffic stops going to a pod that can't serve it.
