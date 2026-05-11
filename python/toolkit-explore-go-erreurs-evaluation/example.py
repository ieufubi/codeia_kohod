package main

import (
	"context"
	"fmt"
	"time"
)

// Result représente le résultat d'une évaluation
type Result struct {
	Score float64
	Error error
}

// Evaluator définit le contrat pour le toolkit explore Go
type Evaluator interface {
	Evaluate(ctx context.Context, input string) Result
}

// PromptEvaluator implémente l'interface de manière sécurisée
type PromptEvaluator struct {
	Threshold float64
}

// Evaluate exécute la logique sans provoquer de panic
func (p *PromptEvaluator) Evaluate(ctx context.Context, input string) Result {
	// Simulation d'un travail long
	select {
	case <-time.After(100 * time.Millisecond):
		score := float64(len(input)) / 10.0
		if score < p.Threshold {
			return Result{Score: score, Error: fmt.Errorf("score trop faible")}
		}
		return Result{Score: score, Error: nil}
	case <-ctx.Done():
		// Gestion correcte du timeout du contexte
		return Result{Score: 0, Error: ctx.Err()}
\	}
}

func main() {
	// Création du contexte avec un timeout de 50ms
	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()

	eval := &PromptEvaluator{Threshold: 0.5}

	// Test 1 : Cas de succès
	res1 := eval.Evaluate(ctx, "un long texte de test")
	fmt.Printf("Test 1 - Score: %f, Erreur: %v\n", res1.Score, res1.Error)

	// Test 2 : Cas de timeout (le contexte expire)
	ctxTimeout, cancel2 := context.WithTimeout(context.Background(), 10*time.Millisecond)
	defer cancel2()
	res2 := eval.Evaluate(ctxTimeout, "test")
	fmt.Printf("Test 2 - Score: %f, Erreur: %v\n", res2.Score, res2.Error)
}