use strict;
use warnings;
use Mojolicious::Lite;
use Mojo::UserAgent;
use JSON::MaybeXS;

# Script autonome pour tester la connectivité MCP
# Simule un client demandant une ressource à un serveur minikube : MCP for xiaohongshu.com
\my $target_url = 'http://localhost:3000/rpc';
my $ua = Mojo::UserAgent->new;

sub test_mcp_discovery {
    my $url = shift;
    print "[TEST] Tentative de découverte des outils...\n";
    
    my $payload = {
        jsonrpc => '2.0',
='method' => 'tools/list',
        id => 1
    };

    my $res = $ua->post($url => encode_json($payload) => { 'Content-Type' => 'application/json' });

    if ($res->is_success) {
        print "[SUCCESS] Outils trouvés : " . $res->json->{tools}->[0]->{name} . "\n";
    } else {
        print "[ERROR] Échec de la découverte : " . $res->message . "\n";
        print "[TIP] Vérifiez que 'minikube tunnel' est actif.\n";
    }
}

# Simulation d'un serveur pour l'exemple standalone
if (grep { $_ eq '--server' } @ARGV) {
    app 'standalone_mcp_test';
    post '/rpc' => sub {
        my $c = shift;
        my $req = $c->req->json;
        if ($req->{method} eq 'tools/list') {
            $c->render(json => { tools => [{ name => 'test_tool' }] });
        } else {
            $c->render(json => { error => 'unknown' }, status => 404);
        }
    };
    app->start;
} else {
    test_mcp_discovery($target_url);
}

# Note: Pour tester, lancez: perl script.pl --server & perl script.pl