use strict;
use warnings;
use HTTP::Tiny;
use JSON::MaybeXS;

# Simulation d'un client intelligent utilisant cc connect
# Ce script teste la disponibilité et la réponse d'un modèle spécifique

my $endpoint = 'http://localhost:8080/v1/chat/completions';
my $api_key = 'sk-votre-cle-cc-connect';

my $http = HTTP::Tiny->new(timeout => 60);

my $payload = {
    model => 'gpt-4o', # even if it's Claude, we use the mapping
    messages => [{ role => 'user', content => 'Explique le concept de monade en une phrase.' }]
};

print "Envoi de la requête vers cc connect...\n";

my $response = $http->post($endpoint, {
    headers => {
        'Authorization' => "Bearer $api_key",
        'Content-Type'  => 'application/json',
    },
    content => encode_json($payload),
});

if ($response->{success}) {
    my $data = decode_json($response->{content});
    my $answer = $data->{choices}[0]{message}{content};
    print "\nRéponse du modèle :\n$answer\n";
} else {
    die "Échec de la requête cc connect : $response->{status} ($response->{reason})\n";
}

# Note: Ce script nécessite que le service Sub2API soit actif localement.