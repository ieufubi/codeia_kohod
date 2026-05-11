import os
import sys
from kubernetes import client, config
from typing import Dict, Optional

class K8sMonitor:
    """
    Classe de monitoring pour un cluster 1Panel Kubernetes local.
    Utilise le typage statique pour garantir la robustie.
    """
    def __init__(self, kubeconfig_path: Optional[str] = None):
        self.kubeconfig = kubeconfig_path or os.path.expanduser("~/.kube/config")
        self._initialize_client()

    def _initialize_client(self) -> None:
        """Initialise la connexion au cluster."""
        try:
            if os.path.exists(self.kubeconfig):
                config.load_kube_config(config_file=self.kubeconfig)
            else:
                raise FileNotFoundError(f"Kubeconfig introuvable : {self.kubeconfig}")
        except Exception as e:
            print(f"Erreur d'initialisation : {e}")
            sys.exit(1)

    def get_node_metrics(self) -> Dict[str, str]:
        """Récupère les informations de base des nœuds."""
        v1 = client.CoreV1Api()
        nodes = v1.list_node()
        metrics = {}
        
        for node in nodes.items:
            name = node.metadata.name
            # On récupère simplement l'état de disponibilité
            status = "Unknown"
            for condition in node.status.conditions:
                if condition.type == "Ready" and condition.status == "True":
                    status = "Ready"
            metrics[name] = status
        return metrics

def main() -> None:
    """Point d'entrée principal du script de monitoring."""
    monitor = K8sMonitor()
    print("--- Rapport de santé du cluster K3s (1Panel) ---")
    
    try:
        node_stats = monitor.get_node_metrics()
        if not node_stats:
            print("Aucun nœud détecté.")
            return

        for node, status in node_stats.items:
            icon = "✅" if status == "Ready" else "❌"
            print(f"Nœud: {node:<20} Statut: {status:<10} {icon}")
            
    except Exception as e:
        print(f"Une erreur critique est survenue : {e}")

if __name__ == "__main__":
    main()