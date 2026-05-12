package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"time"
)

// Ce programme simule un agent IA qui génère un fichier contenant un secret,
// puis utilise gitleaks pour valider la sécurité du contenu.

func main() {
	secretFile := "generated_config.txt"
	secretContent := "AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"

	// 1. Simulation de l'agent qui écrit un fichier dangereux
	err := os.WriteFile(secretFile, []byte(secretContent), 0644)
	if err != nil {
		fmt.Printf("Erreur lors de la création du fichier : %v\n", err)
		os.Exit(1)
	}
	defer os.Remove(secretFile) // Nettoyage

	fmt.Println("Agent IA : Fichier généré. Lancement du scan gitleaks Cloud Native...")

	// 2. Configuration du scanner avec un timeout strict
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 3. Exécution de gitleaks sur le fichier spécifique
	// On utilise --redact pour protéger les logs
	cmd := exec.CommandContext(ctx, "gitleaks", "detect", "--path", secretFile, "--redact")

	output, err := cmd.CombinedOutput()

	// 4. Analyse du résultat
	if err != nil {
		// Si l'exit code est non nul, gitleaks a trouvé un secret ou a échoué
		fmt.Printf("ALERTE : Fuite de secret détectée !\n")
		fmt.Printf("Sortie du scanner : %s\n", string(output))
		fmt.Println("Action : Blocage du commit et notification de l'équipe sécurité.")
		os.Exit(1)
	}

	fmt.Println("Succès : Aucun secret détecté dans le fichier généré.")
}