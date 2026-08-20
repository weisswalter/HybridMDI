program TestFelder;
{$APPTYPE CONSOLE}
// Gibt aus, welche Feldklassen FireDAC fuer v_lagerort und artikel_fach
// erzeugt. Grundlage fuer die persistenten Felder im DFM - geraten waere
// jeder Typ ein Laufzeitfehler.
uses
  System.SysUtils, Data.DB, Vcl.Forms, FireDAC.Comp.Client, ZentraleDatenDm;

procedure Zeige(const ATabelle: string);
var
  LT: TFDTable;
  I: Integer;
begin
  LT := TdmZentraleDaten(TdmZentraleDaten.GetInstance)
         .FindComponent('FDTable' + ATabelle) as TFDTable;
  if not Assigned(LT) then
  begin
    Writeln(ATabelle, ': nicht gefunden');
    Exit;
  end;
  if not LT.Active then
    LT.Open;
  Writeln('--- ', ATabelle, ' (', LT.FieldCount, ' Felder)');
  for I := 0 to LT.FieldCount - 1 do
    Writeln(Format('%-24s %-20s Size=%d Required=%s',
      [LT.Fields[I].FieldName, LT.Fields[I].ClassName, LT.Fields[I].Size,
       BoolToStr(LT.Fields[I].Required, True)]));
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    TdmZentraleDaten.GetInstance;
    Zeige('vorgang');
    Zeige('vorgang_verlauf');
    Zeige('vorgang_zustand');
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
