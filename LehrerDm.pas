unit LehrerDm;

// Lehrermodul - DataModule. Aufbau analog MitarbeiterDm (siehe dort fuer die
// allgemeinen Konventionen): zwei lockstep-Tabellen person + person_beziehung,
// gemeinsam bearbeitet, dazu die Uebersichten.
//
// ANSTELLUNGSART wird ABGELEITET, nicht gespeichert (Walters Vorgabe
// 29.07.2026):
//   ist_lehrer und ist_mitarbeiter  -> Lohnmitarbeiter
//   ist_lehrer ohne ist_mitarbeiter -> Honorarlehrer
// Bewusst kein drittes Flag: sonst gaebe es drei Wahrheiten, die auseinander
// laufen koennen. Die Ableitung steht im SQL der Liste, damit sie an genau
// einer Stelle liegt.
//
// Kompetenzen kommen aus person_kompetenz und sind der Gegenpart zu
// kurs_kompetenz mit rolle='lehrer': erst daraus laesst sich beantworten,
// welcher Lehrer einen Kurs ueberhaupt halten darf.

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,
  udmModuleTemplate;

type
  TdmLehrer = class(TdmModuleTemplate)
    qryLehrer: TFDQuery;
    dstblLehrer: TDataSource;
    tblPerson: TFDTable;
    dstblPerson: TDataSource;
    tblPersonBeziehung: TFDTable;
    dstblPersonBeziehung: TDataSource;
    qryKompetenzen: TFDQuery;
    dstblKompetenzen: TDataSource;
    qryKompetenzAuswahl: TFDQuery;
    dsKompetenzAuswahl: TDataSource;
    qryKurse: TFDQuery;
    dstblKurse: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FMandantId: Integer;
    FPersonId: Integer;
    function Ausfuehren(const ASql: string; const AParams: array of Variant): Integer;
  public
    class function GetInstance: TObject;
    property MandantId: Integer read FMandantId;
    property PersonId: Integer read FPersonId;

    procedure OpenLehrer;
    procedure LadeListe;
    procedure LadeLehrer(APersonId, ABeziehungsId: Integer);

    procedure Bearbeiten;
    procedure Speichern;
    procedure Abbrechen;

    // Kompetenz eintragen. AGueltigBis = 0 heisst unbefristet; ist am
    // Kompetenztyp eine Gueltigkeitsdauer hinterlegt, wird sie aus
    // erworben_am hochgerechnet.
    function KompetenzHinzufuegen(AKompetenzId: Integer;
      AErworbenAm, AGueltigBis: TDate; const ABemerkung: string): string;
    procedure KompetenzEntfernen(APersonKompetenzId: Integer);
  end;

var
  dmLehrer: TdmLehrer;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  LehrerFrm;

class function TdmLehrer.GetInstance: TObject;
begin
  Result := dmLehrer;
end;

