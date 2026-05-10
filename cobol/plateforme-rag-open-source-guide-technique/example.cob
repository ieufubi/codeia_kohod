import os
import json

# Script de simulation de pipeline complet
# Ce script simule l'ingestion de données préparées par COBOL vers une base vectorielle

class SimpleRAGSimulator:
    def __init__(self):
        self.vector_store = []
        self.index = []

    def ingest_json(self, file_path):
        # Simulation de chargement de données structurées
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                # On simule ici l'ajout de vecteurs (en réalité, c'est du calcul mathématique)
                for entry in data:
                    self.vector_store.append({
                        'id': entry['id'],
                        'content': entry['text']
                    })
            print(f"Ingestion réussie : {len(self.vector_store)} documents indexés.")
        except Exception as e:
            print(f"Erreur lors de l'ingestion : {e}")

    def query(self, question_text):
        # Simulation de recherche par mot-clé (fallback simple)
        print(f"Recherche pour : '{question_text}'")
        results = []
        for doc in self.vector_store:
            if any(word.lower() in doc['content'].lower() for word in question_text.split()):
                results.append(doc['content'])
        return results

if __name__ == "__main__":
    # Création d'un fichier de test simulé (comme produit par le COBOL)
    test_data = [
        {"id": "001", "text": "La procédure de clôture nécessite la validation du superviseur."},
        {"id": "002", "text": "Le serveur de production est situé dans le datacenter A."},
        {"id": "003", "text": "Les sauvegardres sont effectuées chaque nuit à 02:00."}
    ]
    
    with open('test_input.json', 'w') as f:
        json.dump(test_data, f)

    # Exécution du simulateur
    rag = SimpleRAG_Simulator()
    rag.ingest_json('test_input.json')
    
    # Test de la recherche
    matches = rag.query("Quand sont les sauvegardes ?")
    for match in matches:
        print(f"Résultat trouvé : {match}")

    # Nettoyage
    os.remove('test_input.json')