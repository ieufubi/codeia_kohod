import json
import random

class MockSivchari:
    """Simulation simplifiée du framework pour démonstration"""
    def __init__(self, model_name):
        self.model_name = model_name
        self.results = []

    def run_test(self, skill_name, input_data, expected_output):
        # Simulation d'un appel LLM avec une part d'incertitude
        print(f"Testing {skill_name} with input: {input_data}")
        
        # Simulation d'une réponse LLM qui peut être correcte ou non
        success_rate = 0.8
        if random.random() < success_rate:
            actual_output = expected_output
            status = "PASS"
        else:
            # Simulation d'une erreur de format (le fameux bug de production)
            actual_output = "Here is your result: " + json.dumps(expected_output)
            status = "FAIL (Format Error)"

        self.results.append({
            "input": input_data,
            "expected": expected_output,
            "actual": actual_output,
            "status": status
        })
        return status

    def report(self):
        print("\n--- Test Report ---")
        passed = 0
        for r in self.results:
            print(f"[{r['status']}] Input: {r['input']} | Output: {r['actual']}")
            if "FAIL" not in r['status']:
                passed += 1
        
        accuracy = (passed / len(self.results)) * 100
        print(f"\nTotal Accuracy: {accuracy}%")

# Scénario de test de la gestion des compétences agents
def main():
    # Initialisation du moteur de test
    tester = MockSivchari(model_name="gpt-4o")
    
    # Définition des cas de test
    test_cases = [
        {"input": "search:config", "expected": {"file": "config.json"}},
        {"input": "search:readme", "expected": {"file": "README.md"}},
        {"input": "search:setup", "expected": {"file": "setup.py"}}
    ]

    # Exécution de la suite de tests
    for case in test_cases:
        tester.run_test(
            skill_name="file_search",
            input_data=case["input"],
            expected_output=case["expected"]
        )

    # Affichage du rapport final
    tester.report()

if __name__ == "__main__":
    main()