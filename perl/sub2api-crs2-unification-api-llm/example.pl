use strict;
use warnings;
use LWP::UserAgent;
use JSON::MaybeXS;

# Script de simulation de charge pour tester la robustesse du relais
# Ce script simule un copilot swe agent envoyant des requêtes en boucle

my $relay_url = 'http://localhost:808lement/v1/chat/completions';
my $api_key = 'sk-test-key';
my $iterations = 10;

my $ua = LWP::UserAgent->new;
$ua->timeout(10);

print "Démarrage du test de charge sur le relais...\n";

for (my $i = 1; $i <= $iterations; $i++) {
    my $payload = {
        model => 'gpt-3.5-turbo',
        messages => [{ role => 'user', content => "Test numéro $i" }]
    };

    my $response = $ua->post($relay_url,
        Content_Type => 'application/json',
        Content => encode_json($payload),
        'Authorization' => "Bearer $api_key"
    );

    if ($response->is_success) {
        print "Requête $i : SUCCESS\n";
    } else {
        print "Requête $i : FAILED ($response->status_line)\n";
    }
    
    # Petite pause pour ne pas saturer le processeur (comme un vrai agent)
    sleep(1);
}

print "Test terminé.\n";