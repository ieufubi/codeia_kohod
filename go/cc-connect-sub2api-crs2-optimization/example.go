package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

// SimpleProxy implémente un routage basique pour démontrer le concept.
type SimpleProxy struct {
	routes map[string]*url.URL
}

func (p *SimpleProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// On cherche la cible dans notre table de routage.
	target, ok := p.routes[r.URL.Path]
	if !ok {
		http.Error(w, "Route non trouvée", http.StatusNotFound)
		return
	}

	proxy := httputil.NewSingleHostReverseProxy(target)
	
	// On modifie la requête pour simuler le comportement de cc connect.
	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)
		req.Header.Set("X-Proxy-Source", "cc-connect-demo")
		req.Header.Set("Authorization", "Bearer demo-token")
	}

	proxy.ServeHTTP(w, r)
}

func main() {
	// Simulation de destinations (ex: OpenAI et Anthropic)
	openai, _ := url.Parse("http://localhost:8081")
	anthropic, _ := url.Parse("http://localhost:8082")

	proxy := &SimpleProxy{
		routes: map[string]*url.URL{
			"/v1/openai":  openai,
			"/v1/anthropic": anthropic,
		},
	}

	server := &http.Server{
		Addr:         ":8080",
		Handler:      proxy,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	fmt.Println("Serveur proxy cc connect démarré sur :8080")
	fmt.Println("Routes disponibles: /v1/openai, /v1/anthropic")
	if err := server.ListenAndServe(); err != nil {
		fmt.Printf("Erreur serveur: %v\n", err)
	}
}