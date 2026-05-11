use strict;
use warnings;
use JSON::PP;

# Script autonome pour simuler un audit de compétence
# Ce script simule la lecture de logs et génère une alerte

my $mock_log = <<'END_LOG';
{"timestamp": "2023-10-27T10:00:00", "skill": "calculator", "status": "success", "latency": 150}
{"timestamp": "2023-10-27T10:01:00", "skill": "calculator", "status": "failure", "latency": 2000}
{"timestamp": "2023-10-27T10:02:00", "skill": "calculator", "status": "success", "latency": 180}
END_LOG

my $success_count = 0;
my $fail_count = 0;
my $total_latency = 0;
my $count = 0;

open(my $fh, '<', \$<) or die "Erreur lecture log: $!"; # Note: using direct string for demo
# Pour l'exemple, on utilise la variable $mock_log

foreach my $line (split /\n/, $mock_log) {
    next unless $line =~ /^\{/; # Skip empty lines
    my $entry = decode_json($line);
    
    if ($entry->{status} eq 'success') {
        $success_count++;
    } else {
        $fail_count++;
    }
    
    $total_latency += $entry->{latency};
    $count++;
}

if ($count > 0) {
    my $accuracy = ($success_count / $count) * 100;
    my $avg_latency = $total_latency / $count;
    
    print "--- Résultat de l'audit de compétence ---\n";
    printf "Précision: %.2f%%\n", $accuracy;
    printf "Latence moyenne: %.2f ms\n", $avg_latency;
    
    if ($accuracy < 100) {
        print "ALERTE: Des échecs ont été détectés dans la gestion des compétences d'agents.\n";
    } else {
        print "Statut: Stable.\n";
    }
}

print "\nFin de l'audit.\n";