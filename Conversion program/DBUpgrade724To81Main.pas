unit DBUpgrade724To81Main;

// Version: 8.1

interface

uses
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Def,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Memo,
  FMX.StdCtrls,
  System.Classes,
  System.SysUtils;

type
  TfrmDBUpgrade724To81 = class(TForm)
    btnBrowse: TButton;
    btnClose: TButton;
    btnUpgrade: TButton;
    chkConfirmBackup: TCheckBox;
    edtDatabase: TEdit;
    lblDatabase: TLabel;
    lblInstructions: TLabel;
    lblStatus: TLabel;
    memoReport: TMemo;
    OpenDialog1: TOpenDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnUpgradeClick(Sender: TObject);
    procedure edtDatabaseChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FReportLines: TStringList;
    FSuppressChange: Boolean;
    procedure AddReportLine(const AText: string);
    procedure AnalyzeDatabase;
    procedure BackupDatabase(const ADatabasePath: string; out ABackupPath: string);
    procedure ConfigureConnection(const AConnection: TFDConnection;
      const ADatabasePath: string);
    procedure CopySeasonalGroupsToPlaylist(const AConnection: TFDConnection);
    function DatabaseRootForLogs(const ADatabasePath: string): string;
    function DefaultDatabasePath: string;
    function DetectDatabaseVersion(const AConnection: TFDConnection): string;
    procedure EnsurePLSettingsSchema(const AConnection: TFDConnection);
    procedure EnsureRandomDirectorySchema(const AConnection: TFDConnection);
    procedure EnsureRequiredTables(const AConnection: TFDConnection);
    procedure EnsureSilenceScheduleSchema(const AConnection: TFDConnection);
    procedure EnsureTableRows(const AConnection: TFDConnection);
    function LastSqliteChangeCount(const AConnection: TFDConnection): Integer;
    procedure NormalizeAllTimeColumns(const AConnection: TFDConnection);
    procedure NormalizeTimeColumn(const AConnection: TFDConnection;
      const ATableName, AColumnName: string; const AWithMilliseconds: Boolean);
    function NormalizeTimeText(const AValue: string;
      const AWithMilliseconds: Boolean): string;
    procedure RunUpgrade(const ADatabasePath: string);
    procedure SaveReport(const ADatabasePath: string; out AReportPath: string);
    procedure SetDatabasePath(const APath: string);
    function TableExists(const AConnection: TFDConnection;
      const ATableName: string): Boolean;
    function TableHasColumn(const AConnection: TFDConnection;
      const ATableName, AColumnName: string): Boolean;
  public
    destructor Destroy; override;
  end;

var
  frmDBUpgrade724To81: TfrmDBUpgrade724To81;

implementation

{$R *.fmx}

uses
  FireDAC.DApt,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  System.DateUtils,
  System.IOUtils,
  System.Types;

procedure TfrmDBUpgrade724To81.AddReportLine(const AText: string);
begin
  FReportLines.Add(AText);
  memoReport.Lines.Add(AText);
  memoReport.GoToTextEnd;
end;

procedure TfrmDBUpgrade724To81.AnalyzeDatabase;
var
  Connection: TFDConnection;
  DatabasePath: string;
begin
  DatabasePath := Trim(edtDatabase.Text);
  lblStatus.Text := 'No database selected.';
  if DatabasePath = '' then
    Exit;
  if not TFile.Exists(DatabasePath) then
  begin
    lblStatus.Text := 'Database not found.';
    Exit;
  end;

  Connection := TFDConnection.Create(nil);
  try
    ConfigureConnection(Connection, DatabasePath);
    Connection.Connected := True;
    lblStatus.Text := 'Detected database: ' + DetectDatabaseVersion(Connection);
  except
    on E: Exception do
      lblStatus.Text := 'Could not inspect database: ' + E.Message;
  end;
  Connection.Free;
end;

procedure TfrmDBUpgrade724To81.BackupDatabase(const ADatabasePath: string;
  out ABackupPath: string);
var
  BackupDir: string;
  Stamp: string;
