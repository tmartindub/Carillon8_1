unit RandomDirectory;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
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
  FMX.DialogService.Sync,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  Math,
  RandomDirectoryManager,
  System.Classes,
  System.Rtti,
  System.SysUtils,
  System.UIConsts,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows, FMX.Controls.Presentation, FMX.Layouts;
type
  TfrmRandomDirectory = class(TForm)
    lblHdr: TLabel;
    edRandMusicDir1: TEdit;
    btnSelectDir1: TButton;
    edRandMusicDir2: TEdit;
    btnSelectDir2: TButton;
    edFrmDate2: TEdit;
    edToDate2: TEdit;
    lblFromDate2: TLabel;
    lblToDate2: TLabel;
    edRandMusicDir3: TEdit;
    btnSelectDir3: TButton;
    edFrmDate3: TEdit;
    edToDate3: TEdit;
    lblFromDate3: TLabel;
    lblToDate3: TLabel;
    edRandMusicDir4: TEdit;
    btnSelectDir4: TButton;
    edFrmDate4: TEdit;
    edToDate4: TEdit;
    lblFromDate4: TLabel;
    lblToDate4: TLabel;
    edRandMusicDir5: TEdit;
    btnSelectDir5: TButton;
    edFrmDate5: TEdit;
    edToDate5: TEdit;
    lblFromDate5: TLabel;
    lblToDate5: TLabel;
    edRandMusicDir6: TEdit;
    btnSelectDir6: TButton;
    edFrmDate6: TEdit;
    edToDate6: TEdit;
    lblFromDate6: TLabel;
    lblToDate6: TLabel;
    edRandMusicDir7: TEdit;
    btnSelectDir7: TButton;
    edFrmDate7: TEdit;
    edToDate7: TEdit;
    lblFromDate7: TLabel;
    lblToDate7: TLabel;
    lblNum1: TLabel;
    lblNum2: TLabel;
    lblNum3: TLabel;
    lblNum4: TLabel;
    lblNum5: TLabel;
    lblNum6: TLabel;
    lblNum7: TLabel;
    rdDataSource1: TDataSource;
    rdFDQuery1: TFDQuery;
    rdFDConnection1: TFDConnection;
    rdOpenDialog1: TOpenDialog;
    btnSave: TButton;
    btnCancel: TButton;
    brnClose: TButton;
    DBNavigator1: TBindNavigator;
    procedure FormCreate(Sender: TObject);
    procedure brnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FGeneratedOriginalOnDestroy: TNotifyEvent;
    BindSourceDB_rdDataSource1: TBindSourceDB;
    FLoadingSlots: Boolean;
    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    procedure RandomFieldChanged(Sender: TObject);
    procedure GeneratedFormDestroyHandler(Sender: TObject);
    function HasPendingRandomDirectoryChanges: Boolean;
    function SavePendingRandomDirectoryChanges: Boolean;
    function ConfirmCloseWithPendingRandomDirectoryChanges: Boolean;
    procedure DiscardPendingRandomDirectoryChanges;
    procedure WireHandlers;
    procedure SelectDirClick(Sender: TObject);
    function ChooseDirectory(const InitialDir: string): string;
    procedure ApplyTheme;
    procedure LoadSlots;
    procedure SaveSlots;
    procedure CancelSlots;
    function BuildSlot(const ASlotNo: Integer; ADirEdit, AFromEdit, AToEdit: TEdit): TRandomDirectorySlot;
    function FormatAnnualDate(const ADate: TDateTime; const AHasDate: Boolean): string;
    function TryParseAnnualDate(const AText: string; const AIsToDate: Boolean; const AFromDate: TDateTime; const AHasFromDate: Boolean; out ADate: TDateTime; out AHasDate: Boolean): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
var
  frmRandomDirectory: TfrmRandomDirectory;
implementation

uses
  CarillonTheme;

{$R *.fmx}

constructor TfrmRandomDirectory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FormCreate(Self);
  ConfigurePortableSQLiteConnection(rdFDConnection1);
  rdFDConnection1.Connected := True;
  rdFDQuery1.Connection := rdFDConnection1;
  EnsureRandomDirectorySchema(rdFDConnection1);
  rdFDQuery1.UpdateOptions.UpdateTableName := 'PL_RAND_DIR_ROTATION';
  rdFDQuery1.UpdateOptions.KeyFields := 'slot_no';
  rdFDQuery1.SQL.Text := 'SELECT * FROM PL_RAND_DIR_ROTATION ORDER BY slot_no';
  rdFDQuery1.Open;
  rdDataSource1.DataSet := rdFDQuery1;
  LoadSlots;
  WireHandlers;
