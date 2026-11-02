# N05 — No way out

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Network | ★★★ | Oct 30 – Nov 5 | `ip route`, connected routes vs default route, "Network is unreachable" |

## Story
The client machine (`tshoot-client`, `10.200.0.2/24`) talks fine to its neighbour `10.200.0.1`.
But the `pricing` API, which lives on another network at **`10.201.0.1:8086`**, is unreachable from it.
On the server side, `pricing` is up and listening.

## Symptoms
```bash
sudo ip netns exec tshoot-client curl --max-time 3 http://10.200.0.1:8086/health.txt   # works
sudo ip netns exec tshoot-client curl -v --max-time 3 http://10.201.0.1:8086/health.txt   # "Network is unreachable"
```

## Your mission
Make `pricing` reachable at `10.201.0.1:8086` from the client.
**Only change the client's configuration** (commands prefixed with `ip netns exec tshoot-client`).

## Commands
```bash
sudo ./break.sh   |   sudo ./check.sh   |   sudo ./reset.sh
```

<details><summary>Hint 1</summary>"Network is unreachable" is returned by the client's own kernel before any packet leaves. Why would the kernel not know where to send it?</details>
<details><summary>Hint 2</summary><code>sudo ip netns exec tshoot-client ip route</code>. Compare with <code>ip route</code> on your WSL. Which line is missing?</details>

## Debrief
1. Where does the route `10.200.0.0/24 dev tsh-client` come from, without anyone adding it?
2. What is a default route, and who is the gateway here?
3. Three different errors: "Network is unreachable", "No route to host", "Connection timed out". Who produces each?
   (Vocabulary check: **route** = path for packets, **root** = superuser. Don't mix them up in the video!)
