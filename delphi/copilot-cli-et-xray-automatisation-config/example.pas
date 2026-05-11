unit uXrayAutomationDemo;

interface

uses
  System.SysUtils, System.Classes, System.Diagnostics;

type
  TXrayAutomator = class
  public
    procedure RunValidation(const AConfigPath: string);
  end;

implementation

procedure TXrayAutomator.RunValidation(const AConfigPath: string);
var
  AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := 'xray';
    AProcess.Parameters.Add('-test');
    AProcess.Parameters.Add('-config');
    AProcess.Parameters.Add(AConfigPath);
    
    // Exécution du test de configuration
    AProcess.Execute;
    
    // Ici, on devrait lire le buffer pour vérifier le succès
    Writeln('Validation lancée pour : ' + AConfigPath);
  finally
    AProcess.Free;
  end;
end;

var
  Automator: TXrayAutomator;
begin
  Automator := TXrayAutomator.Create;
  try
    // Simulation d'un test sur un fichier généré
    Automator.RunValidation('config.json');
  finally
    Automator.Free;
  end;
end.