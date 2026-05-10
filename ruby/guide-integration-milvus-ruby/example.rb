require 'securerandom' 

# Simulation d'un client pour illustrer la logique de gestion de vecteurs
class MockMilvusClient
  def initialize(uri)
    @uri = uri
    @collections = {}
  end

  def create_collection(name, dim)
    @collections[name] = { dim: dim, data: [] }
    puts "Collection '#{name}' créée avec dimension #{dim}"
  end

  def insert(name, records)
    return unless @collections[name]
    @collections[name][:data].concat(records)
    puts "Insertion de #{records.size} vecteurs dans '#{name}'"
  end

  def search(name, query_vec, top_k: 3)
    collection = @collections[name]
    raise "Dimension mismatch" if query_vec.size != collection[:dim]

    # Simulation d'un calcul de distance euclidienne (L2)
    results = collection[:data].map do |item|
      dist = Math.sqrt(item[:vector].zip(query_vector).map { |a, b| (a - b)**2 }.sum)
      { id: item[:id], distance: dist }
    end

    results.sort_by { |r| r[:distance] }.take(top_k)
  end
end

# Script de test
query_vector = Array.new(128) { rand }
client = MockMilvusClient.new('localhost:19530')

client.create_collection('embeddings_test', 128)

# Génération de données factices\mock_data = Array.new(10) do |i|
  { id: i, vector: Array.new(128) { rand } }
end

client.insert('embeddings_test', mock_data)

puts "Recherche en cours..."
matches = client.search('embeddings_test', query_vector, top_k: 2)

puts "Résultats de la recherche :"
matches.each { |m| puts "ID: #{m[:id]} - Distance: #{m[:distance].round(4)}" }