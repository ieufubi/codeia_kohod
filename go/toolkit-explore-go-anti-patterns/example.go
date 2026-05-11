package main

import (
	"context"
	"fmt"
	"sync"
	"time"
)

// Task représente une unité de travail pour le toolkit explore Go
type Task struct {
	ID      int
	Payload string
}

// Result contient le score final
type Result struct {
	TaskID int
	Score  float64
}

// Processor gère le traitement des tâches
type Processor struct {
	results []Result
	mu      sync.Mutex
}

// Process execute le traitement en parallèle avec limitation de concurrence
func (p *Processor) Process(ctx context.Context, tasks []Task, maxConcurrency int) {
	sem := make(chan struct{}, maxConcurrency)
	var wg sync.WaitGroup

	for _, t := range tasks {
		wg.Add(1)
		// Semaphore pattern pour limiter les goroutines
		sem <- struct{}{}

		go func(task Task) {
			defer wg.Done()
			defer func() {
				<-sem // Libère le slot dans le semaphore
			}()

			// Vérification du contexte avant le travail
			if ctx.Err() != nil {
				return
			}

			res := p.runEvaluation(ctx, task)
			p.save(res)
		}(t)
	}

	wg.Wait()
}

func (p *Processor) runEvaluation(ctx context.Context, t Task) Result {
	// Simulation d'un calcul complexe
	select {
	case <-time.After(50 * time.Millisecond):
		return Result{TaskID: t.ID, Score: 0.95}
	case <-ctx.Done():
		return Result{TaskID: t.ID, Score: 0.0}
	}
}

func (p *Processor) save(r Result) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.results = append(p.results, r)
}

func main() {
	tasks := []Task{}
	for i := 1; i <= 10; i++ {
		tasks = append(tasks, Task{ID: i, Payload: "data"})
	}

	processor := &Processor{}
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	fmt.Println("Début de l'évaluation avec toolkit explore Go...")
	processor.Process(ctx, tasks, 3)

	fmt.Printf("Nombre de résultats collectés : %d/10\n", len(processor.results))
	for _, r := range processor.results {
		fmt.Printf("Task %d: Score %.2f\n", r.TaskID, r.Score)
	}
}