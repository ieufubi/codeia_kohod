use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);

# Simulation d'un moteur de surveillance d'agents
# Ce script vérifie l'intégrité d'un environnement de sandbox

sub monitor_agent_activity {
    my ($agent_id) = @_;
    my $start_time = [gettimeofday];

    print "[INFO] Surveillance démarrée pour l'agent: $agent_id\n";

    # Simulation de processus de surveillance
    for (my $i = 1; $i <= 3; $i++) {
        sleep(1);
        my $risk_level = rand(100);
        
        printf("[%d] Analyse du trafic réseau... Score de risque: %.2f%%\n", $i, $risk_level);

        if ($risk_level > 85) {
            print "[ALERTE] Comportement suspect détecté sur l'agent $agent_id !\n";
            print "[ACTION] Isolation immédiate de l'environnement waza en cours...\n";
            return 0;
        }
    }

    my $elapsed = tv_interval($start_time);
    printf("[OK] Aucun incident détecté pour $agent_id. Temps de scan: %.2f s\n", $elapsed);
    return 1;
}

# Test du moniteur
my @agents = ('agent-python-3.12', 'agent-node-20', 'agent-go-1.22');

foreach my $id (@agents) {
    print "--------------------------------------------------\n";
    my $status = monitor_agent_activity($id);
    if (!$status) {
        print "[FATAL] L'agent $id a été mis en quarantaine.\n";
    }
}

print "--------------------------------------------------\n";
print "Fin du rapport de surveillance.\n";