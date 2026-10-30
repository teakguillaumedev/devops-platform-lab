# K07 — Solution

**Root cause:** Requests of 16 CPU / 32Gi exceed any kind node. The scheduler finds no fit → Pending.

**Diagnosis**
```bash
kubectl -n tshoot-k07 describe pod -l app=pdf-renderer | grep -A3 Events   # 0/3 nodes are available: Insufficient cpu, Insufficient memory
```

**Fix**
```bash
kubectl -n tshoot-k07 set resources deploy/pdf-renderer --requests=cpu=50m,memory=32Mi --limits=cpu=200m,memory=64Mi
```

**Debrief**
1. Requests → scheduler (placement) and CPU shares. Limits → kubelet/kernel (cgroups cap: throttle or OOM).
2. Guaranteed (requests = limits for all), Burstable (some requests), BestEffort (none). Here: Burstable.
3. Taints without tolerations, node affinity/selector, unbound PVC, pod anti-affinity, quota.
