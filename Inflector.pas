unit Inflector;

interface

type
  TIrregular = record
    Singular: string;
    Plural: string;
  end;

  TIrregulars = array of TIrregular;

  TPattern = record
    Pattern: string;
    Replacement: string;
  end;

  TPluralPattern = TPattern;

  TPluralPatterns = array of TPluralPattern;

  TSingularPattern = TPattern;

  TSingularPatterns = array of TSingularPattern;

  TInflector = class
  private
    class function GetIrregulars: TIrregulars;
    class function GetPluralPatterns: TPluralPatterns;
    class function GetSingularPatterns: TSingularPatterns;
    class function IrregularToPlural(const Word: string): string;
    class function IrregularToSingular(const Word: string): string;
    class function Uncountable(const Word: string): Boolean;
  public
    class function Camelize(const LowerCaseAndUnderscoredWord: string; const FirstLetterInUppercase: Boolean = True): string;
    class function Classify(const TableName: string): string;
    class function Pluralize(const Word: string): string;
    class function Singularize(const Word: string): string;
  end;

implementation

uses
  Classes,
  Delphinator,
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
  cameled := TDelphinator.FixReservedWords(cameled);
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
  Result := className;
end;

class function TInflector.GetIrregulars: TIrregulars;
var
  irregulars: TIrregulars;
begin
  SetLength(irregulars, 7);
  irregulars[0].Singular := 'person';
  irregulars[0].Plural := 'people';
  irregulars[1].Singular := 'man';
  irregulars[1].Plural := 'men';
  irregulars[2].Singular := 'child';
  irregulars[2].Plural := 'children';
  irregulars[3].Singular := 'sex';
  irregulars[3].Plural := 'sexes';
  irregulars[4].Singular := 'move';
  irregulars[4].Plural := 'moves';
  irregulars[5].Singular := 'cow';
  irregulars[5].Plural := 'kine';
  irregulars[6].Singular := 'zombie';
  irregulars[6].Plural := 'zombies';
  Result := irregulars;
end;

class function TInflector.GetPluralPatterns: TPluralPatterns;
var
  plurals: TPluralPatterns;
begin
  SetLength(plurals, 21);
  plurals[0].Pattern := '(.*)$';
  plurals[0].Replacement := '$1s';
  plurals[1].Pattern := '(.*)s$';
  plurals[1].Replacement := '$1s';
  plurals[2].Pattern := '(ax|test)is$';
  plurals[2].Replacement := '$1es';
  plurals[3].Pattern := '(octop|vir)us$';
  plurals[3].Replacement := '$1i';
  plurals[4].Pattern := '(octop|vir)i$';
  plurals[4].Replacement := '$1i';
  plurals[5].Pattern := '(alias|status)$';
  plurals[5].Replacement := '$1es';
  plurals[6].Pattern := '(bu)s$';
  plurals[6].Replacement := '$1ses';
  plurals[7].Pattern := '(buffal|tomat)o$';
  plurals[7].Replacement := '$1oes';
  plurals[8].Pattern := '([ti])um$';
  plurals[8].Replacement := '$1a';
  plurals[9].Pattern := '([ti])a$';
  plurals[9].Replacement := '$1a';
  plurals[10].Pattern := 'sis$';
  plurals[10].Replacement := 'ses';
  plurals[11].Pattern := '(?:([^f])fe|([lr])f)$';
  plurals[11].Replacement := '$1\2ves';
  plurals[12].Pattern := '(hive)$';
  plurals[12].Replacement := '$1s';
  plurals[13].Pattern := '([^aeiouy]|qu)y$';
  plurals[13].Replacement := '$1ies';
  plurals[14].Pattern := '(x|ch|ss|sh)$';
  plurals[14].Replacement := '$1es';
  plurals[15].Pattern := '(matr|vert|ind)(?:ix|ex)$';
  plurals[15].Replacement := '$1ices';
  plurals[16].Pattern := '([m|l])ouse$';
  plurals[16].Replacement := '$1ice';
  plurals[17].Pattern := '([m|l])ice$';
  plurals[17].Replacement := '$1ice';
  plurals[18].Pattern := '^(ox)$';
  plurals[18].Replacement := '$1en';
  plurals[19].Pattern := '^(oxen)$';
  plurals[19].Replacement := '$1';
  plurals[20].Pattern := '(quiz)$';
  plurals[20].Replacement := '$1zes';
  Result := plurals;
end;

class function TInflector.GetSingularPatterns: TSingularPatterns;
var
  singulars: TSingularPatterns;
