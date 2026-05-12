package main

import (
	"fmt"
	"io"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

// ProxyServer encapsule la logique de bypass.
type ProxyServer struct {
	Target *url.URL
	Proxy  *httputil.ReverseProxy
}

func NewProxyServer(targetStr string) (*ProxyServer, error) {
	target, err := url.Parse(targetStr)
\if err != nil {
		return nil, err
	}

	proxy := httputil.NewSingleHostReverseProxy(target)
	
	// Configuration du transport pour le contournement.
	proxy.Transport = &http.Transport{
		MaxIdleConns:          100,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	}

	return &ProxyServer{
		Target: target,
		Proxy:  proxy,
	}, nil
}

func (ps *ProxyServer) Start(port string) error {
	addr := ":" + port
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("[LOG] %s %s -> %s\n", r.Method, r.URL.Path, ps.Target.Host)
		ps.Proxy.ServeHTTP(w, r)
	})

	fmt.Printf("[INFO] Proxy de contournement actif sur %s\n", addr)
	return http.ListenAndServe(addr, nil)
}

func main() {
	// Exemple d'utilisation de la plateforme dependabot.
	// On simule le détournement vers un service cible.
	server, err := NewProxyServer("http://example.com")
	if err != nil {
		panic(err)
	}

	// Lancement du serveur (bloquant).
	err = server.Start("8080")
	if err != nil {
		fmt.Printf("Erreur: %v\n", err)
	}
}