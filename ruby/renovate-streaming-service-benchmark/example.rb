require 'socket'

# Script de test de charge minimaliste pour le Renovastre streaming service
# Simule un client TCP qui lit le flux sans interruption
# Usage: ruby load_test.rb localhost 9292

class LoadTester
  def initialize(host, port)
    @host = host
    @port = port
  end

  def run(duration_seconds)
    puts "Démarrage du test de charge sur #{@host}:#{@port} pour #{duration_seconds}s"
    start_time = Time.now
    bytes_received = 0

    begin
      socket = TCPSocket.new(@host, @port)
      
      while Time.now - start_time < duration_seconds
        # Lecture de chunks de 16KB
        chunk = socket.read(16384)
        break if chunk.nil?
        
        bytes_received += chunk.bytesize
        # Affichage de la progression toutes les 5 secondes
        if (Time.now - start_time).to_i % 5 == 0
          puts "Progression : #{(bytes_received / 1024.0 / 1024.0).round(2)} MB reçus..."
        end
      end
    rescue Errno::ECONNREFUSED
      puts "Erreur : Le serveur n'est pas accessible. Vérifiez que le service est lancé."
    rescue StandardError => e
      puts "Erreur lors du test : #{e.message}"
    ensure
      socket&.close
      total_mb = (bytes_received / 1024.0 / 1024.0).round(2)
      puts "--- TEST TERMINÉ ---"
      puts "Total reçu : #{total_mb} MB"
      puts "Durée : #{(Time.now - start_time).round(2)} secondes"
      puts "Débit moyen : #{(total_mb / (Time.now - start_time)).round(2)} MB/s"
    end
  end
end

# Configuration et exécution
HOST = ARGV[0] || '127.0.0.1'
PORT = ARGV[1] || '9292'

tester = LoadTester.new(HOST, PORT.to_i)
tester.run(30) # Test de 30 secondes