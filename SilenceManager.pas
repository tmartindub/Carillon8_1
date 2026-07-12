unit SilenceManager;

// Version: 8.1
interface

uses
  AudioManager,
  FireDAC.Comp.Client,
  System.Generics.Collections,
  System.SysUtils;

type
  TSilenceStateChangedEvent = procedure(Sender: TObject; Active: Boolean;
    const Purpose: string; UntilTime: TDateTime) of object;

  TSilenceWindowInfo = record
    EndTime: TTime;
    Purpose: string;
    StartTime: TTime;
    WindowId: Integer;
  end;

  TSilenceWindowRule = record
    EndTime: TTime;
    Friday: Boolean;
    Monday: Boolean;
    Purpose: string;
    Saturday: Boolean;
    StartTime: TTime;
    Sunday: Boolean;
    Thursday: Boolean;
    Tuesday: Boolean;
    Wednesday: Boolean;
    WindowId: Integer;
  end;

  TSilenceManager = class
  private
    FActiveWindowId: Integer;
    FAudioManager: TAudioManager;
    FConnection: TFDConnection;
    FCurrentEndTime: TDateTime;
    FCurrentPurpose: string;
    FManagedMuteActive: Boolean;
    FOnStateChanged: TSilenceStateChangedEvent;
    FRules: TList<TSilenceWindowRule>;
    FRulesLoaded: Boolean;
    FWasMutedBeforeManagedSilence: Boolean;
    procedure EnsureConnection;
    procedure EnsureRulesLoaded;
    function ReadActiveWindow(const ADateTime: TDateTime;
      const AEndInclusive: Boolean; out AWindowId: Integer;
      out APurpose: string; out AEndTime: TDateTime): Boolean;
    function RuleAppliesToDate(const ARule: TSilenceWindowRule;
      const ADate: TDateTime): Boolean;
    function RuleContainsDateTime(const ARule: TSilenceWindowRule;
      const ADateTime: TDateTime; const AEndInclusive: Boolean;
      out AEndDateTime: TDateTime): Boolean;
  public
    constructor Create(AAudioManager: TAudioManager);
    destructor Destroy; override;
    class procedure EnsureDatabaseReady(const AConnection: TFDConnection); static;
    class procedure EnsureDefaultRows(const AConnection: TFDConnection); static;
    class procedure EnsureSchema(const AConnection: TFDConnection); static;
    procedure GetSilenceWindowsForDate(const ADate: TDateTime;
      const AWindows: TList<TSilenceWindowInfo>);
    function IsScheduleTimeSilenced(const ADateTime: TDateTime): Boolean;
    function IsTimeSilenced(const ADateTime: TDateTime): Boolean;
    procedure ReleaseManagedMute;
    procedure Reload;
    procedure Tick;
    property CurrentEndTime: TDateTime read FCurrentEndTime;
    property CurrentPurpose: string read FCurrentPurpose;
    property ManagedMuteActive: Boolean read FManagedMuteActive;
    property OnStateChanged: TSilenceStateChangedEvent read FOnStateChanged
      write FOnStateChanged;
  end;

implementation

uses
  CarillonTheme,
  Data.DB,
  DateUtils,
  FireDAC.Stan.Param;

const
  SilenceTableName = 'silence_schedule';

function ParseSilenceTime(const AValue: string; out ATime: TTime): Boolean;
var
  Hours: Integer;
  LText: string;
  Minutes: Integer;
  Parts: TArray<string>;
  Seconds: Integer;
  Suffix: string;
