import asyncio
import httpx
import sys

# Simulation d'un agent de test pour le Relais API LLM
# Ce script teste la connectivité vers un endpoint de proxy

async def test_llm_proxy(proxy_url: str, provider: str):
    payload = {
        "model": f"{provider}-model",
        "messages": [{"role": "user", "content": "Test de latence"}],
        "stream": False
    }
    
    async with httpx.AsyncClient() as client:
        print(f"[*] Test de l'appel vers le provider: {provider}")
        try:
            start_time = asyncio.get_event_loop().time()
            response = await client.post(f"{proxy_url}/v1/chat/completions/{provider}", json=payload)
            end_time = asyncio.get_event_loop().time()
            
            duration = end_time - start_time
            
            if response.status_code == 200:
                print(f"[+] Succès ! Temps de réponse: {duration:.2f}s")
                print(f"[+] Contenu: {response.json().get('choices', [{}])[0].get('message', {}).get('content', 'Pas de contenu')}")
            else:
                print(f"[-] Erreur {response.status_code}: {response.text}")
                
        except Exception as e:
            print(f"[!] Échec de la connexion au relais: {e}")

if __name__ == "__main__":
    # URL de l'instance locale du relais
    TARGET_PROXY = "http://localhost:8000"
    
    # Liste des providers à tester
    test_providers = ["openai", "claude", "gemini"]
    
    loop = asyncio.get_event_loop()
    for provider in test_providers:
        loop.run_until_complete(test_llm_proxy(TARGET_PROXY, provider))
    
    print("[*] Tests terminés.")