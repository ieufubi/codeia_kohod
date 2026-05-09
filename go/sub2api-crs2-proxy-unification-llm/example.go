package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

// SimpleProxy implémente un routage basique pour démonstration
type SimpleProxy struct {
	target *url.URL
}

func (p *SimpleProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// On simule un changement de destination basé sur un header
	if r.Header.Get("X-Target") == "google" {
		fmt.Println("Redirection vers Gemini...")
		// Dans un cas réel, on changerait l'URL du proxy
	}

	proxy := httputil.NewSingleHostReverseProxy(p.target)
	proxy.ServeHTTP(w, r)
}

func main() {
	target, err := url.Parse("http://localhost:8081") // Endpoint de test
	if err != nil {
		log.Fatal(err)
	}

	proxy := &SimpleProxy{target: target}

	fmt.Println("Sub2API-CRS2 proxy de test démarré sur :8080")
	server := &http.Server{
		Addr:    ":8080",
		Handler: proxy,
	}

	if err := server.ListenAndServe(); err != nil {
		log.Fatal("Erreur serveur: ", err)
	}
}