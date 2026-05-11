program CSVParserDemo;

{$APPTYPE Console}

uses
  System.SysUtils, System.Classes;

type
  TFinanceParser = class
  public
    procedure ProcessFile(const AFileName: string);
  end;

procedure TFinanceParser.ProcessFile(const AFileName: string);
var
  Lines: TStringList;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    if not FileExists(AFileName) then
    begin
      Writeln('Fichier introuvable.');
      Exit;
    end;

    Lines.LoadFromFile(AFileName);
    Writeln('Analyse de la gestion financière kumo...');

    for I := 0 to Lines.Count - 1 do
    begin
      try
        // Simulation de parsing simple
        Writeln('Traitement ligne ' + IntToStr(I + 1) + ': ' + Lines[I]);
      except
        on E: Exception do
          Writeln('Erreur ligne ' + IntToStr(I + 1) + ': ' + E.Message);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

var
  Parser: TFinanceParser;
begin
  Parser := TFinanceParser.Create;
  try
    // On suppose que test.csv existe avec du contenu
    Parser.ProcessFile('test.csv');
  finally
    Parser.Free;
  end;
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.