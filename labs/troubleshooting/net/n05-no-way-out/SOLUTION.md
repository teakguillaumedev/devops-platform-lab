# N05 — Solution

**Root cause:** the client only has the *connected* route `10.200.0.0/24 dev tsh-client` (created automatically with its IP).
It has no route to `10.201.0.0/24` and no default route → its own kernel refuses with `ENETUNREACH` before sending anything.

**Diagnosis**
```bash
sudo ip netns exec tshoot-client ip route                 # only 10.200.0.0/24
sudo ip netns exec tshoot-client ip route get 10.201.0.1  # RTNETLINK answers: Network is unreachable
```

**Fix (either):**
```bash
sudo ip netns exec tshoot-client ip route add default via 10.200.0.1
sudo ip netns exec tshoot-client ip route add 10.201.0.0/24 via 10.200.0.1   # more specific
```

**Debrief**
1. Assigning `10.200.0.2/24` to an interface creates the connected route for the whole /24.
2. The route used when nothing more specific matches; gateway here = 10.200.0.1 (the host).
3. *Network is unreachable* = local kernel, no route. *No route to host* = ARP failed on the local link or ICMP host-unreachable
   from a router. *Timed out* = packets sent, nothing came back (DROP, host down).
