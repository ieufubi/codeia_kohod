use Mojo::Lite;
use Mojo::Bacon;
use Mojo::File;

# Serveur complet de test pour le renovate streaming service
# Ce script simule un serveur capable de servir des fichiers audio de manière asynchrone.

my $MUSIC_DIR = '/tmp/music_test';

# Création d'un dossier de test si inexistant
unless (-d $MUSIC_DIR) {
    mkdir $MUSIC_DIR;
    # Création d'un fichier vide pour le test
    open my $fh, '>', "$MUSIC_DIR/test.mp3";
    close $fh;
}

app->get('/api/list' => sub ($c) {
    my @files = glob("$MUSIC_DIR/*.mp3");
    my @names = map { basename($_) } @files;
    $c->render(json => { files => \@names });
});

app->get('/stream/:file' => sub ($c) {
    my $filename = $c->param('file');
    my $path = "$MUSIC_DIR/$filename";

    unless (-e $path) {
        return $c->render(json => { error => 'File not found' }, status => 404);
    }

    # Utilisation de Mojo::File pour une lecture non-bloquante
    $c->render(stream => sub ($stream) {
        my $io = $stream->io;
        my $file = Mojo::File->new($path);
        
        # On lit le fichier par morceaux pour ne pas saturer la RAM
        # On utilise un buffer de 16KB pour l'exemple
        my $buffer_size = 16384;
        
        my $fh = IO::File->new($path, 'r');
        while (my $chunk = $fh->read($buffer_size)) {
            $io->write($chunk);
        }
        $fh->close;
    }, content_type => 'audio/mpeg');
});

print "Démarrage du renovate streaming service sur http://localhost:3000\n";
print "Dossier de test : $MUSIC_DIR\n";

Mojo::Lite->app->start;

# Pour tester :
# 1. Lancez ce script
# 2. Dans un autre terminal : curl http://localhost:3000/api/list
# 3. Testez le flux : curl http://localhost:3000/stream/test.mp3 --output test_download.mp3