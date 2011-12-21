unit Delphinator;

interface

type
  TDelphinator = class
  public
    class function ConcatLongString(const InStr: string; const Multiline: Boolean): string;
    class function FixReservedWords(const Value: string): string;
    class function MySQLTypeToDelphiType(const SQLType: string): string;
    class function MySQLTypeToDelphiAsType(const SQLType: string): string;
  end;

implementation

uses
  SysUtils;

const
  CRLF = #13#10;
  CRLF2 = CRLF + CRLF;
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
    if (Multiline) then
    begin
      delim := ''' + ' + CRLF + TAB2 + '''';
    end
    else
    begin
      delim := ''' + ''';
    end;
    outStr := Copy(InStr, 1, BREAK_COUNT) + delim + ConcatLongString(Copy(InStr, BREAK_COUNT + 1, MaxInt), Multiline);
  end;
  Result := outStr;
end;

class function TDelphinator.FixReservedWords(const Value: string): string;
const
  RESERVED_WORDS = 'ClassTypeUnitNameLabelProgram';
var
  corrected: string;
begin
  corrected := Value;
  if (Pos(Value, RESERVED_WORDS) > 0) then
    corrected := Value + '_';
  Result := corrected;
end;

class function TDelphinator.MySQLTypeToDelphiType(const SQLType: string): string;
var
  delphiType, sqlTypeL: string;
begin
  delphiType := '';
  sqlTypeL := LowerCase(SQLType);
  if (Pos('tinyint(1)', sqlTypeL) > 0) then
    delphiType := 'Boolean'
  else if ((Pos('int', sqlTypeL) > 0) or (Pos('decimal', sqlTypeL) > 0)) then
    delphiType := 'Integer';
  if ((Pos('float', sqlTypeL) > 0) or (Pos('double', sqlTypeL) > 0)) then
    delphiType := 'Extended';
  if ((Pos('char', sqlTypeL) > 0) or (Pos('text', sqlTypeL) > 0) or (Pos('enum', sqlTypeL) > 0) or (Pos('set', sqlTypeL) > 0)) then
    delphiType := 'string';
// TODO: MyDAC components will not assign TDate values to query parameters in expected format, will have to use TDateTime for all
  if ((Pos('date', sqlTypeL) > 0) or (Pos('timestamp', sqlTypeL) > 0)) then
    delphiType := 'TDateTime'
//  if ((Pos('datetime', sqlTypeL) > 0) or (Pos('timestamp', sqlTypeL) > 0)) then
//    delphiType := 'TDateTime'
//  else if (Pos('date', sqlTypeL) > 0) then
//    delphiType := 'TDate'
  else if (Pos('time', sqlTypeL) > 0) then
    delphiType := 'TTime';
  if ((Pos('blob', sqlTypeL) > 0) or (Pos('binary', sqlTypeL) > 0)) then
    delphiType := 'Variant';
  Result := delphiType;
end;

class function TDelphinator.MySQLTypeToDelphiAsType(const SQLType: string): string;
var
  asType, sqlTypeL: string;
begin
  asType := '';
  sqlTypeL := LowerCase(SQLType);
  if (Pos('tinyint(1)', sqlTypeL) > 0) then
    asType := 'AsBoolean'
  else if ((Pos('int', sqlTypeL) > 0) or (Pos('decimal', sqlTypeL) > 0)) then
    asType := 'AsInteger';
  if ((Pos('float', sqlTypeL) > 0) or (Pos('double', sqlTypeL) > 0)) then
    asType := 'AsExtended';
  if ((Pos('char', sqlTypeL) > 0) or (Pos('text', sqlTypeL) > 0) or (Pos('enum', sqlTypeL) > 0) or (Pos('set', sqlTypeL) > 0)) then
    asType := 'AsString';
  if ((Pos('date', sqlTypeL) > 0) or (Pos('time', sqlTypeL) > 0)) then
    asType := 'AsDateTime';
  if ((Pos('blob', sqlTypeL) > 0) or (Pos('binary', sqlTypeL) > 0)) then
    asType := 'AsVariant';
  Result := asType;
end;

end.
