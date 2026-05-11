import os
import json
import base64
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

# Simulation d'un processus d'extraction complet
class BrowserDataExtractor:
    def __init__(self, local_state_content: str):
        self.local_state = json.loads(local_state_content)
        self.master_key = self._derive_key()

    def _derive_key(self) -> bytes:
        """Simule la dérivation de la clé (enlever la couche DPAPI dans la réalité)"""
        encrypted_key_b64 = self.local_state['os_crypt']['encrypted_key']
        raw_key = base64.b64decode(encrypted_key_b64)
        # On suppose ici que le préfixe est déjà géré
        return raw_key[5:]

    def decrypt_entry(self, encrypted_blob: bytes) -> str:
        """Décrypte une entrée spécifique (cookie ou password)"""
        if not encrypted_blob.startswith(b'v10'):
            return "Format inconnu"
        
        nonce = encrypted_blob[3:15]
        ciphertext = encrypted_blob[15:]
        
        aesgcm = AESGCM(self.master_key)
        try:
            decrypted = aesgcm.decrypt(nonce, ciphertext, None)
            return decrypted.decode('utf-8')
        except Exception as e:
            return f"Erreur de décryptage: {str(e)}"

if __name__ == "__main__":
    # Simulation de données pour le test
    # Dans la réalité, ces données proviennent des fichiers physiques
    mock_local_state = '{"os_crypt": {"encrypted_key": "dmEwR016RXpORFl6TVRFeU16RXpORFl6TVRFeU16RXpORFl6TVRFeU16RXpORFl6TVRFeU16RXpORFl6TVRFeU16RXpORFl6"}}'
    # Note: La clé ci-dessus est un placeholder pour la démonstration
    
    # Création d'un payload chiffré factice pour le test
    fake_master_key = b'0123456789abcdef01234566789abcdef' # 32 bytes
    fake_nonce = os.urandom(12)
    fake_ciphertext = b'secret_data_payload'
    # Construction du blob conforme (v10 + nonce + ciphertext)
    fake_blob = b'v10' + fake_nonce + fake_ciphertext

    # Test de l'extracteur
    # On injecte une clé manuelle pour que l'exemple soit exécutable sans DPAPI
    extractor = BrowserDataExtractor(mock_local_state)
    # Forcer la clé pour le test
    extractor.master_key = fake_master_key
    
    result = extractor.decrypt_entry(fake_blob)
    print(f"Résultat de l'extraction : {result}")