unit LogManager;

// Version: 8.1
interface

procedure AddCarillonLogMessage(const AMsg: string);
function CarillonLogFilePath: string;
function ReadCarillonPlayCount(const ADate: TDateTime): Integer;
function TryParseCarillonLogLineDateTime(const ALine: string;
  out AValue: TDateTime): Boolean;
procedure TrimCarillonPlayLog(const ADaysToKeep: Integer = 30);
procedure InitializeCarillonPlaybackDiagnostics;
procedure TraceCarillonPlayback(const AMessage: string);

implementation

uses
  System.Classes, System.DateUtils, System.IOUtils, System.SysUtils,
  Winapi.Windows;

var
  PlaybackDiagnosticFileName: string;

procedure TraceCarillonPlayback(const AMessage: string);
var
  DiagnosticStream: TFileStream;
  DiagnosticBytes: TBytes;
begin
  if PlaybackDiagnosticFileName = '' then
    Exit;
  try
    DiagnosticBytes := TEncoding.UTF8.GetBytes(Format(
      '%s [pid=%d thread=%d tick=%d] %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now, TFormatSettings.Invariant),
       GetCurrentProcessId, GetCurrentThreadId, GetTickCount64, AMessage]) + sLineBreak);
    if FileExists(PlaybackDiagnosticFileName) then
      DiagnosticStream := TFileStream.Create(PlaybackDiagnosticFileName,
        fmOpenReadWrite or fmShareDenyWrite)
    else
      DiagnosticStream := TFileStream.Create(PlaybackDiagnosticFileName,
        fmCreate or fmShareDenyWrite);
    try
      DiagnosticStream.Seek(0, soEnd);
      DiagnosticStream.WriteBuffer(DiagnosticBytes[0], Length(DiagnosticBytes));
      // Fail-fast bypasses Delphi handlers, so persist each stage before continuing.
      if not FlushFileBuffers(DiagnosticStream.Handle) then
        OutputDebugString('Carillon playback diagnostic flush failed.');
    finally
      DiagnosticStream.Free;
    end;
  except
    // Diagnostics must not prevent playback if the USB is full or unwritable.
    OutputDebugString('Carillon playback diagnostic write failed.');
  end;
end;

procedure InitializeCarillonPlaybackDiagnostics;
var
  DiagnosticDirectory: string;
begin
  PlaybackDiagnosticFileName := '';
  try
    DiagnosticDirectory := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'logs' + PathDelim + 'diagnostics';
    if not ForceDirectories(DiagnosticDirectory) then
      Exit;
    PlaybackDiagnosticFileName := IncludeTrailingPathDelimiter(DiagnosticDirectory) +
      'CarillonPlayback-' + FormatDateTime('yyyymmdd-hhnnss-zzz', Now) + '-' +
      UIntToStr(GetCurrentProcessId) + '.log';
    TraceCarillonPlayback('diagnostics.start revision=2026-09-25 executable=' + ParamStr(0));
    {$IFDEF WIN64}
    TraceCarillonPlayback('build.platform=Win64');
    {$ELSE}
    TraceCarillonPlayback('build.platform=Win32');
    {$ENDIF}
    {$IFDEF DEBUG}
    TraceCarillonPlayback('build.configuration=Debug');
    {$ELSE}
    TraceCarillonPlayback('build.configuration=Release');
    {$ENDIF}
  except
    PlaybackDiagnosticFileName := '';
    OutputDebugString('Carillon playback diagnostics could not be initialized.');
  end;
end;

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

function ReadCarillonPlayCount(const ADate: TDateTime): Integer;
var
  Lines: TStringList;
  Line, MessageText: string;
  Stamp: TDateTime;
begin
  Result := 0;
  if not FileExists(CarillonLogFilePath) then
    Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(CarillonLogFilePath);
    for Line in Lines do
      if TryParseCarillonLogLineDateTime(Line, Stamp) and
         (DateOf(Stamp) = DateOf(ADate)) then
      begin
        MessageText := Copy(Line, Pos(' - ', Line) + 3, MaxInt);
        if MessageText.StartsWith('Played Song: ') then
          Inc(Result);
      end;
  finally
    Lines.Free;
  end;
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
