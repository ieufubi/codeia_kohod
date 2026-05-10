package main

import (
	"context"
	"fmt"
	"log"
	"time"
	"github.com/milvus-io/milvus-sdk-go/v2/client"
)

// Ce programme illustre un cycle de vie complet : Connexion, Création, Insertion, Recherche.
// Nécessite un serveur Milvus actif sur localhost:19530

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// 1. Initialisation du client
	c, err := client.NewClient(ctx, "localhost:19530")
	if err != nil {
		log.Fatalf("Erreur connexion: %v", err)
	}
	defer c.Close()

	collectionName := "demo_collection"
	dim := 128

	// 2. Création du schéma (simplifié pour l'exemple)
	schema := client.NewSchema()
	schema.WithName(collectionName)
	schema.AddField(client.NewField[int64]("id", true))
	schema.AddField(client.NewVectorField("vec", dim))

	// 3. Création de la collection
	err = c.CreateCollection(ctx, schema, true)
	if err != nil {
		log.Printf("Note: la collection existe peut-être déjà: %v", err)
	}

	// 4. Insertion de données factices
	ids := []int64{1, 2, 3}
	vectors := [][]float32{
		make([]float32, dim), // vecteur de zéros
		make([]float32, dim), 
		make([]float32, dim),
	}
	// On modifie juste la première valeur pour la distinction
	vectors[0][0] = 0.9
	vectors[1][0] = 0.1

	err = c.Insert(ctx, collectionName, []string{"id", "vec"}, []interface{}{ids, vectors})
	if err != nil {
		log.Fatalf("Erreur insertion: %v", err)
	}

	// 5. Création de l'index pour permettre la recherche
	err = c.CreateIndex(ctx, collectionName, "vec", client.HNSW, map[string]interface{}{"M": 8})
	if err != nil {
		log.Fatalf("Erreur index: %v", err)
	}

	// 6. Chargement de la collection en mémoire
	err = c.LoadCollection(ctx, collectionName, false)
	if err != nil {
		log.Fatalf("Erreur chargement: %v", err)
	}

	// 7. Recherche
	queryVec := []float32{0.85, 0, 0 /* ... rest 0 */}
	searchParam, _ := client.NewIndexSearchParam("vec", client.HNSW, map[string]interface{}{"ef": 10})

	res, err := c.Search(ctx, collectionName, []string{"id"}, []client.Vector{client.FloatVector(queryVec)}, []client.MetricType{client.L2}, searchParam, 1)
	if err != nil {
		log.Fatalf("Erreur recherche: %v", err)
	}

	fmt.Printf("Recherche terminée. Résultats trouvés: %d\n", len(res))
	if len(res) > 0 {
		fmt.Printf("ID du plus proche voisin: %v\n", res[0].ID)
	}
}