import json
import base64
import sqlite3
from pathlib import Path
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

# Ce script simule l'extraction de données pour un test unitaire
# Il ne nécessite pas de vrai profil Chrome pour fonctionner (mocking)

def mock_extraction_logic(local_state_json: str, cookies_db_path: Path):
    """Simulation d'un moteur d'extraction complet."""
    try:
        # 1. Chargement de la configuration
        ls_data = json.loads(local_state_json)
        encrypted_key_b64 = ls_data['os_crypt']['encrypted_key']
        encrypted_key = base64.b64decode(encrypted_key_b64)
        
        # 2. Simulation du déchiffrement de la clé (on suppose la clé déjà déchiffrée)
        # Dans la réalité, on utiliserait DPAPI ou Keychain ici
        master_key = encrypted_key[5:] # On simule le retrait du préfixe
        
        decryptor = BrowserDecryptor(Path("dummy"))
        decryptor.load_master_key(master_key)
        
        print(f"[+] Clé maîtresse chargée: {master_key.hex()[:10]}...")

        # 3. Lecture de la base de données (mock)
        if not cookies_db_path.exists():
            print("[-] Erreur: Base de données introuvable.")
            return

        results = decryptor.extract_sqlite_data(cookies_db_path, "SELECT name, encrypted_value FROM cookies")
        
        for row in results:
            val = row['encrypted_value']
            try:
                decrypted_val = decryptor.decrypt_payload(val)
                print(f"[OK] Cookie: {row['name']} -> {decrypted_val.decode('utf-8')}")
            except Exception as e:
                print(f"[!] Échec décryptage pour {row['name']}: {e}")

    except KeyError as e:
        print(f"[!] Erreur structurelle dans le fichier Local State: {e}")
    except Exception as e:
        print(f"[!] Erreur inattendue: {e}")

class BrowserDecryptor:
    def __init__(self, local_state_path: Path):
        self.local_state_path = local_state_path
        self.master_key: bytes | None = None

    def load_master_key(self, decrypted_key: bytes) -> None:
        self.master_key = decrypted_key

    def decrypt_payload(self, encrypted_blob: bytes) -> bytes:
        if not self.master_key: raise ValueError("No key")
        if not encrypted_blob.startswith(b'v10'): return encrypted_blob
        nonce = encrypted_blob[3:15]
        ciphertext = encrypted_blob[15:]
        aesgcm = AESGCM(self.master_key)
        return aesgcm.decrypt(nonce, ciphertext, None)

    def extract_sqlite_data(self, db_path: Path, query: str) -> list[dict]:
        with sqlite3.connect(db_path) as conn:
            conn.row_factory = sqlite3.Row
            return [dict(r) for r in conn.execute(query).fetchall()]

if __name__ == "__main__":
    # Création d'un environnement de test
    test_dir = Path("test_env")
    test_dir.mkdir(exist_ok=True)
    db_file = test_dir / "test_cookies.db"
    
    # Création d'une base SQLite factice
    with sqlite3.connect(db_file) as conn:
        conn.execute("CREATE TABLE cookies (name TEXT, encrypted_value BLOB)")
        # On simule un payload chiffré (v10 + nonce + ciphertext + tag)
        # Pour l'exemple, on utilise une clé simple
        fake_key = b"0123456789abcdef0123456789abcdef" # 32 bytes
        aesgcm = AESGCM(fake_key)
        nonce = b"123456789012" # 12 bytes
        ct = aesgcm.encrypt(nonce, b"secret_session_value", None)
        payload = b"v10" + nonce + ct
        conn.execute("INSERT INTO cookies VALUES (?, ?)", ("session_token", payload))

    # Mock du fichier Local State
    # On encode la clé avec le préfixe 'dpapi:' (simulé)
    mock_ls = {
        "os_crypt": {
            "encrypted_key": base64.b64encode(b"dpapi:" + fake_key).decode()
        }
    }
    
    mock_extraction_logic(json.dumps(mock_ls), db_file)"
}