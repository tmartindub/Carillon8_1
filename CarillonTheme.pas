unit CarillonTheme;

// Version: 8.1
interface

uses
  FireDAC.Comp.Client, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Types,
  System.UITypes;

type
  TCarillonThemeButtonTier = (ctbtPrimary, ctbtSecondary, ctbtDanger);

  TCarillonColorTheme = record
    MenuItemName: string;
    ThemeName: string;
    AccentVclColor: Integer;
    BackgroundVclColor: Integer;
    FontVclColor: Integer;
    SurfaceVclColor: Integer;
  end;

  TCarillonThemePalette = record
    AccentColor: TAlphaColor;
    BackgroundColor: TAlphaColor;
    ButtonColor: TAlphaColor;
    ButtonDangerColor: TAlphaColor;
    ButtonDangerTextColor: TAlphaColor;
    ButtonSecondaryColor: TAlphaColor;
    ButtonSecondaryTextColor: TAlphaColor;
    ButtonTextColor: TAlphaColor;
    CardTextColor: TAlphaColor;
    FontColor: TAlphaColor;
    GridEvenColor: TAlphaColor;
    GridGroupColor: TAlphaColor;
    GridGroupSelectedColor: TAlphaColor;
    GridHeaderColor: TAlphaColor;
    GridHeaderTextColor: TAlphaColor;
    GridOddColor: TAlphaColor;
    GridSelectedColor: TAlphaColor;
    GridSelectedTextColor: TAlphaColor;
    GroupBoxFrameColor: TAlphaColor;
    InputColor: TAlphaColor;
    InputStrokeColor: TAlphaColor;
    LabelAccentColor: TAlphaColor;
    PanelStrokeColor: TAlphaColor;
    RaisedSurfaceColor: TAlphaColor;
    SurfaceColor: TAlphaColor;
  end;

const
  CarillonColorThemes: array[0..10] of TCarillonColorTheme = (
    (MenuItemName: 'miThemeCobaltHarbor'; ThemeName: 'Cobalt Harbor'; AccentVclColor: $00D46D2E; BackgroundVclColor: $00F3D1BB; FontVclColor: $00603518; SurfaceVclColor: $00FFFFFF),
    (MenuItemName: 'miThemeRoyalCurrent'; ThemeName: 'Royal Current'; AccentVclColor: $00F4A43F; BackgroundVclColor: $00633A22; FontVclColor: $00F7F5EE; SurfaceVclColor: $008A5B3A),
    (MenuItemName: 'miThemeEmeraldGlass'; ThemeName: 'Emerald Glass'; AccentVclColor: $006E9113; BackgroundVclColor: $00D3E0B6; FontVclColor: $00394611; SurfaceVclColor: $00FDFFFA),
    (MenuItemName: 'miThemeCopperDawn'; ThemeName: 'Copper Dawn'; AccentVclColor: $002E58B8; BackgroundVclColor: $00B8CBEB; FontVclColor: $001C3060; SurfaceVclColor: $00F4F8FF),
    (MenuItemName: 'miThemeIndigoVelvet'; ThemeName: 'Indigo Velvet'; AccentVclColor: $00C94E60; BackgroundVclColor: $00F0C6CD; FontVclColor: $0063242D; SurfaceVclColor: $00FFFCFF),
    (MenuItemName: 'miThemeCranberrySilk'; ThemeName: 'Cranberry Silk'; AccentVclColor: $006636B5; BackgroundVclColor: $00D0BFEB; FontVclColor: $003A1F60; SurfaceVclColor: $00FCFAFF),
    (MenuItemName: 'miThemeAtlanticTeal'; ThemeName: 'Atlantic Teal'; AccentVclColor: $00967618; BackgroundVclColor: $00E2D7B4; FontVclColor: $004E3F14; SurfaceVclColor: $00FFFEFA),
    (MenuItemName: 'miThemeMidnightCopper'; ThemeName: 'Midnight Copper'; AccentVclColor: $00479AE5; BackgroundVclColor: $00362D2C; FontVclColor: $00EAF0F5; SurfaceVclColor: $00594033),
    (MenuItemName: 'miThemePineGold'; ThemeName: 'Pine Gold'; AccentVclColor: $003592BC; BackgroundVclColor: $00BFDBDE; FontVclColor: $002C482D; SurfaceVclColor: $00F8FDFA),
    (MenuItemName: 'miThemeGraphiteIce'; ThemeName: 'Graphite Ice'; AccentVclColor: $00E28E5C; BackgroundVclColor: $004D3729; FontVclColor: $00FAF6F1; SurfaceVclColor: $00634A3B),
    (MenuItemName: 'miThemeVerdantSlate'; ThemeName: 'Verdant Slate'; AccentVclColor: $00547826; BackgroundVclColor: $00C7D5B8; FontVclColor: $002F3D1D; SurfaceVclColor: $00FAFDF9)
  );

function AlphaColorToVCLColor(Color: TAlphaColor): Integer;
function BlendVclColors(const ABaseColor, ABlendColor: Integer;
  const ABlendAmount: Single): Integer;
