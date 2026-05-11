import sys
from typing import Dict, List
from packaging.version import Version

class DependencyManager:
    """Simule un gestionnaire de dépendances pour service de streaming."""
    
    def __init__(self):
        self.dependencies: Dict[str, str] = {
            "jellyfin": "10.8.13",
            "navidne": "2.5.1",
            "transmission": "3.00.5"
        }

    def check_updates(self, registry_data: Dict[str, str]) -> List[str]:
        """Compare les versions locales avec les versions du registre."""
        updates_found = []
        for service, current_ver in self.dependencies.items():
            if service in registry_data:
                new_ver = registry_data[service]
                if Version(new_ver) > Version(current_ver):
                    updates_found.append(f"{service}: {current_ver} -> {new_ver}")
        return updates_found

if __name__ == "__main__":
    # Simulation d'un scan de registre après passage de Renovate
    manager = DependencyManager()
    remote_registry = {
        "jellyfin": "10.9.0",
        "navidne": "2.5.1",
        "transmission": "3.01.0"
    }
    
    print("--- Scan de dérive de version ---")
    updates = manager.check_updates(remote_registry)
    
    if not updates:
        print("Tout est à jour. Aucune action requise.")
    else:
        print("Mises à jour détectées :")
        for update in updates:
            print(f"[!] {update}")
    print("--- Fin du scan ---")