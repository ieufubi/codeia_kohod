package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strings"
)

// AIInterceptor simule l'analyse intelligente du terminal Caddy AI
type AIInterceptor struct {
	threshold int
}

// Write implémente l'interface io.Writer pour intercepter les données
func (a *AIInterceptor) Write(p []byte) (n int, err error) {
	content := string(p)
	// On cherche des mots clés d'erreur pour déclencher l'IA
	if strings.Contains(content, "error") || strings.Contains(content, "failed") {
		fmt.Printf("\n[AI ANALYST] Detection d'une anomalie : %s", content)
		fmt.Println("Suggestion : Vérifiez les permissions ou les dépendances.")
	}
	// On renvoie les données vers la destination d'origine (Stdout)
	return os.Stdout.Write(p)
}

func main() {
	// Simulation d'un flux de commande
	commandOutput := "Executing task...\nError: connection refused\nTask failed."
	reader := strings.NewReader(commandOutput)
	
	// Initialisation de l'intercepteur
	interceptor := &AIInterceptor{}
	
	// On utilise TeeReader pour lire le flux tout en l'envoyant à l'intercepteur
	tee := io.TeeReader(reader, interceptor)

	// Lecture et affichage du flux original
	scanner := bufio.NewScanner(tee)
	fmt.Println("--- Début du flux terminal ---")
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
	fmt.Println("--- Fin du flux terminal ---")
}