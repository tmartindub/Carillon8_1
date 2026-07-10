unit email;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  Data.Bind.DBScope,
  Data.DB,
  DateUtils,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FMX.Controls,
  FMX.DialogService.Sync,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Memo,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  Fmx.Bind.Navigator,
  IdBaseComponent,
  IdComponent,
  IdExplicitTLSClientServerBase,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdMessage,
  IdMessageClient,
  IdSMTP,
  IdSSL,
  IdSSLOpenSSL,
  IdTCPClient,
  IdTCPConnection,
  Math,
  System.Classes,
  System.Rtti,
  System.SysUtils,
  System.UIConsts,
  System.UITypes,
  System.Variants,
  Winapi.Windows, FMX.Memo.Types, FMX.ScrollBox, FMX.Controls.Presentation,
  IdCTypes, IdSSLOpenSSLHeaders;
type
  TEmailConfig = record
    Enabled: Boolean;
    Username: string;
    Password: string;
    Host: string;
    Port: Integer;
    Recipients: string;
    MorningRecipients: string;
    TestRecipient: string;
  end;
  TFormSettings = record
    BGColor: TAlphaColor;
    FontColor: TAlphaColor;
  end;
  TfrmEmailSettings = class(TForm)
    memRecipients: TMemo;
    chkEnableEmail: TCheckBox;
    edtTestRecipient: TEdit;
    btnSave: TButton;
    btnClose: TButton;
    btnTest: TButton;
    lblRecipients: TLabel;
    lblEnableEmail: TLabel;
    lblTestRecipient: TLabel;
    lblHeader: TLabel;
    FDConnection1: TFDConnection;
    EmailQuery: TFDQuery;
    EmailDataSource: TDataSource;
    DBNavigator1: TBindNavigator;
    edtEmailUser: TEdit;
    edtAppPassword: TEdit;
    edtSMTPHost: TEdit;
    edtSMTPPort: TEdit;
    SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    chkShowPassword: TCheckBox;
    memMorningRecipients: TMemo;
    Timer1: TTimer;
    btnSendMorningReport: TButton;
    Panel1: TPanel;
    Label3: TLabel;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkShowPasswordClick(Sender: TObject);
    procedure SendMorningReport;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSendMorningReportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FGeneratedOriginalOnDestroy: TNotifyEvent;
    FGeneratedShuttingDown: Boolean;
    FGeneratedToggleSuppress_chkShowPassword: Integer;
    FGeneratedToggleOriginalClick_chkShowPassword: TNotifyEvent;
    FGeneratedToggleOriginalChange_chkShowPassword: TNotifyEvent;
    FGeneratedFormCreateRan: Boolean;
    FLoadingEmailControls: Boolean;
    FEmailConfig: TEmailConfig;
    FFormSettings: TFormSettings;
    BindSourceDB_EmailDataSource: TBindSourceDB;
    procedure GeneratedFormDestroyHandler(Sender: TObject);
    procedure chkShowPassword_GeneratedUserChange(Sender: TObject);
    procedure EmailControlChanged(Sender: TObject);
    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    function HasPendingEmailChanges: Boolean;
    function SavePendingEmailChanges: Boolean;
    function ConfirmCloseWithPendingEmailChanges: Boolean;
    procedure DiscardPendingEmailChanges;
    procedure LoadEmailSettings;
    procedure LoadFormSettings;
    procedure ApplyFormSettings;
    procedure SendTestEmail;
    function HTMLSafe(const S: string): string;
    function ExecuteSettingsQuery(const ASQL: string): TFDQuery;
    function ValidateEmailSettings: Boolean;
  public
    class procedure SendEmailIfEnabled(const Msg, Recipients: string);
  end;
var
  frmEmailSettings: TfrmEmailSettings;
implementation
uses
  CarillonTheme,
  LogManager,
  playlist,
  System.IOUtils,
  System.StrUtils;
{$R *.fmx}

function FindNamedChild(const Root: TFmxObject; const AName: string): TFmxObject;
var
  I: Integer;
  Child: TFmxObject;
begin
  Result := nil;
  if Root = nil then
    Exit;
  if SameText(Root.Name, AName) then
    Exit(Root);
  for I := 0 to Root.ChildrenCount - 1 do
  begin
    Child := FindNamedChild(Root.Children[I], AName);
    if Child <> nil then
      Exit(Child);
  end;
end;
procedure SetStatusBarPanelText(const AStatusBar: TStatusBar; const AIndex: Integer; const AText: string);
var
  Obj: TFmxObject;
begin
  if AStatusBar = nil then
    Exit;
  Obj := FindNamedChild(AStatusBar, AStatusBar.Name + 'Panel' + IntToStr(AIndex));
  if Obj is TLabel then
    TLabel(Obj).Text := AText;
end;
function GetStatusBarPanelText(const AStatusBar: TStatusBar; const AIndex: Integer): string;
var
  Obj: TFmxObject;
begin
  Result := '';
  if AStatusBar = nil then
    Exit;
  Obj := FindNamedChild(AStatusBar, AStatusBar.Name + 'Panel' + IntToStr(AIndex));
  if Obj is TLabel then
    Result := TLabel(Obj).Text;
end;
var
  LastReportDate: TDate;
// -------- Helpers (local to this unit) --------
function FormatUptimeFromSeconds(const TotalSeconds: Int64): string;
var
  Days, Hours, Minutes, Seconds: Int64;
