import re
import math
from typing import List, Tuple

class SecretScanner:
    """
    Scanner minimaliste pour illustrer le concept de détection par pattern.
    Implémente une recherche de pattern et une vérification d'entropie.
    """
    def __init__(self, patterns: dict[str, str]):
        self.patterns = {name: re.compile(regex) for name, regex in patterns.items()}

    def calculate_entropy(self, text: str) -> float:
        if not text:
            return 0.0
        probs = [count / len(text) for count in Counter(text).values()]
        return -sum(p * math.log2(p) for p in probs)

    def scan_line(self, line: str, line_no: int) -> List[Tuple[int, str, str]]:
        findings = []
        for name, regex in self.patterns.items():
            match = regex.search(line)
            if match:
                # On vérifie si le contenu trouvé a une entropie élevée
                # pour limiter les faux positifs (ex: variable nommage standard)
                content = match.group(0)
                entropy = self.calculate_entropy(content)
                
                if entropy > 3.0:
                    findings.append((line_no, name, content))
        return findings

from collections import Counter

def main():
    # Configuration des patterns (simulant un fichier .gitleaks.toml)
    rules = {
        "AWS_KEY": "AKIA[A-Z0-9]{16}",
        "GENERIC_TOKEN": "token-[a-z0-9]{32}"
    }
    
    scanner = SecretScanner(rules)
    
    # Simulation d'un fichier source
    source_code = [
        "import os",
        "# Configuration de l'API",
        "AWS_ACCESS_KEY = 'AKIA_REDACTED_NOT_A_KEY'",  # Détection attendue
        "APP_TOKEN = 'token-1234567890abcdef1234567890abcdef'",  # Détection attendue
        "DEBUG_MODE = True",
        "USER_NAME = 'admin_user'"  # Ne doit pas être détecté (entropie faible)
    ]
    
    print("Démarrage du scan de sécurité...\n")
    for idx, line in enumerate(source_code, 1):
        results = scanner.scan_line(line, idx)
        for line_no, rule_name, value in results:
            print(f"[ALERTE] Ligne {line_no}: {rule_name} détecté -> {value}")

if __name__ == "__main__":
    main