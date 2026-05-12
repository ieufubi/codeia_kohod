require 'rack'
require 'rack/proxy'
require 'socket'

# Implémentation complète d'une plateforme proxy universelle
# Ce script crée un proxy qui redirige /service1 vers le port 3001
# et /service2 vers le port 3002.

class UniversalDevProxy < Rack::Proxy
  def initialize(app, config)
    @config = config
    super(app)
  end

  def rewrite_path(path)
    @config.each do |prefix, target_url|
      if path.start_with?(prefix)
        # On extrait le reste du chemin après le préfixe
        remaining_path = path.sub(prefix, '')
        # On reconstruit l'URL vers la destination
        return "#{target_url}#{remaining_path}"
      end
    end
    path
  end
end

# Configuration des destinations
# Note : Les services doivent être lancés au préalable
proxy_config = {
  '/service1' => 'http://localhost:3001',
  '/service2' => 'http://localhost:3002'
}

# Middleware de logging pour la plateforme proxy universelle
class SimpleLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    puts "[#{Time.now.strftime('%H:%M:%S')}] #{env['REQUEST_METHOD']} #{env['PATH_INFO']} -> #{status}"
    [status, headers, body]
  end
end

# Construction de la stack Rack
app = Rack::Builder.new do
  use SimpleLogger
  use UniversalDevProxy, proxy_config
  
  # Fallback si aucune route ne correspond
  run lambda { |env|
    [404, { 'Content-Type' => 'text/plain' }, ['Route non configurée dans la plateforme proxy universelle.']] 
  }
end

puts "Plateforme proxy universelle démarrée sur http://localhost:8080"
puts "Routes actives: #{proxy_config.keys.join(', ')}"

# Lancement du serveur
Rack::Handler::WEBrick.run app, Port: 8080