begin
  Days := TotalSeconds div 86400;
  Hours := (TotalSeconds mod 86400) div 3600;
  Minutes := (TotalSeconds mod 3600) div 60;
  Seconds := TotalSeconds mod 60;
  Result := Format('%d days %d hours %d minutes %d seconds', [Days, Hours, Minutes, Seconds]);
end;
function GetBootTime: TDateTime;
begin
  Result := Now - (GetTickCount64 / MSecsPerDay);
end;
function GetWindowsUptimeSeconds: Int64;
begin
  Result := GetTickCount64 div 1000;
end;
function FileSizeToGB(const Bytes: UInt64): Double;
begin
  Result := Bytes / (1024 * 1024 * 1024);
end;
function GetDiskUsage(const DriveRoot: string; out UsedGB, FreeGB, TotalGB, UsedPct: Double): Boolean;
var
  FreeAvail, TotalBytes, TotalFree: UInt64;
begin
  Result := False;
  UsedGB := 0; FreeGB := 0; TotalGB := 0; UsedPct := 0;
  if GetDiskFreeSpaceEx(PChar(DriveRoot), FreeAvail, TotalBytes, @TotalFree) then
  begin
    TotalGB := FileSizeToGB(TotalBytes);
    FreeGB := FileSizeToGB(TotalFree);
    UsedGB := TotalGB - FreeGB;
    if TotalGB > 0 then
      UsedPct := (UsedGB / TotalGB) * 100.0;
    Result := True;
  end;
end;
function GetMemoryUsage(out UsedMB, TotalMB: UInt64; out UsedPct: Double): Boolean;
var
  MS: TMemoryStatusEx;
begin
  Result := False;
  UsedMB := 0; TotalMB := 0; UsedPct := 0;
  ZeroMemory(@MS, SizeOf(MS));
  MS.dwLength := SizeOf(MS);
  if GlobalMemoryStatusEx(MS) then
  begin
    TotalMB := MS.ullTotalPhys div (1024*1024);
    UsedMB := (MS.ullTotalPhys - MS.ullAvailPhys) div (1024*1024);
    if TotalMB > 0 then
      UsedPct := (UsedMB / TotalMB) * 100.0;
    Result := True;
  end;
end;
function FileTimeToInt64(const FT: TFileTime): UInt64;
begin
  Result := (UInt64(FT.dwHighDateTime) shl 32) or UInt64(FT.dwLowDateTime);
end;
function GetCPUUsagePercent: Double;
var
  Idle1, Kernel1, User1: TFileTime;
  Idle2, Kernel2, User2: TFileTime;
  I1, K1, U1, I2, K2, U2: UInt64;
  Sys1, Sys2, SysDelta, IdleDelta: UInt64;
begin
  Result := 0.0;
  if not GetSystemTimes(Idle1, Kernel1, User1) then Exit;
  Sleep(200);
  if not GetSystemTimes(Idle2, Kernel2, User2) then Exit;
  I1 := FileTimeToInt64(Idle1); K1 := FileTimeToInt64(Kernel1); U1 := FileTimeToInt64(User1);
  I2 := FileTimeToInt64(Idle2); K2 := FileTimeToInt64(Kernel2); U2 := FileTimeToInt64(User2);
  Sys1 := (K1 + U1);
  Sys2 := (K2 + U2);
  if Sys2 <= Sys1 then Exit;
  SysDelta := Sys2 - Sys1;
  IdleDelta := I2 - I1;
  if SysDelta = 0 then Exit;
  Result := (1.0 - (IdleDelta / SysDelta)) * 100.0;
  if Result < 0 then Result := 0;
  if Result > 100 then Result := 100;
end;
function TryParseDurationToSeconds(const S: string; out Secs: Int64): Boolean;
var
  T: TDateTime;
  Parts: TArray<string>;
  H, M, Se: Int64;
begin
  Result := False;
  Secs := 0;
  if S.Trim = '' then Exit;
  // Try Delphi time parsing first
  if TryStrToTime(S, T) then
  begin
    Secs := Round(T * 86400);
    Exit(True);
  end;
  // Try simple "mm:ss" or "hh:mm:ss"
  Parts := S.Trim.Split([':']);
  try
    if Length(Parts) = 2 then
    begin
      M := StrToIntDef(Parts[0], -1);
      Se := StrToIntDef(Parts[1], -1);
      if (M >= 0) and (Se >= 0) then
      begin
        Secs := M*60 + Se;
        Exit(True);
      end;
    end
    else if Length(Parts) = 3 then
    begin
      H := StrToIntDef(Parts[0], -1);
      M := StrToIntDef(Parts[1], -1);
      Se := StrToIntDef(Parts[2], -1);
      if (H >= 0) and (M >= 0) and (Se >= 0) then
      begin
        Secs := H*3600 + M*60 + Se;
        Exit(True);
      end;
    end;
  except
  end;
end;
function SecondsToHMS(const Secs: Int64): string;
var
  H, M, S: Int64;
begin
  H := Secs div 3600;
  M := (Secs mod 3600) div 60;
  S := Secs mod 60;
  Result := Format('%.2d:%.2d:%.2d', [H, M, S]);
end;
function FormatAppUptimeFromStartTime(const StartTime: TDateTime): string;
var
  TotalYears, TotalMonths, RemainingDays, TotalWeeks: Integer;
  Days, Hours, Minutes, Seconds: Integer;
