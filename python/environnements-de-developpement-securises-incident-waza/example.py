import os
import subprocess
import sys
from typing import List, Dict

class SecureExecutor:
    """
    Un exécutable autonome démontrant l'isolation de l'environnement.
    Ce script simule la création d'un environnement de développement sécurisé.
    """
    
    def __init__(self, whitelist_bins: List[str], safe_env: Dict[str, str]):
        self.whitelist_bins = whitelist_bins
        self.safe_env = safe_env

    def run(self, args: List[str]) -> None:
        if not args:
            print("Erreur: Aucune commande fournie.")
            return

        # Vérification de la whitelist (Sécurité de niveau 1)
        if args[0] not in self.whitelist_bins:
            print(f"ALERTE SÉCURITÉ: Tentative d'exécution de {args[0]} bloquée.")
            return

        print(f"Exécution sécurisée de: {' '.join(args)}")
        
        try:
            # Exécution avec environnement restreint (Sécurité de niveau 2)
            # On utilise shell=False pour empêcher l'injection de commandes
            result = subprocess.run(
                args,
                env=self.safe_env,
                shell=False,
                check=True,
                capture_output=True,
                text=True
            )
            print("Sortie:", result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Erreur lors de l'exécution: {e.stderr}")
        except Exception as e:
            print(f"Erreur inattendue: {e}")

def main():
    # Configuration de la sandbox
    # On ne définit que le PATH minimal et une variable de debug
    allowed_env = {
        "PATH": "/usr/bin:/bin",
        "APP_MODE": "SANDBOX"
    }
    
    # Seuls echo et ls sont autorisés
    allowed_commands = ["echo", "ls", "printf"]
    
    executor = SecureExecutor(allowed_commands, allowed_env)

    print("--- Scénario 1: Commande autorisée ---")
    executor.run(["echo", "Bonjour le monde de la sécurité!"])

    print(
        "\n--- Scénario 2: Tentative d'injection (shell=False protège ici) ---"
    )
    # Même si l'utilisateur essaie d'ajouter une commande via un argument
    executor.run(["echo", "Hello; cat /etc/passwd"])

    print(
        "\n--- Scénario 3: Commande interdite (Whitelist) ---"
    )
    executor.run(["cat", "/etc/hostname"])

if __name__ == "__main__":
    # Vérification de la version de Python pour les fonctionnalités de typage
    if sys.version_info < (3, 12):
        print("Ce script nécessite Python 3.12+")
        sys.exit(1)
    main()