end;
destructor TfrmRandomDirectory.Destroy;
begin
  if rdFDQuery1.Active then
    rdFDQuery1.Close;
  if rdFDConnection1.Connected then
    rdFDConnection1.Connected := False;
  inherited Destroy;
end;
procedure TfrmRandomDirectory.FormActivate(Sender: TObject);
begin
  ApplyTheme;
end;
procedure TfrmRandomDirectory.FormCreate(Sender: TObject);
begin
  FGeneratedOriginalOnDestroy := Self.OnDestroy;
  Self.OnDestroy := GeneratedFormDestroyHandler;
  Self.OnCloseQuery := FormCloseQuery;
  ApplyTheme;
  if BindSourceDB_rdDataSource1 = nil then
  begin
    BindSourceDB_rdDataSource1 := TBindSourceDB.Create(Self);
    BindSourceDB_rdDataSource1.DataSource := rdDataSource1;
  end;
  if Assigned(DBNavigator1) then
  begin
    DBNavigator1.DataSource := BindSourceDB_rdDataSource1;
    DBNavigator1.BeforeAction := DBNavigator1BeforeAction;
  end;
end;
procedure TfrmRandomDirectory.ApplyTheme;
var
  Q: TFDQuery;
  BG, FG: TAlphaColor;
  i: Integer;
begin
  BG := $8EBDDC;
  FG := $000080;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := rdFDConnection1;
    Q.SQL.Text := 'SELECT form_bgcolor, form_fontcolor FROM pl_settings';
    Q.Open;
    if not Q.IsEmpty then
    begin
      BG := VCLColorToAlphaColor(Q.FieldByName('form_bgcolor').AsInteger);
      FG := VCLColorToAlphaColor(Q.FieldByName('form_fontcolor').AsInteger);
    end;
  finally
    Q.Free;
  end;
  Self.Fill.Kind := TBrushKind.Solid;
  Self.Fill.Color := BG;
  ApplyContainerBackgroundColor(Self, BG);
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TLabel then
      TLabel(Components[i]).TextSettings.FontColor := FG;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TButton then
      ApplyTieredButtonStyle(TButton(Components[i]), BG, FG)
    else if Components[i] is TEdit then
      ApplyCardEditStyle(TStyledControl(Components[i]), BG, FG);
end;
procedure TfrmRandomDirectory.LoadSlots;
var
  Slots: array[0..6] of TRandomDirectorySlot;
begin
  FLoadingSlots := True;
  try
    LoadRandomDirectorySlots(rdFDConnection1, Slots);
    edRandMusicDir1.Text := Slots[0].MusicDir;
    edRandMusicDir2.Text := Slots[1].MusicDir;
    edFrmDate2.Text := FormatAnnualDate(Slots[1].FromDate, Slots[1].HasFromDate);
    edToDate2.Text := FormatAnnualDate(Slots[1].ToDate, Slots[1].HasToDate);
    edRandMusicDir3.Text := Slots[2].MusicDir;
    edFrmDate3.Text := FormatAnnualDate(Slots[2].FromDate, Slots[2].HasFromDate);
    edToDate3.Text := FormatAnnualDate(Slots[2].ToDate, Slots[2].HasToDate);
    edRandMusicDir4.Text := Slots[3].MusicDir;
    edFrmDate4.Text := FormatAnnualDate(Slots[3].FromDate, Slots[3].HasFromDate);
    edToDate4.Text := FormatAnnualDate(Slots[3].ToDate, Slots[3].HasToDate);
    edRandMusicDir5.Text := Slots[4].MusicDir;
    edFrmDate5.Text := FormatAnnualDate(Slots[4].FromDate, Slots[4].HasFromDate);
    edToDate5.Text := FormatAnnualDate(Slots[4].ToDate, Slots[4].HasToDate);
    edRandMusicDir6.Text := Slots[5].MusicDir;
    edFrmDate6.Text := FormatAnnualDate(Slots[5].FromDate, Slots[5].HasFromDate);
    edToDate6.Text := FormatAnnualDate(Slots[5].ToDate, Slots[5].HasToDate);
    edRandMusicDir7.Text := Slots[6].MusicDir;
    edFrmDate7.Text := FormatAnnualDate(Slots[6].FromDate, Slots[6].HasFromDate);
    edToDate7.Text := FormatAnnualDate(Slots[6].ToDate, Slots[6].HasToDate);
  finally
    FLoadingSlots := False;
  end;
