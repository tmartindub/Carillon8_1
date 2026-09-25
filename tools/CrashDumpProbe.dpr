program CrashDumpProbe;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, Winapi.Windows;

procedure RaiseFailFastException(ExceptionRecord, ContextRecord: Pointer;
  Flags: DWORD); stdcall; external kernel32 name 'RaiseFailFastException';

begin
  if (ParamCount <> 1) or (ParamStr(1) <> '--verify-crash-capture') then
  begin
    Writeln('Diagnostic probe only. Requires --verify-crash-capture.');
    Halt(1);
  end;
  Writeln('Synthetic fail-fast capture test. PID=', GetCurrentProcessId);
  Flush(Output);
  RaiseFailFastException(nil, nil, 0);
  Halt(1);
end.
