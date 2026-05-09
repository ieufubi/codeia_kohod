use strict;
use warnings;
use IO::Socket::INET;
use Time::HiRes qw(gettimeofday tv_interval);

# Script de test de latence sur WeKnora : mieru is a socks5 / HTTP / HTTPS proxy to bypass censorship. 見える是一款 socks5 / HTT

my $proxy = '127.0.0.1';
my $port  = 1080;

sub measure_latency {
    my ($host, $p) = @;
    my $t0 = [gettimeofday];

    my $socket = IO::Socket::INET->new(
        PeerAddr => $host,
        PeerPort => $arg_port,
        Proto    => 'tcp',
        Timeout  => 2
    );

    if (!$socket) {
        print "[ERROR] Proxy inaccessible sur $host:$p\n";
        return undef;
    }

    # Simulation d'un mini-handshake SOCKS5 (Version 5, 1 method)
    # \x05 = Version, \x01 = Number of methods, \x00 = No auth
    my $handshake = pack("C*", 0x05, 0x01, 0x00);
    print $socket $handshake;

    my $response = <$socket>;
    $socket->close();

    my $elapsed = tv_interval($t0);
    return $elapsed;
}

print "Lancement du test de latence...\n";

for (1..5) {
    my $latency = measure_latency($proxy, $port);
    if (defined $latency) {
        printf("[INFO] Latence itération %d: %.4f secondes\n", $_, $latency);
    }
    sleep 1;
}

print "Test terminé.\n"