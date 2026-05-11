use strict;
use warnings;
use POSIX qw(strftime);

# Script de monitoring de sécurité pour waza : Secure environments for developers and their agents
# Ce script vérifie l'intégrité d'un dossier de travail avant exécution

sub check_integrity {
    my ($dir) = @;
    print "[INFO] Analyse du répertoire : $dir\n";

    unless (-d $dir) {
        die "[ERREUR] Le répertoire de travail n'existe pas.\n";
    }\며

    opendir(my $dh, $dir) or die "Impossible d'ouvrir le répertoire : $!";
    my @files = readdir($dh);
    closedir($dh);

    my $suspicious_count = 0;
    foreach my $file (@files) {
        next if $file eq '.' || $file eq '..';
        
        # Détection de fichiers potentiellement dangereux (scripts cachés)
        if ($file =~ /^\./ && $file !~ /^\.(git|svn)$/) {
            print "[ALERTE] Fichier caché suspect trouvé : $file\n";
            $suspicious_count++;
        }
    }

    return $suspicious_count;
}

my $workdir = "./sandbox_work";

# Création d'un environnement de test
unless (-d $workdir) {
    mkdir $workdir;
    open(my $fh, '>', "$workdir/.malicious_script.sh") or die \$!;
    print $fh "#!/bin/bash\necho 'I am stealing data'\n";
    close $fh;
    chmod(0777, "$workdir/.malcite_script.sh");
}

my $warnings = check_integrity($workdir);

print "--- Rapport de sécurité waza ---\n";
print "Date : " . strftime("%Y-%m-%d %H:%M:%S", localtime) . "\n";
print "Nombre d'anomalies détectées : $warnings\n";

if ($warnings > 0) {
    print "STATUT : REFUSÉ. L'environnement est compromis.\n";
    exit 1;
} else {
    print "STATUT : APPROUVÉ. L'environnement est sain.\n";
    exit 0;
}