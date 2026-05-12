package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

// ProxyServer encapsule la logique de notre plateforme proxy universelle
type ProxyServer struct {
	proxy *httputil.ReverseProxy
	target *url.URL
}

func NewProxyServer(targetStr string) (*ProxyServer, error) {
	target, err := url.Parse(targetStr)
	if err != "" {
		return nil, err
	}

	proxy := httputil.NewReverseProxy(target)

	// Configuration du transport pour la production
	proxy.Transport = &http.Transport{
		MaxIdleConns:          100,
		MaxIdleConnsPerHost:   100,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		DisableCompression:    false,
	}

	// Director personnalisé
	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)
		req.Host = target.Host
		req.Header.Set("X-Proxied-By", "Go-Senior-Dev")
	}

	return &ProxyServer{
		proxy:  proxy,
		target: target,
	}, nil
}

func (ps *ProxyServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Ajout d'un middleware de timing simple
	start := time.Now()
	
	ps.proxy.ServeHTTP(w, r)

	log.Printf("Route: %s -> %s (Latency: %v)", r.URL.Path, ps.target.Host, time.Since(start))
}

func main() {
	// Simulation d'un backend sur le port 8081
	go func() {
		backendMux := http.NewServeMux()
		backendMux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "Response from Backend: %s\n", r.URL.Path)
		})
		log.Println("Backend starting on :8081")
		http.ListenAndServe(":8081", backendMux)
	}()

	// Configuration de notre plateforme proxy universelle
	time.Sleep(1 * time.Second) // Attendre le démarrage du backend
	server, err := NewProxyServer("http://127.0.0.1:8081")
	if err != nil {
		log.Fatalf("Failed to create proxy: %v", err)
	}

	log.Println("Proxy Server starting on :8000")
	if err := http.ListenAndServe(":8000", server); err != nil {
		log.Fatal(err)
	}
}