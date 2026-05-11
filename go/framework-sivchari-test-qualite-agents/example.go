package main

import (
	"context"
	"fmt"
	"time"
)

// Skill simple pour illustron la logique
type CalculatorSkill struct{}

func (s *CalculatorSkill) Execute(ctx context.Context, input string) (string, error) {
	// Simulation d'un délai réseau
	select {
	case <-time.After(200 * time.Millisecond):
		return "42", nil
	case <-ctx.Done():
		return "", ctx.Err()
	}
}

func main() {
	skill := &CalculatorSkill{}
	
	// Cas 1: Succès
	ctx1, cancel1 := context.WithTimeout(context.Background(), 500*time.Millisecond)
	defer cancel1()
	res1, err1 := skill.Execute(ctx1, "calculer 6*7")
	if err1 != nil {
		fmt.Printf("Erreur attendue : %v\n", err1)
	} else {
		fmt.Printf("Résultat 1 : %s\n", res1)
	}

	// Cas 2: Timeout (Simulation d'un problème de performance)
	ctx2, cancel2 := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel2()
	res2, err2 := skill.Execute(ctx2, "calculer 6*7")
	if err2 != nil {
		fmt.Printf("Erreur attendue (timeout) : %v\n", err2)
	} else {
		fmt.Printf("Résultat 2 : %s\n", res2)
	}
}