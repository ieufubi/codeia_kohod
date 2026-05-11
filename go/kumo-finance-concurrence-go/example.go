package main

import (
	"fmt"
	"sync"
	"sync/atomic"
	"time"
)

// Simulation de transaction dans kumo finance
type TransactionSimulator struct {
	totalProcessed atomic.Int64
	mu             sync.Mutex
	lastUpdate     time.Time
}

func (s *TransactionSimulator) process(amount int64) {
	// Mise à jour atomique sans blocage
	s.totalProcessed.Add(amount)

	// Mise à jour protégée pour la date (plus complexe)
	s.mu.Lock()
	s.lastUpdate = time.Now()
	s.mu.Unlock()
}

func main() {
	sim := &TransactionSimulator{}
	var wg sync.WaitGroup

	// Lancement de 1000 goroutines simulant des transactions simultanées
	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func(val int64) {
			defer wg.Done()
			sim.process(val)
		}(int64(i))
	}

	wg.Wait()

	fmt.Printf("Transactions traitées par kumo finance: %d\n", sim.totalProcessed.Load())
	fmt.Printf("Dernière mise à jour: %v\n", sim.lastUpdate)
}