procedure BuildCarillonThemePalette(const AThemeIndex: Integer;
  const ABackgroundColor, AFontColor: TAlphaColor;
  out APalette: TCarillonThemePalette);
function CarillonDatabasePath: string;
procedure ConfigurePortableSQLiteConnection(const AConnection: TFDConnection);
function FindCarillonThemeIndex(const ABackgroundColor,
  AFontColor: TAlphaColor): Integer;
function FindCarillonThemeIndexByMenuName(const AMenuItemName: string): Integer;
function GetVclColorLuminance(const AColor: Integer): Double;
function LoadCurrentThemeColors(out ABackgroundColor,
  AFontColor: TAlphaColor): Boolean;
function LoadCurrentThemeIndex(out AThemeIndex: Integer;
  out ABackgroundColor, AFontColor: TAlphaColor): Boolean;
procedure SaveCurrentThemeColors(const ABackgroundColor, AFontColor: TAlphaColor);
function ShiftVclColor(const AColor: Integer; const AAmount: Single): Integer;
function ThemeUsesWhiteAccentLabels(const AThemeIndex: Integer): Boolean;
function VCLColorToAlphaColor(Color: Cardinal): TAlphaColor;

procedure ApplyCarillonThemeToForm(const AForm: TForm;
  const AThemeIndex: Integer; const AIncludeInteractiveText: Boolean = True);
procedure ApplyCardEditStyle(const AControl: TStyledControl;
  const ABackgroundColor, AFontColor: TAlphaColor);
procedure ApplyContainerBackgroundColor(const Root: TFmxObject;
  const Color: TAlphaColor);
procedure ApplyCurrentCarillonThemeToForm(const AForm: TForm;
  const AIncludeInteractiveText: Boolean = True);
procedure ApplyTieredButtonStyle(const AButton: TButton;
  const ABackgroundColor, AFontColor: TAlphaColor);

implementation

uses
  Data.DB, FireDAC.Stan.Param, FMX.ComboEdit, FMX.Edit,
  FMX.Graphics, FMX.Memo, FMX.Objects, Math, System.Classes,
  System.IOUtils, System.Rtti, System.SysUtils, Winapi.Windows;

function VCLColorToAlphaColor(Color: Cardinal): TAlphaColor;
begin
  Result := TAlphaColor($FF000000 or ((Color and $000000FF) shl 16) or
    (Color and $0000FF00) or ((Color and $00FF0000) shr 16));
end;

function AlphaColorToVCLColor(Color: TAlphaColor): Integer;
begin
  Result := Integer(((Color and $00FF0000) shr 16) or
    (Color and $0000FF00) or ((Color and $000000FF) shl 16));
end;

function BlendVclColors(const ABaseColor, ABlendColor: Integer;
  const ABlendAmount: Single): Integer;
var
  BlendAmount: Single;
  BlueValue: Integer;
  GreenValue: Integer;
  RedValue: Integer;
begin
  BlendAmount := EnsureRange(ABlendAmount, 0.0, 1.0);
  RedValue := Round((ABaseColor and $FF) * (1.0 - BlendAmount) +
    (ABlendColor and $FF) * BlendAmount);
  GreenValue := Round(((ABaseColor shr 8) and $FF) * (1.0 - BlendAmount) +
    ((ABlendColor shr 8) and $FF) * BlendAmount);
  BlueValue := Round(((ABaseColor shr 16) and $FF) * (1.0 - BlendAmount) +
    ((ABlendColor shr 16) and $FF) * BlendAmount);
  Result := RGB(RedValue, GreenValue, BlueValue);
end;

function ShiftVclColor(const AColor: Integer; const AAmount: Single): Integer;
begin
  if AAmount >= 0 then
    Result := BlendVclColors(AColor, RGB(255, 255, 255), AAmount)
  else
    Result := BlendVclColors(AColor, RGB(0, 0, 0), -AAmount);
end;

function GetVclColorLuminance(const AColor: Integer): Double;
var
  BlueValue: Integer;
  GreenValue: Integer;
  RedValue: Integer;
begin
  RedValue := AColor and $FF;
  GreenValue := (AColor shr 8) and $FF;
  BlueValue := (AColor shr 16) and $FF;
  Result := ((0.299 * RedValue) + (0.587 * GreenValue) +
    (0.114 * BlueValue)) / 255.0;
end;

function GetReadableVclTextColor(const ABackgroundColor: Integer): Integer;
begin
  if GetVclColorLuminance(ABackgroundColor) >= 0.58 then
    Result := RGB(34, 38, 45)
  else
    Result := RGB(245, 244, 240);
end;

function GetReadableVclButtonTextColor(const ABackgroundColor: Integer): Integer;
begin
  Result := RGB(34, 38, 45);
end;

function GetReadableAccentLabelVclColor(const AAccentColor,
  ABackgroundColor: Integer): Integer;
var
  BackgroundLuminance: Double;
