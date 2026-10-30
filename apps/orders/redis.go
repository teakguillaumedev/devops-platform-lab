package main

// A tiny Redis client speaking RESP (the Redis protocol) over TCP.
// Only what this service needs: PING, INCR, LPUSH, LRANGE.
// Written by hand on purpose: zero dependency, and you can read what goes on the wire.
// Try it yourself:  printf '*1\r\n$4\r\nPING\r\n' | nc localhost 6379   -> +PONG

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"net"
	"strconv"
	"strings"
	"sync"
	"time"
)

type redisClient struct {
	addr string
	mu   sync.Mutex
	conn net.Conn
	rd   *bufio.Reader
}

func newRedisClient(addr string) *redisClient { return &redisClient{addr: addr} }

// do sends one command and reads one reply. One connection, serialized by a mutex:
// simple, good enough for a lab. On any error the connection is dropped and re-dialed next time.
func (c *redisClient) do(args ...string) (any, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.conn == nil {
		conn, err := net.DialTimeout("tcp", c.addr, 2*time.Second)
		if err != nil {
			return nil, err
		}
		c.conn, c.rd = conn, bufio.NewReader(conn)
	}
	_ = c.conn.SetDeadline(time.Now().Add(3 * time.Second))

	var b strings.Builder
	fmt.Fprintf(&b, "*%d\r\n", len(args))
	for _, a := range args {
		fmt.Fprintf(&b, "$%d\r\n%s\r\n", len(a), a)
	}
	if _, err := c.conn.Write([]byte(b.String())); err != nil {
		c.reset()
		return nil, err
	}
	reply, err := c.read()
	if err != nil {
		var redisErr redisError
		if !errors.As(err, &redisErr) {
			c.reset()
		}
	}
	return reply, err
}

func (c *redisClient) reset() {
	if c.conn != nil {
		_ = c.conn.Close()
	}
	c.conn, c.rd = nil, nil
}

type redisError string

func (e redisError) Error() string { return "redis: " + string(e) }

func (c *redisClient) read() (any, error) {
	line, err := c.rd.ReadString('\n')
	if err != nil {
		return nil, err
	}
	line = strings.TrimSuffix(line, "\r\n")
	if line == "" {
		return nil, errors.New("redis: empty reply")
	}
	switch line[0] {
	case '+': // simple string
		return line[1:], nil
	case '-': // error
		return nil, redisError(line[1:])
	case ':': // integer
		return strconv.ParseInt(line[1:], 10, 64)
	case '$': // bulk string
		n, _ := strconv.Atoi(line[1:])
		if n < 0 {
			return nil, nil
		}
		buf := make([]byte, n+2)
		if _, err := io.ReadFull(c.rd, buf); err != nil {
			return nil, err
		}
		return string(buf[:n]), nil
	case '*': // array
		n, _ := strconv.Atoi(line[1:])
		out := make([]any, 0, max(n, 0))
		for i := 0; i < n; i++ {
			v, err := c.read()
			if err != nil {
				return nil, err
			}
			out = append(out, v)
		}
		return out, nil
	}
	return nil, fmt.Errorf("redis: unexpected reply %q", line)
}

func (c *redisClient) ping() error {
	_, err := c.do("PING")
	return err
}

func (c *redisClient) incr(key string) (int64, error) {
	v, err := c.do("INCR", key)
	if err != nil {
		return 0, err
	}
	return v.(int64), nil
}

func (c *redisClient) lpush(key, value string) error {
	_, err := c.do("LPUSH", key, value)
	return err
}

func (c *redisClient) lrange(key string, start, stop int) ([]string, error) {
	v, err := c.do("LRANGE", key, strconv.Itoa(start), strconv.Itoa(stop))
	if err != nil {
		return nil, err
	}
	items, _ := v.([]any)
	out := make([]string, 0, len(items))
	for _, it := range items {
		if s, ok := it.(string); ok {
			out = append(out, s)
		}
	}
	return out, nil
}
