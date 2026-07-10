unit GroupForm;
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
  FireDAC.Phys.IB,
  FireDAC.Phys.IBDef,
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
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.ImgList,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  Math,
  Overlay,
  System.Classes,
  System.ImageList,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UIConsts,
  System.UITypes,
  System.Variants,
  Winapi.Messages,
  Winapi.Windows, FMX.ScrollBox, FMX.Layouts, FMX.Controls.Presentation;
type
  TGroups = class(TForm)
    DBNavigator1: TBindNavigator;
    btnClose: TButton;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDTable1: TFDTable;
    DataSource1: TDataSource;
    Label1: TLabel;
    DBGrid1: TStringGrid;
    btnRecalculateDates: TButton;
    ImageList1: TImageList;
    Timer1: TTimer;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRecalculateDatesClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure Timer1Timer(Sender: TObject);
    // New procedure for holiday calculations
  private
    FGeneratedOriginalOnDestroy: TNotifyEvent;
    FGeneratedShuttingDown: Boolean;
    FLastAutoRecalcYear: Integer;
    BindSourceDB_DataSource1: TBindSourceDB;
    FOriginal_DBNavigator1_BeforeAction: EBindNavClick;
    GridEditorPanel_DBGrid1: TPanel;
    FUpdatingSelection_DBGrid1: Integer;
    Lbl_DBGrid1_0: TLabel;
    Ed_DBGrid1_0: TEdit;
    Lbl_DBGrid1_1: TLabel;
    Ed_DBGrid1_1: TDateEdit;
    Lbl_DBGrid1_2: TLabel;
    Ed_DBGrid1_2: TDateEdit;
    Lbl_DBGrid1_3: TLabel;
    Ed_DBGrid1_3: TTimeEdit;
    { Private declarations }
    procedure GeneratedFormDestroyHandler(Sender: TObject);
    procedure DBGrid1_GeneratedSelChanged(Sender: TObject);
    procedure DBGrid1_GeneratedCellClick(const Column: TColumn; const Row: Integer);
    procedure DBGrid1_RefreshSelectorGrid;
    procedure DBGrid1_SyncGeneratedEditors;
    procedure DBGrid1_CommitGeneratedEditors;
    function DBGrid1_TryParseGeneratedDate(const AInput: string; out AValue: TDateTime): Boolean;
    function DBGrid1_TryParseGeneratedTime(const AInput: string; out AValue: TDateTime): Boolean;
    function DBGrid1_AssignGeneratedFieldValue(AField: TField; const AInput: string; out ANormalized: string; out AError: string): Boolean;
    procedure DBNavigator1_GeneratedBeforeAction(Sender: TObject; Button: TBindNavigateBtn);
    procedure DBGrid1_GeneratedMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure Ed_DBGrid1_0_GeneratedExit(Sender: TObject);
    procedure Ed_DBGrid1_0_GeneratedChangeTracking(Sender: TObject);
    procedure Ed_DBGrid1_0_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure Ed_DBGrid1_1_GeneratedExit(Sender: TObject);
    procedure Ed_DBGrid1_1_GeneratedChangeTracking(Sender: TObject);
    procedure Ed_DBGrid1_1_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure Ed_DBGrid1_2_GeneratedExit(Sender: TObject);
    procedure Ed_DBGrid1_2_GeneratedChangeTracking(Sender: TObject);
    procedure Ed_DBGrid1_2_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure Ed_DBGrid1_3_GeneratedExit(Sender: TObject);
    procedure Ed_DBGrid1_3_GeneratedChangeTracking(Sender: TObject);
    procedure Ed_DBGrid1_3_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure DataSource1_GeneratedDataChange(Sender: TObject; Field: TField);
    procedure ResizeFormForResolution(AForm: TForm);
  public
    { Public declarations }
  end;
var
  Groups: TGroups;
implementation
uses
  CarillonTheme,
  EasterCalculator;
{$R *.fmx}
procedure ApplyGridSelectionColor(const AGrid: TFmxObject; const Color: TAlphaColor);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplySelectionToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
    TintObj: ITintedObject;
  begin
    if Node = nil then
      Exit;
    if Supports(Node, ITintedObject, TintObj) then
      TintObj.TintColor := Color;
    if Node is TShape then
    begin
      TShape(Node).Fill.Color := Color;
      TShape(Node).Stroke.Color := Color;
    end;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplySelectionToStyleTree(Node.Children[J]);
  end;
