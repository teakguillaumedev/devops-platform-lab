# D04 — Who is redis?

| Domain | Difficulty | Plan week | Skills |
|--------|-----------|-----------|--------|
| Docker | ★★☆ | Nov 6 – 12 | default bridge vs user-defined network, embedded DNS 127.0.0.11, `docker network` |

## Story
Two containers: `tshoot-d04-redis` and `tshoot-d04-app`. Both are running.
The app is configured with `REDIS_HOST=tshoot-d04-redis`, which is exactly the container name.
It cannot find Redis.

## Symptoms
```bash
docker ps --filter name=tshoot-d04
docker logs -f tshoot-d04-app        # app: ERROR cannot resolve 'tshoot-d04-redis'
```

## Your mission
Make the app reach Redis **by name**. Rules: no IP addresses, no `localhost`, no `--link`.
Bonus: do it without recreating the app container.

## Commands
```bash
./break.sh   |   ./check.sh   |   ./reset.sh   (name your networks with "tshoot" so reset cleans them)
```

<details><summary>Hint 1</summary><code>docker inspect -f '{{json .NetworkSettings.Networks}}' tshoot-d04-app</code>. Which network? Then <code>docker exec tshoot-d04-app cat /etc/resolv.conf</code>.</details>
<details><summary>Hint 2</summary>The default <code>bridge</code> network has no embedded DNS. User-defined networks do.</details>

## Debrief
1. Why does `docker compose` never have this problem?
2. Why would an IP address work today and break tomorrow?
3. The Kubernetes equivalent: what gives a stable name to a set of pods?
