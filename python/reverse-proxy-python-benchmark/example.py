import asyncio
import httpx
def run_proxy_test(target_url: str, source_headers: dict):
    """
    Simule l'envoi d'une requête via un reverse proxy Python.
    Ce code utilise les concepts ASGI (Starlette/httpx) pour simuler le transfert L7.
    """
    async def execute_request():
        # httpx est utilisé ici comme substitut fonctionnel à l'objet Request d'ASGI,
        # car il gère nativement la gestion des sessions et les en-têtes de manière typée.
        print(f"[DEBUG] Tentative connexion au target : {target_url}")
        try:
            async with httpx.AsyncClient() as client:
                # Le proxy doit passer tous les headers pour ne pas perdre d'infos contextuelles.
                response = await client.get(
                    target_url,
                    headers=source_headers,
                    timeout=5.0 # Timeout crucial en production
                )
                print(f"[SUCCESS] Code de statut reçu : {response.status_code}")
                return response.text[:100] + "... (réponse complète)"
        except httpx.TimeoutException:
            # Gestion explicite des timeouts est une bonne pratique.
            print("[ERROR] Timeout atteint lors de la connexion au backend.")
            return None
        except Exception as e:
            print(f"[CRITICAL ERROR] Erreur imprévue : {e}")
            return None

async def main():
    # Simulation d'un client externe qui envoie des headers spécifiques.
    source_headers = {
        'User-Agent': 'MyCustomProxyClient/1.0',
        'X-Forwarded-For': '203.0.113.42', # L'IP réelle du client
        'Accept': '*/*', 
    }
    # URL cible simulée (doit être accessible pour le test).
    target = "https://httpbin.org/get"

    resultat_proxy = await execute_request()
    if resultat_proxy:
        print("\n--- Résultat final du proxy ---")
        # Ici, on pourrait parser la réponse pour vérifier que X-Forwarded-* a bien été reçu.
        print(f"Contenu traité : {resultat_proxy}")
    else:
        print("Le processus de proxy a échoué ou le backend est injoignable.")

if __name__ == "__main__/: 
    # Exécuter l'async main pour simuler un cycle I/O complet.
    try: 
        asyncio.run(main())
    except KeyboardInterrupt:
        pass