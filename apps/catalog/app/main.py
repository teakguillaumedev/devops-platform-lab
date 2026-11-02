"""catalog — product catalog service (Python / FastAPI / PostgreSQL).

Endpoints
  GET /products          list products
  GET /products/{id}     one product (404 if unknown)
  GET /healthz           liveness: the process answers
  GET /readyz            readiness: PostgreSQL answers
  GET /metrics           Prometheus metrics
"""

import json
import logging
import os
import sys
import time
from contextlib import asynccontextmanager

import psycopg
from fastapi import FastAPI, HTTPException, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

SERVICE = "catalog"
DATABASE_URL = os.environ.get("DATABASE_URL")  # required, e.g. postgresql://ministore:ministore@localhost:5432/ministore

SEED_PRODUCTS = [
    ("Mechanical keyboard", 89.90, 25),
    ("USB-C dock", 59.00, 40),
    ("27-inch monitor", 249.00, 10),
    ("Noise-cancelling headset", 129.50, 15),
    ("Kubernetes Up & Running (book)", 44.99, 30),
]


# ---------- logging: one JSON object per line on stdout ----------
class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        entry = {
            "ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "level": record.levelname.lower(),
            "service": SERVICE,
            "msg": record.getMessage(),
        }
        entry.update(getattr(record, "extra_fields", {}))
        return json.dumps(entry)


handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
log = logging.getLogger(SERVICE)
log.addHandler(handler)
log.setLevel(os.environ.get("LOG_LEVEL", "INFO").upper())
log.propagate = False


def info(msg: str, **fields) -> None:
    log.info(msg, extra={"extra_fields": fields})


# ---------- metrics ----------
REQUESTS = Counter("http_requests_total", "HTTP requests", ["service", "method", "path", "status"])
LATENCY = Histogram("http_request_duration_seconds", "HTTP latency", ["service", "path"])


# ---------- database ----------
def connect() -> psycopg.Connection:
    return psycopg.connect(DATABASE_URL, connect_timeout=3, autocommit=True)


def init_db() -> None:
    """Create the table and seed it. Retries: the DB may start after us."""
    for attempt in range(1, 31):
        try:
            with connect() as conn:
                conn.execute(
                    """CREATE TABLE IF NOT EXISTS products (
                           id    SERIAL PRIMARY KEY,
                           name  TEXT NOT NULL,
                           price NUMERIC(10,2) NOT NULL,
                           stock INTEGER NOT NULL
                       )"""
                )
                count = conn.execute("SELECT count(*) FROM products").fetchone()[0]
                if count == 0:
                    with conn.cursor() as cur:
                        cur.executemany(
                            "INSERT INTO products (name, price, stock) VALUES (%s, %s, %s)", SEED_PRODUCTS
                        )
                    info("database seeded", products=len(SEED_PRODUCTS))
            info("database ready")
            return
        except psycopg.OperationalError as exc:
            info("database not reachable yet", attempt=attempt, error=str(exc).strip())
            time.sleep(2)
    log.error("giving up: database unreachable")
    sys.exit(1)


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not DATABASE_URL:
        log.error("DATABASE_URL is not set")
        sys.exit(1)
    init_db()
    info("catalog started")
    yield
    # uvicorn receives SIGTERM, stops accepting connections, finishes in-flight requests, then we land here.
    info("catalog stopping (graceful shutdown)")


app = FastAPI(title="ministore catalog", lifespan=lifespan)


@app.middleware("http")
async def observe(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    route = request.scope.get("route")
    path = route.path if route else "unmatched"
    elapsed = time.perf_counter() - start
    REQUESTS.labels(SERVICE, request.method, path, response.status_code).inc()
    LATENCY.labels(SERVICE, path).observe(elapsed)
    if path not in ("/healthz", "/readyz", "/metrics"):
        info("request", method=request.method, path=request.url.path, status=response.status_code,
             duration_ms=round(elapsed * 1000, 1))
    return response


def row_to_product(row) -> dict:
    return {"id": row[0], "name": row[1], "price": float(row[2]), "stock": row[3]}


@app.get("/products")
def list_products():
    with connect() as conn:
        rows = conn.execute("SELECT id, name, price, stock FROM products ORDER BY id").fetchall()
    return [row_to_product(r) for r in rows]


@app.get("/products/{product_id}")
def get_product(product_id: int):
    with connect() as conn:
        row = conn.execute("SELECT id, name, price, stock FROM products WHERE id = %s", (product_id,)).fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="product not found")
    return row_to_product(row)


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/readyz")
def readyz(response: Response):
    try:
        with connect() as conn:
            conn.execute("SELECT 1")
        return {"status": "ready"}
    except psycopg.OperationalError as exc:
        response.status_code = 503
        return {"status": "not ready", "error": str(exc).strip()}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
