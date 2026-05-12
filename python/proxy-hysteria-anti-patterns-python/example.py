import asyncio
import signal
import sys
from typing import NoReturn

class HysteriaMonitor:
    """Exemple de monitoring simplifié du proxy Hysteria."""
    
    def __init__(self):
        self.running = True
        self.loss_history = []

    async def watch_logs(self, process: asyncio.subprocess.Process) -> None:
        """Lit stdout et extrait la perte de paquets."""
        while self.running:
            line = await process.stdout.readline()
            if not line:
                break
            
            decoded_line = line.decode('utf-8').strip()
            print(f"[LOG] {decoded_line}")
            
            # Simulation d'extraction de perte de paquets
            if "loss=" in decoded_line:
                try:
                    loss_val = float(decoded_line.split("loss=")[1].split()[0])
                    self.loss_history.append(loss_val)
                    print(f"--> Taux de perte actuel: {loss_val*100}%")
                except (IndexError, ValueError):
                    pass

    async def run_forever(self) -> None:
        """Point d'entrée principal du moniteur."""
        # Simulation d'un processus Hysteria (remplacez par le vrai binaire)
        cmd = [sys.executable, "-c", "import time; print('loss=0.01'); time.sleep(10)"]
        
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE
        )
        
        # Gestion du signal d'arrêt
        loop = asyncio.get_running_loop()
        for sig in (signal.SIGINT, signal.SIGTERM):
            loop.add_signal_handler(sig, lambda: asyncio.create_task(self.shutdown()))

        try:
            await self.watch_logs(process)
        except Exception as e:
            print(f"Erreur critique: {e}")
        finally:
            await process.wait()

    async def shutdown(self) -> None:
        """Procédure de fermeture propre."""
        print("\nArrêt du moniteur en cours...")
        self.running = False
        # Ici, on fermerait le vrai processus Hysteria

if __name__ == "__main__":
    monitor = HysteriaMonitor()
    try:
        asyncio.run(monitor.run_forever())
    except KeyboardInterrupt:
        pass