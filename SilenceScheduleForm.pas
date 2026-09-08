unit SilenceScheduleForm;

// Version: 8.1
interface

uses
  Data.DB,
  Data.Bind.DBScope,
  FireDAC.Comp.Client,
  FMX.Controls,
  FMX.Edit,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.UITypes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FMX.Controls.Presentation, Fmx.Bind.Navigator,
  Data.Bind.Controls, FMX.Layouts;

type
  TfrmSilenceSchedule = class(TForm)
    btnClose: TButton;
    btnFirst: TButton;
    btnLast: TButton;
    btnNext: TButton;
    btnPrior: TButton;
    btnSave: TButton;
    chkEnabled: TCheckBox;
    chkFriday: TCheckBox;
    chkMonday: TCheckBox;
    chkSaturday: TCheckBox;
    chkSunday: TCheckBox;
    chkThursday: TCheckBox;
    chkTuesday: TCheckBox;
    chkWednesday: TCheckBox;
    edEndTime: TEdit;
    edPurpose: TEdit;
    edStartTime: TEdit;
    lblDays: TLabel;
    lblEndTime: TLabel;
    lblEntry: TLabel;
    lblHeader: TLabel;
    lblNote: TLabel;
    lblPurpose: TLabel;
    lblStartTime: TLabel;
    lblStatus: TLabel;
    SilenceConnection: TFDConnection;
    SilenceDataSource: TDataSource;
    SilenceQuery: TFDQuery;
    DBNavigator1: TBindNavigator;
    procedure btnCloseClick(Sender: TObject);
    procedure btnFirstClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure ControlChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FDirty: Boolean;
    FLoadingControls: Boolean;
    BindSourceDB_SilenceDataSource: TBindSourceDB;
    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    procedure SilenceQueryAfterScroll(DataSet: TDataSet);
    function FormatTimeEdit(const AEdit: TEdit): Boolean;
    procedure LoadControlsFromRecord;
    procedure MoveToRecord(const ADirection: Integer);
    procedure OpenSilenceSchedule;
    procedure RefreshMainSchedule;
    function SaveControlsToRecord: Boolean;
    procedure SetDirty(const AValue: Boolean);
    procedure UpdateNavigationState;
  public
  end;

var
  frmSilenceSchedule: TfrmSilenceSchedule;

implementation

uses
  CarillonTheme,
  DateUtils,
  FMX.DialogService.Sync,
  FMX.Dialogs,
  Playlist,
  SilenceManager;

{$R *.fmx}

function TryParseScheduleClockTime(const AInput: string; out ATime: TTime): Boolean;
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
  LText := UpperCase(Trim(AInput));
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

function NormalizeScheduleClockTime(const AInput: string; out ANormalized: string;
  out ATime: TTime): Boolean;
begin
  Result := TryParseScheduleClockTime(AInput, ATime);
  if Result then
    ANormalized := FormatDateTime('h:nn:ss AM/PM', ATime)
  else
    ANormalized := '';
end;

procedure TfrmSilenceSchedule.btnCloseClick(Sender: TObject);
begin
  if FDirty then
  begin
    case TDialogServiceSync.MessageDialog('Save changes before closing?',
      TMsgDlgType.mtConfirmation, mbYesNoCancel, TMsgDlgBtn.mbYes, 0) of
      mrYes:
        if not SaveControlsToRecord then
          Exit;
      mrCancel:
        Exit;
    end;
  end;
  SetDirty(False);
  if TFmxFormState.Modal in FormState then
    ModalResult := mrOk
  else
    Hide;
end;

procedure TfrmSilenceSchedule.btnFirstClick(Sender: TObject);
begin
  if not SaveControlsToRecord then
    Exit;
  SilenceQuery.First;
  LoadControlsFromRecord;
end;

procedure TfrmSilenceSchedule.btnLastClick(Sender: TObject);
begin
  if not SaveControlsToRecord then
    Exit;
  SilenceQuery.Last;
  LoadControlsFromRecord;
end;

procedure TfrmSilenceSchedule.btnNextClick(Sender: TObject);
begin
  MoveToRecord(1);
end;

