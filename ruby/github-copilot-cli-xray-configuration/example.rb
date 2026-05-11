require 'net/http'
require 'uri'
require 'json'

# Script autonome pour tester la configuration du tunnel proxy
# Ce script simule une requête API vers GitHub et analyse la réponse.

class GitHubConnectivityTester
  def initialize(proxy_url)
    @proxy_uri = URI.parse(proxy_url)
    @target_uri = URI.parse('https://api.github.com/zen')
  end

  def run_test
    puts "--- Début du test de connectivité ---"
    puts "Cible: #{@target_uri}"
    puts "Proxy: #{@proxy_uri}"

    begin
      response = perform_request
      process_response(response)
    rescue SocketError => e
      puts "[ERREUR] Résolution DNS impossible. Vérifiez votre connexion internet ou Xray."
    rescue Net::OpenTimeout, Net::ReadTimeout
      puts "[ERREUR] Timeout. Le proxy est trop lent ou le serveur est injoignable."
    rescue StandardError => e
      puts "[ERREUR] Une erreur inattendue est survenue: #{e.message}"
    ensure
      puts "--- Fin du test ---"
    end
  end

  private

  def perform_request
    # Utilisation de la classe Net::HTTP::Proxy pour injecter le proxy
    proxy_class = Net::HTTP::Proxy(@proxy_uri.host, @proxy_uri.port)
    
    proxy_class.start(@target_uri.host, @target_uri.port, use_ssl: true) do |http|
      http.open_timeout = 5
      http.read_timeout = 5
      http.get(@target_uri.path)
    end
  end

  def process_response(response)
    if response.code == '200'
      puts "[OK] Connexion réussie !"
      puts "Message reçu de GitHub: #{response.body}"
    else
      puts "[ALERTE] Réponse non attendue: #{response.code}"
      puts "Contenu: #{response.body[0..50]}..."
    end
  end
end

# Configuration de l'environnement de test
# Remplacez par l'adresse de votre instance Xray locale
PROXY_ADDRESS = 'http://127.0.0.1:10809'

tester = GitHubConnectivityTester.new(PROXY_ASSY)
tester.run_test