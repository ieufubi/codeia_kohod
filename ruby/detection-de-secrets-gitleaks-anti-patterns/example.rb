require 'open3'
require 'json'

# Script autonome pour vérifier l'intégrité des secrets dans un dossier
# Usage: ruby scanner_standalone.rb ./mon_projet

class SecurityAuditor
  def initialize(target_dir)
    @target_dir = target_dir
    @results = []
  end

  def audit!
    puts "--- Début de l'audit de sécurité : #{@target_perm} ---"
    
    # On simule l'appel à Gitleaks
    # Dans un vrai scénario, on appellerait le binaire installé
    command = ['gitleaks', 'detect', '--path', @target_dir, '--report-format', 'json', '--report-path', 'audit_report.json']
    
    puts "Exécution de la commande : #{command.join(' ')}"
    
    stdout, stderr, status = Open3.capture3(*command)

    if File.exist?('audit_report.json')
      process_report('audit_report.json')
    else
      puts "Erreur : Aucun rapport généré. Vérifiez que Gitleaks est installé."
    end

    print_summary
  end

  private

  def process_report(report_path)
    report_data = JSON.parse(File.read(report_path))
    @results = report_data
  rescue JSON::ParserError => e
    puts "Erreur de parsing : #{e.message}"
  end

  def print_summary
    if @results.empty?
      puts "[OK] Aucun secret trouvé dans #{@target_dir}."
    else
      puts "[ALERTE] #{@results.size} fuites potentielles détectées !"
      @results.each do |leak|
        puts "  -> Type: #{leak['rule_id']} | Fichier: #{leak['File']}"
      end
      exit 1
    end
  end
end

# Point d'entrée du script
if ARGV.empty?
  puts "Usage: ruby scanner_standalone.rb <directory>"
  exit 1
end

target_directory = ARGV[0]
auditor = SecurityAuditor.new(target_directory)
auditor.audit!