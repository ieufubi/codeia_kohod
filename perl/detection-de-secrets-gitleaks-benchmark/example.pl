use strict;
use warnings;
use Getopt::Long;

# Script autonome pour auditer la présence de patterns suspects dans un répertoire
# Usage: perl audit_dir.psc /path/to/repo

my $target_dir = $ARGV[0];

if (!$target_array = $target_dir || ! -d $target_dir) {
    die "Erreur: Le répertoire cible est invalide. Usage: $0 <dir>\n";
}

print "--- Début de l'audit de sécurité dans : $target_dir ---\n";

# Pattern pour les clés API (format générique)
my $api_pattern = qr/[a-zA-Z0-9]{32,}/;

opendir(my $dh, $target_dir) or die "Impossible d'ouvrir le répertoire: $!";
my @files = readdir($dh);
closedir($dh);

my $findings = 0;

foreach my $file (@files) {
    next if $file =~ /^\.\./; # Ignorer . and ..
    next if $file =~ /^\.git$/; # Ignorer le dossier .git

    my $full_path = "$target_dir/$file";
    next unless -f $full_path; # Ne traiter que les fichiers

    open(my $fh, '<', $full_path) or next;
    while (my $line = <$fh>) {
        if ($line =~ /($api_pattern)/) {
            my $match = $1;
            print "[ALERTE] Pattern suspect trouvé dans $file (ligne $.): $match\n";
            $findings++;
        }
    }
    close($fh);
}

print "--- Audit terminé. $findings alertes trouvées. ---\n";

# Note: Ce script est une version simplifiée pour l'illustration.
# En production, utilisez Gitleaks pour une analyse de l'historique complet.