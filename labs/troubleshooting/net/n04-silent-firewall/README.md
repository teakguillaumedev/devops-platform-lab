# N04 — The silent firewall

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Network | ★★☆ | Oct 30 – Nov 5 | refused vs timeout, `curl -w`, `iptables -S` / `nft list ruleset`, `tcpdump` |

## Story
Two services run on this host: `billing` on **8084** and `reports` on **8085**.
Monitoring says both are down, but the symptoms are not the same at all.

## Symptoms
```bash
# from the client machine (network namespace tshoot-client)
sudo ip netns exec tshoot-client curl -s -o /dev/null -w 'billing: %{http_code} in %{time_total}s\n' --max-time 5 http://10.200.0.1:8084/health.txt
sudo ip netns exec tshoot-client curl -s -o /dev/null -w 'reports: %{http_code} in %{time_total}s\n' --max-time 5 http://10.200.0.1:8085/health.txt
# and from the server itself — why does billing work from here?
curl -s -o /dev/null -w 'billing (local): %{http_code}\n' http://10.200.0.1:8084/health.txt
```

## Your mission
1. Explain **in one sentence each** why `billing` hangs and why `reports` fails instantly.
2. Repair `billing` from the client's point of view (`10.200.0.2` → `10.200.0.1:8084`).
3. `reports` is decommissioned on purpose: do not repair it, just prove that it is not running.

## Commands
```bash
sudo ./break.sh   |   sudo ./check.sh   |   sudo ./reset.sh
```

<details><summary>Hint 1</summary>Is something listening on 8084? <code>ss -ltnp</code>. And on 8085?</details>
<details><summary>Hint 2</summary>If a process listens but packets get no answer at all, something in the kernel drops them: <code>sudo iptables -S</code> (or <code>sudo nft list ruleset</code>).</details>
<details><summary>Hint 3</summary>See it with your own eyes: <code>sudo tcpdump -ni tsh-host port 8084</code> while the client curls.</details>

## Debrief
1. DROP vs REJECT: which one gives a timeout, which one gives "connection refused" (or "no route to host")?
2. What does a closed port answer with, at TCP level?
3. In Kubernetes, which object produces exactly the "timeout" symptom between two pods?
