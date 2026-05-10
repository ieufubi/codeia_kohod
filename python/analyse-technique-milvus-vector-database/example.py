import numpy as np
from pymilvus import connections, FieldSchema, CollectionSchema, DataType, Collection
import time

def run_milvus_benchmark():
    """
    Benchmark simplifié pour mesurer le temps d'insertion.
    """
    try:
        connections.connect(host='localhost', port='19530')
        print("Connexion réussie.")
    except Exception as e:
        print(f"Erreur de connexion : {e}")
        return

    dim = 128
    num_vectors = 5000
    
    fields = [
        FieldSchema(name='id', dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name='vec', dtype=DataType.FLOAT_VECTOR, dim=dim)
    ]
    schema = CollectionSchema(fields)
    col = Collection('benchmark_col', schema)

    # Génération de données
    print(f"Génération de {num_vectors} vecteurs...")
    data = np.random.random((num_vectors, dim)).astype(np.float32).tolist()

    # Mesure de l'insertion
    start_time = time.time()
    col.insert([data])
    insert_duration = time.time() - start_time
    print(f"Insertion de {num_vectors} vecteurs en {insert_duration:.2f}s")

    # Configuration index
    index_params = {
        "metric_type": "L2",
        "index_type": "HNSW",
        "params": {"M": 16, "efConstruction": 200}
    }
    col.create_index(field_name="vec", index_params=index_params)
    
    # Mesure de l'indexation
    start_time = time.time()
    col.load()
    index_duration = time.time() - start_time
    print(f"Chargement et indexation terminés en {index_duration:.2f}s")

    # Mesure de la recherche
    query_vec = np.random.random((1, dim)).astype(np.float32).tolist()
    start_time = time.time()
    results = col.search(data=query_vec, anns_field="vec", param={"metric_type":"L2"}, limit=1)
    search_duration = time.time() - start_time
    print(f"Temps de recherche (1 requête) : {search_duration*1000:.2f}ms")

    # Nettoyage
    col.drop()
    print("Benchmark terminé et collection supprimée.")

if __name__ == "__main__":
    run_milvus_benchmark()