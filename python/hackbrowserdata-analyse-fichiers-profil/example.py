import sqlite3
import pathlib
import shutil
import os
from tempfile import NamedTemporaryFile

class BrowserDataCleaner:
    """
    Classe pour gérer le nettoyage sécurisé des profils de navigateur.
    Conforme aux principes de l'encapsulation et de la robustesse.
    """
    def __init__(self, profile_path: str):
        self.profile_path = pathlib.Path(profile_path)
        self.cookies_db = self.profile_path / "Cookies"

    def clean_expired_cookies(self) -> int:
        """Supprime les cookies expirés via une copie temporaire."""
        if not self.cookies_db.exists():
            return 0

        with NamedTemporaryFile(delete=False) as tmp:
            tmp_path = tmp.name
            shutil.copy2(self.cookies_db, tmp_path)

        deleted = 0
        try:
            conn = sqlite3.connect(tmp_path)
            cursor = conn.cursor()
            
            # On compte les cookies qui ont une date d'expiration passée
            # Note: La structure exacte dépend de la version de Chromium
            cursor.execute("SELECT COUNT(*) FROM cookies WHERE expires < strftime('%s', 'now')")
            deleted = cursor.fetchone()[0]
            
            conn.commit()
            conn.close()
            
            # Note: Dans un vrai outil, on réinjecterait la base propre
            # Ici, on simule la logique de nettoyage
            print(f"[INFO] {deleted} cookies identifiés comme expirés.")
            
        except sqlite3.Error as e:
            print(f"[ERROR] Erreur SQLite: {e}")
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
        
        return deleted

if __name__ == "__main__":
    # Simulation d'un chemin de profil
    # Dans un usage réel, utilisez : os.path.expanduser('~/.config/google-chrome/Default')
    fake_profile = pathlib.Path(".")
    fake_cookies = fake_profile / "Cookies"
    
    # Création d'une base de test
    with sqlite3.connect(fake_cookies) as conn:
        conn.execute("CREATE TABLE IF NOT EXISTS cookies (name TEXT, expires REAL)")
        conn.execute("INSERT INTO cookies VALUES ('session_id', 1000)") # Expire en 1970
        conn.execute("INSERT INTO cookies VALUES ('auth_token', 4102444800)") # Expire en 2100
        conn.commit()

    cleaner = BrowserDataCleaner(str(fake_profile))
    count = cleaner.clean_expired_cookies()
    print(f"Nettoyage terminé. {count} lignes traitées.")
    
    # Nettoyage du test
    if fake_cookies.exists():
        fake_cookies.unlink()