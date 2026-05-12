use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);
use Net::UDP;

# Script de diagnostic de performance réseau
# Analyse la stabilité d'un flux Hysteria proxy

sub diagnostic_network {
    my ($target, $port) = @_;
    my @rtt_samples;
    my $iterations = 10;

    print "Démarrage du diagnostic sur $target:$port\n";
    print "Nombre d'échantillons : $iterations\n";

    for (1..$iterations) {
        my $udp = Net::UDP->new();
        my $start = [gettimeofday];
        
        eval {
            $udp->send($target, $port, "DATA_PROBE");
            my $res = $udp->recv(2);
            if ($res) {
                push @rtt_samples, tv_interval($start);
            }
        };
        
        if ($@) {
            warn "Échantillon $_ échoué : $@";
        }
        
        # Petit délai entre les probes pour éviter la saturation
        select(undef, undef, undef, 0.1);
    }

    if (@rtt_samples == 0) {
        die "Échec total du diagnostic. Le serveur est injoignable.\n";
    }

    my $avg_rtt = 0;
    $avg_rtt += $_ for @rtt_samples;
    $avg_rtt /= scalar @rtt_samples;

    my $max_rtt = 0;
    $max_rtt = $_ if $_ > $max_rtt for @rtt_samples;

    print "\n--- Résultats du Diagnostic ---\n";
    printf("RTT Moyen : %.4f s\n", $avg_rtt);
    printf("RTT Max   : %.4f s\n", $max_rtt);
    printf("Échantillons valides : %d/%d\n", scalar @rtt_samples, $iterations);
    
    my $jitter = $max_rtt - $avg_rtt;
    print "Gigue estimée : $jitter s\n";

    if ($jitter > 0.05) {
        print "ALERTE : Instabilité réseau détectée (Jitter élevé).\n";
    } else {
        print "Stabilité du flux : Excellente.\n";
    }
}

# Point d'entrée
my $host = shift @ARGV || '127.0.0.1';
my $port = shift @ARGV || 4433;

diagnostic_network($host, $port);