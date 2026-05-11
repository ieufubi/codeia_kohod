package main

import (
	"fmt"
	"time"
)

// PodSimulator simule le cycle de vie d'un pod Kubernetes.
type PodSimulator struct {
	Name   string
	Status string
}

// Run simule l'exécution du pod avec des changements d'état.
func (p *PodSimulator) Run() {
	states := []string{"Pending", "ContainerCreating", "Running", "Terminating"}
	for _, state := range states {
		p.Status = state
		fmt.Printf("[%s] Pod %s est maintenant en état: %s\n", 
			time.Now().Format("15:04:05"), p.Name, p.Status)
		time.Sleep(1500 * time.Millisecond)
	}
	fmt.Printf("Pod %s a terminé son cycle.\n", p.Name)
}

func main() {
	// Simulation d'un déploiement sur 1Panel Kubernetes local
	pod := PodSimulator{
		Name:   "nginx-ingress-controller",
		Status: "Pending",
	}

	fmt.Println("Démarrage de la simulation d'orchestration...")
	pod.Run()
}