procedure TdmLehrer.DataModuleCreate(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TFDCustomQuery then
      TFDCustomQuery(Components[I]).Connection := PGManagerDm.dmPGManager.FDConnection1
    else if Components[I] is TFDTable then
      TFDTable(Components[I]).Connection := PGManagerDm.dmPGManager.FDConnection1;

  tblPerson.UpdateOptions.AutoIncFields          := 'person_id';
  tblPersonBeziehung.UpdateOptions.AutoIncFields := 'beziehungs_id';

  // Die Anstellungsart wird hier abgeleitet - siehe Unit-Kommentar.
  qryLehrer.SQL.Text :=
    'SELECT pb.beziehungs_id, p.person_id, p.vorname, p.nachname_firmenname, ' +
    '       p.titel, p.geburtsdatum, ' +
    '       CASE WHEN pb.ist_mitarbeiter THEN ''Lohnmitarbeiter'' ' +
    '            ELSE ''Honorarlehrer'' END AS anstellungsart, ' +
    '       rt.rollen_bezeichnung AS rolle_name, ' +
    '       (SELECT count(*) FROM person_kompetenz pk ' +
    '         WHERE pk.person_id = p.person_id AND pk.mandant_id = pb.mandant_id) AS kompetenzen ' +
    'FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
    'LEFT JOIN rolle_typ rt ON rt.mandant_id = pb.mandant_id AND rt.rolle_id = pb.rolle_id ' +
    'WHERE pb.mandant_id = :m AND pb.ist_lehrer = true ' +
    'ORDER BY p.nachname_firmenname, p.vorname';

  // Abgelaufene Nachweise sind der eigentliche Grund, warum das Modul
  // gebraucht wird - deshalb steht der Reststatus in der Liste.
  qryKompetenzen.SQL.Text :=
    'SELECT pk.person_kompetenz_id, pk.kompetenz_id, kt.bezeichnung, ' +
    '       kt.quelle, pk.erworben_am, pk.gueltig_bis, pk.bemerkung, ' +
    '       CASE WHEN pk.gueltig_bis IS NULL THEN ''unbefristet'' ' +
    '            WHEN pk.gueltig_bis < CURRENT_DATE THEN ''ABGELAUFEN'' ' +
    '            WHEN pk.gueltig_bis < CURRENT_DATE + 60 THEN ''laeuft bald ab'' ' +
    '            ELSE ''gueltig'' END AS status ' +
    'FROM person_kompetenz pk ' +
    'JOIN kompetenz_typ kt ON kt.mandant_id = pk.mandant_id ' +
    '                     AND kt.kompetenz_id = pk.kompetenz_id ' +
    'WHERE pk.person_id = :p AND pk.mandant_id = :m ' +
    'ORDER BY kt.bezeichnung';

  qryKompetenzAuswahl.SQL.Text :=
    'SELECT kompetenz_id, bezeichnung, gueltigkeit_monate FROM kompetenz_typ ' +
    'WHERE mandant_id = :m AND aktiv ORDER BY bezeichnung';

  // Welche Kurse darf dieser Lehrer halten? Gegenprobe zwischen den
  // Kompetenzen der Person und kurs_kompetenz mit rolle='lehrer'.
  qryKurse.SQL.Text :=
    'SELECT k.kurs_id, k.kurs_nr, k.bezeichnung, k.unterrichtsstunden, ' +
    '       count(kk.kompetenz_id) AS gefordert, ' +
    '       count(pk.kompetenz_id) AS vorhanden, ' +
    '       CASE WHEN count(kk.kompetenz_id) = count(pk.kompetenz_id) ' +
    '            THEN ''ja'' ELSE ''nein'' END AS darf_halten ' +
    'FROM kurs k ' +
    'LEFT JOIN kurs_kompetenz kk ON kk.kurs_id = k.kurs_id AND kk.rolle = ''lehrer'' ' +
    'LEFT JOIN person_kompetenz pk ON pk.kompetenz_id = kk.kompetenz_id ' +
    '                             AND pk.mandant_id = kk.mandant_id ' +
    '                             AND pk.person_id = :p ' +
    '                             AND (pk.gueltig_bis IS NULL OR pk.gueltig_bis >= CURRENT_DATE) ' +
    'WHERE k.mandant_id = :m AND k.aktiv ' +
    'GROUP BY k.kurs_id, k.kurs_nr, k.bezeichnung, k.unterrichtsstunden ' +
    'ORDER BY k.bezeichnung';
end;

function TdmLehrer.Ausfuehren(const ASql: string;
  const AParams: array of Variant): Integer;
var
  LQry: TFDQuery;
  I: Integer;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := ASql;
    for I := 0 to High(AParams) do
      LQry.Params[I].Value := AParams[I];
    LQry.ExecSQL;
    Result := LQry.RowsAffected;
  finally
    LQry.Free;
  end;
end;

// ── Laden ───────────────────────────────────────────────────────────────────

procedure TdmLehrer.LadeListe;
begin
  qryLehrer.Close;
  qryLehrer.ParamByName('m').AsInteger := FMandantId;
  qryLehrer.Open;

  if not qryLehrer.IsEmpty then
    LadeLehrer(qryLehrer.FieldByName('person_id').AsInteger,
               qryLehrer.FieldByName('beziehungs_id').AsInteger)
  else
    LadeLehrer(0, 0);
end;

procedure TdmLehrer.LadeLehrer(APersonId, ABeziehungsId: Integer);
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblPersonBeziehung.State in dsEditModes then tblPersonBeziehung.Cancel;

  FPersonId := APersonId;

  qryKompetenzen.Close;
  qryKurse.Close;

  if APersonId <= 0 then
    Exit;

  tblPerson.Locate('person_id', APersonId, []);
  if ABeziehungsId > 0 then
    tblPersonBeziehung.Locate('beziehungs_id', ABeziehungsId, []);

  qryKompetenzen.ParamByName('p').AsInteger := APersonId;
  qryKompetenzen.ParamByName('m').AsInteger := FMandantId;
  qryKompetenzen.Open;

  qryKurse.ParamByName('p').AsInteger := APersonId;
  qryKurse.ParamByName('m').AsInteger := FMandantId;
  qryKurse.Open;
end;

// ── Stammdaten ──────────────────────────────────────────────────────────────
// Angelegt werden Lehrer NICHT hier: eine Person entsteht im Personenmodul,
// hier wird nur das Haekchen "Lehrer" gesetzt. Das Modul zeigt und pflegt,
// es dupliziert die Personenanlage nicht.

procedure TdmLehrer.Bearbeiten;
begin
  if not tblPerson.IsEmpty then
    tblPerson.Edit;
end;

procedure TdmLehrer.Speichern;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Post;
  if tblPersonBeziehung.State in dsEditModes then
    tblPersonBeziehung.Post;
  LadeListe;
end;

procedure TdmLehrer.Abbrechen;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Cancel;
  if tblPersonBeziehung.State in dsEditModes then
    tblPersonBeziehung.Cancel;
end;

// ── Kompetenzen ─────────────────────────────────────────────────────────────

function TdmLehrer.KompetenzHinzufuegen(AKompetenzId: Integer;
  AErworbenAm, AGueltigBis: TDate; const ABemerkung: string): string;
var
  LQry: TFDQuery;
begin
  Result := '';
  if FPersonId <= 0 then
    Exit('Bitte zuerst einen Lehrer w' + #228 + 'hlen.');
  if AKompetenzId <= 0 then
    Exit('Bitte eine Kompetenz w' + #228 + 'hlen.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    // Ist am Typ eine Gueltigkeitsdauer hinterlegt und kein Enddatum
    // angegeben, rechnet die Datenbank es aus dem Erwerbsdatum hoch - so
    // steht die Regel an einer Stelle und nicht in jeder Maske neu.
    LQry.SQL.Text :=
      'INSERT INTO person_kompetenz (mandant_id, person_id, kompetenz_id, ' +
      '  erworben_am, gueltig_bis, bemerkung) ' +
      'SELECT :m, :p, :k, :e, ' +
      '       COALESCE(:g, CASE WHEN kt.gueltigkeit_monate IS NULL THEN NULL ' +
      '                         ELSE (:e2::date + (kt.gueltigkeit_monate || '' months'')::interval)::date ' +
      '                    END), :b ' +
      'FROM kompetenz_typ kt WHERE kt.mandant_id = :m2 AND kt.kompetenz_id = :k2';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('p').AsInteger := FPersonId;
    LQry.ParamByName('k').AsInteger := AKompetenzId;
    LQry.ParamByName('e').AsDate := AErworbenAm;
    if AGueltigBis > 0 then
      LQry.ParamByName('g').AsDate := AGueltigBis
    else
      LQry.ParamByName('g').Clear;
    LQry.ParamByName('e2').AsDate := AErworbenAm;
    LQry.ParamByName('b').AsString := ABemerkung;
    LQry.ParamByName('m2').AsInteger := FMandantId;
    LQry.ParamByName('k2').AsInteger := AKompetenzId;
    try
      LQry.ExecSQL;
    except
      on E: Exception do
        if Pos('person_kompetenz_person_id_kompetenz_id_erworben_am_key', E.Message) > 0 then
          Result := 'Diese Kompetenz ist mit demselben Erwerbsdatum bereits ' +
                    'eingetragen.'
        else
          Result := E.Message;
    end;
  finally
    LQry.Free;
  end;

  if Result = '' then
    LadeLehrer(FPersonId, 0);
end;

procedure TdmLehrer.KompetenzEntfernen(APersonKompetenzId: Integer);
begin
  Ausfuehren('DELETE FROM person_kompetenz WHERE person_kompetenz_id = :i',
    [APersonKompetenzId]);
  LadeLehrer(FPersonId, 0);
end;

// ── Start ───────────────────────────────────────────────────────────────────

procedure TdmLehrer.OpenLehrer;
begin
  if not PGManagerDm.dmPGManager.FDConnection1.Connected then
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

  tblPerson.Filtered := False;
  tblPerson.Open;

  tblPersonBeziehung.Filtered := False;
  tblPersonBeziehung.Open;
  tblPersonBeziehung.Filter := Format('mandant_id=%d', [FMandantId]);
  tblPersonBeziehung.Filtered := True;

  qryKompetenzAuswahl.Close;
  qryKompetenzAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryKompetenzAuswahl.Open;

  LadeListe;

  if not Assigned(frmLehrer) then
    frmLehrer := TfrmLehrer.Create(Application);
  frmLehrer.Show;
end;

end.
