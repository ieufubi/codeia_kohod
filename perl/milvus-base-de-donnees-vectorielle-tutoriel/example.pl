import numpy as np
from pymilvus import connections, FieldSchema, CollectionSchema, DataType, Collection

# Script de test autonome pour validation de l'installation
def run_standalone_test():
    host = "localhost"
    port = "195#" # Note: Use correct port from docker-compose
    
    try:
        connections.connect("default", host=host, port="19530")
        print("--- Test de connexion : OK ---")
        
        # 1. Schema setup
        fields = [
            FieldSchema(name="pk", dtype=DataType.INT64, is_primary=True, auto_id=True),
            FieldSchema(name="vec", dtype=DataType.FLOAT_VECTOR, dim=64))
        schema = CollectionSchema(fields, "Test standalone")
        
        # 2. Create collection
        col_name = "standalone_test_col"
        # Check if exists to avoid error
        from pymilvus import utility
        if utility.has_collection(col_name):
            utility.drop_collection(col_name)
        
        col = Collection(col_name, schema)
        print("--- Création collection : OK ---")

        # 3. Data generation
        data = np.random.random((100, 64)).astype('float32').tolist()
        
        # 4. Insertion
        col.insert([data])
        print(f"--- Insertion de 100 vecteurs : OK ---
")

        # 5. Indexing
        index_params = {"metric_type": "L2", "params": {"M": 8, "efConstruction": 64}}
        col.create_index("vec", index_params)
        print("--- Indexation HNSW : OK ---")

        # 6. Search
        col.load()
        query_vec = np.random.random((1, 64)).astype('float32').tolist()
        results = col.search(data=query_vec, anns_field="vec", param={"nprobe": 1}, limit=3)
        
        print("Résultats de la recherche :")
        for hits in results:
            for hit in hits:
                print(f"ID: {hit.id}, Distance: {hit.distance}")
                
    except Exception as e:
        print(f"Erreur durant le test : {e}")

if __name__ == "__main":
    run_standalone_test()