# N04 — Solution

**Root cause:**
- `billing` (8084) is running, but an iptables rule **DROPs** packets arriving on `tsh-host` for port 8084 → no answer → **timeout**.
- `reports` (8085) is not running → the kernel answers **RST** → **refused** instantly.
- From the server itself, traffic to 10.200.0.1 goes through `lo`, not `tsh-host`, so the rule does not match: "works locally".

**Diagnosis**
```bash
ss -ltnp | grep -E '808[45]'                     # 8084 listens, 8085 doesn't
sudo iptables -S INPUT                           # -A INPUT -i tsh-host -p tcp --dport 8084 ... -j DROP
sudo iptables -L INPUT -v -n                     # the pkts counter of the rule increases at each curl
sudo tcpdump -ni tsh-host port 8084              # SYNs arrive, nothing goes back
```

**Fix:** `sudo iptables -D INPUT -i tsh-host -p tcp --dport 8084 -m comment --comment hardening-2024 -j DROP`
(or delete by number: `sudo iptables -L INPUT --line-numbers` then `sudo iptables -D INPUT <n>`).

**Debrief**
1. DROP → silence → timeout. REJECT → ICMP port-unreachable or TCP RST → immediate error.
2. A RST (`[R.]` in tcpdump).
3. A NetworkPolicy (default deny) → timeouts between pods (see K09).