begin
  if (StartTime <= 0) or (StartTime > Now) then
    Exit('Unknown');
  TotalYears := YearsBetween(StartTime, Now);
  TotalMonths := MonthsBetween(IncYear(StartTime, TotalYears), Now);
  RemainingDays := DaysBetween(IncMonth(IncYear(StartTime, TotalYears), TotalMonths), Now);
  TotalWeeks := RemainingDays div 7;
  Days := RemainingDays mod 7;
  Hours := HoursBetween(StartTime, Now) mod 24;
  Minutes := MinutesBetween(StartTime, Now) mod 60;
  Seconds := SecondsBetween(StartTime, Now) mod 60;
  Result := Format('%d years %d months %d weeks %d days %d hours %d minutes %d seconds',
    [TotalYears, TotalMonths, TotalWeeks, Days, Hours, Minutes, Seconds]);
end;
// -------- End helpers --------
procedure TfrmEmailSettings.FormCreate(Sender: TObject);
begin
  FGeneratedOriginalOnDestroy := Self.OnDestroy;
  Self.OnDestroy := GeneratedFormDestroyHandler;
  Self.OnCloseQuery := FormCloseQuery;
  if FGeneratedFormCreateRan then
    Exit;
  FGeneratedFormCreateRan := True;
  ConfigurePortableSQLiteConnection(FDConnection1);
  FDConnection1.connected := True;
  EmailQuery.Connection := FDConnection1;
  EmailQuery.SQL.Text := 'SELECT * FROM pl_settings';
  EmailQuery.Open;
  EmailDataSource.DataSet := EmailQuery;
  if BindSourceDB_EmailDataSource = nil then
  begin
    BindSourceDB_EmailDataSource := TBindSourceDB.Create(Self);
    BindSourceDB_EmailDataSource.DataSource := EmailDataSource;
  end;
  if Assigned(DBNavigator1) then
  begin
    DBNavigator1.DataSource := BindSourceDB_EmailDataSource;
    DBNavigator1.BeforeAction := DBNavigator1BeforeAction;
  end;
  chkEnableEmail.OnChange := EmailControlChanged;
  memRecipients.OnChange := EmailControlChanged;
  memMorningRecipients.OnChange := EmailControlChanged;
  edtTestRecipient.OnChangeTracking := EmailControlChanged;
  edtEmailUser.OnChangeTracking := EmailControlChanged;
  edtAppPassword.OnChangeTracking := EmailControlChanged;
  edtSMTPHost.OnChangeTracking := EmailControlChanged;
  edtSMTPPort.OnChangeTracking := EmailControlChanged;
  LoadEmailSettings;
  if TimeOf(Now) >= EncodeTime(5, 0, 0, 0) then
    LastReportDate := DateOf(Now) // Already past time ? don't send again
  else
    LastReportDate := 0; // Not yet sent today
  Timer1.Interval := 60000;
  Timer1.Enabled := True;
  // Generated FMX LiveBindings from original VCL data-aware controls
  if Assigned(chkShowPassword) then
  begin
    FGeneratedToggleOriginalClick_chkShowPassword := chkShowPassword.OnClick;
    FGeneratedToggleOriginalChange_chkShowPassword := chkShowPassword.OnChange;
    chkShowPassword.OnClick := nil;
    chkShowPassword.OnChange := chkShowPassword_GeneratedUserChange;
  end;
end;
procedure TfrmEmailSettings.EmailControlChanged(Sender: TObject);
begin
  if FLoadingEmailControls then
    Exit;
  if EmailQuery.Active and (not EmailQuery.IsEmpty) and not (EmailQuery.State in dsEditModes) then
    EmailQuery.Edit;
end;

procedure TfrmEmailSettings.DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
begin
  case Button of
    TBindNavigateBtn.nbPost:
    begin
      if not ValidateEmailSettings then
      begin
        if TDialogServiceSync.MessageDialog(
          'All Email settings are not filled in correctly.' + #13#10 +
          'If you continue, email of events and reports will not send.' +
          #13#10#13#10 + 'Do you want to continue?', TMsgDlgType.mtConfirmation,
          mbYesNo, TMsgDlgBtn.mbYes, 0) <> mrYes then
          Abort;
      end;
      if EmailQuery.Active and (not EmailQuery.IsEmpty) then
      begin
        if not (EmailQuery.State in dsEditModes) then
          EmailQuery.Edit;
        EmailQuery.FieldByName('email_enabled').AsInteger := Ord(chkEnableEmail.IsChecked);
        EmailQuery.FieldByName('morning_report_recipients').AsString := memMorningRecipients.Text;
        EmailQuery.FieldByName('email_recipients').AsString := memRecipients.Text;
        EmailQuery.FieldByName('email_user').AsString := edtEmailUser.Text;
        EmailQuery.FieldByName('email_password').AsString := edtAppPassword.Text;
        EmailQuery.FieldByName('smtp_host').AsString := edtSMTPHost.Text;
        EmailQuery.FieldByName('smtp_port').AsInteger := StrToIntDef(edtSMTPPort.Text, 0);
        EmailQuery.FieldByName('test_recipient').AsString := edtTestRecipient.Text;
        EmailQuery.Post;
        EmailQuery.Refresh;
      end;
      LoadEmailSettings;
      Abort;
    end;
    TBindNavigateBtn.nbCancel:
    begin
      if EmailQuery.Active and (EmailQuery.State in dsEditModes) then
        EmailQuery.Cancel;
      if EmailQuery.Active then
        EmailQuery.Refresh;
      LoadEmailSettings;
      FormShow(Self);
      Abort;
    end;
  end;
end;
function TfrmEmailSettings.HasPendingEmailChanges: Boolean;
begin
  Result := EmailQuery.Active and (EmailQuery.State in dsEditModes);
