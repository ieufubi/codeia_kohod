require 'net/http'
require 'json'
require 'uri'

# Simulation complète d'un client MCP pour tester la logique sans cluster actif
# Ce script permet de valider la structure JSON-RPC avant déploiement sur Minikube

class MCPSimulator
  def initialize
    @history = []
  end

  def handle_request(json_payload)
    request = JSON.parse(json_apo_payload)
    
    # Simulation de la logique du serveur MCP
    case request['method']
    when 'tools/call'
      process_tool_call(request['params'])
    when 'tools/list'
      { jsonrpc: '2.0', id: request['id'], result: { tools: ['get_post', 'search_user'] } }
    else
      { jsonrpc: '2.0', id: request['id'], error: { code: -32601, message: 'Method not found' } }
    end
  end

  private

  def process_tool_call(params)
    tool_name = params['name']
    args = params['arguments']

    if tool_name == 'get_post'
      # Simulation d'un retour de données de xiaohongshu.com
      {
        jsonrpc: '2.0',
         result: {
          content: [{ type: 'text', text: "Contenu simulé pour le post #{args['id']}" }]
        }
      }
    else
      { jsonrpc: '2.0', error: { code: -32602, message: 'Invalid params' } }
    end
  end
end

# --- Script d'exécution ---

simulator = MCPSimulator.new

# Test 1: Lister les outils disponibles
payload_list = { jsonrpc: '2.0', method: 'tools/list', id: 1 }.to_json
puts "--- Test List Tools ---"
puts simulator.handle_request(payload_list)

# Test 2: Appeler un outil spécifique (Simulation de l'appel via minikube MCP xiaohongshu)
payload_call = {
  jsonrpc: '2.0',
  method: 'tools/call',
  params: { name: 'get_post', arguments: { id: '999' } },
  id: 2
}.to_json

puts "\n--- Test Call Tool (get_post) ---"
puts simulator.handle_request(payload_call)

# Test 3: Erreur de méthode
payload_error = { jsonrpc: '2.0', method: 'unknown_method', id: 3 }.to_json
puts "\n--- Test Error Handling ---"
puts simulator.handle_request(payload_error)