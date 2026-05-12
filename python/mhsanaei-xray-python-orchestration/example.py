import asyncio
import json
import subprocess
from pathlib import Path
from typing import Dict, Any

class XrayValidator:
    """Vérificateur de configuration MHSanaei Xray"""
    
    def __init__(self, config_path: Path):
        self.config_path = config_path

    def validate_syntax(self) -> bool:
        """Vérifie si le fichier JSON est syntaxiquement correct"""
        if not self.config_path.exists():
            print(f"Erreur : {self.configconfig_path} introuvable.")
            return False
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                json.load(f)
            return True
        except json.JSONDecodeError as e:
            print(f"Erreur syntaxe JSON : {e.msg} à la ligne {e.lineno}")
            return False

    def check_port_availability(self, port: int) -> bool:
        """Vérifie si le port est libre sur le système"""
        # Utilisation de ss (socket statistics) disponible sur Linux
        try:
            result = subprocess.run(
                ['ss', '-tuln'], 
                capture_output=True, 
                text=True, 
                check=True
            )
            return f":{port} " not in result.stdout
        except subprocess.CalledProcessError:
            return False

async def main_orchestrator():
    """Point d'entrée principal de l'orchestrateur"""
    config_file = Path("config.json")
    
    # Simulation d'un fichier de config pour l'exemple
    config_file.write_text(json.dumps({
        "inbounds": [{"port": 443, "protocol": "vless"}],
        "outbounds": [{"protocol": "freedom"}]
    }))

    validator = XrayValidator(config_file)
    
    print("--- Début de la vérification MHSanaei Xray ---")
    
    if not validator.validate_syntax():
        print("Échec : Le fichier JSON est corrompu.")
        return

    test_port = 443
    if not validator.check_port_availability(test_port):
        print(f"Échec : Le port {test_port} est déjà utilisé.")
    else:
        print(f"Succès : Le port {test_port} est disponible. Prêt pour le déploiement.")

    # Nettoyage
    config_file.unlink()

if __name__ == "__main__":
    asyncio.run(main_orchestrator())