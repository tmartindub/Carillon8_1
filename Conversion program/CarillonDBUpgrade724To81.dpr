program CarillonDBUpgrade724To81;

// Version: 8.1

uses
  System.StartUpCopy,
  FMX.Forms,
  DBUpgrade724To81Main in 'DBUpgrade724To81Main.pas' {frmDBUpgrade724To81};

begin
  Application.Initialize;
  Application.CreateForm(TfrmDBUpgrade724To81, frmDBUpgrade724To81);
  Application.Run;
end.