procedure TfrmSilenceSchedule.btnPriorClick(Sender: TObject);
begin
  MoveToRecord(-1);
end;

procedure TfrmSilenceSchedule.btnSaveClick(Sender: TObject);
begin
  if SaveControlsToRecord then
    lblStatus.Text := 'Silence schedule saved.';
end;

procedure TfrmSilenceSchedule.ControlChanged(Sender: TObject);
begin
  if not FLoadingControls then
  begin
    if SilenceQuery.Active and (not SilenceQuery.IsEmpty) and
      not (SilenceQuery.State in dsEditModes) then
      SilenceQuery.Edit;
    SetDirty(True);
  end;
end;

procedure TfrmSilenceSchedule.DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
begin
  case Button of
    TBindNavigateBtn.nbPost:
    begin
      if not SaveControlsToRecord then
        Abort;
      lblStatus.Text := 'Silence schedule saved.';
      Abort;
    end;
    TBindNavigateBtn.nbCancel:
    begin
      if SilenceQuery.Active and (SilenceQuery.State in dsEditModes) then
        SilenceQuery.Cancel;
      LoadControlsFromRecord;
      Abort;
    end;
    TBindNavigateBtn.nbFirst, TBindNavigateBtn.nbPrior, TBindNavigateBtn.nbNext, TBindNavigateBtn.nbLast:
      if not SaveControlsToRecord then
        Abort;
  end;
end;

procedure TfrmSilenceSchedule.SilenceQueryAfterScroll(DataSet: TDataSet);
begin
  LoadControlsFromRecord;
end;
function TfrmSilenceSchedule.FormatTimeEdit(const AEdit: TEdit): Boolean;
var
  Normalized: string;
  TimeValue: TTime;
begin
  Result := True;
  if Trim(AEdit.Text) = '' then
    Exit;

  if not NormalizeScheduleClockTime(AEdit.Text, Normalized, TimeValue) then
  begin
    ShowMessage('Enter times as 24-hour HH:MM:SS or 12-hour h:MM:SS AM/PM, for example 22:15:30 or 10:15:30 PM.');
    Exit(False);
  end;

  AEdit.Text := Normalized;
end;

procedure TfrmSilenceSchedule.FormCreate(Sender: TObject);
begin
  FDirty := False;
  FLoadingControls := False;
  if BindSourceDB_SilenceDataSource = nil then
  begin
    BindSourceDB_SilenceDataSource := TBindSourceDB.Create(Self);
    BindSourceDB_SilenceDataSource.DataSource := SilenceDataSource;
  end;
  if Assigned(DBNavigator1) then
  begin
    DBNavigator1.DataSource := BindSourceDB_SilenceDataSource;
    DBNavigator1.BeforeAction := DBNavigator1BeforeAction;
  end;
  SilenceQuery.AfterScroll := SilenceQueryAfterScroll;
  OpenSilenceSchedule;
  ApplyCurrentCarillonThemeToForm(Self);
end;

procedure TfrmSilenceSchedule.FormShow(Sender: TObject);
begin
  if not SilenceQuery.Active then
    OpenSilenceSchedule;
  LoadControlsFromRecord;
  ApplyCurrentCarillonThemeToForm(Self);
end;

procedure TfrmSilenceSchedule.LoadControlsFromRecord;
  function DisplayTimeText(const AValue: string): string;
  var
    Normalized: string;
    TimeValue: TTime;
  begin
    Result := Trim(AValue);
    if Result = '' then
      Exit;
    if NormalizeScheduleClockTime(Result, Normalized, TimeValue) then
      Result := Normalized;
  end;