begin
  BackupDir := TPath.Combine(TPath.GetDirectoryName(ADatabasePath), 'backup');
  TDirectory.CreateDirectory(BackupDir);
  Stamp := FormatDateTime('yyyymmdd_hhnnss', Now);
  ABackupPath := TPath.Combine(BackupDir,
    'carillon7_2_4_before_8_1_upgrade_' + Stamp + '.db');
  TFile.Copy(ADatabasePath, ABackupPath, False);
  AddReportLine('Backup created: ' + ABackupPath);
end;

procedure TfrmDBUpgrade724To81.btnBrowseClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'Carillon SQLite database (*.db)|*.db|All files (*.*)|*.*';
  OpenDialog1.Title := 'Select Carillon 7.2.4 database';
  if TFile.Exists(Trim(edtDatabase.Text)) then
    OpenDialog1.FileName := Trim(edtDatabase.Text);
  if OpenDialog1.Execute then
    SetDatabasePath(OpenDialog1.FileName);
end;

procedure TfrmDBUpgrade724To81.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDBUpgrade724To81.btnUpgradeClick(Sender: TObject);
var
  DatabasePath: string;
begin
  DatabasePath := Trim(edtDatabase.Text);
  if DatabasePath = '' then
  begin
    ShowMessage('Select a Carillon database first.');
    Exit;
  end;
  if not TFile.Exists(DatabasePath) then
  begin
    ShowMessage('The selected database does not exist.');
    Exit;
  end;
  if not chkConfirmBackup.IsChecked then
  begin
    ShowMessage('Check the confirmation box before upgrading.');
    Exit;
  end;

  btnUpgrade.Enabled := False;
  btnBrowse.Enabled := False;
  try
    RunUpgrade(DatabasePath);
  finally
    btnBrowse.Enabled := True;
    btnUpgrade.Enabled := True;
  end;
end;

procedure TfrmDBUpgrade724To81.ConfigureConnection(
  const AConnection: TFDConnection; const ADatabasePath: string);
begin
  AConnection.LoginPrompt := False;
  AConnection.Params.Clear;
  AConnection.Params.Values['DriverID'] := 'SQLite';
  AConnection.Params.Values['Database'] := ADatabasePath;
  AConnection.Params.Values['OpenMode'] := 'ReadWrite';
  AConnection.Params.Values['LockingMode'] := 'Normal';
  AConnection.Params.Values['BusyTimeout'] := '10000';
end;

procedure TfrmDBUpgrade724To81.CopySeasonalGroupsToPlaylist(
  const AConnection: TFDConnection);
var
  RowsChanged: Integer;
begin
  AConnection.ExecSQL(
    'UPDATE playlist SET ' +
    'play_date_from = COALESCE((SELECT PLAY_DATE_FROM FROM seasonalgroups ' +
    'WHERE seasonalgroups.SEASONALGROUP = playlist.season), play_date_from), ' +
    'play_date_to = COALESCE((SELECT PLAY_DATE_TO FROM seasonalgroups ' +
    'WHERE seasonalgroups.SEASONALGROUP = playlist.season), play_date_to), ' +
    'scheduled_time1 = COALESCE((SELECT PLAY_TIME FROM seasonalgroups ' +
    'WHERE seasonalgroups.SEASONALGROUP = playlist.season), scheduled_time1) ' +
    'WHERE COALESCE(TRIM(season), '''') <> '''' ' +
    'AND EXISTS (SELECT 1 FROM seasonalgroups ' +
    'WHERE seasonalgroups.SEASONALGROUP = playlist.season)');
  RowsChanged := LastSqliteChangeCount(AConnection);
  AddReportLine('Seasonal group dates/times copied to playlist rows: ' +
    RowsChanged.ToString);
end;

function TfrmDBUpgrade724To81.DatabaseRootForLogs(
  const ADatabasePath: string): string;
var
  DatabaseDir: string;
  ParentDir: string;
begin
  DatabaseDir := TPath.GetDirectoryName(ADatabasePath);
  ParentDir := TPath.GetDirectoryName(DatabaseDir);
  if SameText(TPath.GetFileName(DatabaseDir), 'databases') and
    (ParentDir <> '') then
    Result := ParentDir
  else
    Result := DatabaseDir;
end;

function TfrmDBUpgrade724To81.DefaultDatabasePath: string;
begin
  Result := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)),
    'databases'), 'carillon.db');
end;

destructor TfrmDBUpgrade724To81.Destroy;
begin
  FReportLines.Free;
  inherited Destroy;
end;

