unit SettingsForm;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  Data.Bind.Components,
  Data.Bind.Controls,
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
  Fmx.Bind.Editors,
  Fmx.Bind.Navigator,
  FMX.Controls,
  FMX.DateTimeCtrls,
  FMX.DialogService.Sync,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Menus,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  Math,
  Overlay,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UIConsts,
  System.UITypes,
  System.Variants,
  Winapi.Messages,
  Winapi.Windows, FMX.Layouts, FMX.Controls.Presentation;
type
  TSettingsMain = class(TForm)
    lblSystemSettings: TLabel;
    setMainMenu1: TMenuBar;
    File1: TMenuItem;
    Exit1: TMenuItem;
    setFDConnection1: TFDConnection;
    setFDQuery1: TFDQuery;
    setDataSource1: TDataSource;
    Label1: TLabel;
    edOrgName: TEdit;
    DirectoryDialog1: TOpenDialog;
    btnCloseSettings: TButton;
    lblLogOnOff: TLabel;
    chkLogOnOff: TCheckBox;
    lblLogNote: TLabel;
    lblLogStatus: TLabel;
    Timer1: TTimer;
    SilenceTimer: TTimer;
    lblOtherStart: TLabel;
    dtAshWed: TDateEdit;
    dtHolyThuBeg: TDateEdit;
    dtHolySatEnd: TDateEdit;
    dtOtherStart: TDateEdit;
    dtOtherEnd: TDateEdit;
    dtAllSouls: TDateEdit;
    chkEnableSilence: TCheckBox;
    btnRecalcEaster: TButton;
    btnClearOtherDates: TButton;
    lblBeginDate: TLabel;
    lblEndDate: TLabel;
    tkOtherStartTime: TEdit;
    tkOtherEndTime: TEdit;
    DBNavigator1: TBindNavigator;
    btnSaveSettings: TButton;
    btnCancelSettings: TButton;
    procedure ValidateDateTimeRanges;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure btnCloseSettingsClick(Sender: TObject);
    procedure btnSaveSettingsClick(Sender: TObject);
    procedure btnCancelSettingsClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SilenceTimerTimer(Sender: TObject);
    procedure btnRecalcEasterClick(Sender: TObject);
    procedure btnClearOtherDatesClick(Sender: TObject);
    procedure dtAshWedChange(Sender: TObject);
    procedure dtHolyThuBegChange(Sender: TObject);
    procedure dtHolySatEndChange(Sender: TObject);
    procedure dtOtherStartChange(Sender: TObject);
    procedure dtOtherEndChange(Sender: TObject);
    procedure dtAllSoulsChange(Sender: TObject);
    procedure tkOtherStartTimeExit(Sender: TObject);
    procedure tkOtherEndTimeExit(Sender: TObject);
    procedure MuteUnmuteClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FGeneratedOriginalOnDestroy: TNotifyEvent;
    FGeneratedShuttingDown: Boolean;
    FLoadingSettingsControls: Boolean;
    BindSourceDB_setDataSource1: TBindSourceDB;
    FOriginal_DBNavigator1_BeforeAction: EBindNavClick;
    FGeneratedToggleSuppress_chkEnableSilence: Integer;
    FGeneratedToggleOriginalClick_chkEnableSilence: TNotifyEvent;
    FGeneratedToggleOriginalChange_chkEnableSilence: TNotifyEvent;
    FLastLogTrimDate: TDateTime;
    FLastEasterRecalcYear: Integer;
    procedure GeneratedFormDestroyHandler(Sender: TObject);
    procedure setDataSource1_GeneratedDataChange(Sender: TObject; Field: TField);
    procedure DBNavigator1_GeneratedBeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    procedure GeneratedSetToggleState_chkEnableSilence(AValue: Boolean);
    procedure chkEnableSilence_GeneratedUserChange(Sender: TObject);
    procedure SettingsControlChanged(Sender: TObject);
    function HasPendingSettingsChanges: Boolean;
    function SavePendingSettingsChanges: Boolean;
    function ConfirmCloseWithPendingSettingsChanges: Boolean;
    procedure DiscardPendingSettingsChanges;
    procedure ClearLogFile;
    procedure LoadSilenceSettings;
    procedure SaveSilenceSettings;
    procedure UpdateEasterDates;
    procedure UpdateAllSoulsDate;
    function TryValidateTime(const S: string; out D: TDateTime): Boolean;
  public
  end;
var
  SettingsMain: TSettingsMain;
  FLastSilenceAction: TDateTime;
implementation
uses
  CarillonTheme,
  EasterCalculator, LogManager,
  email,
  Playlist;
{$R *.fmx}
type
  TGeneratedManualFieldBinding = class
  public
    Control: TCustomEdit;
    Owner: TComponent;
    DataSet: TDataSet;
    FieldName: string;
    OriginalChangeTracking: TNotifyEvent;
    OriginalExit: TNotifyEvent;
    OriginalKeyDown: TKeyEvent;
    Guard: Integer;
  end;
  TGeneratedManualFieldBindingHandler = class
  public
    procedure GeneratedManualFieldChangeTracking(Sender: TObject);
    procedure GeneratedManualFieldExit(Sender: TObject);
    procedure GeneratedManualFieldKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  end;
var
  GeneratedManualFieldBindingList: TObjectList<TGeneratedManualFieldBinding>;
  GeneratedManualFieldBindingMap: TObjectDictionary<TObject, TGeneratedManualFieldBinding>;
  GeneratedManualFieldBindingHandler: TGeneratedManualFieldBindingHandler;
procedure GeneratedEnsureManualFieldBindingInfra;
begin
  if GeneratedManualFieldBindingList = nil then
    GeneratedManualFieldBindingList := TObjectList<TGeneratedManualFieldBinding>.Create(True);
  if GeneratedManualFieldBindingMap = nil then
    GeneratedManualFieldBindingMap := TObjectDictionary<TObject, TGeneratedManualFieldBinding>.Create;
  if GeneratedManualFieldBindingHandler = nil then
    GeneratedManualFieldBindingHandler := TGeneratedManualFieldBindingHandler.Create;
end;
function GeneratedFindManualFieldBinding(const AControl: TObject): TGeneratedManualFieldBinding;
begin
  Result := nil;
  if (GeneratedManualFieldBindingMap <> nil) and (AControl <> nil) then
    GeneratedManualFieldBindingMap.TryGetValue(AControl, Result);
end;
function GeneratedGetManualFieldDisplayText(AControl: TCustomEdit): string;
var
  Binding: TGeneratedManualFieldBinding;
  LField: TField;
