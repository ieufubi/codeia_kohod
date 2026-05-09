import base64
import time
from typing import List, Dict

class DNSTunnelSimulator:
    """Simulateur de tunneling DNS avancé avec gestion de séquence."""
    
    def __init__(self, domain: str):
        self.domain = domain
        self.buffer: Dict[int, bytes] = {}
        self.expected_seq = 0

    def fragment_data(self, data: bytes) -> List[str]:
        """Fragmente les données en segments DNS valides."""
        encoded = base64.b32encode(data).decode().strip("=").lower()
        fragments = []
        for i in range(0, len(encoded), 50):\  # 50 chars pour la sécurité
            seq = self.expected_seq
            segment = encoded[i:i+50]
            fragments.append(f"{seq}.{segment}.{self.domain}")
            self.expected_seq += 1
        return fragments

    def receive_fragment(self, fragment: str) -> None:
        """Simule la réception et le réassemblage d'un fragment."""
        parts = fragment.split('.')
        if len(parts) < 3: 
            return
        
        seq = int(parts[0])
        payload = parts[1]
        self.buffer[seq] = payload.encode()
        print(f"[RECV] Fragment {seq} reçu.")

    def reconstruct(self) -> bytes:
        """Réassemble les fragments stockés dans le buffer."""
        sorted_keys = sorted(self.buffer.keys())
        full_encoded = "".join([self.buffer[k].decode() for k in sorted_keys])
        
        # Ajout du padding nécessaire pour le Base32
        padding = len(full_encoded) % 8
        if padding > 0:
            full_encoded += "=" * (8 - padding)
            
        return base64.b32decode(full_encoded, casefold=True)

if __name__ == "__main__":
    # Test du simulateur
    simulator = DNSTunnelSimulator("example.com")
    original_message = b"Tunneling DNS is a complex but useful technique for bypass."
    
    print(f"Message original: {original_message.decode()}")
    
    # Phase d'envoi
    fragments = simulator.fragment_data(original_message)
    print(f"Nombre de fragments générés: {len(fragments)}")
    
    # Phase de réception (simulation)
    for frag in fragments:
        simulator.receive_fragment(frag)
        
    # Reconstruction
    try:
        reconstructed = simulator.reconstruct()
        print(f"Message reconstruit: {reconstructed.decode()}")
        assert reconstructed == original_message
        print("Succès : Intégrité du message préservée.")
    except Exception as e:
        print(f"Erreur de reconstruction: {e}")