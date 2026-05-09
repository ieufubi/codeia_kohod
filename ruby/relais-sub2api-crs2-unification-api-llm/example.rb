require 'json'
require 'net/http'
require 'securerandom'

# Simulation d'un client robuste pour le Relais Sub2API-CRS2
class RobustLLMClient
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def call_api(prompt)
    uri = URI("#{@endpoint}/v1/chat/completions")
    
    # Simulation d'une requête HTTP
    payload = {
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }],
      request_id: SecureRandom.uuid
    }

    puts "[LOG] Envoi de la requête vers le relais..."
    
    # Dans un vrai cas, on utiliserait Net::HTTP.post
    # Ici, nous simulons une réponse du Relais Sub2API-CRS2
    simulated_response = simulate_relay_response(payload)
    
    process_response(simulated_response)
  end

  private

  def simulate_relay_response(payload)
    # Simulation d'une réponse qui contient un changement de structure
    # On simule le bug mentionné dans l'article
    {
      "id" => "chatcmpl-\#{SecureRandom.hex(4)}",
      "choices" => [{
        "message" => { "role" => "assistant", "content" => "Réponse simulée" }
      }],
      "usage" => {
        "prompt_tokens" => 10,
        "completion_tokens" => 20,
        "total_tokens" => 30 # Le relais essaie de maintenir la compatibilité
      }
    }
  end

  def process_response(response)
    # Utilisation de .dig pour la sécurité (principe de moindre étonnement)
    content = response.dig('choices', 0, 'message', 'content')
    tokens = response.dig('usage', 'total_tokens') || 
             (response.dig('usage', 'prompt_tokens').to_i + response.dig('usage', 'completion_tokens').to_i)

    if content.nil?
      puts "[ERROR] Réponse vide ou format incorrect."
      return
    end

    puts "[SUCCESS] Contenu: #{content}"
    puts "[INFO] Tokens consommés: #{tokens}"
  end
end

# Exécution du test
client = RobustLLMClient.new("http://localhost:8080")
client.call_api("Explique-moi le principe de Matz.")