begin
  Result := False;
  ATime := 0;
  LText := UpperCase(Trim(AValue));
  if LText = '' then
    Exit;

  LText := StringReplace(LText, '.', ':', [rfReplaceAll]);
  while Pos('  ', LText) > 0 do
    LText := StringReplace(LText, '  ', ' ', [rfReplaceAll]);

  Suffix := '';
  if Length(LText) >= 2 then
    if SameText(Copy(LText, Length(LText) - 1, 2), 'AM') or
      SameText(Copy(LText, Length(LText) - 1, 2), 'PM') then
    begin
      Suffix := Copy(LText, Length(LText) - 1, 2);
      Delete(LText, Length(LText) - 1, 2);
      LText := Trim(LText);
    end;

  Hours := 0;
  Minutes := 0;
  Seconds := 0;
  Parts := LText.Split([':']);
  if (Length(Parts) < 2) or (Length(Parts) > 3) then
    Exit;
  if not TryStrToInt(Trim(Parts[0]), Hours) then
    Exit;
  if not TryStrToInt(Trim(Parts[1]), Minutes) then
    Exit;
  if Length(Parts) = 3 then
    if not TryStrToInt(Trim(Parts[2]), Seconds) then
      Exit;

  if (Minutes < 0) or (Minutes > 59) or (Seconds < 0) or (Seconds > 59) then
    Exit;

  if Suffix = 'AM' then
  begin
    if (Hours < 1) or (Hours > 12) then
      Exit;
    if Hours = 12 then
      Hours := 0;
  end
  else if Suffix = 'PM' then
  begin
    if (Hours < 1) or (Hours > 12) then
      Exit;
    if Hours < 12 then
      Inc(Hours, 12);
  end
  else if (Hours < 0) or (Hours > 23) then
    Exit;

  try
    ATime := EncodeTime(Hours, Minutes, Seconds, 0);
    Result := True;
  except
    Result := False;
  end;
end;

constructor TSilenceManager.Create(AAudioManager: TAudioManager);
begin
  inherited Create;
  FActiveWindowId := 0;
  FAudioManager := AAudioManager;
  FConnection := nil;
  FCurrentEndTime := 0;
  FCurrentPurpose := '';
  FManagedMuteActive := False;
  FOnStateChanged := nil;
  FRules := TList<TSilenceWindowRule>.Create;
  FRulesLoaded := False;
  FWasMutedBeforeManagedSilence := False;
end;

destructor TSilenceManager.Destroy;
begin
  ReleaseManagedMute;
  FRules.Free;
  FConnection.Free;
  inherited Destroy;
end;

class procedure TSilenceManager.EnsureDatabaseReady(
  const AConnection: TFDConnection);
begin
  EnsureSchema(AConnection);
  EnsureDefaultRows(AConnection);
end;

class procedure TSilenceManager.EnsureDefaultRows(
  const AConnection: TFDConnection);
var
  I: Integer;
  Query: TFDQuery;
begin
  if AConnection = nil then
    Exit;
  if not AConnection.Connected then
    AConnection.Connected := True;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text :=
      'INSERT OR IGNORE INTO ' + SilenceTableName + ' ' +
      '(silence_id, enabled, Purpose, start_time, end_time, monday, tuesday, ' +
      'wednesday, thursday, friday, saturday, sunday) ' +
      'VALUES (:silence_id, 0, :purpose, NULL, NULL, 0, 0, 0, 0, 0, 0, 0)';
    for I := 1 to 12 do
    begin
      Query.ParamByName('silence_id').AsInteger := I;
      Query.ParamByName('purpose').AsString := 'Silence Window ' + I.ToString;
      Query.ExecSQL;
    end;
  finally
    Query.Free;
  end;
end;

class procedure TSilenceManager.EnsureSchema(const AConnection: TFDConnection);
var
  Query: TFDQuery;
