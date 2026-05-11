program K8sMonitorApp;

{$APPTYPE Console}

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient;

// Application de monitoring simple pour 1Panel Kubernetes local

procedure MonitorCluster;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  URL: string;
begin
  URL := 'http://localhost:8888/api/v1/status'; // URL par défaut de 1Panel
  HTTP := TNetHTTPClient.Create;
  try
    Writeln('--- Monitor K8s Local (1Panel) ---');
    try
      Response := HTTP.Get(URL);
      Writeln('Statut API : ' + Response.StatusCode.ToString);
      if Response.StatusCode = 200 then
        Writeln('Le service est disponible.')
      else
        Writeln('Le service répond avec une erreur.');
    except
      on E: Exception do
        Writeln('Erreur de connexion : ' + E.Message);
    end;
  finally
    HTTP.Free;
  end;
end;

begin
  try
    MonitorCluster;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.