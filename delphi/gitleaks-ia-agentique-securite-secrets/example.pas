program GitleaksSimulatedScanner;

// Simulation d'un scanner de secrets pour illustrer le concept de gitleaks et IA agentique
// Ce programme ne remplace pas le vrai Gitleaks mais montre la logique de détection

uses
  SysUtils, Classes;

type
  TSecretPattern = record
    Pattern: string;
    Description: string;
  end;

var
  Patterns: array[0..1] of TSecretPattern;
  CurrentLine: string;
  i: Integer;
  Found: Boolean;
<br><br>function IsSecret(const AText: string): Boolean;<br>var<br>  p: Integer;<br>begin<br>  Result := False;<br>  for p := 0 to High(Patterns) do<br>  begin<br>    // Simulation d'une recherche de pattern simple (sans regex complexe pour l'exemple)<br>    if Pos(Patterns[p].Pattern, AText) > 0 then<br>    begin<br>      WriteLn('[ALERTE] Secret detecte: ', Patterns[p].Description);<br>      Result := True;<br>      Break;<br>    end;<br>  end;<br>end;<br><br>begin<br>  // Initialisation des patterns de détection<br>  Patterns[0].Pattern := 'AKIA'; // Format typique AWS Key<br>  Patterns[0].Description := 'AWS Access Key ID';<br>  Patterns[1].Pattern := 'sk_live_'; // Format typant Stripe<br>  Patterns[1].Description := 'Stripe Live Secret Key';<br><br>  WriteLn('--- Debut du scan de securite (Simulation) ---');<br>  <br>  // Simulation de lecture de lignes de code générées par une IA<br>  // Dans un vrai cas, on lirait le flux Git<br>  const<br>    Lines: array[0..2] of string = (<br>      'const API_KEY = "AKIA_EXAMPLE_12345";',<br>      'var stripe_token = "sk_live_51Mz... ";',<br>      'print("Hello World");'<br>    );<br><br>  for i := 0 to High(Lines) do<br>  begin<br>    CurrentLine := Lines[i];<br>    WriteLn('Analyse de la ligne: ', CurrentLine);<br>    if IsSecret(CurrentLine) then<br>      Found := True;<br>  end;<br><br>  if not Found then<br>    WriteLn('Scan termine: Aucun secret detecte.')<br>  else<br>    WriteLn('Scan termine: Attention, des secrets ont ete exposes !');<br><br>  WriteLn('--- Fin du scan ---');<br>  Readln;<br>end.