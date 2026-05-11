package main

import (
	"context"
	"fmt"
	"time"
)

// AgentSimulation représente une instance de l'agent utilisant le toolkit Go explore
type AgentSimulation struct {
	MaxIterations int
	CurrentIter   int
}

// Run exécute une boucle d'agent avec contrôle de sécurité
func (a *AgentSimulation) Run(ctx context.Context, task string) error {
	a.CurrentIter = 0
	fmt.Printf("Lancement de la tâche : %s\n", task)

	for a.CurrentIter < a.MaxIterations {
		a.CurrentIter++
		fmt.Printf("Itération %d/%d...\n", a.CurrentIter, a.MaxIterations)

		// Simulation d'une décision d'agent
		select {
		case <-ctx.Done():
			return fmt.Errorf("arrêt prématuré : timeout atteint")
		case <-time.After(500 * time.Millisecond):
			// Simulation d'un travail effectué
			if a.CurrentIter == a.MaxIterations {
				fmt.Println("Tâche terminée avec succès.")
				return nil
			}
			fmt.Println("L'agent décide de continuer...")
		}
	}
	return fmt.Errorf("erreur : limite d'itérations atteinte sans conclusion")
}

func main() {
	// Configuration de l'agent avec une limite stricte pour éviter les loops
	agent := AgentSimulation{MaxIterations: 3}
	
	// Création d'un contexte avec timeout de 2 secondes
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	err := agent.Run(ctx, "Nettoyage des fichiers batch")
	if err != nil {
		fmt.Printf("Échec de l'agent : %v\n", err)
	} else {
		fmt.Println("Processus achevé proprement.")
	}
}