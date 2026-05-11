import os
import subprocess
import tempfile
import shutil
from typing import List, Dict

class SecureAgentRunner:
    """Exemple complet d'un runner pour agent sécurisé."""
    
    def __init__(self, allowed_vars: List[str]):
        self.allowed_vars = allowed_vars
        self.sandbox_dir = tempfile.mkdtemp(prefix="waza_sandbox_")

    def cleanup(self):
        """Nettoyage de l'environnement après exécution."""
        if os.path.exists(self.sandbox_dir):
            shutil.rmtree(self.sandbox_dir)

    def run(self, command: List[str], timeout: int = 5) -> str:
        # Construction de l'environnement restreint
        safe_env: Dict[str, str] = {
            "PATH": "/usr/bin:/bin",
            "TMPDIR": self.sandbox_dir
        }
        
        for key in self.allowed_vars:
            if key in os.environ:
                safe_env[key] = os.environ[key]

        try:
            # Exécution avec isolation du répertoire de travail
            process = subprocess.run(
                command,
                env=safe_env,
                cwd=self.sandbox_dir,
                capture_output=True,
                text=True,
                timeout=timeout,
                check=True
            )
            return process.stdout
        except subprocess.TimeoutExpired:
            return "ERROR: Timeout reached"
        except subprocess.CalledProcessError as e:
            return f"ERROR: {e.stderr}"

if __name__ == "__main__":
    # Simulation d'un environnement avec un secret dangereux
    os.environ["AWS_SECRET_KEY"] = "SUPER_SECRET_DO_NOT_LEAK"
    os.environ["USER_CONTEXT"] = "developer_admin"

    # On ne veut autoriser que USER_CONTEXT
    runner = SecureAgentRunner(allowed_vars=["USER_CONTEXT"])
    
    print("--- Test 1: Exécution légitime ---")
    # On lance un echo qui tente de lire l'environnement
    # On utilise python -c pour simuler un script d'agent
    cmd = ["python3", "-c", "import os; print(os.environ.get('USER_CONTEXT', 'NOT_FOUND'))"]
    print(f"Résultat attendu: developer_admin | Résultat obtenu: {runner.run(cmd)}")

    print(\
"--- Test 2: Tentative de fuite de secret ---")
    cmd_leak = ["python3", "-c", "import os; print(os.environ.get('AWS_SECRET_KEY', 'NOT_FOUND'))"]
    print(f"Résultat attendu: NOT_FOUND | Résultat obtenu: {runner.run(cmd_leak)}")

    # Nettoyage final
    runner.cleanup()