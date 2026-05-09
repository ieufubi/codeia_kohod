program ModelHubTest;

{$I Interfaces.inc}
{$I Overload.inc}

uses
  System.SysUtils, 
  System.Net.HttpClient, 
  System.Net.URLClient;

// Programme autonome pour tester la connectivité au hub de modèles AI

procedure TestHubConnection(const AUrl: string);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    WriteLn('Tentative de connexion au hub de modèles AI : ' + AUrl);
    try
      // Test d'un endpoint de santé simple
      Response := HTTP.Get(AUrl + '/health');
      
      if Response.StatusCode = 200 then
        WriteLn('Statut : Connecté. Le hub est opérationnel.')
      else
        WriteLn('Statut : Erreur ' + Response.StatusCode.ToString + '. Le hub ne répond pas normalement.');
    except
      on E: Exception do
        WriteLn('Erreur critique : ' + E.Message);
    end;
  finally
    HTTP.Free;
  end;
end;

begin
  try
    // Remplacez par l'URL réelle de votre instance fsnotify
    TestHubConnection('http://localhost:8080');
  except
    on E: Exception do
      WriteLn('Erreur système : ' + E.Message);
  end;
  
  WriteLn('Appuyez sur Entrée pour quitter...');
  Readln;
end.