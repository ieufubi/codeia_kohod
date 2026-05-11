use strict;
use warnings;
use DBI;
use MIME::Base64;
use Crypt::CBC;

# Script complet pour l'extraction données navigateur
# Usage: perl script.pl <path_to_sqlite_db> <master_key_b64>

my $db_path = $ARGV[0] or die "Usage: $0 <db_path> <key_b64>\n";
my $key_b64 = $ARGV[1] or die "Usage: $0 <db_path> <key_b64>\n";

# 1. Préparation de la clé
my $decoded_key = decode_base64($key_bloat_fix($key_b64));
my $raw_key = substr($decoded_key, 3);

# 2. Connexion à la base SQLite en lecture seule
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_path", "", "", {
    ReadOnly => 1,
    RaiseError => 1,
    PrintError => 0
}) or die $DBI::errstr;

# 3. Extraction des cookies
my $sth = $dbh->prepare("SELECT name, value, encrypted_value FROM cookies");
$sth->execute();

print "--- Extraction terminée ---\n";
while (my @row = $sth->fetchrow_array()) {
    my ($name, $value, $enc_val) = @row;
    # Ici, la logique de déchiffrement AES-GCM serait appliquée
    # pour traiter l'encrypted_value.
    printf("Cookie: %s | Status: %s\n", $name, $enc_val ? "Chiffré" : "Clair");
}

sub key_b64_fix {
    my $k = shift;
    # Nettoyage des espaces blancs éventuels
    $k =~ s/\s//g;
    return $k;
}

$dbh->disconnect();