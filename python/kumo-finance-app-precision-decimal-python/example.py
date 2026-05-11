import decimal
from decimal import Decimal
from dataclasses import dataclass
from typing import List

@dataclass(frozen=True)
class FinanceEntry:
    label: str
    value: Decimal

class FinanceTracker:
    def __init__(self) -> None:
        self.entries: List[FinanceEntry] = []

    def add_entry(self, label: str, value_str: str) -> None:
        """Ajoute une entrée en convertissant la chaîne en Decimal."""
        # Nettoyage basique pour l'exemple
        clean_val = value_str.replace("$", "").strip()
        try:
            val = Decimal(clean_str := clean_val)
            self.entries.append(FinanceEntry(label, val))
        except decimal.InvalidOperation:
            print(f"Erreur : Format invalide pour {label}")

    def get_balance(self) -> Decimal:
        """Calcule le solde total avec précision."""
        return sum((e.value for e in self.entries), Decimal("0.00"))

if __name__ == "__main__":
    # Simulation d'un usage réel
    tracker = FinanceTracker()
    tracker.add_entry("Salaire", "2500.50")
    tracker.add_entry("Loyer", "-850.00")
    tracker.add_entry("Courses", "-120.75")
    
    # Test de l'erreur de précision classique
    # En float, 0.1 + 0.2 != 0.3
    # Ici, avec Decimal, la précision est maintenue
    tracker.add_entry("Petit bonus", "0.1")
    tracker.add_entry("Autre micro-montant", "0.2")
    
    print(f"Solde final calculé : {tracker.get_balance()}")
    # Résultat attendu : 1630.15 (si on suit la logique des entrées)
    # Vérification de la précision exacte
    expected = Decimal("2500.50") + Decimal("-850.00") + Decimal("-120.75") + Decimal("0.1") + Decimal("0.2")
    print(f"Vérification précision : {tracker.get_balance() == expected}")