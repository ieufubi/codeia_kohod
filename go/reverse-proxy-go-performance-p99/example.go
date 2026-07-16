package main

import (
    "context"
    "fmt"
    "io"
    "log"
    "net/http"
    "time"
)

type TestProxy struct {
    TargetURL string
}

// SimulateService appelle une URL distante et mesure le temps.
func (tp *TestProxy) SimulateService(ctx context.Context, reqBody io.Reader) error {
    client := &http.Client{
        Timeout: 5 * time.Second,
    }

    req, _ := http.NewRequestWithContext(ctx, "POST", tp.TargetURL, reqBody)
    resp, err := client.Do(req)
    if err != nil {
        return fmt.Errorf("erreur de connexion ou timeout: %w", err)
    }
    defer resp.Body.Close()

    // Simulation d'un traitement lent en lisant le corps.
    _, readErr := io.Copy(io.Discard, resp.Body) 
    if readErr != nil { 
        return fmt.Errorf("erreur de lecture du body: %w", readErr)
    }
	return nil
}

func main() {
    // Utilisation d'une URL locale pour le test.
    const target = "http://localhost:8080/api/data"
    proxy := &TestProxy{TargetURL: target}

    // Créer un corps de données simulé (ex: 1MB)
    body := make([]byte, 1024*1024)
	reader := io.NopCloser(bytes.NewReader(body))

    // Contexte avec une durée limitée pour simuler un timeout client.
    ctx, cancel := context.WithTimeout(context.Background(), 3 * time.Second)
    defer cancel()

    fmt.Println("Début de la simulation proxy...")
	if err := proxy.SimulateService(ctx, reader); err != nil {
        log.Printf("Simulation terminée avec erreur attendue (si timeout) : %v", err)
    }
}