begin
  Result := '';
  if AControl = nil then
    Exit;
  Result := AControl.Text;
  Binding := GeneratedFindManualFieldBinding(AControl);
  if (Binding = nil) or not Assigned(Binding.DataSet) or not Binding.DataSet.Active or Binding.DataSet.IsEmpty then
    Exit;
  LField := Binding.DataSet.FindField(Binding.FieldName);
  if LField <> nil then
    Result := LField.DisplayText;
end;
function GeneratedTryParseBoundDate(const AInput: string; out AValue: TDateTime): Boolean;
var
  LText: string;
  FS: TFormatSettings;
  Parts: TArray<string>;
  A, B, C: Integer;
  Y, M, D: Word;
begin
  AValue := 0;
  LText := Trim(AInput);
  if LText = '' then
    Exit(False);
  FS := TFormatSettings.Create;
  if TryStrToDate(LText, AValue, FS) or TryStrToDateTime(LText, AValue, FS) then
  begin
    AValue := Trunc(AValue);
    Exit(True);
  end;
  LText := StringReplace(LText, '-', '/', [rfReplaceAll]);
  LText := StringReplace(LText, '.', '/', [rfReplaceAll]);
  Parts := LText.Split(['/']);
  if Length(Parts) <> 3 then
    Exit(False);
  if not TryStrToInt(Trim(Parts[0]), A) then
    Exit(False);
  if not TryStrToInt(Trim(Parts[1]), B) then
    Exit(False);
  if not TryStrToInt(Trim(Parts[2]), C) then
    Exit(False);
  if Length(Trim(Parts[0])) = 4 then
  begin
    Y := A; M := B; D := C;
  end
  else
  begin
    Y := C;
    if Y < 100 then
      if Y < 50 then Inc(Y, 2000) else Inc(Y, 1900);
    if A > 12 then
    begin
      D := A; M := B;
    end
    else if B > 12 then
    begin
      M := A; D := B;
    end
    else
    begin
      M := A; D := B;
    end;
  end;
  try
    AValue := EncodeDate(Y, M, D);
    Result := True;
  except
    Result := False;
  end;
end;
function GeneratedTryParseBoundTime(const AInput: string; out AValue: TDateTime): Boolean;
var
  LText: string;
  FS: TFormatSettings;
  Hours: Integer;
  Minutes: Integer;
  Seconds: Integer;
  Parts: TArray<string>;
  Suffix: string;
begin
  AValue := 0;
  LText := UpperCase(Trim(AInput));
  if LText = '' then
    Exit(False);
  FS := TFormatSettings.Create;
  if TryStrToTime(LText, AValue, FS) or TryStrToDateTime(LText, AValue, FS) then
  begin
    AValue := Frac(AValue);
    Exit(True);
  end;
  LText := StringReplace(LText, '.', ':', [rfReplaceAll]);
  while Pos('  ', LText) > 0 do
    LText := StringReplace(LText, '  ', ' ', [rfReplaceAll]);
  Suffix := '';
  if Length(LText) >= 2 then
  begin
    if SameText(Copy(LText, Length(LText) - 1, 2), 'AM') or
       SameText(Copy(LText, Length(LText) - 1, 2), 'PM') then
    begin
      Suffix := Copy(LText, Length(LText) - 1, 2);
      Delete(LText, Length(LText) - 1, 2);
      LText := Trim(LText);
    end;
  end;
  Hours := 0;
  Minutes := 0;
  Seconds := 0;
  if Pos(':', LText) = 0 then
  begin
    if (Suffix = '') and (Length(LText) in [3, 4]) then
    begin
      if not TryStrToInt(Copy(LText, 1, Length(LText) - 2), Hours) then
        Exit(False);
      if not TryStrToInt(Copy(LText, Length(LText) - 1, 2), Minutes) then
        Exit(False);
    end
    else
    begin
      if not TryStrToInt(LText, Hours) then
        Exit(False);
    end;
  end
  else
  begin
    Parts := LText.Split([':']);
    if (Length(Parts) < 2) or (Length(Parts) > 3) then
      Exit(False);
    if not TryStrToInt(Trim(Parts[0]), Hours) then
      Exit(False);
    if not TryStrToInt(Trim(Parts[1]), Minutes) then
      Exit(False);
    if Length(Parts) = 3 then
      if not TryStrToInt(Trim(Parts[2]), Seconds) then
        Exit(False);
  end;
  if (Minutes < 0) or (Minutes > 59) or (Seconds < 0) or (Seconds > 59) then
    Exit(False);
  if Suffix = 'AM' then
  begin
    if (Hours < 1) or (Hours > 12) then
      Exit(False);
    if Hours = 12 then
      Hours := 0;
  end
  else if Suffix = 'PM' then
  begin
    if (Hours < 1) or (Hours > 12) then
      Exit(False);
    if Hours < 12 then
      Inc(Hours, 12);
  end
  else if (Hours < 0) or (Hours > 23) then
    Exit(False);
  try
    AValue := EncodeTime(Hours, Minutes, Seconds, 0);
    Result := True;
  except
    Result := False;
  end;
end;
function GeneratedAssignBoundFieldValue(AField: TField; const AInput: string; out ANormalized: string; out AError: string): Boolean;
var
  LValue: string;
  LDateTime: TDateTime;
  LFieldName: string;
begin
  ANormalized := '';
  AError := '';
  if AField = nil then
    Exit(False);
  LValue := Trim(AInput);
  if LValue = '' then
  begin
    AField.Clear;
    ANormalized := '';
    Exit(True);
  end;
  if Assigned(AField.OnSetText) or Assigned(AField.OnGetText) then
  begin
    try
      AField.Text := LValue;
      ANormalized := AField.DisplayText;
      Exit(True);
    except
      on E: Exception do
      begin
        AError := E.Message;
        Exit(False);
      end;
    end;
  end;
  LFieldName := UpperCase(AField.FieldName);
  if (AField.DataType = ftTime) or
     (((AField.DataType in [ftUnknown, ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftFixedChar, ftFixedWideChar]) and
       ((Pos('_TIME', LFieldName) > 0) or (Pos('TIME_', LFieldName) > 0) or (Pos('PLAY_TIME', LFieldName) > 0) or (Pos('SCHEDULED_TIME', LFieldName) > 0))) and
      (Pos('DATE', LFieldName) = 0)) then
  begin
    if not GeneratedTryParseBoundTime(LValue, LDateTime) then
    begin
      AError := '"' + AInput + '" is not a valid time.';
      Exit(False);
    end;
    AField.AsDateTime := LDateTime;
    ANormalized := AField.DisplayText;
    Exit(True);
  end;
  if (AField.DataType in [ftDate, ftDateTime, ftTimeStamp]) or
     ((AField.DataType in [ftUnknown, ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftFixedChar, ftFixedWideChar]) and
      (Pos('DATE', LFieldName) > 0)) then
  begin
    if not GeneratedTryParseBoundDate(LValue, LDateTime) then
    begin
      AError := '"' + AInput + '" is not a valid date.';
      Exit(False);
    end;
    AField.AsDateTime := LDateTime;
    ANormalized := AField.DisplayText;
    Exit(True);
  end;
  try
    AField.Text := LValue;
    ANormalized := AField.DisplayText;
    Result := True;
  except
    on E: Exception do
    begin
      AError := E.Message;
      Result := False;
    end;
  end;
