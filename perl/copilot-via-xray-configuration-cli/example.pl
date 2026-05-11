#!/usr/bin/perl
# Script de diagnostic complet pour la chaîne de proxy
# Usage: perl check_proxy.pl

use strict;
use warnings;
use LWP::UserAgent;
use JSON::PP;
use Socket;

my $target_host = 'api.github.com';
my $proxy_addr  = '127.0.0.1:10809'; # À adapter selon votre config Xray
my $proxy_type  = 'http';

print "--- Diagnostic de connectivité : $target_host ---\n";

# 1. Test de résolution DNS locale
my $resolved_ip = gethostbyname($target_host);
if ($resolved_ip) {
    print "[OK] Résolution DNS : $target_host -> $resolved_ip\n";
} else {
    print "[ERREUR] DNS échoué pour $target_host\n";
}

# 2. Test de connectivité via le proxy
my $ua = LWP::UserAgent->new;
$ua->proxy(['http', 'https'], "$proxy_type://$proxy_addr");
$ua->timeout(5);

print "[INFO] Test de requête HTTP via $proxy_type://$proxy_addr...\n";
my $url = "https://$target_host/zen";
my $response = $ua->get($url);

if ($response->is_success) {
    print "[OK] Réponse reçue : " . substr($response->decoded_content, 0, 50) . "...\n";
    print "[OK] Statut HTTP : " . $response->code . "\n";
} else {
    print "[ERREUR] Échec de la requête : " . $response->status_line . "\n";
    print "[CONSEIL] Vérifiez que Xray est lancé et que le port $proxy_addr est correct.\n";
}

print "--- Fin du diagnostic ---\n";