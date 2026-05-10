import os
from typing import List
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma

# Simulation d'un fichier de connaissance
KNOWLEDGE_FILE = "knowledge.txt"

def setup_dummy_data():
    """Crée un fichier de texte pour le test."""
    with open(KNOWLEDGE_FILE, "w", encoding="utf-8") as f:
        f.write("Le projet Alpha est lancé en 2024.\n")
        f.write("Le budget alloué est de 500 000 euros.\n")
        f.write("Le responsable technique est Jean Dupont.")

class SimpleRAG:
    def __init__(self, storage_path: str = "./chroma_db"):
        self.storage_path = storage_path
        # Modèle léger pour exécution CPU
        self.embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        self.vectorstore = None

    def build_index(self, file_path: str):
        """Charge, découpe et indexe le document."""
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Fichier {file_path} introuvable.")

        loader = TextLoader(file_path, encoding="utf-8")
        docs = loader.load()
        
        splitter = RecursiveCharacterText_Splitter(chunk_size=100, chunk_overlap=20)
        chunks = splitter.split_documents(docs)
        
        self.vectorstore = Chroma.from_documents(
            documents=chunks, 
            embedding=self.embeddings,
            persist_directory=self.storage_path
        )
        print(f"Index créé avec {len(chunks)} segments.")

    def query(self, question: str) -> List[str]:
        """Recherche les segments les plus proches."""
        if not self.vectorstore:
            raise RuntimeError("L'index n'est pas initialisé.")
        
        results = self.vectorstore.similarity_search(question, k=1)
        return [r.page_content for r in results]

if __name__ == "__main__":
    # Nettoyage préalable
    if os.path.exists("./chroma_db"):
        import shutil
        shutil.rmtree("./chroma_db")

    setup_dummy_data()
    
    rag = SimpleRAG()
    rag.build_index(KNOWLEDGE_FILE)
    
    user_query = "Qui est le responsable technique ?"
    answer = rag.query(user_query)
    
    print(f"Question: {user_query}")
    print(f"Réponse trouvée dans l'index: {answer[0] if answer else 'Aucune réponse.'}")