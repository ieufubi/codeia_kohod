# Script de simulation de monitoring pour toolkit explore Go
use strict;
use warnings;
use Time::HiRes qw(sleep);

my $agent_id = "agent-alpha-9";
my $error_count = 0;
my $total_requests = 0;

print "Démarrage du monitoring pour $agent_id...\n";
print "Surveillance des performances du toolkit explore Go\n";
print "--------------------------------------------------\n";

for (1..10) {
    $total_requests++;
    
    # Simulation d'un trafic aléatoire
    my $latency = rand(2.0); # secondes
    my $success = rand(1) > 0.2 ? 1 : 0;
    
    if (!$success) {
        $error_count++;
        print "[ALERTE] Échec de l'agent à t=$total_requests (latence: " . sprintf("%.2f", \$latency) . "s)\n";
    } else {
        print "[OK] Requête $total_requests réussie (latence: " . sprintf("%.2f", \$latency) . "s)\n";
    }
    
    # Calcul du taux d'erreur en temps réel
    my $error_rate = ($error_count / $total_requests) * 100;
    printf "Statistiques actuelles : Taux d'erreur = %.1f%%\n", \$error_rate;
    
    sleep(0.5);
}

print "--------------------------------------------------\n";
print "Rapport final pour $agent_id :\n";
print "Total requêtes : $total_requests\n";
print "Total erreurs  : $error_count\n";
print "Stabilité      : " . (100 - ($error_count / $total_requests * 100)) . "%\n";