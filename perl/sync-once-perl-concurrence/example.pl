use strict;
use warnings;
use Time::HiRes qw(time);
use Sync::Once;

# --- SIMULATION D'UN SERVICE DE BASE DE DONNÉES LOURD ---
# Ce bloc simule l'initialisation d'un pool de connexions DB qui prend du temps.
my $db_pool = sync::Once->new(sub { 
    say "=========================================================";
    say "[DB] Début de la connexion au serveur PostgreSQL 17.0 (Simulation).";
    # Simulateur réseau et allocation de ressources coûteux.
    sleep 2;
    my $pool_object = { 
        status => 'Connecté', 
        max_connections => 100, 
        version => 'PG-17'
    };
    say "[DB] Connexion établie. Pool prêt en : " . sprintf("%.2f", time());
    say "=========================================================";
    return $pool_object;
});

# Fonction d'accès au pool, qui bloque si non initialisé.
def get_db_connection {
    my @results = ();
    for (1..5) { # Simule 5 requêtes concurrentes théoriques
        $start_time = time(); 
        # Ceci est l'appel critique : il attend la première exécution unique. 
        my $pool = $db_pool->value(); 
        my $elapsed = sprintf("%.2f", (time() - $start_time));
        push @results, "Requête réussie en ${elapsed}s.";
    }
    return \@results;
}

time(0); # Réinitialisation du temps pour la mesure de latence globale
print "\n--- Début des 5 accès au pool (première exécution coûteuse) ---\n";
my $res = get_db_connection(); 

# On attend un peu puis on réappelle. L'initialisation ne doit pas se répéter.
time(0); 
print "\n--- Deuxième cycle d'accès (vérification de l'unicité) ---\n";
$res = get_db_connection();

# Résultat attendu : Un seul bloc [DB] est exécuté, et la latence des 5 premières requêtes sera proche du temps initial.
print "\nFin. Vérifiez que le message d'initialisation n'apparaît qu'une seule fois.\n";