package main

import (
	"fmt"
	"net/http"
	"time"
)

// SimpleServer illustre un serveur de monitoring pour notre <strong>copilot swe agent</strong>
type SimpleServer struct {
	startTime time.Time
	reqCount  int
}

func (s *SimpleServer) handleStats(w http.ResponseWriter, r *http.Request) {
	s.reqCount++
	uptime := time.Since(s.startTime).String()
	fmt.Fprintf(w, "Uptime: %s | Total Requests: %d\n", uptime, s.reqCount)
}

func main() {
	server := &SimpleServer{
		startTime: time.Now(),
		reqCount:  0,
	}

	http.HandleFunc("/stats", server.handleStats)

	fmt.Println("Server starting on :8081...")
	// Utilisation d'un serveur avec timeout configuré pour la production
	srv := &http.Server{
		Addr:         ":8081",
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	if err := srv.ListenAndServe(); err != nil {
		fmt.Printf("Erreur serveur: %v\n", err)
	}
}