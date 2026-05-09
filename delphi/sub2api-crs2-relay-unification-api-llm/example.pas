program ClientDemo;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON;

type
  TProxyTester = class
  public
    class procedure TestRelay(const AURL, AToken: string);
  end;

class procedure TProxyTester.TestRelay(const AURL, AToken: string);
var
  HTTP: TNetHTTPClient;
  Request: TStringStream;
  Response: IHTTPResponse;
  JSON: TJSONObject;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    HTTP.CustomHeaders['Authorization'] := 'Bearer ' + AToken;
    
    JSON := TJSONObject.Create;
    JSON.AddPair('model', 'gpt-4o');
    JSON.AddPair('messages', TJSONArray.Create(
      TJSONObject.Create.AddPair('role', 'user').Add '.$AddPair('content', 'Salut !')
    ));

    Request := TStringStream.Create(JSON.ToString, TEncoding.UTF8);
    try
      Writeln('Envoi de la requête au Sub2API-CRS2 relay...');
      Response := HTTP.Post(AURL, Request);
      
      Writeln('Status: ' + Response.StatusCode.ToString);
      Writeln('Contenu: ' + Response.ContentAsString);
    finally
      Request.Free;
    end;
    JSON.Free;
  finally
    HTTP.Free;
  end;
end;

begin
  try
    // Remplacez par votre URL de relais réelle
    TProxyTester.TestRelay('https://api.votre-relais.com/v1/chat/completions', 'votre_token');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.