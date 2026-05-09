import asyncio
import hashlib
import time
from pydantic import BaseModel, Field
from typing import List

class ModelArtifact(BaseModel):
    name: str
    version: str
    checksum: str

class FsnotifyHub:
    def __init__(self):
        self.registry: List[ModelArtifact] = []

    async def register_model(self, name: str, version: str, file_path: str):
        """Enregistre un modèle après vérification du hash."""
        print(f"--- Traitement de {name} ---")
        
        # Simulation calcul de hash (en réalité, on lirait le fichier)
        sha256_hash = hashlib.sha256(name.encode()).hexdigest()
        
        new_artifact = ModelArtifact(
            name=name,
            version=version,
            checksum=sha256_hash
        )
        self.registry.append(new_artifact)
        print(f"Modèle {name} (v{version}) enregistré avec succès.")
        return new_artifact

    async def distribute(self, artifact: ModelArtifact, nodes: List[str]):
        """Simule la distribution vers des nœuds distants."""
        tasks = [self._send_to_node(node, artifact) for node in nodes]
        await asyncio.gather(*tasks)

    async def _send_to_node(self, node: str, artifact: ModelArtifact):
        """Simulation d'un transfert réseau."""
        print(f"[Envoi] Vers {node} : {artifact.name} (v{artifact.version})...")
        await asyncio cling_delay(1) # Simulation latence
        print(f"[OK] {node} a reçu l'artefact.")

async def cling_delay(seconds: int):
    await asyncio.sleep(seconds)

async def main():
    hub = FsnotifyHub()
    nodes = ["edge-1", "edge-2", "cloud-core"]

    # Scénario 1: Enregistrement d'un modèle
    artifact = await hub.register_model("resnet-50", "1.2.0", "path/to/model.bin")

    # Scénario 2: Distribution
    print("Début de la phase de distribution")
    start_time = time.perf_counter()
    await hub.distribute(artifact, nodes)
    end_time = time.perf_counter()

    print(f"\nDistribution terminée en {end_time - start_time:.2f} secondes.")

if __name__ == "__main__":
    asyncio.run(main())