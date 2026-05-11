require 'open3'
require 'json'

# Ce script permet de surveiller l'état de santé des pods 
# dans un environnement 1Panel : Run Kubernetes locally.
# Il est conçu pour être exécuté de manière autonome.

class ClusterMonitor
  def initialize(context)
    @context = context
  end

  def monitor_pods
    puts "--- Surveillance du cluster : #{@context} ---"
    
    loop do
      # On récupère les pods au format JSON pour un parsing propre
      cmd = "kubectl --context=#{@context} get pods -o json"
      stdout, stderr, status = Open3.capture3(cmd)

      if status.success?
        pods = JSON.parse(stdout)['items']
        process_pods(pods)
      else
        puts "Erreur de lecture : #{stderr}"
      end

      sleep 10 # Pause de 10 secondes entre chaque vérification
    end
  end

  private

  def process_pods(pods)
    return puts "Aucun pod trouvé dans le contexte actuel." if pods.empty?

    puts "\n[#{Time.now.strftime('%H:%M:%S')}] État des pods :"
    pods.each do |pod|
      name = pod['metadata']['name']
      status = pod['status']['phase']
      puts " - #{name} : #{status}"
    end
  end
end

# Configuration de l'exécution
# Remplacez '1panel-k8s-context' par votre contexte réel
CONTEXT_NAME = '1panel-k8s-context'

begin
  monitor = ClusterMonitor.new(CONTEXT_NAME)
  monitor.monitor_pods
rescue Interrupt
  puts "\nArrêt de la surveillance par l'utilisateur."
rescue StandardError => e
  puts "Une erreur est survenue : #{e.message}"
end