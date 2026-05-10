package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
)

// Ce code illustre un proxy minimaliste pour Sub2API-CRS2
// Il redirige les requêtes vers OpenAI en modifiant le header Host

func main() {
	// URL de l'upstream (ex: OpenAI)
	target := "https://api.openai.com"
	targetURL, err := url.Parse(target)
	if err != nil {
		panic(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(targetURL)

	// Configuration du Director pour la réécriture de l'Host
	originalDirector := proxy.Director
	proxy.Director = func(r *http.Request) {
		originalDirector(r)
		r.Header.Set("X-Proxy-By", "Sub2API-CRS2-Demo")
		r.Host = targetURL.Host // Crucial pour ne pas être rejeté par le fournisseur
	}

	http.HandleFunc("/v1/chat/completions", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Requête reçue pour le modèle: %s\n", r.URL.Path)
		proxy.ServeHTTP(w, r)
	})

	fmt.Println("Serveur Sub2API-CRS2 de test démarré sur :8080")
	fmt.Printf("Redirection vers : %s\n", target)

	err = http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}