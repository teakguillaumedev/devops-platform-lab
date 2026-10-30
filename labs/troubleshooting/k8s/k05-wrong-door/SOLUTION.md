# K05 — Solution

**Root cause:** Service `targetPort: 8080` but nginx listens on 80. kube-proxy forwards to podIP:8080 → RST → refused.

**Diagnosis**
```bash
kubectl -n tshoot-k05 get endpointslices -o wide   # ports 8080
kubectl -n tshoot-k05 exec deploy/api -- netstat -ltn  # :80
```

**Fix**
```bash
kubectl -n tshoot-k05 patch svc api --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":80}]'
```

**Debrief**
1. `port` = Service port (clients). `targetPort` = port on the pod. `containerPort` = documentation of what the container exposes. `nodePort` = port opened on every node.
2. Not required for traffic; it documents the port and allows **named ports** (`targetPort: http`).
3. The Service references a name; the port number is defined once, next to the container.
