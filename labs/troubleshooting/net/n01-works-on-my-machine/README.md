# N01 — "It works on my machine"

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Network | ★☆☆ | Oct 30 – Nov 5 | `ss -ltnp`, bind address, `curl -v` |

## Story
The `inventory` API was deployed on this host on port **8081**. The developer swears it works:
`curl http://localhost:8081/health.txt` answers fine on the server.
But the client machine (`10.200.0.2`, simulated by the network namespace `tshoot-client`)
cannot reach it at `http://10.200.0.1:8081/health.txt`.

## Symptoms
```bash
curl http://localhost:8081/health.txt                                   # works
sudo ip netns exec tshoot-client curl -v http://10.200.0.1:8081/health.txt   # fails
```

## Your mission
Make the API reachable from the client **without changing its port**.
The service is started by `/tmp/tshoot/start-inventory.sh` (that's its "unit file").

## Commands
```bash
sudo ./break.sh     # set up the incident
sudo ./check.sh     # PASS when fixed
sudo ./reset.sh     # clean everything
```

<details><summary>Hint 1</summary>Look at the exact error message of curl: "connection refused" or "timeout"? What does each one mean?</details>
<details><summary>Hint 2</summary><code>ss -ltnp | grep 8081</code> — read the <em>Local Address</em> column carefully.</details>

## Debrief (answer in your notes)
1. What is the difference between listening on `127.0.0.1`, `10.200.0.1` and `0.0.0.0`?
2. Why is this exact bug so frequent once an app is put in a container? (hint: what is `localhost` inside a container?)
3. Refused vs timeout: which one is a RST packet, which one is silence?
