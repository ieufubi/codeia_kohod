import asyncio
import socket
import struct
import ssl

class ProxyServer:
    """Serveur proxy minimaliste pour tester le WeKnora bypass censorship."""
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port

    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        try:
            # Lecture de l'étape de négociation (simplifié)
            header = await reader.read(2)
            if not header or header[0] != 0x05:
                return

            # Lecture de la méthode (simplifié)
            method_data = await reader.read(1)
            
            # Lecture de la commande (simplifié)
            cmd_data = await reader.read(1)
            if cmd_data[0] != 0x01: # CONNECT
                return

            # Lecture de l'adresse cible (IPv4)
            addr_bytes = await reader.read(4)
            target_ip = socket.inet_ntoa(addr_bytes)
            
            # Lecture du port
            port_bytes = await reader.read(2)
            target_port = struct.unpack("!H", port_bytes)[0]

            print(f"[PROXY] Tentative de connexion vers {target_ip}:{target_port}")

            # Connexion à la cible réelle
            remote_reader, remote_writer = await asyncio.open_connection(target_ip, target_port)

            # Bridge des flux
            async def bridge(src: asyncio.StreamReader, dst: asyncio.StreamWriter):
                try:
                    while True:
                        data = await src.read(8192)
                        if not data:
                            break
                        dst.write(data)
                        await dst.drain()
                except Exception:
                    pass
                finally:
                    dst.close()

            await asyncio.gather(
                bridge(reader, remote_writer),
                bridge(remote_reader, writer)
            )

        except Exception as e:
            print(f"[ERROR] {e}")
        finally:
            writer.close()

    async def run(self):
        server = await asyncio.start_server(self.handle_client, self.host, self.port)
        print(f"[INFO] Serveur Proxy démarré sur {self.host}:{self.port}")
        async with server:
            await server.serve_forever()

if __name__ == "__main__":
    # Note: Pour tester, utilisez un client SOCKS5 compatible
    proxy = ProxyServer("127.0.0.1", 1080)
    try:
        asyncio.run(proxy.run())
    except KeyboardInterrupt:
        print("\n[INFO] Arrêt du serveur.")