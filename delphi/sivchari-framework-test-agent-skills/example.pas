import subprocess
import json
import sys

# Script de monitoring de la qualité des skills via la CLI sivchari
# Ce script automatise la vérification après chaque déploiement

def run_skill_audit(skill_name: str, config_path: str) -> bool:
    print(f"--- Lancement de l'audit pour le skill: {skill_name} ---")
    
    try:
        # Appel de la commande CLI sivchari
        # On capture la sortie pour l'analyser programmatiquement
        result = subprocess.run(
            ["sivchari", "test", skill_name, "--config", config_path],
            capture_output=True,
            text=True,
            check=True
        )
        
        print("Sortie de la CLI:")
        print(result.stdout)
        return True

    except subprocess.CalledProcessError as e:
        print(f"ERREUR CRITIQUE: Le test du skill {skill_name} a échoué.")
        print(f"Détails de l'erreur: {e.stderr}")
        return False
    except FileNotFoundError:
        print("Erreur: La commande 'sivchari' n'est pas installée dans le PATH.")
        return False

if __name__ == "__main__":
    # Configuration du test
    SKILL_TO_TEST = "order_parser"
    CONFIG_FILE = "tests/sivchari_config.yaml"

    # Exécution de l'audit
    success = run_skill_audit(SKILL_TO_TEST, CONFIG_FILE)
    
    if success:
        print("Audit terminé: Le skill est conforme aux exigences.")
        sys.exit(0)
    else:
        print("Audit terminé: Régression détectée. Arrêt du déploiement.")
        sys.exit(1)