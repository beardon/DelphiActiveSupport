unit Inflector;

interface

type
  TInflector = class
  private
    class function IrregularToPlural(const Word: string): string;
    class function IrregularToSingular(const Word: string): string;
    class function Uncountable(const Word: string): Boolean;
  public
    class function Camelize(const LowerCaseAndUnderscoredWord: string; const FirstLetterInUppercase: Boolean = True): string;
    class function Classify(const TableName: string): string;
    class function Memberify(const FieldName: string): string;
    class function Pluralize(const Word: string): string;
    class function Singularize(const Word: string): string;
  end;

implementation

uses
  Classes,
  Delphinator,
  Inflectors,
  RegularExpressions,
  SysUtils;

{**
 * By default, Camelize converts strings to UpperCamelCase. If the argument to FirstLetterInUppercase is set to False then Camelize produces lowerCamelCase.
 *
 * @param string LowerCaseAndUnderscoredWord
 * @param Boolean FirstLetterInUppercase
 * @return string
 *}
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
  if (not FirstLetterInUppercase) then
    Result := LowerCase(cameled[1]) + Copy(cameled, 2, MaxInt)
  else
    Result := cameled;
end;

{**
 * Create a class name from a plural table name like Rails does for table names to models. Note that this returns a string and not a Class.
 *
 * @param string TableName
 * @return string
 *}
class function TInflector.Classify(const TableName: string): string;
var
  className: string;
begin
  className := Camelize(TableName);
  className := Singularize(className);
  className := TDelphinator.FixReservedWords(className);
  Result := className;
end;

{**
 * Create a class member name from a field name.
 *
 * @param string FieldName
 * @return string
 *}
class function TInflector.Memberify(const FieldName: string): string;
var
  memberName: string;
begin
  memberName := Camelize(FieldName);
  memberName := TDelphinator.FixReservedWords(memberName);
  Result := memberName;
end;

class function TInflector.IrregularToPlural(const Word: string): string;
var
  i: Integer;
  irregular: string;
begin
  irregular := Word;
  for i := High(INFLECTOR_IRREGULARS) downto Low(INFLECTOR_IRREGULARS) do
  begin
    if irregular = INFLECTOR_IRREGULARS[i, 0] then
    begin
      irregular := INFLECTOR_IRREGULARS[i, 1];
      Break;
    end;
  end;
  Result := irregular;
end;

class function TInflector.IrregularToSingular(const Word: string): string;
var
  i: Integer;
  irregular: string;
begin
  irregular := Word;
  for i := Low(INFLECTOR_IRREGULARS) to High(INFLECTOR_IRREGULARS) do
  begin
    if irregular = INFLECTOR_IRREGULARS[i, 1] then
    begin
      irregular := INFLECTOR_IRREGULARS[i, 0];
      Break;
    end;
  end;
  Result := irregular;
end;

{**
 * Returns the plural form of the word in the string.
 *
 * @param string Word
 * @return string
 *}
class function TInflector.Pluralize(const Word: string): string;
var
  i: Integer;
  pluralWord: string;
  pat, repl: string;
begin
  pluralWord := Word;
  if (Not Uncountable(pluralWord)) then
  begin
    pluralWord := IrregularToPlural(pluralWord);
    if (pluralWord = Word) then
    for i := High(INFLECTOR_PLURALS) downto Low(INFLECTOR_PLURALS) do
    begin
      pat := INFLECTOR_PLURALS[i, 0];
      repl := INFLECTOR_PLURALS[i, 1];
      if TRegEx.Match(pluralWord, pat, [roIgnoreCase]).Success then
      begin
        pluralWord := TRegEx.Replace(pluralWord, pat, repl, [roIgnoreCase]);
        break;
      end;
    end;
  end;
  Result := pluralWord;
end;

{**
 * The reverse of Pluralize, returns the singular form of a word in a string.
 *
 * @param string Word
 * @return string
 *}
class function TInflector.Singularize(const Word: string): string;
var
  i: Integer;
  singularWord: string;
begin
  singularWord := Word;
  if (Not Uncountable(singularWord)) then
  begin
    singularWord := IrregularToSingular(singularWord);
    if (singularWord = Word) then
    for i := High(INFLECTOR_SINGULARS) downto Low(INFLECTOR_SINGULARS) do
    begin
      if TRegEx.Match(singularWord, INFLECTOR_SINGULARS[i, 0], [roIgnoreCase]).Success then
      begin
        singularWord := TRegEx.Replace(singularWord, INFLECTOR_SINGULARS[i, 0], INFLECTOR_SINGULARS[i, 1], [roIgnoreCase]);
        Break;
      end;
    end;
  end;
  Result := singularWord;
end;

class function TInflector.Uncountable(const Word: string): Boolean;
var
  found: Boolean;
  i: Integer;
begin
  found := False;
  for i := High(INFLECTOR_UNCOUNTABLE) downto Low(INFLECTOR_UNCOUNTABLE) do
  begin
    if (Word = INFLECTOR_UNCOUNTABLE[i]) then
    begin
      found := True;
      Break;
    end;
  end;
  Result := found;
end;

end.
