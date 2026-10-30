# N02 — "DNS says it's fine"

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Network | ★★☆ | Oct 30 – Nov 5 | `dig` vs `getent hosts`, `/etc/hosts`, `/etc/nsswitch.conf`, `curl -v` |

## Story
Since an old "proxy setup" script ran on this machine, `curl http://example.com` hangs and then times out.
You check DNS with `dig example.com`: the answer is a perfectly valid public IP.
"So it's not DNS", says your colleague. Is he right?

## Symptoms
```bash
curl -v --max-time 5 http://example.com     # hangs, then timeout
dig +short example.com                       # valid public IPs
```

## Your mission
Find why `curl` does not go where `dig` says, and repair name resolution for `example.com`.
Don't break anything else on the machine.

## Commands
```bash
sudo ./break.sh   |   ./check.sh   |   sudo ./reset.sh
```
(needs internet access from WSL)

<details><summary>Hint 1</summary>Read the line <code>*   Trying x.x.x.x:80...</code> in <code>curl -v</code>. Compare with dig.</details>
<details><summary>Hint 2</summary>dig talks to a DNS server directly. Applications use the system resolver (glibc): <code>getent hosts example.com</code>. Who decides the order? <code>grep hosts /etc/nsswitch.conf</code></details>

## Debrief
1. Why does `dig` lie to you in this situation? Which command shows what applications really get?
2. What does the line `hosts: files dns` mean?
3. In Kubernetes, which file plays this role inside a pod, and what does `hostAliases` do?
