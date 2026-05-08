import asyncio
import random
import time
from typing import Final

# Simulation complète d'un cycle de vie de périphérique

DEVICE_ID: Final[str] = "sensor-alpha-99"
MAX_RETRIES: Final[int] = 3

class SimulatedDevice:
    def __init__(self, device_id: str):
        self.device_id = device_id
        self.current_temp: float = 20.0
        self.target_temp: float = 20.0
        self.is_running: bool = True

    async def read_sensor(self) -> float:
        """Simule une lecture de capteur avec un peu de bruit."""
        await asyncio.sleep(0.5)
        self.current_temp += random.uniform(-0.5, 0.5)
        return self.current_temp

    async def apply_control_logic(self):
        """Logique de réconciliation locale (Edge computing)."""
        if abs(self.current_temp - self.target_temp) > 1.0:
            print(f"[Edge] Écart détecté ({self.current_temp:.2f}°C). Ajustement en cours...")
            # Simulation d'une action physique (ex: allumer un chauffage)
            await asyncio.sleep(1)
            self.current_temp = self.target_temp
            print(f"[Edge] Température stabilisée à {self.current_temp:.2f}°C")

    async def run_loop(self):
        """Boucle principale de l'agent."""
        print(f"[Agent] Démarrage de l'agent pour {self.device_id}")
        try:
            while self.is_running:
                temp = await self.read_sensor()
                print(f"[Agent] Rapport d'état : {temp:.2f}°C")
                
                # Simulation de réception de commande du serveur
                if random.random() < 0.2:  # 20% de chance de recevoir une nouvelle cible
                    new_target = random.uniform(15.0, 30.0)
                    print(f"[Agent] NOUVELLE COMMANDE REÇUE : Cible = {new_target:.2f}°C")
                    self.target_temp = new_target
                
                await self.apply_control_logic()
                await asyncio.sleep(2)
        except asyncio.CancelledError:
            print("[Agent] Arrêt de l'agent.")
        finally:
            self.is_running = False

async def main():
    device = SimulatedDevice(DEVICE_ID)
    # On lance l'agent et on simule une interruption après 15 secondes
    task = asyncio.create_task(device.run_loop())
    
    await asyncio.sleep(15)
    print("[System] Arrêt programmé du test.")
    task.cancel()
    await asyncio.gather(task, return_exceptions=True)

if __name__ == "__main__":
    asyncio.run(main())