require 'digest'
require 'time'

# Simule un cache de tokens/coûts par fournisseur
$token_cache = {}

# Constante pour la simulation du coût par token
COST_PER_TOKEN = 0.0001

# Simulation de la récupération d'un résultat avec coût et latence
def call_llm_api(provider, prompt, tokens)
  # Simule le temps de latence réseau variable
  latency = rand(0.1..0.5)
  sleep(latency)
  
  # Calcul du coût
  cost = tokens * COST_PER_TOKEN
  
  puts "[DEBUG] Appel réussi à #{provider} en #{latency.round(2)}s. Coût estimé : #{cost.round(4)} USD."
  return {
    text: "Réponse générée par #{provider} pour : #{prompt[0..10]}...",
    source: provider,
    latency: latency,
    cost: cost
  }
end

# Simulation du cœur de la gestion des API LLM multi-sources
def managed_api_call(prompts)
  results = []
  puts "\n--- Démarrage de la gestion des API LLM multi-sources ---"
  
  # Définition des fournisseurs et leur ordre de priorité
  providers = [:openai, :anthropic, :gemini]
  
  prompts.each_with_index do |prompt, index|
    puts "\n[Requête #{index+1}] Traitement du prompt : '#{prompt}'"
    
    best_result = nil
    min_cost = Float::INFINITY
    
    # On boucle sur les fournisseurs pour trouver le meilleur compromis
    providers.each do |provider|
      # Simulation d'appel, ici on suppose que 50 tokens sont utilisés
      result = call_llm_api(provider, prompt, 50)
      
      # Logique de sélection : on choisit le fournisseur le moins coûteux (ou le plus rapide si le coût est égal)
      if result[:cost] < min_cost
        min_cost = result[:cost]
        best_result = result
      end
    end
    results << best_result
  end
  
  puts "\n--- Fin du traitement. Total des coûts estimés : #{results.sum { |r| r[:cost] }.round(4)} USD ---"
end

prompts_a_tester = [
  "Écris un haïku sur Ruby.",
  "Explique le pattern Circuit Breaker.",
  "Quelle est la meilleure pratique pour un proxy API ?"
]

managed_api_call(prompts_a_tester)