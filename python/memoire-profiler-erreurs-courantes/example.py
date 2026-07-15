import time
import gc
from memory_profiler import profile
import numpy as np

def allocate_and_process(size: int) -> tuple[float, float]:
    """Simule l'allocation de mémoire et le traitement externe."""
    # Allocation Python visible par memory_profiler (Heap)
    large_list = [i for i in range(size)] 
    time.sleep(0.01) # Simuler un travail CPU
    
    # Allocation C/C++ invisible pour le profiler simple (Mémoire externe)
    data_np = np.random.rand(int(size / 2))
    sum_val = np.sum(data_np)
    return float(large_list[-1]), sum_val

@profile 
def run_test_cycle(iterations: int):
    """Exécute le cycle N fois pour mesurer la stabilité mémoire."""
    print("Démarrage du profilage sur", iterations, "cycles...")
    total_mem = 0.0
    for i in range(iterations):
        # Forcer l'isolation des cycles de mesure.
        gc.collect()
        start_time = time.monotonic() 
        l, s = allocate_and_process(10000) # Taille fixe pour la comparaison.
        end_time = time.monotonic()
        total_mem += (s + l)
    print("Cycle terminé. Analyse des résultats dans le rapport memory_profile.")

if __name__ == '__main__':
    # Exécuter ce script via : python -m memory_profiler nom_du_fichier.py
    run_test_cycle(iterations=10)