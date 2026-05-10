program CaddyAutomationDemo;

{$APPLIB: System.SysUtils, System.SysProcs}

// Simulation d'un outil de monitoring utilisant le concept de terminal Caddy AI
procedure MonitorSystem;
var
  CommandToRun: string;
begin
  // Dans un vrai scénario, ceci appellerait le binaire Caddy
  // Ici, nous simulons la transformation sémantique
  WriteLn('Analyse de l''intention utilisateur...');
  CommandToRun := 'df -h | grep "/dev/sda1"'; 
  
  WriteLn('Intention: "Vérifie l''espace disque sur la partition principale"');
  WriteLn('Commande générée par Caddy AI: ' + CommandToRun);
  
  // Simulation de l''exécution
  WriteLn('Résultat de l''exécution:');
  WriteLn('/dev/sda1       40G   22G   18G  50% /');
end;

begin
  try
    MonitorSystem;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Appuyez sur Entrée pour quitter...');
  Readln;
end.