require 'yaml'
require 'digest'

# Script d'audit complet pour configuration proxy Hysteria
# Ce script vérifie l'intégrité et la sécurité des paramètres
class HysteriaSecurityAuditor
  def initialize(config_path)
    @path = config_path
    @report = []
  end

  def run_audit
    return puts "Erreur : Fichier introuvable." unless File.exist?(@path)

    config = YAML.load_file(@path)
    
    audit_auth(config)
    audit_bandwidth(config)
    audit_tls(config)
    
    print_report
  end

  private

  def audit_auth(config)
    token = config.dig('auth')
    if token.nil? || token.length < 16
      @report << "[CRITIQUE] Token d'authentification trop court ou absent."
    end
  end

  def audit_bandwidth(config)
    up = config.dig('bandwidth', 'up').to_i
    if up > 500_000_000 # 500 Mbps
      @report << "[AVERTISSEMENT] Bande passante 'up' potentiellement excessive."
    end
  end

  def audit_tls(config)
    cert = config.dig('tls', 'cert')
    if cert.nil? || cert.empty?
      @report << "[ERREUR] Certificat TLS manquant dans la configuration."
    end
  end

  def print_report
    puts "--- Rapport d'audit pour #{@path} ---"
    if @report.empty?
      puts "Aucune anomalie détectée. Configuration conforme."
    else
      @report.each { |msg| puts msg }
    end
    puts "------------------------------------------"
  end
end

# Simulation d'un fichier de config pour l'exemple
File.write('test_config.yaml', <<~YAML)
  auth: 'short_key'
  bandwidth:
    up: 800000000
    down: 800000000
  tls:
    cert: ''
  obfuscation: 'some_pattern'
YAML

# Exécution de l'audit
auditor = HysteriaSecurityAuditor.new('test_config.yaml')
auditor.run_audit

# Nettoyage
File.delete('test_config.yaml')