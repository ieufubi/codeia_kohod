import socket
import json

# Simulation d'un mini-serveur de monitoring pour harness : Open device management
# Ce code illustre la réception brute de données sur un socket TCP
\HOST = '127.0.0.1'
PORT = 65432

def start_monitor():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        print(f"Serveur de monitoring démarré sur {HOST}:{PORT}")
        print("En attente de données de l'agent harness...")
        
        while True:
            conn, addr = s.accept()
            with conn:
                print(f"Connexion établie avec l'agent : {addr}")
                data = conn.recv(1024)
                if not data:
                    break
                
                try:
                    # Tentative de décodage du message reçu
                    payload = json.loads(data.decode('utf-8'))
                    print(f"Données reçues : {payload}")
                    
                    # Réponse de confirmation au périphérique
                    response = {"status": "received", "timestamp": 1715432100}
                    conn.sendall(json.dumps(response).encode('utf-8'))
                except json.JSONDecodeError:
                    print("Erreur : Format de message non conforme au protocole harness")
                    conn.sendall(b'{"error": "invalid_json"}')

if __name__ == "__main__":
    try:
        start_monitor()
    except KeyboardInterrupt:
        print("\nArrêt du moniteur.")