function TfrmDBUpgrade724To81.DetectDatabaseVersion(
  const AConnection: TFDConnection): string;
begin
  if TableExists(AConnection, 'silence_schedule') and
    TableExists(AConnection, 'PL_RAND_DIR_ROTATION') and
    TableHasColumn(AConnection, 'PL_RAND_DIR_ROTATION', 'slot_no') then
    Exit('8.1-compatible');

  if TableExists(AConnection, 'PL_RAND_DIR_ROTATION') and
    (not TableHasColumn(AConnection, 'PL_RAND_DIR_ROTATION', 'slot_no')) then
    Exit('7.2.4 wide random-directory format');

  Result := 'unknown or partially upgraded';
end;

procedure TfrmDBUpgrade724To81.edtDatabaseChange(Sender: TObject);
begin
  if not FSuppressChange then
    AnalyzeDatabase;
end;

procedure TfrmDBUpgrade724To81.EnsurePLSettingsSchema(
  const AConnection: TFDConnection);

  procedure AddColumnIfMissing(const AColumnName, ADefinition: string);
  begin
    if not TableHasColumn(AConnection, 'PL_SETTINGS', AColumnName) then
    begin
      AConnection.ExecSQL('ALTER TABLE PL_SETTINGS ADD COLUMN ' + ADefinition);
      AddReportLine('Added PL_SETTINGS column: ' + AColumnName);
    end;
  end;

