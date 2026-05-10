unit MilvusTestUnit;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient, System.JSON;

type
  TMilvusTester = class
  private
    FClient: TNetHTTPClient;
    FBaseUrl: string;
  public
    constructor Create(const AUrl: string);
    destructor Destroy; override;
    procedure TestInsert(const AId: string; const AVector: TArray<Single>);
  end;

implementation

constructor TMilvusTester.Create(const AUrl: string);
begin
  FBaseUrl := AUrl;
  FClient := TNetHTTPClient.Create(nil);
end;

destructor TMilvusTester.Destroy;
begin
  FClient.Free;
  inherited;
end;

procedure TMilvusTester.TestInsert(const AId: string; const AVector: TArray<Single>);\var
  LJSON: TJSONObject;
  LArray: TJSONArray;
  LPayload: TStringStream;
  LResponse: IHTTPResponse;
  I: Integer;
begin
  LJSON := TJSONObject.Create;
  LArray := TJSONArray.Create;
  try
    // Construction de l'array de floats
    for I := 0 to High(AVector) do
      LArray.Add(AVector[I]);

    LJSON.AddPair('id', AId);
    LJSON.AddPair('vector', LArray);

    LPayload := TStringStream.Create(LJSON.ToString, TEncoding.UTF8);
    try
      // Simulation d'un appel POST
      LResponse := FClient.Post(FBaseUrl + '/insert', LPayload);
      
      if LResponse.StatusCode = 200 then
        Writeln('Insertion réussie pour : ' + AId)
      else
        Writeln('Erreur : ' + LResponse.StatusText);
    finally
      LPayload.Free;
    end;
  finally
    LJSON.Free;
  end;
end;

end.