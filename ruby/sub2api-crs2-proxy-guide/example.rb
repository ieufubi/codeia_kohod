require 'net/http'
require 'uri'
require 'json'

# Script de test de robustesse pour Sub2API-CRS2 proxy
# Ce script simule des appels successifs et vérifie la gestion des erreurs

class ProxyStressTester
  def initialize(proxy_url, api_key)
    @uri = URI.parse("#{proxy_url}/v1/chat/completions")
    @api_key = api_key
  end

  def run_test_suite
    puts "--- Démarrage du test de robustesse Sub2API-CRS2 proxy ---"
    
    test_cases = [
      { name: 'Appel Standard (GPT-4)', model: 'gpt-4o', prompt: 'Hello' },
      { name: 'Appel Modèle Alternatif (Claude)', model: 'claude-3-sonnet', prompt: 'Salut' },
      { name: 'Appel Modèle Inexistant', model: 'invalid-model', prompt: 'Test' },
      { name: 'Payload Vide', model: 'gpt-4o', prompt: '' }
    ]

    test_cases.each do |test|
      puts "Exécution : #{test[:name]}"
      result = perform_request(test[:model], test[:prompt])
      
      if result.is_a?(Hash) && result.key?('error')
        puts "  [!] Erreur capturée : #{result['error']}"
      else
        puts "  [+] Succès : #{result.dig('choices', 0, 'message', 'content') || 'Pas de contenu'}"
      end
    end
    
    puts "--- Fin des tests ---"
  end

  private

  def perform_request(model, prompt)
    request = Net::HTTP::Post.new(@uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = {
      model: model,
      messages: [{ role: 'user', content: prompt }]
    }.to_json

    Net::HTTP.start(@uri.host, @uri.port, use_ssl: true) do |http|
      response = http.request(request)
      JSON.parse(response.body)
    end
  rescue => e
    { 'error' => e.message }
  end
end

# Configuration de l'environnement de test
PROXY_ENDPOINT = 'http://localhost:8080'
TEST_KEY = 'sk-test-key-123'

tester = ProxyStressTester.new(PROXY_ENDPOINT, TEST_KEY)
tester.run_test_suite