end;
procedure GeneratedSyncManualFieldBinding(const ABinding: TGeneratedManualFieldBinding);
var
  LField: TField;
  LText: string;
begin
  if (ABinding = nil) or (ABinding.Control = nil) then
    Exit;
  if ABinding.Guard > 0 then
    Exit;
  if (ABinding.Owner <> nil) and (csDestroying in ABinding.Owner.ComponentState) then
    Exit;
  if csDestroying in ABinding.Control.ComponentState then
    Exit;
  if ABinding.Control.IsFocused then
    Exit;
  LText := '';
  if Assigned(ABinding.DataSet) and ABinding.DataSet.Active and (not ABinding.DataSet.IsEmpty) then
  begin
    LField := ABinding.DataSet.FindField(ABinding.FieldName);
    if LField <> nil then
      LText := LField.DisplayText;
  end;
  Inc(ABinding.Guard);
  try
    if ABinding.Control.Text <> LText then
      ABinding.Control.Text := LText;
  finally
    Dec(ABinding.Guard);
  end;
end;
procedure GeneratedSyncManualFieldBindingsForDataSet(const ADataSet: TDataSet);
var
  Binding: TGeneratedManualFieldBinding;
begin
  if (ADataSet = nil) or (GeneratedManualFieldBindingList = nil) then
    Exit;
  for Binding in GeneratedManualFieldBindingList do
    if Binding.DataSet = ADataSet then
      GeneratedSyncManualFieldBinding(Binding);
end;
procedure TGeneratedManualFieldBindingHandler.GeneratedManualFieldChangeTracking(Sender: TObject);
var
  Binding: TGeneratedManualFieldBinding;
begin
  Binding := GeneratedFindManualFieldBinding(Sender);
  if (Binding = nil) or (Binding.Guard > 0) then
    Exit;
  if (Binding.Owner <> nil) and (csDestroying in Binding.Owner.ComponentState) then
    Exit;
  if (Binding.Control <> nil) and (csDestroying in Binding.Control.ComponentState) then
    Exit;
  if not Assigned(Binding.DataSet) or not Binding.DataSet.Active or Binding.DataSet.IsEmpty then
    Exit;
  if not (Binding.DataSet.State in dsEditModes) then
    Binding.DataSet.Edit;
  if Assigned(Binding.OriginalChangeTracking) then
    Binding.OriginalChangeTracking(Sender);
end;
procedure TGeneratedManualFieldBindingHandler.GeneratedManualFieldExit(Sender: TObject);
var
  Binding: TGeneratedManualFieldBinding;
  LField: TField;
  LNormalized: string;
  LError: string;
begin
  Binding := GeneratedFindManualFieldBinding(Sender);
  if (Binding = nil) or (Binding.Control = nil) or (Binding.Guard > 0) then
    Exit;
  if (Binding.Owner <> nil) and (csDestroying in Binding.Owner.ComponentState) then
    Exit;
  if csDestroying in Binding.Control.ComponentState then
    Exit;
  if not Assigned(Binding.DataSet) or not Binding.DataSet.Active or Binding.DataSet.IsEmpty then
    Exit;
  LField := Binding.DataSet.FindField(Binding.FieldName);
  if LField = nil then
    Exit;
  if not (Binding.DataSet.State in dsEditModes) then
    Binding.DataSet.Edit;
  if not GeneratedAssignBoundFieldValue(LField, Binding.Control.Text, LNormalized, LError) then
  begin
    Inc(Binding.Guard);
    try
      if LError <> '' then
        ShowMessage(LError);
      GeneratedSyncManualFieldBinding(Binding);
    finally
      Dec(Binding.Guard);
    end;
    Exit;
  end;
  Inc(Binding.Guard);
  try
    if Binding.Control.Text <> LNormalized then
      Binding.Control.Text := LNormalized;
  finally
    Dec(Binding.Guard);
  end;
  if Assigned(Binding.OriginalExit) then
    Binding.OriginalExit(Sender);
end;
procedure TGeneratedManualFieldBindingHandler.GeneratedManualFieldKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Binding: TGeneratedManualFieldBinding;
begin
  Binding := GeneratedFindManualFieldBinding(Sender);
  if Key = vkReturn then
  begin
    GeneratedManualFieldBindingHandler.GeneratedManualFieldExit(Sender);
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  if (Binding <> nil) and Assigned(Binding.OriginalKeyDown) then
    Binding.OriginalKeyDown(Sender, Key, KeyChar, Shift);
end;
procedure GeneratedCommitManualFieldBindingsForDataSet(const ADataSet: TDataSet);
var
  Binding: TGeneratedManualFieldBinding;
begin
  if (ADataSet = nil) or (GeneratedManualFieldBindingList = nil) then
    Exit;
  for Binding in GeneratedManualFieldBindingList do
    if (Binding.DataSet = ADataSet) and (Binding.Control <> nil) then
      GeneratedManualFieldBindingHandler.GeneratedManualFieldExit(Binding.Control);
end;
procedure GeneratedRegisterManualFieldBinding(AControl: TCustomEdit; ADataSet: TDataSet; const AFieldName: string);
var
  Binding: TGeneratedManualFieldBinding;
