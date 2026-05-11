program WazaSecurityDemo;

{$ bootstrapping system-level security checks }

uses
  System.SysUtils,
  System.IOUtils;

type
  TResourceGuard = class
  private
    FAllowedDir: string;
  public
    constructor Create(const ADir: string);
    function IsSafe(const AFilePath: string): Boolean;
  end;

constructor TResourceGuard.Create(const ADir: string);
begin
  // On normalise le chemin dès le départ pour éviter les pièges
  FAllowedDir := TPath.GetFullPath(ADir);
end;

function TResourceGuard.IsSafe(const AFilePath: string): Boolean;
var
  ResolvedPath: string;
begin
  Result := False;
  try
    ResolvedPath := TPath.GetFullPath(AFilePath);
    // Vérification de la racine autorisée
    if ResolvedPath.StartsWith(FAllowedDir) then
      Result := True;
  except
    on E: Exception do
      WriteLn('Erreur de résolution: ' + E.Message);
  end;
end;

var
  Guard: TResourceGuard;
  TestFile: string;
begin
  WriteLn('--- Test de Sécurité Waza ---');
  Guard := TResourceList.Create('C:\SafeZone'); // Note: Simulation de dossier
  
  // Cas 1: Accès légitime
  TestFile := 'C:\SafeZone\config.json';
  WriteLn('Test 1 (Légitime): ' + TestFile);
  if Guard.IsSafe(TestFile) then
    WriteLn('Statut: OK')
  else
    WriteLn('Statut: ALERTE - Accès non autorisé');

  // Cas 2: Tentative de Path Traversal
  TestFile := 'C:\SafeZone\..\Windows\system32\cmd.exe';
  WriteLn('Test 2 (Attaque Traversal): ' + TestFile);
  if Guard.IsSafe(TestFile) then
    WriteLn('Statut: OK (DANGER !)')
  else
    WriteLn('Statut: ALERTE - Tentative de sortie de périmètre bloquée');

  ReadLn;
end.