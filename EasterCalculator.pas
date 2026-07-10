unit EasterCalculator;

// Version: 8.1
interface

uses
  System.SysUtils;

function CalculateEasterDate(const AYear: Integer): TDateTime;

implementation

function CalculateEasterDate(const AYear: Integer): TDateTime;
var
  A: Integer;
  B: Integer;
  C: Integer;
  D: Integer;
  E: Integer;
  F: Integer;
  G: Integer;
  H: Integer;
  I: Integer;
  K: Integer;
  L: Integer;
  M: Integer;
  Month: Integer;
  Day: Integer;
begin
  A := AYear mod 19;
  B := AYear div 100;
  C := AYear mod 100;
  D := B div 4;
  E := B mod 4;
  F := (B + 8) div 25;
  G := (B - F + 1) div 3;
  H := (19 * A + B - D - G + 15) mod 30;
  I := C div 4;
  K := C mod 4;
  L := (32 + 2 * E + 2 * I - H - K) mod 7;
  M := (A + 11 * H + 22 * L) div 451;
  Month := (H + L - 7 * M + 114) div 31;
  Day := ((H + L - 7 * M + 114) mod 31) + 1;
  Result := EncodeDate(AYear, Month, Day);
end;

end.
