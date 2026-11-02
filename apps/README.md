# ministore — the app this lab runs

A deliberately small online shop split into 3 services, so that every DevOps topic of the plan
(containers, Kubernetes, CI/CD, GitOps, observability) has something real to work on.

```
                 ┌──────────────────────┐
  browser ──────▶│ gateway   :8080      │  Node.js / Express
                 │ web page + /api/*    │
                 └───────┬────────┬─────┘
          /api/products  │        │  /api/orders
                         ▼        ▼
     ┌──────────────────────┐   ┌──────────────────────┐
     │ catalog   :8001      │◀──│ orders    :8002      │  Go (standard library only)
     │ Python / FastAPI     │   │ checks the product   │
     └─────────┬────────────┘   └─────────┬────────────┘
               ▼                          ▼
        PostgreSQL :5432              Redis :6379
```

Three languages on purpose: each one teaches a different way to build an image
(interpreted + pip, interpreted + npm, compiled static binary).

## Contract shared by all services

| Endpoint     | Meaning | Used later for |
|--------------|---------|----------------|
| `GET /healthz` | the process answers (never checks dependencies) | liveness probe |
| `GET /readyz`  | dependencies answer — 503 otherwise | readiness probe, `depends_on: condition: service_healthy` |
| `GET /metrics` | Prometheus text format | ServiceMonitor, Grafana |

- Logs: one JSON object per line on **stdout** (never files) → `docker logs`, `kubectl logs`, Loki.
- Configuration: **environment variables only** (12-factor).
- Shutdown: **SIGTERM** → stop accepting connections, finish in-flight requests, exit 0. Only works if the app actually receives the signal (see `notes/day02`: PID 1, exec form).

## Configuration

| Service | Variable | Default | Notes |
|---------|----------|---------|-------|
| gateway | `PORT` | `8080` | |
| gateway | `CATALOG_URL` | `http://localhost:8001` | |
| gateway | `ORDERS_URL` | `http://localhost:8002` | |
| gateway | `UPSTREAM_TIMEOUT_MS` | `3000` | |
| catalog | `DATABASE_URL` | — **required** | `postgresql://user:pass@host:5432/db`. Exits 1 if missing. Retries the DB for 60 s at startup, creates + seeds the table. |
| catalog | `LOG_LEVEL` | `INFO` | |
| orders  | `PORT` | `8002` | |
| orders  | `REDIS_ADDR` | `localhost:6379` | |
| orders  | `CATALOG_URL` | `http://localhost:8001` | |

Start commands:
- catalog: `uvicorn app.main:app --host 0.0.0.0 --port 8001 --no-access-log` (from `apps/catalog/`)
- orders: `go build -o orders . && ./orders` (from `apps/orders/`, `CGO_ENABLED=0` gives a fully static binary)
- gateway: `node server.js` (from `apps/gateway/`, after `npm ci`)

## Try it without containers first

```bash
./apps/run-local.sh start     # see the one-time setup at the top of the script
./apps/smoke-test.sh          # end-to-end check through the gateway
./apps/run-local.sh stop
```

Things worth doing while it runs: `ss -ltnp`, `curl -v localhost:8080/readyz`,
stop Redis (`sudo systemctl stop redis-server`) and watch `/readyz` go 503,
`printf '*1\r\n$4\r\nPING\r\n' | nc localhost 6379` to speak Redis by hand (that is what `orders/redis.go` does).

---

## Your mission — week of Nov 6 (Docker)

There is **no Dockerfile and no compose file on purpose**. Write them yourself:

1. `apps/orders/Dockerfile` — multi-stage: build in `golang`, run from `scratch` or `distroless/static`. Target: **< 15 MB**.
2. `apps/catalog/Dockerfile` — `python:3.12-slim`, dependencies layer cached before the code, non-root user.
3. `apps/gateway/Dockerfile` — `node:22-alpine`, `npm ci --omit=dev`, `.dockerignore` (no `node_modules`!), non-root, `CMD ["node", "server.js"]` (why not `npm start`?).
4. `compose.yaml` at the repo root — 5 services, a user-defined network, a named volume for PostgreSQL,
   healthchecks + `depends_on: condition: service_healthy`, only the gateway published on the host.
5. Done when: `docker compose up -d && ./apps/smoke-test.sh` passes, and `docker compose stop` takes **under 2 seconds**
   (if it takes 10 s, a service is not receiving SIGTERM).

Bonus: compare image sizes (`docker images`), scan them (`trivy image`), and explain each layer (`docker history`).