end;

procedure TfrmRandomDirectory.SaveSlots;
var
  Slots: array[0..6] of TRandomDirectorySlot;
begin
  Slots[0] := BuildSlot(1, edRandMusicDir1, nil, nil);
  Slots[1] := BuildSlot(2, edRandMusicDir2, edFrmDate2, edToDate2);
  Slots[2] := BuildSlot(3, edRandMusicDir3, edFrmDate3, edToDate3);
  Slots[3] := BuildSlot(4, edRandMusicDir4, edFrmDate4, edToDate4);
  Slots[4] := BuildSlot(5, edRandMusicDir5, edFrmDate5, edToDate5);
  Slots[5] := BuildSlot(6, edRandMusicDir6, edFrmDate6, edToDate6);
  Slots[6] := BuildSlot(7, edRandMusicDir7, edFrmDate7, edToDate7);
  SaveRandomDirectorySlots(rdFDConnection1, Slots);
  rdFDQuery1.Refresh;
end;
procedure TfrmRandomDirectory.CancelSlots;
begin
  LoadSlots;
end;
procedure TfrmRandomDirectory.RandomFieldChanged(Sender: TObject);
begin
  if FLoadingSlots then
    Exit;
  if rdFDQuery1.Active and (not rdFDQuery1.IsEmpty) and not (rdFDQuery1.State in dsEditModes) then
    rdFDQuery1.Edit;
end;

procedure TfrmRandomDirectory.DBNavigator1BeforeAction(Sender: TObject; Button: TBindNavigateBtn);
begin
  case Button of
    nbPost:
    begin
      SaveSlots;
      if rdFDQuery1.Active and (rdFDQuery1.State in dsEditModes) then
        rdFDQuery1.Cancel;
      LoadSlots;
      Abort;
    end;
    nbCancel:
    begin
      CancelSlots;
      if rdFDQuery1.Active and (rdFDQuery1.State in dsEditModes) then
        rdFDQuery1.Cancel;
      Abort;
    end;
  end;
end;
function TfrmRandomDirectory.HasPendingRandomDirectoryChanges: Boolean;
begin
  Result := rdFDQuery1.Active and (rdFDQuery1.State in dsEditModes);
end;
function TfrmRandomDirectory.SavePendingRandomDirectoryChanges: Boolean;
begin
  try
    DBNavigator1BeforeAction(Self, nbPost);
    Result := not HasPendingRandomDirectoryChanges;
  except
    on E: EAbort do
      Result := not HasPendingRandomDirectoryChanges;
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
    end;
  end;
end;
procedure TfrmRandomDirectory.DiscardPendingRandomDirectoryChanges;
begin
  try
    DBNavigator1BeforeAction(Self, nbCancel);
  except
    on E: EAbort do
      ;
  end;
end;
function TfrmRandomDirectory.ConfirmCloseWithPendingRandomDirectoryChanges: Boolean;
begin
  Result := True;
  if not HasPendingRandomDirectoryChanges then
    Exit;
  case TDialogServiceSync.MessageDialog('Save changes before closing?',
    TMsgDlgType.mtConfirmation, mbYesNoCancel, TMsgDlgBtn.mbCancel, 0) of
    mrYes:
      Result := SavePendingRandomDirectoryChanges;
    mrNo:
      begin
        DiscardPendingRandomDirectoryChanges;
        Result := not HasPendingRandomDirectoryChanges;
      end;
  else
    Result := False;
  end;
end;
procedure TfrmRandomDirectory.SelectDirClick(Sender: TObject);
var
  N: Integer;
  NewDir: string;
  Edit: TEdit;
begin
  N := TComponent(Sender).Tag;
  if (N < 1) or (N > 7) then
    Exit;
  Edit := TEdit(FindComponent('edRandMusicDir' + IntToStr(N)));
  if not Assigned(Edit) then
    Exit;
  NewDir := ChooseDirectory(Edit.Text);
  if NewDir <> '' then
    Edit.Text := NewDir;
