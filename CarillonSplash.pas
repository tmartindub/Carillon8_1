unit CarillonSplash;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  Data.DB,
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
  FMX.Forms,
  FMX.Graphics,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  Math,
  System.Classes,
  System.SysUtils,
  System.UIConsts,
  System.UITypes,
  System.Variants,
  Winapi.Messages,
  Winapi.Windows, FMX.Controls.Presentation;
type
  TForm1 = class(TForm)
    Westminster: TImage;
    Label1: TLabel;
    fmVersionLabel: TLabel;
    splFDQuery1: TFDQuery;
    splFDConnection1: TFDConnection;
    Panel1: TPanel;
    lblOrgName: TLabel;
    DataSource1: TDataSource;
    constructor Create(AOwner: TComponent); override;
    // Override the constructor to initialize the event
  private
    { Private declarations }
    procedure ResizeFormForResolution(AForm: TForm);
    procedure FormCreateHandler(Sender: TObject);
  public
    { Public declarations }
    OrgName: string;
    RandSongsDir: string;
  end;
var
  Form1: TForm1;
implementation
{$R *.fmx}
constructor TForm1.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // Call the inherited constructor
  FormCreateHandler(Self);
end;
procedure TForm1.FormCreateHandler(Sender: TObject);
begin
  OrgName := '';
  RandSongsDir := '';
  try
    splFDQuery1.Connection := splFDConnection1;
    splFDQuery1.Open;
    if not splFDQuery1.Eof then
    begin
      OrgName := splFDQuery1.FieldByName('ORGANIZATION_NAME').AsString;
      RandSongsDir := splFDQuery1.FieldByName('RAND_SONGS_DIRECTORY').AsString;
    end;
  except
    OrgName := '';
    RandSongsDir := '';
  end;
  if splFDQuery1.Active then
    splFDQuery1.Close;
  // Set organization name label
  lblOrgName.Text := OrgName;
  lblOrgName.Visible := True;
  lblOrgName.TextAlign := TTextAlign.Center;
  lblOrgName.VertTextAlign := TTextAlign.Center;
  // Resize / scale form for current resolution
  ResizeFormForResolution(Self);
  Label1.Position.X := (ClientWidth - Label1.Width) / 2;
  Panel1.Width := Round(lblOrgName.Width + 24);
  Panel1.Height := Round(lblOrgName.Height + 12);
  lblOrgName.Position.X := (Panel1.Width - lblOrgName.Width) / 2;
  lblOrgName.Position.Y := (Panel1.Height - lblOrgName.Height) / 2;
  Panel1.Position.X := (ClientWidth - Panel1.Width) / 2;
  fmVersionLabel.Position.X := Label1.Position.X +
    ((Label1.Width - fmVersionLabel.Width) / 2);
end;
procedure TForm1.ResizeFormForResolution(AForm: TForm);
var
  ScreenWidth, ScreenHeight: Integer;
begin
  // Get the current screen resolution
  ScreenWidth := Round(Screen.WorkAreaWidth);
  ScreenHeight := Round(Screen.WorkAreaHeight);
  // Optionally, center the form on the screen
  AForm.left := (ScreenWidth - AForm.Width) div 2;
  AForm.Top := Round((ScreenHeight - AForm.Height) / 2);
end;
end.
