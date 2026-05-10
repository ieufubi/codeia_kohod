unit UProxyTester;

interface

uses
  System.SysUtils, System.Classes, IdTCPClient, IdGlobal;

type
  TWeKnoraTester = class
  private
    FClient: TIdTCPClient;
    procedure ExecuteHandshake;
  public
    constructor Create;
    destructor Destroy; override;
    procedure TestConnection(const AHost: string; APort: Integer);
  end;

implementation

constructor TWeKnoraTester.Create;
begin
  FClient := TIdTCPClient.Create(nil);
  FClient.ConnectTimeout := 5000;
  FClient.ReadTimeout := 5000;
end;

destructor TWeKnoraTester.Destroy;
begin
  FClient.Free;
  inherited;
end;

procedure TWeKnoraTester.ExecuteHandshake;
var
  LHandshake: TBytes;
begin
  // Phase 1: Negotiation (Version 5, 1 method)
  LHandshake := [5, 1, 0];
  FClient.IOHandler.WriteBytes(LHandshake);
  
  // Phase 2: Check response (Must be 0x00 for No Auth)
  FClient.IOHandler.ReadBytes(LHandshake, 1);
  if LHandshake[0] <> 0 then
    raise Exception.Create('Auth method not supported by proxy');
end;

procedure TWeKnoraTester.TestConnection(const AHost: string; APort: Integer);
begin
  try
    FClient.Host := '127.0.0.1'; // On se connecte au proxy lui-même
    FClient.Port := 1080;
    FClient.Connect;
    
    ExecuteHandshake;
    
    // Phase 3: SOCKS5 Connect Command
    // [Ver, Cmd, Rsv, ATYP, AddrType, Addr, Port]
    // ATYP 0x03 = Domain Name
    FClient.IOHandler.Write(Byte(5));
    FClient.IOHandler.Write(Byte(1)); // CMD Connect
    FClient.IOHandler.Write(Byte(0)); // Reserved
    FClient.IOHandler.Write(Byte(3)); // ATYP Domain
    
    // Write domain name length and name
    FClient.IOHandler.Write(Byte(Length(AHost)));
    FClient.IOHandler.Write(AHost);
    
    // Write Port (Big Endian)
    FClient.IOHandler.Write(Word(APort));
    
    Writeln('Request sent for: ', AHost);
    Writeln('Waiting for proxy response...');
    
    // Check response
    FClient.IOHandler.ReadBytes(LHandshake, 1);
    if LHandshake[0] = 0 then
      Writeln('Success: Tunnel established.')
    else
      Writeln('Error: Proxy rejected connection.');
      
  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;
  FClient.Disconnect;
end;

end.