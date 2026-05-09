import asyncio
import httpx
import time

# Simulation d'un client agent utilisant le Sub2API-CRS2 proxy
class AI_Agent:
    def __init__(self, proxy_url: str, api_key: str):
        self.proxy_url = proxy_url
        self.headers = {"x-api-key": api_key, "Content-Type": "application/json"}

    async def ask(self, model: str, prompt: str):
        payload = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}]
        }
        
        start_time = time.perf_counter()
        async with httpx.AsyncClient() as client:
            try:
                # On simule l'appel vers le proxy
                response = await client.post(
                    f"{self.proxy_url}/v1/chat/completions",
                    json=payload,
                    headers=self.headers,
                    timeout=10.0
                )
                latency = time.perf_counter() - start_time
                
                if response.status_code == 200:
                    data = response.json()
                    print(f"[SUCCESS] Model: {model} | Latency: {latency:.2f}s")
                    print(f"Response: {data['choices'][0]['message']['content']}")
                else:
                    print(f"[ERROR] Status: {response.status_code} | {response.text}")
            
            except Exception as e:
                print(f"[CRITICAL] Connection failed: {e}")

async def main():
    # Configuration de l'agent vers le proxy local
    agent = AI_Agent(proxy_url="http://localhost:8080", api_key="user_alpha")
    
    # Test de plusieurs modèles via le même proxy
    print("--- Test 1: GPT-4 ---")
    await agent.ask("gpt-4", "Explique la récursion en Python.")
    
    print("\n--- Test 2: Claude-3 ---")
    await agent.ask("claude-3", "Quelle est la complexité de l'algorithme de sorting?")

if __name__ == "__main":
    asyncio.run(main())