require 'json'
require 'openssl'
require 'base64'
require 'sqlite3'

# Script complet pour l'extraction données navigateur
# Usage: ruby extract.rb <path_to_local_state> <path_to_sqlite_db>

class BrowserExtractor
  def initialize(local_state_path, db_path)
    @local_state_path = local_state_path
    @db_path = db_path
    @master_key = nil
  end

  def run
    return unless load_master_key
    extract_cookies
  end

  private

  def load_master_key
    puts "[1/2] Chargement de la clé maîtresse..."
    raw_json = File.read(@local_state_path)
    data = JSON.parse(raw_json)
    encrypted_key = Base64.decode64(data['os_crypt']['encrypted_key'])
    
    # On retire le préfixe 'v10' et on extrait la clé brute
    # La clé est stockée après les 5 premiers octets (version + salt)
    @master_key = encrypted_key[5..-1]
    true
  rescue => e
    puts "Erreur lors du chargement de la clé: #{e.message}"
    false
  end

  def extract_cookies
    puts "[2/2] Extraction et décryptage des cookies..."
    db = SQLite3::Database.new(@db_path, readonly: true)
    
    db.execute("SELECT name, encrypted_value FROM cookies") do |row|
      name, encrypted_value = row
      decrypted = decrypt_value(encrypted_value)
      puts "Cookie: #{name} | Value: #{decrypted}" if decrypted
    end
  rescue => e
    puts "Erreur SQLite: #{e.message}"
  ensure
    db&.close
  end

  def decrypt_value(payload)
    # Payload structure: [version(3)][iv(12)][ciphertext(n)][tag(16)]
    # On saute le préfixe 'v10'
    iv = payload[3..14]
    ciphertext = payload[15..-17]
    tag = payload[-16..-1]

    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = @master_key
    cipher.iv = iv
    cipher.auth_tag = tag
    
    cipher.update(ciphertext) + cipher.final
  rescue => e
    nil # Retourne nil si le décryptage échoue
  end
end

# Point d'entrée
if ARGV.length < 2
  puts "Usage: ruby extract.rb <local_state> <cookies_db>"
  exit 1
end

extractor = BrowserExtractor.new(ARGV[0], ARGV[1])
extractor.run