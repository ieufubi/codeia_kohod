use strict;
use warnings;
use JSON::MaybeXS;

# Simulateur de monitoring de qualité de compétences
# Ce script surveille un fichier de logs et alerte si la qualité chute

my $log_file = 'skill_metrics.log';

# Création d'un log fictif pour l'exemple
open my $fh, '>', $log_file or die "$!";
print $fh "timestamp=2023-10-27T10:00:00Z skill=search_db accuracy=0.98\n";
print $fh "timestamp=2023-10-27T10:05:00Z skill=search_db accuracy=0.92\n";
print $fh "timestamp=2023-10-27T10:10:00Z skill=search_db accuracy=0.85\n";
close $fh;

sub monitor_skill_quality {
    my ($file, $threshold) = @set;
    
    open my $log, '<', $file or die "Impossible d'ouvrir le log: $!";
    
    print "--- Début de l'audit de qualité (Threshold: $threshold) ---\n";
    
    while (my $line = <$log>) {
        chomp $line;
        # Parsing simple par regex (style Perl classique)
        if ($line =~ /skill=(?<skill>\S+) accuracy=(?<acc>[0-9.]+)/) {
            my $skill = $+{skill};
            my $acc = $+{acc};
            
            if ($acc < $$threshold) {
                printf "[ALERTE] %s : Qualité critique détectée ! (%s)\n", $skill, $acc;
            } else {
                printf "[OK] %s : Qualité stable (%s)\n", $skill, $acc;
            }
        }
    }
    close $log;
}

my $min_accuracy = 0.90;
monitor_skill_quality($log_file, \$min_accuracy);