begin
  SetLength(singulars, 25);
  singulars[0].Pattern := '(.*)s$';
  singulars[0].Replacement := '$1';
  singulars[1].Pattern := '(n)ews$';
  singulars[1].Replacement := '$1ews';
  singulars[2].Pattern := '([ti])a$';
  singulars[2].Replacement := '$1um';
  singulars[3].Pattern := '((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$';
  singulars[3].Replacement := '$1\2sis';
  singulars[4].Pattern := '(^analy)ses$';
  singulars[4].Replacement := '$1sis';
  singulars[5].Pattern := '([^f])ves$';
  singulars[5].Replacement := '$1fe';
  singulars[6].Pattern := '(hive)s$';
  singulars[6].Replacement := '$1';
  singulars[7].Pattern := '(tive)s$';
  singulars[7].Replacement := '$1';
  singulars[8].Pattern := '([lr])ves$';
  singulars[8].Replacement := '$1f';
  singulars[9].Pattern := '([^aeiouy]|qu)ies$';
  singulars[9].Replacement := '$1y';
  singulars[10].Pattern := '(s)eries$';
  singulars[10].Replacement := '$1eries';
  singulars[11].Pattern := '(m)ovies$';
  singulars[11].Replacement := '$1ovie';
  singulars[12].Pattern := '(x|ch|ss|sh)es$';
  singulars[12].Replacement := '$1';
  singulars[13].Pattern := '([m|l])ice$';
  singulars[13].Replacement := '$1ouse';
  singulars[14].Pattern := '(bus)es$';
  singulars[14].Replacement := '$1';
  singulars[15].Pattern := '(o)es$';
  singulars[15].Replacement := '$1';
  singulars[16].Pattern := '(shoe)s$';
  singulars[16].Replacement := '$1';
  singulars[17].Pattern := '(cris|ax|test)es$';
  singulars[17].Replacement := '$1is';
  singulars[18].Pattern := '(octop|vir)i$';
  singulars[18].Replacement := '$1us';
  singulars[19].Pattern := '(alias|status)es$';
  singulars[19].Replacement := '$1';
  singulars[20].Pattern := '^(ox)en';
  singulars[20].Replacement := '$1';
  singulars[21].Pattern := '(vert|ind)ices$';
  singulars[21].Replacement := '$1ex';
  singulars[22].Pattern := '(matr)ices$';
  singulars[22].Replacement := '$1ix';
  singulars[23].Pattern := '(quiz)zes$';
  singulars[23].Replacement := '$1';
  singulars[24].Pattern := '(database)s$';
  singulars[24].Replacement := '$1';
  Result := singulars;
end;

class function TInflector.IrregularToPlural(const Word: string): string;
var
  i: Integer;
  irregular: string;
  irregulars: TIrregulars;
begin
  irregulars := GetIrregulars;
  irregular := Word;
  for i := Low(irregulars) to High(irregulars) do
  begin
    if irregular = irregulars[i].Singular then
      irregular := irregulars[i].Plural;
  end;
  Result := irregular;
end;

class function TInflector.IrregularToSingular(const Word: string): string;
var
  i: Integer;
  irregular: string;
  irregulars: TIrregulars;
begin
  irregulars := GetIrregulars;
  irregular := Word;
  for i := Low(irregulars) to High(irregulars) do
  begin
    if irregular = irregulars[i].Plural then
      irregular := irregulars[i].Singular;
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
  plurals: TPluralPatterns;
begin
  plurals := GetPluralPatterns;
  pluralWord := Word;
  if (Not Uncountable(pluralWord)) then
  begin
    pluralWord := IrregularToPlural(pluralWord);
    if (pluralWord = Word) then
    for i := High(plurals) downto Low(plurals) do
    begin
      if TRegEx.Match(pluralWord, plurals[i].Pattern, [roIgnoreCase]).Success then
      begin
        pluralWord := TRegEx.Replace(pluralWord, plurals[i].Pattern, plurals[i].Replacement, [roIgnoreCase]);
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
  singulars: TSingularPatterns;
begin
  singulars := GetSingularPatterns;
  singularWord := Word;
  if (Not Uncountable(singularWord)) then
  begin
    singularWord := IrregularToSingular(singularWord);
    if (singularWord = Word) then
    for i := High(singulars) downto Low(singulars) do
    begin
      if TRegEx.Match(singularWord, singulars[i].Pattern, [roIgnoreCase]).Success then
      begin
        singularWord := TRegEx.Replace(singularWord, singulars[i].Pattern, singulars[i].Replacement, [roIgnoreCase]);
        Break;
      end;
    end;
  end;
  Result := singularWord;
end;

class function TInflector.Uncountable(const Word: string): Boolean;
var
  terms: TStringList;
begin
  terms := TStringList.Create;
  terms.Delimiter := ' ';
  terms.DelimitedText := 'equipment information rice money species series fish sheep jeans';
  Result := (terms.IndexOf(Word) > -1);
  terms.Free;
end;

end.
