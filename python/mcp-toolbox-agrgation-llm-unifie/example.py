import asyncio
import time
import httpx

# --- Configuration simulée ---
API_KEYS = {
    "openai": "sk-dummy-openai",
    "gemini": "AIzaSy-dummy-gemini"
}

async def fetch_llm_response(provider: str, prompt: str) -> str:
    """Simule un appel API avec un délai variable pour simuler la latence."""
    print(f"[START] Appel {provider}...")
    # Simule une latence aléatoire entre 0.5 et 1.5 seconde
    latency = 0.5 + hash(provider) % 100 / 100.0
    await asyncio.sleep(latency)
    
    if provider == "openai" and time.time() % 10 > 8: # Simule une panne OpenAI 20% du temps
        raise httpx.ConnectError(f"Simulation de panne réseau pour {provider}.")
        
    return f"Réponse de {provider} : Le concept est {prompt[:20]}... (Latence: {latency:.2f}s)"

async def run_parallel_llm_call(prompts: list[str]):
    """Exécute plusieurs appels LLM en parallèle pour maximiser le débit."""
    print("\n--- Début de l'exécution parallèle (asyncio.gather) ---")
    
    # Créer une liste de tâches asynchrones
    tasks = []
    for provider in ['openai', 'gemini', 'claude']:
        tasks.append(fetch_llm_response(provider, prompts[0]))
    
    start_time = time.time()
    
    try:
        # asyncio.gather exécute toutes les tâches en même temps
        results = await asyncio.gather(*tasks, return_exceptions=True)
        end_time = time.time()
        
        print("\n--- Résumé des résultats ---")
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                print(f"[FAIL] Échec de l'appel {['openai', 'gemini', 'claude'][i]}: {type(result).__name__}")
            else:
                print(f"[OK] {result}")
        
        print(f"\nTemps total d'exécution : {end_time - start_time:.2f} secondes.")

    except Exception as e:
        print(f"Erreur globale : {e}")

if __name__ == "__main__":
    prompt_test = "Explique le rôle du circuit breaker dans un microservice."
    asyncio.run(run_parallel_llm_call([prompt_test]))