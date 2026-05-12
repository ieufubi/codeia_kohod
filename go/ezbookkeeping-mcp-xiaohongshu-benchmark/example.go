package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"
)

// Request structure for JSON-RPC
type RPCRequest struct {
	JSONRPC string          `json:"jsonrpc"` 
	Method  string          `json:"method"`  
	Params  json.RawMessage `json:"params"`  
	ID      interface{}     `json:"id"`      
}

// Response structure for JSON-RPC
type RPCResponse struct {
	JSONRPC string      `json:"jsonrpc"` 
	Result  interface{} `json:"result,omitempty"` 
	Error   interface{} `json:"error,omitempty"` 
	ID      interface{} `json:"id"`      
}

func main() {
	// On utilise stderr pour les logs afin de ne pas polluer stdout
	logger := os.Stderr
	fmt.Fprintln(logger, "D\u00e9marrage du serveur ezbookkeeping MCP Xiaohongshu...")

	// Simulation d'une boucle de lecture sur Stdin (standard pour MCP)
	// Dans un vrai cas, on utiliserait un scanner sur os.Stdin
	input := `{"jsonrpc":"2.0","method":"get_post","params":{"id":"99"},"id":1}`

	var req RPCRequest
	err := json.Unmarshal([]byte(input), &req)
	if err != nil {
		fmt.Fprintf(logger, "Erreur de parsing: %v\n", err)
		os.Exit(1)
	}

	// Traitement de la r\u00e9qu\u00eate
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	processRequest(ctx, req)
}

func processRequest(ctx context.Context, req RPCRequest) {
	// Simulation d'un traitement de r\u00e9ponse
	response := RPCResponse{
		JSONRPC: "2.0",
		ID:      req.ID,
	}

	select {
	case <-time.After(50 * time.Millisecond):
		// Simulation r\u00e9ussie
		response.Result = map[string]string{"status": "success", "data": "post_content"}
	case <-ctx.Done():
		// Gestion du timeout
		response.Error = map[string]interface{}{"code": -32000, "message": "timeout"}
	}

	// La r\u00e9ponse finale est envoy\u00e9e sur STDOUT
	output, _ := json.Marshal(response)
	fmt.Println(string(output))
}