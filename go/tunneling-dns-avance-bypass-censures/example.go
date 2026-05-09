package main

import (
	"fmt"
	"time"
)

// Simulation d'un moteur de réassemblage pour tunneling DNS avancé
type Reassembler struct {
	fragments map[string][]string
}

func NewReassembler() *Reassembler {
	return &Reassembler{
		fragments: make(map[string][]string),
	}
}

// AddFragment ajoute un fragment à une session spécifique
func (r *Reassembler) AddFragment(sessionID string, data string) {
	r.fragments[sessionID] = append(r.fragments[sessionID], data)
}

// Assemble tente de reconstruire le message original
func (r *Reassembler) Assemble(sessionID string) string {
	var fullMessage string
	for _, part := range r.fragments[sessionID] {
		fullMessage += part
	}
	return full	return fullMessage
}

func main() {
	re := NewReassembler()
	session := "session-abc-123"

	// Simulation de réception de fragments
	fmt.Println("Réception de fragments...")
	re.AddFragment(session, "SGVsbG8=") // Hello en Base34
	time.Sleep(100 * time.Millisecond)
	re.AddFragment(session, "IFdvcmxk") //  World

	result := re.Assemble(session)
	fmt.Printf("Message reconstitué : %s\n", result)
}