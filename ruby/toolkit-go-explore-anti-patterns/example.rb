package main

import (
	"fmt"
	"errors"
)

// InfrastructureNode représente une ressource dans notre graphe
type InfrastructureNode struct {
	Name string
	Type string
}

// DeploymentEngine simule le comportement du toolkit Go explore
type DeploymentEngine struct {
	Nodes []InfrastructureNode
}

// AddResource ajoute une ressource avec validation de type
func (e *DeploymentEngine) AddResource(name, nodeType string) error {
	if name == "" {
		return errors.New("le nom de la ressource ne peut pas être vide")
	}
	if nodeType == "" {
		return errors.New("le type de ressource est obligatoire")
	}
	e.Nodes = append(e.Nodes, InfrastructureNode{Name: name, Type: nodeType})
	return nil
}

// Evaluate simule la phase d'évaluation du toolkit
func (e *DeploymentEngine) Evaluate() error {
	fmt.Println("--- Phase d'évaluation en cours ---")
	for _, node := range e.Nodes {
		if node.Type == "Forbidden" {
			return fmt.Errorf("ressource interdite détectée: %s", node.Name)
		}
		fmt.Printf("[OK] Ressource validée: %s (%s)\n", node.Name, node.Type)
	}
	return nil
}

func main() {
	// Simulation d'un utilisateur utilisant le toolkit
	engine := &DeploymentEngine{}

	// Ajout de ressources
	err := engine.AddResource("web-server", "Compute")
	if err != nil {
		fmt.Println("Erreur lors de la configuration:", err)
		return
	}

	err = engine.AddResource("database", "Storage")
	if err != nil {
		fmt.Println("Erreur lors de la configuration:", err)
		return
	}

	// Tentative d'ajout d'une ressource malveillante
	err = engine.AddResource("malware-node", "Forbidden")
	if err != nil {
		fmt.Println("Erreur de sécurité:", err)
	}

	// Lancement de l'évaluation
	if err := engine.Evaluate(); err != nil {
		fmt.Printf("Échec de l'évaluation: %v\n", err)
	} else {
		fmt.Println("Prêt pour le déploiement!")
	}
}