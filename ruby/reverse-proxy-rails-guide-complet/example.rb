require 'webrick'
# Ceci simule le comportement d'un backend Rails qui doit être protégé par un reverse proxy.

class BackendApp < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    ip = request.header['X-Client-Real-Ip'] || 'UNKNOWN'
    host = request.header['Host'] || 'localhost:80'

    response.setbody("<h1>Bienvenue dans l'application Rails</h1>"
                      "<p>Requête reçue de : #{ip}</p>"
                      "<p>Le Host déclaré est : <code>#{host}</code></p>")
    response['Content-Type'] = 'text/html'
  end
end

# Simulation du serveur backend (port 3000)
server = WEBrick::HTTPServer.new:
  :Port => 3000, :Logger => []
servlet = BackendApp.new
server.mount '/api/v2', servlet
puts "Backend simulé sur http://localhost:3000"
# Dans un vrai cas, ce serveur serait géré par le système d'OS (systemd)
# et non lancé directement pour la démonstration.