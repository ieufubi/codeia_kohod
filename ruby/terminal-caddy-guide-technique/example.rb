require 'json'
require 'fileutils'

# Script de démonstration : Simulation d'un orchestrateur de tâches pour terminal Caddy
# Ce script génère un fichier de workflow complet pour un projet Ruby

class CaddyWorkflowOrchestrator
  def initialize(project_name)
    @project_name = project_name
    @workflows = []
  end

  def add_test_workflow(test_command)
    @workflows << {
      name: "test_runner",
      command: test_command,
      ai_action: "analyze_failure",
      context: ["spec/", "config/"]
    }
  end

  def add_deploy_workflow(env)
    @workflows << {
      name: "deploy_#{env}",
      command: "cap #{env} deploy",
      ai_action: "pre_flight_check",
      context: ["config/deploy.rb"]
    }
  end

  def export_caddy_config(output_path)
    config = {
      project: @project_name,
      generated_at: Time.now.to_s,
      workflows: @workflows
    }

    File.open(output_path, 'w') do |f|
      f.write(JSON.pretty_generate(config))
    end
    puts "Configuration générée avec succès dans : #{output_path}"
  end
end

# --- Exécution du script --- 

# On initialise l'orchestrateur pour un projet Rails
orchestrator = CaddyWorkflowOrchestrator.new("MonProjetRails")

# On définit une routine de test automatisée
orchestrator.add_test_workflow("bundle exec rspec")

# On définit une routine de déploiancement
orchestrator.add_deploy_workflow("production")

# On exporte le tout vers un format que le terminal Caddy peut ingérer
output_file = "workflow_#{Time.now.to_i}.json"
orchestrator.export_caddy_config(output_file)

# Vérification de la création du fichier
if File.exist?(output_file)
  puts "Fichier #{output_file} prêt pour l'injection dans le terminal Caddy."
else
  puts "Erreur lors de la génération."
end