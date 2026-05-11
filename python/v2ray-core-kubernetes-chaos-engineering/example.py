import json
import os
import time
from typing import List, Dict

class ChaosController:
    """
    Contrôleur de chaos pour v2ray core Kubernetes.
    Gère l'injection et la suppression automatique des anomalies.
    """
    def __init__(self, config_path: str):
        self.config_path = config_path
        self.original_config: Dict = {}

    def load_config(self) -> None:
        if not os.path.exists(self.config_path):
            raise FileNotFoundError(f"Config introuvable: {self.config_path}")
        with open(self.config_path, 'r') as f:
            self.original_config = json.load(f)

    def inject_latency(self, delay_ms: int) -> None:
        """Injecte une latence dans l'outbound principal."""
        new_config = json.loads(json.dumps(self.original_config))
        if 'outbounds' in new_config:
            outbound = new_config['outbounds'][0]
            outbound.setdefault('settings', {})['latency'] = delay_ms
            self._apply(new_config)

    def _apply(self, config: Dict) -> None:
        with open(self.config_path, 'w') as f:
            json.dump(config, f, indent=4)
        print("Configuration v2ray core Kubernetes mise à jour.")

    def rollback(self) -> None:
        """Restaure la configuration initiale."""
        if self.original_config:
            with open(self.config_path, 'w') as f:
                json.dump(self.original_config, f, indent=4)
            print("Rollback effectué.")

if __name__ == "__main__":
    # Simulation de workflow
    # Création d'un fichier de test
    test_config = "/tmp/v2ray_test.json"
    initial_data = {
        "outbounds": [{"protocol": "freedom", "settings": {}}]
    }
    
    with open(test_config, 'w') as f:
        json.dump(initial_data, f)

    controller = ChaosController(test_config)
    controller.load_config()

    try:
        print("Début de l'expérience de chaos...")
        controller.inject_latency(1500)
        time.sleep(2)  # Simulation de la durée du test
    finally:
        controller.rollback()