begin
  if AConnection = nil then
    Exit;
  if not AConnection.Connected then
    AConnection.Connected := True;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS ' + SilenceTableName + ' (' +
      'silence_id INTEGER NOT NULL PRIMARY KEY, ' +
      'enabled INTEGER NOT NULL DEFAULT 0, ' +
      'Purpose TEXT, ' +
      'start_time TEXT, ' +
      'end_time TEXT, ' +
      'monday INTEGER NOT NULL DEFAULT 0, ' +
      'tuesday INTEGER NOT NULL DEFAULT 0, ' +
      'wednesday INTEGER NOT NULL DEFAULT 0, ' +
      'thursday INTEGER NOT NULL DEFAULT 0, ' +
      'friday INTEGER NOT NULL DEFAULT 0, ' +
      'saturday INTEGER NOT NULL DEFAULT 0, ' +
      'sunday INTEGER NOT NULL DEFAULT 0)';
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TSilenceManager.EnsureConnection;
begin
  if FConnection = nil then
  begin
    FConnection := TFDConnection.Create(nil);
    ConfigurePortableSQLiteConnection(FConnection);
  end;

  if not FConnection.Connected then
  begin
    FConnection.Connected := True;
    EnsureDatabaseReady(FConnection);
  end;
end;

procedure TSilenceManager.EnsureRulesLoaded;
begin
  if not FRulesLoaded then
    Reload;
end;

procedure TSilenceManager.GetSilenceWindowsForDate(const ADate: TDateTime;
  const AWindows: TList<TSilenceWindowInfo>);
var
  Rule: TSilenceWindowRule;
  WindowInfo: TSilenceWindowInfo;
begin
  if AWindows = nil then
    Exit;

  EnsureRulesLoaded;
  for Rule in FRules do
    if RuleAppliesToDate(Rule, ADate) then
    begin
      WindowInfo.EndTime := Rule.EndTime;
      WindowInfo.Purpose := Rule.Purpose;
      WindowInfo.StartTime := Rule.StartTime;
      WindowInfo.WindowId := Rule.WindowId;
      AWindows.Add(WindowInfo);
    end;
end;

function TSilenceManager.IsScheduleTimeSilenced(
  const ADateTime: TDateTime): Boolean;
var
  EndTime: TDateTime;
  Purpose: string;
  WindowId: Integer;
begin
  Result := ReadActiveWindow(ADateTime, True, WindowId, Purpose, EndTime);
end;

function TSilenceManager.IsTimeSilenced(const ADateTime: TDateTime): Boolean;
var
  EndTime: TDateTime;
  Purpose: string;
  WindowId: Integer;
begin
  Result := ReadActiveWindow(ADateTime, False, WindowId, Purpose, EndTime);
end;

function TSilenceManager.ReadActiveWindow(const ADateTime: TDateTime;
  const AEndInclusive: Boolean; out AWindowId: Integer; out APurpose: string;
  out AEndTime: TDateTime): Boolean;
var
  Rule: TSilenceWindowRule;
begin
  Result := False;
  AWindowId := 0;
  APurpose := '';
  AEndTime := 0;

  EnsureRulesLoaded;
  for Rule in FRules do
    if RuleContainsDateTime(Rule, ADateTime, AEndInclusive, AEndTime) then
    begin
      AWindowId := Rule.WindowId;
      APurpose := Rule.Purpose;
      Result := True;
      Exit;
    end;
end;

procedure TSilenceManager.ReleaseManagedMute;
var
  EndedPurpose: string;
  EndedTime: TDateTime;
begin
  if not FManagedMuteActive then
    Exit;

  EndedPurpose := FCurrentPurpose;
  EndedTime := FCurrentEndTime;

  if Assigned(FAudioManager) and (not FWasMutedBeforeManagedSilence) then
    FAudioManager.SetMute(False);

  FActiveWindowId := 0;
  FCurrentEndTime := 0;
  FCurrentPurpose := '';
  FManagedMuteActive := False;
  FWasMutedBeforeManagedSilence := False;

  if Assigned(FOnStateChanged) then
    FOnStateChanged(Self, False, EndedPurpose, EndedTime);
end;

procedure TSilenceManager.Reload;
var
  Query: TFDQuery;
  Rule: TSilenceWindowRule;
begin
  EnsureConnection;
  FRules.Clear;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'SELECT silence_id, Purpose, start_time, end_time, monday, tuesday, ' +
      'wednesday, thursday, friday, saturday, sunday FROM ' +
      SilenceTableName + ' WHERE enabled = 1 ORDER BY silence_id';
    Query.Open;
    while not Query.Eof do
    begin
      if ParseSilenceTime(Query.FieldByName('start_time').AsString,
        Rule.StartTime) and
        ParseSilenceTime(Query.FieldByName('end_time').AsString,
        Rule.EndTime) and (CompareTime(Rule.StartTime, Rule.EndTime) <> 0) then
      begin
        Rule.WindowId := Query.FieldByName('silence_id').AsInteger;
        Rule.Purpose := Trim(Query.FieldByName('Purpose').AsString);
        if Rule.Purpose = '' then
          Rule.Purpose := 'Silence Window ' + Rule.WindowId.ToString;
        Rule.Monday := Query.FieldByName('monday').AsInteger <> 0;
        Rule.Tuesday := Query.FieldByName('tuesday').AsInteger <> 0;
        Rule.Wednesday := Query.FieldByName('wednesday').AsInteger <> 0;
        Rule.Thursday := Query.FieldByName('thursday').AsInteger <> 0;
        Rule.Friday := Query.FieldByName('friday').AsInteger <> 0;
        Rule.Saturday := Query.FieldByName('saturday').AsInteger <> 0;
        Rule.Sunday := Query.FieldByName('sunday').AsInteger <> 0;
        FRules.Add(Rule);
      end;
      Query.Next;
    end;
  finally
    Query.Free;
    FRulesLoaded := True;
  end;
end;

function TSilenceManager.RuleAppliesToDate(const ARule: TSilenceWindowRule;
  const ADate: TDateTime): Boolean;
begin
  case DayOfTheWeek(ADate) of
    1: Result := ARule.Monday;
    2: Result := ARule.Tuesday;
    3: Result := ARule.Wednesday;
    4: Result := ARule.Thursday;
    5: Result := ARule.Friday;
    6: Result := ARule.Saturday;
  else
    Result := ARule.Sunday;
  end;
end;

function TSilenceManager.RuleContainsDateTime(const ARule: TSilenceWindowRule;
  const ADateTime: TDateTime; const AEndInclusive: Boolean;
  out AEndDateTime: TDateTime): Boolean;
var
  CurrentDate: TDateTime;
  CurrentTime: TDateTime;
  EndCompare: Integer;
  PreviousDate: TDateTime;
begin
  Result := False;
  AEndDateTime := 0;
  CurrentDate := DateOf(ADateTime);
  CurrentTime := TimeOf(ADateTime);

  if CompareTime(ARule.StartTime, ARule.EndTime) < 0 then
  begin
    EndCompare := CompareTime(CurrentTime, ARule.EndTime);
    if RuleAppliesToDate(ARule, CurrentDate) and
      (CompareTime(CurrentTime, ARule.StartTime) >= 0) and
      ((EndCompare < 0) or (AEndInclusive and (EndCompare = 0))) then
    begin
      AEndDateTime := CurrentDate + ARule.EndTime;
      Result := True;
    end;
    Exit;
  end;

  if RuleAppliesToDate(ARule, CurrentDate) and
    (CompareTime(CurrentTime, ARule.StartTime) >= 0) then
  begin
    AEndDateTime := IncDay(CurrentDate, 1) + ARule.EndTime;
    Result := True;
    Exit;
  end;

  PreviousDate := IncDay(CurrentDate, -1);
  EndCompare := CompareTime(CurrentTime, ARule.EndTime);
  if RuleAppliesToDate(ARule, PreviousDate) and
    ((EndCompare < 0) or (AEndInclusive and (EndCompare = 0))) then
  begin
    AEndDateTime := CurrentDate + ARule.EndTime;
    Result := True;
  end;
end;

procedure TSilenceManager.Tick;
var
  EndTime: TDateTime;
  Purpose: string;
  WindowId: Integer;
  WasActive: Boolean;
  PreviousWindowId: Integer;
begin
  WasActive := FManagedMuteActive;
  PreviousWindowId := FActiveWindowId;

  if ReadActiveWindow(Now, False, WindowId, Purpose, EndTime) then
  begin
    if not FManagedMuteActive then
    begin
      FWasMutedBeforeManagedSilence := Assigned(FAudioManager) and
        FAudioManager.Muted;
      FManagedMuteActive := True;
    end;

    FActiveWindowId := WindowId;
    FCurrentPurpose := Purpose;
    FCurrentEndTime := EndTime;

    if Assigned(FAudioManager) and (not FAudioManager.Muted) then
      FAudioManager.SetMute(True);

    if ((not WasActive) or (PreviousWindowId <> FActiveWindowId)) and
      Assigned(FOnStateChanged) then
      FOnStateChanged(Self, True, FCurrentPurpose, FCurrentEndTime);

    Exit;
  end;

  ReleaseManagedMute;
end;

end.
