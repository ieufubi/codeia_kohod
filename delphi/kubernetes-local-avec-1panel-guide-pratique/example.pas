program KubernetesMonitor;

// Programme autonome pour surveiller la santé d'un service K8s
// Ce code simule un agent de monitoring simple

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient;

type
  TMonitorResult = record
    IsAlive: Boolean;
    LatencyMs: Int64;
    Message: string;
  end;

function CheckServiceHealth(const AUrl: string): TMonitorResult;
var
  HTTP: TNetHTTPClient;
  LStart: TDateTime;
  LEnd: TDateTime;
begin
  Result.IsAlive := False;
  HTTP := TNetHTTPClient.Create(nil);
  try
    try
      LStart := Now;
      HTTP.Get(AUrl);
      LEnd := Now;
      Result.IsAlive := True;
      Result.LatencyMs := Round((LEnd - LStart) * 86400 * 1000);
      Result.Message := 'Réponse reçue avec succès';
    except
    on E: Exception do
    begin
      Result.IsAlive := False;
      Result.Message := E.Message;
    end;
    end;
  finally
    HTTP.Free;
  end;
end;

var
  MonitorResult: TMonitorResult;
  TargetURL: string;
begin
  TargetURL := 'http://localhost:8080'; // URL de votre service K8s
  Writeln('Démarrage de la surveillance sur : ' + TargetURL);
  
  repeat
    MonitorResult := CheckServiceHealth(TargetURL);
    
    if MonitorResult.IsAlive then
      Writeln('[OK] Latence: ' + MonitorResult.LatencyMs.ToString + 'ms')
    else
      Writeln('[ERREUR] ' + MonitorResult.Message);
      
    Sleep(5000); // Attendre 5 secondes entre chaque test
  until False;
end.