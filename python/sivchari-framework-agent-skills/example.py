import asyncio
from typing import Dict, Any
from pydantic import BaseModel

# Simulation d'un framework simplifié pour démonstration
class SkillContract(BaseModel):
    input_val: int
    expected: int

class MockSkill:
    async def execute(self, data: Dict[str, Any]) -> int:
        # Simulation d'un calcul asynchrone
        await asyncio.sleep(0.01)
        return data.get("value", 0) * 2

async def run_demo():
    skill = MockSkill()
    test_cases = [
        SkillContract(input_val=10, expected=20),
        SkillContract(input_val=5, expected=10),
        SkillContract(input_val=0, expected=0)
    ]
    
    print(f"--- Début de l'évaluation sivchari pour agents ---")
    for case in test_cases:
        payload = {"value": case.input_val}
        try:
            result = await skill.execute(payload)
            status = "OK" if result == case.expected else "FAIL"
            print(f"Input: {case.input_val} | Expected: {case.expected} | Got: {result} | [{status}]")
        except Exception as e:
            print(f"Erreur: {e}")
    print("--- Fin de l'évaluation ---")

if __name__ == "__main__":
    asyncio.run(run_demo())