begin
  if not (AGrid is TStyledControl) then
    Exit;
  Styled := TStyledControl(AGrid);
  Styled.ApplyStyleLookup;
  Styled.StylesData['selection.Fill.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['selection.Stroke.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['focus.Fill.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['focus.Stroke.Color'] := TValue.From<TAlphaColor>(Color);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>('selection', StyleObj) then
    ApplySelectionToStyleTree(StyleObj);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>('focus', StyleObj) then
    ApplySelectionToStyleTree(StyleObj);
end;
function CalculateThanksgiving(Year: Integer): TDateTime;
var
  FirstDayOfMonth: TDateTime;
begin
  FirstDayOfMonth := EncodeDate(Year, 11, 1);
  Result := FirstDayOfMonth +
    (((4 - DayOfTheWeek(FirstDayOfMonth)) + 7) mod 7) + 21;
end;
function CalculateMemorialDay(Year: Integer): TDateTime;
var
  LastDayOfMonth: TDateTime;
begin
  // Find the last day of May
  LastDayOfMonth := EncodeDate(Year, 5, 31);
  // Get the last Monday of May by moving back to the nearest Monday
  Result := LastDayOfMonth - (DayOfTheWeek(LastDayOfMonth) - 1) mod 7;
end;

function NextFixedDate(const AMonth, ADay: Word; const AToday: TDate): TDate;
var
  TargetYear: Word;
begin
  TargetYear := YearOf(AToday);
  Result := EncodeDate(TargetYear, AMonth, ADay);
  if Result < AToday then
    Result := EncodeDate(TargetYear + 1, AMonth, ADay);
end;

procedure NextFixedDateRange(const AStartMonth, AStartDay, AEndMonth,
  AEndDay: Word; const AToday: TDate; out ADateFrom, ADateTo: TDate);
var
  TargetYear: Word;
begin
  TargetYear := YearOf(AToday);
  ADateFrom := EncodeDate(TargetYear, AStartMonth, AStartDay);
  ADateTo := EncodeDate(TargetYear, AEndMonth, AEndDay);
  if ADateTo < AToday then
  begin
    ADateFrom := EncodeDate(TargetYear + 1, AStartMonth, AStartDay);
    ADateTo := EncodeDate(TargetYear + 1, AEndMonth, AEndDay);
  end;
end;

function NextEasterDate(const AToday: TDate): TDate;
var
  TargetYear: Word;
begin
  TargetYear := YearOf(AToday);
  Result := CalculateEasterDate(TargetYear);
  if Result < AToday then
    Result := CalculateEasterDate(TargetYear + 1);
end;

function NextThanksgivingDate(const AToday: TDate): TDate;
var
  TargetYear: Word;
begin
  TargetYear := YearOf(AToday);
  Result := CalculateThanksgiving(TargetYear);
  if Result < AToday then
    Result := CalculateThanksgiving(TargetYear + 1);
end;

function NextMemorialDayDate(const AToday: TDate): TDate;
var
  TargetYear: Word;
begin
  TargetYear := YearOf(AToday);
  Result := CalculateMemorialDay(TargetYear);
  if Result < AToday then
    Result := CalculateMemorialDay(TargetYear + 1);
end;

function TryCalculateSeasonalGroupDates(const ASeasonalGroup: string;
  const AToday: TDate; out ADateFrom, ADateTo: TDate): Boolean;
begin
  Result := True;
  if SameText(ASeasonalGroup, 'Christmas') then
    NextFixedDateRange(12, 22, 12, 26, AToday, ADateFrom, ADateTo)
  else if SameText(ASeasonalGroup, 'Christmas Eve') then
  begin
    ADateFrom := NextFixedDate(12, 24, AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Easter') then
  begin
    ADateFrom := NextEasterDate(AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Epiphany') then
  begin
    ADateFrom := NextFixedDate(1, 6, AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Independence Day') then
  begin
    ADateFrom := NextFixedDate(7, 4, AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Memorial Day') then
  begin
    ADateFrom := NextMemorialDayDate(AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'New Year''s Day') then
  begin
    ADateFrom := NextFixedDate(1, 1, AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Nine Eleven') then
  begin
    ADateFrom := NextFixedDate(9, 11, AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Thanksgiving') then
  begin
    ADateFrom := NextThanksgivingDate(AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Valentine''s Day') then
  begin
    ADateFrom := NextFixedDate(2, 14, AToday);
    ADateTo := ADateFrom;
  end
  else if SameText(ASeasonalGroup, 'Veterans Day') then
  begin
    ADateFrom := NextFixedDate(11, 11, AToday);
    ADateTo := ADateFrom;
  end
  else
    Result := False;
end;
procedure TGroups.DBGrid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
begin
  Canvas.Fill.Kind := TBrushKind.Solid;
  if (TGridDrawState.Selected in State) or (TGridDrawState.RowSelected in State) then
  begin
    Canvas.Fill.Color := TAlphaColor($00FAE8D7);
  end
  else
  begin
    Canvas.Fill.Color := VCLColorToAlphaColor($F0FFFF);
  end;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
end;
procedure TGroups.btnCloseClick(Sender: TObject);
begin
  Close;
end;
procedure TGroups.FormCreate(Sender: TObject);
var
  stBGColor: TAlphaColor;
  stFontColor: TAlphaColor;
  I: Integer;
begin
  FGeneratedOriginalOnDestroy := Self.OnDestroy;
  Self.OnDestroy := GeneratedFormDestroyHandler;
  // Set form color using settings file values or default to beige/maroon
  var
    TempQuery: TFDQuery;
  begin
    // Create a temporary query to fetch colors
    ConfigurePortableSQLiteConnection(FDConnection1);
    FDConnection1.connected := True;
    TempQuery := TFDQuery.Create(nil);
    try
      TempQuery.Connection := FDConnection1;
      TempQuery.SQL.Text :=
        'SELECT form_bgcolor, form_fontcolor FROM pl_settings';
      TempQuery.Open;
      if not TempQuery.IsEmpty then
      begin
        // Check if either field is NULL
        if TempQuery.FieldByName('form_bgcolor').IsNull or
          TempQuery.FieldByName('form_fontcolor').IsNull then
        begin
          // Use defaults if NULL
          stBGColor := VCLColorToAlphaColor($8EBDDC);
          stFontColor := VCLColorToAlphaColor($000080);
        end
        else
        begin
          // Assign field values directly if not NULL
          stBGColor := VCLColorToAlphaColor(TempQuery.FieldByName('form_bgcolor').AsInteger);
          stFontColor := VCLColorToAlphaColor(TempQuery.FieldByName('form_fontcolor').AsInteger);
        end;
      end
      else
      begin
        // No records, use defaults
        stBGColor := VCLColorToAlphaColor($8EBDDC);
        stFontColor := VCLColorToAlphaColor($000080);
      end;
    finally
      TempQuery.Free; // Free the temporary query
    end;
    // Apply the retrieved or default color values
    // Form background
    Self.Fill.Kind := TBrushKind.Solid;
    Self.Fill.Color := stBGColor;
    ApplyContainerBackgroundColor(Self, stBGColor);
    // Form fonts for all labels
    for I := 0 to Self.ComponentCount - 1 do
      if Self.Components[I] is TLabel then
        TLabel(Self.Components[I]).TextSettings.FontColor := stFontColor;
    for I := 0 to Self.ComponentCount - 1 do
      if Self.Components[I] is TButton then
        ApplyTieredButtonStyle(TButton(Self.Components[I]), stBGColor, stFontColor)
      else if Self.Components[I] is TEdit then
        ApplyCardEditStyle(TStyledControl(Self.Components[I]), stBGColor, stFontColor);
  end;
  // Set form color using RGB
  // Self.Color := GeneratedRGB(220, 189, 142);
  // Call the resize method when the form is created
  ResizeFormForResolution(Self);
  // Load the table data
  FDTable1.Close;
  FDTable1.Open;
  FDQuery1.Close;
  FDQuery1.Open;
  // Generated FMX LiveBindings from original VCL data-aware controls
  if BindSourceDB_DataSource1 = nil then
  begin
    BindSourceDB_DataSource1 := TBindSourceDB.Create(Self);
    BindSourceDB_DataSource1.DataSource := DataSource1;
  end;
  if Assigned(DBNavigator1) then
    DBNavigator1.DataSource := BindSourceDB_DataSource1;
  if Assigned(DBGrid1) and not Assigned(DBGrid1.OnSelChanged) then
    DBGrid1.OnSelChanged := DBGrid1_GeneratedSelChanged;
  if Assigned(DBGrid1) and not Assigned(DBGrid1.OnCellClick) then
    DBGrid1.OnCellClick := DBGrid1_GeneratedCellClick;
  if Assigned(DBGrid1) then
  begin
    ApplyGridSelectionColor(DBGrid1, $FFD7E8FA);
    DBGrid1.Options := DBGrid1.Options - [TGridOption.Editing, TGridOption.CancelEditingByDefault];
  end;
  if Assigned(DBGrid1) and (DBGrid1.ColumnCount = 0) then
  begin
    DBGrid1.BeginUpdate;
    try
      with TStringColumn.Create(DBGrid1) do
      begin
        Parent := DBGrid1;
        Header := 'Group';
        Width := 155;
        ReadOnly := True;
      end;
      with TStringColumn.Create(DBGrid1) do
      begin
        Parent := DBGrid1;
        Header := 'Play Date From';
        Width := 115;
        ReadOnly := True;
      end;
      with TStringColumn.Create(DBGrid1) do
      begin
        Parent := DBGrid1;
        Header := 'Play Date To';
        Width := 115;
        ReadOnly := True;
      end;
      with TStringColumn.Create(DBGrid1) do
      begin
        Parent := DBGrid1;
        Header := 'Play Time';
        Width := 115;
        ReadOnly := True;
      end;
    finally
      DBGrid1.EndUpdate;
    end;
  end;
  if Assigned(DBGrid1) and not Assigned(DBGrid1.OnMouseWheel) then
    DBGrid1.OnMouseWheel := DBGrid1_GeneratedMouseWheel;
  if Assigned(DBNavigator1) then
  begin
    FOriginal_DBNavigator1_BeforeAction := DBNavigator1.BeforeAction;
    DBNavigator1.BeforeAction := DBNavigator1_GeneratedBeforeAction;
  end;
  if Assigned(DBGrid1) and (GridEditorPanel_DBGrid1 = nil) then
  begin
    GridEditorPanel_DBGrid1 := TPanel.Create(Self);
    GridEditorPanel_DBGrid1.Parent := Self;
    GridEditorPanel_DBGrid1.Visible := True;
    GridEditorPanel_DBGrid1.Position.Y := DBGrid1.Position.Y;
    if Round(Self.ClientWidth - (DBGrid1.Position.X + DBGrid1.Width)) >= 190 then
    begin
      GridEditorPanel_DBGrid1.Position.X := DBGrid1.Position.X + DBGrid1.Width + 12;
      GridEditorPanel_DBGrid1.Width := Self.ClientWidth - GridEditorPanel_DBGrid1.Position.X - 12;
      if GridEditorPanel_DBGrid1.Width < 180 then
        GridEditorPanel_DBGrid1.Width := 180;
      GridEditorPanel_DBGrid1.Height := 12 + (4 * 50);
    end
    else
    begin
      GridEditorPanel_DBGrid1.Position.X := DBGrid1.Position.X;
      GridEditorPanel_DBGrid1.Position.Y := DBGrid1.Position.Y + DBGrid1.Height + 8;
      GridEditorPanel_DBGrid1.Width := DBGrid1.Width;
      GridEditorPanel_DBGrid1.Height := 12 + ((((4 + 1) div 2)) * 50);
    end;
  end;
  if Lbl_DBGrid1_0 = nil then
  begin
    Lbl_DBGrid1_0 := TLabel.Create(Self);
    Lbl_DBGrid1_0.Parent := GridEditorPanel_DBGrid1;
    Lbl_DBGrid1_0.Text := 'Group';
    Lbl_DBGrid1_0.AutoSize := True;
  end;
  if Ed_DBGrid1_0 = nil then
  begin
    Ed_DBGrid1_0 := TEdit.Create(Self);
    Ed_DBGrid1_0.Parent := GridEditorPanel_DBGrid1;
  end;
  Ed_DBGrid1_0.OnChangeTracking := Ed_DBGrid1_0_GeneratedChangeTracking;
  Ed_DBGrid1_0.OnExit := Ed_DBGrid1_0_GeneratedExit;
  Ed_DBGrid1_0.OnKeyDown := Ed_DBGrid1_0_GeneratedKeyDown;
  if GridEditorPanel_DBGrid1.Position.X > DBGrid1.Position.X then
  begin
    Lbl_DBGrid1_0.Position.X := 8;
    Lbl_DBGrid1_0.Position.Y := 8 + (0 * 50);
    Ed_DBGrid1_0.Position.X := 8;
    Ed_DBGrid1_0.Position.Y := 24 + (0 * 50);
    Ed_DBGrid1_0.Width := GridEditorPanel_DBGrid1.Width - 16;
  end
  else
  begin
    Lbl_DBGrid1_0.Position.X := 8 + ((0 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Lbl_DBGrid1_0.Position.Y := 8 + ((0 div 2) * 50);
    Ed_DBGrid1_0.Position.X := 8 + ((0 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Ed_DBGrid1_0.Position.Y := 24 + ((0 div 2) * 50);
    Ed_DBGrid1_0.Width := ((GridEditorPanel_DBGrid1.Width - 24) / 2);
  end;
  if Lbl_DBGrid1_1 = nil then
  begin
    Lbl_DBGrid1_1 := TLabel.Create(Self);
    Lbl_DBGrid1_1.Parent := GridEditorPanel_DBGrid1;
    Lbl_DBGrid1_1.Text := 'Play Date From';
    Lbl_DBGrid1_1.AutoSize := True;
  end;
  if Ed_DBGrid1_1 = nil then
  begin
    Ed_DBGrid1_1 := TDateEdit.Create(Self);
    Ed_DBGrid1_1.Parent := GridEditorPanel_DBGrid1;
    Ed_DBGrid1_1.ShowCheckBox := False;
    Ed_DBGrid1_1.ShowClearButton := True;
    Ed_DBGrid1_1.Format := 'm/d/yyyy';
  end;
  Ed_DBGrid1_1.OnChange := Ed_DBGrid1_1_GeneratedChangeTracking;
  Ed_DBGrid1_1.OnExit := Ed_DBGrid1_1_GeneratedExit;
  Ed_DBGrid1_1.OnKeyDown := Ed_DBGrid1_1_GeneratedKeyDown;
  if GridEditorPanel_DBGrid1.Position.X > DBGrid1.Position.X then
  begin
    Lbl_DBGrid1_1.Position.X := 8;
    Lbl_DBGrid1_1.Position.Y := 8 + (1 * 50);
    Ed_DBGrid1_1.Position.X := 8;
    Ed_DBGrid1_1.Position.Y := 24 + (1 * 50);
    Ed_DBGrid1_1.Width := GridEditorPanel_DBGrid1.Width - 16;
  end
  else
  begin
    Lbl_DBGrid1_1.Position.X := 8 + ((1 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Lbl_DBGrid1_1.Position.Y := 8 + ((1 div 2) * 50);
    Ed_DBGrid1_1.Position.X := 8 + ((1 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Ed_DBGrid1_1.Position.Y := 24 + ((1 div 2) * 50);
    Ed_DBGrid1_1.Width := ((GridEditorPanel_DBGrid1.Width - 24) / 2);
  end;
  if Lbl_DBGrid1_2 = nil then
  begin
    Lbl_DBGrid1_2 := TLabel.Create(Self);
    Lbl_DBGrid1_2.Parent := GridEditorPanel_DBGrid1;
    Lbl_DBGrid1_2.Text := 'Play Date To';
    Lbl_DBGrid1_2.AutoSize := True;
  end;
  if Ed_DBGrid1_2 = nil then
  begin
    Ed_DBGrid1_2 := TDateEdit.Create(Self);
    Ed_DBGrid1_2.Parent := GridEditorPanel_DBGrid1;
    Ed_DBGrid1_2.ShowCheckBox := False;
    Ed_DBGrid1_2.ShowClearButton := True;
    Ed_DBGrid1_2.Format := 'm/d/yyyy';
  end;
  Ed_DBGrid1_2.OnChange := Ed_DBGrid1_2_GeneratedChangeTracking;
  Ed_DBGrid1_2.OnExit := Ed_DBGrid1_2_GeneratedExit;
  Ed_DBGrid1_2.OnKeyDown := Ed_DBGrid1_2_GeneratedKeyDown;
  if GridEditorPanel_DBGrid1.Position.X > DBGrid1.Position.X then
  begin
    Lbl_DBGrid1_2.Position.X := 8;
    Lbl_DBGrid1_2.Position.Y := 8 + (2 * 50);
    Ed_DBGrid1_2.Position.X := 8;
    Ed_DBGrid1_2.Position.Y := 24 + (2 * 50);
    Ed_DBGrid1_2.Width := GridEditorPanel_DBGrid1.Width - 16;
  end
  else
  begin
    Lbl_DBGrid1_2.Position.X := 8 + ((2 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Lbl_DBGrid1_2.Position.Y := 8 + ((2 div 2) * 50);
    Ed_DBGrid1_2.Position.X := 8 + ((2 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Ed_DBGrid1_2.Position.Y := 24 + ((2 div 2) * 50);
    Ed_DBGrid1_2.Width := ((GridEditorPanel_DBGrid1.Width - 24) / 2);
  end;
  if Lbl_DBGrid1_3 = nil then
  begin
    Lbl_DBGrid1_3 := TLabel.Create(Self);
    Lbl_DBGrid1_3.Parent := GridEditorPanel_DBGrid1;
    Lbl_DBGrid1_3.Text := 'Play Time';
    Lbl_DBGrid1_3.AutoSize := True;
  end;
  if Ed_DBGrid1_3 = nil then
  begin
    Ed_DBGrid1_3 := TTimeEdit.Create(Self);
    Ed_DBGrid1_3.Parent := GridEditorPanel_DBGrid1;
    Ed_DBGrid1_3.ShowCheckBox := False;
    Ed_DBGrid1_3.ShowClearButton := True;
    Ed_DBGrid1_3.Format := 'h:nn:ss AM/PM';
    Ed_DBGrid1_3.UseNowTime := False;
  end;
  Ed_DBGrid1_3.OnChange := Ed_DBGrid1_3_GeneratedChangeTracking;
  Ed_DBGrid1_3.OnExit := Ed_DBGrid1_3_GeneratedExit;
  Ed_DBGrid1_3.OnKeyDown := Ed_DBGrid1_3_GeneratedKeyDown;
  if GridEditorPanel_DBGrid1.Position.X > DBGrid1.Position.X then
  begin
    Lbl_DBGrid1_3.Position.X := 8;
    Lbl_DBGrid1_3.Position.Y := 8 + (3 * 50);
    Ed_DBGrid1_3.Position.X := 8;
    Ed_DBGrid1_3.Position.Y := 24 + (3 * 50);
    Ed_DBGrid1_3.Width := GridEditorPanel_DBGrid1.Width - 16;
  end
  else
  begin
    Lbl_DBGrid1_3.Position.X := 8 + ((3 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Lbl_DBGrid1_3.Position.Y := 8 + ((3 div 2) * 50);
    Ed_DBGrid1_3.Position.X := 8 + ((3 mod 2) * ((GridEditorPanel_DBGrid1.Width - 24) / 2));
    Ed_DBGrid1_3.Position.Y := 24 + ((3 div 2) * 50);
    Ed_DBGrid1_3.Width := ((GridEditorPanel_DBGrid1.Width - 24) / 2);
  end;
  ApplyTieredButtonStyle(btnClose, stBGColor, stFontColor);
  ApplyTieredButtonStyle(btnRecalculateDates, stBGColor, stFontColor);
  ApplyCardEditStyle(Ed_DBGrid1_0, stBGColor, stFontColor);
  ApplyCardEditStyle(Ed_DBGrid1_1, stBGColor, stFontColor);
  ApplyCardEditStyle(Ed_DBGrid1_2, stBGColor, stFontColor);
  ApplyCardEditStyle(Ed_DBGrid1_3, stBGColor, stFontColor);
  DBGrid1_RefreshSelectorGrid;
  DBGrid1_SyncGeneratedEditors;
  if Assigned(DataSource1) and not Assigned(DataSource1.OnDataChange) then
    DataSource1.OnDataChange := DataSource1_GeneratedDataChange;
  ApplyCurrentCarillonThemeToForm(Self);
end;
procedure TGroups.FormShow(Sender: TObject);
begin
  ApplyCurrentCarillonThemeToForm(Self);
end;
procedure TGroups.btnRecalculateDatesClick(Sender: TObject);
var
  PlayDateFrom, PlayDateTo: TDate;
  SeasonalGroup: string;
  TodayDate: TDate;
begin
  TodayDate := Date;

  // Ensure FDTable1 is active and positioned at first record
  if not FDTable1.Active then
  begin
    try
      FDTable1.Open;
    except
      on E: Exception do
      begin
        ShowMessage('Could not open seasonal groups table: ' + E.Message);
        Exit;
      end;
    end;
  end;
  FDTable1.First;

  while not FDTable1.Eof do
  begin
    SeasonalGroup := FDTable1.FieldByName('SEASONALGROUP').AsString;

    if TryCalculateSeasonalGroupDates(SeasonalGroup, TodayDate,
      PlayDateFrom, PlayDateTo) then
    begin
      FDTable1.Edit;
      FDTable1.FieldByName('PLAY_DATE_FROM').AsDateTime := PlayDateFrom;
      FDTable1.FieldByName('PLAY_DATE_TO').AsDateTime := PlayDateTo;
      FDTable1.Post;
    end;

    FDTable1.Next;
  end;

  // Refresh FDTable1 so it reflects all committed changes
  FDTable1.Refresh;

  // Refresh FDQuery1 (the grid's data source) and update the display
  FDQuery1.Close;
  FDQuery1.Open;

  // Refresh the grid and sync the side-panel editors
  DBGrid1_RefreshSelectorGrid;
  DBGrid1_SyncGeneratedEditors;
end;

procedure TGroups.ResizeFormForResolution(AForm: TForm);
var
  ScreenWidth, ScreenHeight: Integer;
begin
  // Get the current screen resolution
  ScreenWidth := Round(Screen.WorkAreaWidth);
  ScreenHeight := Round(Screen.WorkAreaHeight);
  // Optionally, center the form on the screen
  AForm.Left := Round((ScreenWidth - AForm.Width) / 2);
  AForm.Top := Round((ScreenHeight - AForm.Height) / 2);
end;
procedure TGroups.Timer1Timer(Sender: TObject);
var
  CurrentTime: TTime;
  CurrentDate: TDate;
begin
  if FGeneratedShuttingDown then
    Exit;
  CurrentTime := Time;
  CurrentDate := Date;
  if (FormatDateTime('mm/dd', CurrentDate) = '01/03') and
     (FormatDateTime('hh:nn', CurrentTime) >= '00:02') and
     (FLastAutoRecalcYear <> YearOf(CurrentDate)) then
  begin
    FLastAutoRecalcYear := YearOf(CurrentDate);
    btnRecalculateDatesClick(Self);
  end;
end;

procedure TGroups.DBNavigator1_GeneratedBeforeAction(Sender: TObject; Button: TBindNavigateBtn);
begin
  case Button of
    nbPost:
      DBGrid1_CommitGeneratedEditors;
    nbCancel:
    begin
      if Assigned(FDQuery1) and FDQuery1.Active and (FDQuery1.State in dsEditModes) then
        FDQuery1.Cancel;
      DBGrid1_SyncGeneratedEditors;
      Abort;
    end;
  end;
  if Assigned(FOriginal_DBNavigator1_BeforeAction) then
    FOriginal_DBNavigator1_BeforeAction(Sender, Button);
end;
procedure TGroups.DBGrid1_GeneratedSelChanged(Sender: TObject);
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if Assigned(DBGrid1) and Assigned(FDQuery1) and FDQuery1.Active and
     (not FDQuery1.IsEmpty) and (DBGrid1.Selected >= 0) then
  begin
    Inc(FUpdatingSelection_DBGrid1);
    try
      if FDQuery1.RecNo <> DBGrid1.Selected + 1 then
        FDQuery1.RecNo := DBGrid1.Selected + 1;
    finally
      Dec(FUpdatingSelection_DBGrid1);
    end;
    DBGrid1_SyncGeneratedEditors;
  end;
end;

procedure TGroups.DBGrid1_CommitGeneratedEditors;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  if Assigned(Ed_DBGrid1_0) then
    Ed_DBGrid1_0_GeneratedExit(Ed_DBGrid1_0);
  if Assigned(Ed_DBGrid1_1) then
    Ed_DBGrid1_1_GeneratedExit(Ed_DBGrid1_1);
  if Assigned(Ed_DBGrid1_2) then
    Ed_DBGrid1_2_GeneratedExit(Ed_DBGrid1_2);
  if Assigned(Ed_DBGrid1_3) then
    Ed_DBGrid1_3_GeneratedExit(Ed_DBGrid1_3);
end;

function TGroups.DBGrid1_TryParseGeneratedDate(const AInput: string;
  out AValue: TDateTime): Boolean;
var
  LText: string;
  FS: TFormatSettings;
  Parts: TArray<string>;
  A: Integer;
  B: Integer;
  C: Integer;
  Y: Word;
  M: Word;
  D: Word;
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
    Y := A;
    M := B;
    D := C;
  end
  else
  begin
    Y := C;
    if Y < 100 then
      if Y < 50 then
        Inc(Y, 2000)
      else
        Inc(Y, 1900);
    if A > 12 then
    begin
      D := A;
      M := B;
    end
    else if B > 12 then
    begin
      M := A;
      D := B;
    end
    else
    begin
      M := A;
      D := B;
    end;
  end;
  try
    AValue := EncodeDate(Y, M, D);
    Result := True;
  except
    Result := False;
  end;
end;

function TGroups.DBGrid1_TryParseGeneratedTime(const AInput: string;
  out AValue: TDateTime): Boolean;
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
  Parts := LText.Split([':']);
  if (Length(Parts) < 1) or (Length(Parts) > 3) then
    Exit(False);
  if not TryStrToInt(Trim(Parts[0]), Hours) then
    Exit(False);
  if (Length(Parts) >= 2) and not TryStrToInt(Trim(Parts[1]), Minutes) then
    Exit(False);
  if (Length(Parts) = 3) and not TryStrToInt(Trim(Parts[2]), Seconds) then
    Exit(False);
  if Suffix = 'PM' then
  begin
    if Hours < 12 then
      Inc(Hours, 12);
  end
  else if Suffix = 'AM' then
  begin
    if Hours = 12 then
      Hours := 0;
  end;
  try
    AValue := EncodeTime(Hours, Minutes, Seconds, 0);
    Result := True;
  except
    Result := False;
  end;
end;

function TGroups.DBGrid1_AssignGeneratedFieldValue(AField: TField;
  const AInput: string; out ANormalized: string; out AError: string): Boolean;
var
  DateValue: TDateTime;
  TimeValue: TDateTime;
begin
  Result := False;
  ANormalized := AInput;
  AError := '';
  if AField = nil then
    Exit(True);

  if Trim(AInput) = '' then
  begin
    AField.Clear;
    ANormalized := '';
    Exit(True);
  end;

  if SameText(AField.FieldName, 'PLAY_DATE_FROM') or
     SameText(AField.FieldName, 'PLAY_DATE_TO') then
  begin
    if not DBGrid1_TryParseGeneratedDate(AInput, DateValue) then
    begin
      AError := AField.DisplayName + ' must be a valid date.';
      Exit;
    end;
    AField.AsDateTime := DateValue;
    ANormalized := FormatDateTime('m/d/yyyy', DateValue);
    Exit(True);
  end;

  if SameText(AField.FieldName, 'PLAY_TIME') then
  begin
    if not DBGrid1_TryParseGeneratedTime(AInput, TimeValue) then
    begin
      AError := AField.DisplayName + ' must be a valid time.';
      Exit;
    end;
    AField.AsDateTime := TimeValue;
    ANormalized := FormatDateTime('h:nn:ss AM/PM', TimeValue);
    Exit(True);
  end;

  AField.AsString := AInput;
  ANormalized := AField.DisplayText;
  Result := True;
end;
procedure TGroups.DBGrid1_GeneratedCellClick(const Column: TColumn; const Row: Integer);
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if Assigned(DBGrid1) and Assigned(FDQuery1) and FDQuery1.Active and (not FDQuery1.IsEmpty) and
     (Row >= 0) and (Row < DBGrid1.RowCount) then
  begin
    Inc(FUpdatingSelection_DBGrid1);
    try
      DBGrid1.Selected := Row;
      if FDQuery1.RecNo <> Row + 1 then
        FDQuery1.RecNo := Row + 1;
    finally
      Dec(FUpdatingSelection_DBGrid1);
    end;
    DBGrid1_SyncGeneratedEditors;
  end;
end;
procedure TGroups.DBGrid1_RefreshSelectorGrid;
var
  LBookmark: TBookmark;
  LRow: Integer;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(DBGrid1) or (DBGrid1.ColumnCount = 0) then
    Exit;
  Inc(FUpdatingSelection_DBGrid1);
  try
    DBGrid1.BeginUpdate;
    try
      if Assigned(FDQuery1) and FDQuery1.Active and
         (not FDQuery1.IsEmpty) then
      begin
        LBookmark := nil;
        FDQuery1.DisableControls;
        try
          LBookmark := FDQuery1.GetBookmark;
          DBGrid1.RowCount := 0;
          FDQuery1.First;
          LRow := 0;
          while not FDQuery1.Eof do
          begin
            if DBGrid1.RowCount <= LRow then
              DBGrid1.RowCount := LRow + 1;
            if FDQuery1.FindField('SEASONALGROUP') <> nil then
              DBGrid1.Cells[0, LRow] := FDQuery1.FieldByName('SEASONALGROUP').DisplayText
            else
              DBGrid1.Cells[0, LRow] := '';
            if FDQuery1.FindField('PLAY_DATE_FROM') <> nil then
              DBGrid1.Cells[1, LRow] := FDQuery1.FieldByName('PLAY_DATE_FROM').DisplayText
            else
              DBGrid1.Cells[1, LRow] := '';
            if FDQuery1.FindField('PLAY_DATE_TO') <> nil then
              DBGrid1.Cells[2, LRow] := FDQuery1.FieldByName('PLAY_DATE_TO').DisplayText
            else
              DBGrid1.Cells[2, LRow] := '';
            if FDQuery1.FindField('PLAY_TIME') <> nil then
              DBGrid1.Cells[3, LRow] := FDQuery1.FieldByName('PLAY_TIME').DisplayText
            else
              DBGrid1.Cells[3, LRow] := '';
            Inc(LRow);
            FDQuery1.Next;
          end;
          if (LBookmark <> nil) and FDQuery1.BookmarkValid(LBookmark) then
            FDQuery1.GotoBookmark(LBookmark);
        finally
          if LBookmark <> nil then
            FDQuery1.FreeBookmark(LBookmark);
          FDQuery1.EnableControls;
        end;
        if FDQuery1.RecNo > 0 then
          DBGrid1.Selected := FDQuery1.RecNo - 1
        else
          DBGrid1.Selected := 0;
      end
      else
        DBGrid1.RowCount := 0;
    finally
      DBGrid1.EndUpdate;
    end;
  finally
    Dec(FUpdatingSelection_DBGrid1);
  end;
end;
procedure TGroups.DBGrid1_GeneratedMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  if Assigned(FDQuery1) and FDQuery1.Active and (not FDQuery1.IsEmpty) then
  begin
    if WheelDelta > 0 then
    begin
      if not FDQuery1.BOF then
        FDQuery1.Prior;
    end
    else if WheelDelta < 0 then
    begin
      if not FDQuery1.EOF then
        FDQuery1.Next;
      if FDQuery1.EOF and (not FDQuery1.IsEmpty) then
        FDQuery1.Last;
    end;
    Handled := True;
  end;
end;
procedure TGroups.Ed_DBGrid1_0_GeneratedChangeTracking(Sender: TObject);
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
end;
procedure TGroups.Ed_DBGrid1_0_GeneratedExit(Sender: TObject);
var
  LField: TField;
  LValue: string;
  LNormalized: string;
  LError: string;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  LField := FDQuery1.FindField('SEASONALGROUP');
  if LField = nil then
    Exit;
  LValue := Trim(Ed_DBGrid1_0.Text);
  if LField.DisplayText = LValue then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
  if not DBGrid1_AssignGeneratedFieldValue(LField, LValue, LNormalized, LError) then
  begin
    Inc(FUpdatingSelection_DBGrid1);
    try
      if LError <> '' then
        ShowMessage(LError);
      Ed_DBGrid1_0.Text := LField.DisplayText;
    finally
      Dec(FUpdatingSelection_DBGrid1);
    end;
    Exit;
  end;
  Ed_DBGrid1_0.Text := LNormalized;
end;
procedure TGroups.Ed_DBGrid1_0_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Ed_DBGrid1_0_GeneratedExit(Sender);
    Key := 0;
    KeyChar := #0;
  end;
end;
procedure TGroups.Ed_DBGrid1_1_GeneratedChangeTracking(Sender: TObject);
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
end;
procedure TGroups.Ed_DBGrid1_1_GeneratedExit(Sender: TObject);
var
  LField: TField;
  LValue: string;
  LNormalized: string;
  LError: string;
  LDate: TDateTime;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  LField := FDQuery1.FindField('PLAY_DATE_FROM');
  if LField = nil then
    Exit;
  if Ed_DBGrid1_1.IsEmpty then
    LValue := ''
  else
    LValue := FormatDateTime('m/d/yyyy', Ed_DBGrid1_1.Date);
  if (Trim(LValue) = '') and LField.IsNull then
    Exit;
  if SameText(LField.DisplayText, LValue) then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
  if not DBGrid1_AssignGeneratedFieldValue(LField, LValue, LNormalized, LError) then
  begin
    Inc(FUpdatingSelection_DBGrid1);
    try
      if LError <> '' then
        ShowMessage(LError);
      if LField.IsNull then
        Ed_DBGrid1_1.IsEmpty := True
      else
      begin
        Ed_DBGrid1_1.Date := LField.AsDateTime;
        Ed_DBGrid1_1.IsEmpty := False;
      end;
    finally
      Dec(FUpdatingSelection_DBGrid1);
    end;
    Exit;
  end;
  Inc(FUpdatingSelection_DBGrid1);
  try
    if LNormalized = '' then
      Ed_DBGrid1_1.IsEmpty := True
    else if DBGrid1_TryParseGeneratedDate(LNormalized, LDate) then
    begin
      Ed_DBGrid1_1.Date := LDate;
      Ed_DBGrid1_1.IsEmpty := False;
    end;
  finally
    Dec(FUpdatingSelection_DBGrid1);
  end;
end;
procedure TGroups.Ed_DBGrid1_1_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Ed_DBGrid1_1_GeneratedExit(Sender);
    Key := 0;
    KeyChar := #0;
  end;
end;
procedure TGroups.Ed_DBGrid1_2_GeneratedChangeTracking(Sender: TObject);
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
end;
procedure TGroups.Ed_DBGrid1_2_GeneratedExit(Sender: TObject);
var
  LField: TField;
  LValue: string;
  LNormalized: string;
  LError: string;
  LDate: TDateTime;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  LField := FDQuery1.FindField('PLAY_DATE_TO');
  if LField = nil then
    Exit;
  if Ed_DBGrid1_2.IsEmpty then
    LValue := ''
  else
    LValue := FormatDateTime('m/d/yyyy', Ed_DBGrid1_2.Date);
  if (Trim(LValue) = '') and LField.IsNull then
    Exit;
  if SameText(LField.DisplayText, LValue) then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
  if not DBGrid1_AssignGeneratedFieldValue(LField, LValue, LNormalized, LError) then
  begin
    Inc(FUpdatingSelection_DBGrid1);
    try
      if LError <> '' then
        ShowMessage(LError);
      if LField.IsNull then
        Ed_DBGrid1_2.IsEmpty := True
      else
      begin
        Ed_DBGrid1_2.Date := LField.AsDateTime;
        Ed_DBGrid1_2.IsEmpty := False;
      end;
    finally
      Dec(FUpdatingSelection_DBGrid1);
    end;
    Exit;
  end;
  Inc(FUpdatingSelection_DBGrid1);
  try
    if LNormalized = '' then
      Ed_DBGrid1_2.IsEmpty := True
    else if DBGrid1_TryParseGeneratedDate(LNormalized, LDate) then
    begin
      Ed_DBGrid1_2.Date := LDate;
      Ed_DBGrid1_2.IsEmpty := False;
    end;
  finally
    Dec(FUpdatingSelection_DBGrid1);
  end;
end;
procedure TGroups.Ed_DBGrid1_2_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Ed_DBGrid1_2_GeneratedExit(Sender);
    Key := 0;
    KeyChar := #0;
  end;
end;
procedure TGroups.Ed_DBGrid1_3_GeneratedChangeTracking(Sender: TObject);
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
end;
procedure TGroups.Ed_DBGrid1_3_GeneratedExit(Sender: TObject);
var
  LField: TField;
  LValue: string;
  LNormalized: string;
  LError: string;
  LTime: TDateTime;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  if not Assigned(FDQuery1) or not FDQuery1.Active or FDQuery1.IsEmpty then
    Exit;
  LField := FDQuery1.FindField('PLAY_TIME');
  if LField = nil then
    Exit;
  if Ed_DBGrid1_3.IsEmpty then
    LValue := ''
  else
    LValue := FormatDateTime('h:nn:ss AM/PM', Ed_DBGrid1_3.Time);
  if (Trim(LValue) = '') and LField.IsNull then
    Exit;
  if SameText(LField.DisplayText, LValue) then
    Exit;
  if not (FDQuery1.State in dsEditModes) then
    FDQuery1.Edit;
  if not DBGrid1_AssignGeneratedFieldValue(LField, LValue, LNormalized, LError) then
  begin
    Inc(FUpdatingSelection_DBGrid1);
    try
      if LError <> '' then
        ShowMessage(LError);
      if LField.IsNull then
        Ed_DBGrid1_3.IsEmpty := True
      else
      begin
        Ed_DBGrid1_3.Time := Frac(LField.AsDateTime);
        Ed_DBGrid1_3.IsEmpty := False;
      end;
    finally
      Dec(FUpdatingSelection_DBGrid1);
    end;
    Exit;
  end;
  Inc(FUpdatingSelection_DBGrid1);
  try
    if LNormalized = '' then
      Ed_DBGrid1_3.IsEmpty := True
    else if DBGrid1_TryParseGeneratedTime(LNormalized, LTime) then
    begin
      Ed_DBGrid1_3.Time := Frac(LTime);
      Ed_DBGrid1_3.IsEmpty := False;
    end;
  finally
    Dec(FUpdatingSelection_DBGrid1);
  end;
end;
procedure TGroups.Ed_DBGrid1_3_GeneratedKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Ed_DBGrid1_3_GeneratedExit(Sender);
    Key := 0;
    KeyChar := #0;
  end;
end;
procedure TGroups.DBGrid1_SyncGeneratedEditors;
begin
  if FUpdatingSelection_DBGrid1 > 0 then
    Exit;
  Inc(FUpdatingSelection_DBGrid1);
  try
    if Assigned(FDQuery1) and FDQuery1.Active and
       (not FDQuery1.IsEmpty) then
    begin
      if Assigned(Ed_DBGrid1_0) then
      begin
        if FDQuery1.FindField('SEASONALGROUP') <> nil then
          Ed_DBGrid1_0.Text := FDQuery1.FieldByName('SEASONALGROUP').DisplayText
        else
          Ed_DBGrid1_0.Text := '';
      end;
      if Assigned(Ed_DBGrid1_1) then
      begin
        if (FDQuery1.FindField('PLAY_DATE_FROM') <> nil) and
           (not FDQuery1.FieldByName('PLAY_DATE_FROM').IsNull) then
        begin
          Ed_DBGrid1_1.Date := FDQuery1.FieldByName('PLAY_DATE_FROM').AsDateTime;
          Ed_DBGrid1_1.IsEmpty := False;
        end
        else
          Ed_DBGrid1_1.IsEmpty := True;
      end;
      if Assigned(Ed_DBGrid1_2) then
      begin
        if (FDQuery1.FindField('PLAY_DATE_TO') <> nil) and
           (not FDQuery1.FieldByName('PLAY_DATE_TO').IsNull) then
        begin
          Ed_DBGrid1_2.Date := FDQuery1.FieldByName('PLAY_DATE_TO').AsDateTime;
          Ed_DBGrid1_2.IsEmpty := False;
        end
        else
          Ed_DBGrid1_2.IsEmpty := True;
      end;
      if Assigned(Ed_DBGrid1_3) then
      begin
        if (FDQuery1.FindField('PLAY_TIME') <> nil) and
           (not FDQuery1.FieldByName('PLAY_TIME').IsNull) then
        begin
          Ed_DBGrid1_3.Time := Frac(FDQuery1.FieldByName('PLAY_TIME').AsDateTime);
          Ed_DBGrid1_3.IsEmpty := False;
        end
        else
          Ed_DBGrid1_3.IsEmpty := True;
      end;
      if Assigned(DBGrid1) and (FDQuery1.RecNo > 0) then
        DBGrid1.Selected := FDQuery1.RecNo - 1;
    end
    else
    begin
      if Assigned(Ed_DBGrid1_0) then
        Ed_DBGrid1_0.Text := '';
      if Assigned(Ed_DBGrid1_1) then
        Ed_DBGrid1_1.IsEmpty := True;
      if Assigned(Ed_DBGrid1_2) then
        Ed_DBGrid1_2.IsEmpty := True;
      if Assigned(Ed_DBGrid1_3) then
        Ed_DBGrid1_3.IsEmpty := True;
    end;
  finally
    Dec(FUpdatingSelection_DBGrid1);
  end;
end;
procedure TGroups.GeneratedFormDestroyHandler(Sender: TObject);
begin
  // Generated FMX cleanup for bindings, timers, and media
  FGeneratedShuttingDown := True;
  if Assigned(DBNavigator1) and (DBNavigator1.Owner <> Self) then
    DBNavigator1.BeforeAction := FOriginal_DBNavigator1_BeforeAction;
  if Assigned(DataSource1) and (DataSource1.Owner <> Self) then
    DataSource1.OnDataChange := nil;
  if Assigned(FGeneratedOriginalOnDestroy) then
    FGeneratedOriginalOnDestroy(Sender);
  if Groups = Self then
    Groups := nil;
end;
procedure TGroups.DataSource1_GeneratedDataChange(Sender: TObject; Field: TField);
begin
  if (Sender is TDataSource) and Assigned(TDataSource(Sender).DataSet) and
     (TDataSource(Sender).DataSet.State in dsEditModes) then
    Exit;
  DBGrid1_RefreshSelectorGrid;
  DBGrid1_SyncGeneratedEditors;
end;
end.
