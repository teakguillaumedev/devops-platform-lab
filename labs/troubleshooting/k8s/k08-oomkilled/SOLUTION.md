# K08 — Solution

**Root cause:** The app allocates 150 MB with a 64Mi limit → kernel OOM kill → restart loop.

**Diagnosis**
```bash
kubectl -n tshoot-k08 describe pod -l app=cache | grep -A4 'Last State'   # OOMKilled, exit 137
```

**Fix**
```bash
kubectl -n tshoot-k08 set resources deploy/cache --requests=memory=192Mi --limits=memory=256Mi
```

**Debrief**
1. The kernel (cgroup OOM killer); the kubelet just reports it and restarts the container.
2. Overcommit: the node runs out of memory → kubelet evicts pods (BestEffort first, then Burstable) and the kernel OOM-kills.
3. If the memory use is a bug or unbounded (D03: it grows with the file) → fix the code. If it is a stable, designed need (K08) → size the limit.
