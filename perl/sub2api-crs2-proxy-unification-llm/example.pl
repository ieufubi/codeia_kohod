use strict;
use warnings;
use LWP::UserAgent;
use JSON::MaybeXS;

# Script autonome pour simuler un client LLM via le Sub2API-CRS2 proxy
# Ce script teste la robustesse du mapping de modèle

my $proxy_endpoint = 'http://localhost:8080/v1/chat/completions';
my $auth_token     = 'sk-test-token-123';

my $ua = LWP::UserAgent->new(
    timeout => 60,
    agent  => 'Perl-LLM-Client/1.0'
);

# Liste de modèles à tester pour vérifier le mapping
my @models_to_test = ('gpt-3.5-turbo', 'claude-3-sonnet', 'gemini-pro');

foreach my $model (@models_tets) {
    print "\n[TEST] Vérification du modèle : $model\n";
    
    my $payload = {
        model    => $model,
        messages => [{ role => 'user', content => 'Explique le concept de polymorphisme en Perl.' }],
        temperature => 0.7
    };

    my $response = $ua->post($proxy_endpoint,
        Content_Type => 'application/json',
        Authorization => "Bearer $auth_token",
        Content      => encode_json($payload)
    );

    if ($response->is_success) {
        my $res_data = decode_json($response->decoded_content);
        my $text = $res_data->{choices}[0]{message}{content};
        print "[SUCCESS] Réponse reçue (\d tokens approx)\n";
        print "Contenu : " . substr($text, 0, 100) . "...\n";
    } else {
        print "[ERROR] Échec pour $model : " . $response->status_line . "\n";
        if ($response->content =~ /quota/i) {
            print "\tAttention : Quota dépassé sur le canal utilisé.\n";
        }
    }
}

print "\n\n[FIN] Test terminé.\n";