require 'net/http'
require 'uri'
require 'json'

# Script complet de test d'intégration pour l'agrégateur de modèles IA
class IntegrationTester
  def initialize(hub_url)
    @uri = URI.parse(hub_url)
  end

  def run_test_suite
    puts "--- Début de la suite de tests ---"
    test_health_check
    test_model_availability
    puts "--- Fin des tests ---"
  end

  private

  def test_health_check
    print "Test Health Check: "
    response = Net::HTTP.get_response(@uri.merge("/health"))
    if response.code == "200"
      puts "OK"
    else
      puts "ÉCHEC (Code: #{response.code})"
    end
  rescue StandardError => e
    puts "ERREUR: #{e.message}"
  end

  def test_model_availability
    print "Test Requête Modèle: "
    payload = { model: "llama3-local", prompt: "Test" }
    
    http = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new(@uri.path + "/v1/query", {'Content-Type' => 'application/json'})
    request.body = payload.to_json

    response = http.request(request)
    if response.code == "200"
      puts "OK (Réponse: #{response.body[0..30]}...)"
    else
      puts "ÉCHEC (Code: #{response.code})"
    end
  rescue StandardError => e
    puts "ERREUR: #{e.message}"
  end
end

# Exécution du testeur
# Note: Assurez-vous que le service fsnotify tourne sur le port 8080
tester = IntegrationTester.new("http://localhost:8080")
tester.run_test_suite