end;
procedure TfrmRandomDirectory.WireHandlers;
var
  I: Integer;
  Component: TComponent;
begin
  for I := 1 to 7 do
  begin
    Component := FindComponent('btnSelectDir' + IntToStr(I));
    if Component is TButton then
    begin
      TButton(Component).Tag := I;
      TButton(Component).OnClick := SelectDirClick;
    end;
    Component := FindComponent('edRandMusicDir' + IntToStr(I));
    if Component is TEdit then
      TEdit(Component).OnChangeTracking := RandomFieldChanged;
    Component := FindComponent('edFrmDate' + IntToStr(I));
    if Component is TEdit then
      TEdit(Component).OnChangeTracking := RandomFieldChanged;
    Component := FindComponent('edToDate' + IntToStr(I));
    if Component is TEdit then
      TEdit(Component).OnChangeTracking := RandomFieldChanged;
  end;
  if Assigned(btnSave) then
    btnSave.Visible := False;
  if Assigned(btnCancel) then
    btnCancel.Visible := False;
end;

function TfrmRandomDirectory.FormatAnnualDate(const ADate: TDateTime;
  const AHasDate: Boolean): string;
begin
  if AHasDate then
    Result := FormatDateTime('mm/dd', ADate)
  else
    Result := '';
end;

function TfrmRandomDirectory.TryParseAnnualDate(const AText: string;
  const AIsToDate: Boolean; const AFromDate: TDateTime;
  const AHasFromDate: Boolean; out ADate: TDateTime;
  out AHasDate: Boolean): Boolean;
var
  Day: Integer;
  Month: Integer;
  Parsed: TDateTime;
  Parts: TArray<string>;
  Year: Word;
begin
  Result := True;
  ADate := 0;
  AHasDate := Trim(AText) <> '';
  if not AHasDate then
    Exit;
  Parts := Trim(AText).Split(['/']);
  if (Length(Parts) <> 2) or (not TryStrToInt(Parts[0], Month)) or
    (not TryStrToInt(Parts[1], Day)) then
    Exit(False);
  Year := YearOf(Date);
  try
    Parsed := EncodeDate(Year, Month, Day);
  except
    Exit(False);
  end;
  if AIsToDate and AHasFromDate and (Parsed < AFromDate) then
    Parsed := IncYear(Parsed, 1);
  ADate := Parsed;
end;

function TfrmRandomDirectory.BuildSlot(const ASlotNo: Integer; ADirEdit,
  AFromEdit, AToEdit: TEdit): TRandomDirectorySlot;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.SlotNo := ASlotNo;
  if Assigned(ADirEdit) then
    Result.MusicDir := Trim(ADirEdit.Text);
  if Assigned(AFromEdit) and not TryParseAnnualDate(AFromEdit.Text, False, 0,
    False, Result.FromDate, Result.HasFromDate) then
    raise Exception.Create(Format('Slot %d From date must use mm/dd format.',
      [ASlotNo]));
  if Assigned(AToEdit) and not TryParseAnnualDate(AToEdit.Text, True,
    Result.FromDate, Result.HasFromDate, Result.ToDate, Result.HasToDate) then
    raise Exception.Create(Format('Slot %d To date must use mm/dd format.',
      [ASlotNo]));
end;
function TfrmRandomDirectory.ChooseDirectory(const InitialDir: string): string;
var
  D: string;
begin
  D := InitialDir;
  if (D = '') or not DirectoryExists(D) then
    D := ExtractFilePath(ParamStr(0));
  if SelectDirectory('Select directory', '', D) then
    Result := D
  else
    Result := '';
end;
procedure TfrmRandomDirectory.brnCloseClick(Sender: TObject);
begin
  if ConfirmCloseWithPendingRandomDirectoryChanges then
    Close;
end;
procedure TfrmRandomDirectory.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmCloseWithPendingRandomDirectoryChanges;
end;
procedure TfrmRandomDirectory.GeneratedFormDestroyHandler(Sender: TObject);
begin
  if Assigned(rdDataSource1) and (rdDataSource1.Owner <> Self) then
    rdDataSource1.OnDataChange := nil;
  if Assigned(FGeneratedOriginalOnDestroy) then
    FGeneratedOriginalOnDestroy(Sender);
end;
end.
