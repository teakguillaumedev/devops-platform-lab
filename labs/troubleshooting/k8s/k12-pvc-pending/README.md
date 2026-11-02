# K12 — Storage that never comes

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 27 – Dec 3 | PVC, StorageClass, `WaitForFirstConsumer`, immutable fields |

## Story
The `notes` app stores files on a PersistentVolumeClaim. The manifest was copied from the cloud cluster. On this cluster, the pod and the PVC stay `Pending`.

## Symptoms
```bash
kubectl -n tshoot-k12 get pod,pvc
kubectl get storageclass
```

## Your mission
Get `notes` running with its data on a PVC of **1Gi**.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

`kubectl -n tshoot-k12 describe pvc data` → Events.

</details>
<details><summary>Hint 2</summary>

You will find out that some fields of a PVC can't be edited. What's the alternative? (Is there any data to lose yet?)

</details>

## Debrief (answer in your notes)
1. PV, PVC, StorageClass: who creates what with dynamic provisioning?
2. What does `volumeBindingMode: WaitForFirstConsumer` change?
3. What happens to the data when you delete the PVC? (`reclaimPolicy`)
