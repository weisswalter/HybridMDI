program TestAnmeldung;
{$APPTYPE CONSOLE}
// Prueft das Benutzermodul: Konto fuer eine Person anlegen, Anmeldung mit
// Namen und mit markierter E-Mail, Anmeldepflicht ein- und ausschalten.
// Raeumt am Ende auf.
// Der MDI-Rahmen startet minimiert und ausserhalb des Bildschirms.
uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  Vcl.Forms, Vcl.Controls, FireDAC.Comp.Client,
  ZentraleDatenDm, MandantDm, BenutzerDm, BenutzerFrm;

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
  LDm: TdmBenutzer;
  LHilfe: TFDQuery;
  LFehler: Integer = 0;
  LPerson, LEmail: Integer;
  LAdressen: TStringList;
  LMarkiert: TList<Boolean>;
  LMeldung: string;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
var
  LZusatz: string;
begin
  if AText = '' then LZusatz := '' else LZusatz := '   ' + AText;
  Writeln(Format('%-46s %s%s', [ATitel, BoolToStr(AGut, True), LZusatz]));
  if not AGut then Inc(LFehler);
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TMdiRahmen, LRahmen);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;
    TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 1;

    LHilfe := TFDQuery.Create(nil);
    LAdressen := TStringList.Create;
    LMarkiert := TList<Boolean>.Create;
    try
      LHilfe.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

      // Reste eines abgebrochenen Laufs zuerst weg
      LHilfe.SQL.Text := 'DELETE FROM person_email WHERE email_id IN (SELECT email_id FROM emailadresse WHERE email_adresse LIKE ''zzpruef%'')';
      LHilfe.ExecSQL;
      LHilfe.SQL.Text := 'DELETE FROM emailadresse WHERE email_adresse LIKE ''zzpruef%''';
      LHilfe.ExecSQL;

      // Testadresse an die erste Person haengen
      LHilfe.SQL.Text := 'SELECT person_id FROM person ORDER BY person_id LIMIT 1';
      LHilfe.Open;
      LPerson := LHilfe.Fields[0].AsInteger;
      LHilfe.Close;

      LHilfe.SQL.Text :=
        'INSERT INTO emailadresse (email_adresse) VALUES (''zzpruef.anmeldung@example.org'') ' +
        'RETURNING email_id';
      LHilfe.Open;
      LEmail := LHilfe.Fields[0].AsInteger;
      LHilfe.Close;
      LHilfe.SQL.Text := Format(
        'INSERT INTO person_email (person_id, email_id, mandant_id) VALUES (%d, %d, 1)',
        [LPerson, LEmail]);
      LHilfe.ExecSQL;

      LDm := TdmBenutzer(TdmBenutzer.GetInstance);
      LDm.OpenBenutzer;
      Sag('Fenster offen', Assigned(frmBenutzer));

      Sag('Anmeldepflicht anfangs aus', not LDm.AnmeldungErforderlich);

      LMeldung := LDm.AnmeldepflichtSetzen(True);
      Sag('Einschalten ohne Konto abgelehnt', LMeldung <> '');

      // Konto fuer die Person
      LMeldung := LDm.BenutzerAnlegen('zzpruef.konto', 'Geheim123', LPerson, 1, 'benutzer');
      Sag('Konto fuer Person angelegt', LMeldung = '', LMeldung);

      LMeldung := LDm.Anmelden('zzpruef.konto', 'Geheim123');
      Sag('Anmeldung mit Namen', (LMeldung = '') and LDm.Angemeldet, LMeldung);
      LDm.Abmelden;

      // Adressen der Person - Konto im Gitter suchen
      LDm.LadeBenutzer;
      Sag('Konto im Gitter gefunden',
          LDm.qryBenutzer.Locate('anmeldename', 'zzpruef.konto', []));

      LDm.LadeAnmeldeAdressen(LAdressen, LMarkiert);
      Sag(Format('Adressen der Person (%d)', [LAdressen.Count]),
          LAdressen.IndexOf('zzpruef.anmeldung@example.org') >= 0,
          LAdressen.CommaText);

      LMeldung := LDm.Anmelden('zzpruef.anmeldung@example.org', 'Geheim123');
      Sag('E-Mail ohne Markierung geht nicht', LMeldung <> '');
      LDm.Abmelden;

      LMeldung := LDm.AnmeldeAdresseSetzen(LEmail, True);
      Sag('Adresse als Anmeldung markiert', LMeldung = '', LMeldung);

      LMeldung := LDm.Anmelden('ZZPruef.Anmeldung@Example.ORG', 'Geheim123');
      Sag('Anmeldung mit markierter E-Mail',
          (LMeldung = '') and LDm.Angemeldet, LMeldung);
      LDm.Abmelden;

      LMeldung := LDm.AnmeldepflichtSetzen(True);
      Sag('Anmeldepflicht ein', (LMeldung = '') and LDm.AnmeldungErforderlich, LMeldung);
      LMeldung := LDm.AnmeldepflichtSetzen(False);
      Sag('Anmeldepflicht aus trotz Konto',
          (LMeldung = '') and not LDm.AnmeldungErforderlich, LMeldung);

      // aufraeumen
      // Ein Befehl je Aufruf - FireDAC bereitet vor und kann dann nur einen.
      for LMeldung in TArray<string>.Create(
        'DELETE FROM systemeinstellung WHERE schluessel = ''ANMELDEPFLICHT''',
        'DELETE FROM benutzer_mandant WHERE benutzer_id IN (SELECT benutzer_id FROM benutzer WHERE anmeldename = ''zzpruef.konto'')',
        'DELETE FROM benutzer WHERE anmeldename = ''zzpruef.konto''',
        Format('DELETE FROM person_email WHERE email_id = %d', [LEmail]),
        Format('DELETE FROM emailadresse WHERE email_id = %d', [LEmail])) do
      begin
        LHilfe.SQL.Text := LMeldung;
        LHilfe.ExecSQL;
      end;
      Sag('aufgeraeumt', True);
    finally
      LHilfe.Free; LAdressen.Free; LMarkiert.Free;
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
