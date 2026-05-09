program LLMProxyTest;

{$APPTYPE Console}

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.JSON;

procedure RunTest;
var
  Client: TNetHTTPClient;
  Response: IHTTPResponse;
  RequestBody: TStringStream;
  JSONBody: TJSONObject;
begin
  Client := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;
  try
    // Configuration du corps de la requête pour Sub2API-CRS2
    JSONBody.AddPair('model', 'gpt-4o');
    JSONBody.AddPair('messages', TJSONArray.Create(
      TJSONObject.Create.AddPair('role', 'user').AddPair('content', 'Test de connexion Sub2API-CRS2')
    ));

    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);
    try
      Writeln('Envoi de la requête vers le proxy...');
      
      // Remplacez par votre URL réelle de Sub2API-CRS2
      Response := Client.Post('https://api.openai.com/v1/chat/completions', RequestBody, nil);

      Writeln('Code de statut : ' + Response.StatusCode.ToString);
      if Response.StatusCode = 200 then
      begin
        Writeln('Réponse reçue :');
        Writeln(Response.ContentAsString);
      end
      else
      begin
        Writeln('Erreur : ' + Response.StatusText);
      end;
    finally
      RequestBody.Free;
    end;
  finally
    JSONBody.Free;
    Client.Free;
  end;
end;

begin
  try
    RunTest;
  except
    on E: Exception do
      Writeln('Erreur fatale : ' + E.Message);
  end;
end.