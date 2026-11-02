# K09 — Default deny

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Kubernetes | ★★★ | Nov 27 – Dec 3 | NetworkPolicy, podSelector, timeouts between pods |

## Story
Security enabled a *default deny* policy in `tshoot-k09` and added an exception for the frontend. Since then the frontend times out when calling the backend.

## Symptoms
```bash
kubectl -n tshoot-k09 logs deploy/frontend --tail=5
kubectl -n tshoot-k09 get networkpolicy
```

## Your mission
Let **only** `frontend` reach `backend` on port 80. Keep the default deny: any other pod must still be blocked.

Fix it **in the cluster** (`kubectl edit`, `kubectl patch`, `kubectl set ...`, or apply your own copy of the manifest).
Do not edit `broken.yaml`: it is the incident, `break.sh` re-applies it.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (deletes the namespace)
```

<details><summary>Hint 1</summary>

A timeout (not a refusal) between pods smells like NetworkPolicy (see net/N04: DROP).

</details>
<details><summary>Hint 2</summary>

Read the exception carefully: `kubectl -n tshoot-k09 get networkpolicy allow-frontend -o yaml` vs `kubectl -n tshoot-k09 get pods --show-labels`.

</details>

## Debrief (answer in your notes)
1. Who enforces NetworkPolicies: the API server or the CNI plugin? What happens with a CNI that doesn't support them?
2. Ingress policy on the backend vs egress policy on the frontend: what's the difference?
3. Why is 'default deny + explicit allows' the recommended baseline?
