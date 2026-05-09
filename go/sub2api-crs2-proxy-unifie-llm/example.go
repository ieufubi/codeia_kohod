package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

// Un exemple minimaliste de Sub2API-CRS2 standalone
func main() {
	// Target: On simule un endpoint OpenAI
	target, err := url.Parse("https://api.openai.com")
	if err != nil {
		log.Fatal(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(target)

	// Middleware de transformation
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Request: %s %s\n", r.Method, r.URL.Path)
		
		// Simulation de réécriture de header pour Sub2API-CRS2
		if r.Header.Get("Authorization") == "" {
			http.Error(w, "Missing Sub2API-CRS2 Key", http.StatusUnauthorized)
			return
		}

		// On injecte la vraie clé avant de transmettre
		r.Header.Set("Authorization", "Bearer sk-real-key-123")

		proxy.ServeHTTP(w, r)
	})

	server := &http.Server{
		Addr:    ":8080",
		Handler: handler,
	}

	fmt.Println("Sub2API-CRS2 Proxy running on :8080")
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}

}
// Note: Ce code nécessite une clé API valide pour fonctionner réellement avec OpenAI.