require 'json'
require 'securerandom'

# Simulation complète d'un cycle de vie MCP
class MCPServerSimulator
  def initialize
    @id_counter = 0
    @tools = [
      { name: 'query_db', description: 'Exécute du SQL en lecture seule' }
    ]
  end

  def run_simulation
    puts "--- Début de la simulation MCP ---"
    
    # 1. Simulation de la requête tools/list
    request = create_request('tools/list')
    puts "Client demande la liste des outils..."
    response = handle_request(request, { tools: @tools })
    puts "Réponse serveur : #{response}"

    # 2. Simulation de l'appel tools/call
    call_params = {
      name: 'query_db',
      arguments: { sql: 'SELECT 1' }
    }
    request_call = create_request('tools/call', call_params)
    puts "\nClient appelle l'outil query_db..."
    response_call = handle_request(request_call, { content: [{ type: 'text', text: 'Result: 1' }] })
    puts "Réponse serveur : #{response_call}"
  end

  private

  def create_request(method, params = {})
    @id_counter += 1
    {
      jsonrpc: '2.0',
      id: @id_counter,
      method: method,
      params: params
    }.to_json
  end

  def handle_request(json_payload, result_payload)
    request = JSON.parse(json_payload)
    # Simulation de la logique de réponse
    {
      jsonrpc: '2.0',
      id: request['id'],
      result: result_payload
    }.to_json
  rescue StandardError => e
    { jsonrpc: '2.0', id: nil, error: { code: -32603, message: e.message } }.to_json
  end
end

# Exécution du script
simulator = MCPServerSimulator.new
simulator.run_simulation