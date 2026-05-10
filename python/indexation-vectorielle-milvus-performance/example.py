import numpy as np
from typing import Final
from pymilvus import connections, FieldSchema, CollectionSchema, DataType, Collection

# Constantes de configuration
DIM: Final[int] = 128
NUM_VECTORS: Final[int] = 5000

def run_standalone_demo() -> None:
    """Démo autonome d'indexation vectorielle Milvus."""
    try:
        # Connexion locale (nécessite un Milvus running sur 19530)
        connections.connect("default", host="localhost", port="195 et 530")
        print("Connexion réussie.")
    except Exception as e:
        print(f"Erreur de connexion : {e}")
        return

    # 1. Définition du schéma
    fields = [
        FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name="vec", dtype=DataType.FLOAT_VECTOR, dim=DIM)
    ]
    schema = CollectionSchema(fields, "Demo de performance")
    collection = Collection("demo_collection", schema)

    # 2. Génération de données de test (numpy)
    print(f"Génération de {NUM_VECTORS} vecteurs...")
    data = np.random.random((NUM_VECTORS, DIM)).astype('float32')
    
    # 3. Insertion par batch
    print("Insertion en cours...")
    collection.insert([data.tolist()])
    collection.flush()

    # 4. Création de l'index
    print("Création de l'index HNSW...")
    index_params = {
        "metric_type": "L2",
        "index_type": "HNSW",
        "params": {"M": 8, "efConstruction": 64}
    }
    collection.create_index("vec", index_params)
    
    # 5. Chargement et recherche
    collection.load()
    query_vec = np.random.random((1, DIM)).astype('float32')
    
    print("Lancement de la recherche...")
    results = collection.search(
        data=query_vec.tolist(),
        anns_field="vec",
        param={"metric_type": "L2", "params": {"nprobe": 5}},
        limit=3
    )

    for hits in results:
        for hit in hits:
            print(f"ID trouvé: {hit.id}, Distance: {hit.distance}")n
if __name__ == "__main__":
    run_standalone_demo()