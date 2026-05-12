package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
)

// RealitiesGenerator simule la création d'un identifiant de session pour Xray
// Ce code illustre comment générer un shortId aléatoire pour le paramètre 'shortId'
func RealitiesGenerator(length int) (string, error) {
	if length <= 0 {
		return "", fmt.Errorf("longueur invalide")
	}

	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}

	return hex.EncodeToString(bytes), nil
}

func main() {
	fmt.Println("--- Générateur de ShortID pour Xray, Penetrates Everything ---")

	// Génération de 4 et 8 octets pour tester différentes tailles
	for _, size := range []int{4, 8} {
		shortID, err := RealitiesGenerator(size)
		if err != nil {
			log.Fatalf("Erreur lors de la génération: %v", err)
		}
		fmt.Printf("Taille %d octets -> ShortID: %s\n", size, shortID)
	}

	fmt.Println("----------------------------------------------------------")
	fmt.Println("Utilisez ces IDs dans votre section 'realitySettings' de config.json")
}