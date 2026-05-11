require 'json'
require 'open3'

# Script de diagnostic pour 1Panel Kubernetes local
# Ce script analyse l'état de santé du cluster local
class ClusterHealthMonitor
  def initialize
    @errors = []
  end

  def check_kubectl_presence
    stdout, stderr, status = Open3.capture3('kubectl version --client')
    unless status.success?
      @errors << "kubectl n'est pas installé ou inaccessible."
    end
  end

  def check_nodes_status
    stdout, stderr, status = Open3.capture3('kubectl get nodes')
    if status.success?
      nodes = stdout.split("\n")[1..-1]
      nodes.each do |node|
        parts = node.split
        status_node = parts[2]
        if status_node != "Ready"
          @errors << "Le nœud #{parts[0]} est dans l'état : #{status_node}"
        end
      end
    else
      @errors << "Impossible de récupérer les nœuds : #{stderr}"
    end
  end

  def report
    puts "--- Rapport de Santé 1Panel Kubernetes local ---"
    if @errors.empty?
      puts "Statut : EXCELLENT"
      puts "Aucun problème détecté sur le cluster."
    else
      puts "Statut : ALERTE"
      @errors.each { |err| puts "[!] #{err}" }
    end
    puts "------------------------------------------------"
  end
end

# Exécution du diagnostic
monitor = ClusterHealthMonitor.new
monitor.check_kubectl_presence
monitor.check_nodes_status
monitor.report