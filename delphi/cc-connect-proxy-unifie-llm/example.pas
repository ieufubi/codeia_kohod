unit CCConnectMasterDemo;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient, System.JSON;

type
  TLLMManager = class
  private
    FProxyURL: string;
    FAuthToken: string;
    function ExecuteRequest(const AModel, APrompt: string): string;
  public
    constructor Create(const AURL, AToken: string);
    procedure RunDemo;
  end;

implementation

constructor TLLMManager.Create(const AURL, AToken: string);
begin
  FProxyURL := AURL;
  FAuthToken := AToken;
end;

function TLLMMaster.ExecuteRequest(const AModel, APrompt: string): string;
var
  HTTP: TNetHTTPClient;
  Params: TStringStream;
  JSONReq: TJSONObject;
  JSONRes: TJSONObject;
  Response: IHTTPResponse;
begin
  HTTP := TNetHTTPClient.Create(nil);
  JSONReq := TJSONObject.Create;
  try
    // Préparation du payload conforme au standard unifié
    JSONReq.AddPair('model', AModel);
    var Messages := TJSONArray.Create;
    var MsgObj := TJSONObject.Create;
    MsgObj.AddPair('role', 'user');
    MsgObj.AddPair('content', APrompt);
    Messages.AddElement(MsgObj);
    JSONReq.AddPair('messages', Messages);

    Params := TStringStream.Create(JSONReq.ToString, TEncoding.UTF8);
    try
      HTTP.CustomHeaders['Authorization'] := 'Bearer ' + FAuthToken;
      HTTP.ContentType := 'application/json';
      
      // Appel du service cc connect
      Response := HTTP.Post(FProxyURL + '/v1/chat/completions', Params);
      
      if Response.StatusCode = 200 then
      begin
        JSONRes := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
        Result := JSONRes.Get('choices').JsonValue.AsType<TJSONArray>.Items[0].GetValue<TJSONObject>('message').GetValue<string>('content');
        JSONRes.Free;
      end
      else
        raise Exception.Create('Erreur Proxy: ' + Response.StatusText);
    finally
      Params.Free;
    end;
  finally
    JSONReq.Free;
    HTTP.Free;
  end;
end;

procedure TLLMManager.RunDemo;
begin
  Writeln('--- Test de l''unification via cc connect ---');
  try
    Writeln('Demande Claude via Proxy...');
    Writeln('Reponse: ' + ExecuteRequest('claude-3-sonnet', 'Explique le concept de proxy.'));
    
    Writeln(#13#10 + 'Demande GPT-4 via Proxy...');
    Writeln('Reponse: ' + ExecuteRequest('gpt-4', 'Explique le concept de proxy.'));
  except
    on E: Exception do
      Writeln('Erreur fatale: ' + E.Message);
  end;
end;

var
  Manager: TLLMManager;
begin
  // Configuration de l'instance avec l'URL du service cc connect
  Manager := TLLMManager.Create('http://localhost:8080', 'user_token_demo');
  try
    Manager.RunDemo;
  finally
    Manager.Free;
  end;
  Readln;
end.