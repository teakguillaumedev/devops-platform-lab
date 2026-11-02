// gateway — front door of ministore (Node.js / Express).
//
// Serves a tiny web page and forwards API calls to the backends:
//   GET  /                -> HTML page
//   GET  /api/products    -> catalog  GET /products
//   GET  /api/orders      -> orders   GET /orders
//   POST /api/orders      -> orders   POST /orders
//   GET  /healthz         liveness: the process answers
//   GET  /readyz          readiness: both backends answer their /readyz
//   GET  /metrics         Prometheus metrics

const express = require("express");
const client = require("prom-client");
const path = require("path");

const PORT = Number(process.env.PORT || 8080);
const CATALOG_URL = process.env.CATALOG_URL || "http://localhost:8001";
const ORDERS_URL = process.env.ORDERS_URL || "http://localhost:8002";
const UPSTREAM_TIMEOUT_MS = Number(process.env.UPSTREAM_TIMEOUT_MS || 3000);

// ---------- logging: one JSON object per line on stdout ----------
function log(level, msg, fields = {}) {
  process.stdout.write(
    JSON.stringify({ ts: new Date().toISOString(), level, service: "gateway", msg, ...fields }) + "\n"
  );
}

// ---------- metrics ----------
client.collectDefaultMetrics();
const requests = new client.Counter({
  name: "http_requests_total",
  help: "HTTP requests",
  labelNames: ["service", "method", "path", "status"],
});
const latency = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP latency",
  labelNames: ["service", "path"],
});
const upstreamErrors = new client.Counter({
  name: "gateway_upstream_errors_total",
  help: "Failed calls to a backend",
  labelNames: ["upstream"],
});

const app = express();
app.use(express.json());

app.use((req, res, next) => {
  const end = latency.startTimer();
  res.on("finish", () => {
    const route = req.route ? req.route.path : "unmatched";
    requests.inc({ service: "gateway", method: req.method, path: route, status: res.statusCode });
    const seconds = end({ service: "gateway", path: route });
    if (!["/healthz", "/readyz", "/metrics"].includes(req.path)) {
      log("info", "request", { method: req.method, path: req.path, status: res.statusCode, duration_ms: +(seconds * 1000).toFixed(1) });
    }
  });
  next();
});

// Forward a request to a backend and relay status + JSON body.
async function forward(res, upstreamName, url, options = {}) {
  try {
    const r = await fetch(url, { ...options, signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS) });
    const body = await r.text();
    res.status(r.status).type("application/json").send(body);
  } catch (err) {
    upstreamErrors.inc({ upstream: upstreamName });
    // err.cause carries the real reason: ECONNREFUSED, ENOTFOUND (DNS), timeout...
    const reason = err.cause ? `${err.cause.code || ""} ${err.cause.message || ""}`.trim() : err.message;
    log("error", "upstream call failed", { upstream: upstreamName, url, reason });
    res.status(502).json({ error: `${upstreamName} unreachable`, reason });
  }
}

app.get("/", (_req, res) => res.sendFile(path.join(__dirname, "public", "index.html")));

app.get("/api/products", (_req, res) => forward(res, "catalog", `${CATALOG_URL}/products`));
app.get("/api/orders", (_req, res) => forward(res, "orders", `${ORDERS_URL}/orders`));
app.post("/api/orders", (req, res) =>
  forward(res, "orders", `${ORDERS_URL}/orders`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(req.body),
  })
);

app.get("/healthz", (_req, res) => res.json({ status: "ok" }));

app.get("/readyz", async (_req, res) => {
  const check = async (name, url) => {
    try {
      const r = await fetch(`${url}/readyz`, { signal: AbortSignal.timeout(2000) });
      return [name, r.ok ? "ready" : `not ready (${r.status})`];
    } catch (err) {
      return [name, `unreachable (${err.cause?.code || err.message})`];
    }
  };
  const results = Object.fromEntries(await Promise.all([check("catalog", CATALOG_URL), check("orders", ORDERS_URL)]));
  const ok = Object.values(results).every((v) => v === "ready");
  res.status(ok ? 200 : 503).json({ status: ok ? "ready" : "not ready", upstreams: results });
});

app.get("/metrics", async (_req, res) => {
  res.type(client.register.contentType).send(await client.register.metrics());
});

const server = app.listen(PORT, () =>
  log("info", "gateway started", { port: PORT, catalog: CATALOG_URL, orders: ORDERS_URL })
);

// Graceful shutdown: stop accepting connections, let in-flight requests finish.
// Only works if node is PID 1 or receives the signal — think about `CMD ["node", "server.js"]` vs `npm start`.
function shutdown(signal) {
  log("info", "signal received, graceful shutdown", { signal });
  server.close(() => {
    log("info", "gateway stopped cleanly");
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000).unref();
}
process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
