package main

import (
	"fmt"
	"math/rand"
	"time"
)

// GeneratRandomUUID simule la création d'un identifiant pour Xray
// Dans un vrai projet, utilisez un package cryptographique
func GenerateRandomUUID() string {
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, 16)
	rand.Read(b)
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}

// ConfigTemplate génère une chaîne JSON brute
func ConfigTemplate(uuid string, port int) string {
	return fmt.Sprintf("{\"inbounds\":[{\"port\":%d,\"protocol\":\"vless\",\"uuid\":\"%s\"}]}", port, uuid)
}

func main() {
	fmt.Println("Démarrage de la génération de configuration...")

	// Simulation d'un processus de rotation de port
	for i := 0; i < 3; i++ {
\    	port := 1000 + i
		uuid := GenerateRandomUUID()
		config := ConfigTemplate(uuid, port)

		fmt.Printf("Configuration %d générée : %s\n", i, config)
	}

	fmt.Println("Processus terminé avec succès.")
}