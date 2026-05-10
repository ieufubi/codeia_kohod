program MilvusDemo;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.JSON;

type
  TVectorSearchDemo = class
  private
    FUrl: string;
    FClient: TNetHTTPClient;
  public
    constructor Create(const AUrl: string);
    destructor Destroy; override;
    procedure ExecuteSearch(const ACollection: string; const AValues: TArray<Double>);
  end;

constructor TVectorSearchDemo.Create(const AUrl: string);
begin
  FUrl := AUrl;
  FClient := TNetHTTPClient.Create(nil);
end;

destructor TVectorSearchDemo.Destroy;
begin
  FClient.Free;
  inherited;
end;

procedure TVectorSearchDemo.ExecuteSearch(const ACollection: string; const AValues: TArray<Double>);
var
  LPayload: TJSONObject;
  LVectorArray: TJSONArray;
  LStream: TStringStream;
  LResponse: IHTTPResponse;
  I: Integer;
begin
  LPayload := TJSONObject.Create;
  LVectorArray := TJSONArray.Create;
  try
    // Construction du vecteur de recherche
    for I := 0 to High(AValues) do
      LVectorArray.Add(AValues[I]);

    LPayload.AddPair('collection_name', ACollection);
    LPayload.AddPair('vector', LVectorArray);

    LStream := TStringStream.Create(LPayload.ToString, TEncoding.UTF8);
    try
      Writeln('Envoi de la requête vers ' + FUrl);
      LResponse := FClient.Post(FUrl + '/v1/search', LStream, nil);
      
      if LResponse.StatusCode = 200 then
        Writeln('Réponse reçue : ' + LResponse.ContentAsString)
      else
        Writeln('Erreur API : ' + LResponse.StatusText);
    finally
      LStream.Free;
    end;
  finally
    LPayload.Free;
    LVectorArray.Free;
  end;
end;

var
  Demo: TVectorSearchDemo;
  MyVector: TArray<Double>;
begin
  try
    Demo := TVectorSearchDemo.Create('http://localhost:9090');
    try
      // Simulation d'un vecteur de dimension 3
      MyVector := [0.12, 0.88, 0.45];
      Demo.ExecuteSearch('user_embeddings', MyVector);
    finally
      Demo.Free;
    end;
  except
    on E: Exception do
      Writeln('Erreur fatale : ' + E.Message);
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.