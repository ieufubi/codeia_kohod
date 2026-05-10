import os
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Configuration du pipeline RAG avec LLM
def run_simple_rag(file_path: str, query: str):
    # 1. Chargement du document texte
    if not os.path.exists(file_path):
        print(f"Erreur: Le fichier {file_path} est introuvable.")
        return

    loader = TextLoader(file_path, encoding='utf-8')
    documents = loader.load()

    # 2. Découpage intelligent (Chunking)
    # On définit une taille de 500 caractères avec 50 de recouvrement
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    chunks = text_splitter.split_documents(documents)
    print(f"Nombre de morceaux créés: {len(chunks)}")

    # 3. Initialisation des Embeddings (Modèle léger pour CPU)
    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

    # 4. Création de la base de données vectorielle en mémoire
    vectorstore = Chroma.from_documents(chunks, embeddings)

    # 5. Recherche de similarité
    # On cherche les 2 morceaux les plus proches de la requête
    results = vectorstore.similarity_search(query, k=2)

    print(f"\nQuestion: {query}")
    print("--- Réponses trouvées ---")
    for i, res in enumerate(results):
        print(f"Résultat {i+1}: {res.page_content[:100]}...")

if __name__ == "__main__":
    # Création d'un fichier de test
    test_file = "data.txt"
    with open(test_file, "w", encoding='utf-8') as f:
        f.write("Le projet X utilise le protocole MQTT version 3.1.3.\n")
        f.write("Le serveur de production est situé à Paris.\n")
        f.write("La sécurité est assurée par un certificat TLS 1.3.")

    # Exécution du test
    run_simple_rag(test_file, "Quel protocole est utilisé pour le projet X ?")