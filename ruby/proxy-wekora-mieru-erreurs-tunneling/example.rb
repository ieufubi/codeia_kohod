require 'socket'
require 'openssl'

# Script de test de conformité SOCKS5 pour proxy WeKnora mieru
# Ce script vérifie si le tunnel est fonctionnel et si le handshake réussit.

class SOCKS5Tester
  def initialize(proxy_host, proxy_port)
    @host = proxy_host
    @port = proxy_port
  end

  def run_test(target_host, target_port)
    puts "--- Début du test sur proxy WeKnora mieru ---"
    puts "Proxy: #{@host}:#{@port} | Cible: #{target_host}:#{target_port}"

    begin
      socket = TCPSocket.new(@host, @port)
      
      # 1. Handshake
      puts "[1] Envoi du handshake..."
      socket.write([0x05, 0x01, 0x00].pack('C*'))
      resp = socket.read(2)
      raise "Échec handshake: #{resp.unpack1('H*')}" unless resp.unpack1('C') == 0x05

      # 2. Connection Request (CONNECT)
      puts "[2] Envoi de la requête CONNECT..."
      payload = [0x05, 0x01, 0x00, 0x03, target_host.length].pack('C*') + target_host
      payload += [target_port].pack('n')
      socket.write(payload)

      # 3. Verification
      reply = socket.read(4)
      status = reply.unpack('C*')[1]
      
      if status == 0x00
        puts "[OK] Connexion établie avec succès !"
        # On tente une lecture minimale pour vérifier le flux
        socket.write("GET / HTTP/1.0\r\n\r\n")
        response = socket.read(100)
        puts "[OK] Réponse reçue: #{response.strip.gsub("\n", " ")}"
      else
        puts "[ERREUR] Le proxy a refusé la connexion (Code: #{status})"
      end

    rescue StandardError => e
      puts "[FATAL] Erreur durant le test: #{e.message}"
    ensure
      socket&.close
      puts "--- Fin du test ---"
    end
  end
end

# Utilisation
tester = SOCKS5Tester.new('127.0.0.1', 1080)
tester.run_test('google.com', 80)