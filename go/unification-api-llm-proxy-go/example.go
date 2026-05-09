package main

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"time"
)

// DemoProxy simule un proxy simplifié pour un copilot swe agent
type DemoProxy struct {
	TargetURL string
}

func (p *DemoProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// On crée un contexte avec timeout pour protéger le système
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()

	// On prépare la requête vers le fournisseur cible
	req, err := http.NewRequestWithContext(ctx, "GET", p.TargetURL, nil)
	if err != nil {
		http.Error(w, "Erreur interne", http.StatusInternalServerError)
		return
	}

	// On utilise un client dédié (simulé ici)
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		// Si le timeout est atteint, on informe le copilot swe agent
		http.Error(w, "Fournisseur trop lent ou indisponible", http.StatusGatewayTimeout)
		return
	}
	defer resp.Body.Close()

	// On copie la réponse vers le client
	w.WriteHeader(resp.StatusCode)
	_, err = io.Copy(w, resp.Body)
	if err != nil {
		fmt.Printf("Erreur de copie: %v\n", err)
	}
}

func main() {
	// Simulation d'un serveur backend qui met du temps à répondre
	go func() {
		http.ListenAndServe(":8081", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			time.Sleep(5 * time.Second) // Simule une latence excessive
			fmt.Fprint(w, "Réponse du fournisseur")
		})
	}()

	// Notre proxy configuré pour le copilot swe agent
	proxy := &DemoProxy{TargetURL: "http://localhost:8081"}
	
	fmt.Println("Proxy démarré sur :8080. Testez avec: curl -i http://localhost:8080")
	http.ListenAndServe(":8080", proxy)
}