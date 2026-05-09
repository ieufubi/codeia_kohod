import asyncio
import httpx
from datetime import datetime
from typing import List, Dict

class Sub2APICRS2Simulator:
    """
    Simulation complète d'un service Sub2API-CRS2.
    Ce script démontre le routage, la gestion de session et le logging.
    """
    def __init__(self):
        self.sessions = ["session_alpha", "session_beta", "session_gamma"]
        self.history: List[Dict] = []
        self.lock = asyncio.Lock()

    async def process_request(self, model: str, user_id: str) -> Dict:
        start_time = datetime.now()
        
        async with self.lock:
            if not self.sessions:
                return {"error": "No sessions available", "status": 429}
            current_session = self.sessions.pop(0)

        try:
            # Simulation d'un délai réseau vers le fournisseur (ex: Claude ou OpenAI)
            await asyncio.sleep(0.5)
            
            result = {
                "status": "success",
                "model": model,
                "session_used": current_session,
                "user": user_id,
                "latency_ms": (datetime.now() - start_time).total_seconds() * 1000
            }
            self.history.append(result)
            return result
        except Exception as e:
            return {"error": str(e), "status": 500}
        finally:
            # Remise de la session dans le pool
            async with self.lock:
                self.sessions.append(current_session)

async def run_load_test(simulator: Sub2APICRS2Simulator, num_requests: int):
    tasks = []
    for i in range(num_requests):
        user = f"user_{i % 5}"
        model = "claude-3-5-sonnet" if i % 2 == 0 else "gpt-4o"
        tasks.append(simulator.process_request(model, user))
    
    responses = await asyncio.gather(*tasks)
    for resp in responses:
        print(f"Request Result: {resp}")

if __name__