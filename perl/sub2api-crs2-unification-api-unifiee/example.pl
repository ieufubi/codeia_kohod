use strict;
use warnings;
use HTTP::Tiny;
use JSON::MaybeXS;

# Script de test de robustesse pour Sub2API-CRS2
# Ce script teste la connectivité et la validité du format de réponse

my $endpoint = 'http://localhost:8080/v1/chat/completions';
my $json_engine = JSON::MaybeXS->new(utf8 => 1);

sub run_test {
    my ($url) = @_;
    print "Test de connexion vers : $url\n";

    my $http = HTTP::Tiny->new(timeout => 5);
    my $payload = {
        model => 'gpt-3.5-turbo',
        messages => [{role => 'user', content => 'Test de charge'}]
    };

    my $response = $http->post($url, {
        body => $json_engine->encode($payload),
        headers => { 'Content-Type' => 'application/json' }
    });

    if ($response->{success}) {
        print "[OK] Réponse reçue avec le code $response->{status}\n";
        
        # Tentative de décodage du JSON
        eval {
            my $data = $json_engine->decode($response->{content});
            if (exists $data->{choices}) {
                print "[OK] Structure de réponse valide (choices trouvés).\n";
            } else {
                warn "[ERREUR] Structure JSON incorrecte : manque 'choices'.\n";
            }
        };
        if ($@) {
            warn "[ERREUR] Échec du décodage JSON : $@\n";
        }
    } else {
        print "[ECHEC] Impossible de contacter Sub2API-CRS2 : $response->{reason}\n";
    }
}

# Exécution du test
eval {
    run_test($endpoint);
};
if ($@) {
    die "Erreur fatale durant l'exécution du test : $@\n";
}

print "\nFin du test de robustesse.\n";