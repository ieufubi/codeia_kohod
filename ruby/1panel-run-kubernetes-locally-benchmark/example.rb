require 'socket'
# Outil de diagnostic réseau pour clusters Kubernetes locaux
# Vérifie si le port de l'API Kubernetes est accessible

class K8sPortChecker
  def initialize(host, port)
    @host = host
    @port = port
  end

  def check_connectivity
    puts "Tentative de connexion à #{@host}:#{@port}..."
    
    begin
      # Tentative de socket TCP avec un timeout de 2 secondes
      socket = Socket.new(:INET, :STREAM)
      sockaddr = Socket.sockaddr_in(@port, @host)
      
      # Utilisation de select pour gérer le timeout
      if IO.select([socket], nil, nil, 2)
        socket.connect(sockaddr)
        puts "[OK] Le port est accessible. L'API est réactive."
        true
      else
        puts "[ERREUR] Timeout : Le service ne répond pas sur le port #{@port}."
        false
      end
    rescue Errno::ECONNREFUSED
      puts "[ERREUR] Connexion refusée. Vérifiez que 1Panel : Run Kubernetes locally est lancé."
      false
    rescue StandardError => e
      puts "[ERREUR] Une erreur inattendue est survenue : #{e.message}"
      false
    ensure
      socket.close if socket && !socket.closed?
    end
  end
end

# Simulation d'un test sur le port par défaut de l'API K8s (6443)
checker = K8sPortChecker.new('127.0.0.1', 6443)
checker.check_connectivity
</code_exemple_standalone]