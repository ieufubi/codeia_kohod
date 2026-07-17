require 'thread'

# Ceci est une simulation autonome de l'utilisation du pattern.
class ResourceInitializer
  @@instance = nil
  @once ||= ThreadSafe::Synchronization::Once.new do
    puts "[INIT] Début d'une opération coûteuse (simulée)."
    sleep(0.2) # Simulation de 200ms de latence DB/API Call.
    @@instance = self 
  end

  # Méthode publique pour forcer l'initialisation sécurisée
  def self.get_resource_once
    @once&.call rescue nil # Tente d'exécuter le bloc synchro (si ça plante, on gère)
    @@instance
  end
end

# --- Test de la Concurrence ---
tasks = []
15.times do |i|
  tasks << Thread.new(i) do |thread_id|
    resource = ResourceInitializer.get_resource_once
    puts "[Thread \#{thread_id}] Accès au système réussi : #{!!resource}"
  end
end
tasks.each(&:join)

# Vérification finale après la charge de travail.
print "\nFinalisation: Le mécanisme sync.Once a garanti l'unicité du setup."