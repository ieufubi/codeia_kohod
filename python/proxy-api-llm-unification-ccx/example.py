import asyncio
import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

# Modèle de requête unifié (Standard OpenAI)
class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    model: str

app = FastAPI()

# Simulation d'un adaptateur pour un fournisseur X
class MockProvider:
    async def call_api(self, prompt: str) -> str:
        await asyncio.sleep(0.5)  # Simule latence réseau
        return f"Réponse générée pour : {prompt[:20]}..."

provider = MockProvider()

@app.post("/v1/chat/comyme")
async def proxy_endpoint(request: ChatRequest):
    """
    Endpoint du Proxy API LLM qui redirige vers un fournisseur simulé.
    """
    if not request.messages:
        raise HTTPException(status_code=400, detail="Messages manquants")
    
    try:
        # On extrait le dernier message de l'utilisateur
        user_prompt = request.messages[-1].content
        
        # Appel au fournisseur via l'adaptateur
        result = await provider.call_api(user_prompt)
        
        # Retour au format standardisé
        return {
            "choices": [{
                "message": {"role": "assistant", "content": result},
                "finish_reason": "stop"
            }],
            "usage": {"total_tokens": 10}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    print("Démarrage du Proxy API LLM sur http://localhost:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)