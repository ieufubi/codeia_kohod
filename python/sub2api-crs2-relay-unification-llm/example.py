import asyncio
import httpx
import time
from typing import Dict, Any

class Sub2APITestClient:
    """Client de test autonome pour valider le fonctionnement du relais."""
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base string(base_url).rstrip('/')
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }

    async def call_chat_completion(self, model: str, prompt: str) -> Dict[str, Any]:
        url = f"{self.base_url}/chat/completions"
        payload = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}]
        }
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                start_time = time.perf_counter()
                response = await client.post(url, json=payload, headers=self.headers)
                latency = time.perf_counter() - start_time
                
                response.raise_for_status()
                data = response.json()
                print(f"[SUCCESS] Modèle: {model} | Latence: {latency:.3f}s")
                return data
            except httpx.HTTPStatusError as e:
                print(f"[ERROR] Erreur HTTP: {e.response.status_code} - {e.response.text}")
                return {}
            except Exception as e:
                print(f"[ERROR] Erreur inattendue: {str(e)}")
                return {}

async def main():
    # Configuration de test (à adapter avec votre instance Sub2API-CRS2 relay)
    RELAY_URL = "http://localhost:8080/v1"
    TEST_KEY = "test-key-123"
    
    tester = Sub2APITestClient(RELAY_URL, TEST_KEY)
    
    print("--- Test de session LLM via Sub2API-CRS2 relay ---")
    
    # Test 1: Appel GPT-4o
    print("Test 1: Appel GPT-4o...")
    await tester.call_chat_completion("gpt-4o", "Explique le Zen de Python en une phrase.")
    
    # Test 2: Appel Claude (via le relais)
    print("\nTest 2: Appel Claude-3-Sonnet...")
    await tester.call_chat_completion("claude-3-5-sonnet", "Quelle est la capitale de la France ?")

if __name__ == "__main__":
    asyncio.run(main())