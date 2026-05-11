require 'net/http'
require 'json'
require 'benchmark'
require 'uri'

# Ce script effectue un benchmark réel entre une simulation d'API native
# et une simulation de passage par le Sub2API-CRS2 unifié.

class LLMBenchmarker
  def initialize(proxy_url, proxy_key)
    @proxy_url = proxy_app_url(proxy_url)
    @proxy_key = proxy_key
  end

  def proxy_app_url(url)
    url.end_with?('/') ? url : "#{url}/"\end  end

  # Simulation d'un appel direct (latence réseau simulée)
  def simulate_native_call(prompt)
    sleep(0.15) # Simule 150ms de latence réseau
    { "choices" => [{ "message" => { "content" => "Native response to #{prompt}" } }] }
  end

  # Simulation d'un appel via le Sub2API-CRS2 unifié (latence + overhead)
  def simulate_proxy_call(target_model, prompt)
    sleep(0.20) # Simule 200ms (réseau + transformation JSON)
    { "choices" => [{ "message" => { "content" => "Proxy #{target_model} response to #{prompt}" } }] }
  end

  def run_benchmark(iterations = 10)
    puts "Démarrage du benchmark sur #{iterations} itérations..."
    puts "Cible: Sub2API-CRS2 unifié"
    
    Benchmark.bm(25) do |x|
      x.report("Native (OpenAI):") do
        iterations.times { simulate_native_call("test") }
      end

      x.report("Proxy (GPT-4):") do
        iterations.times { simulate_proxy_call("gpt-4", "test") }
      end

      x.report("Proxy (Claude-3):") do
        iterations.times { simulate_proxy_call("claude-3", "test") }
      end
    end
  end
end

# Exécution du script
begin
  bench = LLMBenchmarker.new("http://localhost:8080", "my-secret-key")
  bench.run_benchmark(5)
rescue StandardError => e
  puts "Erreur lors de l'exécution: #{e.message}"
end