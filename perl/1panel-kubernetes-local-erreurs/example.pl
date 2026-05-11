#!/usr/bin/perl
use strict;
use warnings;

# Ce script vérifie la présence de processus critiques pour 1Panel Kubernetes local
# Il ne nécessite aucune dépendance externe, juste un environnement Linux standard.

my @critical_processes = ('k3s', 'docker', '1panel');
my $found_count = 0;

print "--- Scan des processus critiques pour 1Panel Kubernetes local ---\n";

foreach my $proc (@critical_processes) {
    # On cherche le processus dans la table ps
    my $check = `ps aux | grep $proc | grep -v grep`;
    
    if ($check) {
        print "[OK] Processus $proc est actif.\n";
        $found_count++;
    } else {
        print "[ERREUR] Processus $proc est manquant !\n";
    }
}

print "---------------------------------------------------------------\n";
print "Score de santé : $found_count/" . scalar(@critical_processes) . "\n";

if ($found_count < scalar(@critical_processes)) {
    print "Action requise : Redémarrez les services via 1Panel ou systemctl.\n";
    exit 1;
} else {
    print "Environnement prêt pour le développement.\n";
    exit 0;
}