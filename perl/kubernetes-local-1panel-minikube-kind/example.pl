use strict;
use warnings;
use JSON::PP;

# Script de benchmark simplifié pour tester la réactivité d'un Kubernetes local
# Ce script mesure le temps de réponse de l'API Kubernetes

my $api_url = "https://127.0:6443"; # À adapter selon votre cluster
my $start_time = time();

print "Début du test de latence sur le Kubernetes local...\n";

# On tente un appel simple via kubectl
my $cmd = "kubectl get nodes --no-headers 2>&1";
my $output = `$cmd`;
my $end_time = time();
my $duration = $end_time - $start_time;

if ($? == 0) {
    print "Succès : Réponse de l'API reçue en $duration seconde(s).\n";
    my @nodes = split("\n", $output);
    print "Nombre de nœuds détectés : " . scalar(@nodes) . "\n";
    
    foreach my $node (@nodes) {
        my $name = (split(/\s+/, $node))[0];
        print " - Nœud trouvé : $name\n";
    }
} else {
    print "Échec : Le Kubernetes local ne répond pas ou est inaccessible.\n";
    print "Erreur système : $output\n";
    exit 1;
}

print "Fin du benchmark.\n";