begin
  if (AControl = nil) or (ADataSet = nil) or (Trim(AFieldName) = '') then
    Exit;
  GeneratedEnsureManualFieldBindingInfra;
  Binding := GeneratedFindManualFieldBinding(AControl);
  if Binding <> nil then
    Exit;
  Binding := TGeneratedManualFieldBinding.Create;
  Binding.Control := AControl;
  Binding.Owner := AControl.Owner;
  Binding.DataSet := ADataSet;
  Binding.FieldName := AFieldName;
  Binding.OriginalChangeTracking := AControl.OnChangeTracking;
  Binding.OriginalExit := AControl.OnExit;
  Binding.OriginalKeyDown := AControl.OnKeyDown;
  Binding.Guard := 0;
  GeneratedManualFieldBindingList.Add(Binding);
  GeneratedManualFieldBindingMap.Add(AControl, Binding);
  AControl.OnChangeTracking := GeneratedManualFieldBindingHandler.GeneratedManualFieldChangeTracking;
  AControl.OnExit := GeneratedManualFieldBindingHandler.GeneratedManualFieldExit;
  AControl.OnKeyDown := GeneratedManualFieldBindingHandler.GeneratedManualFieldKeyDown;
  GeneratedSyncManualFieldBinding(Binding);
end;
procedure GeneratedCleanupManualFieldBindingsForOwner(const AOwner: TComponent);
var
  I: Integer;
  Binding: TGeneratedManualFieldBinding;
begin
  if GeneratedManualFieldBindingList <> nil then
    for I := GeneratedManualFieldBindingList.Count - 1 downto 0 do
    begin
      Binding := GeneratedManualFieldBindingList[I];
      if Binding <> nil then
      begin
        if Binding.Control <> nil then
        begin
          Binding.Control.OnChangeTracking := nil;
          Binding.Control.OnExit := nil;
          Binding.Control.OnKeyDown := nil;
          if GeneratedManualFieldBindingMap <> nil then
            GeneratedManualFieldBindingMap.Remove(Binding.Control);
        end;
        Binding.Control := nil;
        Binding.Owner := nil;
        Binding.DataSet := nil;
        Binding.OriginalChangeTracking := nil;
        Binding.OriginalExit := nil;
        Binding.OriginalKeyDown := nil;
        GeneratedManualFieldBindingList.Delete(I);
      end;
    end;
  if GeneratedManualFieldBindingMap <> nil then
    FreeAndNil(GeneratedManualFieldBindingMap);
  if GeneratedManualFieldBindingHandler <> nil then
    FreeAndNil(GeneratedManualFieldBindingHandler);
  if GeneratedManualFieldBindingList <> nil then
    FreeAndNil(GeneratedManualFieldBindingList);
end;
const
  OneMinute: TDateTime = 1 / 1440;
procedure TSettingsMain.FormCreate(Sender: TObject);
var
  stBGColor, stFontColor: TAlphaColor;
  i, chkLog: Integer;
  TempQuery: TFDQuery;
begin
  FGeneratedOriginalOnDestroy := Self.OnDestroy;
  Self.OnDestroy := GeneratedFormDestroyHandler;
  Self.OnCloseQuery := FormCloseQuery;
  SilenceTimer.Interval := 2000;
  SilenceTimer.Enabled := True;
  FLastSilenceAction := 0;
  Timer1.Interval := 60000;
  ConfigurePortableSQLiteConnection(setFDConnection1);
  setFDConnection1.connected := True;
  TempQuery := TFDQuery.Create(nil);
  try
    TempQuery.Connection := setFDConnection1;
    TempQuery.SQL.Text :=
      'SELECT form_bgcolor, form_fontcolor, logging_status FROM pl_settings';
    TempQuery.Open;
    if not TempQuery.IsEmpty then
    begin
      stBGColor := VCLColorToAlphaColor(TempQuery.FieldByName('form_bgcolor').AsInteger);
      stFontColor := VCLColorToAlphaColor(TempQuery.FieldByName('form_fontcolor').AsInteger);
      chkLog := TempQuery.FieldByName('logging_status').AsInteger;
    end
    else
    begin
      stBGColor := VCLColorToAlphaColor($8EBDDC);
      stFontColor := VCLColorToAlphaColor($000080);
      chkLog := 0;
    end;
  finally
    TempQuery.Free;
  end;
  Self.Fill.Kind := TBrushKind.Solid;
  Self.Fill.Color := stBGColor;
  ApplyContainerBackgroundColor(Self, stBGColor);
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TLabel then
      TLabel(Components[i]).TextSettings.FontColor := stFontColor;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TButton then
      ApplyTieredButtonStyle(TButton(Components[i]), stBGColor, stFontColor)
    else if Components[i] is TEdit then
      ApplyCardEditStyle(TStyledControl(Components[i]), stBGColor, stFontColor);
  chkLogOnOff.IsChecked := (chkLog = 1);
  chkLogOnOff.OnChange := SettingsControlChanged;
  setFDQuery1.Connection := setFDConnection1;
  setFDConnection1.connected := True;
  setFDQuery1.SQL.Text := 'SELECT * FROM pl_settings';
  setFDQuery1.Open;
  LoadSilenceSettings;
  dtAshWed.OnClosePicker := dtAshWedChange;
  dtHolyThuBeg.OnClosePicker := dtHolyThuBegChange;
  dtHolySatEnd.OnClosePicker := dtHolySatEndChange;
  dtOtherStart.OnChange := dtOtherStartChange;
  dtOtherEnd.OnChange := dtOtherEndChange;
  dtAllSouls.OnClosePicker := dtAllSoulsChange;
  tkOtherStartTime.OnExit := tkOtherStartTimeExit;
  tkOtherEndTime.OnExit := tkOtherEndTimeExit;
  // Generated FMX LiveBindings from original VCL data-aware controls
  if BindSourceDB_setDataSource1 = nil then
  begin
    BindSourceDB_setDataSource1 := TBindSourceDB.Create(Self);
    BindSourceDB_setDataSource1.DataSource := setDataSource1;
  end;
  GeneratedRegisterManualFieldBinding(edOrgName, setFDQuery1, 'ORGANIZATION_NAME');
  if Assigned(setDataSource1) and not Assigned(setDataSource1.OnDataChange) then
    setDataSource1.OnDataChange := setDataSource1_GeneratedDataChange;
  if Assigned(DBNavigator1) then
  begin
    FOriginal_DBNavigator1_BeforeAction := DBNavigator1.BeforeAction;
    DBNavigator1.BeforeAction := DBNavigator1_GeneratedBeforeAction;
  end;


  if Assigned(DBNavigator1) then
    DBNavigator1.DataSource := BindSourceDB_setDataSource1;
  if Assigned(chkEnableSilence) then
  begin
    FGeneratedToggleOriginalClick_chkEnableSilence := chkEnableSilence.OnClick;
    FGeneratedToggleOriginalChange_chkEnableSilence := chkEnableSilence.OnChange;
    chkEnableSilence.OnClick := nil;
    chkEnableSilence.OnChange := chkEnableSilence_GeneratedUserChange;
  end;
  // Trim the play log to the last 30 days at startup. This is the
  // catch-up for any day when the app was not running at 00:10.
  ClearLogFile;
  FLastLogTrimDate := Date;
  FLastEasterRecalcYear := YearOf(Date);
  ApplyCurrentCarillonThemeToForm(Self);
