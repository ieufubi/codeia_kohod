use strict;
use warnings;
use IO::Socket::INET;

# Script de simulation de monitoring de bande passante pour le hub
# Ce script vérifie si le port du hub de modèles AI est accessible
\my $host = '127.0.0.1';
my $port = 8080;

print "Tentative de connexion au hub de modèles AI sur $host:$port...\n";

my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    Proto    => 'tcp',
    Timeout  => 5
);

if ($socket) {
    print "Succès : Le hub est opérationnel.\n";
    
    # Simulation d'une requête de statut
    print $socket "GET /api/v1/status HTTP/1.0\r\n\r\n";
    
    my $response = <$socket>;
    print "Réponse du serveur : $response";
    
    $socket->close();
} else {
    warn "Erreur : Impossible de contacter le hub de modèles AI : $!";
    exit 1;
}

# Note : Dans un vrai projet, on utiliserait LWP pour parser le contenu.
# Ce script est une preuve de concept minimaliste pour tester la connectivité.