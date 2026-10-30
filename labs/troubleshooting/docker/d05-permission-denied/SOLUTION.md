# D05 — Solution

**Root cause:** `RUN mkdir /data` runs as **root** (before `USER app`), so `/data` is `root:root 755`.
The app runs as uid 10001: it can read and traverse `/data` but not create files in it.

**Diagnosis**
```bash
docker run --rm --entrypoint sh tshoot/d05 -c 'id; ls -ld /data'   # uid=10001(app) ; drwxr-xr-x root root /data
```

**Fix:**
```dockerfile
RUN mkdir /data && chown app:app /data
USER app
```
(or `install -d -o app -g app /data`; for copied files: `COPY --chown=app:app ...`).

**Debrief**
1. root in the container = uid 0 on the host kernel: a container escape or a mounted host path gives full power.
2. A volume mounted over `/data` keeps the **volume's** ownership. In K8s, `securityContext.fsGroup` makes the volume group-writable for the pod.
3. `strace -f -e trace=file` (EACCES) → `namei -l <path>` → `id`.
