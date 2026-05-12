#!/usr/bin/perl
# Générateur de template de configuration Xray Reality
# Utilise uniquement des modules standards pour la portabilité
use strict;
use warnings;

my $private_key = "VOTRE_CLE_PRIVEE";
my $dest_host = "www.microsoft.com:443";
my $short_id = "a1b2c3d4";

my $template = <<'EOF';
{
    "inbounds": [{
        "port": 443,
        "protocol": "vless",
        "settings": {
            "clients": [{"id": "UUID_A_GENERER", "flow": "xtls-rprx-vision"}],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "tcp",
            "security": "reality",
            "realitySettings": {
                "dest": "%s",
                "serverNames": ["%s"],
                "privateKey": "%s",
                "shortId": ["%s"]
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# Formatage du template avec les variables
my $config = sprintf($template, $dest_host, $dest_host, $private_key, $short_id);

print "--- CONFIGURATION GENEREE ---\n";
print $config;
print "--- FIN DE CONFIGURATION ---\n";

# Note: Pour un usage réel, utilisez un module comme Data::UUID pour l'ID client.