begin
  if (SilenceQuery = nil) or (not SilenceQuery.Active) or SilenceQuery.IsEmpty then
    Exit;

  FLoadingControls := True;
  try
    lblEntry.Text := Format('Silence Window %d of 12',
      [SilenceQuery.FieldByName('silence_id').AsInteger]);
    chkEnabled.IsChecked := SilenceQuery.FieldByName('enabled').AsInteger <> 0;
    edPurpose.Text := SilenceQuery.FieldByName('Purpose').AsString;
    edStartTime.Text := DisplayTimeText(SilenceQuery.FieldByName('start_time').AsString);
    edEndTime.Text := DisplayTimeText(SilenceQuery.FieldByName('end_time').AsString);
    chkMonday.IsChecked := SilenceQuery.FieldByName('monday').AsInteger <> 0;
    chkTuesday.IsChecked := SilenceQuery.FieldByName('tuesday').AsInteger <> 0;
    chkWednesday.IsChecked := SilenceQuery.FieldByName('wednesday').AsInteger <> 0;
    chkThursday.IsChecked := SilenceQuery.FieldByName('thursday').AsInteger <> 0;
    chkFriday.IsChecked := SilenceQuery.FieldByName('friday').AsInteger <> 0;
    chkSaturday.IsChecked := SilenceQuery.FieldByName('saturday').AsInteger <> 0;
    chkSunday.IsChecked := SilenceQuery.FieldByName('sunday').AsInteger <> 0;
    lblStatus.Text := '';
    SetDirty(False);
  finally
    FLoadingControls := False;
  end;

  UpdateNavigationState;
end;

procedure TfrmSilenceSchedule.MoveToRecord(const ADirection: Integer);
begin
  if not SaveControlsToRecord then
    Exit;

  if ADirection < 0 then
    SilenceQuery.Prior
  else if ADirection > 0 then
    SilenceQuery.Next;

  if SilenceQuery.Bof then
    SilenceQuery.First
  else if SilenceQuery.Eof then
    SilenceQuery.Last;

  LoadControlsFromRecord;
end;

procedure TfrmSilenceSchedule.OpenSilenceSchedule;
begin
  ConfigurePortableSQLiteConnection(SilenceConnection);
  SilenceConnection.Connected := True;
  TSilenceManager.EnsureDatabaseReady(SilenceConnection);

  SilenceQuery.Close;
  SilenceQuery.Connection := SilenceConnection;
  SilenceQuery.UpdateOptions.UpdateMode := upWhereKeyOnly;
  SilenceQuery.UpdateOptions.KeyFields := 'silence_id';
  SilenceQuery.SQL.Text :=
    'SELECT silence_id, enabled, Purpose, start_time, end_time, monday, ' +
    'tuesday, wednesday, thursday, friday, saturday, sunday ' +
    'FROM silence_schedule ORDER BY silence_id';
  SilenceQuery.Open;
  SilenceDataSource.DataSet := SilenceQuery;
  if not SilenceQuery.IsEmpty then
    SilenceQuery.First;
  LoadControlsFromRecord;
end;

procedure TfrmSilenceSchedule.RefreshMainSchedule;
begin
  if Assigned(fmDailyPlayList) then
    fmDailyPlayList.RefreshSilenceRulesAndSchedule;
end;

function TfrmSilenceSchedule.SaveControlsToRecord: Boolean;
var
  EndTime: TTime;
  EndTimeStorage: string;
  NewPurpose: string;
  OldEnabled: Boolean;
  OldPurpose: string;
  StartTime: TTime;
  StartTimeStorage: string;
  WindowId: Integer;
