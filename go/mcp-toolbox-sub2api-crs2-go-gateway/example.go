package main

import (
	"context"
	"fmt"
	"time"
	"sync"
)

// LLMAPI représente une connexion API unique
type LLMAPI struct {
	Name    string
	RateLimiter *RateLimiter
}

// RateLimiter simule la gestion des tokens disponibles
type RateLimiter struct {
	Tokens int
	mu sync.Mutex
}

// ConsumeToken vérifie et consomme un token
func (r *RateLimiter) ConsumeToken() bool {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.Tokens > 0 {
		r.Tokens--
		return true
	} else {
		return false
	}
}

// TestRateLimiter exécute une série de requêtes avec gestion des tokens
func TestRateLimiter(ctx context.Context, api *LLMAPI, tokens int) {
	fmt.Printf("\n--- Test de l'API %s (Tokens initiaux: %d) ---\n", api.Name, tokens)
	api.RateLimiter.Tokens = tokens

	for i := 1; i <= 10; i++ {
		// Tente de consommer un token
		if api.RateLimiter.ConsumeToken() {
			fmt.Printf("Requête %d : Token consommé. Traitement réussi.\n", i)
		} else {
			fmt.Printf("Requête %d : Échec. Quota dépassé. Stop.\n", i)
			break
		}
		time.Sleep(50 * time.Millisecond) // Pause simulée
	}
}

func main() {
	// Simulation de deux fournisseurs avec des quotas différents
	openai := &LLMAPI{
		Name: "OpenAI",
		RateLimiter: &RateLimiter{Tokens: 5},
	}
	gemini := &LLMAPI{
		Name: "Gemini",
		RateLimiter: &RateLimiter{Tokens: 10},
	}

	ctx := context.Background()

	// Exécution séquentielle pour montrer la dépendance au quota
	TestRateLimiter(ctx, openai, 5)
	TestRateLimiter(ctx, gemini, 10)
	
	// Le service mcp toolbox : Sub2API-CRS2 utiliserait ces mécanismes
	// pour choisir le fournisseur qui a le quota le plus favorable au moment T.
}