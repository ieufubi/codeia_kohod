program V2RayChaosTester;

{$APPTYPE console}

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient;

{ Programme autonome pour tester la latence via un proxy chaos }

procedure RunChaosTest(const AUrl: string; const AProxy: string; APort: Integer);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  LStart, LEnd: TDateTime;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    // Configuration du proxy pour simuler le passage par v2ray core chaos
    HTTP.ProxySettings.ProxyServer := AProxy;
    HTTP.ProxySettings.ProxyPort := APort;

    Writeln('Test de latence sur: ' + AUrl);
    Writeln('Via proxy: ' + AProxy + ':' + APort.ToString);
    Writeln('------------------------------------------');

    LStart := Now;
    try
      // Tentative de requête
      Response := HTTP.Get(AUrl);
      LEnd := Now;
      
      Writeln('Statut: ' + Response.StatusCode.ToString);
      Writeln('Temps de reponse: ' + FormatDateTime('ss.zzz', LEnd - LStart) + ' secondes');
    except
      on E: Exception do
        Writeln('Erreur detectee (le chaos a peut-etre coupe la connexion): ' + E.Message);
    end;
  finally
    HTTP.Free;
  end;
end;

begin
  try
    // Simulation d'un appel vers un service Kubernetes
    // Dans un vrai scenario, l'IP 10.96.0.5 serait un service interne
    RunChaosTest('http://httpbin.org/delay/1', '127.0.0.1', 1080);
    
    Writeln('------------------------------------------');
    Writeln('Fin du test.');
  except
    on E: Exception do
      Writeln('Erreur fatale: ' + E.Message);
  end;
end.