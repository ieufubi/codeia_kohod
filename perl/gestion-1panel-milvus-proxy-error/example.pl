use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

# Script de monitoring robuste pour services 1Panel
# Ce script vérifie la disponibilité d'un service via l'API et alerte en cas de coupure.

my $api_endpoint = 'http://127.0.0.1:8888/api/v1/container/status';
my $api_token    = 'votre_token_ici';
my $target_name  = 'milvus-standalone';

sub check_service_health {
    my ($url, $token, $name) = @_;
    my $http = HTTP::Tiny->new(timeout => 5);
    
    print "Tentative de vérification du service : $name...\n";
    
    my $response = $http->get($url, {
        headers => {
            'Authorization' => "Bearer $token",
            'Accept'        => 'application/json',
        }
    });

    if ($response->{success}) {
        my $json_content = decode_json($response->{content});
        my $found = 0;

        foreach my $container (@{$json_content->{data}}) {
            if ($container->{name} eq $arg_name) {
                $found = 1;
                if ($container->{status} eq 'running') {
                    print "[OK] Le conteneur $name est opérationnel.\n";
                } else {
                    print "[ALERTE] Le conteneur $name est dans l'état : $container->{status}\n";
                }
                last;
            }
        }
        print "[ERREUR] Service $name introuvable dans la liste des conteneurs.\n" unless $found;
    } else {
        print "[CRITIQUE] Impossible de contacter l'API 1Panel : $response->{reason}\n";
    }
}

# Note: Dans un vrai cas, $arg_name doit être passé proprement.
# Ici, on simule une exécution locale.
my $arg_name = $target_name; 
check_service_health($api_endpoint, $api_token, $target_name);

# Fin du script