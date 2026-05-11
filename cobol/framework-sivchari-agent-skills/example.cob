import json
from sivchari import Skill, Tool, Schema

# Configuration du schéma de sortie
response_schema = Schema(
    type="object",
    properties={
        "command": {"type": "string"},
        "success": {"type": "boolean"}
    },
    required=["command", "success"]
)

@Tool(name="execute_jcl")
def execute_jcl(job_name: str) -> str:
    """Simule l'exécution d'un job JCL sur un mainframe."""
    # Logique de simulation
    if "ERROR" in job_name:
        return "JOB ABENDED"
    return "JOB COMPLETED"

# Définition de la Skill
jcl_executor_skill = Skill(
    name="jcl_executor",
    prompt="Convert the user request into a JCL command name and check status.",
    tools=[execute_jcl],
    response_format=response_schema
)

# Exemple de test manuel rapide
def manual_test():
    test_input = {"user_request": "Run the daily cleanup job"}
    try:
        # Simulation d'un appel
        print(f"Testing Skill: {jcl_executor_skill.name}")
        # Dans la réalité, on appellerait l'agent ici
        print("Input:", test_input)
        print("Output (simulated): {"command": "CLEANUP", "success": true}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    manual_test()