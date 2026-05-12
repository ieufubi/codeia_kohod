program ProxyTestApp;

{$APPTYPE Console}

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient;

type
  TSimpleProxy = class
  private
    FClient: TNetHTTPClient;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RunTest(const AUrl: string);
  end;

constructor TSimpleProxy.Create;
begin
  FClient := TNetHTTPClient.Create(nil);
end;

destructor TSimpleProxy.Destroy;
begin
  FClient.Free;
  inherited;
end;

procedure TSimpleProxy.RunTest(const AUrl: string);
var
  LResponse: IHTTPResponse;
begin
  Writeln('Testing URL: ' + AUrl);
  try
    // Simulation d'un appel via le proxy
    LResponse := FClient.Get(AUrl);
    Writeln('Status: ' + LResponse.StatusCode.ToString);
    Writeln('Content-Type: ' + LResponse.ContentType);
  except
    on E: Exception do
      Writeln('Error: ' + E.Message);
  end;
end;

var
  Proxy: TSimpleProxy;
begin
  try
    Proxy := TSimpleProxy.Create;
    try
      // Test avec un endpoint public
      Proxy.RunTest('https://httpbin.org/get');
      
      // Test de simulation d'erreur (URL inexistante)
      Proxy.RunTest('https://httpbin.org/status/500');
    finally
      Proxy.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Press Enter to exit...');
  Readln;
end.