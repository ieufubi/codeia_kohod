package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

// Ce programme illustre une détection de secrets par streaming.
// Il est conçu pour être utilisé sur de gros fichiers sans impact mémoire.

const ( 
	patternAPI = `(?i)api_key:[a-z0-9]{32}` // Pattern insensible à la casse
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run main.go <file_path>")
		os.Exit(1)
	}

	filePath := os.Args[1]
	re, err := os.Open(filePath)
	if err != nil {
		fmt.Printf("Erreur ouverture fichier: %v\n", err)
		os.Exit(1)
	}
	defer r.Close()

	re := regexp.MustCompile(patternAPI)
	scanner := bufio.NewScanner(r)
	
	lineCount := 0
	foundCount := 0

	// Lecture ligne par ligne pour garantir la stabilité mémoire
	for scanner.Scan() {
		lineCount++
		line := scanner.Text()
		if re.MatchString(line) {
			foundCount++
			fmt.Printf("[ALERTE] Ligne %d: Secret détecté -> %s\n", lineCount, line)
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Printf("Erreur lors de la lecture: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("\nScan terminé. Lignes analysées: %d. Secrets trouvés: %d.\n", lineCount, foundCount)
}