begin
  if (SilenceQuery = nil) or (not SilenceQuery.Active) or SilenceQuery.IsEmpty then
    Exit(True);

  try
    if not FormatTimeEdit(edStartTime) then
      Exit(False);
    if not FormatTimeEdit(edEndTime) then
      Exit(False);
  except
    Exit(False);
  end;

  StartTimeStorage := '';
  EndTimeStorage := '';
  if Trim(edStartTime.Text) <> '' then
  begin
    if not TryParseScheduleClockTime(edStartTime.Text, StartTime) then
    begin
      ShowMessage('Enter times as 24-hour HH:MM:SS or 12-hour h:MM:SS AM/PM.');
      edStartTime.SetFocus;
      Exit(False);
    end;
    StartTimeStorage := FormatDateTime('HH:NN:SS', StartTime);
  end;
  if Trim(edEndTime.Text) <> '' then
  begin
    if not TryParseScheduleClockTime(edEndTime.Text, EndTime) then
    begin
      ShowMessage('Enter times as 24-hour HH:MM:SS or 12-hour h:MM:SS AM/PM.');
      edEndTime.SetFocus;
      Exit(False);
    end;
    EndTimeStorage := FormatDateTime('HH:NN:SS', EndTime);
  end;

  if chkEnabled.IsChecked then
  begin
    if Trim(edStartTime.Text) = '' then
    begin
      ShowMessage('Start time is required when a silence window is enabled.');
      edStartTime.SetFocus;
      Exit(False);
    end;

    if Trim(edEndTime.Text) = '' then
    begin
      ShowMessage('End time is required when a silence window is enabled.');
      edEndTime.SetFocus;
      Exit(False);
    end;

    if CompareTime(StartTime, EndTime) = 0 then
    begin
      ShowMessage('Start time and end time cannot be the same.');
      edEndTime.SetFocus;
      Exit(False);
    end;
  end;

  if not FDirty then
    Exit(True);

  WindowId := SilenceQuery.FieldByName('silence_id').AsInteger;
  OldEnabled := SilenceQuery.FieldByName('enabled').AsInteger <> 0;
  OldPurpose := Trim(SilenceQuery.FieldByName('Purpose').AsString);
  if OldPurpose = '' then
    OldPurpose := Format('Silence Window %d', [WindowId]);
  NewPurpose := Trim(edPurpose.Text);
  if NewPurpose = '' then
    NewPurpose := Format('Silence Window %d', [WindowId]);

  SilenceQuery.Edit;
  SilenceQuery.FieldByName('enabled').AsInteger := Ord(chkEnabled.IsChecked);
  SilenceQuery.FieldByName('Purpose').AsString := NewPurpose;
  SilenceQuery.FieldByName('start_time').AsString := StartTimeStorage;
  SilenceQuery.FieldByName('end_time').AsString := EndTimeStorage;
  SilenceQuery.FieldByName('monday').AsInteger := Ord(chkMonday.IsChecked);
  SilenceQuery.FieldByName('tuesday').AsInteger := Ord(chkTuesday.IsChecked);
  SilenceQuery.FieldByName('wednesday').AsInteger := Ord(chkWednesday.IsChecked);
  SilenceQuery.FieldByName('thursday').AsInteger := Ord(chkThursday.IsChecked);
  SilenceQuery.FieldByName('friday').AsInteger := Ord(chkFriday.IsChecked);
  SilenceQuery.FieldByName('saturday').AsInteger := Ord(chkSaturday.IsChecked);
  SilenceQuery.FieldByName('sunday').AsInteger := Ord(chkSunday.IsChecked);
  SilenceQuery.Post;

  if Assigned(fmDailyPlayList) then
  begin
    if (not OldEnabled) and chkEnabled.IsChecked then
      fmDailyPlayList.AddToLog(Format(
        'Silence window enabled: %d - %s, %s to %s',
        [WindowId, NewPurpose, Trim(edStartTime.Text), Trim(edEndTime.Text)]))
    else if OldEnabled and (not chkEnabled.IsChecked) then
      fmDailyPlayList.AddToLog(Format('Silence window disabled: %d - %s',
        [WindowId, OldPurpose]))
    else if chkEnabled.IsChecked then
      fmDailyPlayList.AddToLog(Format(
        'Silence window updated: %d - %s, %s to %s',
        [WindowId, NewPurpose, Trim(edStartTime.Text), Trim(edEndTime.Text)]));
  end;

  SetDirty(False);
  RefreshMainSchedule;
  Result := True;
end;

procedure TfrmSilenceSchedule.SetDirty(const AValue: Boolean);
begin
  FDirty := AValue;
  if FDirty then
    lblStatus.Text := 'Unsaved changes'
  else if Assigned(lblStatus) and SameText(lblStatus.Text, 'Unsaved changes') then
    lblStatus.Text := '';
end;

procedure TfrmSilenceSchedule.UpdateNavigationState;
begin
  if (SilenceQuery = nil) or (not SilenceQuery.Active) then
    Exit;

  btnFirst.Enabled := not SilenceQuery.Bof;
  btnPrior.Enabled := not SilenceQuery.Bof;
  btnNext.Enabled := not SilenceQuery.Eof;
  btnLast.Enabled := not SilenceQuery.Eof;
end;

end.
