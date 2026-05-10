package main

import (
	"fmt"
	"sync"
)

// Vector represents a simplified embedding
type Vector []float32

// Document represents a chunk of text with its vector
type Document struct {
	Content string
	Vector  Vector
}

// Processor handles the concurrent vectorization
type Processor struct {
	mu        sync.Mutex
	Documents []Document
}

// ProcessChunks simulates vectorizing text chunks in parallel
func (p *Processor) ProcessChunks(chunks []string) {
	var wg sync.WaitGroup

	for _, chunk := range chunks {
		wg.Add(1)
		go func(c string) {
			defer wg.Done()
			
			// Simulation d'un calcul d'embedding
			v := Vector{0.1, 0.2, 0.3} 
			
			p.mu.Lock()
			p.Documents = append(p.Documents, Document{Content: c, Vector: v})
			p.mu.Unlock()
		}(chunk)
	}
	wg.Wait()
}

func main() {
	chunks := []string{
		"Le Go est rapide.",
		"La concurrence est native.",
		"Le RAG utilise des documents.",
	}

	processor := &Processor{}
	fmt.Println("Début de la vectorisation...")
	processor.ProcessChunks(chunks)

	fmt.Printf("Traitement terminé. %d documents indexés.\n", len(processor.Documents))
	for _, doc := range processor.Documents {
		fmt.Printf("Contenu: %s | Vecteur: %v\n", doc.Content, doc.Vector)
	}
}