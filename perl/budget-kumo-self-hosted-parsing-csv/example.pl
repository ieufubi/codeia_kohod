use strict;
use warnings;
use feature 'say';
use Text::CSV_XS;

# Simulation d'un fichier CSV bancaire
my $csv_content = "Date;Libelle;Montant\n" . 
                  "15/01/2024;Courses Carrefour;-45.50\n" . 
                  "16/01/2024;Salaire;-2500.00";

sub process_finance_data {
    my ($data) = @_;
    my $csv = Text::CSV_XS->new({ sep_char => ';' });
    my $fh = do { local \$fh; open \$fh, '<', \$< => \$DATA or die \$!; \$fh };
    
    # Lecture de l'en-tête
    my $header = $csv->getline(\$fh);
    my %mapping;
    for my $i (0 .. $#$header) {
        $mapping{$header->[$i]} = $i;
    }

    print "\n--- Analyse du budget kumo self-hosted ---\n";
    
    while (my $row = $csv->getline(\$fh)) {
        my $date   = $row->[$mapping{'Date'}];
        my $label  = $row->[$mapping{'Libelle'}];
        my $amount = $row->[$mapping{'Montant'}];
        
        say sprintf("[%s] %-20s : %8.2f EUR", $date, $label, $amount);
    }
}

# On utilise le handle DATA pour la démo
process_finance_data(\$DATA);

__DATA__
15/01/2024;Courses Carrefour;-45.50
16/01/2024;Salaire;-2500.00