end;
procedure TSettingsMain.FormShow(Sender: TObject);
begin
  ApplyCurrentCarillonThemeToForm(Self);
end;
procedure TSettingsMain.Exit1Click(Sender: TObject);
begin
  btnCloseSettingsClick(Sender);
end;
procedure TSettingsMain.btnSelectDirClick(Sender: TObject);
var
  Dir: string;
begin
  DirectoryDialog1.Title := 'Select Random Music Directory';
  if DirectoryDialog1.Execute then
  begin
    Dir := DirectoryDialog1.FileName;
    setFDQuery1.Edit;
    setFDQuery1.FieldByName('rand_songs_directory').AsString := Dir;
    setFDQuery1.Post;
  end;
end;
procedure TSettingsMain.btnCloseSettingsClick(Sender: TObject);
begin
  if not ConfirmCloseWithPendingSettingsChanges then
    Exit;
  if Assigned(frmOverlay) then
  begin
    frmOverlay.Close;
    frmOverlay.Free;
    frmOverlay := nil;
  end;
  if TFmxFormState.Modal in Self.FormState then
    ModalResult := mrOk
  else
  begin
    Hide;
    if Assigned(Application.MainForm) then
    begin
      Application.MainForm.Show;
      Application.MainForm.BringToFront;
    end;
  end;
