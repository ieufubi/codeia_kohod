import asyncio
import struct
import socket
from typing import Final

# Configuration
HOST: Final[str] = '127.0.0.1'
PORT: Final[int] = 1080
SOCKS_VERSION: Final[int] = 0x05

async def proxy_stream(reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
    """Transfère les données entre deux flux sans modification"""
    try:
        while True:
            data = await reader.read(4096)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except Exception:
        pass
    finally:
        writer.close()

async def handle_socks5_connection(client_reader: asyncio.StreamReader, client_writer: asyncio.StreamWriter) -> None:
    """Logique principale du Proxy WeKnora"""
    try:
        # 1. Handshake
        header = await client_reader.readexactly(2)
        version, nmethods = struct.unpack('!BB', header)
        
        if version != SOCKS_VERSION:
            client_writer.close()
            return

        methods = await client_reader.readexactly(nmethods)
        # Réponse : Méthode 0x00 (No Auth)
        client_writer.write(struct.pack('!BB', SOCKS_VERSION, 0x00))
        await client_writer.drain()

        # 2. Command Phase
        cmd_data = await client_reader.readexactly(4)
        cmd, _, addr_type = struct.unpack('!BBB', cmd_data)

        if addr_type == 0x01:  # IPv4
            addr_bytes = await client_reader.readexactly(4)
            dest_addr = socket.inet_ntoa(addr_bytes)
        elif addr_type == 0x03:  # Domain
            domain_len = (await client_reader.readexactly(1))[0]
            dest_addr = (await client_reader.readexactly(domain_len)).decode('ascii')
        else:
            return

        # Port (2 bytes)
        port_bytes = await client_reader.readexactly(2)
        dest_port = struct.unpack('!H', port_bytes)[0]

        # 3. Connect to destination
        print(f"[Proxy] Connexion vers {dest_addr}:{dest_port}")
        remote_reader, remote_writer = await asyncio.open_connection(dest_addr, dest_port)

        # 4. Acknowledge success
        client_writer.write(struct.pack('!BBBBI', SOCKS_VERSION, 0x00, 0x00, 0x01, 0))
        await client_writer.drain()

        # 5. Bi-directional forwarding
        await asyncio.gather(
            proxy_stream(client_reader, remote_writer),
            proxy_stream(remote_reader, client_writer)
        )

    except Exception as e:
        print(f"[Error] {e}")
    finally:
        client_writer.close()

async def main():
    server = await asyncio.start_server(handle_socks5_connection, HOST, PORT)
    print(f"[Server] Proxy WeKnora actif sur {HOST}:{PORT}")
    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[Server] Arrêt du proxy.")