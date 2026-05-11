package main

import (
	"context"
	"fmt"
	"time"
)

// AgentSkill simule une compétence d'agent simple.
type AgentSkill struct {
	NameStr string
}

func (s *AgentSkill) Execute(ctx context.Context, input string) (string, error) {
	// Simulation d'un appel API LLM avec latence.
	select {
	case <-time.After(100 * time.Millisecond):
		return "Processed: " + input, nil
	case <-ctx.Done():
		return "", ctx.Err()
	}
}

func (s *AgentSkill) Name() string {
	return s.NameStr
}

func main() {
	skill := &AgentSkill{NameStr: "text-summarizer"}
	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()

	fmt.Println("Lancement du test pour:", skill.Name())

	// Test 1: Succès probable
	res1, err1 := skill.Execute(context.Background(), "Hello World")
	if err1 != nil {
		fmt.Printf("Erreur test 1: %v\n", errort1)
	} else {
		fmt.Printf("Résultat 1: %s\n", res1)
	}

	// Test 2: Timeout provoqué
	res2, err2 := skill.Execute(ctx, "Slow Task")
	if err2 != nil {
		fmt.Printf("Erreur test 2 (attendu): %v\n", err2)
	} else {
		fmt.Printf("Résultat 2: %s\n", res2)
	}
}