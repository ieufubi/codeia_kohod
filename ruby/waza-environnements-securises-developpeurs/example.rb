require 'securerandom'

# Simulation complète d'un système de confinement
class WazaSandbox
  attr_reader :logs

  def initialize
    @logs = []
    @allowed_dirs = ['/tmp/sandbox']
  end

  def run_command(command, current_dir)
    puts "--- Exécution de : #{command} ---"
    
    # Vérification de la politique de sécurité
    if command.include?("..") || !@allowed_dirs.any? { |d| current_dir.start_with?(d) }
      log_violation(command, "Tentative de sortie du répertoire")
      return false
    end

    # Simulation de l'exécution
    if command.start_with?("rm")
      log_success("Fichier supprimé dans le bac à sable")
    else
      log_success("Commande exécutée avec succès")
    end
    true
  end

  private

  def log_violation(cmd, reason)
    @logs << "[ALERTE] #{Time.now} - Commande: #{cmd} - Raison: #{reason}"
  end

  def log_success(msg)
    @logs << "[INFO] #{Time.now} - #{msg}"
  end
end

# Scénario de test
sandbox = WazaSandbox.new
working_dir = "/tmp/sandbox"

# 1. Commande légitime
sandbox.run_command("ls -la", working_dir)

# 2. Commande malveillante (tentative de remontée de répertoire)
sandbox.run_command("rm -rf ../../etc", working_dir)

# 3. Commande malveillante (accès hors zone)
sandbox.run_command("cat /etc/passwd", working_dir)

puts "\n\nRésultat de l'audit de sécurité :"
puts sandbox.logs