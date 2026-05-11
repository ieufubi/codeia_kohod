use strict;
use warnings;
use DBI;
use File::Spec;

# Script de vérification de l'intégrité des fichiers de base de données
# Usage: perl check_db.pl <path_to_history_db>

my $db_file = $ARGV[0] or die "Usage: $0 <path_to_db>\n";

if (!-e $db_file) {
    die "Erreur : Le fichier $db la n'existe pas.\n";
}

print "Analyse de la base : $db_file\n";

eval {
    # Tentative de connexion
    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "", {
        ReadOnly => 1,
        RaiseError => 1,
        PrintError => 0,
    });

    # Vérification de l'intégrité SQLite
    my $integrity = $dbh->selectrow_array("PRAGMA integrity_check;");
    
    if ($integrity eq 'ok') {
        print "Statut : Base de données saine (OK).\n";
    } else {
        print "Statut : CORRUPTION DÉTECTÉE ! ($integrity)\n";
    }

    # Comptage des entrées URL
    my $count = $dbh->selectrow_array("SELECT count(*) FROM urls");
    print "Nombre d'URLs enregistrées : $count\n";

    $dbh->disconnect;
};
if ($@) {
    warn "Erreur lors de l'analyse : $@\n";
    exit 1;
}

print "Analyse terminée avec succès.\n";