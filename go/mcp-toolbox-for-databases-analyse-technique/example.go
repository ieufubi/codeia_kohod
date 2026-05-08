package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq" // Driver PostgreSQL
)

// Ce code illustre un serveur MCP minimaliste pour tester une connexion SQL.
// Il simule l'exécution d'une requête via un contexte avec timeout.
func main() {
	// Configuration de la connexion (à adapter avec vos credentials)
	connStr := "postgres://user:pass@localhost:5432/dbname?sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Erreur ouverture DB: %v", err)
	}
	defer db.Close()

	// Simulation d'une requête provenant d'un client MCP
	query := "SELECT version();"
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Exécution de la requête
	var version string
	err = db.QueryRowContext(ctx, query).Scan(&version)
	if err != nil {
		// On écrit l'erreur sur stderr pour ne pas polluer le canal MCP (stdout)
		fmt.Fprintf(os.Stderr, "Erreur exécution SQL: %v\n", err)
		os.Exit(1)
	}

	// Le résultat est écrit sur stdout, format conforme MCP (simplifié)
	fmt.Printf("{{\"result\": \"%s\"}}\n", version)
}