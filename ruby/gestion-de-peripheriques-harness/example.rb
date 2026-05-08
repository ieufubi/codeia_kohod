require 'thread'
require 'json'

# Simulation d'un système complet de gestion de périphériques
class HardwareOrchestrator
  def initialize
    @devices = {}
    @lock = Mutex.new
    @event_log = Queue.new
  end

  def register_device(id, type)
    @lock.synchronize do
      @devices[id] = { type: type, status: :online, last_seen: Time.now }
      log("Device #{id} (#{type}) registered.")
    end
  end

  def update_device_telemetry(id, data)
    @lock.synchronize do
      return unless @devices.key?(id)
      @devices[id][:last_seen] = Time.now
      @devices[id][:data] = data
      log("Telemetry received for #{id}: #{data}")
    end
  end

  def simulate_failure(id)
    @lock.synchronize do
      return unless @devices.key?(id)
      @devices[id][:status] = :error
      log("ALERT: Device #{id} entered error state!")
    end
  end

  def log(msg)
    @event_log << "[#{Time.now.strftime('%H:%M:%S')}] #{msg}"
  end

  def run_monitor(duration)
    end_time = Time.now + duration
    
    # Thread de monitoring des timeouts
    monitor_thread = Thread.new do
      while Time.now < end_time
        @lock.synchronize do
          @devices.each do |id, info|
            if info[:status] == :online && (Time.now - info[:last_seen] > 5)
              info[:status] = :offline
              log("TIMEOUT: Device #{id} is now offline.")
            end
          end
        end
        sleep 2
      end
    end

    # Thread d'affichage des logs
    logger_thread = Thread.new do
      while Time.now < end_time || !@event_log.empty?
        msg = @event_log.pop(true) rescue nil
        puts msg if msg
        sleep 0.1
      end
    end

    monitor_thread.join
    logger_thread.join
  end
end

# --- Exécution du scénario ---
orchestrator = HardwareOrchestrator.new

# 1. Enregistrement de plusieurs capteurs
orchestrator.register_device("therm-01", :thermometer)
orchestrator.register_device("humid-01", :hygrometer)
orchestrator.register_device("press-01", :barometer)

# 2. Simulation d'activité
Thread.new do
  10.times do |i|
    sleep 1
    orchestrator.update_device_telemetry("therm-01", { temp: 20 + rand(5) })
    orchestrister_telemetry_humid = { humidity: 40 + rand(10) }
    orchestrator.update_device_telemetry("humid-01", orchestrister_telemetry_humid)
    
    # On simule une panne sur le capteur de pression à l'itération 4
    orchestrator.simulate_failure("press-01") if i == 4
  end
end

# 3. Lancement du monitoring pendant 15 secondes
puts "Starting Hardware Orchestration Monitor..."
orchestrator.run_monitor(15)
puts "Monitoring session ended."