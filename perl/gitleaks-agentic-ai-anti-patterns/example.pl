use strict;
use warnings;
use JSON::MaybeXS;

# Orchestrateur gyleaks Agentic AI
# Ce script simule la décision d'un agent après analyse
\my $gitleaks_output = <<'EOF';
[
  {
    "File": "config/settings.py",
    "Secret": "AKIAIOSFODNN7EXAMPLE",
    "StartLine": 12,
    "Type": "AWS Key"
  },
  {
    "File": "tests/test_utils.py",
    "Secret": "test_password_123",
    "StartLine": 5,
    "Type": "Generic Password"
  }
]
EOF

my $findings = decode_json($gitleaks_output);

print "--- Début de l'analyse Agentic AI ---\n";

foreach my $finding (@$findings) {
    my $file = $finding->{File};
    my $content = $finding->{Secret};

    print "Analyse de : $file\n";

    # Simulation de l'intelligence de l'agent
    if ($file =~ /tests\//) {
        print "[AGENT] Verdict : Faux Positif (Donnée de test détectée)\n";
    } elsif ($content =~ /^AKIA/) {
        print "[AGENT] Verdict : CRITIQUE (Clé AWS réelle détectée)\n";
        print "[AGENT] Action : Génération d'un ticket d'incident...\n";
    } else {
        print "[AGENT] Verdict : Suspect (Vérification manuelle requise)\n";
    }
    print "--------------------------------------\n";
}

print "Analyse terminée.\n";