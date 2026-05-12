require 'json'
require 'digest'

# Simulation d'un système de Proxy API LLM autonome
class MockLLMProxy
  def initialize
    @providers = {
      'claude' => { url: 'api.anthropic.com', format: :anthropic },
      'gemini' => { url: 'api.gemini.google', format: :google }
    }
  end

  # Simule le routage et la transformation
  def process_request(provider_name, payload)
    provider = @providers[provider_name]
    raise 'Provider not found' unless provider

    puts "[Proxy] Routing to #{provider_name} (#{provider[:url]})..."
    
    # Simulation de la transformation du payload
    transformed = transform_payload(provider[:format], payload)
    
    # Simulation de la réponse du fournisseur
    raw_response = simulate_provider_response(provider[:format])
    
    # Re-formatage vers le standard unique
    reformat_response(provider[:format], raw_response)
  end

  private

  def transform_payload(format, payload)
    case format
    when :anthropic
      { messages: payload[:messages], max_tokens: 1000 }
    when :google
      { contents: [{ parts: [{ text: payload[:messages].first[:content] }] }] }
    end
  end

  def simulate_provider_response(format)
    case format
    when :anthropic
      { content: [{ text: "Réponse de Claude" }] }
    when :google
      { candidates: [{ content: { parts: [{ text: "Réponse de Gemini" }] } } ] }
    end
  end

  def reformat_response(format, raw_body)
    # On ramène tout au format standard 'unified'
    content = if format == :anthropic
                raw_body.dig('content', 0, 'text')
              else
                raw_body.dig('candidates', 0, 'content', 'parts', 0, 'text')
              end
    
    {
      status: 'success',
      result: content,
      timestamp: Time.now.to_i
    }
  end
end

# Test du proxy
proxy = MockLLMProxy.new
standard_payload = { messages: [{ role: 'user', content: 'Hello' }] }

puts "--- Test Claude ---"
puts JSON.pretty_generate(proxy.process_request('claude', standard_payload))

puts "\n--- Test Gemini ---"
puts JSON.pretty_generate(proxy.process_request('gemini', standard_payload))