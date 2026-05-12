program CCX_Proxy_Demo;

{$APPTYPE Console}

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.JSON;

type
  TCCXDemoClient = class
  private
    FHTTP: TNetHTTPClient;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ExecuteTest;
  end;

constructor TCCXDemoClient.Create;
begin
  FHTTP := TNetHTTPClient.Create;
end;

destructor TCCXDemoClient.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

procedure TCCXDemoClient.ExecuteTest;
var
  LResponse: IHTTPResponse;
  LPayload: TStringStream;
begin
  Writeln('--- Test CCX API Proxy Demo ---');
  LPayload := TStringStream.Create('{"prompt": "Hello World"}', TEncoding.UTF8);
  try
    // Simulation d'un appel vers un endpoint fictif
    Writeln('Envoi de la requête...');
    // Note: Cette URL est fictive pour la démonstration
    LResponse := FHTTP.Post('https://httpbin.org/post', LPayload);
    
    Writeln('Code Statut: ', LResponse.StatusCode);
    Writeln('Contenu reçu:');
    Writeln(LResponse.ContentAsString);
  finally
    LPayload.Free;
  end;
end;

var
  Client: TCCXDemoClient;
begin
  try
    Client := TCCXDemoClient.Create;
    try
      Client.ExecuteTest;
    finally
      Client.Free;
    end;
  except
    on E: Exception do
      Writeln('Erreur critique: ', E.Message);
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.