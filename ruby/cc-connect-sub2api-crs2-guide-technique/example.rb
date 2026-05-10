require 'httpx'
require 'json'

# Simulation complète d'un client intelligent utilisant CC Connect
# Ce script démontre la gestion de modèles multiples et le retry logic.

class SmartLLMClient
  def initialize(gateway_url)
    @gateway_url = gateway_url
    @http = HTTPX.with(timeout: { connect: 5, read: 30 })
  end

  def smart_query(model_name, prompt)
    retries = 0
    max_retries = 3

    begin
      puts "[LOG] Tentative de requête sur le modèle : #{model_name}..."
      
      payload = {
        model: model_name,
        messages: [{ role: 'user', content: prompt }]
      }

      response = @http.post("#{@gateway_url}/v1/chat/completions", json: payload)

      if response.status == 429
        raise "Rate limit atteint (429)"
      elsif response.status != 200
        raise "Erreur serveur (Status: #{response.status})"
      end

      JSON.parse(response.body.to_s)

    rescue => e
      retries += 1
      if retries <= max_retries
        wait_time = 2**retries
        puts "[WARN] Erreur : #{e.message}. Réessai dans #{wait_time}s..."
        sleep(wait_time)
        retry
      else
        puts "[ERROR] Échec définitif après #{max_retries} tentatives."
        nil
      end
    end
  end
end

# --- Script d'exécution ---
# Note : Remplacez l'URL par votre instance CC Connect réelle.
GATEWAY = "http://localhost:8080"
client = SmartLLMClient.new(GATEWAY)

models_to_test = ['gpt-4o', 'claude-3-sonnet']
prompt_text = "Quelle est la complexité algorithmique du tri fusion ?"

models_to_test.each do |model|
  puts "\n--- Test du modèle #{model} ---"
  result = client.smart_query(model, prompt_text)
  
  if result
    content = result.dig("choices", 0, "message", "content")
    puts "Réponse : #{content[0..100]}..."
  else
    puts "Aucune réponse obtenue pour #{model}."
  end
end