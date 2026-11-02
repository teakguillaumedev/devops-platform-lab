# K10 — Lost in namespaces

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★☆ | Nov 27 – Dec 3 | cluster DNS, `<svc>.<ns>.svc.cluster.local`, `/etc/resolv.conf` search domains |

## Story
The `api` service was moved to a dedicated namespace `tshoot-k10-data`. The `frontend` in `tshoot-k10-app` was not touched and now fails with `bad address 'api'`.

## Symptoms
```bash
kubectl -n tshoot-k10-app logs deploy/frontend --tail=3
kubectl -n tshoot-k10-data get svc api
```

## Your mission
Make `frontend` reach `api` again. `api` stays in `tshoot-k10-data`.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespaces)
```

<details><summary>Hint 1</summary>

`kubectl -n tshoot-k10-app exec deploy/frontend -- cat /etc/resolv.conf` → look at the `search` line.

</details>
<details><summary>Hint 2</summary>

A short name is only completed with the pod's **own** namespace first.

</details>

## Debrief (answer in your notes)
1. Write the FQDN of the Service. Which part can be omitted, and from where?
2. What does `ndots:5` mean, and why can it generate many useless DNS queries?
3. Compare with net/N02: who answers DNS questions inside the cluster?
