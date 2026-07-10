unit ClockUnit;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Menus,
  FMX.Objects,
  FMX.Types,
  Math,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UIConsts,
  System.UITypes,
  System.Variants,
  Winapi.Messages,
  Winapi.Windows;
type
  TfmClock = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    MainMenu1: TMenuBar;
    fmFile: TMenuItem;
    fmClose: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FBackgroundBitmap: FMX.Graphics.TBitmap;
    FSecondCounter: Integer;
    CenterX: Integer;
    CenterY: Integer;
    procedure DrawClockHands(ShowDebug: Boolean);
    procedure DrawHand(Canvas: TCanvas; CenterX, CenterY: Integer;
      Angle: Extended; Length: Integer; Color: TAlphaColor; Thickness: Integer;
      HandType: string; ShowDebug: Boolean);
  // // FMX manual review: procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND; - handle through FMX events
    procedure ResizeFormForResolution(AForm: TForm); // Resizing procedure
  public
    offsetx, offsety: Integer;
  end;
  var
    fmClock: TfmClock;
implementation
{$R *.fmx}
procedure FillAndStrokeEllipse(ACanvas: TCanvas; const R: TRectF);
begin
  ACanvas.FillEllipse(R, 1);
  ACanvas.DrawEllipse(R, 1);
end;
procedure TfmClock.FormCreate(Sender: TObject);
begin
  // Enable double buffering to reduce flicker
  // FMX manual review: DoubleBuffered := True;
  FSecondCounter := 0;
  Timer1.Interval := 1000;
  Timer1.Enabled := True;
  // Create and store the background bitmap
  FBackgroundBitmap := FMX.Graphics.TBitmap.Create;
  FBackgroundBitmap.SetSize(Image1.Bitmap.Width, Image1.Bitmap.Height);
  if FBackgroundBitmap.Canvas.BeginScene then
  try
  FBackgroundBitmap.Canvas.DrawBitmap(Image1.Bitmap, System.Types.RectF(0, 0, Image1.Bitmap.Width, Image1.Bitmap.Height), System.Types.RectF(0, 0, Image1.Bitmap.Width, Image1.Bitmap.Height), 1);
  finally
    FBackgroundBitmap.Canvas.EndScene;
  end;
  // Resize the form based on the current resolution
  ResizeFormForResolution(Self);
  // Adjust the offsets for fine-tuning the hands' positioning
  CenterX := Round(ClientWidth / 2) + offsetx; // Dynamically calculate Center X
  CenterY := Round(ClientHeight / 2) + offsety; // Dynamically calculate Center Y
  DrawClockHands(False); // Initial call to set the clock hands
end;
procedure TfmClock.FormDestroy(Sender: TObject);
begin
  if Assigned(Timer1) then
    Timer1.Enabled := False;
  FreeAndNil(FBackgroundBitmap); // Free the background bitmap
  if fmClock = Self then
    fmClock := nil;
end;
procedure TfmClock.Timer1Timer(Sender: TObject);
begin
  Inc(FSecondCounter); // Increment the counter every second
  DrawClockHands(True);
end;
procedure TfmClock.Button1Click(Sender: TObject);
begin
  Close;
end;
  // FMX manual review: procedure TfmClock.WMSysCommand(var Msg: TWMSysCommand);
  // FMX manual review: begin
  // FMX manual review: if (Msg.CmdType and $FFF0) = SC_MINIMIZE then
  // FMX manual review: begin
  // FMX manual review: Timer1.Enabled := True;
  // FMX manual review: end
  // FMX manual review: else if (Msg.CmdType and $FFF0) = SC_CLOSE then
  // FMX manual review: begin
  // FMX manual review: Close;
  // FMX manual review: end
  // FMX manual review: else
  // FMX manual review: begin
  // FMX manual review: inherited;
  // FMX manual review: end;
  // FMX manual review: end;
procedure TfmClock.DrawClockHands(ShowDebug: Boolean);
var
  NowTime: TDateTime;
  Hour, Minute, Second, MilliSecond: Word;
  MinuteAngle, HourAngle: Extended;
begin
  NowTime := Now;
  DecodeTime(NowTime, Hour, Minute, Second, MilliSecond);
  // Calculate angles
  MinuteAngle := 360 * (Minute / 60);
  HourAngle := 360 * ((Hour mod 12) / 12) + (Minute / 60) * 30;
  // Restore the background
  Image1.Bitmap.Assign(FBackgroundBitmap);
  // Draw the hands on the canvas
  if Image1.Bitmap.Canvas.BeginScene then
  try
  DrawHand(Image1.Bitmap.Canvas, CenterX, CenterY, MinuteAngle, 217, claBlack, 10,
    'Minute', ShowDebug); // Length and thickness of minute hand
  DrawHand(Image1.Bitmap.Canvas, CenterX, CenterY, HourAngle, 170, claBlack, 10, 'Hour',
    ShowDebug); // Length and thickness of hour hand
  finally
    Image1.Bitmap.Canvas.EndScene;
  end;
