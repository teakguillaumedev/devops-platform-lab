# K12 — Solution

**Root cause:** `storageClassName: fast-ssd` doesn't exist in kind (only `standard`, local-path). No provisioner → PVC Pending → pod Pending. `storageClassName` is immutable on a PVC.

**Diagnosis**
```bash
kubectl -n tshoot-k12 describe pvc data     # storageclass.storage.k8s.io "fast-ssd" not found
kubectl get storageclass
```

**Fix**
```bash
kubectl -n tshoot-k12 delete pvc data   # no data yet, safe
kubectl -n tshoot-k12 apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: data, namespace: tshoot-k12}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: standard
  resources: {requests: {storage: 1Gi}}
EOF
kubectl -n tshoot-k12 delete pod -l app=notes   # optional: retry immediately
```

**Debrief**
1. Admin defines StorageClasses; user creates a PVC; the provisioner creates a PV and binds it.
2. The PV is created only when a pod using the PVC is scheduled, so it lands in the pod's zone/node.
3. `Delete` (default for dynamic): the PV and the disk are deleted with it. `Retain`: the PV stays, manual cleanup.
