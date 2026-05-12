require 'digest'

# Script autonome pour simuler la détection de secrets par entropie
# Ce script illustre comment l'entropie peut aider à identifier des chaînes suspectes.

class SecretScannerSimulator
  def initialize(threshold = 3.5)
    @threshold = threshold
  end

  def analyze_string(label, content)
    entropy = calculate_entropy(content)
    status = entropy > @threshold ? "[ALERTE]" : "[OK]"
    
    puts "#{status} #{label} (Entropie: #{entropy.round(2)})"
  end

  private

  def calculate_entropy(str)
    return 0.0 if str.empty?
    
    counts = str.chars.tally
    len = str.length.to_f

    counts.values.reduce(0.0) do |sum, count|
      p = count / len
      sum - (p * Math.log2(p))
    end
  end
end

# Scénario de test
scanner = SecretScannerSimulator.new(3.8)

# 1. Une chaîne de texte normal
scanner.analyze_string("Texte standard", "Ceci est une phrase de test tout a fait normale.")

# 2. Un mot de passe simple
scanner.analyze_string("Mot de passe faible", "password123")

# 3. Une clé API (Haute entropie)
scanner.analyze_string("Clé API Stripe", "sk_live_REDACTED_NOT_A_KEY")

# 4. Un hash SHA-256
scanner.analyze_string("Hash SHA-256", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

# Observation : Notez la différence de comportement entre le texte naturel 
# et les chaînes aléatoires. La détection de secrets repose sur ce gap.