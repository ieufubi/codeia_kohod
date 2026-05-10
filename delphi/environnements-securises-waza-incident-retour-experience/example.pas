program WazaSecurityTest;

{$MODE Delphiscript}

uses
  SysUtils;

// Simulation d'un moteur de vérification de sécurité
procedure VerifySecurityPolicy(const ACommand: string);
var
  IsAllowed: Boolean;
begin
  IsAllowed := True;
  
  // Simulation de la détection d'un appel dangereux
  if Pos('docker', ACommand) > 0 then
  begin
    WriteLn('[ALERTE] Tentative d''accès au socket Docker détectée !');
    IsAllowed := False;
  end;

  if IsAllowed then
    WriteLn('[OK] Commande autorisée par les environnements sécurisés waza.')
  else
    WriteLn('[ERREUR] Commande bloquée par le filtre eBPF.');
end;

var
  CommandToRun: string;
begin
  WriteLn('--- Testeur de Politique de Sécurité Waza ---');
  
  // Cas 1: Commande légitime
  CommandToRun := 'ls -la /tmp';
  WriteLn('Test 1: ' + CommandToRun);
  VerifySecurityPolicy(CommandToRun);
  
  WriteLn('');

  // Cas 2: Commande malveillante
  CommandToRun := 'docker run --privileged alpine';
  WriteLn('Test 2: ' + CommandToRun);
  VerifySecurityPolicy(CommandToRun);
  
  WriteLn('');
  WriteLn('Fin du test de sécurité.');
end.