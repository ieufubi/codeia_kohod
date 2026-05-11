import os
import sys
from kubernetes import client, config
from typing import Final

class K8sAuditor:
    """Classe pour auditer la santé du cluster local via 1Panel."""
    
    def __init__(self, context: str):
        self.context = context
        try:
            config.load_kube_config(context=self.context)
            self.v1 = client.CoreV1Api()
        except Exception as e:
            print(f"Erreur d'initialisation du contexte {self.context}: {e}")
            sys.exit(1)

    def audit_nodes(self) -> None:
        """Vérifie si les nœuds sont prêts."""
        print(f"--- Audit du contexte: {self.context} ---")
        nodes = self.v1.list_node()
        for node in nodes.items:
            status = """Unknown"""
            for condition in node.status.conditions:
                if condition.type == "Ready" and condition.status == "True":
                    status = "Ready"
            print(f"Nœud: {node.metadata.name} | État: {status}")

    def audit_pods_memory(self) -> None:
        """Alerte si un pod dépasse une limite critique."""
        CRITICAL_THRESHOLD_MB: Final[float] = 1024.0
        pods = self.v1.list_pod_for_all_namespaces()
        
        for pod in pods.items:
            for container in pod.spec.containers:
                if container.resources.limits and 'memory' in container.resources.limits:
                    mem_str = container.resources.limits['memory']
                    # Conversion simple pour l'exemple
                    mem_val = float(mem_str.replace('Mi', '').replace('Gi', ''))
                    if 'Gi' in mem_str:
                        mem_val *= 1024
                        
                    if mem_val > CRITICAL_THRESHOLD_MB:
                        print(f"ALERTE: Pod {pod.metadata.name} est trop gourmand ({mem_val} MiB)")

if __name__ == "__main__":
    # On suppose que l'utilisateur a un contexte nommé 'k3s-1panel' configuré
    auditor = K8sAuditor(context="k3s-1panel")
    auditor.audit_nodes()
    auditor.audit_pods_memory()