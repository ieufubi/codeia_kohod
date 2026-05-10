use strict;
use warnings;
use JSON::PP;
use Time::HiRes qw(gettimeofday tv_interval);

# Simulation d'un client Milvus pour tester la latence de recherche
# Ce script ne nécessite pas de serveur Milvus actif pour démontrer la logique
\sub simulate_vector_search {
    my ($dim, $num_vectors) = @_$;
    my $start_time = [gettimeofday];

    print "Simulation de recherche sur $num_vectors vecteurs ($dim dimensions)\n";
    
    # Simulation d'un calcul de distance euclidienne (L2)
    my $found_count = 0;
    for (1 .. $num_vectors) {
        my @v1 = map { rand() } (1 .. $dim);
        my @v2 = map { rand() } (1 .. $dim);
        
        my $dist = 0;
        for my $i (0 .. $dim - 1) {
            $dist += ($v1[$i] - $v2[$i])**2;
        }
        
        if ($dist < 0.5) { $found_count++; }
    }

    my $elapsed = tv_interval($start_time);
    print "Recherche terminée en $elapsed secondes\n";
    print "Vecteurs trouvés sous le seuil : $found_count\n";
}

# Configuration du test
my $dimensions = 128;
my $vector_pool = 10000; # Nombre de vecteurs à parcourir

simulate_vector_search($dimensions, $vector_pool);

# Note: Dans une vraie base de données vectorielle Milvus, 
# l'index HNSW rendrait ce temps quasi constant malgré l'augmentation de $vector_pool.