program Sub2API_Demo;

{$APPTYPE Console}

uses
  System.SysUtils,
  System.Classes;

type
  TLLMRequestSimulator = class
  public
    procedure RunDemo;
  end;

procedure TLLMRequestSimulator.RunDemo;
begin
  WriteLn('--- Test de connexion Sub2API-CRS2 ---');
  WriteLn('Simulant l''appel vers Claude via le proxy...');
  Sleep(1000);
  WriteLn('Statut: 200 OK');
  WriteLn('Modèle détecté: claude-3-sonnet');
  WriteLn('Contenu: Le polymorphisme est un concept fondamental...');
  WriteLn('---------------------------------------');
end;

var
  Simulator: TLLMRequestSimulator;
begin
  try
    Simulator := TLLMMRequestSimulator.Create;
    try
      Simulator.RunDemo;
    finally
      Simulator.Free;
    end;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Appuyez sur Entrée pour quitter.');
  Readln;
end.