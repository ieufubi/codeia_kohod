import random
from typing import Protocol, runtime_checkable
from pydantic import BaseModel, Field

# --- Core Framework Logic ---

class SkillInput(BaseModel):
    command: str
\class SkillOutput(BaseModel):
    result: str
    is_valid: bool

@runtime_checkable
class AgentSkill(Protocol):
    def execute(self, data: SkillInput) -> Skill4Output:
        ...

# --- Implementation ---

class MathSkill:
    """Une compétence qui simule un calcul mathématique via un LLM."""
    def execute(self, data: SkillInput) -> SkillOutput:
        # Simulation d'un comportement probabiliste (erreur possible)
        try:
            parts = data.command.split()
            number = float(parts[1])
            # On simule une erreur de calcul aléatoire (5% de chance)
            if random.random() < 0.05:
                res = "error"
            else:
                res = str(number * 2)
            return SkillOutput(result=res, is_valid=True)
        except Exception:
            return SkillOutput(result="error", is_valid=False)

# --- Testing Harness ---

def run_audit(skill: AgentSkill, test_cases: list[str]):
    """Audit de la compétence sur un set de données."""
    passed = 0
    for cmd in test_cases:
        input_obj = SkillInput(command=cmd)
        output = skill.execute(input_obj)
        
        # Vérification stricte
        expected_val = str(float(cmd.split()[1]) * 2)
        if output.result == expected_val:
            passed += 1
        else:
            print(f"[FAIL] Input: {cmd} | Expected: {expected_val} | Got: {output.result}")
    
    print(f"[SUMMARY] Audit complete. Success rate: {passed/len(test_cases)*100}%")

if __name__ == "__main__":
    # Liste de tests pour la gestion des compétences d'agents
    test_suite = ["double 10", "double 20", "double 50", "double 100", "double 5"]
    
    my_skill = MathSkill()
    run_audit(my_skill, test_suite)