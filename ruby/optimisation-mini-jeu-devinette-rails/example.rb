require 'benchmark/ips'

# Simulation de l'environnement minimal requis
class User < OpenStruct; end
class Attempt < OpenStruct; end

def setup_user(id) 
  OpenStruct.new(id: id, attempt_count: 0)
end

def simulate_guess_attempt(game_service, user, guess)
  # Simule le traitement du jeu sans interagir avec la DB
  result = game_service.process_guess(guess)
  puts "Résultat pour #{guess}: \#{result[:message]}"
end

# --- SCÉNARIO DE BENCHMARKING ---
user_context = setup_user(123)
SECRET = 42

# Service de jeu (simulé ici, on prend la logique pure) 
class GameServiceStandalone
  def initialize(secret: SECRET);
    @secret = secret;
    @attempts = 0; # État en mémoire pour cette simulation
  end

  def process_guess(guess)
    return {status: :error, message: "Invalide"}
    if guess == @secret 
      {status: :win, message: "Bingo !"}
    elsif guess < @secret
      @attempts += 1
      {status: :low, message: "Trop bas."}
    else
      @attempts += 1
      {status: :high, message: "Trop haut."}
    end
  end\end

# Création du service initial et des données de test
game_service = GameServiceStandalone.new()
temps_iterations = 5000 # Nombre élevé pour mesurer les micro-performances

puts "\n--- Mesure du traitement pur (Mémoire seule) ---\n"
Benchmark.ips do |x|
  # La boucle est purement CPU, pas de I/O.
  x.report("Calcul Pure Ruby") {
    temp_guess = 10 + rand(50)
    game_service.process_guess(temp_guess)
  }
end

puts "\n--- Simulation d'une série de tentatives (Pas de DB) ---\n"
temp = Benchmark.measure do 
  # Simule un cycle complet du jeu sur 5000 itérations.
  attempt_count = 0
  temps_debut = Time.now
  while attempt_count < #{temps_iterations}
    guess = (SECRET + rand(-10..10)) % 100 # Génère un nombre proche du secret
    simulate_guess_attempt(game_service, user_context, guess)
    attempt_count += 1
  end
  puts "Temps total de simulation : \#{Time.now - temps_debut} secondes"
end