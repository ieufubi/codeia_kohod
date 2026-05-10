package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/milvus-io/milvus-sdk-go/v2/client"
)

// Ce programme illustre une insertion sécurisée avec batching
// pour éviter l'explosion de segments dans Milvus.
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Connexion au serveur Milvus
	conn, err := client.NewClient(ctx, client.Config{Address: "localhost:19530"})
	if err != nil {
		log.Fatalf("Erreur connexion: %v", err)
	}
	defer conn.Close()

	collectionName := "test_batch_collection"

	// Simulation de données
	batchSize := 100
	vectors := make([][]float32, batchSize)
	for i := 0; i < batchSize; i++ {
		vec := make([]float32, 128)
		for j := 0; j < 128; j++ {
			vec[j] = 0.1 // Valeur constante pour l'exemple
		}
		vectors[i] = vec
	}

	// Dans un vrai cas, utilisez un ticker pour forcer l'envoi
	start := time.Now()

	// Insertion du lot
	err = conn.Insert(ctx, collectionName, vectors, nil)
	if err != nil {
		fmt.Printf("Échec de l'insertion: %v\n", err)
		return
	}

	fmt.Printf("Batch de %d vecteurs inséré en %v\n", batchSize, time.Since(start))
}