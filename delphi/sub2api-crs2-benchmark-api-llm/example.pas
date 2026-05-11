program LLM_Latency_Benchmark;

{$APPTYPE Console}

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Diagnostics;

type
  TBenchmarkResult = record
    AverageLatency: Double;
    TotalRequests: Integer;
    SuccessCount: Integer;
  end;

function RunBenchmark(const AURL: string; AIterations: Integer): TBenchmarkResult;
var
  HTTP: TNetHTTPClient;
  SWD: TStopwatch;
  I: Integer;
  LResponse: IHTTPResponse;
  TotalTime: Double;
  Successes: Integer;
begin
  Result.TotalRequests := AIterations;
  Result.SuccessCount := 0;
  TotalTime := 0;
  
  HTTP := TNetHTTPClient.Create(nil);
  SWD := TStopwatch.StartNew;
  
  try
    for I := 1 to AIterations do
    begin
      try
        SWD.Restart;
        // Simulation d'un appel vers le relais Sub2API-CRS2
        LResponse := HTTP.Get(AURL);
        
        if LResponse.StatusCode = 200 then
        begin
          Inc(Result.SuccessCount);
          TotalTime := TotalTime + SWD.Elapsed.TotalSeconds;
        end;
      except
        on E: Exception do
          Writeln('Erreur lors de la requête ' + I.ToString + ': ' + E.Message);
      end;
    end;
  finally
    HTTP.Free;
  end;

  if Result.SuccessCount > 0 then
    Result.AverageLatency := TotalTime / Result.SuccessCount
  else
    Result.AverageLatency := 0;
end;

var
  Res: TBenchmarkResult;
  TargetURL: string;
begin
  TargetURL := 'https://api.openai.com/v1/models'; // Exemple de test
  Writeln('Démarrage du benchmark sur : ' + TargetURL);
  Writeln('Nombre d iteration : 10');
  
  Res := RunBenchmark(TargetURL, 10);
  
  Writeln('--- RESULTATS ---');
  Writeln('Requetes reussies : ' + Res.SuccessCount.ToString);
  Writeln('Latence moyenne : ' + FormatFloat('0.000', Res.AverageLatency) + ' s');
  
  if Res.AverageLatency > 1.0 then
    Writeln('Attention : Latence trop elevee pour du temps reel.')
  else
    Writeln('Performance acceptable.');

  Readln;
end;