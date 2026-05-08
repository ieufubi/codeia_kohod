use strict;\use warnings;
use Mojo::Base;
use Mojo::UserAgent;
use Mojo::JSON;
use Mojo::Cache;

# Simulation d'un système de quota et de proxy pour l'API agrégateur LLM

# Cache de simulation des quotas (simule Redis)
my $quota_store = Mojo::Cache->new();

# Limite de tokens par jour (pour la démo)
my $DAILY_LIMIT = 1000;

# Simule la vérification du quota (doit être atomique en prod)
sub check_quota(\%args) {
    my $provider = $args->{'provider'}; 
    my $token_cost = $args->{'cost'}; 
    
    # Simulation de l'atomicité
    my $current_used = $quota_store->get("quota:$provider") || 0;
    
    if ($current_used + $token_cost > $DAILY_LIMIT) {
        die "Quota dépassé pour $provider. Impossible d'appeler l'API agrégateur LLM." ;
    }
    
    # Mise à jour du quota (atomique dans un vrai Redis)
    $quota_store->set("quota:$provider", $current_used + $token_cost, ttl => 86400);
    return 1;
}

# Le corps du proxy
sub proxy_request(\%args) {
    my $prompt = $args->{'prompt'}; 
    my $provider = $args->{'provider'}; 
    my $cost = $args->{'cost'}; 

    # 1. Vérification des prérequis
    eval { check_quota({provider => $provider, cost => $cost}); };
    if ($@) { die "ERREUR DE QUOTA : $@"; }

    print "[Proxy] Requête reçue pour $provider. Quota OK.\n";
    
    # 2. Simulation de l'appel API
    my $url = "https://api.$provider.com/v1/chat/completions";
    my $ua = Mojo::UserAgent->new();
    
    # Le payload standardisé
    my $payload = Mojo::JSON->new->encode(
        model => "standard",
        messages => [ { role => "user", content => $prompt } ]
    );

    # Simulation de la requête asynchrone
    # En production, on gérerait le callback et les erreurs réseau ici
    print "[Proxy] Envoi de la requête à $provider... (Simulation réseau)\n";
    
    # Simulation de la réponse
    return "[Réponse standardisée de $provider] Traitement réussi pour le prompt : " . substr($prompt, 0, 30) . "...";
}

# Exemple d'exécution
try { 
    my $result = proxy_request({prompt => "Explication de Perl 5", provider => "openai", cost => 10});
    print "\n[SUCCÈS] " . $result . "\n";
    
    # Tentative de dépassement de quota
    print "\n--- Tentative de dépassement de quota ---\n";
    my $fail_result = proxy_request({prompt => "Trop de prompts", provider => "openai", cost => 1000});
} catch { 
    my ($@) = @_; 
    print "\n[ÉCHEC] " . $@ . "\n";
};