#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket::INET;
# Script autonome simulant un proxy minimal pour l'apprentissage.

my $BACKEND_HOST = '127.0.0.1'; # Adapter au backend réel
my $BACKEND_PORT = 8080; 

print "--- Démarrage du Proxy Kernel ---\n";

# Simuler la connexion client (ici, STDIN est le 'client')
my $client_sock = IO::Socket::INET->new(
    PeerAddr => '127.0.0.1',
    PeerPort => 9000,
) or die "Cannot connect to simulated client: $@";

# Connecter au backend (la vraie cible)
my $backend_sock = IO::Socket::INET->new(
    PeerAddr => $BACKEND_HOST,
    PeerPort => $BACKEND_PORT,
    Proto    => 'tcp' 
) or die "Cannot connect to backend: $@";

# Écriture des headers de simulation au client (simule l'envoi d'une requête POST)
print $client_sock->fileno(), "POST /test HTTP/1.1\r\n"; # Méthode et chemin
print $client_sock->fileno(), "Host: backend-service.local\r\n"; 
print $client_sock->fileno(), "Content-Length: 0\r\n";  # Pas de corps ici
print $client_sock->fileno(), "Connection: Keep-Alive\r\n"; # Important pour le streaming
print $client_sock->fileno(), "X-Client-ID: test-script\r\n"; 
print $client_sock->fileno(), "Content-Type: application/json\r\n";
print $client_sock->fileno(), "\r\n"; # Double CRLF pour terminer les headers
STDOUT->flush();

# Le cœur du transfert : lecture et écriture simultanées (Conceptuel)
my $transfer_done = 0;
while (!$transfer_done) {
    select(undef, undef, undef, 0.1); # Attendre sur les deux sockets pendant 0.1s
    
    # Si le client a des données à envoyer (Simulation de lecture)
    if (IO::Select::can($client_sock)) { 
        my $data = <$client_sock>;
        print $backend_sock->fileno(), $data; # Écho direct au backend
        sysout("Transfert : " . length($data) . " octets reçus du client\r\n");
    }
    # Si le backend a des données à envoyer (Simulation de lecture)
    elsif (IO::Select::can($backend_sock)) { 
        my $response = <$backend_sock>;
        print $client_sock->fileno(), $response; # Écho direct au client
        sysout("Transfert : " . length($response) . " octets reçus du backend\r\n");
    }
    # Ici, on devrait gérer les erreurs de déconnexion ou timeouts.
} 

print "--- Transfert terminé ---\n";
close($client_sock);
close($backend_sock);