begin
  BackgroundLuminance := GetVclColorLuminance(ABackgroundColor);
  if BackgroundLuminance < 0.40 then
    Result := BlendVclColors(AAccentColor, RGB(255, 255, 255), 0.24)
  else if BackgroundLuminance < 0.56 then
    Result := BlendVclColors(AAccentColor, RGB(255, 255, 255), 0.18)
  else
    Result := ShiftVclColor(AAccentColor, -0.36);
end;

function ThemeUsesWhiteAccentLabels(const AThemeIndex: Integer): Boolean;
begin
  Result := (AThemeIndex = 1) or // Royal Current
    (AThemeIndex = 7) or // Midnight Copper
    (AThemeIndex = 9); // Graphite Ice
end;

procedure BuildCarillonThemePalette(const AThemeIndex: Integer;
  const ABackgroundColor, AFontColor: TAlphaColor;
  out APalette: TCarillonThemePalette);
var
  AccentVclColor: Integer;
  BackgroundVclColor: Integer;
  ButtonDangerVclColor: Integer;
  ButtonSecondaryVclColor: Integer;
  ButtonVclColor: Integer;
  CardTextVclColor: Integer;
  FontVclColor: Integer;
  GridEvenVclColor: Integer;
  GridGroupSelectedVclColor: Integer;
  GridGroupVclColor: Integer;
  GridHeaderVclColor: Integer;
  GridOddVclColor: Integer;
  GridSelectedVclColor: Integer;
  GroupBoxFrameVclColor: Integer;
  InputStrokeVclColor: Integer;
  InputVclColor: Integer;
  IsDarkTheme: Boolean;
  LabelAccentVclColor: Integer;
  PanelStrokeVclColor: Integer;
  RaisedSurfaceVclColor: Integer;
  SurfaceVclColor: Integer;
