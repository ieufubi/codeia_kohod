use strict;
use warnings;
use Mojolicious::Lite;
use JSON::MaybeXS;
use Mojo::UserAgent;

# Ce script est un exemple autonome d'un proxy minimaliste.
# Il simule le comportement du Proxy API LLM CCX.

my $api_key = 'sk-dummy-key-12345';

app->on('startup', sub {
    print "Serveur Proxy API LLM CCX démarré sur http://localhost:3000\n";
});

post '/v1/chat/completions' => sub ($c) {
    my $payload = $c->req->json;
    return $c->render(json => {error => 'No payload'}, status => 400) unless $payload;

    my $model = $payload->{model} // 'unknown';
    print "[LOG] Requête pour le modèle: $model\n";

    # Simulation d'un appel vers un fournisseur (ex: OpenAI)
    # Dans un vrai proxy, on utiliserait Mojo::UserAgent vers l'API réelle.
    
    my $response_data = {
        id => 'chatcmpl-' . time,
        object => 'chat.completion',
        created => time,
        model => $model,
        choices => [{
            index => 0,
            message => {
                role => 'assistant',
                content => "Réponse simulée pour $model"
            },
            finish_reason => 'stop'
        }],
        usage => {
            prompt_tokens => 10,
            completion_tokens => 20,
            total_tokens => 30
        }
    };

    $c->render(json => $response_data);
};

app->start;

# Pour tester :
# 1. Installez Mojolicious: cpanm Mojolicious
# 2. Lancez: perl script.pl
# 3. Testez: curl -X POST http://localhost:3000/v1/chat/completions -H 'Content-Type: application/json' -d '{"model": "gpt-4"}'