end;
function TfrmEmailSettings.SavePendingEmailChanges: Boolean;
begin
  try
    DBNavigator1BeforeAction(Self, TBindNavigateBtn.nbPost);
    Result := not HasPendingEmailChanges;
  except
    on E: EAbort do
      Result := not HasPendingEmailChanges;
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
    end;
  end;
end;
procedure TfrmEmailSettings.DiscardPendingEmailChanges;
begin
  try
    DBNavigator1BeforeAction(Self, TBindNavigateBtn.nbCancel);
  except
    on E: EAbort do
      ;
  end;
end;
function TfrmEmailSettings.ConfirmCloseWithPendingEmailChanges: Boolean;
begin
  Result := True;
  if not HasPendingEmailChanges then
    Exit;
  case TDialogServiceSync.MessageDialog('Save changes before closing?',
    TMsgDlgType.mtConfirmation, mbYesNoCancel, TMsgDlgBtn.mbCancel, 0) of
    mrYes:
      Result := SavePendingEmailChanges;
    mrNo:
      begin
        DiscardPendingEmailChanges;
        Result := not HasPendingEmailChanges;
      end;
  else
    Result := False;
  end;
end;function TfrmEmailSettings.ExecuteSettingsQuery(const ASQL: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FDConnection1;
  Result.SQL.Text := ASQL;
  Result.Open;
end;
procedure TfrmEmailSettings.LoadEmailSettings;
var
  q: TFDQuery;
begin
  FLoadingEmailControls := True;
  q := ExecuteSettingsQuery('SELECT * FROM pl_settings');
  try
    with FEmailConfig do
    begin
      Enabled := q.FieldByName('email_enabled').AsInteger = 1;
      Username := q.FieldByName('email_user').AsString;
      Password := q.FieldByName('email_password').AsString;
      Host := q.FieldByName('smtp_host').AsString;
      Port := q.FieldByName('smtp_port').AsInteger;
      Recipients := q.FieldByName('email_recipients').AsString;
      MorningRecipients := q.FieldByName('morning_report_recipients').AsString;
      TestRecipient := q.FieldByName('test_recipient').AsString;
      FEmailConfig.Host := Trim(q.FieldByName('smtp_host').AsString);
      if FEmailConfig.Host = '' then
        if Assigned(fmDailyPlaylist) then
          fmDailyPlaylist.AddToLog('Email: SMTP host is missing - email will not send.');
    end;
  finally
    q.Free;
    FLoadingEmailControls := False;
  end;
  if EmailQuery.Active and (EmailQuery.State in dsEditModes) then
    EmailQuery.Cancel;
end;
procedure TfrmEmailSettings.LoadFormSettings;
var
  q: TFDQuery;
begin
  q := ExecuteSettingsQuery
    ('SELECT form_bgcolor, form_fontcolor FROM pl_settings');
  try
    if not q.IsEmpty then
    begin
      FFormSettings.BGColor := VCLColorToAlphaColor(q.FieldByName('form_bgcolor').AsInteger);
      FFormSettings.FontColor := VCLColorToAlphaColor(q.FieldByName('form_fontcolor').AsInteger);
    end
    else
    begin
      FFormSettings.BGColor := $8EBDDC;
      FFormSettings.FontColor := $000080;
    end;
  finally
    q.Free;
  end;
end;
procedure TfrmEmailSettings.ApplyFormSettings;
var
  i: Integer;
begin
  Self.Fill.Kind := TBrushKind.Solid;
  Self.Fill.Color := FFormSettings.BGColor;
  ApplyContainerBackgroundColor(Self, FFormSettings.BGColor);
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TLabel then
      TLabel(Components[i]).TextSettings.FontColor := FFormSettings.FontColor;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TButton then
      ApplyTieredButtonStyle(TButton(Components[i]), FFormSettings.BGColor,
        FFormSettings.FontColor)
    else if Components[i] is TEdit then
      ApplyCardEditStyle(TStyledControl(Components[i]), FFormSettings.BGColor,
        FFormSettings.FontColor)
    else if Components[i] is TMemo then
      ApplyCardEditStyle(TStyledControl(Components[i]), FFormSettings.BGColor,
        FFormSettings.FontColor);
  ApplyCurrentCarillonThemeToForm(Self);
end;
procedure TfrmEmailSettings.FormShow(Sender: TObject);
begin
  if not FGeneratedFormCreateRan then
    FormCreate(Self);
  LoadEmailSettings;
  LoadFormSettings;
  ApplyFormSettings;
  FLoadingEmailControls := True;
  try
    with FEmailConfig do
    begin
    chkEnableEmail.IsChecked := Enabled;
    memRecipients.Text := Recipients;
    edtEmailUser.Text := Username;
    edtAppPassword.Text := Password;
    edtSMTPHost.Text := Host;
    edtSMTPPort.Text := IntToStr(Port);
    edtTestRecipient.Text := TestRecipient;
      memMorningRecipients.Text := MorningRecipients;
    end;
  finally
    FLoadingEmailControls := False;
  end;
  if EmailQuery.Active and (EmailQuery.State in dsEditModes) then
    EmailQuery.Cancel;
end;
function TfrmEmailSettings.ValidateEmailSettings: Boolean;
begin
  Result := (edtEmailUser.Text <> '') and (edtAppPassword.Text <> '') and
    (edtSMTPHost.Text <> '') and (StrToIntDef(edtSMTPPort.Text, 0) > 0);
end;
procedure TfrmEmailSettings.btnSaveClick(Sender: TObject);
begin
  DBNavigator1BeforeAction(Sender, TBindNavigateBtn.nbPost);
end;
procedure TfrmEmailSettings.SendTestEmail;
var
  Recipients: string;
begin
  if not FEmailConfig.Enabled then
  begin
    ShowMessage('The email system is not currently active.');
    Exit;
  end;
  Recipients := FEmailConfig.Recipients;
  If Recipients = '' then
  begin
    ShowMessage('No test message recipients have been specified.');
    Exit;
  end;
  SendEmailIfEnabled
    ('This is a test message from the carillon bell system. <br><br><br>This is an automated message. Please do not respond.',
    Recipients);
  ShowMessage('A test message has been sent.');
end;
function TfrmEmailSettings.HTMLSafe(const S: string): string;
begin
  Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;
procedure TfrmEmailSettings.SendMorningReport;
var
  OrgName, Recipients: string;
  ReportHTML: TStringBuilder;
  LogLines: TStringList;
  q: TFDQuery;
  LogFilePath: string;
  BootTime: TDateTime;
  UptimeSec: Int64;
  UsedGB, FreeGB, TotalGB, UsedPct: Double;
  UsedMB, TotalMB: UInt64;
  MemPct: Double;
  CpuPct: Double;
  LastStartup: string;
  AppUptime: string;
  i: Integer;
  RecentPlays: TStringList;
  YesterdayCount: Integer;
  YesterdayDate: TDate;
  DT: TDateTime;
  L: string;
  PlaylistCount: Integer;
  TotalDurSecs: Int64;
  DurSecs: Int64;
  Missing: TStringList;
  NextEventTime: TTime;
  NextEventSong: string;
  FirstEventTime, LastEventTime: TTime;
  ErrorLines: TStringList;
  MaintLines: TStringList;
  MaintCount: Integer;
  VersionNumber: String;
begin
  if not Assigned(fmDailyPlaylist) then
    Exit;
  VersionNumber := GetStatusBarPanelText(fmDailyPlaylist.StatusBar1, 3);
  if not FEmailConfig.Enabled then
    Exit;
  LogLines := TStringList.Create;
  RecentPlays := TStringList.Create;
  Missing := TStringList.Create;
  ErrorLines := TStringList.Create;
  MaintLines := TStringList.Create;
  ReportHTML := TStringBuilder.Create;
  try
    // Org name
    OrgName := 'Organization name not set';
    q := ExecuteSettingsQuery('SELECT organization_name FROM pl_settings');
    try
      if not q.IsEmpty then
        OrgName := q.FieldByName('organization_name').AsString;
    finally
      q.Free;
    end;
    Recipients := FEmailConfig.MorningRecipients;
    if Recipients = '' then
    begin
      fmDailyPlaylist.AddToLog('Morning report send attempted, but no recipients specified.');
      Exit;
    end;
    // System metrics
    BootTime := GetBootTime;
    UptimeSec := GetWindowsUptimeSeconds;
    CpuPct := GetCPUUsagePercent;
    GetMemoryUsage(UsedMB, TotalMB, MemPct);
    // Drive root (portable)
    // Example: "E:\"
    if ExtractFileDrive(ParamStr(0)) <> '' then
      LogFilePath := ExtractFileDrive(ParamStr(0)) + '\'
    else
      LogFilePath := 'C:\';
    GetDiskUsage(LogFilePath, UsedGB, FreeGB, TotalGB, UsedPct);
    // Log
    LogFilePath := CarillonLogFilePath;
    LastStartup := 'Unknown';
    YesterdayCount := 0;
    YesterdayDate := Date - 1;
    if FileExists(LogFilePath) then
      LogLines.LoadFromFile(LogFilePath);
    // ------------------------------------------------------------
    // OPTION A FIX (PASS 1): Find LastStartup by scanning entire log
    // ------------------------------------------------------------
    for i := LogLines.Count - 1 downto 0 do
    begin
      L := LogLines[i];
      if Pos('Application initialized', L) > 0 then
      begin
        // Keep your original separator-based behavior but validate via parser
        if TryParseCarillonLogLineDateTime(L, DT) then
          LastStartup := Trim(Copy(L, 1, Pos(' - ', L) - 1))
        else
          LastStartup := Trim(L);
        Break; // Found the most recent startup
      end;
    end;
    // ------------------------------------------------------------
    // PASS 2: Collect bounded RecentPlays + other items safely
    // ------------------------------------------------------------
    for i := LogLines.Count - 1 downto 0 do
    begin
      L := LogLines[i];
      if (Pos('Played Song:', L) > 0) and (RecentPlays.Count < 20) then
        RecentPlays.Add(L);
      if Pos('Total Songs played yesterday:', L) > 0 then
        YesterdayCount := StrToIntDef(Trim(Copy(L, LastDelimiter(':', L)+1, 20)), YesterdayCount);
      // Errors / warnings from previous date only
      if (Pos('Error', L) > 0) or (Pos('Warning', L) > 0) then
      begin
        if TryParseCarillonLogLineDateTime(L, DT) and (DateOf(DT) = YesterdayDate) then
          ErrorLines.Add(L);
      end;
    end;
    // Application uptime (from Playlist form start time)
    if Assigned(fmDailyPlaylist) then
      AppUptime := FormatAppUptimeFromStartTime(fmDailyPlaylist.StartTime)
    else
      AppUptime := 'Unknown';
    // Schedule stats from global Schedule (Playlist.pas)
    // Schedule list is event-level (same as ShowRemainingPlaylist)
    FirstEventTime := 0;
    LastEventTime := 0;
    NextEventTime := 0;
    NextEventSong := '';
    if Assigned(PlaybackSchedule) and (PlaybackSchedule.Count > 0) then
    begin
      FirstEventTime := PlaybackSchedule[0].ScheduledTime;
      LastEventTime := PlaybackSchedule[PlaybackSchedule.Count-1].ScheduledTime;
      for i := 0 to PlaybackSchedule.Count-1 do
      begin
        if CompareTime(Now, PlaybackSchedule[i].ScheduledTime) <= 0 then
        begin
          NextEventTime := PlaybackSchedule[i].ScheduledTime;
          NextEventSong := PlaybackSchedule[i].SongPath;
          Break;
        end;
      end;
    end;
    // Playlist summary from fmDailyPlaylist.PlaylistQuery (already in Playlist form)
    PlaylistCount := 0;
    TotalDurSecs := 0;
    // IMPORTANT: use a TEMP query so we do not disturb live playback cursor
    if Assigned(fmDailyPlaylist) and Assigned(fmDailyPlaylist.PlaylistQuery) then
    begin
      var QPlaylist: TFDQuery;
      QPlaylist := TFDQuery.Create(nil);
      try
        QPlaylist.Connection := fmDailyPlaylist.PlaylistQuery.Connection;
        QPlaylist.SQL.Text := fmDailyPlaylist.PlaylistQuery.SQL.Text;
        QPlaylist.Open;
        QPlaylist.First;
        while not QPlaylist.Eof do
        begin
          Inc(PlaylistCount);
          if TryParseDurationToSeconds(
               QPlaylist.FieldByName('song_duration').AsString, DurSecs) then
            Inc(TotalDurSecs, DurSecs);
          // Missing/broken files: list by full path
          var SongPath := QPlaylist.FieldByName('song_name').AsString;
          if not TPath.IsPathRooted(SongPath) then
            SongPath := TPath.Combine(ExtractFilePath(ParamStr(0)), SongPath);
          if not FileExists(SongPath) then
            Missing.Add(SongPath);
          QPlaylist.Next;
        end;
      finally
        QPlaylist.Free;
      end;
    end;
    // Collect last 10 maintenance entries (newest first), then display oldest->newest
    MaintLines.Clear;
    MaintCount := 0;
    for i := LogLines.Count - 1 downto 0 do
    begin
      if MaintCount >= 10 then
        Break;
      if TryParseCarillonLogLineDateTime(LogLines[i], DT) then
      begin
        // Previous day shutdown/start/report
        if (DateOf(DT) = YesterdayDate) and
           ((Pos('Application shut down', LogLines[i]) > 0) or
            (Pos('Application initialized', LogLines[i]) > 0) or
            (Pos('Morning report produced', LogLines[i]) > 0)) then
        begin
          MaintLines.Add(LogLines[i]);
          Inc(MaintCount);
          Continue;
        end;
        // Today's early-morning maintenance window (00:0000:10)
        if (DateOf(DT) = Date) and (TimeOf(DT) <= EncodeTime(0,10,0,0)) and
           ((Pos('Total Songs played yesterday', LogLines[i]) > 0) or
            (Pos('Daily Song Count reset', LogLines[i]) > 0) or
            (Pos('Randomize seed reset', LogLines[i]) > 0) or
            (Pos('Schedule for', LogLines[i]) > 0)) then
        begin
          MaintLines.Add(LogLines[i]);
          Inc(MaintCount);
          Continue;
        end;
      end;
    end;
    // ---- Build HTML ----
    ReportHTML.Append('<html><head><meta charset="UTF-8">');
    ReportHTML.Append('<style>');
    ReportHTML.Append('body{font-family:Arial,Helvetica,sans-serif;font-size:10pt;}');
    ReportHTML.Append('.title{font-size:14pt;font-weight:bold;}');
    ReportHTML.Append('.hr{border-top:1px solid #999;margin:10px 0;}');
    ReportHTML.Append('.section{font-weight:bold;margin-top:10px;}');
    ReportHTML.Append('.mono{font-family:consolas,monospace;font-size:11pt;}');
    ReportHTML.Append('table{border-collapse:collapse;}td{padding:2px 6px;vertical-align:top;}');
    ReportHTML.Append('</style></head><body>');
    ReportHTML.Append('<div class="title">Carillon System Health Report</div><br>');
    ReportHTML.Append('Date: ' + HTMLSafe(FormatDateTime('dddd, mmmm d, yyyy - hh:nn AM/PM', Now)) + '<br>');
    ReportHTML.Append('Organization: ' + HTMLSafe(OrgName) + '<br>');
    ReportHTML.Append('<div class="hr"></div>');
    // System Data
    ReportHTML.Append('<div class="section">System Data</div>');
    ReportHTML.Append('<table>');
    ReportHTML.Append('<tr><td>System Drive used:</td><td>' + HTMLSafe(ExtractFileDrive(ParamStr(0)) + '\') + '</td></tr>');
    ReportHTML.Append('<tr><td>System Drive Usage:</td><td>' +
      Format('%.2f GB used / %.2f GB free of %.2f GB (%.1f%%)', [UsedGB, FreeGB, TotalGB, UsedPct]) +
      '</td></tr>');
    ReportHTML.Append('<tr><td>Last Windows Boot:</td><td>' + HTMLSafe(FormatDateTime('yyyy-mm-dd hh:nn:ss', BootTime)) + '</td></tr>');
    ReportHTML.Append('<tr><td>Windows System Uptime:</td><td>' + HTMLSafe(FormatUptimeFromSeconds(UptimeSec)) + '</td></tr>');
    ReportHTML.Append('<tr><td>CPU Usage:</td><td>' + FormatFloat('0.0', CpuPct) + '%</td></tr>');
    ReportHTML.Append('<tr><td>RAM Used:</td><td>' + Format('%d MB of %d MB (%.1f%%)', [UsedMB, TotalMB, MemPct]) + '</td></tr>');
    ReportHTML.Append('<tr><td>Application Version:</td><td>' + HTMLSafe(VersionNumber) + '</td></tr>');
    ReportHTML.Append('<tr><td>Last Application Startup:</td><td>' + HTMLSafe(LastStartup) + '</td></tr>');
    ReportHTML.Append('<tr><td>Application Uptime:</td><td>' + HTMLSafe(AppUptime) + '</td></tr>');
    ReportHTML.Append('</table>');
    // Audio device
    ReportHTML.Append('<br><div class="section">Audio Device</div>');
    ReportHTML.Append('&bull; Windows Audio with application volume control<br>');
    // Schedule Status
    ReportHTML.Append('<br><div class="section">Schedule Status</div>');
    ReportHTML.Append('<table>');
    ReportHTML.Append('<tr><td>Scheduled Events Today:</td><td>' + IntToStr(IfThen(Assigned(PlaybackSchedule), PlaybackSchedule.Count, 0)) + '</td></tr>');
    if Assigned(PlaybackSchedule) and (PlaybackSchedule.Count > 0) then
    begin
      ReportHTML.Append('<tr><td>First Event:</td><td>' + HTMLSafe(FormatDateTime('hh:nn AM/PM', FirstEventTime)) + '</td></tr>');
      ReportHTML.Append('<tr><td>Last Event:</td><td>' + HTMLSafe(FormatDateTime('hh:nn AM/PM', LastEventTime)) + '</td></tr>');
      if NextEventSong <> '' then
        ReportHTML.Append('<tr><td>Next Event:</td><td>' + HTMLSafe(FormatDateTime('hh:nn AM/PM', NextEventTime) + ' - "' + ExtractFileName(NextEventSong) + '"') + '</td></tr>');
    end;
    ReportHTML.Append('</table>');
    // Recent play activity
  ReportHTML.Append('<div class="section">Recent Play Activity (Last 20)</div>');
  ReportHTML.Append('<div class="mono">');
    for i := RecentPlays.Count - 1 downto 0 do
      begin
        ReportHTML.Append(HTMLSafe(RecentPlays[i]) + '<br>');
        if (i mod 5 = 0) and (i <> 0) then
          ReportHTML.Append('<br>');
      end;
ReportHTML.Append('</div>');
    // Yesterday summary
    ReportHTML.Append('<div class="section">Yesterday Play Summary</div>');
    ReportHTML.Append('&bull; Total Songs Played Yesterday: ' + IntToStr(YesterdayCount) + '<br>');
    // Daily maintenance activity (previous day + early-morning reset) - LIMITED TO LAST 10
    ReportHTML.Append('<div class="section">Daily Maintenance Activity (Last 10)</div>');
    ReportHTML.Append('<div class="mono">');
    if MaintLines.Count = 0 then
      ReportHTML.Append('None found.<br>')
    else
      for i := MaintLines.Count - 1 downto 0 do
        ReportHTML.Append(HTMLSafe(MaintLines[i]) + '<br>');
    ReportHTML.Append('</div>');
    // Playlist summary
    ReportHTML.Append('<div class="section">Playlist Summary</div>');
    ReportHTML.Append('&bull; Total songs in playlist: ' + IntToStr(PlaylistCount) + '<br>');
    ReportHTML.Append('&bull; Total playlist duration: ' + HTMLSafe(SecondsToHMS(TotalDurSecs)) + '<br>');
    if Missing.Count = 0 then
      ReportHTML.Append('&bull; Missing or broken files: None<br>')
    else
      ReportHTML.Append('&bull; Missing or broken files: ' + IntToStr(Missing.Count) + '<br><div class="mono">' + HTMLSafe(Missing.Text).Replace(#13#10,'<br>') + '</div>');
    // Errors previous date
    ReportHTML.Append('<div class="section">Errors (previous date)</div>');
    if ErrorLines.Count = 0 then
      ReportHTML.Append('None detected.<br>')
    else
    begin
      ReportHTML.Append('<div class="mono">');
      for i := 0 to ErrorLines.Count-1 do
        ReportHTML.Append(HTMLSafe(ErrorLines[i]) + '<br>');
      ReportHTML.Append('</div>');
    end;
    // Health score: reuse existing logic if present elsewhere; fallback simple
    ReportHTML.Append('<div class="section">Overall Health Score</div>');
    // Simple conservative score: 100 - (missing files) - (errors*5)
    ReportHTML.Append(IntToStr(Max(0, 100 - Missing.Count - (ErrorLines.Count*5))) + ' / 100<br>');
    // Remaining schedule for today (authoritative: global Schedule list, same as ShowRemainingPlaylist)
    ReportHTML.Append('<div class="section">Remaining Schedule for Today</div>');
    ReportHTML.Append('<div class="mono">');
    if Assigned(PlaybackSchedule) and (PlaybackSchedule.Count > 0) then
    begin
    var DisplayCount: integer;
    DisplayCount := 0;
    for i := 0 to PlaybackSchedule.Count - 1 do
      begin
        if CompareTime(Now, PlaybackSchedule[i].ScheduledTime) <= 0 then
          begin
            ReportHTML.Append(HTMLSafe(FormatDateTime('hh:nn AM/PM', PlaybackSchedule[i].ScheduledTime) +
        ' - ' + ExtractFileName(PlaybackSchedule[i].SongPath)) + '<br>');
            Inc(DisplayCount);
        if (DisplayCount mod 5 = 0) then ReportHTML.Append('<br>');
          end;
      end;
    end
    else
      ReportHTML.Append('No more events scheduled for today.<br>');
    ReportHTML.Append('</div>');
    ReportHTML.Append('<br><br>This is an automated message. Please do not respond.');
    ReportHTML.Append('</body></html>');
    SendEmailIfEnabled(ReportHTML.ToString, Recipients);
  finally
    ReportHTML.Free;
    LogLines.Free;
    RecentPlays.Free;
    Missing.Free;
    ErrorLines.Free;
    MaintLines.Free;
  end;
  fmDailyPlaylist.AddToLog('Morning report produced and sent');
end;
procedure TfrmEmailSettings.Timer1Timer(Sender: TObject);
var
  NowTime: TDateTime;
begin
  if FGeneratedShuttingDown then
    Exit;
  NowTime := Now;
  if (TimeOf(NowTime) >= EncodeTime(5, 0, 0, 0)) and
    (DateOf(NowTime) <> LastReportDate) then
  begin
    LastReportDate := DateOf(NowTime);
    SendMorningReport;
  end;
end;
procedure TfrmEmailSettings.btnCloseClick(Sender: TObject);
begin
  if ConfirmCloseWithPendingEmailChanges then
    Close;
end;
procedure TfrmEmailSettings.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmCloseWithPendingEmailChanges;
end;
procedure TfrmEmailSettings.btnTestClick(Sender: TObject);
begin
  SendTestEmail;
end;
procedure TfrmEmailSettings.chkShowPasswordClick(Sender: TObject);
begin
  edtAppPassword.Password := not chkShowPassword.IsChecked;
end;
procedure TfrmEmailSettings.btnSendMorningReportClick(Sender: TObject);
begin
  if not FEmailConfig.Enabled then
  begin
    ShowMessage('The email system is not currently active.');
    Exit;
  end;
  SendMorningReport;
  ShowMessage('A test morning report was sent.');
end;
class procedure TfrmEmailSettings.SendEmailIfEnabled(const Msg,
  Recipients: string);
var
  SMTP: TIdSMTP;
  EmailMsg: TIdMessage;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  if not Assigned(frmEmailSettings) then
    Exit;
  frmEmailSettings.LoadEmailSettings;
  if Recipients = '' then
  begin
    if Assigned(fmDailyPlaylist) then
      fmDailyPlaylist.AddToLog('An email was attempted with no recipients.');
    Exit;
  end;
  if Msg = '' then
  begin
    if Assigned(fmDailyPlaylist) then
      fmDailyPlaylist.AddToLog('An email was attempted with no message content.');
    Exit;
  end;
  SMTP := TIdSMTP.Create(nil);
  EmailMsg := TIdMessage.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      SSL.SSLOptions.Method := sslvTLSv1_2;
      SSL.SSLOptions.Mode := sslmClient;
      SMTP.IOHandler := SSL;
      SMTP.Username := frmEmailSettings.FEmailConfig.Username;
      SMTP.Password := frmEmailSettings.FEmailConfig.Password;
      SMTP.Host := frmEmailSettings.FEmailConfig.Host;
      SMTP.Port := frmEmailSettings.FEmailConfig.Port;
      SMTP.UseTLS := utUseExplicitTLS;
      SMTP.AuthType := satDefault;
      SMTP.ConnectTimeout := 5000;
      SMTP.ReadTimeout := 15000;
      EmailMsg.ContentType := 'text/html; charset=UTF-8';
      EmailMsg.Subject := 'Carillon Bell System Alert';
      EmailMsg.From.Address := frmEmailSettings.FEmailConfig.Username;
      EmailMsg.Recipients.EmailAddresses := Recipients;
      EmailMsg.Body.Text := Msg;
      if Trim(SMTP.Host) = '' then
        raise Exception.Create('Email send failure: Host is required but not set.');
      SMTP.Connect;
      try
        SMTP.Send(EmailMsg);
      finally
        if SMTP.Connected then
          SMTP.Disconnect;
      end;
    except
      on E: Exception do
      begin
        if Assigned(fmDailyPlaylist) then
          fmDailyPlaylist.AddToLog('Email send failure: ' + E.Message);
      end;
    end;
  finally
    EmailMsg.Free;
    SMTP.Free;
    SSL.Free;
  end;
end;
procedure TfrmEmailSettings.chkShowPassword_GeneratedUserChange(Sender: TObject);
begin
  if FGeneratedShuttingDown then
    Exit;
  if FGeneratedToggleSuppress_chkShowPassword = 0 then
    if Assigned(FGeneratedToggleOriginalClick_chkShowPassword) then
      FGeneratedToggleOriginalClick_chkShowPassword(Sender);
  if Assigned(FGeneratedToggleOriginalChange_chkShowPassword) then
    FGeneratedToggleOriginalChange_chkShowPassword(Sender);
end;
procedure TfrmEmailSettings.GeneratedFormDestroyHandler(Sender: TObject);
begin
  // Generated FMX cleanup for bindings, timers, and media
  FGeneratedShuttingDown := True;
  if Assigned(chkShowPassword) then
  begin
    chkShowPassword.OnChange := nil;
    chkShowPassword.OnClick := nil;
  end;
  if Assigned(FGeneratedOriginalOnDestroy) then
    FGeneratedOriginalOnDestroy(Sender);
  if frmEmailSettings = Self then
    frmEmailSettings := nil;
end;
end.

