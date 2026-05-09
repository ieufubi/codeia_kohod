program DNSFragmenter;

/*
 * Programme de test pour la fragmentation de données
 * Utile pour simuler le comportement de 'explore'
 */

uses
  System.SysUtils;

type
  TFragmenter = class
  public
    class function SplitData(const Data: string; MaxLen: Integer): TStringList;
  end;

class function TFragmenter.SplitData(const Data: string; MaxLen: Integer): TStringList;
var
  List: TStringList;
  i: Integer;
begin
  List := TStringList.Create;
  i := 0;
  while i < Length(Data) do
  begin
    if (i + MaxLen) > Length(Data) then
      List.Add(Copy(Data, i + 1, Length(Data) - i))
    else
      List.Add(Copy(Data, i + 1, MaxLen));
    Inc(i, MaxLen);
  end;
  Result := List;
end;

var
  Payload: string;
  Fragments: TStringList;
  S: string;
begin
  Payload := 'Ce_message_est_trop_long_pour_un_seul_label_dns_standard';
  Writeln('Original: ', Payload);
  
  // On simule une limite de 20 caractères par label
  Fragments := TFragmenter.SplitData(Payload, 20);
  
  try
    for S in Fragments do
      Writeln('Fragment: ', S);
  finally
    Fragments.Free;
  end;
  
  Writeln('Appuyez sur Entrée pour quitter...');
  Readln;
end.