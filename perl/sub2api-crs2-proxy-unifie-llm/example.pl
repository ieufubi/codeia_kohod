use strict;
use warnings;
use JSON::PP;
use Time::HiRes qw(gettimeofday tv_interval);

# Script de benchmark de latence pour Sub2API-CRS2
# Ce script mesure le temps de réponse du proxy pour différents modèles
\my @models = ('gpt-4-turbo', 'claude-3-opus', 'gemini-pro');
my $proxy_endpoint = 'http://localhost:8080/v1/chat/completions';
my $auth_token = 'sk-proxy-token-123';

print "Démarrage du benchmark Sub2API-CRS2...\n";
print "------------------------------------------\n";

foreach my $model (@models) {
    my $t0 = [gettimeofday];
    
    # Simulation de requête HTTP (remplacer par HTTP::Tiny en production)
    # Ici on simule la logique de traitement du proxy
    my $payload = {
        model => $model,
        messages => [{role => 'user', content => 'Hello'}]
    };
    
    # Simulation d'un délai réseau et de traitement
    my $delay = ($model eq 'claude-3-opus') ? 1.5 : 0.3;
    select(undef, undef, undef, $delay);
    
    my $elapsed = tv_interval($t0);
    
    printf("Modèle: %-15s | Latence simulée: %0.4f s\n", $model, $elapsed);
}

print "------------------------------------------\n";
print "Benchmark terminé.\n";

# Note: En situation réelle, utilisez LWP::UserAgent pour tester le vrai endpoint.
# Ce script illustre la structure de mesure de performance.