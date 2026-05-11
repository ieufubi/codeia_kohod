require 'json'
require 'base64'
require 'openssl'
require 'fileutils'

# Script complet pour simuler l'analyse de HackBrowserData
class BrowserDataAuditor
  def initialize(local_state_path)
    @path = local_state_path
  end

  # Simule la lecture de la clé maîtresse
  def fetch_master_key
    return nil unless File.exist?(@path)
    
    raw_json = File.read(@path)
    config = JSON.parse(raw_json)
    encoded_key = config.dig('os_crypt', 'encrypted_key')
    
    return nil unless encoded_key
    
    # Décoder et retirer le préfixe (v10 ou v11)
    decoded = Base64.decode64(encoded_key)
    decoded.start_with?('v10', 'v11') ? decoded[3..-1] : decoded
  rescue StandardError => e
    puts "Erreur lors de la récupération de la clé : #{e.message}"
    nil
  end

  # Simule le déchiffrement d'un cookie
  def decrypt_cookie_value(encrypted_blob, master_key)
    return nil if encrypted_blob.nil? || master_key.nil()

    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = master_key

    # Structure attendue : nonce(12) + ciphertext + tag(16)
    nonce = encrypted_blob[0, 12]
    tag = encrypted_blob[-16, 16]
    ciphertext = encrypted_blob[12...-16]

    cipher.iv = nonce
    cipher.auth_tag = tag
    
    cipher.update(ciphertext) + cipher.final
  rescue OpenSSL::Cipher::CipherError
    puts "Erreur d'intégrité du cookie (Tag invalide)"
    nil
  end
end

# --- TEST DU SCRIPT ---
# Création d'un faux fichier Local State pour l'exemple
fake_path = 'local_state_test.json'
fake_key = 'v10' + 'A' * 32 # Simulation d'une clé chiffrée
File.write(fake_pass, { os_crypt: { encrypted_key: Base64.encode64(fake_key) } }.to_json)

# Simulation d'un cookie chiffré (Nonce + Ciphertext + Tag)
# Note: Dans un vrai cas, cela proviendrait de la base SQLite
fake_encrypted_cookie = '123456789012' + 'secret_data' + '1234567890123456'

auditor = BrowserDataAuditor.new(fake_path)
master_key = auditor.fetch_master_key

if master_key
  puts "Clé maîtresse récupérée (tronquée) : #{master_key[0..5]}..."
  # On ne peut pas déchiffrer le faux cookie sans la vraie structure AES-GCM
  # Mais le mécanisme de parsing est validé.
else
  puts "Échec de l'audit."
end

# Nettoyage
File.delete(fake_path) if File.exist?(fake_path)