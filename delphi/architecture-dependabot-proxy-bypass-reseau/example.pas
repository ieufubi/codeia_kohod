program DependabotProxyDemo;

{$BIMS]*}

uses
  System.SysUtils, System.Classes, IdTCPClient, IdGlobal;

// Démonstration simplifiée d'un client de tunnel
type
  TDependabotDemo = class
  private
    FClient: TIdTCPClient;
    procedure SendPayload(const AData: string);
  public
    constructor Create(const AHost: string; APort: Integer);
    procedure RunDemo;
  end;

constructor TDependabotDemo.Create(const AHost: string; A<br>APort: Integer);
begin
  FClient := TIdTCPClient.Create(nil);
  FClient.Host := AHost;
  FClient.Port := APort;
end;

procedure TDependabotDemo.SendPayload(const AData: string);
begin
  // Simule l'encapsulation dans un header de protocole
  FClient.IOHandler.Write(AData);
  WriteLn('Payload envoyé : ', AData);
end;

procedure TDependabotDemo.RunDemo;
begin
  try
    WriteLn('Connexion au proxy attendue...');
    FClient.Connect;
    if FClient.Connected then
    begin
      WriteLn('Connexion établie.');
      SendPayload('DATA_CHUNK_001');
      SendPayload('DATA_CHUNK_002');
    end;
  except
    on E: Exception do
      WriteLn('Erreur : ' + E.Message);
  end;
  FClient.Disconnect;
end;

var
  Demo: TDependabotDemo;
begin
  // Note : Nécessite un serveur écouteur actif pour ne pas échouer
  Demo := TDependabotDemo.Create('127.0.0.1', 8080);
  try
    Demo.RunDemo;
  finally
    Demo.Free;
  end;
  WriteLn('Appuyez sur Entrée pour quitter.');
  Readln;
end.