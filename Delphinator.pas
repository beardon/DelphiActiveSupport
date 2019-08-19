unit Delphinator;

interface

type
  TDelphinator = class
  private
    class function GetMySQLTypePrecision(const SQLType: string): Integer;
    class function GetMySQLTypeScale(const SQLType: string): Integer;
  public
    class function ConcatLongString(const InStr: string; const Multiline: Boolean): string;
    class function IsMySQLTypeBoolean(const SQLType: string): Boolean;
    class function FixReservedWords(const Value: string): string;
    class function MySQLTypeToDelphiType(const SQLType: string; const IsNullable: Boolean): string;
    class function MySQLTypeToDelphiAsType(const SQLType: string; const IsNullable: Boolean): string;
  end;

implementation

uses
  SysUtils;

const
  CRLF = #13#10;
  TAB = '  ';
  TAB2 = TAB + TAB;

class function TDelphinator.ConcatLongString(const InStr: string; const Multiline: Boolean): string;
const
  BREAK_COUNT = 150;
var
  outStr, delim: string;
begin
  outStr := InStr;
  if (Length(InStr) > BREAK_COUNT) then
  begin
    if Multiline then
      delim := ''' + ' + CRLF + TAB2 + ''''
    else
      delim := ''' + ''';
    outStr := Copy(InStr, 1, BREAK_COUNT) + delim + ConcatLongString(Copy(InStr, BREAK_COUNT + 1, MaxInt), Multiline);
  end;
  Result := outStr;
end;

class function TDelphinator.FixReservedWords(const Value: string): string;
const
  RESERVED_WORDS = 'ClassTypeUnitNameLabelProgramFileClassName';
var
  corrected: string;
begin
  corrected := Value;
  if (Pos(Value, RESERVED_WORDS) > 0) then
    corrected := Value + '_';
  Result := corrected;
end;

class function TDelphinator.GetMySQLTypePrecision(const SQLType: string): Integer;
var
  options: string;
  precision: Integer;
begin
  precision := 0;
  if ((Pos('(', SQLType) > 0) and (Pos(')', SQLType) > 0)) then
  begin
    options := copy(SQLType, Pos('(', SQLType) + 1, Pos(')', SQLType) - Pos('(', SQLType) - 1);
    if (Pos(',', options) > 0) then
      precision := StrToInt(copy(options, 0, Pos(',', options) - 1))
    else
      precision := StrToInt(options);
  end;
  Result := precision;
end;

class function TDelphinator.GetMySQLTypeScale(const SQLType: string): Integer;
var
  options: string;
  scale: Integer;
begin
  scale := 0;
  if ((Pos('(', SQLType) > 0) and (Pos(')', SQLType) > 0)) then
  begin
    options := copy(SQLType, Pos('(', SQLType) + 1, Pos(')', SQLType) - Pos('(', SQLType) - 1);
    if (Pos(',', options) > 0) then
      scale := StrToInt(copy(options, Pos(',', options) + 1, Length(options) - Pos(',', options)));
  end;
  Result := scale;
end;

class function TDelphinator.IsMySQLTypeBoolean(const SQLType: string): Boolean;
var
  sqlTypeL: string;
begin
  sqlTypeL := LowerCase(SQLType);
  Result := (Pos('tinyint(1)', sqlTypeL) > 0);
end;

class function TDelphinator.MySQLTypeToDelphiType(const SQLType: string; const IsNullable: Boolean): string;
var
  delphiType, sqlTypeL: string;
  precision, scale: Integer;
begin
  delphiType := '';
  sqlTypeL := LowerCase(SQLType);
  precision := GetMySQLTypePrecision(SQLType);
  scale := GetMySQLTypeScale(SQLType);
  if ((Pos('tinyint', sqlTypeL) > 0) or (precision = 1)) then
    delphiType := 'Boolean';
  if ((Pos('tinyint(1)', sqlTypeL) > 0) or (Pos('bool', sqlTypeL) > 0)) then
    delphiType := 'Boolean'
  else if (Pos('bigint', sqlTypeL) > 0) then
    delphiType := 'Int64'
  else if (Pos('int', sqlTypeL) > 0) then
    delphiType := 'Integer';
  if (Pos('decimal', sqlTypeL) > 0) then
  begin
    if (scale < 5) then
      delphiType := 'Currency'
    else
      delphiType := 'Extended'
  end;
  if ((Pos('float', sqlTypeL) > 0) or (Pos('double', sqlTypeL) > 0)) then
    delphiType := 'Extended';
  if ((Pos('char', sqlTypeL) > 0) or (Pos('text', sqlTypeL) > 0) or (Pos('enum', sqlTypeL) > 0) or (Pos('set', sqlTypeL) > 0)) then
    delphiType := 'string';
// TODO: MyDAC components will not assign TDate values to query parameters in expected format, will have to use TDateTime for all
  if ((Pos('date', sqlTypeL) > 0) or (Pos('time', sqlTypeL) > 0)) then
  begin
    if IsNullable then
      delphiType := 'Variant'
    else
      delphiType := 'TDateTime';
  end;
  if ((Pos('blob', sqlTypeL) > 0) or (Pos('binary', sqlTypeL) > 0)) then
    delphiType := 'Variant';
  Result := delphiType;
end;

class function TDelphinator.MySQLTypeToDelphiAsType(const SQLType: string; const IsNullable: Boolean): string;
var
  asType, sqlTypeL: string;
  scale: Integer;
begin
  asType := '';
  sqlTypeL := LowerCase(SQLType);
  scale := GetMySQLTypeScale(SQLType);
  if (Pos('int', sqlTypeL) > 0) then
    asType := 'AsInteger';
  if (Pos('decimal', sqlTypeL) > 0) then
  begin
    if (scale < 5) then
      asType := 'AsCurrency'
    else
      asType := 'AsExtended'
  end;
  if ((Pos('float', sqlTypeL) > 0) or (Pos('double', sqlTypeL) > 0)) then
    asType := 'AsExtended';
  if ((Pos('char', sqlTypeL) > 0) or (Pos('text', sqlTypeL) > 0) or (Pos('enum', sqlTypeL) > 0) or (Pos('set', sqlTypeL) > 0)) then
    asType := 'AsString';
  if ((Pos('date', sqlTypeL) > 0) or (Pos('time', sqlTypeL) > 0)) then
  begin
    if IsNullable then
      asType := 'AsVariant'
    else
      asType := 'AsDateTime';
  end;
  if ((Pos('blob', sqlTypeL) > 0) or (Pos('binary', sqlTypeL) > 0)) then
    asType := 'AsVariant';
  Result := asType;
end;

end.