unit KursDm;

// Kursmodul — DataModule.
//
// AUFBAU (siehe sql/kurs.sql): Curriculum und Durchfuehrung sind getrennt.
//   tblKurs              = WAS gelehrt wird (Lernziele, Stunden, Material,
//                          Unterkurse, Kompetenzen) — ueber Jahre gleich
//   qryDurchfuehrungen   = die konkrete Runde (Semester, Leiter, Raum)
//   qryTermine           = Stundenplan der gewaehlten Durchfuehrung
//   qryTeilnehmer        = Anmeldungen dieser Durchfuehrung
//
// Doppelbelegung von Raum und Lehrer verhindert die DATENBANK
// (EXCLUDE-Constraints). Diese Unit faengt den Fehler nur ab und uebersetzt
// ihn in eine verstaendliche Meldung — die Pruefung selbst wird bewusst NICHT
// in Delphi nachgebaut, sonst gaebe es zwei Wahrheiten.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.DateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmKurs = class(TdmModuleTemplate)
    tblKurs: TFDMemTable;
    dstblKurs: TDataSource;
    qryUnterkurse: TFDQuery;
    dstblUnterkurse: TDataSource;
    qryKompetenzen: TFDQuery;
    dstblKompetenzen: TDataSource;
    qryMaterial: TFDQuery;
    dstblMaterial: TDataSource;
    qryDurchfuehrungen: TFDQuery;
    dstblDurchfuehrungen: TDataSource;
    qryTermine: TFDQuery;
    dstblTermine: TDataSource;
    qryTeilnehmer: TFDQuery;
    dstblTeilnehmer: TDataSource;
    qryKursAuswahl: TFDQuery;
    dsKursAuswahl: TDataSource;
    qryKompetenzAuswahl: TFDQuery;
    dsKompetenzAuswahl: TDataSource;
    qryArtikelAuswahl: TFDQuery;
    dsArtikelAuswahl: TDataSource;
    qryLehrerAuswahl: TFDQuery;
    dsLehrerAuswahl: TDataSource;
    qryRaumAuswahl: TFDQuery;
    dsRaumAuswahl: TDataSource;
    qrySemesterAuswahl: TFDQuery;
    dsSemesterAuswahl: TDataSource;
    qryPersonAuswahl: TFDQuery;
    dsPersonAuswahl: TDataSource;
    qryBelegung: TFDQuery;
    dsBelegung: TDataSource;
    qryRaumEignung: TFDQuery;
    dsRaumEignung: TDataSource;
    qryLehrerEignung: TFDQuery;
    dsLehrerEignung: TDataSource;
    qryBaukasten: TFDQuery;
    dsBaukasten: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblKursNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    function Ausfuehren(const ASql: string; const AParams: array of Variant): Integer;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    property MandantId: Integer read FMandantId;
    procedure OpenKurs;

    procedure LadeDetails(AKursId: Integer);
    procedure LadeDurchfuehrungsdetails(ADurchfuehrungId: Integer);

    // Alle Termine des Mandanten an einem Tag - Grundlage der Gantt-Ansicht
    // im Reiter "Termine". Bewusst ALLE, nicht nur die dieser Durchfuehrung:
    // erst dadurch sieht man, ob Leiter oder Raum schon anderweitig verplant
    // sind. Der Tag wird um plus/minus einen Tag erweitert, damit Termine
    // ueber Mitternacht vollstaendig erfasst werden.
    procedure LadeBelegung(ADatum: TDate);

    // Eignung fuer ein konkretes Zeitfenster: welcher Raum und welcher
    // Lehrer kommt fuer diesen Kurs in Frage, und warum nicht. Die
    // Regeln stehen in fn_raum_auswahl / fn_lehrer_auswahl - inklusive
    // Mehrzweckraeumen, die sich mit freiem mobilem Inventar nachruesten
    // lassen. Hier wird nur aufgerufen, nicht nachgerechnet.
    procedure LadeEignung(AKursId: Integer; AVon, ABis: TDateTime);

    // Baukasten als BAUM (fn_kurs_baukasten): flaches, nach Pfad
    // sortiertes Ergebnis mit Ebenenangabe. Ein Baum aus N Einzelabfragen
    // waere bei jeder Ebene ein Rundlauf zur Datenbank.
    procedure LadeBaukasten(AKursId: Integer);

    procedure UnterkursHinzufuegen(AKursId, AUnterKursId: Integer; APflicht: Boolean);
    procedure UnterkursEntfernen(AKursId, AUnterKursId: Integer);
    procedure KompetenzHinzufuegen(AKursId, AKompetenzId: Integer; const ARolle: string);
    procedure KompetenzEntfernen(AKursId, AKompetenzId: Integer; const ARolle: string);
    procedure MaterialHinzufuegen(AKursId, AArtikelId: Integer;
      APauschal, AProTeilnehmer: Double; ARueckgabe: Boolean);
    procedure MaterialEntfernen(AKursId, AArtikelId: Integer);

    function DurchfuehrungAnlegen(AKursId, ASemesterId, ALeiterId, ARaumId: Integer;
      const ABezeichnung: string): Integer;
    procedure TeilnehmerHinzufuegen(ADurchfuehrungId, APersonId: Integer);
    procedure TeilnehmerEntfernen(ADurchfuehrungId, APersonId: Integer);

    // Legt einen Einzeltermin an. Raum/Leiter werden aus der Durchfuehrung
    // MATERIALISIERT (kopiert), nicht per NULL vererbt — sonst greifen die
    // EXCLUDE-Constraints nicht.
    // Rueckgabe: '' bei Erfolg, sonst die Konfliktmeldung.
    function TerminAnlegen(ADurchfuehrungId: Integer; AVon, ABis: TDateTime;
      const AThema: string): string;
    // Serie: erzeugt ATermine Termine im Abstand von AWochen. Kollisionen
    // werden gesammelt zurueckgegeben, die uebrigen Termine trotzdem angelegt.
    function SerieAnlegen(ADurchfuehrungId: Integer; AStart: TDateTime;
      ADauerMinuten, AAnzahl, AWochenAbstand: Integer;
      const AThema: string): string;
    procedure TerminEntfernen(ATerminId: Integer);

    // Erzeugt aus v_kurs_materialbedarf einen Entnahme-Beleg (belegart
    // 'Entnahme') fuer den Kursleiter. Rueckgabe: Klartext-Ergebnis.
    function EntnahmeErzeugen(ADurchfuehrungId: Integer): string;
  end;

