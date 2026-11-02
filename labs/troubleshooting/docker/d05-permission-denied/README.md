# D05 — Permission denied (as it should be)

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Docker + Linux | ★☆☆ | Nov 6 – 12 | `USER`, ownership vs mode, `namei -l`, `id` (Day 02) |

## Story
Following the security review, the team added `USER app` to the Dockerfile. Since then the app crashes at startup:
`PermissionError: [Errno 13] Permission denied: '/data/state.json'`.
Someone proposes: "just remove `USER app`" — someone else: "`chmod 777 /data`". Both are refused.

## Your mission
Fix `app/Dockerfile` so the app starts, still runs as a **non-root** user, and `/data` is **not world-writable**.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh
```

<details><summary>Hint 1</summary><code>docker run --rm --entrypoint sh tshoot/d05 -c 'id; ls -ld /data'</code> — who owns <code>/data</code>, who are you?</details>
<details><summary>Hint 2</summary>Each <code>RUN</code> before <code>USER</code> runs as root. Order matters.</details>

## Debrief
1. Why is running as root in a container a risk, even with namespaces?
2. If `/data` becomes a **volume** mounted from the host, is your fix still enough? What is `fsGroup` in Kubernetes?
3. Day 02 reflex: the 3 commands to debug any "Permission denied".