begin
  BackgroundVclColor := AlphaColorToVCLColor(ABackgroundColor);
  FontVclColor := AlphaColorToVCLColor(AFontColor);
  if (AThemeIndex >= Low(CarillonColorThemes)) and
     (AThemeIndex <= High(CarillonColorThemes)) then
  begin
    BackgroundVclColor := CarillonColorThemes[AThemeIndex].BackgroundVclColor;
    SurfaceVclColor := CarillonColorThemes[AThemeIndex].SurfaceVclColor;
    AccentVclColor := CarillonColorThemes[AThemeIndex].AccentVclColor;
    FontVclColor := CarillonColorThemes[AThemeIndex].FontVclColor;
  end
  else
  begin
    if GetVclColorLuminance(BackgroundVclColor) >= 0.55 then
      SurfaceVclColor := BlendVclColors(BackgroundVclColor, RGB(255, 255, 255), 0.68)
    else
      SurfaceVclColor := BlendVclColors(BackgroundVclColor, RGB(255, 255, 255), 0.18);
    if GetVclColorLuminance(BackgroundVclColor) >= 0.55 then
      AccentVclColor := BlendVclColors(FontVclColor, RGB(62, 116, 214), 0.42)
    else
      AccentVclColor := ShiftVclColor(FontVclColor, 0.24);
  end;

  IsDarkTheme := GetVclColorLuminance(BackgroundVclColor) < 0.38;
  if IsDarkTheme then
  begin
    RaisedSurfaceVclColor := BlendVclColors(SurfaceVclColor, RGB(255, 255, 255), 0.12);
    ButtonVclColor := BlendVclColors(AccentVclColor, SurfaceVclColor, 0.16);
    ButtonSecondaryVclColor := BlendVclColors(RaisedSurfaceVclColor, RGB(255, 255, 255), 0.10);
    ButtonDangerVclColor := BlendVclColors(RGB(180, 92, 78), SurfaceVclColor, 0.18);
    LabelAccentVclColor := GetReadableAccentLabelVclColor(AccentVclColor,
      BackgroundVclColor);
    PanelStrokeVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.18);
    InputVclColor := BlendVclColors(RaisedSurfaceVclColor, RGB(255, 255, 255), 0.12);
    InputStrokeVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.22);
    GridEvenVclColor := BlendVclColors(InputVclColor, RGB(255, 255, 255), 0.04);
    GridOddVclColor := BlendVclColors(GridEvenVclColor, AccentVclColor, 0.10);
    GridGroupVclColor := BlendVclColors(SurfaceVclColor, AccentVclColor, 0.22);
    GridSelectedVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.26);
    GridGroupSelectedVclColor := BlendVclColors(GridGroupVclColor, RGB(255, 255, 255), 0.20);
    GridHeaderVclColor := ShiftVclColor(AccentVclColor, -0.08);
  end
  else
  begin
    RaisedSurfaceVclColor := BlendVclColors(SurfaceVclColor, RGB(255, 255, 255), 0.28);
    ButtonVclColor := BlendVclColors(AccentVclColor, SurfaceVclColor, 0.10);
    ButtonSecondaryVclColor := BlendVclColors(RaisedSurfaceVclColor, AccentVclColor, 0.06);
    ButtonDangerVclColor := BlendVclColors(RGB(192, 102, 84), RGB(255, 255, 255), 0.32);
    LabelAccentVclColor := GetReadableAccentLabelVclColor(AccentVclColor,
      BackgroundVclColor);
    PanelStrokeVclColor := ShiftVclColor(AccentVclColor, -0.24);
    InputVclColor := BlendVclColors(RaisedSurfaceVclColor, RGB(255, 255, 255), 0.34);
    InputStrokeVclColor := BlendVclColors(AccentVclColor, SurfaceVclColor, 0.32);
    GridEvenVclColor := BlendVclColors(InputVclColor, RGB(255, 255, 255), 0.08);
    GridOddVclColor := BlendVclColors(GridEvenVclColor, AccentVclColor, 0.07);
    GridGroupVclColor := BlendVclColors(SurfaceVclColor, AccentVclColor, 0.14);
    GridSelectedVclColor := BlendVclColors(AccentVclColor, RGB(255, 255, 255), 0.62);
    GridGroupSelectedVclColor := BlendVclColors(GridGroupVclColor, RGB(255, 255, 255), 0.30);
    GridHeaderVclColor := ShiftVclColor(AccentVclColor, -0.05);
  end;

  if ThemeUsesWhiteAccentLabels(AThemeIndex) then
    LabelAccentVclColor := RGB(245, 244, 240);
  if ThemeUsesWhiteAccentLabels(AThemeIndex) then
  begin
    GridSelectedVclColor := ShiftVclColor(AccentVclColor, -0.36);
    GridGroupSelectedVclColor := ShiftVclColor(GridSelectedVclColor, -0.10);
  end;
  if ThemeUsesWhiteAccentLabels(AThemeIndex) then
    GroupBoxFrameVclColor := LabelAccentVclColor
  else
    GroupBoxFrameVclColor := GridHeaderVclColor;
  if GetVclColorLuminance(FontVclColor) < 0.50 then
    CardTextVclColor := FontVclColor
  else
    CardTextVclColor := GetReadableVclTextColor(InputVclColor);

  APalette.AccentColor := VCLColorToAlphaColor(AccentVclColor);
  APalette.BackgroundColor := VCLColorToAlphaColor(BackgroundVclColor);
  APalette.ButtonColor := VCLColorToAlphaColor(ButtonVclColor);
  APalette.ButtonDangerColor := VCLColorToAlphaColor(ButtonDangerVclColor);
  APalette.ButtonDangerTextColor := VCLColorToAlphaColor(
    GetReadableVclButtonTextColor(ButtonDangerVclColor));
  APalette.ButtonSecondaryColor := VCLColorToAlphaColor(ButtonSecondaryVclColor);
  APalette.ButtonSecondaryTextColor := VCLColorToAlphaColor(
    GetReadableVclButtonTextColor(ButtonSecondaryVclColor));
  APalette.ButtonTextColor := VCLColorToAlphaColor(
    GetReadableVclButtonTextColor(ButtonVclColor));
  APalette.CardTextColor := VCLColorToAlphaColor(CardTextVclColor);
  APalette.FontColor := VCLColorToAlphaColor(FontVclColor);
  APalette.GridEvenColor := VCLColorToAlphaColor(GridEvenVclColor);
  APalette.GridGroupColor := VCLColorToAlphaColor(GridGroupVclColor);
  APalette.GridGroupSelectedColor := VCLColorToAlphaColor(GridGroupSelectedVclColor);
  APalette.GridHeaderColor := VCLColorToAlphaColor(GridHeaderVclColor);
  APalette.GridHeaderTextColor := VCLColorToAlphaColor(
    GetReadableVclTextColor(GridHeaderVclColor));
  APalette.GridOddColor := VCLColorToAlphaColor(GridOddVclColor);
  APalette.GridSelectedColor := VCLColorToAlphaColor(GridSelectedVclColor);
  APalette.GridSelectedTextColor := VCLColorToAlphaColor(
    GetReadableVclTextColor(GridSelectedVclColor));
  APalette.GroupBoxFrameColor := VCLColorToAlphaColor(GroupBoxFrameVclColor);
  APalette.InputColor := VCLColorToAlphaColor(InputVclColor);
  APalette.InputStrokeColor := VCLColorToAlphaColor(InputStrokeVclColor);
  APalette.LabelAccentColor := VCLColorToAlphaColor(LabelAccentVclColor);
  APalette.PanelStrokeColor := VCLColorToAlphaColor(PanelStrokeVclColor);
  APalette.RaisedSurfaceColor := VCLColorToAlphaColor(RaisedSurfaceVclColor);
  APalette.SurfaceColor := VCLColorToAlphaColor(SurfaceVclColor);
end;

function CarillonDatabasePath: string;
begin
  Result := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)),
    'databases'), 'carillon.db');
end;

procedure ConfigurePortableSQLiteConnection(const AConnection: TFDConnection);
begin
  if AConnection = nil then
    Exit;
  AConnection.Connected := False;
  AConnection.LoginPrompt := False;
  AConnection.Params.Values['DriverID'] := 'SQLite';
  AConnection.Params.Values['Database'] := CarillonDatabasePath;
