# K04 — Solution

**Root cause:** Service selector `app: shopweb`, pods labelled `app: shop-web`: the Service matches no pod → no endpoints → nothing to forward to.

**Diagnosis**
```bash
kubectl -n tshoot-k04 get endpointslices      # ENDPOINTS <unset>
kubectl -n tshoot-k04 get pods --show-labels
```

**Fix**
```bash
kubectl -n tshoot-k04 patch svc web -p '{"spec":{"selector":{"app":"shop-web"}}}'
```

**Debrief**
1. The list of pod IPs:ports behind a Service, maintained by the EndpointSlice controller from the selector + readiness.
2. The API server rejects a Deployment whose `selector` does not match its own template labels.
3. `kubectl get endpointslices -n <ns>` (empty = selector or readiness problem).
