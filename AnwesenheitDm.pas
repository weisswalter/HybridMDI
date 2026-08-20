unit AnwesenheitDm;

// Anwesenheit / Zeiterfassung — DataModule.
//
// ZWEI ERFASSUNGSARTEN, EINE TAGESLISTE (siehe sql/zeiterfassung.sql):
//   'check'   Klienten — je Abschnitt des Rasters eine Zeile zum Abhaken.
//             Wie oft am Tag kontrolliert wird, ist Stammdatum
//             (erfassungsraster/raster_abschnitt), nicht Code.
//   'stempel' Lehrer   — kommen/gehen/Pause, minutengenau.
// Beide muenden ueber fn_tag_verdichten in anwesenheit_tag.
//
// Die Rechenregeln (Soll, Saldo, Ferienverbrauch, Beschneidung der Abschnitte
// an der Betriebszeit) stehen BEWUSST in der Datenbank
// (sql/zeiterfassung_views.sql). Diese Unit ruft nur Funktionen auf und
// uebersetzt DB-Fehler in verstaendliche Meldungen — die Pruefungen selbst
// werden nicht in Delphi nachgebaut, sonst gaebe es zwei Wahrheiten.

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
  TdmAnwesenheit = class(TdmModuleTemplate)
    qryTag: TFDQuery;
    dstblTag: TDataSource;
    qryCheck: TFDQuery;
    dstblCheck: TDataSource;
    qryStempel: TFDQuery;
    dstblStempel: TDataSource;
    qryAbwesenheit: TFDQuery;
    dstblAbwesenheit: TDataSource;
    qryRegime: TFDQuery;
    dstblRegime: TDataSource;
    qryMonat: TFDQuery;
    dstblMonat: TDataSource;
    qryFerien: TFDQuery;
    dstblFerien: TDataSource;
    qryPersonAuswahl: TFDQuery;
    dsPersonAuswahl: TDataSource;
    qryArtAuswahl: TFDQuery;
    dsArtAuswahl: TDataSource;
    qryRasterAuswahl: TFDQuery;
    dsRasterAuswahl: TDataSource;
    qryAdresseAuswahl: TFDQuery;
    dsAdresseAuswahl: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FMandantId: Integer;
    FDatum: TDate;
    FPersonId: Integer;
    function Ausfuehren(const ASql: string; const AParams: array of Variant): Integer;
    function SkalarInt(const ASql: string; const AParams: array of Variant): Integer;
  public
    class function GetInstance: TObject;
    property MandantId: Integer read FMandantId;
    property Datum: TDate read FDatum;
    property PersonId: Integer read FPersonId;

    procedure OpenAnwesenheit;

    procedure SetzeDatum(ADatum: TDate);
    procedure LadeTag;
    procedure LadeDetails(APersonId: Integer);
    procedure LadeMonat(APersonId, AJahr, AMonat: Integer);

    // Legt die Abschnittszeilen des Tages fuer alle Check-Personen an.
    // Feiertage, Wochenenden und Betriebsferien ueberspringt die DB von
    // selbst (Betriebszeit = 0). Rueckgabe: Klartext.
    function ListeErzeugen: string;
    // Schreibt Soll/Ist aller Personen des Tages fest.
    function VerdichtenAlle: string;
    procedure Verdichten(APersonId: Integer);
    function TagFreigeben(APersonId: Integer): string;

    // ── Check (Klienten) ─────────────────────────────────────────────────
    procedure CheckSetzen(ACheckId: Integer; AAnwesend, AEntschuldigt: Boolean;
      AArtId, AFehlminuten: Integer; const ABemerkung: string);
    // Setzt alle offenen Abschnitte der Person auf anwesend — der Regelfall,
    // damit der Betreuer nur die Ausnahmen anfassen muss.
    function AlleAnwesend(APersonId: Integer): Integer;

    // ── Stempel (Lehrer) ─────────────────────────────────────────────────
    function StempelSetzen(APersonId: Integer; const AArt: string;
      AZeitpunkt: TDateTime): string;
    procedure StempelEntfernen(AStempelId: Integer);

    // ── Abwesenheit ──────────────────────────────────────────────────────
    function AbwesenheitAnlegen(APersonId, AArtId: Integer;
      AVon, ABis: TDate; AHalbtags: Boolean; const ABemerkung: string): string;
    procedure AbwesenheitEntfernen(AId: Integer);
    procedure AbwesenheitGenehmigen(AId, AGenehmigerId: Integer);

    // ── Erfassungsregime ─────────────────────────────────────────────────
    function RegimeAnlegen(APersonId: Integer; AAb: TDate;
      const AErfassungsart: string; ARasterId: Integer; APensum: Double;
      AAdresseId: Integer): string;
    procedure RegimeBeenden(AId: Integer; ABis: TDate);
    procedure FerienAnspruchSetzen(APersonId, AJahr: Integer;
      ATage, AUebertrag: Double);
  end;

