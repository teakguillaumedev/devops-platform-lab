# Day 03 — Networking part 1

## Layers & tools
- App (HTTP, DNS): curl -v, dig · Transport (ports): ss, nc · Network (IP, routes): ip a, ip route, ping · Link: ip link

## Addressing & routing
- `ip a`: lo = loopback (127.0.0.1, never leaves the host). eth0 = 172.20.118.153/20 (virtual Hyper-V NIC).
- `ip route`: default via 172.20.112.1 = gateway (Windows). Most specific route wins.
- NAT: private IP rewritten to the gateway's IP on the way out (SNAT/masquerade). Inbound needs an explicit rule (DNAT) → `docker run -p 8080:80`.
- WSL2 and Docker work the same way: private network + gateway + NAT.

## DNS
- Resolver (8.8.8.8, 1.1.1.1, WSL relay 10.255.255.254) vs authoritative servers.
- Resolution: root → TLD (.com) → authoritative → answer cached for TTL seconds. `dig +trace @1.1.1.1 google.com`.
- Records: A, AAAA, CNAME, MX, TXT. RRSIG/NSEC3 = DNSSEC.
- `dig` queries DNS directly; apps use the system resolver (nsswitch: files dns → /etc/hosts first). Use `getent hosts` to see what the app sees.
- "dig shows new IP but app hits the old one": stale /etc/hosts, DNS cache (TTL, JVM), connection pool.
- Lower TTL to 60 s a day before an IP migration.

## Ports
- 127.0.0.1 = local only; 0.0.0.0 = all interfaces. Check with `ss -tlnp`.
- App in a container bound to 127.0.0.1 + `-p` → refused: Docker forwards to the container's eth0, not its lo. Fix: bind 0.0.0.0.

## HTTPS request = DNS → TCP → TLS → HTTP
- `curl -s -o /dev/null -w "%{time_namelookup} %{time_connect} %{time_appconnect} %{time_starttransfer} %{time_total}"` (cumulative).
- DNS ≈ 5 s → resolver timeout. High TTFB with fast TCP/TLS → slow server/app.
- Cert errors: expired vs wrong host. Never `curl -k` in prod (MITM).
