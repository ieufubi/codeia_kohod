use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);

# Script de monitoring de latence post-injection
# Simule un client qui mesure le temps de réponse d'un service sous stress

sub measure_latency {
    my ($url, $proxy) = @;
    my $start = [gettimeofday];
    
    # Simulation d'un appel curl via le proxy v2ray core
    my $cmd = "curl -s -x $proxy $url -o /dev/null -w '%{time_total}\n'";
    my $output = `$cmd`;
    chomp($output);
    
    my $elapsed = tv_interval($start);
    return $output;
}

my $target_service = "http://api.payments.internal/health";
my $v2ray_proxy = "socks5h://localhost:1080";
my $iterations = 10;

print "Démarrage du monitoring de latence sur $target_service...\n";
print "Proxy utilisé: $v2ray_proxy\n";
print "--------------------------------------------------\n";

my $total_time = 0;
my $success_count = 0;

for (my $i = 1; $i <= $iterations; $i++) {
    my $latency = measure_latency($target_service, $v2ray_proxy);
    
    if ($latency =~ /^\d+(\.\d+)$/) {
        my $val = $1;
        printf("Itération %02d: Latence = %.4f s\n", $i, $val);
        $total_time += $val;
        $success_count++;
    } else {
        print "Itération $i: ÉCHEC (Service injoignable)\n";
    }
    
    # Petite pause entre les mesures
    sleep(1);
}

if ($success_count > 0) {
    my $avg = $total_time / $success_count;
    print "--------------------------------------------------\n";
    printf("Résultat final: Moyenne sur %d requêtes = %.4f s\n", $success_count, $avg);
} else {
    print "Erreur: Aucune donnée collectée.\n";
}

# Note: Ce script suppose que v2ray core est déjà en cours d'exécution en local avec le proxy 1080.