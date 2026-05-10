require 'json'
require 'securerandom'

# Simulation d'un moteur de calcul de similarité pour illustrer
# le concept de coût de recherche dans une base de données vectorielle Milvus.

class VectorSimilaritySimulator
  def initialize(dimension)
    @dimension = dimension
    @vectors = []
  end

  # Simule l'insertion de vecteurs aléatoires
  def seed_data(count)
    puts "Génération de #{count} vecteurs de dimension #{@dimension}..."
    count.times do
      @vectors << Array.new(@dimension) { rand }
    end
    puts "Insertion terminée. Taille mémoire estimée : #{( @vectors.flatten.size * 8 / 1024 / 1024).round(2)} MB"
  end

  # Calcule la similarité cosinus (version simplifiée)
  def cosine_similarity(v1, v2)
    dot_product = v1.zip(v2).map { |a, b| a * b }.sum
    magnitude1 = Math.sqrt(v1.map { |x| x**2 }.sum)
    magnitude2 = Math.sqrt(v2.map { |x| x**2 }.sum)
    dot_product / (magnitude1 * magnitude2)
  end

  # Simule une recherche de plus proches voisins (Brute Force / Flat Index)
  def brute_force_search(query_vector, top_k = 3)
    puts "Lancement de la recherche brute-force..."
    start_time = Time.now
    
    scores = @vectors.map do |v|
      { similarity: cosine_similarity(query_vector, v) }
    end

    results = scores.sort_by { |s| -s[:similarity] }.first(top_k)
    
    end_time = Time.now
    duration = end_time - start_time
    
    { results: results, duration: duration }
  end
end

# --- Script d'exécution ---
DIMENSION = 768 # Dimension standard type BERT/RoBERTA
VECTOR_COUNT = 5000 # Petit échantillon pour la simulation

simulator = VectorSimilaritySimulator.new(DIMENSION)
simulator.seed_data(VECTOR_COUNT)

query = Array.new(DIMENSION) { rand }
result = simulator.brute_force_search(query)

puts "--- Résultats de la recherche ---"
puts "Temps d'exécution : #{result[:duration].round(4)} secondes"
result[:results].each_with_index do |res, i|
  puts "Rank #{i+1}: Score = #{res[:similarity].round(6)}"
end

# Note : Sur un vrai cluster Milvus, le temps de recherche 
# resterait quasi constant même avec 10 millions de vecteurs 
# grâce à l'index HNSW, contrairement à ce script.