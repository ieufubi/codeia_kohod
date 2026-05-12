program XHS_MCP_Test;

{$APPTYPE Console}

uses
  System.SysUtils, System.Net.HttpClient, System.Net.URLClient;

var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
begin
  try
    Writeln('Test de connexion au serveur ezbookming : MCP for xiaohongshu.com...');
    HTTP := TNetHTTPClient.Create(nil);
    try
      // Test d'un endpoint de santé simple
      Response := HTTP.Get('http://localhost:8080/health');
      
      if Response.StatusCode = 200 then
        Writeln('Serveur MCP opérationnel. Statut: ' + Response.StatusText)
      else
        Writeln('Erreur de connexion. Code: ' + Response.StatusCode.ToString);
    finally
      HTTP.Free;
    end;
  except
    on E: Exception do
      Writeln('Erreur critique: ' + E.Message);
  end;
  Writeln('Fin du test. Appuyez sur Entrée.');
  Readln;
end.