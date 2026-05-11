package main

import (
	"fmt"
	"net/http"
	"time"
)

// HealthChecker vérifie si un service de streaming est opérationnel
type HealthChecker struct {
	URL     string
	Timeout time.Duration
}

// Check performs a simple GET request to verify service availability
func (h *HealthChecker) Check() error {
	client := &http.Client{
		Timeout: h.Timeout,
	}

	resp, err := client.Get(h.URL)
	if err != nil {
		return fmt.Errorf("service inaccessible : %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("service en erreur : code %d", resp.StatusCode)
	}

	return nil
}

func main() {
	// Simulation de vérification de plusieurs services de la stack
	services := []HealthChecker{
		{URL: "http://localhost:8096", Timeout: 2 * time.Second}, // Jellyfin
		{URL: "http://localhost:7878", Timeout: 2 * time.Second}, // Radarr
	}

	fmt.Println("--- Audit de santé de la stack streaming ---")

	for _, s := range services {
		err := s.Check()
		if err != nil {
			fmt.Printf("[!] %s : %v\n", s.URL, err)
		} else {
			fmt.Printf("[OK] %s est opérationnel\n", s.URL)
		}
	}
	fmt.Println("--- Fin de l'audit ---")
}