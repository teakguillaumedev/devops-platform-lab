# Troubleshooting bank

22 reproducible incidents, from Linux networking to Kubernetes. Each one breaks something on purpose;
your job is to find **why** and fix it **properly**. A `check.sh` tells you when you are done,
and it rejects the classic "cheat" fixes (`chmod 777`, hard-coded IPs, deleting the policy…).

Solutions are **not on this branch**. They live on the `solutions` branch:
`git show solutions:labs/troubleshooting/net/n01-works-on-my-machine/SOLUTION.md`
Look only after a real attempt (rule: 30 minutes, or 3 written hypotheses).

## The method (use it every time, write it in your notes)
1. **Observe** — exact symptom, exact error message, who is affected, since when.
2. **Hypothesis** — one sentence: "I think X because Y".
3. **Test** — one command that proves or kills the hypothesis.
4. **Fix** — the smallest change that addresses the *cause*, not the symptom.
5. **Verify** — `./check.sh`, then explain the debrief questions out loud (good training for videos).

## Index

| ID | Incident | Domain | ★ | When (plan) | Needs |
|----|----------|--------|---|-------------|-------|
| [N01](net/n01-works-on-my-machine) | "It works on my machine" | Network | ★ | Oct 30 – Nov 5 | sudo |
| [N02](net/n02-dns-liar) | "DNS says it's fine" | Network | ★★ | Oct 30 – Nov 5 | sudo, internet |
| [N03](net/n03-port-squatter) | The port squatter | Network + systemd | ★★ | Oct 30 – Nov 5 | sudo, systemd |
| [N04](net/n04-silent-firewall) | The silent firewall | Network | ★★ | Oct 30 – Nov 5 | sudo, iptables |
| [N05](net/n05-no-way-out) | No way out | Network | ★★★ | Oct 30 – Nov 5 | sudo |
| [D01](docker/d01-ten-seconds-to-die) | Ten seconds to die | Docker | ★★ | Nov 6 – 12 | docker |
| [D02](docker/d02-ghost-file) | The ghost file | Docker | ★★ | Nov 6 – 12 | docker |
| [D03](docker/d03-silent-death) | Silent death | Docker | ★★ | Nov 6 – 12 | docker |
| [D04](docker/d04-who-is-redis) | Who is redis? | Docker | ★★ | Nov 6 – 12 | docker |
| [D05](docker/d05-permission-denied) | Permission denied (as it should be) | Docker | ★ | Nov 6 – 12 | docker |
| [K01](k8s/k01-typo-in-prod) | The typo that stops production | K8s | ★ | Nov 13 – 26 | kind |
| [K02](k8s/k02-crash-loop) | CrashLoopBackOff | K8s | ★ | Nov 13 – 26 | kind |
| [K03](k8s/k03-config-error) | CreateContainerConfigError | K8s | ★★ | Nov 13 – 26 | kind |
| [K04](k8s/k04-lonely-service) | The lonely Service | K8s | ★★ | Nov 13 – 26 | kind |
| [K05](k8s/k05-wrong-door) | Knocking on the wrong door | K8s | ★★ | Nov 13 – 26 | kind |
| [K06](k8s/k06-never-ready) | Running but never Ready | K8s | ★★ | Nov 13 – 26 | kind |
| [K07](k8s/k07-pending-forever) | Pending forever | K8s | ★★ | Nov 13 – 26 | kind |
| [K08](k8s/k08-oomkilled) | OOMKilled | K8s | ★★ | Nov 27 – Dec 3 | kind |
| [K09](k8s/k09-network-policy) | Default deny | K8s | ★★★ | Nov 27 – Dec 3 | kind ≥ 0.24 |
| [K10](k8s/k10-cross-namespace-dns) | Lost in namespaces | K8s | ★★ | Nov 27 – Dec 3 | kind |
| [K11](k8s/k11-killed-while-booting) | Killed while booting | K8s | ★★★ | Nov 27 – Dec 3 | kind |
| [K12](k8s/k12-pvc-pending) | Storage that never comes | K8s | ★★ | Nov 27 – Dec 3 | kind |

Notice the threads between levels: N04 (DROP = timeout) → K09 (NetworkPolicy), N02 (resolver) → K10 (cluster DNS),
Day 02 cgroups → D03 → K08, Day 02 PID 1 → D01 → `terminationGracePeriodSeconds`.

## How to run
```bash
cd labs/troubleshooting/net/n01-works-on-my-machine
sudo ./break.sh      # create the incident        (net scenarios need sudo, docker/k8s don't)
...investigate & fix...
sudo ./check.sh      # PASS / FAIL
sudo ./reset.sh      # clean up (docker scenarios also restore app/ with git)
```
Kubernetes scenarios need a local cluster: `./k8s/setup-kind.sh` (kind, 1 control plane + 2 workers).
For K scenarios, CKA-style: set `alias k=kubectl` and try to solve each one in **under 10 minutes**.

## Exam mode (Nov 27 – Dec 3)
Ask someone (or a script) to pick 3 random K scenarios, run their `break.sh` without reading the README,
and solve them with only `kubectl` and a 30-minute timer.
`ls k8s | grep '^k' | shuf -n 3`

## Video material
Every scenario is a ready-made short video: *symptom → wrong intuition → the command that reveals the cause → fix → why*.
