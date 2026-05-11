require 'json'
require 'securerandom'

# Simulation d'un moteur d'évaluation de skill (Mini-Sivchari)
# Ce script illustre la logique de comparaison entre une sortie agent et une vérité terrain.

class SkillEvaluator
  def initialize(ground_truth_file)
    @ground_assurance = JSON.parse(File.read(ground_truth_file))
  end

  # Simule l'appel d'un agent (ici on génère une réponse aléatoire pour l'exemple)
  def simulate_agent_call(prompt)
    # Dans la réalité, ceci appellerait l'API OpenAI ou Claude
    # On simule ici une erreur de type (string au lieu de int)
    {
      "tool_call" => {
        "name" => "weather_lookup",
        "args" => { "location" => "Paris", "unit" => "kelvin" } # Erreur volontaire
      }
    }
  end

  def evaluate(prompt)
    actual_output = simulate_agent_call(prompt)
    expected_output = @ground_assurance.find { |test| test['prompt'] == prompt }

    return "Prompt non trouvé dans le dataset" unless expected_output

    results = []
    
    # Vérification du nom de l'outil
    name_match = actual_output['tool_call']['name'] == expected_output['expected_call']['name']
    results << { metric: "tool_name_match", passed: name_match }

    # Vérification des arguments (le point critique)
    args_match = actual_output['tool_call']['args'] == expected_output['expected_call']['args']
    results << { metric: "args_match", passed: args_match }

    {
      prompt: prompt,
      results: results,
      success: results.all? { |r| r[:passed] }
    }
  end
end

# --- Script d'exécution ---

# 1. Création d'un dataset temporaire
dataset_path = 'temp_dataset.json'
File.write(dataset_path, [
  {
    "prompt" => "Quel temps fait-il à Paris?",
    "expected_call" => { "name" => "weather_lookup", "args" => { "location" => "Paris", "unit" => "celsius" } }
  }
].to_json)

# 2. Lancement de l'évaluation
begin
  evaluator = SkillEvaluator.new(dataset_path)
  report = evaluator.evaluate("Quel temps fait-il à Paris?")

  puts "--- RAPPORT D'ÉVALUATION SIMULÉ ---"
  puts "Prompt: #{report[:prompt]}"
  puts "Succès global: #{report[:success] ? 'OUI' : 'NON'}"
  report[:results].each do |res|
    status = res[:passed] ? "[OK]" : "[ERREUR]"
    puts "  #{status} #{res[:metric]}"
  end
ensure
  File.delete(dataset_path) if File.exist?(dataset_path)
end