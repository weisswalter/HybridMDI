program TestEinstellungen;
{$APPTYPE CONSOLE}
// Legt ueber jeden Reiter des Einstellungsfensters einen Eintrag an, aendert
// ihn und prueft in der Datenbank nach, ob er wirklich dort angekommen ist.
// Genau das ging vorher nicht: der Post landete in der Speicherkopie.
// Raeumt am Ende alles wieder weg.
// Der MDI-Rahmen startet minimiert und ausserhalb des Bildschirms.
uses
  System.SysUtils, System.Classes, Data.DB, Vcl.Forms, Vcl.Controls,
  FireDAC.Comp.Client,
  ZentraleDatenDm, MandantDm, EinstellungenDm, EinstellungenFrm;

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

const
  // Reiter, Name des Bezeichnungsfeldes - der Rest kommt aus dem Modul.
  cReiter: array[0..8] of record Titel, Feld: string; end = (
    (Titel: 'Personentyp';      Feld: 'bezeichnung'),
    (Titel: 'Rollentyp';        Feld: 'rollen_bezeichnung'),
    (Titel: 'Adressentyp';      Feld: 'bezeichnung'),
    (Titel: 'Emailtyp';         Feld: 'bezeichnung'),
    (Titel: 'Telefonnummertyp'; Feld: 'bezeichnung'),
    (Titel: 'Rechnungstyp';     Feld: 'bezeichnung'),
    (Titel: 'Leadquelle';       Feld: 'bezeichnung'),
    (Titel: 'Kompetenztyp';     Feld: 'bezeichnung'),
    (Titel: 'Artikelkategorie'; Feld: 'bezeichnung'));

var
  LRahmen: TMdiRahmen;
  LDm: TdmEinstellungen;
  LPruef: TFDQuery;
  LFehler: Integer = 0;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
var
  LZusatz: string;
begin
  if AText = '' then LZusatz := '' else LZusatz := '   ' + AText;
  Writeln(Format('%-40s %s%s', [ATitel, BoolToStr(AGut, True), LZusatz]));
  if not AGut then Inc(LFehler);
end;

function Zaehle(const ATabelle, AFeld, AWert: string): Integer;
begin
  LPruef.Close;
  LPruef.SQL.Text := Format('SELECT count(*) FROM %s WHERE %s = %s',
    [ATabelle, AFeld, QuotedStr(AWert)]);
  LPruef.Open;
  Result := LPruef.Fields[0].AsInteger;
end;

var
  I: Integer;
  LDs: TDataSource;
  LTabelle, LMeldung, LName: string;
begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TMdiRahmen, LRahmen);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;
    TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 3;

    LPruef := TFDQuery.Create(nil);
    try
      LPruef.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
      LDm := TdmEinstellungen(TdmEinstellungen.GetInstance);
      LDm.OpenEinstellungen;
      Sag('Fenster offen', Assigned(frmEinstellungen));

      for I := 0 to 8 do
      begin
        LTabelle := LDm.TabelleFuerTab(I);
        LDs := LDm.DataSourceFuerTab(I);
        if (LTabelle = '') or (LDs = nil) then
        begin
          Sag(cReiter[I].Titel, False, 'kein Speicherweg hinterlegt');
          Continue;
        end;

        LName := 'ZZPruef ' + cReiter[I].Titel;

        // Anlegen
        LDs.DataSet.Append;
        LDs.DataSet.FieldByName(cReiter[I].Feld).AsString := LName;
        LMeldung := LDm.TypSpeichern(I);
        Sag(cReiter[I].Titel + ' anlegen',
            (LMeldung = '') and
            (Zaehle(LTabelle, cReiter[I].Feld, LName) = 1), LMeldung);

        // Aendern
        LDs.DataSet.Edit;
        LDs.DataSet.FieldByName(cReiter[I].Feld).AsString := LName + ' neu';
        LMeldung := LDm.TypSpeichern(I);
        Sag('   ... aendern',
            (LMeldung = '') and
            (Zaehle(LTabelle, cReiter[I].Feld, LName + ' neu') = 1) and
            (Zaehle(LTabelle, cReiter[I].Feld, LName) = 0), LMeldung);

        // Leere Bezeichnung
        LDs.DataSet.Edit;
        LDs.DataSet.FieldByName(cReiter[I].Feld).AsString := '   ';
        LMeldung := LDm.TypSpeichern(I);
        Sag('   ... leere Bezeichnung abgelehnt', LMeldung <> '');

        // Loeschen ueber das Fenster - der eigentliche Pruefpunkt
        LDs.DataSet.Locate(cReiter[I].Feld, LName + ' neu', []);
        LMeldung := LDm.TypLoeschen(I);
        Sag('   ... loeschen',
            (LMeldung = '') and
            (Zaehle(LTabelle, cReiter[I].Feld, LName + ' neu') = 0), LMeldung);

        // Reste, falls das Loeschen nicht griff
        LPruef.Close;
        LPruef.SQL.Text := Format('DELETE FROM %s WHERE %s LIKE ''ZZPruef %%''',
          [LTabelle, cReiter[I].Feld]);
        LPruef.ExecSQL;
      end;

      Writeln;
      if LFehler = 0 then Writeln('Alles in Ordnung.')
                     else Writeln(LFehler, ' Pruefung(en) fehlgeschlagen.');
    finally
      LPruef.Free;
    end;
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
