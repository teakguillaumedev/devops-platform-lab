package main

// Prometheus metrics in the text exposition format, written by hand.
// The format is just lines of:   metric_name{label="value"} 42
// Compare with `curl localhost:8002/metrics` and with what catalog (official client) exposes.

import (
	"fmt"
	"net/http"
	"sort"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

type metrics struct {
	mu            sync.Mutex
	requests      map[string]uint64  // key: method|path|status
	durationSum   map[string]float64 // key: path
	durationCount map[string]uint64  // key: path
	ordersCreated atomic.Uint64
	startedAt     time.Time
}

func newMetrics() *metrics {
	return &metrics{
		requests:      map[string]uint64{},
		durationSum:   map[string]float64{},
		durationCount: map[string]uint64{},
		startedAt:     time.Now(),
	}
}

func (m *metrics) observe(method, path string, status int, d time.Duration) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.requests[fmt.Sprintf("%s|%s|%d", method, path, status)]++
	m.durationSum[path] += d.Seconds()
	m.durationCount[path]++
}

func (m *metrics) handler(w http.ResponseWriter, _ *http.Request) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var b strings.Builder

	b.WriteString("# HELP http_requests_total HTTP requests\n# TYPE http_requests_total counter\n")
	keys := make([]string, 0, len(m.requests))
	for k := range m.requests {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	for _, k := range keys {
		p := strings.SplitN(k, "|", 3)
		fmt.Fprintf(&b, "http_requests_total{service=\"orders\",method=%q,path=%q,status=%q} %d\n", p[0], p[1], p[2], m.requests[k])
	}

	b.WriteString("# HELP http_request_duration_seconds HTTP latency\n# TYPE http_request_duration_seconds summary\n")
	paths := make([]string, 0, len(m.durationSum))
	for p := range m.durationSum {
		paths = append(paths, p)
	}
	sort.Strings(paths)
	for _, p := range paths {
		fmt.Fprintf(&b, "http_request_duration_seconds_sum{service=\"orders\",path=%q} %f\n", p, m.durationSum[p])
		fmt.Fprintf(&b, "http_request_duration_seconds_count{service=\"orders\",path=%q} %d\n", p, m.durationCount[p])
	}

	b.WriteString("# HELP orders_created_total Orders created\n# TYPE orders_created_total counter\n")
	fmt.Fprintf(&b, "orders_created_total %d\n", m.ordersCreated.Load())
	b.WriteString("# HELP process_uptime_seconds Seconds since start\n# TYPE process_uptime_seconds gauge\n")
	fmt.Fprintf(&b, "process_uptime_seconds %f\n", time.Since(m.startedAt).Seconds())

	w.Header().Set("Content-Type", "text/plain; version=0.0.4")
	_, _ = w.Write([]byte(b.String()))
}
