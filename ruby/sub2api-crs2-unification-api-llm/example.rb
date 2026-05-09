require 'net/http'
require 'uri'
require 'json'

# Script autonome pour tester la configuration Sub2API-CRS2
# Ce script simule un appel client vers le proxy

class Sub2APITestClient
  def initialize(proxy_url, api_key)
    @uri = URI.parse(proxy_url)
    @api_key = api_key
  end

  def test_connection(model_name)
    puts "--- Test de connexion vers Sub2API-CRS2 ---"
    puts "Modèle cible : #{model_name}"
    
    request = Net::HTTP::Post.new(@uri)
    request['Authorization'] = "Bearer #{@api_key}"
    request['Content-Type'] = 'application/json'
    request.body = {
      model: model_name,
      messages: [{ role: 'user', content: 'Réponds par le mot TEST' }]
    }.to_json

    begin
      response = Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
        http.request(request)
      end

      if response.code == '200'
        data = JSON.parse(response.body)
        content = data.dig('choices', 0, 'message', 'content')
        puts "Succès ! Réponse reçue : #{content}"
      else
        puts "Erreur HTTP #{response.code} : #{response.body}"
      end
    rescue StandardError => e
      puts "Échec critique : #{e.message}"
    end
  end
end

# Configuration de test (à adapter selon votre instance)
PROXY_URL = 'http://localhost:8080/v1/chat/completions'
API_KEY = 'votre_cle_de_test'
MODEL = 'gpt-4'

# Exécution
client = Sub2APITestClient.new(PROXY_URL, API_KEY)
client.test_connection(MODEL)