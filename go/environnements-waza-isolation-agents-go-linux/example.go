package main

import (
	"fmt"
	"os"
	"os/exec"
	"syscall"
	"runtime"
)

// SandboxDemo illustre la création d'un environnement restreint.
// Ce code doit être exécuté avec des privilèges suffisants.
func SandboxDemo() error {
	// On verrouille le thread pour l'isolation
	runtime.LockOSThread()

	// On définit la commande à exécuter (un simple shell)
	cmd := exec.Command("/bin/sh")

	// Configuration des namespaces pour les <strong>Environnements waza</strong>
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | 
				syscall.CLONE_NEWPID | 
				syscall.CLONE_NEWNS | 
				syscall.CLONE_NEWNET,
	}

	// On vide l'environnement pour éviter la fuite de secrets
	cmd.Env = []string{"PATH=/usr/bin:/bin", "AGENT_ID=12345"}

	// Redirection des flux
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	fmt.Println("--- Démarrage de l'agent dans l'environnement waza ---")
	fmt.Println("--- Tapez 'exit' pour quitter ---")

	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("échec de l'exécution : %w", err)
	}

	fmt.Println("--- Fin de l'exécution de l'agent ---")
	return nil
}

func main() {
	if err := SandboxDemo(); err != nil {
		fmt.Fprintf(os.Stderr, "Erreur critique : %v\n", err)
		os.Exit(1)
	}
}