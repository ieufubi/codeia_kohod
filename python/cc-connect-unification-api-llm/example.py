import asyncio
import httpx
import time
from typing import List, Dict

class MockProvider:
    """Simule un fournisseur d'API pour les tests de cc connect."""
    def __init__(self, name: str, latency: float):
        self.name = name
        self.latency = latency

    async def respond(self, prompt: str) -> str:
        await asyncio.sleep(self.latency)
        return f"Response from {self.name} to: {prompt}"

class CCConnectSimulator:
    """Simule le comportement de cc connect (routing et transformation)."""
    def __init__(self):
        self.providers = {
            "gpt-4": MockProvider("OpenAI", 0.2),
            "claude-3": MockProvider("Anthropic", 0.8),
            "gemini": MockProvider("Google", 0.4)
        }

    async def route_request(self, model: str, prompt: str) -> str:
        if model not in self.providers:
            raise ValueError(f"Model {model} not found in cc connect config")
        
        provider = self.providers[model]
        return await provider.respond(prompt)

async def run_benchmark():
    """Benchmark simple pour comparer les performances de routage."""
    simulator = CCConnectSimulator()
    models_to_test = ["gpt-4", "claude-3", "gemini", "unknown"]
    
    print(f"\n--- Benchmark cc connect simulation ---")
    
    for model in models_to_test:
        start_time = time.perf_counter()
        try:
            print(f"Testing model: {model}...", end=" ", flush=True)
            response = await simulator.route_request(model, "Hello World")
            end_time = time.perf_counter()
            print(f"SUCCESS | Latency: {end_time - start_time:.4f}s | Result: {response}")
        except Exception as e:
            end_time = time.perf_counter()
            print(f"FAILED  | Latency: {end_time - start_time:.4f}s | Error: {e}")

if __name__ == "__main__":
    # Exécution du script de test
    asyncio.run(run_benchmark())