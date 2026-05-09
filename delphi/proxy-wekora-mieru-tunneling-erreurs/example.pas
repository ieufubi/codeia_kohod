program SOCKS5ClientTest;

{$APPTYPE Console}

uses
  System.SysUtils,
  IdTCPClient,
  IdGlobal,
  IdBytes;

procedure RunTest;
var
  TCPClient: TIdTCPClient;
  Handshake: TBytes;
begin
  TCPClient := TIdTCPClient.Create(nil);
  try
    // Configuration vers le proxy local
    TCPClient.Host := '127.0.0.1';
    TCPClient.Port := 1080;
    TCPClient.ConnectTimeout := 5000;

    WriteLn('Tentative de connexion au Proxy WeKnora Mieru...');
    TCPClient.Connect;

    // 1. Handshake SOCKS5 (Version 5, No Auth)
    SetLength(Handshake, 3);
    Handshake[0] := 0x05; // SOCKS5
    Handshake[1] := 0x01; // 1 method
    Handshake[2] := 0x00; // No auth

    TCPClient.IOHandler.Write(Handshake);
    
    // 2. Lecture réponse
    if not TCPClient.IOHandler.ReadBytes(Handshake, 2) then
      raise Exception.Create('Erreur lecture handshake');

    if Handshake[0] <> 0x05 then
      raise Exception.Create('Le proxy ne supporte pas SOCKS5');

    WriteLn('Handshake réussi. Tunnel prêt.');

  except
    on E: Exception do
      WriteLn('Erreur critique : ' + E.Message);
  end;
  TCPClient.Free;
end;

begin
  try
    RunTest;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteStrLn('Appuyez sur Entrée pour quitter...');
  Readln;
end;