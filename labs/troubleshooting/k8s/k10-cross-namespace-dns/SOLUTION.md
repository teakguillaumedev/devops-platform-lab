# K10 — Solution

**Root cause:** `http://api` is completed with the pod's own namespace first: `api.tshoot-k10-app.svc.cluster.local` doesn't exist → NXDOMAIN (`bad address`).

**Diagnosis**
```bash
kubectl -n tshoot-k10-app exec deploy/frontend -- cat /etc/resolv.conf   # search tshoot-k10-app.svc.cluster.local svc.cluster.local cluster.local
kubectl -n tshoot-k10-app exec deploy/frontend -- nslookup api.tshoot-k10-data
```

**Fix**
```bash
kubectl -n tshoot-k10-app set env deploy/frontend BACKEND_URL=http://api.tshoot-k10-data.svc.cluster.local
# alternative: an ExternalName Service named api in tshoot-k10-app pointing to api.tshoot-k10-data.svc.cluster.local
```

**Debrief**
1. `api.tshoot-k10-data.svc.cluster.local`. From any pod `api.tshoot-k10-data` works (search `svc.cluster.local`); just `api` only from the same namespace.
2. Names with fewer than 5 dots are tried with every search domain first: `google.com` → 4 useless queries. Use a trailing dot or lower `ndots` in `dnsConfig`.
3. CoreDNS (Service `kube-dns` in kube-system), configured as nameserver in each pod's resolv.conf.
