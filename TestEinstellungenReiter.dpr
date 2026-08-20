program TestEinstellungenReiter;
{$APPTYPE CONSOLE}
// Prueft, dass jeder Reiter des Einstellungsfensters erreichbar ist.
//
// Beim TRibbonPanel ist die Kopfleiste die Wahrheit: HeaderButtons[i] wird
// von ReconnectLoadedTabSheets der Reihe nach mit dem i-ten TabSheet des
// Panels gepaart. Ein TabSheet ohne Kopfschalter ist damit unerreichbar -
// genau das war mir passiert.
uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.ComCtrls,
  Vcl.Controls, RibbonPanel,
  EinstellungenFrm;

type
  TMdiRahmen = class(TForm)
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TMdiRahmen.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  FormStyle := fsMDIForm;
  Position := poDesigned;
  Left := -32000;
  Top := -32000;
  WindowState := wsMinimized;
end;

var
  LRahmen: TMdiRahmen;
  LF: TfrmEinstellungen;
  I, LFehler, LText, LSchalter, LSheets: Integer;
  LMess: TBitmap;
  LTitel, LName: string;
begin
  LFehler := 0;
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TMdiRahmen, LRahmen);
    LF := TfrmEinstellungen.Create(nil);
    LMess := TBitmap.Create;
    try
      LMess.Canvas.Font := LF.Font;

      LSchalter := LF.JvRibbonPanel1.HeaderButtons.Count;
      LSheets := 0;
      for I := 0 to LF.JvRibbonPanel1.ControlCount - 1 do
        if LF.JvRibbonPanel1.Controls[I] is TTabSheet then
          Inc(LSheets);

      Writeln(Format('Kopfschalter: %d   Tabsheets im Panel: %d',
                     [LSchalter, LSheets]));
      Writeln;

      for I := 0 to LSchalter - 1 do
      begin
        LTitel := LF.JvRibbonPanel1.HeaderButtons[I].Caption;
        LText := LMess.Canvas.TextWidth(LTitel);

        if Assigned(LF.JvRibbonPanel1.HeaderButtons[I].TabSheet) then
          LName := LF.JvRibbonPanel1.HeaderButtons[I].TabSheet.Name
        else
          LName := '(ohne Seite)';

        if LName = '(ohne Seite)' then
          Inc(LFehler);
        if LF.JvRibbonPanel1.HeaderButtons[I].Width < LText + 20 then
        begin
          Inc(LFehler);
          LName := LName + Format('  ZU SCHMAL Text=%d Breite=%d',
            [LText, LF.JvRibbonPanel1.HeaderButtons[I].Width]);
        end;

        Writeln(Format('  %d %-18s -> %s', [I, LTitel, LName]));
      end;

      if LSheets > LSchalter then
      begin
        Inc(LFehler);
        Writeln(Format('  %d Tabsheet(s) ohne Kopfschalter - nicht erreichbar.',
                       [LSheets - LSchalter]));
      end;

      Writeln;
      if LFehler = 0 then
        Writeln('Jeder Reiter ist erreichbar.')
      else
        Writeln(LFehler, ' Beanstandung(en).');
    finally
      LMess.Free;
      LF.Free;
    end;
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
