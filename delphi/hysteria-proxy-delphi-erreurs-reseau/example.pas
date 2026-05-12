program HysteriaBufferMonitor;

{$APPTYPE Console}

uses
  System.SysUtils, System.Classes;

type
  TUDPBufferManager = class
  private
    FBuffer: TBytes;
    FMaxCapacity: Integer;
  public
    constructor Create(AMaxCap: Integer);
    procedure ProcessPacket(const AData: TBytes);
    property MaxCapacity: Integer read FMaxCapacity;
  end;

constructor TUDPBufferManager.Create(AMaxCap: Integer);
begin
  FMaxCapacity := AMaxCap;
  SetLength(FBuffer, AMaxCap);
end;

procedure TUDPBufferManager.ProcessPacket(const AData: TBytes);
var
  i: Integer;
begin
  // Vérification de la taille pour éviter le débordement de buffer
  if Length(AData) > FMaxCapacity then
  begin
    Writeln('Alerte: Paquet trop grand pour le buffer pré-alloué!');
    Exit;
  end;

  // Copie sécurisée dans le buffer circulaire (simplifié ici)
  for i := 0 to Length(AData) - 1 do
  begin
    FBuffer[i] := AData[i];
  end;
  
  Writeln('Paquet de ' + IntToStr(Length(AData)) + ' octets traité.');
end;

var
  Manager: TUDPBufferManager;
  IncomingData: TBytes;
begin
  try
    Manager := TUDPBufferManager.Create(1024);
    
    // Simulation d'un paquet reçu via Hysteria proxy
    IncomingData := TBytes.Create($01, $02, $03, $04, $05);
    
    Writeln('Démarrage du monitoring UDP...');
    Manager.ProcessPacket(IncomingData);
    
    // Simulation d'un paquet corrompu (trop grand)
    SetLength(IncomingData, 2048);
    Manager.ProcessPacket(IncomingData);

  except
    on E: Exception do
      Writeln('Erreur critique: ' + E.Message);
  end;
  WriteStr('Appuyez sur Entrée pour quitter...');
  Readln;
end.