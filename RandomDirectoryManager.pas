unit RandomDirectoryManager;

// Version: 8.1
interface

uses
  FireDAC.Comp.Client, System.SysUtils;

type
  TRandomDirectorySlot = record
    SlotNo: Integer;
    MusicDir: string;
    FromDate: TDateTime;
    HasFromDate: Boolean;
    ToDate: TDateTime;
    HasToDate: Boolean;
  end;

procedure EnsureRandomDirectorySchema(const AConnection: TFDConnection);
procedure LoadRandomDirectorySlot(const AConnection: TFDConnection;
  const ASlotNo: Integer; out ASlot: TRandomDirectorySlot);
procedure LoadRandomDirectorySlots(const AConnection: TFDConnection;
  var ASlots: array of TRandomDirectorySlot);
procedure SaveRandomDirectorySlot(const AConnection: TFDConnection;
  const ASlot: TRandomDirectorySlot);
procedure SaveRandomDirectorySlots(const AConnection: TFDConnection;
  const ASlots: array of TRandomDirectorySlot);
function ResolveRandomMusicDirectory(const AConnection: TFDConnection): string;

implementation

uses
  Data.DB, FireDAC.Stan.Param, System.DateUtils;

function TableHasColumn(const AConnection: TFDConnection; const ATableName,
  AColumnName: string): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text := 'PRAGMA table_info(' + ATableName + ')';
    Q.Open;
    while not Q.Eof do
    begin
      if SameText(Q.FieldByName('name').AsString, AColumnName) then
        Exit(True);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TableExists(const AConnection: TFDConnection;
  const ATableName: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT name FROM sqlite_master WHERE type = ''table'' AND name = :name';
    Q.ParamByName('name').AsString := ATableName;
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

procedure CreateRowTable(const AConnection: TFDConnection);
begin
  AConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS PL_RAND_DIR_ROTATION (' +
    'slot_no INTEGER PRIMARY KEY CHECK (slot_no BETWEEN 1 AND 7), ' +
    'rand_music_dir TEXT CHECK (LENGTH(rand_music_dir) <= 150), ' +
    'frm_date DATE, ' +
    'to_date DATE)');
end;

procedure EnsureSevenRows(const AConnection: TFDConnection);
var
  I: Integer;
begin
  for I := 1 to 7 do
    AConnection.ExecSQL(
      'INSERT INTO PL_RAND_DIR_ROTATION (slot_no) ' +
      'SELECT :slot_no WHERE NOT EXISTS (' +
      'SELECT 1 FROM PL_RAND_DIR_ROTATION WHERE slot_no = :slot_no)',
      [I]);
end;

procedure MigrateWideTable(const AConnection: TFDConnection);
var
  I: Integer;
  InsertSql: string;
begin
  if TableExists(AConnection, 'PL_RAND_DIR_ROTATION_WIDE_BACKUP') then
    AConnection.ExecSQL('DROP TABLE PL_RAND_DIR_ROTATION_WIDE_BACKUP');
  AConnection.ExecSQL(
    'ALTER TABLE PL_RAND_DIR_ROTATION RENAME TO PL_RAND_DIR_ROTATION_WIDE_BACKUP');
  CreateRowTable(AConnection);
  for I := 1 to 7 do
  begin
    InsertSql := Format(
      'INSERT INTO PL_RAND_DIR_ROTATION ' +
      '(slot_no, rand_music_dir, frm_date, to_date) ' +
      'SELECT %d, rand_music_dir%d, frm_date%d, to_date%d ' +
      'FROM PL_RAND_DIR_ROTATION_WIDE_BACKUP WHERE id = 1',
      [I, I, I, I]);
    AConnection.ExecSQL(InsertSql);
  end;
end;

procedure EnsureRandomDirectorySchema(const AConnection: TFDConnection);
begin
  if AConnection = nil then
    Exit;
  if not AConnection.Connected then
    AConnection.Connected := True;
  AConnection.StartTransaction;
  try
    if TableExists(AConnection, 'PL_RAND_DIR_ROTATION') then
    begin
      if not TableHasColumn(AConnection, 'PL_RAND_DIR_ROTATION', 'slot_no') then
        MigrateWideTable(AConnection);
    end
    else
      CreateRowTable(AConnection);
    EnsureSevenRows(AConnection);
    AConnection.Commit;
  except
    AConnection.Rollback;
    raise;
  end;
end;

procedure LoadRandomDirectorySlot(const AConnection: TFDConnection;
  const ASlotNo: Integer; out ASlot: TRandomDirectorySlot);
var
  Q: TFDQuery;
begin
  FillChar(ASlot, SizeOf(ASlot), 0);
  ASlot.SlotNo := ASlotNo;
  EnsureRandomDirectorySchema(AConnection);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT slot_no, rand_music_dir, frm_date, to_date ' +
      'FROM PL_RAND_DIR_ROTATION WHERE slot_no = :slot_no';
    Q.ParamByName('slot_no').AsInteger := ASlotNo;
    Q.Open;
    if not Q.IsEmpty then
    begin
      ASlot.MusicDir := Q.FieldByName('rand_music_dir').AsString;
      ASlot.HasFromDate := not Q.FieldByName('frm_date').IsNull;
      if ASlot.HasFromDate then
        ASlot.FromDate := Q.FieldByName('frm_date').AsDateTime;
      ASlot.HasToDate := not Q.FieldByName('to_date').IsNull;
      if ASlot.HasToDate then
        ASlot.ToDate := Q.FieldByName('to_date').AsDateTime;
    end;
  finally
    Q.Free;
  end;
end;

procedure LoadRandomDirectorySlots(const AConnection: TFDConnection;
  var ASlots: array of TRandomDirectorySlot);
var
  Q: TFDQuery;
  I: Integer;
begin
  EnsureRandomDirectorySchema(AConnection);
  for I := Low(ASlots) to High(ASlots) do
  begin
    FillChar(ASlots[I], SizeOf(ASlots[I]), 0);
    ASlots[I].SlotNo := I + 1;
  end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT slot_no, rand_music_dir, frm_date, to_date ' +
      'FROM PL_RAND_DIR_ROTATION ORDER BY slot_no';
    Q.Open;
    while not Q.Eof do
    begin
      I := Q.FieldByName('slot_no').AsInteger - 1;
      if (I >= Low(ASlots)) and (I <= High(ASlots)) then
      begin
        ASlots[I].SlotNo := I + 1;
        ASlots[I].MusicDir := Q.FieldByName('rand_music_dir').AsString;
        ASlots[I].HasFromDate := not Q.FieldByName('frm_date').IsNull;
        if ASlots[I].HasFromDate then
          ASlots[I].FromDate := Q.FieldByName('frm_date').AsDateTime;
        ASlots[I].HasToDate := not Q.FieldByName('to_date').IsNull;
        if ASlots[I].HasToDate then
          ASlots[I].ToDate := Q.FieldByName('to_date').AsDateTime;
      end;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;
procedure SaveRandomDirectorySlot(const AConnection: TFDConnection;
  const ASlot: TRandomDirectorySlot);
var
  Q: TFDQuery;
begin
  if not AConnection.InTransaction then
    EnsureRandomDirectorySchema(AConnection);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'UPDATE PL_RAND_DIR_ROTATION SET ' +
      'rand_music_dir = :rand_music_dir, frm_date = :frm_date, to_date = :to_date ' +
      'WHERE slot_no = :slot_no';
    Q.ParamByName('slot_no').AsInteger := ASlot.SlotNo;
    Q.ParamByName('rand_music_dir').AsString := ASlot.MusicDir;
    Q.ParamByName('frm_date').DataType := ftDate;
    Q.ParamByName('to_date').DataType := ftDate;
    if ASlot.HasFromDate then
      Q.ParamByName('frm_date').AsDateTime := ASlot.FromDate
    else
      Q.ParamByName('frm_date').Clear;
    if ASlot.HasToDate then
      Q.ParamByName('to_date').AsDateTime := ASlot.ToDate
    else
      Q.ParamByName('to_date').Clear;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure SaveRandomDirectorySlots(const AConnection: TFDConnection;
  const ASlots: array of TRandomDirectorySlot);
var
  Slot: TRandomDirectorySlot;
begin
  EnsureRandomDirectorySchema(AConnection);
  AConnection.StartTransaction;
  try
    for Slot in ASlots do
      SaveRandomDirectorySlot(AConnection, Slot);
    AConnection.Commit;
  except
    AConnection.Rollback;
    raise;
  end;
end;

function ResolveRandomMusicDirectory(const AConnection: TFDConnection): string;
var
  FromDay: Integer;
  Q: TFDQuery;
  ToDay: Integer;
  TodayDay: Integer;

  function MonthDayValue(const ADate: TDateTime): Integer;
  begin
    Result := (MonthOf(ADate) * 100) + DayOf(ADate);
  end;

  function DateWindowContainsToday(const AFromDate, AToDate: TDateTime): Boolean;
  begin
    FromDay := MonthDayValue(AFromDate);
    ToDay := MonthDayValue(AToDate);
    if FromDay <= ToDay then
      Result := (TodayDay >= FromDay) and (TodayDay <= ToDay)
    else
      Result := (TodayDay >= FromDay) or (TodayDay <= ToDay);
  end;
begin
  Result := '';
  EnsureRandomDirectorySchema(AConnection);
  TodayDay := MonthDayValue(Date);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT rand_music_dir, frm_date, to_date FROM PL_RAND_DIR_ROTATION ' +
      'WHERE slot_no BETWEEN 2 AND 7 ' +
      'AND COALESCE(TRIM(rand_music_dir), '''') <> '''' ' +
      'AND frm_date IS NOT NULL AND to_date IS NOT NULL ' +
      'ORDER BY slot_no';
    Q.Open;
    while not Q.Eof do
    begin
      if DateWindowContainsToday(Q.FieldByName('frm_date').AsDateTime,
        Q.FieldByName('to_date').AsDateTime) then
        Exit(Trim(Q.FieldByName('rand_music_dir').AsString));
      Q.Next;
    end;
    Q.Close;
    Q.SQL.Text :=
      'SELECT rand_music_dir FROM PL_RAND_DIR_ROTATION WHERE slot_no = 1';
    Q.Open;
    if not Q.IsEmpty then
      Result := Trim(Q.FieldByName('rand_music_dir').AsString);
  finally
    Q.Free;
  end;
end;
end.
