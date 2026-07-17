type
  TNLPContext = record
    DocumentID: string;
    OriginalText: TStringStream; 
    TokensList: TObjectList<string>;
    EntitiesFound: TDictionary<string, TDateTime>; 
  end;

// Simulation d'une tâche lourde et non bloquante (simule l'appel API)
function GetTokensAsync(const Text: string): TObjectList<string>;
var
  Tokens := TObjectList<string>.Create;
begin
  // Simuler une latence réseau de 50ms en arrière-plan.
  TThread.Sleep(50);
  try
    Tokens.Add('delphi');
    Tokens.Add('pipeline');
    Tokens.Add('maîtrisé');
    Tokens.Add('système');
  finally
    // Le cleanup doit être géré par le thread appelant si on ne veut pas de memory leak.
  end;
  Result := Tokens;
end;