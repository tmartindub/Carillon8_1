unit LogManager;

// Version: 8.1
interface

procedure AddCarillonLogMessage(const AMsg: string);
function CarillonLogFilePath: string;
function TryParseCarillonLogLineDateTime(const ALine: string;
  out AValue: TDateTime): Boolean;
procedure TrimCarillonPlayLog(const ADaysToKeep: Integer = 30);

implementation

uses
  System.Classes, System.DateUtils, System.IOUtils, System.SysUtils;

function TryParseLogTimestamp(const AText: string; out AValue: TDateTime): Boolean;
var
  Day: Integer;
  FS: TFormatSettings;
  Hour: Integer;
  Minute: Integer;
  Month: Integer;
  Second: Integer;
  Year: Integer;
begin
  Result := False;
  AValue := 0;
  if Length(AText) = 19 then
  begin
    if (AText[5] = '-') and (AText[8] = '-') and (AText[11] = ' ') and
      (AText[14] = ':') and (AText[17] = ':') then
    begin
      if not TryStrToInt(Copy(AText, 1, 4), Year) then
        Exit;
      if not TryStrToInt(Copy(AText, 6, 2), Month) then
        Exit;
      if not TryStrToInt(Copy(AText, 9, 2), Day) then
        Exit;
      if not TryStrToInt(Copy(AText, 12, 2), Hour) then
        Exit;
      if not TryStrToInt(Copy(AText, 15, 2), Minute) then
        Exit;
      if not TryStrToInt(Copy(AText, 18, 2), Second) then
        Exit;
      try
        AValue := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Minute, Second, 0);
        Exit(True);
      except
        Exit(False);
      end;
    end;
  end;
  FS := TFormatSettings.Create('en-US');
  Result := TryStrToDateTime(AText, AValue, FS);
end;

function CarillonLogFilePath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'logs' + PathDelim + 'CarillonPlayLog.txt';
end;

function TryParseCarillonLogLineDateTime(const ALine: string;
  out AValue: TDateTime): Boolean;
var
  SeparatorPos: Integer;
  TextDate: string;
begin
  Result := False;
  AValue := 0;
  SeparatorPos := Pos(' - ', ALine);
  if SeparatorPos <= 1 then
    Exit;
  TextDate := Copy(ALine, 1, SeparatorPos - 1);
  Result := TryParseLogTimestamp(TextDate, AValue);
end;

procedure AddCarillonLogMessage(const AMsg: string);
var
  LogDirectory: string;
  LogFilePath: string;
  LogFile: TextFile;
  LogFileOpened: Boolean;
  FS: TFormatSettings;
begin
  LogDirectory := ExtractFileDir(CarillonLogFilePath);
  if not DirectoryExists(LogDirectory) then
    ForceDirectories(LogDirectory);
  LogFilePath := CarillonLogFilePath;
  AssignFile(LogFile, LogFilePath);
  LogFileOpened := False;
  try
    if FileExists(LogFilePath) then
      Append(LogFile)
    else
      Rewrite(LogFile);
    LogFileOpened := True;
    FS := TFormatSettings.Invariant;
    Writeln(LogFile, Format('%s - %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now, FS), AMsg]));
  finally
    if LogFileOpened then
      CloseFile(LogFile);
  end;
end;

procedure TrimCarillonPlayLog(const ADaysToKeep: Integer = 30);
var
  Cutoff: TDateTime;
  I: Integer;
  LineDate: TDateTime;
  Lines: TStringList;
  LogFilePath: string;
begin
  LogFilePath := CarillonLogFilePath;
  if not FileExists(LogFilePath) then
    Exit;
  Cutoff := Now - ADaysToKeep;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFilePath);
    for I := Lines.Count - 1 downto 0 do
    begin
      if TryParseCarillonLogLineDateTime(Lines[I], LineDate) and
        (LineDate < Cutoff) then
        Lines.Delete(I);
    end;
    Lines.SaveToFile(LogFilePath);
  finally
    Lines.Free;
  end;
end;

end.