begin
  if not TableExists(AConnection, 'PL_SETTINGS') then
  begin
    AConnection.ExecSQL(
      'CREATE TABLE PL_SETTINGS (' +
      'ORGANIZATION_NAME TEXT CHECK (LENGTH(ORGANIZATION_NAME) <= 100), ' +
      'RAND_SONGS_DIRECTORY TEXT CHECK (LENGTH(RAND_SONGS_DIRECTORY) <= 150))');
    AddReportLine('Created PL_SETTINGS table.');
  end;

  AddColumnIfMissing('LOGGING_STATUS',
    'LOGGING_STATUS INTEGER DEFAULT 0 CHECK (LOGGING_STATUS IN (0, 1))');
  AddColumnIfMissing('form_bgcolor', 'form_bgcolor TEXT');
  AddColumnIfMissing('form_fontcolor', 'form_fontcolor TEXT');
  AddColumnIfMissing('all_souls_day', 'all_souls_day DATE');
  AddColumnIfMissing('other_silence_begin_date',
    'other_silence_begin_date DATE');
  AddColumnIfMissing('other_silence_end_date', 'other_silence_end_date DATE');
  AddColumnIfMissing('silence_enabled',
    'silence_enabled INTEGER DEFAULT 1');
  AddColumnIfMissing('ash_wed_begin', 'ash_wed_begin DATE');
  AddColumnIfMissing('ash_wed_end', 'ash_wed_end DATE');
  AddColumnIfMissing('holy_thu_begin', 'holy_thu_begin DATE');
  AddColumnIfMissing('holy_sat_end', 'holy_sat_end DATE');
  AddColumnIfMissing('other_silence_begin_time',
    'other_silence_begin_time TIME');
  AddColumnIfMissing('other_silence_end_time', 'other_silence_end_time TIME');
  AddColumnIfMissing('email_enabled', 'email_enabled INTEGER DEFAULT 0');
  AddColumnIfMissing('email_recipients', 'email_recipients TEXT');
  AddColumnIfMissing('email_user', 'email_user TEXT');
  AddColumnIfMissing('email_password', 'email_password TEXT');
  AddColumnIfMissing('smtp_host', 'smtp_host TEXT');
  AddColumnIfMissing('smtp_port', 'smtp_port INTEGER');
  AddColumnIfMissing('from_address', 'from_address TEXT');
  AddColumnIfMissing('test_recipient', 'test_recipient TEXT');
  AddColumnIfMissing('morning_report_recipients',
    'morning_report_recipients TEXT');

  AConnection.ExecSQL(
    'INSERT INTO PL_SETTINGS ' +
    '(ORGANIZATION_NAME, RAND_SONGS_DIRECTORY, LOGGING_STATUS, ' +
    'smtp_host, smtp_port, from_address) ' +
    'SELECT ''Your Organization Name Here'', ''.\Random_songs'', 0, ' +
    '''smtp.gmail.com'', 587, ''Westminster Chimes'' ' +
    'WHERE NOT EXISTS (SELECT 1 FROM PL_SETTINGS)');
end;

procedure TfrmDBUpgrade724To81.EnsureRandomDirectorySchema(
  const AConnection: TFDConnection);
var
  BackupTable: string;
  I: Integer;
begin
  if TableExists(AConnection, 'PL_RAND_DIR_ROTATION') and
    (not TableHasColumn(AConnection, 'PL_RAND_DIR_ROTATION', 'slot_no')) then
  begin
    if TableExists(AConnection, 'PL_RAND_DIR_ROTATION_WIDE_BACKUP') then
      BackupTable := 'PL_RAND_DIR_ROTATION_WIDE_BACKUP_' +
        FormatDateTime('yyyymmddhhnnss', Now)
    else
      BackupTable := 'PL_RAND_DIR_ROTATION_WIDE_BACKUP';

    AConnection.ExecSQL('ALTER TABLE PL_RAND_DIR_ROTATION RENAME TO ' +
      BackupTable);
    AddReportLine('Renamed wide random-directory table to ' + BackupTable);

    AConnection.ExecSQL(
      'CREATE TABLE PL_RAND_DIR_ROTATION (' +
      'slot_no INTEGER PRIMARY KEY CHECK (slot_no BETWEEN 1 AND 7), ' +
      'rand_music_dir TEXT CHECK (LENGTH(rand_music_dir) <= 150), ' +
      'frm_date DATE, to_date DATE)');

    for I := 1 to 7 do
      AConnection.ExecSQL(Format(
        'INSERT INTO PL_RAND_DIR_ROTATION ' +
        '(slot_no, rand_music_dir, frm_date, to_date) ' +
        'SELECT %d, rand_music_dir%d, frm_date%d, to_date%d FROM %s ' +
        'WHERE id = 1', [I, I, I, I, BackupTable]));
    AddReportLine('Converted random-directory slots to row-based 8.1 format.');
  end
  else if not TableExists(AConnection, 'PL_RAND_DIR_ROTATION') then
  begin
    AConnection.ExecSQL(
      'CREATE TABLE PL_RAND_DIR_ROTATION (' +
      'slot_no INTEGER PRIMARY KEY CHECK (slot_no BETWEEN 1 AND 7), ' +
      'rand_music_dir TEXT CHECK (LENGTH(rand_music_dir) <= 150), ' +
      'frm_date DATE, to_date DATE)');
    AddReportLine('Created row-based random-directory table.');
  end;

  for I := 1 to 7 do
    AConnection.ExecSQL(
      'INSERT INTO PL_RAND_DIR_ROTATION (slot_no) ' +
      'SELECT :slot_no WHERE NOT EXISTS (' +
      'SELECT 1 FROM PL_RAND_DIR_ROTATION WHERE slot_no = :slot_no)',
      [I]);
  AddReportLine('Verified random-directory slots 1 through 7.');
end;

procedure TfrmDBUpgrade724To81.EnsureRequiredTables(
  const AConnection: TFDConnection);
begin
  if not TableExists(AConnection, 'playlist') then
    raise Exception.Create('Required table missing: playlist');
  if not TableExists(AConnection, 'seasonalgroups') then
    raise Exception.Create('Required table missing: seasonalgroups');
end;

procedure TfrmDBUpgrade724To81.EnsureSilenceScheduleSchema(
  const AConnection: TFDConnection);
var
  I: Integer;
begin
  AConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS silence_schedule (' +
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
    'sunday INTEGER NOT NULL DEFAULT 0)');

  for I := 1 to 12 do
    AConnection.ExecSQL(
      'INSERT OR IGNORE INTO silence_schedule ' +
      '(silence_id, enabled, Purpose, start_time, end_time, monday, tuesday, ' +
      'wednesday, thursday, friday, saturday, sunday) ' +
      'VALUES (:silence_id, 0, :purpose, NULL, NULL, 0, 0, 0, 0, 0, 0, 0)',
      [I, 'Silence Window ' + I.ToString]);
  AddReportLine('Verified silence_schedule table and 12 disabled rows.');
end;

procedure TfrmDBUpgrade724To81.EnsureTableRows(
  const AConnection: TFDConnection);
begin
  EnsureRequiredTables(AConnection);
  EnsurePLSettingsSchema(AConnection);
  EnsureRandomDirectorySchema(AConnection);
  EnsureSilenceScheduleSchema(AConnection);
end;

procedure TfrmDBUpgrade724To81.FormCreate(Sender: TObject);
begin
  FReportLines := TStringList.Create;
  memoReport.Lines.Clear;
  SetDatabasePath(DefaultDatabasePath);
end;

function TfrmDBUpgrade724To81.LastSqliteChangeCount(
  const AConnection: TFDConnection): Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text := 'SELECT changes() AS row_count';
    Query.Open;
    if not Query.IsEmpty then
      Result := Query.FieldByName('row_count').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TfrmDBUpgrade724To81.NormalizeAllTimeColumns(
  const AConnection: TFDConnection);
var
  I: Integer;
begin
  for I := 1 to 12 do
    NormalizeTimeColumn(AConnection, 'playlist', 'scheduled_time' +
      I.ToString, True);
  NormalizeTimeColumn(AConnection, 'seasonalgroups', 'PLAY_TIME', True);
  NormalizeTimeColumn(AConnection, 'PL_SETTINGS', 'other_silence_begin_time',
    False);
  NormalizeTimeColumn(AConnection, 'PL_SETTINGS', 'other_silence_end_time',
    False);
  NormalizeTimeColumn(AConnection, 'silence_schedule', 'start_time', False);
  NormalizeTimeColumn(AConnection, 'silence_schedule', 'end_time', False);
end;

procedure TfrmDBUpgrade724To81.NormalizeTimeColumn(
  const AConnection: TFDConnection; const ATableName, AColumnName: string;
  const AWithMilliseconds: Boolean);
var
  Normalized: string;
  Query: TFDQuery;
  UpdateQuery: TFDQuery;
  UpdatedCount: Integer;
begin
  if not TableExists(AConnection, ATableName) then
    Exit;
  if not TableHasColumn(AConnection, ATableName, AColumnName) then
    Exit;

  UpdatedCount := 0;
  Query := TFDQuery.Create(nil);
  UpdateQuery := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    UpdateQuery.Connection := AConnection;
    Query.SQL.Text := Format(
      'SELECT rowid AS row_id, %s AS time_value FROM %s ' +
      'WHERE %s IS NOT NULL AND TRIM(%s) <> ''''',
      [AColumnName, ATableName, AColumnName, AColumnName]);
    UpdateQuery.SQL.Text := Format(
      'UPDATE %s SET %s = :time_value WHERE rowid = :row_id',
      [ATableName, AColumnName]);
    Query.Open;
    while not Query.Eof do
    begin
      Normalized := NormalizeTimeText(Query.FieldByName('time_value').AsString,
        AWithMilliseconds);
      if (Normalized <> '') and
        (Normalized <> Query.FieldByName('time_value').AsString) then
      begin
        UpdateQuery.ParamByName('time_value').AsString := Normalized;
        UpdateQuery.ParamByName('row_id').AsInteger :=
          Query.FieldByName('row_id').AsInteger;
        UpdateQuery.ExecSQL;
        Inc(UpdatedCount);
      end;
      Query.Next;
    end;
  finally
    Query.Free;
    UpdateQuery.Free;
  end;

  if UpdatedCount > 0 then
    AddReportLine(Format('Normalized %s.%s time values: %d',
      [ATableName, AColumnName, UpdatedCount]));
