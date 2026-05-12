import asyncio
import httpx
from fastapi import FastAPI, Request
from contextlib import asynccontextmanager

# Gestion du cycle de vie pour un client HTTP propre
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialisation du client au démarrage
    app.state.client = httpx.AsyncClient(timeout=10.0)
    yield
    # Fermeture propre des connexions à l'arrêt
    await app.state.client.aclose()

app = FastAPI(lifespan=lifespan)

@app.get("/proxy/{service_name}")
async def dynamic_proxy(service_name: str, request: Request):
    """
    Exemple de routage dynamique basé sur le nom du service.
    Ceci est une implémentation simplifiée d'une plateforme proxy universelle.
    """
    # Mapping fictif (dans la réalité, cela viendrait d'une DB ou config)
    registry = {
        "users": "https://jsonplaceholder.typicode.com/users",
        "posts": "https://jsonplaceholder.typicode.com/posts"
    }
    
    target_base = registry.get(service_name)
    if not target_base:
        return {"error": "Service non répertorié dans la plateforme proxy universelle"}

    # Construction de la cible
    path = request.url.path.replace(f"/proxy/{service_name}", "")
    target_url = f"{target_base}{path}"

    # Proxying de la requête
    try:
        resp = await request.app.state.client.get(target_url)
        return {
            "proxied_url": target_url,
            "status": resp.status_code,
            "data": resp.json()
        }
    except Exception as e:
        return {"error": f"Échec du proxying: {str(e)}"}

if __name__ == "__main:
    import uvicorn
    # Lancement du serveur
    uvicorn.run(app, host="0.0.0.0", port=8000)