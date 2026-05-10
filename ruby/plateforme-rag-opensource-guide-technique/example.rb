require 'json'
require 'net/http'
require 'uri'

# Script autonome pour tester la disponibilité d'Ollama
# Ce script vérifie si le moteur d'embedding est prêt à l'emploi
class OllamaChecker
  def initialize(url)
    @uri = URI.parse(url)
  end

  def check_health
    puts "Vérification de l'endpoint : #{@uri}..."
    response = Net::HTTP.get_response(@uri)
    
    if response.is_a?(Net::HTTPSuccess)
      puts "[OK] Ollama est opérationnel."
      true
    else
      puts "[ERREUR] Impossible de contacter Ollama (Code: #{response.code})"
      false
    end
  rescue StandardError => e
    puts "[ERREUR] Erreur de connexion : #{e.message}"
    false
  end

  def list_models
    puts "Liste des modèles disponibles :"
    # Appel à l'API Ollama pour lister les modèles chargés
    request = Net::HTTP::Get.new('/api/tags')
    response = Net::HTTP.start(@uri.host, @uri.port) { |http| http.request(request) }
    
    if response.is_a?(Net::HTTPSuccess)
      models = JSON.parse(response.body)['models']
      models.each { |m| puts "- #{m['name']}" }
    else
      puts "Erreur lors de la récupération des modèles."
    end
  end
end

# Exécution du test
checker = OllamaChecker.new('http://localhost:11434')
if checker.check_health
  checker.list_models
end