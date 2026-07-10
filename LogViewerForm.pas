unit LogViewerForm;

// Westminster Chimes and Carillon Bells
// Version: 8.1
interface

uses
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Grid, FMX.Layouts,
  FMX.StdCtrls, FMX.Types, System.Classes, System.UITypes;

type
  TfrmLogViewer = class(TForm)
  private
    FCloseButton: TButton;
    FDateColumn: TStringColumn;
    FGrid: TStringGrid;
    FHeaderLabel: TLabel;
    FMessageColumn: TStringColumn;
    FRefreshButton: TButton;
    FStatusLabel: TLabel;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure RefreshButtonClick(Sender: TObject);
    procedure BuildControls;
    procedure LoadLogRows;
    procedure ResizeGridColumns;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshLogRows;
  end;

implementation

uses
  CarillonTheme, LogManager, Math, System.IOUtils, System.SysUtils;

const
  MaxDisplayedLogRows = 1000;
  LogGridFontSize = 16;
  LogDateTimeColumnWidth = 245;

constructor TfrmLogViewer.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Carillon Log';
  OnClose := FormClose;
  OnResize := FormResize;
  Position := TFormPosition.ScreenCenter;
  if Assigned(Application.MainForm) then
  begin
    Width := EnsureRange(Round(Application.MainForm.Width * 0.75), 760, 1200);
    Height := EnsureRange(Round(Application.MainForm.Height * 0.7), 420, 720);
  end
  else
  begin
    Width := 980;
    Height := 560;
  end;
  BuildControls;
  ApplyCurrentCarillonThemeToForm(Self);
  LoadLogRows;
end;

procedure TfrmLogViewer.BuildControls;
var
  HeaderLayout: TLayout;
  ButtonLayout: TLayout;
begin
  HeaderLayout := TLayout.Create(Self);
  HeaderLayout.Parent := Self;
  HeaderLayout.Align := TAlignLayout.Top;
  HeaderLayout.Height := 70;
  HeaderLayout.Padding.Left := 16;
  HeaderLayout.Padding.Right := 16;
  HeaderLayout.Padding.Top := 12;

  FHeaderLabel := TLabel.Create(Self);
  FHeaderLabel.Parent := HeaderLayout;
  FHeaderLabel.Align := TAlignLayout.Top;
  FHeaderLabel.Height := 30;
  FHeaderLabel.Text := 'Carillon Log';
  FHeaderLabel.TextSettings.Font.Size := 26;
  FHeaderLabel.TextSettings.HorzAlign := TTextAlign.Center;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := HeaderLayout;
  FStatusLabel.Align := TAlignLayout.Top;
  FStatusLabel.Height := 24;
  FStatusLabel.TextSettings.Font.Size := 15;
  FStatusLabel.TextSettings.HorzAlign := TTextAlign.Center;

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align := TAlignLayout.Client;
  FGrid.Margins.Left := 16;
  FGrid.Margins.Right := 16;
  FGrid.Margins.Bottom := 10;
  FGrid.Options := [TGridOption.ColLines, TGridOption.RowLines,
    TGridOption.AlwaysShowSelection, TGridOption.Header];
  FGrid.RowHeight := 32;
  FGrid.StyledSettings := FGrid.StyledSettings - [TStyledSetting.Size];
  FGrid.TextSettings.Font.Size := LogGridFontSize;

  FDateColumn := TStringColumn.Create(Self);
  FDateColumn.Parent := FGrid;
  FDateColumn.Header := 'Date / Time';
  FDateColumn.Width := LogDateTimeColumnWidth;

  FMessageColumn := TStringColumn.Create(Self);
  FMessageColumn.Parent := FGrid;
  FMessageColumn.Header := 'Event';
  ResizeGridColumns;

  ButtonLayout := TLayout.Create(Self);
  ButtonLayout.Parent := Self;
  ButtonLayout.Align := TAlignLayout.Bottom;
  ButtonLayout.Height := 58;
  ButtonLayout.Padding.Top := 10;
  ButtonLayout.Padding.Bottom := 12;

  FRefreshButton := TButton.Create(Self);
  FRefreshButton.Parent := ButtonLayout;
  FRefreshButton.Position.X := (Width / 2) - 130;
  FRefreshButton.Position.Y := 10;
  FRefreshButton.Width := 110;
  FRefreshButton.Height := 34;
  FRefreshButton.TextSettings.Font.Size := 14;
  FRefreshButton.Text := 'Refresh';
  FRefreshButton.OnClick := RefreshButtonClick;

  FCloseButton := TButton.Create(Self);
  FCloseButton.Parent := ButtonLayout;
  FCloseButton.Position.X := (Width / 2) + 20;
  FCloseButton.Position.Y := 10;
  FCloseButton.Width := 110;
  FCloseButton.Height := 34;
  FCloseButton.TextSettings.Font.Size := 14;
  FCloseButton.Text := 'Close';
  FCloseButton.OnClick := CloseButtonClick;
end;

procedure TfrmLogViewer.ResizeGridColumns;
begin
  if Assigned(FGrid) and Assigned(FMessageColumn) then
    FMessageColumn.Width := Max(420, Round(FGrid.Width - FDateColumn.Width - 42));
end;

procedure TfrmLogViewer.LoadLogRows;
var
  DateTimeValue: TDateTime;
  DateTimeText: string;
  I: Integer;
  Line: string;
  Lines: TStringList;
  MessageText: string;
  RowIndex: Integer;
  SeparatorPos: Integer;
  StartIndex: Integer;
begin
  FGrid.RowCount := 0;
  if not FileExists(CarillonLogFilePath) then
  begin
    FStatusLabel.Text := 'Log file not found: ' + CarillonLogFilePath;
    Exit;
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(CarillonLogFilePath);
    StartIndex := Max(0, Lines.Count - MaxDisplayedLogRows);
    FGrid.RowCount := Lines.Count - StartIndex;
    RowIndex := 0;
    for I := Lines.Count - 1 downto StartIndex do
    begin
      Line := Lines[I];
      SeparatorPos := Pos(' - ', Line);
      if SeparatorPos > 0 then
      begin
        DateTimeText := Copy(Line, 1, SeparatorPos - 1);
        if TryParseCarillonLogLineDateTime(Line, DateTimeValue) then
          DateTimeText := FormatDateTime('m/d/yyyy h:nn:ss AM/PM',
            DateTimeValue);
        MessageText := Copy(Line, SeparatorPos + 3, MaxInt);
      end
      else
      begin
        DateTimeText := '';
        MessageText := Line;
      end;
      FGrid.Cells[0, RowIndex] := DateTimeText;
      FGrid.Cells[1, RowIndex] := MessageText;
      Inc(RowIndex);
    end;
    if Lines.Count > MaxDisplayedLogRows then
      FStatusLabel.Text := Format('Showing latest %d of %d log entries',
        [MaxDisplayedLogRows, Lines.Count])
    else
      FStatusLabel.Text := Format('Showing %d log entries', [Lines.Count]);
  finally
    Lines.Free;
  end;
end;

procedure TfrmLogViewer.RefreshLogRows;
begin
  LoadLogRows;
end;

procedure TfrmLogViewer.RefreshButtonClick(Sender: TObject);
begin
  RefreshLogRows;
end;

procedure TfrmLogViewer.FormResize(Sender: TObject);
begin
  ResizeGridColumns;
end;

procedure TfrmLogViewer.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogViewer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

end.
