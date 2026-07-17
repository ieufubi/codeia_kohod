import threading
import time
from sync import Once

def simulate_expensive_init(resource_name: str) -> object:
    """Simule l'initialisation coûteuse d'une ressource externe."""
    print(f"[INIT] Début de l'initialisation pour {resource_name}... (Coût simulé)")
    time.sleep(1.0) # Simuler le coût élevé en I/O ou calcul CPU
    if resource_name == "DB":
        return f"ConnectionPool<{resource_name}>"
    else:
        raise ValueError("Ressource inconnue")

class SafeResourceSystem:
    def __init__(self):
        # L'état unique doit être lié à l'instance.
        self._once = Once()
        self.resource: object | None = None

    def setup_system(self, resource_name: str) -> object:
        """Initialise la ressource de manière atomique et thread-safe."""
        print("\nAuteur : Tentative d'accès à l'initialisation unique...")
        # Le bloc critique garantit que le setup ne s'exécutera qu'une fois.
        with self._once:
            self.resource = simulate_expensive_init(resource_name)
            print("[SUCCESS] Initialisation terminée et sécurisée par sync.Once.")
        return str(self.resource)

def worker(system: SafeResourceSystem, resource_name: str):
    """Fonction cible pour les threads qui testent la concurrence."""
    try:
        result = system.setup_system(resource_name)
        print(f"[Thread {threading.current_thread().name}] Accès réussi à : {result}")
    except Exception as e:
        print(f"[Thread {threading.current_thread().name}] Échec lors de l'initialisation: {e}")

if __name__ == "__main__":
    # Création du gestionnaire qui sera partagé par tous les threads.
    manager = SafeResourceSystem()
    threads = []
    NUM_THREADS = 5 # Utiliser un nombre plus petit pour la lisibilité de l'output

    print(f"--- Démarrage des {NUM_THREADS} workers en parallèle ---\n")
    start_time = time.monotonic()

    for i in range(NUM_THREADS):
        t = threading.Thread(target=worker, args=(manager, "DB"), name=f"Worker-{i}")
        threads.append(t)
        t.start()

    # Attendre la fin de tous les threads.
    for t in threads:
        t.join()

    end_time = time.monotonic()
    print("\n===============================================")
    print(f"Processus terminé en {end_time - start_time:.2f} secondes.")
    # Mesure : Le temps total devrait être proche de 1.0 seconde, prouvant que l'initialisation n'a été faite qu'une seule fois.