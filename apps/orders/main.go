// orders — order service (Go, standard library only, Redis storage).
//
// Endpoints
//
//	POST /orders    {"product_id": 1, "quantity": 2} -> checks the product with catalog, stores the order in Redis
//	GET  /orders    last 50 orders
//	GET  /healthz   liveness: the process answers
//	GET  /readyz    readiness: Redis answers PING
//	GET  /metrics   Prometheus metrics (text format written by hand: no dependency)
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"
)

type config struct {
	port       string
	redisAddr  string
	catalogURL string
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

type product struct {
	ID    int     `json:"id"`
	Name  string  `json:"name"`
	Price float64 `json:"price"`
	Stock int     `json:"stock"`
}

type order struct {
	ID        int64     `json:"id"`
	ProductID int       `json:"product_id"`
	Product   string    `json:"product"`
	Quantity  int       `json:"quantity"`
	Total     float64   `json:"total"`
	CreatedAt time.Time `json:"created_at"`
}

type server struct {
	cfg     config
	redis   *redisClient
	http    *http.Client
	metrics *metrics
	log     *slog.Logger
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil)).With("service", "orders")
	cfg := config{
		port:       env("PORT", "8002"),
		redisAddr:  env("REDIS_ADDR", "localhost:6379"),
		catalogURL: env("CATALOG_URL", "http://localhost:8001"),
	}
	s := &server{
		cfg:     cfg,
		redis:   newRedisClient(cfg.redisAddr),
		http:    &http.Client{Timeout: 3 * time.Second},
		metrics: newMetrics(),
		log:     logger,
	}

	mux := http.NewServeMux()
	mux.HandleFunc("POST /orders", s.createOrder)
	mux.HandleFunc("GET /orders", s.listOrders)
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
	mux.HandleFunc("GET /readyz", s.readyz)
	mux.HandleFunc("GET /metrics", s.metrics.handler)

	srv := &http.Server{
		Addr:              ":" + cfg.port, // ":8002" = all interfaces (0.0.0.0)
		Handler:           s.observe(mux),
		ReadHeaderTimeout: 5 * time.Second,
	}

	// SIGTERM (docker stop, kubectl delete pod) or SIGINT (Ctrl+C) cancels ctx.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	go func() {
		logger.Info("orders started", "port", cfg.port, "redis", cfg.redisAddr, "catalog", cfg.catalogURL)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("cannot listen", "error", err.Error())
			os.Exit(1)
		}
	}()

	<-ctx.Done()
	logger.Info("signal received, graceful shutdown (max 10s)")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		logger.Error("shutdown error", "error", err.Error())
		os.Exit(1)
	}
	logger.Info("orders stopped cleanly")
}

func (s *server) createOrder(w http.ResponseWriter, r *http.Request) {
	var in struct {
		ProductID int `json:"product_id"`
		Quantity  int `json:"quantity"`
	}
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil || in.ProductID <= 0 || in.Quantity <= 0 {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": `expected {"product_id": >0, "quantity": >0}`})
		return
	}

	p, status, err := s.fetchProduct(r.Context(), in.ProductID)
	if err != nil {
		s.log.Error("catalog call failed", "error", err.Error())
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": "catalog unavailable: " + err.Error()})
		return
	}
	if status == http.StatusNotFound {
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "unknown product"})
		return
	}

	id, err := s.redis.incr("orders:seq")
	if err != nil {
		s.log.Error("redis INCR failed", "error", err.Error())
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "storage unavailable"})
		return
	}
	o := order{
		ID: id, ProductID: p.ID, Product: p.Name, Quantity: in.Quantity,
		Total: float64(in.Quantity) * p.Price, CreatedAt: time.Now().UTC(),
	}
	payload, _ := json.Marshal(o)
	if err := s.redis.lpush("orders", string(payload)); err != nil {
		s.log.Error("redis LPUSH failed", "error", err.Error())
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "storage unavailable"})
		return
	}
	s.metrics.ordersCreated.Add(1)
	s.log.Info("order created", "order_id", o.ID, "product_id", o.ProductID, "quantity", o.Quantity)
	writeJSON(w, http.StatusCreated, o)
}

func (s *server) fetchProduct(ctx context.Context, id int) (product, int, error) {
	var p product
	req, _ := http.NewRequestWithContext(ctx, http.MethodGet, s.cfg.catalogURL+"/products/"+strconv.Itoa(id), nil)
	resp, err := s.http.Do(req)
	if err != nil {
		return p, 0, err
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusNotFound {
		return p, resp.StatusCode, nil
	}
	if resp.StatusCode != http.StatusOK {
		return p, resp.StatusCode, fmt.Errorf("catalog returned %d", resp.StatusCode)
	}
	return p, resp.StatusCode, json.NewDecoder(resp.Body).Decode(&p)
}

func (s *server) listOrders(w http.ResponseWriter, _ *http.Request) {
	items, err := s.redis.lrange("orders", 0, 49)
	if err != nil {
		s.log.Error("redis LRANGE failed", "error", err.Error())
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "storage unavailable"})
		return
	}
	orders := make([]json.RawMessage, 0, len(items))
	for _, it := range items {
		orders = append(orders, json.RawMessage(it))
	}
	writeJSON(w, http.StatusOK, orders)
}

func (s *server) readyz(w http.ResponseWriter, _ *http.Request) {
	if err := s.redis.ping(); err != nil {
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "not ready", "error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
}

// observe logs each request and feeds the metrics.
func (s *server) observe(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)
		elapsed := time.Since(start)
		s.metrics.observe(r.Method, r.URL.Path, rec.status, elapsed)
		switch r.URL.Path {
		case "/healthz", "/readyz", "/metrics":
		default:
			s.log.Info("request", "method", r.Method, "path", r.URL.Path, "status", rec.status,
				"duration_ms", float64(elapsed.Microseconds())/1000)
		}
	})
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.status = code
	r.ResponseWriter.WriteHeader(code)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