var
  dmKurs: TdmKurs;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  KursFrm, System.SyncObjs;

var
  GSperreKurs: TCriticalSection;

class function TdmKurs.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmKurs) then
  begin
    GSperreKurs.Enter;
    try
      if not Assigned(dmKurs) then
        Application.CreateForm(TdmKurs, dmKurs);
    finally
      GSperreKurs.Leave;
    end;
  end;
  Result := dmKurs;
end;

procedure TdmKurs.DataModuleCreate(Sender: TObject);
var
  I: Integer;
begin
  // Alle Datasets an die zentrale Connection
  for I := 0 to ComponentCount - 1 do
    // Nur Abfragen brauchen eine Verbindung, Speichertabellen nicht
    if Components[I] is TFDCustomQuery then
      TFDCustomQuery(Components[I]).Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

  tblKurs.UpdateOptions.AutoIncFields := 'kurs_id';

  qryUnterkurse.SQL.Text :=
    'SELECT kk.unter_kurs_id, kk.position, kk.pflicht, ' +
    '       k.kurs_nr, k.bezeichnung, k.unterrichtsstunden ' +
    'FROM kurs_kurs kk JOIN kurs k ON k.kurs_id = kk.unter_kurs_id ' +
    'WHERE kk.kurs_id = :k ORDER BY kk.position NULLS LAST, k.bezeichnung';

  qryKompetenzen.SQL.Text :=
    'SELECT kk.kompetenz_id, kk.rolle, kt.bezeichnung, kt.gueltigkeit_monate, kt.quelle ' +
    'FROM kurs_kompetenz kk ' +
    'JOIN kompetenz_typ kt ON kt.mandant_id = kk.mandant_id AND kt.kompetenz_id = kk.kompetenz_id ' +
    'WHERE kk.kurs_id = :k ORDER BY kk.rolle, kt.bezeichnung';

  qryMaterial.SQL.Text :=
    'SELECT m.artikel_id, a.artikel_nr, a.artikelname, ' +
    '       m.menge_pauschal, m.menge_pro_teilnehmer, m.rueckgabe_erwartet ' +
    'FROM kurs_material m JOIN artikel a ON a.artikel_id = m.artikel_id ' +
    'WHERE m.kurs_id = :k ORDER BY a.artikelname';

  qryDurchfuehrungen.SQL.Text :=
    'SELECT d.durchfuehrung_id, d.bezeichnung, d.status, d.von_datum, d.bis_datum, ' +
    '       s.bezeichnung AS semester, p.nachname_firmenname AS leiter, ' +
    '       r.bezeichnung AS raum, ' +
    '       (SELECT count(*) FROM kurs_teilnehmer t ' +
    '         WHERE t.durchfuehrung_id = d.durchfuehrung_id) AS teilnehmer ' +
    'FROM kurs_durchfuehrung d ' +
    'LEFT JOIN semester s ON s.semester_id = d.semester_id ' +
    'LEFT JOIN person p   ON p.person_id   = d.leiter_person_id ' +
    'LEFT JOIN raum r     ON r.raum_id     = d.raum_id ' +
    'WHERE d.kurs_id = :k ORDER BY d.von_datum DESC NULLS LAST';

  qryTermine.SQL.Text :=
    'SELECT t.termin_id, lower(t.zeitraum) AS beginn, upper(t.zeitraum) AS ende, ' +
    '       t.thema, t.status, r.bezeichnung AS raum, ' +
    '       p.nachname_firmenname AS leiter ' +
    'FROM kurs_termin t ' +
    'LEFT JOIN raum r   ON r.raum_id   = t.raum_id ' +
    'LEFT JOIN person p ON p.person_id = t.leiter_person_id ' +
    'WHERE t.durchfuehrung_id = :d ORDER BY lower(t.zeitraum)';

  qryTeilnehmer.SQL.Text :=
    'SELECT tn.person_id, p.vorname, p.nachname_firmenname, tn.status, ' +
    '       tn.angemeldet_am, tn.note ' +
    'FROM kurs_teilnehmer tn JOIN person p ON p.person_id = tn.person_id ' +
    'WHERE tn.durchfuehrung_id = :d ORDER BY p.nachname_firmenname, p.vorname';

  // ── Auswahllisten ────────────────────────────────────────────────────────
  qryKursAuswahl.SQL.Text :=
    'SELECT kurs_id, bezeichnung FROM kurs WHERE mandant_id = :m AND aktiv ' +
    'ORDER BY bezeichnung';
  qryKompetenzAuswahl.SQL.Text :=
    'SELECT kompetenz_id, bezeichnung FROM kompetenz_typ ' +
    'WHERE mandant_id = :m AND aktiv ORDER BY bezeichnung';
  qryArtikelAuswahl.SQL.Text :=
    'SELECT artikel_id, artikelname FROM artikel WHERE mandant_id = :m ' +
    'ORDER BY artikelname';
  // Lehrer: ueber die Beziehung zur Hauptperson (ist_lehrer)
  qryLehrerAuswahl.SQL.Text :=
    'SELECT p.person_id, p.nachname_firmenname FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
    'WHERE pb.mandant_id = :m AND pb.ist_lehrer = true ' +
    'ORDER BY p.nachname_firmenname';
  qryRaumAuswahl.SQL.Text :=
    'SELECT r.raum_id, CAST(COALESCE(r.bezeichnung, ''Raum '' || r.raum_id) || ' +
    '   '' ('' || COALESCE(a.strasse, '''') || '' '' || COALESCE(a.ort, '''') || '')'' ' +
    '   AS varchar(300)) AS anzeige ' +
    'FROM raum r LEFT JOIN adresse a ON a.adresse_id = r.adresse_id ' +
    'ORDER BY r.bezeichnung';
  qrySemesterAuswahl.SQL.Text :=
    'SELECT semester_id, bezeichnung FROM semester WHERE mandant_id = :m ' +
    'ORDER BY von_datum DESC NULLS LAST';
  qryBaukasten.SQL.Text := 'SELECT * FROM fn_kurs_baukasten(:k)';

  qryRaumEignung.SQL.Text :=
    'SELECT * FROM fn_raum_auswahl(:k, :von, :bis)';
  qryLehrerEignung.SQL.Text :=
    'SELECT * FROM fn_lehrer_auswahl(:m, :k, :von, :bis)';

  qryBelegung.SQL.Text :=
    'SELECT t.termin_id, t.durchfuehrung_id, t.raum_id, t.leiter_person_id, ' +
    '       lower(t.zeitraum) AS beginn, upper(t.zeitraum) AS ende, ' +
    '       t.thema, t.status, ' +
    '       k.bezeichnung AS kurs, d.bezeichnung AS durchfuehrung, ' +
    '       r.bezeichnung AS raum, ' +
    '       p.nachname_firmenname AS leiter ' +
    'FROM kurs_termin t ' +
    'JOIN kurs_durchfuehrung d ON d.durchfuehrung_id = t.durchfuehrung_id ' +
    'JOIN kurs k ON k.kurs_id = d.kurs_id ' +
    'LEFT JOIN raum r   ON r.raum_id   = t.raum_id ' +
    'LEFT JOIN person p ON p.person_id = t.leiter_person_id ' +
    'WHERE t.mandant_id = :m ' +
    '  AND t.zeitraum && tstzrange(:von, :bis) ' +
    'ORDER BY lower(t.zeitraum)';

  // Teilnehmer koennen alle Personen des Mandanten sein (Klienten,
  // Mitarbeiter in Weiterbildung, Gaeste)
  qryPersonAuswahl.SQL.Text :=
    'SELECT p.person_id, CAST(p.nachname_firmenname || ' +
    '   CASE WHEN COALESCE(p.vorname,'''') <> '''' THEN '', '' || p.vorname ELSE '''' END ' +
    '   AS varchar(300)) AS anzeige ' +
    'FROM person p JOIN person_mandant pm ON pm.person_id = p.person_id ' +
    'WHERE pm.mandant_id = :m ORDER BY p.nachname_firmenname, p.vorname';
end;

procedure TdmKurs.tblKursNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('aktiv').AsBoolean := True;
end;

function TdmKurs.Ausfuehren(const ASql: string; const AParams: array of Variant): Integer;
var
  LQry: TFDQuery;
  I: Integer;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := ASql;
    for I := 0 to High(AParams) do
      LQry.Params[I].Value := AParams[I];
    LQry.ExecSQL;
    Result := LQry.RowsAffected;
  finally
    LQry.Free;
  end;
end;

procedure TdmKurs.LadeDetails(AKursId: Integer);

  procedure Lade(AQry: TFDQuery; const APar: string; AWert: Integer);
  begin
    AQry.Close;
    AQry.ParamByName(APar).AsInteger := AWert;
    AQry.Open;
  end;

begin
  Lade(qryUnterkurse,      'k', AKursId);
  LadeBaukasten(AKursId);
  Lade(qryKompetenzen,     'k', AKursId);
  Lade(qryMaterial,        'k', AKursId);
  Lade(qryDurchfuehrungen, 'k', AKursId);
  // Termine/Teilnehmer haengen an der Durchfuehrung, nicht am Kurs
  if not qryDurchfuehrungen.IsEmpty then
    LadeDurchfuehrungsdetails(qryDurchfuehrungen.FieldByName('durchfuehrung_id').AsInteger)
  else
  begin
    qryTermine.Close;
    qryTeilnehmer.Close;
  end;
end;

procedure TdmKurs.LadeBelegung(ADatum: TDate);
begin
  qryBelegung.Close;
  qryBelegung.ParamByName('m').AsInteger := FMandantId;
  // Ein Tag Puffer nach beiden Seiten, damit Termine ueber Mitternacht
  // vollstaendig hereinkommen und nicht abgeschnitten erscheinen.
  qryBelegung.ParamByName('von').AsDateTime := Trunc(ADatum) - 1;
  qryBelegung.ParamByName('bis').AsDateTime := Trunc(ADatum) + 2;
  qryBelegung.Open;
end;

procedure TdmKurs.LadeBaukasten(AKursId: Integer);
begin
  qryBaukasten.Close;
  if AKursId <= 0 then
    Exit;
  qryBaukasten.ParamByName('k').AsInteger := AKursId;
  qryBaukasten.Open;
end;

procedure TdmKurs.LadeEignung(AKursId: Integer; AVon, ABis: TDateTime);
begin
  qryRaumEignung.Close;
  qryLehrerEignung.Close;
  if (AKursId <= 0) or (ABis <= AVon) then
    Exit;

  qryRaumEignung.ParamByName('k').AsInteger := AKursId;
  qryRaumEignung.ParamByName('von').AsDateTime := AVon;
  qryRaumEignung.ParamByName('bis').AsDateTime := ABis;
  qryRaumEignung.Open;

  qryLehrerEignung.ParamByName('m').AsInteger := FMandantId;
  qryLehrerEignung.ParamByName('k').AsInteger := AKursId;
  qryLehrerEignung.ParamByName('von').AsDateTime := AVon;
  qryLehrerEignung.ParamByName('bis').AsDateTime := ABis;
  qryLehrerEignung.Open;
end;

procedure TdmKurs.LadeDurchfuehrungsdetails(ADurchfuehrungId: Integer);
begin
  qryTermine.Close;
  qryTermine.ParamByName('d').AsInteger := ADurchfuehrungId;
  qryTermine.Open;

  qryTeilnehmer.Close;
  qryTeilnehmer.ParamByName('d').AsInteger := ADurchfuehrungId;
  qryTeilnehmer.Open;
end;

// ── Curriculum-Bausteine ───────────────────────────────────────────────────

procedure TdmKurs.UnterkursHinzufuegen(AKursId, AUnterKursId: Integer; APflicht: Boolean);
begin
  if AKursId = AUnterKursId then
    raise Exception.Create('Ein Kurs kann sich nicht selbst als Unterkurs enthalten.');
  Ausfuehren(
    'INSERT INTO kurs_kurs (kurs_id, unter_kurs_id, mandant_id, position, pflicht) ' +
    'VALUES (:a, :b, :m, (SELECT COALESCE(MAX(position),0)+1 FROM kurs_kurs WHERE kurs_id=:a2), :p) ' +
    'ON CONFLICT DO NOTHING',
    [AKursId, AUnterKursId, FMandantId, AKursId, APflicht]);
  LadeDetails(AKursId);
end;

procedure TdmKurs.UnterkursEntfernen(AKursId, AUnterKursId: Integer);
begin
  Ausfuehren('DELETE FROM kurs_kurs WHERE kurs_id=:a AND unter_kurs_id=:b',
    [AKursId, AUnterKursId]);
  LadeDetails(AKursId);
end;

procedure TdmKurs.KompetenzHinzufuegen(AKursId, AKompetenzId: Integer; const ARolle: string);
begin
  Ausfuehren(
    'INSERT INTO kurs_kompetenz (kurs_id, kompetenz_id, mandant_id, rolle) ' +
    'VALUES (:k, :c, :m, :r) ON CONFLICT DO NOTHING',
    [AKursId, AKompetenzId, FMandantId, ARolle]);
  LadeDetails(AKursId);
end;

procedure TdmKurs.KompetenzEntfernen(AKursId, AKompetenzId: Integer; const ARolle: string);
begin
  Ausfuehren('DELETE FROM kurs_kompetenz WHERE kurs_id=:k AND kompetenz_id=:c AND rolle=:r',
    [AKursId, AKompetenzId, ARolle]);
  LadeDetails(AKursId);
end;

procedure TdmKurs.MaterialHinzufuegen(AKursId, AArtikelId: Integer;
  APauschal, AProTeilnehmer: Double; ARueckgabe: Boolean);
begin
  Ausfuehren(
    'INSERT INTO kurs_material (kurs_id, artikel_id, mandant_id, menge_pauschal, ' +
    '  menge_pro_teilnehmer, rueckgabe_erwartet) VALUES (:k, :a, :m, :p, :t, :r) ' +
    'ON CONFLICT (kurs_id, artikel_id) DO UPDATE SET menge_pauschal = :p2, ' +
    '  menge_pro_teilnehmer = :t2, rueckgabe_erwartet = :r2',
    [AKursId, AArtikelId, FMandantId, APauschal, AProTeilnehmer, ARueckgabe,
     APauschal, AProTeilnehmer, ARueckgabe]);
  LadeDetails(AKursId);
end;

procedure TdmKurs.MaterialEntfernen(AKursId, AArtikelId: Integer);
begin
  Ausfuehren('DELETE FROM kurs_material WHERE kurs_id=:k AND artikel_id=:a',
    [AKursId, AArtikelId]);
  LadeDetails(AKursId);
end;

// ── Durchfuehrung, Termine, Teilnehmer ─────────────────────────────────────

function TdmKurs.DurchfuehrungAnlegen(AKursId, ASemesterId, ALeiterId, ARaumId: Integer;
  const ABezeichnung: string): Integer;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text :=
      'INSERT INTO kurs_durchfuehrung (kurs_id, mandant_id, semester_id, ' +
      '  bezeichnung, leiter_person_id, raum_id) ' +
      'VALUES (:k, :m, :s, :b, :l, :r) RETURNING durchfuehrung_id';
    LQry.ParamByName('k').AsInteger := AKursId;
    LQry.ParamByName('m').AsInteger := FMandantId;
    if ASemesterId > 0 then LQry.ParamByName('s').AsInteger := ASemesterId
                       else LQry.ParamByName('s').Clear;
    LQry.ParamByName('b').AsString := ABezeichnung;
    if ALeiterId > 0 then LQry.ParamByName('l').AsInteger := ALeiterId
                     else LQry.ParamByName('l').Clear;
    if ARaumId > 0 then LQry.ParamByName('r').AsInteger := ARaumId
                   else LQry.ParamByName('r').Clear;
    LQry.Open;
    Result := LQry.Fields[0].AsInteger;
  finally
    LQry.Free;
  end;
  LadeDetails(AKursId);
end;

procedure TdmKurs.TeilnehmerHinzufuegen(ADurchfuehrungId, APersonId: Integer);
begin
  Ausfuehren(
    'INSERT INTO kurs_teilnehmer (durchfuehrung_id, person_id, mandant_id) ' +
    'VALUES (:d, :p, :m) ON CONFLICT DO NOTHING',
    [ADurchfuehrungId, APersonId, FMandantId]);
  LadeDurchfuehrungsdetails(ADurchfuehrungId);
end;

procedure TdmKurs.TeilnehmerEntfernen(ADurchfuehrungId, APersonId: Integer);
begin
  Ausfuehren('DELETE FROM kurs_teilnehmer WHERE durchfuehrung_id=:d AND person_id=:p',
    [ADurchfuehrungId, APersonId]);
  LadeDurchfuehrungsdetails(ADurchfuehrungId);
end;

function TdmKurs.TerminAnlegen(ADurchfuehrungId: Integer; AVon, ABis: TDateTime;
  const AThema: string): string;
begin
  Result := '';
  try
    // Raum und Leiter aus der Durchfuehrung KOPIEREN — nicht per NULL erben,
    // sonst greifen die EXCLUDE-Constraints nicht.
    Ausfuehren(
      'INSERT INTO kurs_termin (durchfuehrung_id, mandant_id, zeitraum, ' +
      '  raum_id, leiter_person_id, thema) ' +
      'SELECT d.durchfuehrung_id, d.mandant_id, tstzrange(:von, :bis), ' +
      '       d.raum_id, d.leiter_person_id, :thema ' +
      'FROM kurs_durchfuehrung d WHERE d.durchfuehrung_id = :d',
      [AVon, ABis, AThema, ADurchfuehrungId]);
  except
    on E: Exception do
      // Die Kollisionspruefung macht die Datenbank; hier nur uebersetzen.
      if Pos('ex_kurs_termin_raum', E.Message) > 0 then
        Result := Format('Der Raum ist am %s bereits belegt.',
          [FormatDateTime('dd.mm.yyyy hh:nn', AVon)])
      else if Pos('ex_kurs_termin_leiter', E.Message) > 0 then
        Result := Format('Der Kursleiter ist am %s bereits verplant.',
          [FormatDateTime('dd.mm.yyyy hh:nn', AVon)])
      else
        Result := E.Message;
  end;
  if Result = '' then
    LadeDurchfuehrungsdetails(ADurchfuehrungId);
end;

function TdmKurs.SerieAnlegen(ADurchfuehrungId: Integer; AStart: TDateTime;
  ADauerMinuten, AAnzahl, AWochenAbstand: Integer; const AThema: string): string;
var
  I, LOk: Integer;
  LVon, LBis: TDateTime;
  LFehler, LMeldung: string;
begin
  LOk := 0;
  LFehler := '';
  for I := 0 to AAnzahl - 1 do
  begin
    LVon := IncWeek(AStart, I * AWochenAbstand);
    LBis := IncMinute(LVon, ADauerMinuten);
    LMeldung := TerminAnlegen(ADurchfuehrungId, LVon, LBis, AThema);
    if LMeldung = '' then
      Inc(LOk)
    else
      LFehler := LFehler + sLineBreak + '  ' + LMeldung;
  end;
  Result := Format('%d von %d Terminen angelegt.', [LOk, AAnzahl]);
  if LFehler <> '' then
    Result := Result + sLineBreak + 'Nicht angelegt:' + LFehler;
  LadeDurchfuehrungsdetails(ADurchfuehrungId);
end;

procedure TdmKurs.TerminEntfernen(ATerminId: Integer);
var
  LDf: Integer;
begin
  LDf := 0;
  if qryTermine.Active and not qryTermine.IsEmpty then
    LDf := qryTermine.ParamByName('d').AsInteger;
  Ausfuehren('DELETE FROM kurs_termin WHERE termin_id=:t', [ATerminId]);
  if LDf > 0 then
    LadeDurchfuehrungsdetails(LDf);
end;

// ── Materialbedarf -> Entnahme-Beleg ───────────────────────────────────────
// Nutzt v_kurs_materialbedarf (Curriculum-Material x bestaetigte Teilnehmer)
// und legt daraus einen Beleg mit belegart 'Entnahme' an — dasselbe
// Format, das LagerEntnahmeFrm anzeigt und verbucht.
function TdmKurs.EntnahmeErzeugen(ADurchfuehrungId: Integer): string;
var
  LQry: TFDQuery;
  LBelegId, LTypId, LLeiter, LPos: Integer;
  LFehlmenge: string;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

    // Kursleiter als Belegperson
    LQry.SQL.Text := 'SELECT leiter_person_id FROM kurs_durchfuehrung WHERE durchfuehrung_id=:d';
    LQry.ParamByName('d').AsInteger := ADurchfuehrungId;
    LQry.Open;
    if LQry.IsEmpty or LQry.Fields[0].IsNull then
      Exit('Der Durchführung ist kein Kursleiter zugeordnet — ' +
           'ohne ihn kann keine Entnahme gebucht werden.');
    LLeiter := LQry.Fields[0].AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'SELECT rechnungstyp_id FROM rechnungstyp ' +
      'WHERE mandant_id=:m AND bezeichnung=''Entnahme''';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    if LQry.IsEmpty then
      Exit('Der Rechnungstyp "Entnahme" fehlt — bitte in den Einstellungen anlegen.');
    LTypId := LQry.Fields[0].AsInteger;
    LQry.Close;

    // Beleg-Kopf
    LQry.SQL.Text :=
      'INSERT INTO beleg (mandant_id, belegart, rechnungstyp_id, person_id, ' +
      '  bemerkung, durchfuehrung_id) ' +
      'VALUES (:m, ''Entnahme'', :t, :p, :b, :d) RETURNING beleg_id';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('t').AsInteger := LTypId;
    LQry.ParamByName('p').AsInteger := LLeiter;
    LQry.ParamByName('b').AsString  := 'Kursmaterial, automatisch erzeugt';
    LQry.ParamByName('d').AsInteger := ADurchfuehrungId;
    LQry.Open;
    LBelegId := LQry.Fields[0].AsInteger;
    LQry.Close;

    // Positionen aus der Bedarfssicht
    LQry.SQL.Text :=
      'SELECT artikel_id, artikelname, einheit_id, rueckgabe_erwartet, ' +
      '       bedarf, bestand_gesamt ' +
      'FROM v_kurs_materialbedarf WHERE durchfuehrung_id=:d AND bedarf > 0';
    LQry.ParamByName('d').AsInteger := ADurchfuehrungId;
    LQry.Open;

    LPos := 0;
    LFehlmenge := '';
    while not LQry.Eof do
    begin
      Inc(LPos);
      Ausfuehren(
        'INSERT INTO beleg_position (mandant_id, beleg_id, position_nr, ' +
        '  artikel_id, menge, einheit_id, rueckgabe_erwartet) ' +
        'VALUES (:m, :b, :p, :a, :menge, :e, :r)',
        [FMandantId, LBelegId, LPos,
         LQry.FieldByName('artikel_id').AsInteger,
         LQry.FieldByName('bedarf').AsFloat,
         LQry.FieldByName('einheit_id').AsVariant,
         LQry.FieldByName('rueckgabe_erwartet').AsBoolean]);

      // Fehlmengen melden — daraus wird spaeter der Nachbestellvorschlag
      if LQry.FieldByName('bedarf').AsFloat > LQry.FieldByName('bestand_gesamt').AsFloat then
        LFehlmenge := LFehlmenge + sLineBreak +
          Format('  %s: benötigt %.2f, vorhanden %.2f',
            [LQry.FieldByName('artikelname').AsString,
             LQry.FieldByName('bedarf').AsFloat,
             LQry.FieldByName('bestand_gesamt').AsFloat]);
      LQry.Next;
    end;
    LQry.Close;

    if LPos = 0 then
      Exit('Für diesen Kurs ist kein Material hinterlegt (oder keine ' +
           'bestätigten Teilnehmer) — es wurde ein leerer Beleg angelegt.');

    Result := Format('Entnahme-Beleg mit %d Position(en) angelegt.', [LPos]);
    if LFehlmenge <> '' then
      Result := Result + sLineBreak + sLineBreak +
        'ACHTUNG, Bestand reicht nicht:' + LFehlmenge + sLineBreak + sLineBreak +
        'Bitte über "Lief.-Bestellung" nachbestellen.';
  finally
    LQry.Free;
  end;
