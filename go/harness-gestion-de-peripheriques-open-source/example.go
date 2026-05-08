package main

import (
	"context"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// DeviceStatus représente l'état d'un appareil
type DeviceStatus struct {
	ID        string
	IsHealthy bool
	Latency   time.Duration
}

// Simulator gère la gestion de périphériques simulée
type Simulator struct {
	deviceIDs []string
	mu        sync.Mutex
	results   []DeviceStatus
}

// RunCheck simule une vérification de santé sur la flotte
func (s *Simulator) RunCheck(ctx context.Context) {
	var wg sync.WaitGroup

	for _, id := range s.deviceIDs {
		wg.Add(1)
		go func(deviceID string) {
			defer wg.Done()

			// Simulation d'un délai réseau aléatoire
			rand.Seed(time.Now().UnixNano())
			delay := time.Duration(rand.Intn(500)) * time.Millisecond
			time.Sleep(delay)

			status := DeviceStatus{
				ID:        deviceID,
				IsHealthy: delay < 400*time.Millisecond,
				Latency:   delay,
			}

			s.mu.Lock()
			s.results = append(s.results, status)
			s.mu.Unlock()
		}(id)
	}

	wg.Wait()
}

func main() {
	sim := &Simulator{
\		deviceIDs: []string{"node-alpha", "node-beta", "node-gamma", "node-delta"},
	}

	fmt.Println("Démarrage de la gestion de périphériques...")
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	sim.RunCheck(ctx)

	fmt.Println("Résultats de l'audit de la flotte :")
	for _, res := range sim.results {
		statusText := "OK"
		if !res.IsHealthy {
			statusText = "ALERTE (Timeout)"
		}
		fmt.Printf(" - %s: [%s] (latence: %v)\n", res.ID, statusText, res.Latency)
	}

	if ctx.Err() == context.DeadlineExceeded {
		fmt.Println("Attention: L'audit a été interrompu par un timeout global.")
	}
}