unit Overlay;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Types,
  Math,
  System.Classes,
  System.SysUtils,
  System.UIConsts,
  System.UITypes,
  System.Variants;
type
  TfrmOverlay = class(TForm)
  private
    { Private declarations }
    procedure FormCreateHandler(Sender: TObject);
    // Correct signature for OnCreate
    procedure ResizeFormForResolution(AForm: TForm);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;
var
  frmOverlay: TfrmOverlay;
implementation
{$R *.fmx}
constructor TfrmOverlay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // Call the inherited constructor
  FormCreateHandler(Self);
end;
procedure TfrmOverlay.FormCreateHandler(Sender: TObject);
begin
  // Call the resize method when the form is created
  ResizeFormForResolution(Self); // Self refers to the current form
end;
procedure TfrmOverlay.ResizeFormForResolution(AForm: TForm);
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
end.

