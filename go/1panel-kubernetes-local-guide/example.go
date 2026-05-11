package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
)

// K8sMonitor simule un monitoring de santé pour 1Panel Kubernetes local.
// Il vérifie la présence du binaire kubectl et l'accès au cluster.
type K8sMonitor struct {
	ClusterName string
	Kubeconfig  string
}

func (m *K8sMonitor) CheckHealth() error {
	// Vérification de l'existence du fichier kubeconfig
	if _, err := os.Stat(m.Kubeconfig); os.IsNotExist(err) {
		return fmt.Errorf("kubeconfig introuvable : %s", m.Kubeconfig)
	}

	// Exécution de kubectl version pour tester la connectivité
	cmd := exec.Command("kubectl", "version", "--client")
	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("erreur kubectl : %s", string(out))
	}

	fmt.Printf("Cluster %s est accessible.\n", m.ClusterName)
	fmt.Printf("Version détectée : %s", string(out))
	return nil
}

func main() {
	// Configuration de l'instance de monitoring
	monitor := K8sMonitor{
		ClusterName: "Dev-Local-1Panel",
		Kubeconfig:  "/root/1panel/k3s/kubeconfig", // Chemin type 1Panel
	}

	fmt.Println("Démarrage du monitoring 1Panel Kubernetes local...")

	err := monitor.CheckHealth()
	if err != nil {
		log.Fatalf("Échec du monitoring : %v", err)
	}

	fmt.Println("Statut : OK")
}