end;
procedure TSettingsMain.btnSaveSettingsClick(Sender: TObject);
begin
  try
    ValidateDateTimeRanges;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Exit;
    end;
  end;
  DBNavigator1_GeneratedBeforeAction(Sender, nbPost);
  if setFDQuery1.Active and (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Post;
end;
procedure TSettingsMain.btnCancelSettingsClick(Sender: TObject);
begin
  DBNavigator1_GeneratedBeforeAction(Sender, nbCancel);
  if setFDQuery1.Active and (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Cancel;
end;
procedure TSettingsMain.MuteUnmuteClick(Sender: TObject);
begin
  if Assigned(fmDailyPlayList) then
    fmDailyPlayList.mbMuteButtonClick(Sender);
end;
procedure TSettingsMain.Timer1Timer(Sender: TObject);
var
  Today: TDate;
  NowDT: TDateTime;
  HourMin: string;
begin
  if FGeneratedShuttingDown then
    Exit;
  NowDT := Now;
  Today := Date;
  HourMin := FormatDateTime('HH:nn', NowDT);
  if (MonthOf(Today) = 1) and (DayOf(Today) >= 2) and (HourMin >= '00:15') and
    (FLastEasterRecalcYear <> YearOf(Today)) then
  begin
    FLastEasterRecalcYear := YearOf(Today);
    UpdateEasterDates;
    UpdateAllSoulsDate;
    SaveSilenceSettings;
    LoadSilenceSettings;
    FLastSilenceAction := NowDT;
    fmDailyPlayList.AddToLog('Annual Date recalculations were performed');
  end;
  // Daily log trim at 00:10. If that minute was missed (PC asleep,
  // app busy), the first tick of the new day after 00:10 catches up.
  // Runs regardless of the logging on/off setting so the log file
  // is always kept to the last 30 days.
  if (FLastLogTrimDate <> Date) and (HourMin >= '00:10') then
  begin
    ClearLogFile;
    FLastLogTrimDate := Date;
  end;
end;
procedure TSettingsMain.ClearLogFile;
begin
  try
    TrimCarillonPlayLog(30);
  except
  end;
end;
// Legacy date-based silence: handles Ash Wednesday, Holy Thursday/Saturday, All Souls, and one-off Funeral Silence dates stored in pl_settings. The newer SilenceManager handles recurring weekly silence windows from silence_schedule.
procedure TSettingsMain.SilenceTimerTimer(Sender: TObject);
var
  NowDT: TDateTime;
  HHmm: string;
  Dval: TDateTime;
  EndVal: TDateTime;
  ActionName: string;
  EndDateTime: string;
begin
  if FGeneratedShuttingDown then
    Exit;
  { Note: emails from this procedure are written in HTML therefore the
    line breaks used are <br> }
  if not chkEnableSilence.IsChecked then
    Exit;
  NowDT := Now;
  HHmm := FormatDateTime('HH:nn', NowDT);
  // Funeral Silence START at user-defined date/time
  if dtOtherStart.IsChecked and TryValidateTime(tkOtherStartTime.Text, Dval) and
    SameDate(Date, dtOtherStart.Date) and (FormatDateTime('HH:nn', Dval) = HHmm)
    and (NowDT - FLastSilenceAction > OneMinute) then
  begin
    // Determine and format EndDateTime from edit box
    if TryStrToTime(tkOtherEndTime.Text, EndVal) then
    begin
      EndVal := dtOtherEnd.Date + EndVal; // Combine date and time
      EndDateTime := FormatDateTime('mm/dd/yyyy "at" h:nn ampm', EndVal);
    end
    else
      EndDateTime := 'an unknown time';
    FLastSilenceAction := NowDT;
    MuteUnmuteClick(Sender);
    fmDailyPlayList.AddToLog
      ('The system audio has been muted for Funeral Silence');
    fmDailyPlayList.SendToEmail
      ('The system audio has been muted for Funeral Silence. <br>' +
      'It will be unmuted at ' + EndDateTime + '. <br><br><br>' +
      'This is an automated system notification. Please do not reply.'
      + '<br>');
    Exit;
  end;
  // Liturgical MUTE at 02:05
  if (HHmm = '02:05') and (NowDT - FLastSilenceAction > OneMinute) then
  begin
    ActionName := '';
    if SameDate(Date, dtAshWed.Date) then
      ActionName := 'Ash Wednesday'
    else if SameDate(Date, dtHolyThuBeg.Date) then
      ActionName := 'Holy Thursday - Saturday'
    else if SameDate(Date, dtAllSouls.Date) then
      ActionName := 'All Souls Day';
    if ActionName <> '' then
    begin
      FLastSilenceAction := NowDT;
      MuteUnmuteClick(Sender);
      fmDailyPlayList.AddToLog('The system audio has been muted for ' +
        ActionName);
      fmDailyPlayList.SendToEmail('The system audio has been muted for ' +
        ActionName + '.<br>' +
        'It will be unmuted at the end of the required silence period.<br><br><br>'
        + 'This is an automated system notification. Please do not reply.<br>');
      Exit;
    end;
  end;
  // Funeral Silence END at user-defined date/time
  if dtOtherEnd.IsChecked and TryValidateTime(tkOtherEndTime.Text, Dval) and
    SameDate(Date, dtOtherEnd.Date) and (FormatDateTime('HH:nn', Dval) = HHmm)
    and (NowDT - FLastSilenceAction > OneMinute) then
  begin
    FLastSilenceAction := NowDT;
    MuteUnmuteClick(Sender);
    fmDailyPlayList.AddToLog
      ('The system audio has been unmuted for Funeral Silence');
    fmDailyPlayList.SendToEmail
      ('The system audio has been unmuted for Funeral Silence.' +
      '<br><br><br>This is an automated system notification. Please do not reply.<br>');
    Exit;
  end;
  // Liturgical UNMUTE at 23:55
  if (HHmm = '23:55') and (NowDT - FLastSilenceAction > OneMinute) then
  begin
    ActionName := '';
    if SameDate(Date, dtAshWed.Date) then
      ActionName := 'Ash Wednesday'
    else if SameDate(Date, dtHolySatEnd.Date) then
      ActionName := 'Holy Thursday - Saturday'
    else if SameDate(Date, dtAllSouls.Date) then
      ActionName := 'All Souls Day';
    if ActionName <> '' then
    begin
      FLastSilenceAction := NowDT;
      MuteUnmuteClick(Sender);
      fmDailyPlayList.AddToLog('The system audio has been unmuted for ' +
        ActionName);
      fmDailyPlayList.SendToEmail('The system audio has been unmuted for ' +
        ActionName +
        '. <br><br><br>This is an automated system notification. Please do not reply.'
        + sLineBreak);
      Exit;
    end;
  end;
end;
procedure TSettingsMain.btnRecalcEasterClick(Sender: TObject);
begin
  UpdateEasterDates;
  UpdateAllSoulsDate;
  ShowMessage('Dates updated. Click Save to keep these settings.');
  fmDailyPlayList.AddToLog
    ('Liturgical Dates were recalculated for next occurrence');
end;
procedure TSettingsMain.btnClearOtherDatesClick(Sender: TObject);
begin
  dtOtherStart.Date := Date;
  dtOtherEnd.Date := Date;
  dtOtherStart.IsChecked := False;
  dtOtherEnd.IsChecked := False;
  tkOtherStartTime.Text := '';
  tkOtherEndTime.Text := '';
  fmDailyPlayList.AddToLog('Funeral dates were reset');
end;
procedure TSettingsMain.dtAshWedChange(Sender: TObject);
begin
  if FLoadingSettingsControls then
    Exit;
  if setFDQuery1.Active and (not setFDQuery1.IsEmpty) and not (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Edit;
end;
procedure TSettingsMain.dtHolyThuBegChange(Sender: TObject);
begin
  if FLoadingSettingsControls then
    Exit;
  if dtHolyThuBeg.Date >= dtHolySatEnd.Date then
  begin
    ShowMessage('Holy Thursday must be before Holy Saturday');
    dtHolyThuBeg.Date := IncDay(dtHolySatEnd.Date, -1);
  end;

end;
procedure TSettingsMain.dtHolySatEndChange(Sender: TObject);
begin
  if FLoadingSettingsControls then
    Exit;
  if dtHolySatEnd.Date <= dtHolyThuBeg.Date then
  begin
    ShowMessage('Holy Saturday must be after Holy Thursday');
    dtHolySatEnd.Date := IncDay(dtHolyThuBeg.Date, 1);
  end;

end;
procedure TSettingsMain.dtOtherStartChange(Sender: TObject);
begin
  if FLoadingSettingsControls then
    Exit;
  if setFDQuery1.Active and (not setFDQuery1.IsEmpty) and not (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Edit;
end;

procedure TSettingsMain.dtOtherEndChange(Sender: TObject);
begin
  if FLoadingSettingsControls then
    Exit;
  if setFDQuery1.Active and (not setFDQuery1.IsEmpty) and not (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Edit;
end;

procedure TSettingsMain.dtAllSoulsChange(Sender: TObject);
begin
  if FLoadingSettingsControls then
    Exit;
  if setFDQuery1.Active and (not setFDQuery1.IsEmpty) and not (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Edit;
end;
procedure TSettingsMain.tkOtherStartTimeExit(Sender: TObject);
var
  Dval: TDateTime;
begin
  if tkOtherStartTime.Text = '' then
    Exit;
  // Parse whatever the user typed (h:mm, HH:mm, with or without AM/PM)
  if not TryValidateTime(tkOtherStartTime.Text, Dval) then
  begin
    ShowMessage('Invalid time format. Use h:nn AM/PM or HH:nn');
    tkOtherStartTime.SetFocus;
    Exit;
  end;
  // Redisplay in 12-hour form
  tkOtherStartTime.Text := FormatDateTime('h:nn AM/PM', Dval);
  // Pending until Save
end;
procedure TSettingsMain.tkOtherEndTimeExit(Sender: TObject);
var
  DvalStart, DvalEnd: TDateTime;
begin
  if tkOtherEndTime.Text = '' then
    Exit;
  if not TryValidateTime(tkOtherEndTime.Text, DvalEnd) then
  begin
    ShowMessage('Invalid time format. Use h:nn AM/PM or HH:nn');
    tkOtherEndTime.SetFocus;
    Exit;
  end;
  // Make sure end > start
  if (tkOtherStartTime.Text <> '') and TryValidateTime(tkOtherStartTime.Text,
    DvalStart) and (DvalEnd <= DvalStart) then
  begin
    ShowMessage('End time must be after start time');
    tkOtherEndTime.SetFocus;
    Exit;
  end;
  // Redisplay in 12-hour form
  tkOtherEndTime.Text := FormatDateTime('h:nn AM/PM', DvalEnd);
  // Pending until Save
end;
function TSettingsMain.TryValidateTime(const S: string;
  out D: TDateTime): Boolean;
begin
  Result := TryStrToDateTime(S, D);
end;
procedure TSettingsMain.LoadSilenceSettings;
begin
  FLoadingSettingsControls := True;
  try
    if not setFDQuery1.active then
      setFDQuery1.Open;
    with setFDQuery1 do
    begin
    dtAshWed.Date := FieldByName('ash_wed_begin').AsDateTime;
    dtHolyThuBeg.Date := FieldByName('holy_thu_begin').AsDateTime;
    dtHolySatEnd.Date := FieldByName('holy_sat_end').AsDateTime;
    if FieldByName('other_silence_begin_date').IsNull then
      dtOtherStart.IsChecked := False
    else
    begin
      dtOtherStart.IsChecked := True;
      dtOtherStart.Date := FieldByName('other_silence_begin_date').AsDateTime;
    end;
    if not FieldByName('other_silence_begin_time').IsNull then
      tkOtherStartTime.Text := FormatDateTime('h:nn AM/PM',
        FieldByName('other_silence_begin_time').AsDateTime)
    else
      tkOtherStartTime.Text := '';
    if FieldByName('other_silence_end_date').IsNull then
      dtOtherEnd.IsChecked := False
    else
    begin
      dtOtherEnd.IsChecked := True;
      dtOtherEnd.Date := FieldByName('other_silence_end_date').AsDateTime;
    end;
    if not FieldByName('other_silence_end_time').IsNull then
      tkOtherEndTime.Text := FormatDateTime('h:nn AM/PM',
        FieldByName('other_silence_end_time').AsDateTime)
    else
      tkOtherEndTime.Text := '';
    dtAllSouls.Date := FieldByName('all_souls_day').AsDateTime;
      GeneratedSetToggleState_chkEnableSilence((FieldByName('silence_enabled').AsInteger = 1));
    end;
  finally
    FLoadingSettingsControls := False;
  end;
end;
procedure TSettingsMain.SaveSilenceSettings;
begin
  setFDQuery1.Edit;
  setFDQuery1.FieldByName('ash_wed_begin').AsDateTime := dtAshWed.Date;
  setFDQuery1.FieldByName('holy_thu_begin').AsDateTime := dtHolyThuBeg.Date;
  setFDQuery1.FieldByName('holy_sat_end').AsDateTime := dtHolySatEnd.Date;
  if dtOtherStart.IsChecked then
    setFDQuery1.FieldByName('other_silence_begin_date').AsDateTime := dtOtherStart.Date
  else
    setFDQuery1.FieldByName('other_silence_begin_date').Clear;
  if tkOtherStartTime.Text <> '' then
  begin
    var DT: TDateTime;
    if TryStrToDateTime(tkOtherStartTime.Text, DT) then
      setFDQuery1.FieldByName('other_silence_begin_time').AsDateTime := DT
    else
      setFDQuery1.FieldByName('other_silence_begin_time').Clear;
  end
  else
    setFDQuery1.FieldByName('other_silence_begin_time').Clear;
  if dtOtherEnd.IsChecked then
    setFDQuery1.FieldByName('other_silence_end_date').AsDateTime := dtOtherEnd.Date
  else
    setFDQuery1.FieldByName('other_silence_end_date').Clear;
  if tkOtherEndTime.Text <> '' then
  begin
    var DT: TDateTime;
    if TryStrToDateTime(tkOtherEndTime.Text, DT) then
      setFDQuery1.FieldByName('other_silence_end_time').AsDateTime := DT
    else
      setFDQuery1.FieldByName('other_silence_end_time').Clear;
  end
  else
    setFDQuery1.FieldByName('other_silence_end_time').Clear;
  setFDQuery1.FieldByName('all_souls_day').AsDateTime := dtAllSouls.Date;
  setFDQuery1.FieldByName('silence_enabled').AsInteger := Ord(chkEnableSilence.IsChecked);
  setFDQuery1.Post;
end;
procedure TSettingsMain.UpdateEasterDates;
var
  E: TDate;
  Y: Integer;
begin
  Y := YearOf(Date);
  E := CalculateEasterDate(Y);
  if E < Date then
    E := CalculateEasterDate(Y + 1);
  dtAshWed.Date := IncDay(E, -46);
  dtHolyThuBeg.Date := IncDay(E, -3);
  dtHolySatEnd.Date := IncDay(E, -1);
end;
procedure TSettingsMain.UpdateAllSoulsDate;
var
  D: TDate;
  Y: Integer;
begin
  Y := YearOf(Date);
  D := EncodeDate(Y, 11, 2);
  if D < Date then
    D := EncodeDate(Y + 1, 11, 2);
  dtAllSouls.Date := D;
end;
procedure TSettingsMain.ValidateDateTimeRanges;
var
  DVal1, DVal2: TDateTime;
  StartDT, EndDT: TDateTime;
begin
  // Validate Holy Thursday to Holy Saturday
  if dtHolyThuBeg.IsChecked and dtHolySatEnd.IsChecked and
    (dtHolyThuBeg.Date > dtHolySatEnd.Date) then
    raise Exception.Create
      ('Holy Thursday date must be earlier than Holy Saturday date.');
  // Validate Other Date Ranges
  if dtOtherStart.IsChecked and dtOtherEnd.IsChecked and
    (dtOtherStart.Date > dtOtherEnd.Date) then
    raise Exception.Create('Other Begin Date must be earlier than End Date.');
  // Updated to compare full DateTime instead of just time
  if dtOtherStart.IsChecked and dtOtherEnd.IsChecked and
    TryStrToTime(tkOtherStartTime.Text, DVal1) and
    TryStrToTime(tkOtherEndTime.Text, DVal2) then
  begin
    StartDT := Trunc(dtOtherStart.Date) + Frac(DVal1);
    EndDT := Trunc(dtOtherEnd.Date) + Frac(DVal2);
    if StartDT >= EndDT then
      raise Exception.Create
        ('Start Date/Time must be earlier than End Date/Time.');
  end;
end;
procedure TSettingsMain.GeneratedSetToggleState_chkEnableSilence(AValue: Boolean);
begin
  if FGeneratedShuttingDown then
    Exit;
  if not Assigned(chkEnableSilence) then
    Exit;
  Inc(FGeneratedToggleSuppress_chkEnableSilence);
  try
    chkEnableSilence.IsChecked := AValue;
  finally
    Dec(FGeneratedToggleSuppress_chkEnableSilence);
  end;
end;
procedure TSettingsMain.chkEnableSilence_GeneratedUserChange(Sender: TObject);
begin
  if FGeneratedShuttingDown then
    Exit;
  if FGeneratedToggleSuppress_chkEnableSilence = 0 then
    if Assigned(FGeneratedToggleOriginalClick_chkEnableSilence) then
      FGeneratedToggleOriginalClick_chkEnableSilence(Sender);
  if Assigned(FGeneratedToggleOriginalChange_chkEnableSilence) then
    FGeneratedToggleOriginalChange_chkEnableSilence(Sender);
end;
procedure TSettingsMain.SettingsControlChanged(Sender: TObject);
begin
  if FGeneratedShuttingDown or FLoadingSettingsControls then
    Exit;
  if setFDQuery1.Active and (not setFDQuery1.IsEmpty) and not (setFDQuery1.State in dsEditModes) then
    setFDQuery1.Edit;
end;
function TSettingsMain.HasPendingSettingsChanges: Boolean;
begin
  Result := setFDQuery1.Active and (setFDQuery1.State in dsEditModes);
end;
function TSettingsMain.SavePendingSettingsChanges: Boolean;
begin
  try
    btnSaveSettingsClick(Self);
    Result := not HasPendingSettingsChanges;
  except
    on E: EAbort do
      Result := not HasPendingSettingsChanges;
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
    end;
  end;
end;
procedure TSettingsMain.DiscardPendingSettingsChanges;
begin
  try
    btnCancelSettingsClick(Self);
  except
    on E: EAbort do
      ;
  end;
end;
function TSettingsMain.ConfirmCloseWithPendingSettingsChanges: Boolean;
begin
  Result := True;
  if not HasPendingSettingsChanges then
    Exit;
  case TDialogServiceSync.MessageDialog('Save changes before closing?',
    TMsgDlgType.mtConfirmation, mbYesNoCancel, TMsgDlgBtn.mbCancel, 0) of
    mrYes:
      Result := SavePendingSettingsChanges;
    mrNo:
      begin
        DiscardPendingSettingsChanges;
        Result := not HasPendingSettingsChanges;
      end;
  else
    Result := False;
  end;
end;
procedure TSettingsMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmCloseWithPendingSettingsChanges;
end;
procedure TSettingsMain.GeneratedFormDestroyHandler(Sender: TObject);
begin
  // Generated FMX cleanup for bindings, timers, and media
  FGeneratedShuttingDown := True;
  if Assigned(SilenceTimer) then
  begin
    SilenceTimer.Enabled := False;
    SilenceTimer.OnTimer := nil;
  end;
  if Assigned(Timer1) then
  begin
    Timer1.Enabled := False;
    Timer1.OnTimer := nil;
  end;
  GeneratedCleanupManualFieldBindingsForOwner(Self);
  if Assigned(setDataSource1) and (setDataSource1.Owner <> Self) then
    setDataSource1.OnDataChange := nil;
  if Assigned(DBNavigator1) and (DBNavigator1.Owner <> Self) then
    DBNavigator1.BeforeAction := FOriginal_DBNavigator1_BeforeAction;
  if Assigned(chkEnableSilence) then
  begin
    chkEnableSilence.OnChange := nil;
    chkEnableSilence.OnClick := nil;
  end;
  if Assigned(FGeneratedOriginalOnDestroy) then
    FGeneratedOriginalOnDestroy(Sender);
  if SettingsMain = Self then
    SettingsMain := nil;
end;
procedure TSettingsMain.setDataSource1_GeneratedDataChange(Sender: TObject; Field: TField);
begin
  if (Sender is TDataSource) and Assigned(TDataSource(Sender).DataSet) and
     (TDataSource(Sender).DataSet.State in dsEditModes) then
    Exit;
  GeneratedSyncManualFieldBindingsForDataSet(setFDQuery1);
end;
procedure TSettingsMain.DBNavigator1_GeneratedBeforeAction(Sender: TObject; Button: TBindNavigateBtn);
begin
  case Button of
    nbPost:
    begin
      try
        ValidateDateTimeRanges;
      except
        on E: Exception do
        begin
          ShowMessage(E.Message);
          Abort;
        end;
      end;
      GeneratedCommitManualFieldBindingsForDataSet(setFDQuery1);
      if setFDQuery1.Active and (not setFDQuery1.IsEmpty) then
      begin
        if not (setFDQuery1.State in dsEditModes) then
          setFDQuery1.Edit;
        setFDQuery1.FieldByName('organization_name').AsString := edOrgName.Text;
        setFDQuery1.FieldByName('logging_status').AsInteger := Ord(chkLogOnOff.IsChecked);
        setFDQuery1.FieldByName('ash_wed_begin').AsDateTime := dtAshWed.Date;
        setFDQuery1.FieldByName('holy_thu_begin').AsDateTime := dtHolyThuBeg.Date;
        setFDQuery1.FieldByName('holy_sat_end').AsDateTime := dtHolySatEnd.Date;
        if dtOtherStart.IsChecked then
          setFDQuery1.FieldByName('other_silence_begin_date').AsDateTime := dtOtherStart.Date
        else
          setFDQuery1.FieldByName('other_silence_begin_date').Clear;
        if tkOtherStartTime.Text <> '' then
        begin
          var DT: TDateTime;
          if TryStrToDateTime(tkOtherStartTime.Text, DT) then
            setFDQuery1.FieldByName('other_silence_begin_time').AsDateTime := DT
          else
            setFDQuery1.FieldByName('other_silence_begin_time').Clear;
        end
        else
          setFDQuery1.FieldByName('other_silence_begin_time').Clear;
        if dtOtherEnd.IsChecked then
          setFDQuery1.FieldByName('other_silence_end_date').AsDateTime := dtOtherEnd.Date
        else
          setFDQuery1.FieldByName('other_silence_end_date').Clear;
        if tkOtherEndTime.Text <> '' then
        begin
          var DT: TDateTime;
          if TryStrToDateTime(tkOtherEndTime.Text, DT) then
            setFDQuery1.FieldByName('other_silence_end_time').AsDateTime := DT
          else
            setFDQuery1.FieldByName('other_silence_end_time').Clear;
        end
        else
          setFDQuery1.FieldByName('other_silence_end_time').Clear;
        setFDQuery1.FieldByName('all_souls_day').AsDateTime := dtAllSouls.Date;
        setFDQuery1.FieldByName('silence_enabled').AsInteger := Ord(chkEnableSilence.IsChecked);
      end;
    end;
    nbCancel:
    begin
      if setFDQuery1.Active and (setFDQuery1.State in dsEditModes) then
        setFDQuery1.Cancel;
      GeneratedSyncManualFieldBindingsForDataSet(setFDQuery1);
      if setFDQuery1.Active and (not setFDQuery1.IsEmpty) then
        chkLogOnOff.IsChecked := setFDQuery1.FieldByName('logging_status').AsInteger = 1;
      LoadSilenceSettings;
      Abort;
    end;
  else
    GeneratedCommitManualFieldBindingsForDataSet(setFDQuery1);
  end;
  if Assigned(FOriginal_DBNavigator1_BeforeAction) then
    FOriginal_DBNavigator1_BeforeAction(Sender, Button);
end;
end.