end;

function TfrmDBUpgrade724To81.NormalizeTimeText(const AValue: string;
  const AWithMilliseconds: Boolean): string;
var
  Hours: Integer;
  LText: string;
  Minutes: Integer;
  Parts: TArray<string>;
  Seconds: Integer;
  Suffix: string;
  DotPos: Integer;
begin
  Result := '';
  LText := UpperCase(Trim(AValue));
  if LText = '' then
    Exit;

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

  Parts := LText.Split([':']);
  if (Length(Parts) < 2) or (Length(Parts) > 3) then
    Exit;
  if not TryStrToInt(Trim(Parts[0]), Hours) then
    Exit;
  if not TryStrToInt(Trim(Parts[1]), Minutes) then
    Exit;

  Seconds := 0;
  if Length(Parts) = 3 then
  begin
    Parts[2] := Trim(Parts[2]);
    DotPos := Pos('.', Parts[2]);
    if DotPos > 0 then
      Parts[2] := Copy(Parts[2], 1, DotPos - 1);
    if Parts[2] <> '' then
      if not TryStrToInt(Parts[2], Seconds) then
        Exit;
  end;

  if (Minutes < 0) or (Minutes > 59) or (Seconds < 0) or
    (Seconds > 59) then
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

  Result := Format('%.2d:%.2d:%.2d', [Hours, Minutes, Seconds]);
  if AWithMilliseconds then
    Result := Result + '.000';