end;
procedure TfmClock.DrawHand(Canvas: TCanvas; CenterX, CenterY: Integer;
  Angle: Extended; Length: Integer; Color: TAlphaColor; Thickness: Integer;
  HandType: string; ShowDebug: Boolean);
var
  RadAngle: Extended;
  TipX, TipY: Integer;
  BaseLeftX, BaseLeftY, BaseRightX, BaseRightY: Integer;
  BaseWidth: Integer;
  PivotRadius: Integer;
begin
  RadAngle := DegToRad(Angle - 90); // Adjust angle for coordinate system
  TipX := CenterX + Round(Length * Cos(RadAngle));
  TipY := CenterY + Round(Length * Sin(RadAngle));
  BaseWidth := Thickness * 2;
  BaseLeftX := CenterX + Round((BaseWidth / 2) * Cos(RadAngle + PI / 2));
  BaseLeftY := CenterY + Round((BaseWidth / 2) * Sin(RadAngle + PI / 2));
  BaseRightX := CenterX + Round((BaseWidth / 2) * Cos(RadAngle - PI / 2));
  BaseRightY := CenterY + Round((BaseWidth / 2) * Sin(RadAngle - PI / 2));
  Canvas.Stroke.Color := Color;
  Canvas.Stroke.Thickness := 1;
  Canvas.Fill.Color := Color;
  // Draw the hand
  Canvas.FillPolygon([System.Types.PointF(CenterX, CenterY), System.Types.PointF(BaseLeftX, BaseLeftY),
    System.Types.PointF(TipX, TipY), System.Types.PointF(BaseRightX, BaseRightY)], 1);
  // Draw the larger rounded pivot point
  PivotRadius := Round(Thickness * 1.5); // Adjust the size of the pivot point
  Canvas.Fill.Color := Color;
  FillAndStrokeEllipse(Canvas, System.Types.RectF(CenterX - PivotRadius, CenterY - PivotRadius,
    CenterX + PivotRadius, CenterY + PivotRadius));
end;
procedure TfmClock.ResizeFormForResolution(AForm: TForm);
var
  ScreenWidth, ScreenHeight: Integer;
  resWidth, resHeight: Integer;
begin
  // Get the current screen resolution
  ScreenWidth := Round(Screen.WorkAreaWidth);
  ScreenHeight := Round(Screen.WorkAreaHeight);
  resWidth := Round(Screen.Width);
  resHeight := Round(Screen.Height);
  // ==================== Adjust offset depending on resolution of screen=============
  if (resWidth = Round(1920 * 1)) and (resHeight = Round(1080 * 1)) then
  begin
    offsetx := 51;
    offsety := 15;
  end
  else if (resWidth = Round(1680 * 1)) and (resHeight = Round(1050 * 1)) then
  begin
    offsetx := 121;
    offsety := 51;
  end
  else if (resWidth = Round(1600 * 1)) and (resHeight = Round(900 * 1)) then
  begin
    offsetx := 156;
    offsety := 66;
  end
  else if (resWidth = Round(1440 * 1)) and (resHeight = Round(900 * 1)) then
  begin
    offsetx := 201;
    offsety := 88;
  end
  else if (resWidth = Round(1400 * 1)) and (resHeight = Round(1050 * 1)) then
  begin
    offsetx := 216;
    offsety := 76;
  end
  else if (resWidth = Round(1366 * 1)) and (resHeight = Round(768 * 1)) then
  begin
    offsetx := 293;
    offsety := 156;
  end
  else if (resWidth = Round(1360 * 1)) and (resHeight = Round(768 * 1)) then
  begin
    offsetx := 296;
    offsety := 156;
  end
  else if (resWidth = Round(1280 * 1)) and (resHeight = Round(1024 * 1)) then
  begin
    offsetx := 329;
    offsety := 136;
  end
  else if (resWidth = Round(1280 * 1)) and (resHeight = Round(960 * 1)) then
  begin
    offsetx := 329;
    offsety := 136;
  end
  else if (resWidth = Round(1280 * 1)) and (resHeight = Round(800 * 1)) then
  begin
    offsetx := 329;
    offsety := 146;
  end
  else if (resWidth = Round(1280 * 1)) and (resHeight = Round(768 * 1)) then
  begin
    offsetx := 329;
    offsety := 156;
  end
  else if (resWidth = Round(1280 * 1)) and (resHeight = Round(720 * 1)) then
  begin
    offsetx := 359;
    offsety := 196;
  end
  else
  begin
    offsetx := 151;
    offsety := 41;
  end;
  // Optionally, center the form on the screen
  AForm.Left := Round((ScreenWidth - AForm.Width) / 2);
  AForm.Top := Round((ScreenHeight - AForm.Height) / 2);
end;
end.

