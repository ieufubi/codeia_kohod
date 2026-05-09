package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/fsnotify/fsnotify"
)

// ProductionReadyWatcher gère la surveillance avec gestion de contexte et debounce
func ProductionReadyWatcher(ctx context.Context, path string) error {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return err
	}
	defer watcher.Close()

	if err := watcher.Add(path); err != nil {
		return err
	}

	// Canal pour le debouncing
	debounceTimer := time.NewTimer(0)
	if !debounceTimer.Stop() {
		<-debounceTimer.C
	}

	fmt.Printf("Démarrage de la surveillance sur : %s\n", path)

	for {
		select {
		case <-ctx.Done():
			fmt.Println("Arrêt demandé...")
			return nil

		case err, ok := <-watcher.Errors:
			if !ok {
				return nil
			}
			log.Printf("Erreur watcher: %v", err)

		case event, ok := <-watcher.Events:
			if !ok {
				return nil
			}

			// Logique de debounce : on attend la fin de l'écriture
			if event.Has(fsnotify.Write) {
				fmt.Printf("Modification détectée : %s. Attente stabilisation...\n", event.Name)
				debounceTimer.Reset(500 * time.Millisecond)
			}

		case <-debounceTimer.C:
			fmt.Println("Fichier stable. Traitement du contenu terminé.")
		}
	}
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Création d'un fichier temporaire pour le test
	tmpFile := "test_event.txt"
	_ = os.WriteFile(tmpFile, []byte("init"), 0644)
	defer os.Remove(tmpFile)

	// Lancement du watcher
	err := ProductionReadyWatcher(ctx, ".")
	if err != nil {
		log.Fatal(err)
	}

	// Simulation d'une écriture après 1 seconde
	time.Sleep(1 * time.Second)
	_ = os.WriteFile(tmpFile, []byte("updated data"), 0644)

	// Attente pour laisser le debounce s'exécuter
	time.Sleep(2 * time.Second)
}