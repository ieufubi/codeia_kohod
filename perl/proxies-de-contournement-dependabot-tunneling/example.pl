use strict;
use warnings;
use IO::Socket::INET;
use Time::HiRes qw(sleep);

# Script de test autonome pour simulateur de fragmentation
# Ce script simule l'envoi de données fragmentées via un canal fictif
\my $payload = "MESSAGE_CRITIQUE_DE_SECURITE_VERSION_1.0_DATA_STREAM";
my $max_fragment_size = 20;

print "--- Début de la simulation de fragmentation ---\n";
print "Payload original: $payload\n";
print "Taille totale: " . length($payload) . " octets\n\n";

my @fragments;
my $current_fragment = "";

# Découpage du payload en morceaux
for (my $i = 0; $i < length($payload); $i++) {
    my $char = substr($payload, $i, 1);
    $current_fragment .= $char;
    
    if (length($current_fragment) >= $max_fragment_size) {
        push @fragments, $current_fragment;
        print "Fragment généré: $current_fragment\n";
        $current_fragment = "";
    }
}

# Ajout du dernier morceau s'il reste des données
if (length($current_fragment) > 0) {
    push @fragments, $current_fragment;
    print "Fragment final: $current_fragment\n";
}

print "\nNombre total de fragments: " . scalar(@fragments) . "\n";

# Simulation de l'envoi avec délai aléatoire pour imiter le jitter
print "\n--- Simulation de l'envoi sur le réseau (Tunneling) ---\n";
foreach my $frag (@fragments) {
    # Simulation d'un délai de réseau
    my $delay = rand(0.5);
    sleep($delay);
    
    # On simule l'encapsulation DNS
    my $dns_query = $frag . ".tunnel.local";
    print "[SEND] DNS Query: $dns_query (Délai: " . sprintf("%.2f", $delay) . "s)\n";
}

print "\nSimulation terminée sans erreur.\n";