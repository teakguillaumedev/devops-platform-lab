# D04 — Solution

**Root cause:** containers started without `--network` land on the default `bridge` network, which has **no embedded DNS**:
container names are not resolvable there. User-defined networks get Docker's DNS server at `127.0.0.11`.

**Diagnosis**
```bash
docker inspect -f '{{json .NetworkSettings.Networks}}' tshoot-d04-app   # "bridge"
docker exec tshoot-d04-app cat /etc/resolv.conf                         # host's DNS, not 127.0.0.11
```

**Fix (without recreating the containers):**
```bash
docker network create tshoot-net
docker network connect tshoot-net tshoot-d04-redis
docker network connect tshoot-net tshoot-d04-app
```
(or recreate both with `--network tshoot-net`).

**Debrief**
1. Compose always creates a user-defined network `<project>_default` and attaches every service to it.
2. Container IPs are allocated at start: a restart or recreation can change them.
3. A Service (stable virtual IP + DNS name `svc.ns.svc.cluster.local`).
