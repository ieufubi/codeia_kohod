require 'open3'
require 'tempfile'

# Ce script démontre la création d'un environnement de test
# pour simuler l'isolation de waza.

class SandboxSimulator
  def initialize(work_dir)
    @work_dir = work_dir
    Dir.mkdir(@work_dir) unless Dir.exist?(@work_dir)
  end

  def create_agent_script(content)
    path = File.join(@work_dir, 'agent.rb')
    File.write(path, content)
    path
  end

  def run_isolated(script_path, safe_env)
    puts "--- DÉBUT DE L'ISOLATION ---"
    puts "Cible : #{script_path}"
    puts "Environnement autorisé : #{safe_env.keys.join(', ')}"

    # Simulation de l'exécution avec filtrage
    stdout, stderr, status = Open3.capture3(safe_env, "ruby #{script_path}")

    puts "Sortie de l'agent : #{stdout}"
    puts "Erreurs de l'agent : #{stderr}"
    puts "Statut : #{status.success? ? 'SUCCÈS' : 'ÉCHEC'}"
    puts "--- FIN DE L'ISOLATION ---"
  end
end

# 1. Configuration du scénario
# Nous avons un secret sensible sur l'hôte
ENV['SUPER_SECRET_TOKEN'] = 'abc-123-xyz'

simulator = SandboxSimulator.new('./sandbox_test')

# 2. Création d'un agent qui tente de voler le secret
malicious_code = <<~RUBY
  puts "Tentative de vol de secret..."
  if ENV['SUPER_SECRET_TOKEN']
    puts "VOL RÉUSSI : \#{ENV['SUPER_SECRET_TOKEN']}"
  else
    puts "ÉCHEC : Le secret est invisible."
  end
RUBY

agent_file = simulator.create_agent_script(malicious_code)

# 3. TEST 1 : Exécution NON SÉCURISÉE (Danger)
puts "\n[TEST 1] Exécution sans protection (Héritage ENV)..."
Open3.capture3("ruby #{agent_file}") do |stdout, stderr, status|
  # Note: Open3.capture3 ne prend pas de bloc comme capture3, 
  # on utilise la forme simple pour l'exemple.
end
# Pour l'exemple, on utilise la forme simple pour montrer la fuite
_, err, status = Open3.capture3("ruby #{agent_file}")
puts "Résultat attendu : Fuite de données."

# 4. TEST 2 : Exécution avec environnements waza sécurisés (Correct)
puts "\n[TEST 2] Exécution avec filtrage (Style Waza)..."
safe_env = { 'PATH' => '/usr/bin:/bin', 'USER' => 'sandbox_user' }
simulator.run_isolated(agent_file, safe_env)

# Nettoyage
FileUtils.remove_dir('./sandbox_test') if Dir.exist?('./sandbox_test')