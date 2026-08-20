program TestVorgang;
{$APPTYPE CONSOLE}
// Fuehrt das Vorgangsmodul durch einen kompletten Ticketlauf: anlegen,
// Stufen wechseln, Abschluss, Reaktivierungsversuch, Nachfolger. Prueft
// dabei, was das Fenster spaeter anzeigt (Lookup-Spalten, Verlauf,
// Verknuepfung). Raeumt am Ende auf.
// Der MDI-Rahmen startet minimiert und ausserhalb des Bildschirms.
uses
  System.SysUtils, System.Classes, Data.DB, Vcl.Forms, Vcl.Controls,
  FireDAC.Comp.Client,
  ZentraleDatenDm, MandantDm, VorgangDm, VorgangFrm;

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
  LDm: TdmVorgang;
  LTypen, LSchritte: TStringList;
  LFehler: Integer = 0;
  LId, LNach: Integer;
  LMeldung: string;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
var
  LZusatz: string;
begin
  if AText = '' then LZusatz := '' else LZusatz := '   ' + AText;
  Writeln(Format('%-44s %s%s', [ATitel, BoolToStr(AGut, True), LZusatz]));
  if not AGut then Inc(LFehler);
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TMdiRahmen, LRahmen);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;
    TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 3;

    LDm := TdmVorgang(TdmVorgang.GetInstance);
    LDm.OpenVorgang;
    Sag('Modul geoeffnet, Fenster da', Assigned(frmVorgang));

    LTypen := TStringList.Create;
    LSchritte := TStringList.Create;
    try
      LDm.TypenFuellen(LTypen);
      Sag(Format('Vorgangstypen geladen (%d)', [LTypen.Count]), LTypen.Count = 5);

      // Anlegen
      LMeldung := LDm.Anlegen(Integer(NativeInt(LTypen.Objects[0])),
                              'ZZPruef Modullauf', LId);
      Sag('Anlegen', (LMeldung = '') and (LId > 0), LMeldung);
      Sag('  ... Nummer vergeben',
          LDm.tblVorgang.FieldByName('vorgang_nr').AsString <> '',
          LDm.tblVorgang.FieldByName('vorgang_nr').AsString);
      Sag('  ... Lookup Typ/Zustand gefuellt',
          (LDm.tblVorgang.FieldByName('typ_bezeichnung').AsString <> '') and
          (LDm.tblVorgang.FieldByName('zustand_bezeichnung').AsString <> ''),
          LDm.tblVorgang.FieldByName('zustand_bezeichnung').AsString);
      Sag('  ... Verlauf hat einen Eintrag',
          LDm.tblVerlauf.RecordCount = 1);

      // Speichern
      LMeldung := LDm.Speichern('ZZPruef Modullauf geaendert', 'Text dazu', 0);
      Sag('Speichern',
          (LMeldung = '') and
          (LDm.tblVorgang.FieldByName('bezeichnung').AsString =
           'ZZPruef Modullauf geaendert'), LMeldung);

      // Schritte
      LDm.SchritteFuellen(LSchritte);
      Sag(Format('Moegliche Schritte ab Neu (%d)', [LSchritte.Count]),
          LSchritte.Count = 2, LSchritte.CommaText);

      LMeldung := LDm.Weiter(Integer(NativeInt(LSchritte.Objects[
                    LSchritte.IndexOf('In Arbeit')])), 'angefangen');
      Sag('Weiter nach In Arbeit', LMeldung = '', LMeldung);

      LDm.SchritteFuellen(LSchritte);
      LMeldung := LDm.Weiter(Integer(NativeInt(LSchritte.Objects[
                    LSchritte.IndexOf('Abgeschlossen')])), 'erledigt');
      Sag('Weiter nach Abgeschlossen', LMeldung = '', LMeldung);
      Sag('  ... gilt als abgeschlossen', LDm.IstAbgeschlossen);
      Sag('  ... Verlauf hat drei Eintraege', LDm.tblVerlauf.RecordCount = 3);

      LDm.SchritteFuellen(LSchritte);
      Sag('  ... kein Schritt mehr moeglich', LSchritte.Count = 0);

      // Reaktivierung und Aenderung muessen scheitern
      LMeldung := LDm.Speichern('heimlich geaendert', '', 0);
      Sag('Aendern am geschlossenen Vorgang abgelehnt', LMeldung <> '');

      // Nachfolger
      LMeldung := LDm.Nachfolger('ZZPruef Nachfolger', LNach);
      Sag('Nachfolger angelegt', (LMeldung = '') and (LNach > 0), LMeldung);
      Sag('  ... Verknuepfung sichtbar',
          (LDm.tblVerknuepft.RecordCount = 1) and
          (LDm.tblVerknuepft.FieldByName('richtung').AsString = 'Vorgaenger'),
          LDm.tblVerknuepft.FieldByName('vorgang_nr').AsString);
    finally
      LTypen.Free; LSchritte.Free;
    end;

    Writeln;
    if LFehler = 0 then Writeln('Alles in Ordnung.')
                   else Writeln(LFehler, ' Pruefung(en) fehlgeschlagen.');
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
