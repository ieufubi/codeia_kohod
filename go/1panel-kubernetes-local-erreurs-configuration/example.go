package main

import (
	"context"
	"fmt"
	"time"
)

// MonitorNode simule la surveillance d'un noeud dans 1Panel Kubernetes local
type Node struct {
	Name   string
	Status string
}

// FetchNodeStatus simule un appel API vers le cluster
func FetchNodeStatus(ctx context.Context, nodeName string) (*Node, error) {
	// Simulation d'un délai réseau variable
	select {
	case <-time.After(2 * time.Second):
		return &Node{Name: nodeName, Status: "Ready"}, nil
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func main() {
	nodeName := "worker-01"

	// Cas 1: Appel avec un timeout court (échec probable)
	fmt.Println("Tentative 1 (Timeout court)...")
	ctx1, cancel1 := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel1()

	node1, err := FetchNodeStatus(ctx1, nodeName)
	if err != nil {
		fmt.Printf("Erreur attendue : %v\n", err)
	} else {
		fmt.Printf("Node trouvé : %s (%s)\n", node1.Name, node1.Status)
	}

	fmt.Println("\n------------------------------\n")

	// Cas 2: Appel avec un timeout suffisant
	fmt.Println("Tentative 2 (Timeout long)...")
	ctx2, cancel2 := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel2()

	node2, err := FetchNodeStatus(ctx2, nodeName)
	if err != nil {
		fmt.Printf("Erreur : %v\n", err)
	} else {
		fmt.Printf("Node trouvé : %s (%s)\n", node2.Name, node2.Status)
	}
}