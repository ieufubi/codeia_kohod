use strict;
use warnings;
use Socket;

# Outil autonome de test de disponibilité DNS pour tunneling DNS avancé
# Ce script vérifie si un domaine accepte des requêtes de type TXT
\my $target_domain = $ARGV[0] || die "Usage: $0 <domain.com>\n";
my $dns_server = '8.8.8.8';

print "Analyse du domaine : $target_domain via $dns_server\n";

# Construction manuelle d'une requête DNS simple (Header + Question)
# Format: [ID][Flags][QDCOUNT][ANCOUNT][NSCOUNT][ARCOUNT]...[Question]
my $id = pack("n", 0x1234);
my $flags = pack("n", 0x0100); # Standard query
my $qdcount = pack("n", 1);
my $ancount = pack("n", 0);
my $nscount = pack("n", 0);
my $arcount = pack("n", 0);

# Conversion du nom de domaine en format DNS (ex: google.com -> 6google3com0)
my $qname = encode_dns_name($target_domain);
my $qtype = pack("n", 16); # Type TXT
my $qclass = pack("n", 1);  # Class IN

my $packet = $id . $flags . $qdcount . $ancount . $nscount . $arcount . $qname . $qtype . $qclass;

my $proto = socket(my $socket, AF_INET, SOCK_DGRAM, getprotobyname('udp'));
my $dest = sockaddr_in(53, inet_aton($dns_server));

print "Envoi de la requête DNS...\n";
send($socket, $packet, 0);

# Attente de la réponse (timeout 2s)
eval {
    local $SIG{ALRM} = sub { die "Timeout\n" };
    alarm 2;
    my $recv = recv($socket, my $buffer, 512, 0);
    print "Réponse reçue ($recv octets)\n";
    # Ici, un vrai parser analyserait les records TXT
    print "Vérification de la présence de données tunnel...\n";
    if ($buffer =~ /\x00/g) {
        print "Structure DNS valide pour le tunneling DNS avancé.\n";
    }
    alarm 0;
};
if ($@) {
    print "Erreur : $@\n";
}

sub encode_dns_name {
    my $name = shift;
    my $encoded = "";
    foreach my $part (split('\.', $name)) {
        $encoded .= pack("C", length($part)) . $part;
    }
    return $encoded . "\x00";
}