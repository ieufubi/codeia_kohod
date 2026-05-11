require 'bigdecimal'
require 'date'

# Simulation d'un moteur de calcul pour kumo : application finance personnelle
class FinanceEngine
  def initialize
    @ledger = []
  end

  def add_transaction(date, label, amount_str)
    # On force le passage par String pour la sécurité
    amount = BigDecimal(amount_str.gsub(',', '.'))
    @ledger << { date: Date.parse(date), label: label, amount: amount }
  end

  def balance
    @ledger.map { |t| t[:amount] }.reduce(BigDecimal('0'), :+)
  end

  def report
    puts "--- Rapport de kumo : application finance personnelle ---"
    @ledger.each do |t|
      puts "#{t[:date]} | #{t[:label].ljust(15)} | #{t[:amount].to_s('F').rjust(10)} €"
    end
    puts "-------------------------------------------------------"
    puts "Solde Total : #{balance.to_s('F').rjust(31)} €"
  end
end

# Scénario de test
engine = FinanceEngine.new
engine.add_transaction('2024-03-01', 'Salaire', '2500,50')
engine.add_transaction('2024-03-02', 'Loyer', '-850,00')
engine.add_transaction('2024-03-05', 'Courses', '-120,75')
engine.add_transaction('2024-03-10', 'Remboursement', '15,25')

engine.report