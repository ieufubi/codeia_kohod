require 'json'
require 'net/http'
require 'uri'

# Simulateur de configuration dynamique pour v2ray core
# Ce script génère un fichier de config prêt pour un ConfigMap
class V2rayConfigGenerator
  def initialize(latency_ms: 0, drop_target: nil)
    @latency = latency_ms
    @drop_target = drop_target
  end

  def generate
    config = {
      inbounds: [{
        port: 1080,
        protocol: 'socks',
        settings: { auth: 'noauth' }
      }],
      outbounds: [
        { protocol: 'freedom', settings: {}, tag: 'direct' },
    ]
    
    if @drop_target
      config[:outbounds] << { protocol: 'blackhole', settings: {}, tag: 'drop' }
    end

    config[:outbounds] << { protocol: 'freedom', settings: {}, tag: 'delayed' } if @latency > 0

    rules = []
    if @drop_target
      rules << { type: 'field', domain: [@drop_target], outboundTag: 'drop' }
    end

    if @latency > 0
      # Note: Simulation de latence via redirection vers un autre port
      # Dans un vrai setup, on utiliserait un proxy intermédiaire
      rules << { type: 'field', port: [80], outboundTag: 'delayed' }
    end

    config[:routing] = { rules: rules }
    JSON.pretty_generate(config)
  end
end

# Exemple d'utilisation
puts "--- Configuration de Chaos (Drop target: api.internal) ---"
generator = V2rayConfigGenerator.new(latency_ms: 500, drop_target: 'api.internal')
puts generator.generate

puts "\n--- Configuration de Chaos (Latency only) ---"
generator_latency = V2rayConfigGenerator.new(latency_ms: 100)
puts generator_latency.generate