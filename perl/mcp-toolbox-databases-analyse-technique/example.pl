use strict;
use warnings;
use JSON::MaybeXS;

# Script d'exemple : Simulation d'un client MCP interrogeant un serveur
# Ce script démontre comment un client doit formater ses requêtes.
\my $server_input = IO::File->new("<", "/dev/stdin"); # Simulation stdin
my $json = JSON::MaybeXS->new(utf8 => 1);

sub simulate_client_request {
    my ($method, $params) = @_[0, 1];
    
    my $payload = {
        jsonrpc => "2.0",
        method  => $method,
        params  => $params,
        id      => int(rand(1000))
    };

    print "[CLIENT] Envoi de la requête: $method\n";
    return $json->encode($payload);
}

# 1. Demande de liste des outils
my $list_req = simulate_client_request('tools/list', {});
print "[CLIENT] Payload: $list_req\n\n";

# 2. Simulation de la réponse du serveur (on simule le serveur ici)
my $server_response = {
    jsonrpc => "2.0",
    result  => {
        tools => [{
            name => 'query_sql',
            description => 'Exécute du SQL'
        }]
    },
    id => 1
};
print "[SERVER] Réponse reçue: " . $json->encode($server_response) . "\n\n";

# 3. Appel d'un outil spécifique
my $call_req = simulate_client_request('tools/call', {
    name => 'query_sql',
    arguments => { sql => "SELECT 1" }
});
print "[CLIENT] Payload: $call_req\n";

# 4. Simulation de l'exécution
my $exec_response = {
    jsonrpc => "2.0",
    result  => {
        content => [{ type => 'text', text => 'Success: 1' }]
    },
    id => 2
};
print "[SERVER] Réponse reçue: " . $json->encode($exec_response) . "\n";

print "\n[FIN] Simulation terminée avec succès.\n";