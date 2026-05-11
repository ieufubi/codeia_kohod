program SivchariIntegrationDemo;

{$APPTYPE console}

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics;

{ Ce programme simule l'appel à la CLI sivchari et analyse le résultat }

procedure RunSivchariEval(const SkillName: string);
var
  Process: TProcess;
  Output: string;
begin
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'sivchari';
    Process.Parameters.Add('eval');
    Process.Parameters.Add('--skill');
    Process.Parameters.Add(SkillName);
    Process.CommandLine := 'sivchari eval --skill ' + SkillName;
    
    // Dans un vrai cas, on capturerait la sortie standard.
    // Ici, on simule un succès de commande.
    Writeln('Exécution de la commande : ' + Process.CommandLine);
    Writeln('Analyse des métriques en cours...');
    
    // Simulation de parsing JSON
    Writeln('-------------------------------------------');
    Writeln('Résultat pour ' + SkillName + ' :');
    Writeln('  - Precision: 92%');
    Writeln('  - Recall: 88%');
    Writeln('  - Status: PASSED');
    Writeln('-------------------------------------------');
    
  finally
    Process.Free;
  end;
end;

begin
  try
    Writeln('--- Demo Sivchari Integration (Delphi Perspective) ---');
    RunSivchariEval('text_summarizer');
    RunSivchariEval('code_reviewer');
    
    Writeln('Appuyez sur Entree pour quitter.');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.