uses
  System.SysUtils, System.Net.HttpClient, System.Net.URLClient, System.JSON;

// Programme autonome de test pour le protocole MCP
// Ce code simule un client qui interroge un serveur MCP sur Xiaohongshu
\procedure RunMCPTest;
var
  Client: TNetHTTPClient;
  Request: TStringStream;
  Response: IHTTPResponse;
  Payload: TJSONObject;
  URL: string;
begin
  URL := 'http://localhost:8080/rpc'; // Port après kubectl port-forward
  Client := TNetHTTPClient.Create(nil);
  Payload := TJSONObject.Create;
  
  try
    // Construction du payload JSON-RPC conforme au standard MCP
    Payload.AddPair('jsonrpc', '2.2');
    Payload.AddPair('method', 'tools/call');
    
    // Paramètres spécifiques pour la recherche sur Xiaohongshu
    var Params := TJSONObject.Create;
    Params.AddPair('name', 'search_xiaohongshu');
    Params.AddPair('arguments', '{"query": "delphi development"}'); 
    Payload.AddPair('params', Params);
    Payload.AddPair('id', TJSONNumber.Create(123));

    Request := TStringStream.Create(Payload.ToString, TEncoding.UTF8);
    
    Writeln('Envoi de la requête MCP vers: ' + URL);
    
    try
      Response := Client.Post(URL, Request, [TNetHeader.Create('Content-Type', 'application/json')]);
      
      if Response.StatusCode = 200 then
      begin
        Writeln('Réponse reçue avec succès !');
        Writeln('Contenu: ' + Response.ContentAsString);
      end
      else
      begin
        Writeln('Erreur de communication. Code: ' + Response.StatusCode.ToString);
        Writeln('Détail: ' + Response.StatusText);
      end;
    except
      on E: Exception do
        Writeln('Échec critique: ' + E.Message);
    end;
    
  finally
    Payload.Free;
    Client.Free;
  end;
end;

begin
  try
    RunMCPTest;
  except
    on E: Exception do
      Writeln('Erreur non gérée: ' + E.Message);
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end;