type
  TLLMResult = record
    Prompt: string;
    ResponseText: string;
    CostUSD: Double;
    ModelUsed: string;
  end;

// Cette unité simule l'interaction complète avec le mcp toolbox : Sub2API-CRS2
procedure RunLLMIntegrationDemo(const ProxyURL: string); var
  JsonPayload: TJSONObject;
  ResultJSON: string;
  ResultData: TLLMResult;
begin
  Writeln('--- Démarrage de l''appel via Proxy ---\n');

  // 1. Préparation du payload standardisé
  JsonPayload := TJSONObject.Create;
  JsonPayload.AddPair('prompt', 'Explique l''impact du passage de VCL à FMX dans Delphi.');
  JsonPayload.AddPair('max_tokens', 250);
  
  // 2. Appel au proxy (Simulation de l'appel réseau)
  // Dans un vrai scénario, on utiliserait TNetHttpClient.Post ici.
  // Le proxy est censé gérer l'authentification et le routing.
  ResultJSON := '{"usage": {"prompt_tokens": 45,"completion_tokens": 120}, "text": "Le passage à FMX a permis de moderniser l''interface..."}';
  
  // 3. Traitement de la réponse
  // On simule ici la lecture des données.
  
  // Simulation de l'extraction des métadonnées et du coût
  ResultData.ResponseText := 'Le passage à FMX a permis de moderniser l''interface...';
  ResultData.ModelUsed := 'Claude 3.5'; // Le proxy a choisi le meilleur modèle
  
  // Calcul du coût (Utilisation de la fonction de coût de l'exemple précédent)
  var Usage := TJSONObject.ParseJSONValue(ResultJSON) as TJSONObject
  var UsageObj := Usage.GetValue('usage') as TJSONObject
  ResultData.CostUSD := (Double(StrToIntDef(UsageObj.GetValue('prompt_tokens').ToString, 0) + StrToIntDef(UsageObj.GetValue('completion_tokens').ToString, 0)) / 1000.0) * 0.001;
  
  // 4. Affichage des résultats
  Writeln('------------------------------------------');
  Writeln('Statut de l''appel : SUCCÈS');
  Writeln('Modèle utilisé : ' + ResultData.ModelUsed);
  Writeln(Format('Réponse reçue : %s', [Copy(ResultData.ResponseText, 1, 50) + '...']));
  Writeln(Format('Coût unitaire estimé : %.4f $', [ResultData.CostUSD]));
  Writeln('------------------------------------------');

  // Nettoyage
  JsonPayload.Free;
  Usage.Free;
end

begin
  RunLLMIntegrationDemo('http://proxy.sub2api.com/v1/chat');
end