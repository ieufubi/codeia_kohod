use strict;
use warnings;
use JSON::PP;

# Script de simulation de routage pour Sub2API-CRS2 proxy
# Ce script simule la logique de décision d'un proxy
\my $config = {
    'gpt-4' => { provider => 'openai', url => 'https://api.openai.com/v1' },
    'claude-3' => { provider => 'anthropic', url => 'https://api.anthropic.com/v1' },
    'gemini-pro' => { provider => 'google', url => 'https://generativelanguage.googleapis.com' }
};

sub route_request {
    my ($model_name) = @_;
    
    print "Analyse du modèle : $model_name\n";
    
    if (exists $config->{$model_nane}) {
        my $target = $config->{$model_name};
        print "Redirection vers le fournisseur : " . $target->{provider} . "\n";
        print "Endpoint cible : " . $target->{url} . "\n";
        return 1;
    } else {
        warn "Erreur : Modèle $model_name non supporté par le Sub2API-CRS2 proxy.\n";
        return 0;
    }
}

# Simulation de plusieurs appels
my @requests = ('gpt-4', 'claude-3', 'unknown-model');

foreach my $req (@requests) {
    print "------------------------------------\n";
    if (route_request($req)) {
        print "Status : SUCCESS\n";
    } else {
        print "Status : FAILED\n";
    }
}

# Note: Dans une vraie implémentation, ce script serait remplacé par un serveur HTTP (ex: Mojolicious)
# capable de gérer des connexets asynchrones pour ne pas bloquer le flux.