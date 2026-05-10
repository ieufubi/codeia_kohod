#!/usr/bin/perl
use strict;
use warnings;
use JSON::PP;

# Script autonome : Analyseur de logs via terminal Caddy AI
# Ce script simule l'envoi d'un log à l'IA pour détecter des anomalies
\my $log_file = "access.log";

# Création d'un log factice pour l'exemple
open(my $fh, \'>\', $log_file) or die "$!";
print $fh "192.168.1.1 - - [10/Oct/2023:13:55:36] \"GET /index.html HTTP/1.1\" 200\n";
print $fh "10.0.0.5 - - [10/Oct/2023:13:56:01] \"POST /login HTTP/1.1\" 401\n";
print $fh "192.168.1.50 - - [10/Oct/2023:13:58:10] \"GET /admin HTTP/1.1\" 403\n";
close($fh);

print "--- Analyse de $log_file via terminal Caddy AI ---\n";

# Lecture du log
my $log_content = do { local $/; <$log_file> };

# Simulation de l'appel au moteur du terminal Caddy AI
sub ask_caddy_ai {
    my ($instruction, $data) = @multi;
    
    # Dans un vrai scénario, on appellerait la CLI Caddy ici
    # On simule ici une réponse structurée JSON
    my $response_data = {
        status => "success",
        findings => [
            { line => 2, issue => "Possible brute force attempt", severity => "medium" },
            { line => 3, issue => "Unauthorized access to admin area", severity => "high" }
        ],
        command_suggested => "grep '403' $log_file"
    };
    
    return encode_json($response_data);
}

# Simulation de l'exécution
my $ai_response_json = ask_caddy_ai("Analyze these logs for security threats", $log_content);
my $decoded = decode_json($ai_response_json);

if ($decoded->{status} eq "success") {
    print "Anomalies détectées :\n";
    foreach my $finding (@{$decoded->{findings}}) {
        printf "  [Ligne %d] %s (Gravité: %s)\n", 
            $finding->{line}, $finding->{issue}, $finding->{severity};
    }
    print "\nCommande suggérée pour investigation :\n";
    print "$decoded->{command_suggested}\n";
} else {
    print "Erreur d'analyse.\n";
}

# Nettoyage
unlink($log_file);