end;

procedure TfrmDBUpgrade724To81.RunUpgrade(const ADatabasePath: string);
var
  BackupPath: string;
  Connection: TFDConnection;
  ReportPath: string;
begin
  BackupPath := '';
  Connection := nil;
  memoReport.Lines.Clear;
  FReportLines.Clear;
  AddReportLine('Carillon database upgrade 7.2.4 to 8.1');
  AddReportLine('Started: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
  AddReportLine('Database: ' + ADatabasePath);

  try
    try
      BackupDatabase(ADatabasePath, BackupPath);
      Connection := TFDConnection.Create(nil);
      ConfigureConnection(Connection, ADatabasePath);
      Connection.Connected := True;
      AddReportLine('Before upgrade: ' + DetectDatabaseVersion(Connection));

      Connection.StartTransaction;
      try
        EnsureTableRows(Connection);
        CopySeasonalGroupsToPlaylist(Connection);
        NormalizeAllTimeColumns(Connection);
        Connection.Commit;
      except
        Connection.Rollback;
        raise;
      end;

      AddReportLine('After upgrade: ' + DetectDatabaseVersion(Connection));
      AddReportLine('Finished: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
      SaveReport(ADatabasePath, ReportPath);
      AddReportLine('Report saved: ' + ReportPath);
      lblStatus.Text := 'Upgrade complete. Backup and report were created.';
      ShowMessage('Database upgrade complete.' + sLineBreak + sLineBreak +
        'Backup:' + sLineBreak + BackupPath + sLineBreak + sLineBreak +
        'Report:' + sLineBreak + ReportPath);
    except
      on E: Exception do
      begin
        AddReportLine('ERROR: ' + E.Message);
        try
          SaveReport(ADatabasePath, ReportPath);
        except
          ReportPath := '';
        end;
        lblStatus.Text := 'Upgrade failed: ' + E.Message;
        if BackupPath <> '' then
          ShowMessage('Upgrade failed. The original database backup was created.' +
            sLineBreak + sLineBreak + E.Message)
        else
          ShowMessage('Upgrade failed before the database backup could be created.' +
            sLineBreak + sLineBreak + E.Message);
      end;
    end;
  finally
    Connection.Free;
  end;
  AnalyzeDatabase;
end;

procedure TfrmDBUpgrade724To81.SaveReport(const ADatabasePath: string;
  out AReportPath: string);
var
  LogsDir: string;
begin
  LogsDir := TPath.Combine(DatabaseRootForLogs(ADatabasePath), 'logs');
  TDirectory.CreateDirectory(LogsDir);
  AReportPath := TPath.Combine(LogsDir,
    'DatabaseUpgrade_724_to_81_' + FormatDateTime('yyyymmdd_hhnnss', Now) +
    '.txt');
  FReportLines.SaveToFile(AReportPath, TEncoding.UTF8);
end;

procedure TfrmDBUpgrade724To81.SetDatabasePath(const APath: string);
begin
  FSuppressChange := True;
  try
    edtDatabase.Text := APath;
  finally
    FSuppressChange := False;
  end;
  AnalyzeDatabase;
end;

function TfrmDBUpgrade724To81.TableExists(const AConnection: TFDConnection;
  const ATableName: string): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text :=
      'SELECT name FROM sqlite_master WHERE type = ''table'' AND name = :name';
    Query.ParamByName('name').AsString := ATableName;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

function TfrmDBUpgrade724To81.TableHasColumn(const AConnection: TFDConnection;
  const ATableName, AColumnName: string): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text := 'PRAGMA table_info(' + ATableName + ')';
    Query.Open;
    while not Query.Eof do
    begin
      if SameText(Query.FieldByName('name').AsString, AColumnName) then
        Exit(True);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

end.
