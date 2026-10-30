# N01 — Solution

**Root cause:** the service listens on `127.0.0.1:8081` (loopback only). Packets arriving on `tsh-host` (10.200.0.1)
find no socket bound to that address → the kernel answers **RST** → curl says *Connection refused* instantly.

**Diagnosis**
```bash
ss -ltnp | grep 8081          # LISTEN 127.0.0.1:8081  ← the clue
sudo ip netns exec tshoot-client curl -v http://10.200.0.1:8081/health.txt   # "Connection refused" (not a timeout)
```

**Fix:** in `/tmp/tshoot/start-inventory.sh` set `BIND_ADDRESS=0.0.0.0` (all interfaces) or `10.200.0.1` (just that one), re-run it.

**Debrief**
1. `127.0.0.1` = only local callers. `10.200.0.1` = only traffic to that IP. `0.0.0.0` = every address of the host.
2. In a container, `localhost` is the container itself. An app bound on 127.0.0.1 inside a container is unreachable
   from the host *even with* `-p 8080:8080`: Docker forwards to the container's eth0 IP. Same for K8s pods/Services.
3. Refused = RST (port closed or bound elsewhere). Timeout = no answer at all (dropped, host down, wrong route).
