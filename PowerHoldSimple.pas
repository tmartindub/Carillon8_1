unit PowerHoldSimple;
// Westminster Chimes and Carillon Bells
// Version: 8.1
// © 2026 All rights reserved
interface
uses
  Winapi.Windows;
procedure PowerHoldOn;
procedure PowerHoldOff;
implementation
procedure PowerHoldOn;
begin
  // Tell Windows: keep the system awake while my app runs
  SetThreadExecutionState(ES_CONTINUOUS or ES_SYSTEM_REQUIRED);
end;
procedure PowerHoldOff;
begin
  // Restore normal behavior
  SetThreadExecutionState(ES_CONTINUOUS);
end;
end.