var
  dmAnwesenheit: TdmAnwesenheit;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs,
  MandantDm,
  AnwesenheitFrm, System.SyncObjs, ZentraleDatenDm;

var
  GSperreAnwesenheit: TCriticalSection;

class function TdmAnwesenheit.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmAnwesenheit) then
  begin
    GSperreAnwesenheit.Enter;
    try
      if not Assigned(dmAnwesenheit) then
        Application.CreateForm(TdmAnwesenheit, dmAnwesenheit);
    finally
      GSperreAnwesenheit.Leave;
    end;
  end;
  Result := dmAnwesenheit;
end;

procedure TdmAnwesenheit.DataModuleCreate(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TFDCustomQuery then
      TFDCustomQuery(Components[I]).Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung
    else if Components[I] is TFDTable then
      TFDTable(Components[I]).Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

  // Alle Listen kommen aus Datenbankfunktionen — kein Inline-Join hier.
  qryTag.SQL.Text          := 'SELECT * FROM fn_tagesliste(:m, :d)';
  qryCheck.SQL.Text        := 'SELECT * FROM fn_checkliste(:p, :d)';
  qryAbwesenheit.SQL.Text  := 'SELECT * FROM fn_abwesenheitsliste(:p)';
  qryRegime.SQL.Text       := 'SELECT * FROM fn_regimeliste(:p)';
  qryMonat.SQL.Text        := 'SELECT * FROM fn_monatsliste(:p, :j, :mo)';

  qryStempel.SQL.Text :=
    'SELECT stempel_id, zeitpunkt, art, quelle, bemerkung ' +
    'FROM v_zeit_stempel_tag WHERE person_id = :p AND datum = :d ' +
    'ORDER BY zeitpunkt';

  qryFerien.SQL.Text :=
    'SELECT jahr, tage_anspruch, tage_uebertrag, tage_bezogen, tage_rest ' +
    'FROM v_ferien_saldo WHERE person_id = :p ORDER BY jahr DESC';

  // ── Auswahllisten ──────────────────────────────────────────────────────
  qryPersonAuswahl.SQL.Text :=
    'SELECT p.person_id, CAST(p.nachname_firmenname || ' +
    '   CASE WHEN COALESCE(p.vorname,'''') <> '''' THEN '', '' || p.vorname ELSE '''' END ' +
    '   AS varchar(300)) AS anzeige ' +
    'FROM person p JOIN person_mandant pm ON pm.person_id = p.person_id ' +
    'WHERE pm.mandant_id = :m ORDER BY p.nachname_firmenname, p.vorname';

  qryArtAuswahl.SQL.Text :=
    'SELECT art_id, bezeichnung FROM abwesenheitsart ' +
    'WHERE mandant_id = :m AND aktiv ORDER BY bezeichnung';

  qryRasterAuswahl.SQL.Text :=
    'SELECT raster_id, bezeichnung FROM erfassungsraster ' +
    'WHERE mandant_id = :m AND aktiv ORDER BY bezeichnung';

  qryAdresseAuswahl.SQL.Text :=
    'SELECT adresse_id, CAST(COALESCE(strasse,'''') || '' '' || ' +
    '   COALESCE(hausnummer,'''') || '', '' || COALESCE(ort,'''') ' +
    '   AS varchar(300)) AS anzeige FROM adresse ORDER BY ort, strasse';

  FDatum := Date;
end;

function TdmAnwesenheit.Ausfuehren(const ASql: string;
  const AParams: array of Variant): Integer;
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

function TdmAnwesenheit.SkalarInt(const ASql: string;
  const AParams: array of Variant): Integer;
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
    LQry.Open;
    if LQry.IsEmpty or LQry.Fields[0].IsNull then
      Result := 0
    else
      Result := LQry.Fields[0].AsInteger;
  finally
    LQry.Free;
  end;
end;

// ── Laden ──────────────────────────────────────────────────────────────────

procedure TdmAnwesenheit.SetzeDatum(ADatum: TDate);
begin
  FDatum := ADatum;
  LadeTag;
end;

procedure TdmAnwesenheit.LadeTag;
var
  LVorher: Integer;
begin
  // Nach jedem Haken wird die Liste neu geladen. Ohne dieses Merken wuerde
  // die Auswahl dabei auf die erste Person zurueckspringen.
  LVorher := FPersonId;

  qryTag.Close;
  qryTag.ParamByName('m').AsInteger := FMandantId;
  qryTag.ParamByName('d').AsDate := FDatum;
  qryTag.Open;

  if qryTag.IsEmpty then
  begin
    LadeDetails(0);
    Exit;
  end;

  if (LVorher > 0) and qryTag.Locate('person_id', LVorher, []) then
    LadeDetails(LVorher)
  else
    LadeDetails(qryTag.FieldByName('person_id').AsInteger);
end;

procedure TdmAnwesenheit.LadeDetails(APersonId: Integer);
begin
  FPersonId := APersonId;

  qryCheck.Close;
  qryStempel.Close;
  qryAbwesenheit.Close;
  qryRegime.Close;
  qryFerien.Close;

  if APersonId <= 0 then
  begin
    qryMonat.Close;
    Exit;
  end;

  qryCheck.ParamByName('p').AsInteger := APersonId;
  qryCheck.ParamByName('d').AsDate := FDatum;
  qryCheck.Open;

  qryStempel.ParamByName('p').AsInteger := APersonId;
  qryStempel.ParamByName('d').AsDate := FDatum;
  qryStempel.Open;

  qryAbwesenheit.ParamByName('p').AsInteger := APersonId;
  qryAbwesenheit.Open;

  qryRegime.ParamByName('p').AsInteger := APersonId;
  qryRegime.Open;

  qryFerien.ParamByName('p').AsInteger := APersonId;
  qryFerien.Open;

  LadeMonat(APersonId, YearOf(FDatum), MonthOf(FDatum));
end;

procedure TdmAnwesenheit.LadeMonat(APersonId, AJahr, AMonat: Integer);
begin
  qryMonat.Close;
  if APersonId <= 0 then
    Exit;
  qryMonat.ParamByName('p').AsInteger := APersonId;
  qryMonat.ParamByName('j').AsInteger := AJahr;
  qryMonat.ParamByName('mo').AsInteger := AMonat;
  qryMonat.Open;
end;

// ── Tagesbetrieb ───────────────────────────────────────────────────────────

function TdmAnwesenheit.ListeErzeugen: string;
var
  LAnzahl: Integer;
begin
  LAnzahl := SkalarInt('SELECT fn_tagesliste_erzeugen(:m, :d)',
    [FMandantId, FDatum]);
  LadeTag;
  if LAnzahl = 0 then
    Result := Format('Für den %s wurden keine neuen Zeilen angelegt - ' +
      'entweder ist die Liste schon da, oder der Betrieb ist an diesem Tag ' +
      'geschlossen (Wochenende, Feiertag, Betriebsferien).',
      [FormatDateTime('dd.mm.yyyy', FDatum)])
  else
    Result := Format('%d Abschnittszeile(n) angelegt.', [LAnzahl]);
end;

function TdmAnwesenheit.VerdichtenAlle: string;
var
  LAnzahl: Integer;
begin
  LAnzahl := SkalarInt('SELECT fn_tag_verdichten_alle(:m, :d)',
    [FMandantId, FDatum]);
  LadeTag;
  Result := Format('%d Person(en) verdichtet. Bereits freigegebene Tage ' +
    'wurden nicht angefasst.', [LAnzahl]);
end;

procedure TdmAnwesenheit.Verdichten(APersonId: Integer);
begin
  if APersonId <= 0 then
    Exit;
  SkalarInt('SELECT 1 FROM (SELECT fn_tag_verdichten(:p, :d)) x',
    [APersonId, FDatum]);
  LadeTag;
end;

function TdmAnwesenheit.TagFreigeben(APersonId: Integer): string;
begin
  if APersonId <= 0 then
    Exit('Bitte zuerst eine Person wählen.');

  // Erst festschreiben, dann sperren — sonst wuerde ein noch nicht
  // verdichteter Tag mit Nullwerten eingefroren.
  SkalarInt('SELECT 1 FROM (SELECT fn_tag_verdichten(:p, :d)) x',
    [APersonId, FDatum]);

  if Ausfuehren(
    'UPDATE anwesenheit_tag SET status = ''freigegeben'', freigegeben_am = now() ' +
    'WHERE person_id = :p AND datum = :d', [APersonId, FDatum]) = 0 then
    Result := 'Für diesen Tag gibt es noch keine Erfassung.'
  else
    Result := Format('Der %s ist freigegeben und wird nicht mehr neu berechnet.',
      [FormatDateTime('dd.mm.yyyy', FDatum)]);
  LadeTag;
end;

// ── Check (Klienten) ───────────────────────────────────────────────────────

procedure TdmAnwesenheit.CheckSetzen(ACheckId: Integer;
  AAnwesend, AEntschuldigt: Boolean; AArtId, AFehlminuten: Integer;
  const ABemerkung: string);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text :=
      'UPDATE anwesenheit_check SET anwesend = :a, entschuldigt = :e, ' +
      '  art_id = :art, fehlminuten = :f, bemerkung = :b, erfasst_am = now() ' +
      'WHERE check_id = :c';
    LQry.ParamByName('a').AsBoolean := AAnwesend;
    LQry.ParamByName('e').AsBoolean := AEntschuldigt;
    if AArtId > 0 then
      LQry.ParamByName('art').AsInteger := AArtId
    else
      LQry.ParamByName('art').Clear;
    if AFehlminuten > 0 then
      LQry.ParamByName('f').AsInteger := AFehlminuten
    else
      LQry.ParamByName('f').Clear;
    LQry.ParamByName('b').AsString := ABemerkung;
    LQry.ParamByName('c').AsInteger := ACheckId;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
  Verdichten(FPersonId);
  LadeDetails(FPersonId);
end;

function TdmAnwesenheit.AlleAnwesend(APersonId: Integer): Integer;
begin
  Result := Ausfuehren(
    'UPDATE anwesenheit_check SET anwesend = true, entschuldigt = false, ' +
    '  erfasst_am = now() ' +
    'WHERE person_id = :p AND datum = :d AND NOT anwesend AND NOT entschuldigt',
    [APersonId, FDatum]);
  Verdichten(APersonId);
  LadeDetails(APersonId);
end;

// ── Stempel (Lehrer) ───────────────────────────────────────────────────────

function TdmAnwesenheit.StempelSetzen(APersonId: Integer; const AArt: string;
  AZeitpunkt: TDateTime): string;
begin
  Result := '';
  if APersonId <= 0 then
    Exit('Bitte zuerst eine Person wählen.');
  try
    Ausfuehren(
      'INSERT INTO zeit_stempel (mandant_id, person_id, zeitpunkt, art) ' +
      'VALUES (:m, :p, :z, :a)',
      [FMandantId, APersonId, AZeitpunkt, AArt]);
  except
    on E: Exception do
      if Pos('zeit_stempel_person_id_zeitpunkt_art_key', E.Message) > 0 then
        Result := 'Diesen Stempel gibt es zu dieser Uhrzeit bereits.'
      else
        Result := E.Message;
  end;
  if Result = '' then
  begin
    Verdichten(APersonId);
    LadeDetails(APersonId);
  end;
end;

procedure TdmAnwesenheit.StempelEntfernen(AStempelId: Integer);
begin
  Ausfuehren('DELETE FROM zeit_stempel WHERE stempel_id = :s', [AStempelId]);
  Verdichten(FPersonId);
  LadeDetails(FPersonId);
end;

// ── Abwesenheit ────────────────────────────────────────────────────────────

function TdmAnwesenheit.AbwesenheitAnlegen(APersonId, AArtId: Integer;
  AVon, ABis: TDate; AHalbtags: Boolean; const ABemerkung: string): string;
begin
  Result := '';
  if (APersonId <= 0) or (AArtId <= 0) then
    Exit('Bitte eine Person und einen Grund wählen.');
  if ABis < AVon then
    Exit('Das Bis-Datum liegt vor dem Von-Datum.');
  try
    // daterange '[]' — beide Enden einschliessend, wie es der Anwender erwartet
    Ausfuehren(
      'INSERT INTO abwesenheit (mandant_id, person_id, art_id, zeitraum, ' +
      '  halbtags, bemerkung) ' +
      'VALUES (:m, :p, :a, daterange(:von, :bis, ''[]''), :h, :b)',
      [FMandantId, APersonId, AArtId, AVon, ABis, AHalbtags, ABemerkung]);
  except
    on E: Exception do
      // Die Ueberlappungspruefung macht die Datenbank (EXCLUDE).
      if Pos('abwesenheit_person_id_zeitraum_excl', E.Message) > 0 then
        Result := 'In diesem Zeitraum ist für die Person bereits eine ' +
          'Abwesenheit erfasst - niemand kann gleichzeitig in den Ferien ' +
          'und krank sein.'
      else
        Result := E.Message;
  end;
  if Result = '' then
    LadeDetails(APersonId);
end;

procedure TdmAnwesenheit.AbwesenheitEntfernen(AId: Integer);
begin
  Ausfuehren('DELETE FROM abwesenheit WHERE abwesenheit_id = :a', [AId]);
  LadeDetails(FPersonId);
end;

procedure TdmAnwesenheit.AbwesenheitGenehmigen(AId, AGenehmigerId: Integer);
begin
  Ausfuehren(
    'UPDATE abwesenheit SET genehmigt_am = now(), genehmigt_von = :g ' +
    'WHERE abwesenheit_id = :a',
    [AGenehmigerId, AId]);
  LadeDetails(FPersonId);
end;

// ── Erfassungsregime ───────────────────────────────────────────────────────

function TdmAnwesenheit.RegimeAnlegen(APersonId: Integer; AAb: TDate;
  const AErfassungsart: string; ARasterId: Integer; APensum: Double;
  AAdresseId: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := '';
  if APersonId <= 0 then
    Exit('Bitte zuerst eine Person wählen.');
  if (AErfassungsart = 'check') and (ARasterId <= 0) then
    Exit('Für die Check-Erfassung muss ein Raster gewählt werden - es legt ' +
         'fest, wie oft am Tag kontrolliert wird.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text :=
      'INSERT INTO person_arbeitszeit (mandant_id, person_id, gueltig_ab, ' +
      '  erfassungsart, raster_id, pensum_prozent, adresse_id) ' +
      'VALUES (:m, :p, :ab, :art, :r, :pen, :adr)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('p').AsInteger := APersonId;
    LQry.ParamByName('ab').AsDate := AAb;
    LQry.ParamByName('art').AsString := AErfassungsart;
    if ARasterId > 0 then
      LQry.ParamByName('r').AsInteger := ARasterId
    else
      LQry.ParamByName('r').Clear;
    LQry.ParamByName('pen').AsFloat := APensum;
    if AAdresseId > 0 then
      LQry.ParamByName('adr').AsInteger := AAdresseId
    else
      LQry.ParamByName('adr').Clear;
    try
      LQry.ExecSQL;
    except
      on E: Exception do
        if Pos('person_arbeitszeit_person_id_mandant_id', E.Message) > 0 then
          Result := 'Für diesen Zeitraum gibt es bereits ein Regime. Bitte ' +
            'das bisherige zuerst beenden (Bis-Datum setzen).'
        else
          Result := E.Message;
    end;
  finally
    LQry.Free;
  end;

  if Result = '' then
  begin
    LadeDetails(APersonId);
    LadeTag;
  end;
end;

procedure TdmAnwesenheit.RegimeBeenden(AId: Integer; ABis: TDate);
begin
  Ausfuehren('UPDATE person_arbeitszeit SET gueltig_bis = :b ' +
    'WHERE arbeitszeit_id = :a', [ABis, AId]);
  LadeDetails(FPersonId);
  LadeTag;
end;

procedure TdmAnwesenheit.FerienAnspruchSetzen(APersonId, AJahr: Integer;
  ATage, AUebertrag: Double);
begin
  Ausfuehren(
    'INSERT INTO ferien_anspruch (mandant_id, person_id, jahr, tage_anspruch, ' +
    '  tage_uebertrag) VALUES (:m, :p, :j, :t, :u) ' +
    'ON CONFLICT (person_id, jahr) DO UPDATE SET tage_anspruch = :t2, ' +
    '  tage_uebertrag = :u2',
    [FMandantId, APersonId, AJahr, ATage, AUebertrag, ATage, AUebertrag]);
  LadeDetails(APersonId);
end;

// ── Start ──────────────────────────────────────────────────────────────────

procedure TdmAnwesenheit.OpenAnwesenheit;

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

  OeffneAuswahl(qryPersonAuswahl);
  OeffneAuswahl(qryArtAuswahl);
  OeffneAuswahl(qryRasterAuswahl);
  OeffneAuswahl(qryAdresseAuswahl);

  FDatum := Date;
  LadeTag;

  if not Assigned(frmAnwesenheit) then
    frmAnwesenheit := TfrmAnwesenheit.Create(Application);
  frmAnwesenheit.Show;
end;


initialization
  GSperreAnwesenheit := TCriticalSection.Create;

finalization
  GSperreAnwesenheit.Free;

end.
