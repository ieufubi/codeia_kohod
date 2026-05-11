import asyncio
import time
import random
from typing import List

class CopilotSimulator:
    """
    Simulateur de comportement du github copilot cli pour tester
    la robustesse de nos scripts de monitoring.
    """
    def __init__(self, latency_range: tuple[float, float]):
        self.latency_range = latency_range
        self.request_count = 0

    async def suggest_code(self, prompt: str) -> str:
        """
        Simule une requête de suggestion de code avec latence aléatoire.
        """
        self.request_count += 1
        latency = random.uniform(*self.latency_range)
        
        # Simulation du délai réseau
        await asyncio.sleep(latency)
        
        if "error" in prompt.lower():
            raise ConnectionError("Échec de la connexion au github copilot cli")
            
        return f"// Suggestion pour: {prompt}\n    return True"

async def monitor_performance(simulator: CopilotSimulator, iterations: int):
    """
    Boucle de monitoring pour mesurer la stabilité du tunnel Xray.
    """
    start_time = time.perf_counter()
    errors = 0
    
    for i in range(iterations):
        try:
            prompt = f"function test_{i}() {{ "
            result = await simulator.suggest_code(prompt)
            print(f"[{i}] Succès ({len(result)} chars)")
        except Exception as e:
            print(f"[{i}] Erreur: {e}")
            errors += 1
        await asyncio.sleep(0.5)
        
    total_time = time.perf_counter() - start_time
    print(f"\n--- Rapport de monitoring ---")
    print(f"Total requêtes: {iterations}")
    print(f"Erreurs détectées: {errors}")
    print(f"Temps total: {total_time:.2f}s")
    print(f"Moyenne par requête: {total_time/iterations:.2f}s")

if __name__ == "__main__":
    # Simulation d'un proxy avec une latence entre 0.1s et 0.8s
    simulator = CopilotSimulator(latency_range=(0.1, 0.8))
    
    print("Démarrage du monitoring du github coprypt cli...")
    try:
        asyncio.run(monitor_performance(simulator, 10))
    except KeyboardInterrupt:
        print("\nMonitoring arrêté par l'utilisateur.")