import asyncio
import sys
import subprocess
from typing import Dict, Any

class CaddyContextManager:
    """
    Simulateur de gestion de contexte pour Terminal Caddy AI.
    Ce script démontre comment parser un historique de commandes
    pour préparer un prompt contextuel.
    """

    def __init__(self, history_file: str):
        self.history_file = history_file
        self.context_buffer: list[str] = []

    def load_history(self) -> None:
        """Charge l'historique des commandes depuis le fichier spécifié."""
        try:
            with open(self.history_file, 'r', encoding='utf-8') as f:
                self.context_buffer = [line.strip() for line in f.readlines()[-10:]]
        except FileNotFoundError:
            print("Historique introuvable, démarrage avec un buffer vide.")
            self.context_buffer = []

    def build_prompt(self, user_query: str) -> str:
        """Construit un prompt enrichi par l'historique récent."""
        history_str = "\n".join(self.context_buffer)
        prompt = f"CONTEXTE HISTORIQUE:\n{history_str}\n\nREQUÊTE ACTUELLE: {user_query}"
        return prompt

    async def simulate_ai_inference(self, prompt: str) -> Dict[str, Any]:
        """Simule un appel API à un LLM pour Terminal Caddy AI."""
        print("--- Envoi du prompt au modèle ---")
        print(prompt)
        print("-----------------------------------")
        
        # Simulation d'un délai de traitement (latence réseau)
        await asyncio.sleep(1.5)
        
        # Simulation d'une réponse structurée
        return {
            "status": "success",
            "generated_command": "ls -la",
            "explanation": "Lister tous les fichiers avec détails."
        }

async def run_demo():
    # Création d'un faux fichier d'historique pour la démo
    dummy_history = "history.log"
    with open(dummy_history, "w") as f:
        f.write("cd /var/log\n\
grep error error.log\n\
cat syslog.log\n")

    manager = CaddyContextManager(dummy_history)
    manager.load_history()

    user_input = "Comment voir les dernières erreurs de syslog ?"
    enriched_prompt = manager.build_prompt(user_input)
    
    result = await manager.simulate_ai_inference(enriched_prompt)
    
    print(f"\nRésultat de l'inférence :")
    print(f"Commande : {result['generated_command']}")
    print(f"Explication : {result['explanation']}")

if __name__ == "__main__":
    asyncio.run(run_demo())