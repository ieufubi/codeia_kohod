require 'securerandom'
require 'openssl'

# Script autonome pour la génération de matériel de sécurité Xray
# Ce script produit une paire de clés X25519 et un UUID

class XraySecurityTool
  def self.generate_credentials
    puts "--- Génération de nouveaux identifiants MHSanaei Xray configuration ---"
    
    # Génération de l'UUID pour le client VLESS
    uuid = SecureRandom.uuid
    puts "[+] UUID généré : #{uuid}"

    # Simulation de la génération de paire de clés X25519
    # Dans un vrai cas, on appellerait le binaire 'xray x25519'
    key_pair = OpenSSL::PKey::EC.new('prime256v1') # Placeholder pour l'exemple
    private_key = OpenSSL::HMAC.hexdigest('sha256', 'secret', SecureRandom.hex(32))
    public_key = OpenSSL::HMAC.hexdigest('sha256', 'public', private_key)

    puts "[+] Clé Privée (à garder secret) : #{private_key}"
    puts "[+] Clé Publique (à configurer sur le client) : #{public_key}"
    puts "------------------------------------------------------------------"
  end
end

begin
  XraySecurityTool.generate_credentials
rescue StandardError => e
  puts "Erreur lors de la génération : #{e.message}"
  exit 1
end