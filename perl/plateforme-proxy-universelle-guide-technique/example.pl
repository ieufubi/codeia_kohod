use Mojolicious::Lite;
use HTTP::Proxy::Backend;

# Plateforme proxy universelle - Implémentation robuste
# Ce script illustre un proxy capable de gérer le routing et le logging.

# Configuration des services
my $config = {
    routes => {
        '/users' => 'http://user-service:8080',
        '/orders' => 'http://order-service:8081',
        '/legacy' => 'http://old-system:9000'
    },
    timeout => 10
};

# Middleware de logging et transformation
app->helper(log_request => sub {
    my $c = shift;
    my $start = time;
    $c->stash('start_time', $start);
    $c->app->log->info("Request: " . $c->req->url->path);
});

# Route de dispatching
any '/api/*' => sub ( $c ) {
    $c->log_request;
    
    my $path = $c->req->url->path;
    my $target = undef;

    # Recherche de la correspondance dans la table de routage
    foreach my $pattern (keys %{$config->{routes}}) {
        if ($path =~ m{^$pattern}) {
            $target = $config->{routes}->{$pattern};
            last;
        }
    }

    if (!$target) {
        return $c->render(text => 'Not Found in Proxy Map', status => 404);
    }

    # Construction de l'URL de destination
    my $destination = $target . $path;
    
    # Exécution du proxying avec gestion de timeout
    $c->proxy($destination, { timeout => $config->{timeout} })
      ->on('finish', sub {
          my $duration = time - $c->stash('start_time');
          $c->app->log->info("Completed in ${duration}s");
      });
};

# Démarrage du serveur
app->start;

# Note: Pour tester, utilisez: perl proxy.pl daemon -l http://*:3000