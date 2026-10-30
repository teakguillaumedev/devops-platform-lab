# K09 — Solution

**Root cause:** The exception `allow-frontend` allows pods labelled `app: front`; the frontend is `app: frontend`. With default deny, its traffic is dropped → timeouts.

**Diagnosis**
```bash
kubectl -n tshoot-k09 get pods --show-labels
kubectl -n tshoot-k09 get networkpolicy allow-frontend -o jsonpath='{.spec.ingress}'
```

**Fix**
```bash
kubectl -n tshoot-k09 patch networkpolicy allow-frontend --type=json -p '[{"op":"replace","path":"/spec/ingress/0/from/0/podSelector/matchLabels","value":{"app":"frontend"}}]'
```

**Debrief**
1. The CNI plugin. With a CNI that doesn't implement them, policies are accepted by the API and silently ignored.
2. Ingress on backend = who may come in. Egress on frontend = where it may go (and then DNS to kube-dns must be allowed too!).
3. Least privilege: new workloads are isolated by default; every flow is explicit and reviewable.
