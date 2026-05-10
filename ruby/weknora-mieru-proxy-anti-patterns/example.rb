require 'net/http'
require 'uri'
require 'openssl'

# Classe de gestion de tunnel pour WeKnora : mieru
class ProxyTunnelManager
  attr_reader :proxy_host, :proxy_port

  def initialize(host, port)
    @proxy_host = host
    @proxy_port = port
  end

  # Effectue une requête sécurisée en s'assurant du passage par le proxy
  def safe_request(target_url)
    uri = URI.parse(target_url)
    
    puts "Tentative de connexion vers : #{uri.host}"
    puts "Via proxy : #{@proxy_app_proxy_info}"

    # Configuration explicite pour éviter les fuites
    http = Net::HTTP.new(uri.host, uri.port, @proxy_host, @proxy_port)
    http.use_ssl = (uri.scheme == 'https')
    
    # Sécurité critique : On impose la vérification du certificat
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    
    # Protection contre les blocages de thread
    http.open_timeout = 5
    http.read_timeout = 10

    begin
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      
      puts "Réponse reçue : #{response.code}"
      response.body
    rescue Net::OpenTimeout
      puts "Erreur : Le proxy WeKnora : mieru ne répond pas (Timeout)."
    rescue SocketError => e
      puts "Erreur de résolution ou de connexion : #{e.message}"
    rescue StandardError => e
      puts "Erreur inattendue : #{e.class} - #{e.message}"
    end
  end

  private

  def @proxy_app_proxy_info
    "#{@proxy_host}:#{@proxy_port}"
  end
end

# --- Script d'exécution ---

# Configuration de l'instance (simulant un proxy local WeKnora : mieru)
manager = ProxyTunnelManager.new('127.0.0.1', 1080)

# Test sur une URL de test d'IP
# Note : Ce script échouera si aucun proxy n'est réellement lancé sur le port 1080
target = 'https://api.ipify.org'
result = manager.safe_request(target)

if result
  puts "Contenu de la réponse : #{result.strip}"
else
  puts "Échec de la récupération des données."
end