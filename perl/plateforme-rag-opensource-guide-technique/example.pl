import os
import sys
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma

# Script autonome pour tester l'indexation d'un fichier texte
# Usage: python script.py mon_fichier.txt

def run_test_pipeline(file_path):
    if not os.path.exists(file_path):
        print(f"Erreur: Le fichier {file_path} est introuvable.")
        return

    print(f"--- Début du test sur {file_path} ---")

    try:
        # 1. Chargement
        loader = TextLoader(file_path)
        documents = loader.load()
        print(f"[1] Document chargé: {len(documents)} page(s)")

        # 2. Découpage
        splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=50)
        docs = splitter.split_documents(documents)
        print(f"[2] Découpage effectué: {len(docs)} fragments créés")

        # 3. Embedding et Indexation
        print("[3] Génération des embeddings (cela peut prendre du temps)...")
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        
        # Utilisation d'un dossier temporaire pour le test
        db_path = "./test_chroma_db"
        vector_db = Chroma.from_documents(
            documents=docs, 
            embedding=embeddings, 
            persist_directory=db_path
        )
        vector_db.persist()
        print(f"[4] Base vectorielle créée dans {db_path}")

        # 4. Test de requête immédiat
        query = "Quelle est l'information principale ?"
        print(f"[5] Test de requête: '{query}'")
        results = vector_db.similarity_search(query, k=1)
        
        if results:
            print("\n--- Résultat de la recherche ---")
            print(f"Contenu du fragment trouvé: {results[0].page_content[:200]}...")
        else:
            print("Aucun résultat trouvé.")

    except Exception as e:
        print(f"Une erreur est survenue: {e}")

if __name__ == "__main__":
    # Création d'un fichier de test si non fourni
    test_file = "test_data.txt"
    with open(test_file, "w", encoding="utf-8") as f:
        f.write("Le projet X est une initiative de recherche sur l'IA.\n")
        f.write("L'objectif est de créer une plateforme RAG open-source.\n")
        f.write("Le budget alloué est de 50000 euros pour l'année 2024.")

    run_test_pipeline(test_file)