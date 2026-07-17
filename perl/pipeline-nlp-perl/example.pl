use strict;
use warnings;
use feature 'say';
# Simulation d'un traitement de flux très volumineux (streaming)
timeout 10;
my $file = 'input_large.log'; # Supposons ce fichier existe et est énorme

# Utilisation du handle pour éviter la surcharge mémoire globale
my $fh = IO::Handle->new();
$fh->open($file);

say "--- Début Traitement Streaming ---";

while (my $line = <$fh>) {
    chomp $line;
    # Nettoyage initial et normalisation de l'encodage.
    # On s'assure que nous traitons du UTF-8 canonique.
    if ($line =~ /[\xef\xbb\xbf]/) { # Exemple : Détection d'un BOM restant
        $line =~ s/�//g; 
    }
    
    # 1. Tokenisation (simple pour l'exemple autonome)
    my @tokens = split(/[[:space:]]+/, $line);

    # 2. Analyse : On cherche des patterns spécifiques de logs.
    foreach my $token (@tokens) {
        if ($token =~ /ERROR/i && length($token) > 5) { 
            say qq{ALERT: Événement critique détecté sur le token: