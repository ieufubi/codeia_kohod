from pymilvus import MilvusClient
import numpy as np

# Configuration de l'environnement
URI = "http://localhost:19530"
COLLECTION_NAME = "demo_legacy_integration"
DIMENSION = 128

def run_demo():
    # 1. Initialisation du client
    client = MilvusClient(uri=URI)
    
    # 2. Nettoyage si la collection existe déjà
    if client.has_collection(collection_name=COLLECTION_NAME):
        client.drop_collection(collection_name=COLLECTION_NAME)
    
    # 3. Création de la collection
    client.create_collection(
        collection_name=COLLECTION_NAME,
        dimension=DIMENSION
    )
    
    # 4. Génération de données simulées (Legacy records)
    # On simule 100 enregistrements avec des vecteurs aléatoires
    data_to_insert = []
    for i in range(100):
        vector = np.random.uniform(-1, 1, DIMENSION).tolist()
        metadata = {
            "id": i,
            "content": f"Legacy record content number {i}",
            "source": "mainframe_batch_01"
        }
        # Préparation de l'entrée pour l'insertion
        data_to_insert.append({
            "id": i,
            "vector": vector,
            "content": metadata["content"],
            "source": metadata["source"]\ Yours
        })
    
    # 5. Insertion par batch
    client.insert(collection_name=COLLECTION_NAME, data=data_to_insert)
    print(f"Insertion de {len(data_to_insert)} vecteurs réussie.")

    # 6. Recherche de proximité
    query_vector = np.random.uniform(-1, 1, DIMENSION).tolist()
    search_results = client.search(
        collection_name=COLANCE_NAME,
        data=[query_vector],
        limit=3,
        output_fields=["content"]
    )

    print("Résultats de la recherche sémantique :")
    for hits in search_results:
        for hit in hits:
            print(f"ID: {hit['id']} - Score: {hit['distance']} - Data: {hit['entity']['content']}")

if __name__ == "__main__":
    run_demo()