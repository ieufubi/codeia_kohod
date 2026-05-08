use strict;
use warnings;
use IO::Socket::INET;

# Script autonome de simulation de télémétrie
# Ce script simule un flux de données brut vers un serveur
\my $server_ip = '127.0:0.0.1';
my $port      = 8084;
my $device_id = 'sensor-alpha-99';

print "Tentative de connexion à harness : Open device management sur $server_ip:$port...\n";

my $socket = IO::Socket::INET->new(
    PeerAddr => $server_ip,
    PeerPort => $port,
    Proto    => 'tcp',
    Timeout  => 5
);

if (!$socket) {
    warn "Impossible de contacter le contrôleur : $!";
    exit 1;
}

print "Connexion établie. Envoi des données de télémétrie...\n";

for (my $i = 0; $i < 5; $i++) {
    my $temp = 20 + rand(10); # Température aléatoire entre 20 et 30
    my $payload = sprintf("ID:%s|TEMP:%.2f|TS:%d\n", $device_id, $temp, time());
    
    print "Envoi : $payload";
    print $socket $payload;
    
    sleep 2; # Pause entre deux mesures
}

print "Fin de la session de télémétrie.\n";
$socket->close();