unit Inflector;

interface

type
  TInflector = class
  private
    class function Uncountable(const Word: string): Boolean;
  public
    class function Camelize(const LowerCaseAndUnderscoredWord: string; const FirstLetterInUppercase: Boolean = True): string;
    class function Pluralize(const Word: string): string;
  end;

implementation

uses
  Classes,
  Delphinator,
  RegularExpressions,
  SysUtils;

class function TInflector.Camelize(const LowerCaseAndUnderscoredWord: string; const FirstLetterInUppercase: Boolean = True): string;
var
  i: Integer;
  cameled: string;
  humps: TStringList;
begin
  humps := TStringList.Create;
  humps.Delimiter := '_';
  humps.DelimitedText := LowerCaseAndUnderscoredWord;
  for i := 0 to humps.Count - 1 do
    cameled := cameled + UpperCase(humps[i][1]) + Copy(humps[i], 2, MaxInt);
  cameled := TDelphinator.FixReservedWords(cameled);
  if (not FirstLetterInUppercase) then
    Result := LowerCase(cameled[1]) + Copy(cameled, 2, MaxInt)
  else
    Result := cameled;
end;

class function TInflector.Pluralize(const Word: string): string;
var
  regEx: TRegEx;
begin
  regEx := TRegEx.Create('/(matr|vert|ind)(?:ix|ex)$/i', [roIgnoreCase]);
  Result := regEx.Replace(Word, '\1ices');
end;

class function TInflector.Uncountable(const Word: string): Boolean;
var
  terms: TStringList;
begin
  terms := TStringList.Create;
  terms.Delimiter := ' ';
  terms.DelimitedText := 'equipment information rice money species series fish sheep jeans';
  Result := (terms.IndexOf(Word) = -1);
  terms.Free;
end;

end.
