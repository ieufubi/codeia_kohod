package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// ToolResult définit la structure de retour d'un outil MCP
type ToolResult struct {
	Content string `json:"content"`
}

// MCPTool est l'implémentation concrète d'une fonction de scraping
type MCPTool struct {
	Timeout time.Duration
}

// Call exécute la logique métier avec gestion de contexte
func (t *MCPTool) Call(ctx context.Context, args map[string]interface{}) (*ToolResult, error) {
	// Simulation d'un délai réseau
	select {
	case <-time.After(500 * time.Millisecond):
		id, ok := args["id"].(string)
		if !ok {
			return nil, fmt.Errorf("argument 'id' doit être un string")
		}
		return &ToolResult{Content: "Données pour post " + id}, nil
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func main() {
	tool := &MCPTool{Timeout: 2 * time.Second}

	// Simulation d'une requête client
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	args := map[string]interface{}{"id": "xhs_99"}

	fmt.Println("Exécution de l'outil MCP...")
	result, err := tool.Call(ctx, args)
	if err != nil {
		fmt.Printf("Erreur: %v\n", err)
		return
	}

	output, _ := json.MarshalIndent(result, "", "  ")
	fmt.Printf("Résultat: %s\n", string(output))
}