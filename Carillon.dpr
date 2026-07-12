program Carillon;

// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved

uses
  FMX.Forms,
  FMX.Dialogs,
  System.SysUtils,
  Winapi.Windows,
  Playlist in 'Playlist.pas' {fmDailyPlayList} ,
  GroupForm in 'GroupForm.pas' {Groups} ,
  Overlay in 'Overlay.pas' {frmOverlay} ,
  CarillonSplash in 'CarillonSplash.pas' {Form1} ,
  ClockUnit in 'ClockUnit.pas' {fmClock} ,
  SettingsForm in 'SettingsForm.pas' {SettingsMain} ,
  AudioManager in 'AudioManager.pas',
  SilenceManager in 'SilenceManager.pas',
  SilenceScheduleForm in 'SilenceScheduleForm.pas' {frmSilenceSchedule},
  RandomDirectoryManager in 'RandomDirectoryManager.pas',
  LogManager in 'LogManager.pas',
  LogViewerForm in 'LogViewerForm.pas',
  ScheduleManager in 'ScheduleManager.pas',
  MMDevAPI in 'MMDevAPI.pas',
  email in 'email.pas' {Form2} ,
  PowerHoldSimple in 'PowerHoldSimple.pas',
  RandomDirectory in 'RandomDirectory.pas' {frmRandomDirectory};

{$R *.res}

var
  LockHandle: THandle;

begin
  // Attempt to acquire an exclusive lock on the .lock file
  LockHandle := CreateFile(PChar(ExtractFilePath(ParamStr(0)) +
    'Carillon.lock'), GENERIC_READ or GENERIC_WRITE, 0,
    // dwShareMode = 0 ? exclusive lock
    nil, // lpSecurityAttributes
    OPEN_ALWAYS, // open existing or create new
    FILE_ATTRIBUTE_NORMAL, 0);
  if LockHandle = INVALID_HANDLE_VALUE then
  begin
    Showmessage('Another instance of this application is running.');
    Halt; // Could not lock ? another instance is running
  end;

  try
    // ReportMemoryLeaksOnShutdown := True; // Disabled to avoid leak popups during forced Windows shutdown.
    Application.Initialize;


    // Show the splash screen
    Form1 := TForm1.Create(nil);
    try
      Form1.Show;
      Application.ProcessMessages;
      Application.HandleMessage;
    Sleep(2500); // Delay for 2.5 seconds
    finally
      Form1.Free;
      Form1 := nil;
    end;

    Application.CreateForm(TfmDailyPlayList, fmDailyPlayList);
    Application.CreateForm(TfrmOverlay, frmOverlay);
    Application.CreateForm(TGroups, Groups);
    Application.CreateForm(TfmClock, fmClock);

    Application.CreateForm(TSettingsMain, SettingsMain);
    Application.CreateForm(TfrmSilenceSchedule, frmSilenceSchedule);
    Application.CreateForm(TfrmEmailSettings, frmEmailSettings);
    Application.CreateForm(TfrmRandomDirectory, frmRandomDirectory);

    Application.Run;
  finally
    // Release the lock on exit
    if LockHandle <> INVALID_HANDLE_VALUE then
      CloseHandle(LockHandle);
  end;

end.

