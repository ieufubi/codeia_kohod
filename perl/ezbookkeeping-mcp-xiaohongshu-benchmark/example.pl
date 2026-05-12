use strict;
use warnings;
use Mojo::UserAgent;
use JSON::MaybeXS;

# Script autonome pour tester la connectivité à Xiaohongshu
# Usage: perl check_xhs.pl
\my $url = 'https://www.xiaohongshu.com';
my $ua = Mojo::UserAgent->new->agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');

print "Tentative de connexion à $url...\n";

my $tx = $ua->get($url);

if (my $res = $tx->result) {
    if ($res->is_success) {
        print "Succès ! Code HTTP: " . $res->code . "\n";
        print "Taille de la réponse: " . length($res->body) . " octets\n";
        
        # Vérification sommaire de la présence de données
        if ($res->body =~ /"xhs_data"/ || $res->body =~ /"initial_state"/) {
            print "Données structurelles détectées.\n";
        } else {
            print "Attention: Structure de page inconnue (possible changement de XHS).\n";
        }
    } else {
        print "Échec de la requête. Code: " . $res->code . "\n";
        print "Message: " . $res->message . "\n";
    }
} else {
    my $err = $tx->error;
    print "Erreur fatale: " . $err->message . "\n";
}

# Fin du test
print "Fin du processus.\n";