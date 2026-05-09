require 'net/http'
require 'uri'
require 'json'

# Script de test autonome pour valider la connectivité Sub2API-CRS2
# Ce script vérifie si le proxy est joignable et si le format de réponse est conforme.

class Sub2APITestRunner
  def initialize(proxy_url)
    @uri = URI.parse(proxy_url)
  end

  def run_health_check
    puts "--- Test de connectivité vers #{@uri} ---"
    
    response = Net::HTTP.get_response(@uri)
    
    if response.is_a?(Net::HTTPSuccess)
      puts "[OK] Le proxy est en ligne (Status: #{response.code})"
    else
      puts "[ERREUR] Le proxy répond avec un code: #{response.code}"
      return false
    end

    test_chat_endpoint
  end

  private

  def test_chat_endpoint
    puts "--- Test de l'endpoint /v1/chat/completions ---"
    
    endpoint = URI.parse("#{@uri}/v1/chat/completions")
    http = Net::HTTP.new(endpoint.host, endpoint.port)
    
    request = Net::HTTP::Post.new(endpoint.request_uri, {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer test_key'
    })

    payload = {
      model: 'gpt-3.5-turbo', # Test avec un modèle standard
      messages: [{ role: 'user', content: 'Ping' }]
    }
    
    request.body = payload.to_json

    begin
      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        puts "[OK] Réponse reçue avec succès."
        puts "Contenu du message: #{data.dig('choices', 0, 'message', 'content')}"
      else
        puts "[ERREUR] L'endpoint chat a échoué: #{response.code}"
        puts "Corps de la réponse: #{response.body}"
      end
    rescue => e
      puts "[ERREUR] Exception lors de l'appel: #{e.message}"
    end
  end
end

# Exécution du test
# Note: Remplacez l'URL par votre instance Sub2API-CRS2 réelle
PROXY_URL = 'http://localhost:8080'
tester = Sub2APITestRunner.new(PROXY_URL)
tester.run_health_check