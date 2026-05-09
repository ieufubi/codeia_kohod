program RelayClientDemo;
$APPTYPE Console;

{ 
  Exemple de client Delphi pour interroger un Relais API LLM.
  Ce code illustre comment utiliser TNetHTTPClient pour envoyer un prompt.
}

uses
  System.SysUtils, System.Net.HttpClient, System.Net.URLClient, System.Classes;

procedure TestRelay(const AUrl, AToken: string);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  Payload: TStringStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  Payload := TStringStream.Create('{"model": "gpt-4o", "messages": [{"role": "user", "content": "Hello!"}]}', TEncoding.UTF8);
  try
    // Configuration des headers de sécurité du relais
    HTTP.CustomHeaders['Authorization'] := 'Bearer ' + AToken;
    HTTP.ContentType := 'application/json';

    Writeln('Envoi de la requête vers: ' + AUrl);
    
    try
      Response := HTTP.Post(AUrl + '/v1/chat/completions', Payload);
      
      Writeln('Code de statut: ' + Response.StatusCode.ToString);
      if Response.StatusCode = 200 then
        Writeln('Réponse du modèle: ' + Response.ContentAsString)
      else
        Writeln('Erreur du relais: ' + Response.ContentAsString);
    except
      on E: Exception do
        Writeln('Erreur réseau: ' + E.Message);
    end;
  finally
    Payload.Free;
    HTTP.Free;
  end;
end;

begin
  try
    // Remplacez par votre URL de relais et votre token généré
    TestRelay('http://localhost:8080', 'relay-key-789');
  except
    Writeln('Erreur fatale.');
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.