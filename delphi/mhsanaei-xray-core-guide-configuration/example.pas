program XrayConfigManager;

{$APPTYPE Console}

uses
  System.SysUtils;

// Programme autonome pour générer un fichier de config minimaliste
// Utile pour automatiser le déploiement sur VPS
\procedure GenerateMinimalConfig(const AFileName: string);
var
  ConfigContent: string;
  F: TextFile;
begin
  // Configuration brute pour le MHSanaei Xray core
  // On utilise le protocole VLESS avec Reality
  ConfigContent := '{ "inbounds": [ { "port": 443, "protocol": "vless", "settings": { "clients": [ { "id": "550e8400-e29b-41d4-a716-446655440000" } ], "decryption": "none" }, "streamSettings": { "network": "tcp", "security": "reality", "realitySettings": { "dest": "yahoo.com:443", "serverNames": [ "yahoo.com" ], "privateKey": "REMPLACER_PAR_CLE_PRIVEE", "shortIds": ["0123456789abcdef"] } } } ] }';

  AssignFile(F, AFileName);
  try
    Rewrite(F);
    Write(F, ConfigContent);
    Writeln('Configuration générée avec succès dans : ' + AFileName);
  finally
    CloseFile(F);
  end;
end;

begin
  try
    Writeln('--- MHSanaei Xray core Config Manager ---');
    GenerateMinimalConfig('xray_config.json');
    Writeln('Terminé.');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.