end;

procedure TdmKurs.OpenKurs;

  procedure OeffneAuswahl(AQry: TFDQuery);
  begin
    AQry.Close;
    if AQry.Params.FindParam('m') <> nil then
      AQry.ParamByName('m').AsInteger := FMandantId;
    AQry.Open;
  end;

begin
  if not TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung.Connected then
  begin
    ShowMessage('Bitte zuerst im PGManager die Datenbankverbindung herstellen.', '');
    Exit;
  end;

  FMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
  if FMandantId <= 0 then
  begin
    ShowMessage('Bitte zuerst oben im Hauptfenster einen Mandanten w'#228'hlen.', '');
    Exit;
  end;

  tblKurs.Filtered := False;
  // Speichertabellen kommen aus dem zentralen Datenmodul
  TabellenLaden;
  tblKurs.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKurs.Filtered := True;

  OeffneAuswahl(qryKursAuswahl);
  OeffneAuswahl(qryKompetenzAuswahl);
  OeffneAuswahl(qryArtikelAuswahl);
  OeffneAuswahl(qryLehrerAuswahl);
  OeffneAuswahl(qryRaumAuswahl);
  OeffneAuswahl(qrySemesterAuswahl);
  OeffneAuswahl(qryPersonAuswahl);

  if not tblKurs.IsEmpty then
    LadeDetails(tblKurs.FieldByName('kurs_id').AsInteger);

  if not Assigned(frmKurs) then
    frmKurs := TfrmKurs.Create(Application);
  frmKurs.Show;
end;


procedure TdmKurs.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblKurs, 'kurs')]);
end;



initialization
  GSperreKurs := TCriticalSection.Create;

finalization
  GSperreKurs.Free;

end.
