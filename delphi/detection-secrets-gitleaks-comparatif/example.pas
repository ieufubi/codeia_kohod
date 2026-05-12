program SecretScannerDemo;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.RegularExpressions;

function CheckForSecrets(const AText: string): Boolean;
var
  LPattern: string;
  LRegex: TRegEx;
begin
  Result := False;
  // Pattern simulant une clé AWS
  LPattern := 'AKIA[0-9A-Z]{16}';
  LRegex := TRegEx.Create(LPattern, TRegExOptions.None);
  
  if LRegex.IsMatch(AText) then
  begin
    Writeln('ALERTE : Secret detecte dans le flux !');
    Result := True;
  end;
end;

var
  LContent: string;
begin
  try
    Writeln('--- Demo Detection de secrets ---');
    
    // Cas 1: Contenu sain
    LContent := 'var MyID: string = "12345";';
    Writeln('Test 1 (Sain): ', CheckForSecrets(LContent));

    // Cas 2: Contenu avec clé AWS
    LContent := 'const AWS_KEY = "AKIA_REDACTED_NOT_A_KEY";';
    Writeln('Test 2 (Danger): ', CheckForSecrets(LContent));

    Writeln('Fin du programme.');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.