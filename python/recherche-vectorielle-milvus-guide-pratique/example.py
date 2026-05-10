import numpy as np
from pymilvus import connections, FieldSchema, CollectionSchema, DataType, Collection
from sentence_transformers import SentenceTransformer
import time

# Script de test de performance pour la recherche vectorielle Milvus

class MilvusBenchmark:
    def __init__(self, dim: int = 384, count: int = 1000):
        self.dim = dim
        self.count = count
        self.model = SentenceTransformer("all-MiniLM-L6-v2")
        self._setup_milvus()

    def _setup_milvus(self):
        connections.connect("default", host="localhost", port="19530")
        fields = [
            FieldSchema(name="pk", dtype=DataType.INT64, is_primary=True, auto_id=True),
            FieldSchema(name="vector", dtype=DataType.FLOAT_VECTOR, dim=self.dim)
        ]
        schema = CollectionSchema(fields, "Benchmark Schema")
        try:
            Collection("benchmark_col", schema).drop()
        except:
            pass
        self.collection = Collection("benchmark_col", schema)

    def run_benchmark(self):
        print(f"Génération de {self://self.count} vecteurs...")
        # Simulation de données
        data = np.random.random((self.count, self.dim)).astype('float32').tolist()
        
        print("Insertion en cours...")
        start_time = time.time()
        self.collection.insert(data)
        self.collection.flush()
        print(f"Insertion terminée en {time.time() - start_time:.2f}s")

        print("Création de l'index HNSW...")
        index_params = {"metric_type": "L2", "params": {"M": 8, "efConstruction": 64}, "index_type": "HNSW"}
        self.collection.create_index("vector", index_params)
        self.collection.load()

        print("Lancement de la recherche...")
        query_vec = np.random.random((1, self.dim)).astype('float32').tolist()
        
        start_time = time.time()
        results = self.collection.search(query_vec, "vector", params={"nprobe": 10}, limit=5)

        duration = time.time() - start_time
        print(f"Recherche terminée en {duration:.4f}s")
        print(f"Résultat trouvé: {len(results[0])} voisins")

if __name__ == "__main__":
    # Nécessite un serveur Milvus actif sur localhost:19530
    try:
        bench = MilvusBenchmark(dim=384, count=500)
        bench.run_benchmark()
    except Exception as e:
        print(f"Erreur: {e}. Vérifiez que Milvus est lancé.")