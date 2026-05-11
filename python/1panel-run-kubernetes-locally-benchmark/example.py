import os
import subprocess
import sys
from typing import Final

# Configuration des chemins
K3S_PATH: Final[str] = "/usr/local/bin/k3s"

class KubernetesManager:
    """Gestionnaire simplifié pour orchestrer des clusters locaux."""
    
    def __init__(self, cluster_name: str):
        self.cluster_name = cluster_name

    def check_service_running(self) -> bool:
        """Vérifie si le processus k3s est actif sur le système."""
        try:
            # Utilisation de pgrep pour vérifier la présence du processus
            result = subprocess.run(
                ["pgrep", "-f", "k3s"],
                capture_output=True,
                text=True
            )
            return result.returncode == 0
        except FileNotFoundError:
            print("Erreur: pgrep n'est pas installé.")
            return False

    def deploy_test_pod(self) -> None:
        """Déploie un pod Nginx pour valider le cluster."""
        manifest = f"""
apiVersion: v1
kind: Pod
metadata:
  name: test-nginx-{self.cluster_name}
spec:
  containers:
  - name: nginx
    image: nginx:alpine
"""
        
        # Écriture temporaire du manifeste
        filename = f"pod_{self.cluster_name}.yaml"
        with open(filename, "w") as f:
            f.write(manifest)
            
        try:
            print(f"Déploiement du pod sur {self.cluster_name}...")
            subprocess.run(["kubectl", "apply", "-f", filename], check=True)
            print("Déploiement réussi.")
        except subprocess.CalledProcessError:
            print("Échec du déploiement. Vérifiez votre configuration kubectl.")
        finally:
            if os.path.exists(filename):
                os.remove(filename)

def main() -> None:
    """Point d'entrée du script de déploiement."""
    manager = KubernetesManager("dev-local")
    
    if not manager.check_service_running():
        print("Erreur: Le cluster 1Panel : Run Kubernetes locally n'est pas démarré.")
        sys.exit(1)
        
    manager.deploy_test_pod()

if __name__ == "__main__":
    main()