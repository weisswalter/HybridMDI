program TestAbbau;
{$APPTYPE CONSOLE}
// Nur der Abbau: ein Modul erzeugen, eines freigeben, beenden. Ohne
// Datenbank, ohne EventBus-Post. Zeigt, ob die Instanzliste des Templates
// beim Herunterfahren stolpert.
uses
  System.SysUtils, System.Classes, Vcl.Forms,
  udmModuleTemplate;

type
  TdmEins = class(TdmModuleTemplate)
  end;

var
  A, B: TdmEins;
begin
  Application.ShowMainForm := False;
  Application.Initialize;
  A := TdmEins.Create(Application);
  B := TdmEins.Create(nil);
  Writeln('erzeugt');
  B.Free;
  Writeln('eines freigegeben');
  TdmModuleTemplate.AlleBenachrichtigen('DatenGeladen');
  Writeln('benachrichtigt');
  // Jetzt dasselbe Modul selbst freigeben, VOR dem Programmende.
  A.Free;
  Writeln('Ende (A selbst freigegeben)');
end.