end;

function FindCarillonThemeIndex(const ABackgroundColor,
  AFontColor: TAlphaColor): Integer;
var
  BackgroundVclColor: Integer;
  FontVclColor: Integer;
  I: Integer;
begin
  Result := -1;
  BackgroundVclColor := AlphaColorToVCLColor(ABackgroundColor);
  FontVclColor := AlphaColorToVCLColor(AFontColor);
  for I := Low(CarillonColorThemes) to High(CarillonColorThemes) do
    if (CarillonColorThemes[I].BackgroundVclColor = BackgroundVclColor) and
       (CarillonColorThemes[I].FontVclColor = FontVclColor) then
      Exit(I);
end;

function FindCarillonThemeIndexByMenuName(const AMenuItemName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(CarillonColorThemes) to High(CarillonColorThemes) do
    if SameText(CarillonColorThemes[I].MenuItemName, AMenuItemName) then
      Exit(I);
end;

function LoadCurrentThemeColors(out ABackgroundColor,
  AFontColor: TAlphaColor): Boolean;
var
  Conn: TFDConnection;
  Query: TFDQuery;
begin
  Result := False;
  ABackgroundColor := VCLColorToAlphaColor($8EBDDC);
  AFontColor := VCLColorToAlphaColor($000080);
  Conn := TFDConnection.Create(nil);
  Query := TFDQuery.Create(nil);
  try
    ConfigurePortableSQLiteConnection(Conn);
    Conn.Connected := True;
    Query.Connection := Conn;
    Query.SQL.Text := 'SELECT form_bgcolor, form_fontcolor FROM pl_settings';
    Query.Open;
    if not Query.IsEmpty then
    begin
      if not Query.FieldByName('form_bgcolor').IsNull then
        ABackgroundColor := VCLColorToAlphaColor(
          Query.FieldByName('form_bgcolor').AsInteger);
      if not Query.FieldByName('form_fontcolor').IsNull then
        AFontColor := VCLColorToAlphaColor(
          Query.FieldByName('form_fontcolor').AsInteger);
      Result := True;
    end;
  finally
    Query.Free;
    Conn.Free;
  end;
end;

function LoadCurrentThemeIndex(out AThemeIndex: Integer;
  out ABackgroundColor, AFontColor: TAlphaColor): Boolean;
begin
  Result := LoadCurrentThemeColors(ABackgroundColor, AFontColor);
  AThemeIndex := FindCarillonThemeIndex(ABackgroundColor, AFontColor);
end;

procedure SaveCurrentThemeColors(const ABackgroundColor, AFontColor: TAlphaColor);
var
  Conn: TFDConnection;
  Query: TFDQuery;
begin
  Conn := TFDConnection.Create(nil);
  Query := TFDQuery.Create(nil);
  try
    ConfigurePortableSQLiteConnection(Conn);
    Conn.Connected := True;
    Query.Connection := Conn;
    Query.SQL.Text :=
      'UPDATE pl_settings SET form_bgcolor = :stbgColor, form_fontcolor = :stfontColor';
    Query.ParamByName('stbgColor').AsInteger := AlphaColorToVCLColor(ABackgroundColor);
    Query.ParamByName('stfontColor').AsInteger := AlphaColorToVCLColor(AFontColor);
    Query.ExecSQL;
  finally
    Query.Free;
    Conn.Free;
  end;
end;

procedure ApplyStyledBackgroundColor(const Target: TFmxObject;
  const Color: TAlphaColor; const SuppressBackground: Boolean = False);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyBackgroundToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
  begin
    if Node = nil then
      Exit;
    if Node is TBrushObject then
    begin
      TBrushObject(Node).Brush.Kind := TBrushKind.Solid;
      TBrushObject(Node).Brush.Color := Color;
    end;
    if Node is TShape then
      TShape(Node).Fill.Color := Color;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyBackgroundToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  if not ((Target is TPanel) or (Target is TGroupBox) or
          (Target is TStatusBar) or (Target is TToolBar)) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  Styled.StylesData['background.Visible'] := TValue.From<Boolean>(not SuppressBackground);
  Styled.StylesData['background.Fill.Color'] := TValue.From<TAlphaColor>(Color);
  Styled.StylesData['background.Stroke.Color'] := TValue.From<TAlphaColor>(Color);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>('background', StyleObj) then
    ApplyBackgroundToStyleTree(StyleObj);
end;

procedure ApplyContainerBackgroundColor(const Root: TFmxObject;
  const Color: TAlphaColor);
var
  I: Integer;
begin
  if Root = nil then
    Exit;
  if (Root is TPanel) and (TPanel(Root).Align = TAlignLayout.Client) then
    ApplyStyledBackgroundColor(Root, Color, True)
  else
    ApplyStyledBackgroundColor(Root, Color, False);
  for I := 0 to Root.ChildrenCount - 1 do
    ApplyContainerBackgroundColor(Root.Children[I], Color);
end;

procedure ApplyStyledResourceColor(const Target: TFmxObject;
  const ResourceName: string; const FillColor, StrokeColor: TAlphaColor);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyColorToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
    TintObj: ITintedObject;
  begin
    if Node = nil then
      Exit;
    if Supports(Node, ITintedObject, TintObj) then
      TintObj.TintColor := FillColor;
    if Node is TBrushObject then
    begin
      TBrushObject(Node).Brush.Kind := TBrushKind.Solid;
      TBrushObject(Node).Brush.Color := FillColor;
    end;
    if Node is TShape then
    begin
      if TShape(Node).Fill.Kind <> TBrushKind.None then
        TShape(Node).Fill.Color := FillColor;
      TShape(Node).Stroke.Kind := TBrushKind.Solid;
      TShape(Node).Stroke.Color := StrokeColor;
    end;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyColorToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  if SameText(ResourceName, 'background') then
  begin
    Styled.StylesData['background.Fill.Color'] := TValue.From<TAlphaColor>(FillColor);
    Styled.StylesData['background.Stroke.Color'] := TValue.From<TAlphaColor>(StrokeColor);
    Styled.StylesData['Background.Fill.Color'] := TValue.From<TAlphaColor>(FillColor);
    Styled.StylesData['Background.Stroke.Color'] := TValue.From<TAlphaColor>(StrokeColor);
  end;
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>(ResourceName, StyleObj) or
     (SameText(ResourceName, 'background') and
      Styled.FindStyleResource<TFmxObject>('Background', StyleObj)) then
    ApplyColorToStyleTree(StyleObj);
end;

procedure ApplyStyledResourceTextColor(const Target: TFmxObject;
  const ResourceName: string; const TextColor: TAlphaColor);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyTextToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
    TextSettings: ITextSettings;
  begin
    if Node = nil then
      Exit;
    if Node is TText then
      TText(Node).Color := TextColor;
    if Supports(Node, ITextSettings, TextSettings) then
    begin
      TextSettings.StyledSettings :=
        TextSettings.StyledSettings - [TStyledSetting.FontColor];
      TextSettings.TextSettings.FontColor := TextColor;
    end;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyTextToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  Styled.StylesData[ResourceName + '.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(TextColor);
  Styled.StylesData[ResourceName + '.FontColor'] :=
    TValue.From<TAlphaColor>(TextColor);
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>(ResourceName, StyleObj) then
    ApplyTextToStyleTree(StyleObj);
end;

procedure ApplyStyledResourceShapeMetrics(const Target: TFmxObject;
  const ResourceName: string; const AXRadius, AYRadius,
  AStrokeThickness: Single);
var
  Styled: TStyledControl;
  StyleObj: TFmxObject;
  procedure ApplyMetricsToStyleTree(const Node: TFmxObject);
  var
    J: Integer;
  begin
    if Node = nil then
      Exit;
    if Node is TShape then
      TShape(Node).Stroke.Thickness := AStrokeThickness;
    for J := 0 to Node.ChildrenCount - 1 do
      ApplyMetricsToStyleTree(Node.Children[J]);
  end;
begin
  if not (Target is TStyledControl) then
    Exit;
  Styled := TStyledControl(Target);
  Styled.ApplyStyleLookup;
  StyleObj := nil;
  if Styled.FindStyleResource<TFmxObject>(ResourceName, StyleObj) or
     (SameText(ResourceName, 'background') and
      Styled.FindStyleResource<TFmxObject>('Background', StyleObj)) then
    ApplyMetricsToStyleTree(StyleObj);
end;

function ResolveButtonTier(const AButton: TButton): TCarillonThemeButtonTier;
var
  Key: string;
begin
  Result := ctbtSecondary;
  if AButton = nil then
    Exit;
  Key := LowerCase(AButton.Name + ' ' + AButton.Text);
  if (Pos('stop', Key) > 0) or (Pos('clear', Key) > 0) or
     (Pos('delete', Key) > 0) or (Pos('remove', Key) > 0) or
     (Pos('cancel', Key) > 0) then
    Exit(ctbtDanger);
  if (Pos('save', Key) > 0) or (Pos('play', Key) > 0) or
     (Pos('open', Key) > 0) or (Pos('send', Key) > 0) or
     (Pos('test', Key) > 0) or (Pos('browse', Key) > 0) or
     (Pos('select', Key) > 0) or (Pos('recalc', Key) > 0) or
     (Pos('apply', Key) > 0) then
    Exit(ctbtPrimary);
end;

procedure ApplyThemeToButton(const AButton: TButton;
  const APalette: TCarillonThemePalette);
var
  FillColor: TAlphaColor;
  StrokeColor: TAlphaColor;
  TextColor: TAlphaColor;
begin
  if AButton = nil then
    Exit;
  case ResolveButtonTier(AButton) of
    ctbtPrimary:
      begin
        FillColor := APalette.ButtonColor;
        StrokeColor := APalette.PanelStrokeColor;
        TextColor := APalette.ButtonTextColor;
      end;
    ctbtDanger:
      begin
        FillColor := APalette.ButtonDangerColor;
        StrokeColor := APalette.PanelStrokeColor;
        TextColor := APalette.ButtonDangerTextColor;
      end;
  else
    begin
      FillColor := APalette.ButtonSecondaryColor;
      StrokeColor := APalette.InputStrokeColor;
      TextColor := APalette.ButtonSecondaryTextColor;
    end;
  end;
  AButton.StyledSettings := AButton.StyledSettings -
    [TStyledSetting.FontColor, TStyledSetting.Style];
  if ResolveButtonTier(AButton) = ctbtPrimary then
    AButton.TextSettings.Font.Style := [TFontStyle.fsBold]
  else
    AButton.TextSettings.Font.Style := [];
  AButton.TextSettings.FontColor := TextColor;
  ApplyStyledResourceColor(AButton, 'background', FillColor, StrokeColor);
  ApplyStyledResourceShapeMetrics(AButton, 'background', 10, 10, 1.35);
  ApplyStyledResourceTextColor(AButton, 'text', TextColor);
  ApplyStyledResourceTextColor(AButton, 'background', TextColor);
end;

procedure ApplyThemeToInput(const AControl: TStyledControl;
  const APalette: TCarillonThemePalette);
var
  EditControl: TCustomEdit;
  InputSurfaceColor: TAlphaColor;
  InputSurfaceVclColor: Integer;
  InputTextColor: TAlphaColor;
  TextSettings: ITextSettings;
begin
  if AControl = nil then
    Exit;
  EditControl := nil;
  InputSurfaceVclColor := AlphaColorToVCLColor(APalette.InputColor);
  if GetVclColorLuminance(InputSurfaceVclColor) < 0.58 then
    InputSurfaceVclColor := BlendVclColors(InputSurfaceVclColor,
      RGB(255, 255, 255), 0.86);
  InputSurfaceColor := VCLColorToAlphaColor(InputSurfaceVclColor);
  InputTextColor := VCLColorToAlphaColor(
    GetReadableVclTextColor(InputSurfaceVclColor));
  AControl.ApplyStyleLookup;
  if AControl is TCustomEdit then
  begin
    EditControl := TCustomEdit(AControl);
    EditControl.StyledSettings := EditControl.StyledSettings -
      [TStyledSetting.FontColor];
    EditControl.FontColor := InputTextColor;
    EditControl.TextSettings.FontColor := InputTextColor;
  end;
  if Supports(AControl, ITextSettings, TextSettings) then
  begin
    TextSettings.StyledSettings :=
      TextSettings.StyledSettings - [TStyledSetting.FontColor];
    TextSettings.TextSettings.FontColor := InputTextColor;
  end;
  ApplyStyledResourceColor(AControl, 'background', InputSurfaceColor,
    APalette.InputStrokeColor);
  ApplyStyledResourceShapeMetrics(AControl, 'background', 9, 9, 1.25);
  ApplyStyledResourceColor(AControl, 'foreground', InputTextColor,
    InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'text', InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'content', InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'foreground', InputTextColor);
  ApplyStyledResourceTextColor(AControl, 'background', InputTextColor);
  AControl.StylesData['text.FontColor'] := TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['text.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['content.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['content.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['foreground.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  AControl.StylesData['foreground.TextSettings.FontColor'] :=
    TValue.From<TAlphaColor>(InputTextColor);
  if EditControl <> nil then
  begin
    EditControl.FontColor := InputTextColor;
    EditControl.TextSettings.FontColor := InputTextColor;
  end;
  AControl.Repaint;
end;

procedure ApplyThemeToLabel(const ALabel: TLabel;
  const APalette: TCarillonThemePalette);
var
  UseAccentColor: Boolean;
begin
  if ALabel = nil then
    Exit;
  UseAccentColor :=
    SameText(ALabel.Name, 'lblSystemSettings') or
    SameText(ALabel.Name, 'lblHeader') or
    SameText(ALabel.Name, 'Label1') or
    SameText(ALabel.Name, 'Label2') or
    SameText(ALabel.Name, 'Label3') or
    SameText(ALabel.Name, 'Label4') or
    SameText(ALabel.Name, 'Label5') or
    SameText(ALabel.Name, 'Label6') or
    SameText(ALabel.Name, 'Label7') or
    SameText(ALabel.Name, 'Label9');
  ALabel.StyledSettings := ALabel.StyledSettings - [TStyledSetting.FontColor];
  if UseAccentColor then
    ALabel.TextSettings.FontColor := APalette.LabelAccentColor
  else
    ALabel.TextSettings.FontColor := APalette.FontColor;
end;

procedure ApplyThemeToCheckBox(const ACheckBox: TCheckBox;
  const APalette: TCarillonThemePalette;
  const AIncludeInteractiveText: Boolean);
begin
  if (ACheckBox = nil) or (not AIncludeInteractiveText) then
    Exit;
  ACheckBox.StyledSettings := ACheckBox.StyledSettings -
    [TStyledSetting.FontColor];
  ACheckBox.TextSettings.FontColor := APalette.FontColor;
end;

procedure ApplyThemeToSurface(const AControl: TStyledControl;
  const APalette: TCarillonThemePalette; const AFillColor: TAlphaColor);
var
  StrokeColor: TAlphaColor;
begin
  if AControl = nil then
    Exit;
  AControl.ApplyStyleLookup;
  AControl.StylesData['background.Visible'] := TValue.From<Boolean>(True);
  StrokeColor := APalette.PanelStrokeColor;
  ApplyStyledResourceColor(AControl, 'background', AFillColor, StrokeColor);
  ApplyStyledResourceShapeMetrics(AControl, 'background', 12, 12, 1.1);
  if AControl is TGroupBox then
  begin
    TGroupBox(AControl).StyledSettings :=
      TGroupBox(AControl).StyledSettings - [TStyledSetting.FontColor];
    TGroupBox(AControl).TextSettings.FontColor := APalette.GroupBoxFrameColor;
    ApplyStyledResourceTextColor(AControl, 'text', APalette.GroupBoxFrameColor);
    ApplyStyledResourceTextColor(AControl, 'legend', APalette.GroupBoxFrameColor);
    ApplyStyledResourceTextColor(AControl, 'background', APalette.GroupBoxFrameColor);
  end;
end;

procedure ApplyCardEditStyle(const AControl: TStyledControl;
  const ABackgroundColor, AFontColor: TAlphaColor);
var
  Palette: TCarillonThemePalette;
begin
  BuildCarillonThemePalette(FindCarillonThemeIndex(ABackgroundColor,
    AFontColor), ABackgroundColor, AFontColor, Palette);
  ApplyThemeToInput(AControl, Palette);
end;

procedure ApplyTieredButtonStyle(const AButton: TButton;
  const ABackgroundColor, AFontColor: TAlphaColor);
var
  Palette: TCarillonThemePalette;
begin
  BuildCarillonThemePalette(FindCarillonThemeIndex(ABackgroundColor,
    AFontColor), ABackgroundColor, AFontColor, Palette);
  ApplyThemeToButton(AButton, Palette);
end;

procedure ApplyCarillonThemeToForm(const AForm: TForm;
  const AThemeIndex: Integer; const AIncludeInteractiveText: Boolean = True);
var
  I: Integer;
  Palette: TCarillonThemePalette;
  BackgroundColor: TAlphaColor;
  FontColor: TAlphaColor;
begin
  if AForm = nil then
    Exit;
  if (AThemeIndex >= Low(CarillonColorThemes)) and
     (AThemeIndex <= High(CarillonColorThemes)) then
  begin
    BackgroundColor := VCLColorToAlphaColor(
      CarillonColorThemes[AThemeIndex].BackgroundVclColor);
    FontColor := VCLColorToAlphaColor(
      CarillonColorThemes[AThemeIndex].FontVclColor);
  end
  else if not LoadCurrentThemeColors(BackgroundColor, FontColor) then
  begin
    BackgroundColor := VCLColorToAlphaColor($8EBDDC);
    FontColor := VCLColorToAlphaColor($000080);
  end;
  BuildCarillonThemePalette(AThemeIndex, BackgroundColor, FontColor, Palette);
  AForm.Fill.Kind := TBrushKind.Solid;
  AForm.Fill.Color := Palette.BackgroundColor;
  ApplyContainerBackgroundColor(AForm, Palette.BackgroundColor);
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[I] is TLabel then
      ApplyThemeToLabel(TLabel(AForm.Components[I]), Palette)
    else if AForm.Components[I] is TButton then
      ApplyThemeToButton(TButton(AForm.Components[I]), Palette)
    else if AForm.Components[I] is TEdit then
      ApplyThemeToInput(TStyledControl(AForm.Components[I]), Palette)
    else if AForm.Components[I] is TComboEdit then
      ApplyThemeToInput(TStyledControl(AForm.Components[I]), Palette)
    else if AForm.Components[I] is TMemo then
      ApplyThemeToInput(TStyledControl(AForm.Components[I]), Palette)
    else if AForm.Components[I] is TPanel then
      ApplyThemeToSurface(TStyledControl(AForm.Components[I]), Palette,
        Palette.RaisedSurfaceColor)
    else if AForm.Components[I] is TGroupBox then
      ApplyThemeToSurface(TStyledControl(AForm.Components[I]), Palette,
        Palette.RaisedSurfaceColor)
    else if AForm.Components[I] is TCheckBox then
      ApplyThemeToCheckBox(TCheckBox(AForm.Components[I]), Palette,
        AIncludeInteractiveText);
  end;
end;

procedure ApplyCurrentCarillonThemeToForm(const AForm: TForm;
  const AIncludeInteractiveText: Boolean = True);
var
  BackgroundColor: TAlphaColor;
  FontColor: TAlphaColor;
  ThemeIndex: Integer;
begin
  if AForm = nil then
    Exit;
  LoadCurrentThemeIndex(ThemeIndex, BackgroundColor, FontColor);
  ApplyCarillonThemeToForm(AForm, ThemeIndex, AIncludeInteractiveText);
end;

end.
