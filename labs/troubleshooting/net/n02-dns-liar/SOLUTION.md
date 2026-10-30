# N02 — Solution

**Root cause:** `/etc/hosts` contains `192.0.2.10 example.com` (added by the "legacy proxy setup").
Applications use the glibc resolver, which follows `/etc/nsswitch.conf` → `hosts: files dns`: **files first**.
`dig` bypasses all that and queries the DNS server directly, so it shows a correct answer that no application uses.

**Diagnosis**
```bash
curl -v --max-time 5 http://example.com     # "Trying 192.0.2.10:80..." ≠ dig
getent hosts example.com                     # 192.0.2.10 → what apps really get
grep hosts /etc/nsswitch.conf                # files dns
grep example /etc/hosts                      # the culprit
```

**Fix:** remove that line only: `sudo sed -i '/legacy-proxy-setup/d' /etc/hosts`.
(In WSL, `/etc/hosts` is regenerated at boot unless `generateHosts = false` in `/etc/wsl.conf`.)

**Debrief**
1. `dig`/`nslookup` = DNS protocol only. `getent hosts` = the real application path (nsswitch: files, dns, mdns...).
2. Look in local files first, then ask DNS.
3. In a pod: `/etc/hosts` is managed by the kubelet; `spec.hostAliases` adds entries to it. DNS goes to CoreDNS (`/etc/resolv.conf`).
