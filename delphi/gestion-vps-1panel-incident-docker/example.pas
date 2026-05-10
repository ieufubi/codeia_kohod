program Monitor1Panel;

{$ Borland {$B-}\ }
{$ Boole {$B- }

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Classes;

procedure RunMonitor;
var
  Client: TNetHTTPClient;
  Response: IHTTPResponse;
  URL: string;
begin
  URL := 'http://127.0.0.1:8888/api/status'; // Exemple local
  Client := TNetHTTPClient.Create(nil);
  try
    WriteLn('Démarrage du monitoring de la gestion VPS 1Panel...');
    try
      Response := Client.Get(URL);
      WriteLn('Code de réponse : ' + Response.StatusCode.ToString);
      if Response.StatusCode = 200 then
        WriteLn('Le service est opérationnel.')
      else
        WriteLn('Alerte : Le service renvoie une erreur.');
    except
      on E: Exception do
        WriteLn('Erreur critique : ' + E.Message);
    end;
  finally
    Client.Free;
  end;
end;

begin
  try
    RunMonitor;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Appuyez sur Entrée pour quitter...');
  Readln;
end.