import asyncio
import json
from typing import Dict, Any

class MockDatabaseTool:
    """Simulation d'un outil de base de données pour le MCP Toolbox for Databases"""
    def __init__(self):
        self.data = {"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]}

    async def execute_sql(self, sql: str) -> str:
        """Simule l'exécution d'une requête SQL avec un délai asynchrone"""
        await asyncio.sleep(0.5)  # Simulation latence réseau
        if "SELECT" in sql.upper():
            return json.dumps(self.data["users"], indent=2)
        return "Error: Only SELECT is allowed"

async def mcp_server_loop():
    """Boucle principale simulant le serveur MCP"""
    db_tool = MockDatabaseTool()
    print("--- Serveur MCP simulé démarré (stdin/stdout) ---", file=sys.stderr)
    
    # Simulation de réception de messages JSON-RPC
    incoming_messages = [
        {"jsonrpc": "2.0", "method": "call_tool", "params": {"sql": "SELECT * FROM users"}, "id": 1},
        {"jsonrpc": "2.0", "method": "call_tool", "params": {"sql": "DROP TABLE users"}, "id": 2}
    ]

    for msg in incoming_messages:
        print(f"[RECU] {msg['method']} ID:{msg['id']}", file=sys.stderr)
        
        if msg["method"] == "call_tool":
            sql_query = msg["params"]["sql"]
            try:
                result = await db_tool.execute_sql(sql_query)
                response = {"jsonrpc": "2.0", "result": result, "id": msg["id"]}
            except Exception as e:
                response = {"jsonrpc": "2.0", "error": str(e), "id": msg["id"]}
            
            # Envoi de la réponse sur stdout (le canal de retour du client)
            print(json.dumps(response))

if __name__ == "__main__":
    import sys
    try:
        asyncio.run(mcp_server_loop())
    except KeyboardInterrupt:
        pass