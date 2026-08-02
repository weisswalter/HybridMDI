unit LohnDm;

// Lohnmodul — Delphi-Seite.
//
// ARBEITSTEILUNG: Gerechnet wird in der DATENBANK (sql/person_lohn.sql und
// sql/lohn_erweiterung.sql). Dieses DataModule stoesst den Lauf an und liest
// das Ergebnis — es rechnet selbst KEINE Betraege aus. Grund: Die Rechnung
// haengt an Anwesenheit, Abwesenheit, Kursterminen und Beitragssaetzen; sie
// gehoert dorthin, wo diese Daten liegen, und muss auch fuer Auswertungen
// ausserhalb dieses Fensters gelten.
//
// Zentrale Funktionen:
//   fn_lohnlauf(mandant, jahr, monat)                  — alle Personen
//   fn_lohn_berechnen(mandant, person, jahr, monat)    — eine Person
// Beide sind wiederholbar: bereits freigegebene oder ausbezahlte Belege
// bleiben unangetastet.

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
  TdmLohn = class(TdmModuleTemplate)
    qryPerioden: TFDQuery;
    dsPerioden: TDataSource;
    qryPositionen: TFDQuery;
    dsPositionen: TDataSource;
    tblLohn: TFDTable;
    dsLohn: TDataSource;
    tblZulage: TFDTable;
    dsZulage: TDataSource;
    tblAbzug: TFDTable;
    dsAbzug: TDataSource;
    qryPersonen: TFDQuery;
    dsPersonen: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblLohnNewRecord(DataSet: TDataSet);
    procedure tblZulageNewRecord(DataSet: TDataSet);
    procedure tblAbzugNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    FPersonId: Integer;
    function Conn: TFDConnection;
  public
    class function GetInstance: TObject;
    procedure OpenLohn;

    property MandantId: Integer read FMandantId;
    property PersonId: Integer read FPersonId;

    // ── Anzeigen ──────────────────────────────────────────────────────────
    procedure LadePerioden(AJahr, AMonat: Integer);
    procedure LadePositionen(APeriodeId: Integer);
    // Bindet die Bearbeitungslisten an eine Person. 0 = alle des Mandanten.
    procedure WaehlePerson(APersonId: Integer);
    procedure LadeAbzuege;

    // ── Lohnlauf ──────────────────────────────────────────────────────────
    // Liefern 'OK: ...' oder 'FEHLER: ...'.
    function Lohnlauf(AJahr, AMonat: Integer): string;
    function LohnlaufPerson(APersonId, AJahr, AMonat: Integer): string;
    // Freigabe friert den Beleg ein: ein weiterer Lauf ueberschreibt ihn nicht
    // mehr. Genau dafuer ist der Status da.
    function StatusSetzen(APeriodeId: Integer; const AStatus: string): string;
    function PeriodeLoeschen(APeriodeId: Integer): string;

    // ── Bearbeiten ────────────────────────────────────────────────────────
    // Ein gemeinsamer Satz statt vier fast gleicher Methodenpaare.
    function SatzNeu(ADataSet: TDataSet): string;
    function SatzAendern(ADataSet: TDataSet): string;
    function SatzSpeichern(ADataSet: TDataSet): string;
    procedure SatzAbbrechen(ADataSet: TDataSet);
    function SatzLoeschen(ADataSet: TDataSet): string;

    // Sind fuer den Mandanten ueberhaupt Beitragssaetze hinterlegt? Wenn
    // nicht, rechnet der Lauf mit der Pauschale aus der Lohnvereinbarung —
    // das muss die Maske sagen, sonst wundert man sich ueber die Zahlen.
    function HatAbzugssaetze: Boolean;
  end;

var
  dmLohn: TdmLohn;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  LohnFrm;

class function TdmLohn.GetInstance: TObject;
begin
  Result := dmLohn;
end;

function TdmLohn.Conn: TFDConnection;
begin
  Result := PGManagerDm.dmPGManager.FDConnection1;
end;

procedure TdmLohn.DataModuleCreate(Sender: TObject);
begin
  qryPerioden.Connection   := Conn;
  qryPositionen.Connection := Conn;
  tblLohn.Connection       := Conn;
  tblZulage.Connection     := Conn;
  tblAbzug.Connection      := Conn;
  qryPersonen.Connection   := Conn;

  tblLohn.UpdateOptions.AutoIncFields   := 'lohn_id';
  tblZulage.UpdateOptions.AutoIncFields := 'zulage_id';
  tblAbzug.UpdateOptions.AutoIncFields  := 'abzugsart_id';

  // Die Uebersicht rechnet die Anstellungsart bereits aus (Lohnmitarbeiter /
  // Honorarlehrer) — deshalb die Sicht und nicht die Tabelle.
  qryPerioden.SQL.Text :=
    'SELECT * FROM v_lohn_uebersicht ' +
    'WHERE mandant_id = :m AND jahr = :j AND monat = :mo ' +
    'ORDER BY nachname_firmenname, vorname, lohnart';

  qryPositionen.SQL.Text :=
    'SELECT reihenfolge, art, code, bezeichnung, menge, einheit, satz, betrag ' +
    'FROM lohn_periode_position WHERE periode_id = :p ORDER BY reihenfolge';

  // Nur Personen, die als Mitarbeiter oder Lehrer gefuehrt sind. Die Flags
  // haengen an der QUELLperson — ueber ziel_person_id verknuepft bekaeme man
  // ausser der Hauptperson niemanden (siehe sql/person_lohn.sql).
  qryPersonen.SQL.Text :=
    'SELECT p.person_id, ' +
    '       p.nachname_firmenname || '', '' || COALESCE(p.vorname, '''') AS name, ' +
    '       CASE WHEN bool_or(pb.ist_lehrer) AND bool_or(pb.ist_mitarbeiter) ' +
    '                 THEN ''Lohnmitarbeiter'' ' +
    '            WHEN bool_or(pb.ist_lehrer) THEN ''Honorarlehrer'' ' +
    '            ELSE ''Mitarbeiter'' END AS anstellungsart ' +
    'FROM person p ' +
    'JOIN person_beziehung pb ON pb.quell_person_id = p.person_id ' +
    '                        AND pb.mandant_id = :m ' +
    'WHERE pb.ist_mitarbeiter OR pb.ist_lehrer ' +
    'GROUP BY p.person_id, p.nachname_firmenname, p.vorname ' +
    'ORDER BY 2';
end;

procedure TdmLohn.LadePerioden(AJahr, AMonat: Integer);
begin
  qryPerioden.Close;
  qryPerioden.ParamByName('m').AsInteger  := FMandantId;
  qryPerioden.ParamByName('j').AsInteger  := AJahr;
  qryPerioden.ParamByName('mo').AsInteger := AMonat;
  qryPerioden.Open;
end;

procedure TdmLohn.LadePositionen(APeriodeId: Integer);
begin
  qryPositionen.Close;
  qryPositionen.ParamByName('p').AsInteger := APeriodeId;
  qryPositionen.Open;
end;

// Filtern statt neu oeffnen: die Tabellen bleiben bearbeitbar, und der
// Anwender behaelt seine Position, wenn er zwischen Personen wechselt.
procedure TdmLohn.WaehlePerson(APersonId: Integer);
begin
  FPersonId := APersonId;

  tblLohn.Filtered := False;
  if not tblLohn.Active then
    tblLohn.Open;
  if APersonId > 0 then
    tblLohn.Filter := Format('mandant_id=%d and person_id=%d',
      [FMandantId, APersonId])
  else
    tblLohn.Filter := Format('mandant_id=%d', [FMandantId]);
  tblLohn.Filtered := True;

  tblZulage.Filtered := False;
  if not tblZulage.Active then
    tblZulage.Open;
  if APersonId > 0 then
    tblZulage.Filter := Format('mandant_id=%d and person_id=%d',
      [FMandantId, APersonId])
  else
    tblZulage.Filter := Format('mandant_id=%d', [FMandantId]);
  tblZulage.Filtered := True;
end;

procedure TdmLohn.LadeAbzuege;
begin
  tblAbzug.Filtered := False;
  if not tblAbzug.Active then
    tblAbzug.Open;
  tblAbzug.Filter := Format('mandant_id=%d', [FMandantId]);
  tblAbzug.Filtered := True;
end;

function TdmLohn.HatAbzugssaetze: Boolean;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT count(*) FROM lohn_abzugsart ' +
      'WHERE mandant_id = :m AND aktiv';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    Result := LQry.Fields[0].AsInteger > 0;
  finally
    LQry.Free;
  end;
end;

// ── Lohnlauf ────────────────────────────────────────────────────────────────

function TdmLohn.Lohnlauf(AJahr, AMonat: Integer): string;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_lohnlauf(:m, :j, :mo)';
    LQry.ParamByName('m').AsInteger  := FMandantId;
    LQry.ParamByName('j').AsInteger  := AJahr;
    LQry.ParamByName('mo').AsInteger := AMonat;
    LQry.Open;
    Result := Format('OK: %d Abrechnungen berechnet.', [LQry.Fields[0].AsInteger]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmLohn.LohnlaufPerson(APersonId, AJahr, AMonat: Integer): string;
var
  LQry: TFDQuery;
begin
  if APersonId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Person w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_lohn_berechnen(:m, :p, :j, :mo)';
    LQry.ParamByName('m').AsInteger  := FMandantId;
    LQry.ParamByName('p').AsInteger  := APersonId;
    LQry.ParamByName('j').AsInteger  := AJahr;
    LQry.ParamByName('mo').AsInteger := AMonat;
    LQry.Open;
    if LQry.Fields[0].AsInteger = 0 then
      Result := 'OK: Nichts zu berechnen - entweder gibt es f' + #252 +
        'r diesen Monat keine g' + #252 + 'ltige Lohnvereinbarung, oder der ' +
        'Beleg ist bereits freigegeben.'
    else
      Result := Format('OK: %d Abrechnung(en) berechnet.',
        [LQry.Fields[0].AsInteger]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmLohn.StatusSetzen(APeriodeId: Integer; const AStatus: string): string;
var
  LQry: TFDQuery;
begin
  if APeriodeId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Abrechnung w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text :=
      'UPDATE lohn_periode SET status = :s, ' +
      '       freigegeben_am = CASE WHEN :s2 = ''freigegeben'' THEN now() ' +
      '                             ELSE freigegeben_am END ' +
      ' WHERE periode_id = :p';
    LQry.ParamByName('s').AsString  := AStatus;
    LQry.ParamByName('s2').AsString := AStatus;
    LQry.ParamByName('p').AsInteger := APeriodeId;
    LQry.ExecSQL;
    Result := 'OK: Status auf "' + AStatus + '" gesetzt.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

// Nur solange nicht ausbezahlt — sonst verschwaende eine unbedachte Loeschung
// den Nachweis einer tatsaechlich geleisteten Zahlung.
function TdmLohn.PeriodeLoeschen(APeriodeId: Integer): string;
var
  LQry: TFDQuery;
begin
  if APeriodeId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Abrechnung w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'DELETE FROM lohn_periode ' +
      'WHERE periode_id = :p AND status <> ''ausbezahlt''';
    LQry.ParamByName('p').AsInteger := APeriodeId;
    LQry.ExecSQL;
    if LQry.RowsAffected = 0 then
      Result := 'FEHLER: Eine bereits ausbezahlte Abrechnung wird nicht ' +
        'gel' + #246 + 'scht.'
    else
      Result := 'OK: Abrechnung gel' + #246 + 'scht.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

// ── Bearbeiten ──────────────────────────────────────────────────────────────

procedure TdmLohn.tblLohnNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  if FPersonId > 0 then
    DataSet.FieldByName('person_id').AsInteger := FPersonId;
  DataSet.FieldByName('gueltig_ab').AsDateTime := Date;
  DataSet.FieldByName('lohnart').AsString := 'festgehalt';
  DataSet.FieldByName('bezug').AsString := 'monat';
  DataSet.FieldByName('betrag').AsFloat := 0;
  DataSet.FieldByName('waehrung').AsString := 'CHF';
  DataSet.FieldByName('ueberstunden').AsString := 'kompensation';
  DataSet.FieldByName('ueberstunden_faktor').AsFloat := 1.25;
  DataSet.FieldByName('lektion_minuten').AsInteger := 45;
end;

procedure TdmLohn.tblZulageNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  if FPersonId > 0 then
    DataSet.FieldByName('person_id').AsInteger := FPersonId;
  DataSet.FieldByName('art').AsString := 'zulage';
  DataSet.FieldByName('bezug').AsString := 'monat';
  DataSet.FieldByName('betrag').AsFloat := 0;
  DataSet.FieldByName('sozialpflichtig').AsBoolean := True;
  DataSet.FieldByName('gueltig_ab').AsDateTime := Date;
end;

procedure TdmLohn.tblAbzugNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('gueltig_ab').AsDateTime := Date;
  DataSet.FieldByName('prozent_an').AsFloat := 0;
  DataSet.FieldByName('prozent_ag').AsFloat := 0;
  DataSet.FieldByName('basis_ab').AsFloat := 0;
  DataSet.FieldByName('schwelle').AsFloat := 0;
  DataSet.FieldByName('aktiv').AsBoolean := True;
end;

function TdmLohn.SatzNeu(ADataSet: TDataSet): string;
begin
  Result := '';
  if (ADataSet = tblLohn) or (ADataSet = tblZulage) then
    if FPersonId <= 0 then
      Exit('Bitte zuerst links eine Person w' + #228 + 'hlen.');
  if not ADataSet.Active then
    Exit('Die Liste ist nicht ge' + #246 + 'ffnet.');
  ADataSet.Append;
end;

function TdmLohn.SatzAendern(ADataSet: TDataSet): string;
begin
  Result := '';
  if not ADataSet.Active or ADataSet.IsEmpty then
    Exit('Es gibt nichts zu ' + #228 + 'ndern.');
  ADataSet.Edit;
end;

// Die CHECK-Bedingungen der Datenbank in verstaendliche Saetze uebersetzen.
// Roh weitergereicht ("verletzt Check-Constraint person_lohn_art_bezug_check")
// kann damit niemand etwas anfangen.
function TdmLohn.SatzSpeichern(ADataSet: TDataSet): string;
begin
  Result := '';
  if not (ADataSet.State in dsEditModes) then
    Exit;
  try
    ADataSet.Post;
  except
    on E: Exception do
      if Pos('person_lohn_art_bezug_check', E.Message) > 0 then
        Result := 'Diese Kombination gibt es nicht: Festgehalt geht nur pro ' +
          'Monat oder pauschal, Stundenlohn nur pro Stunde, Honorar pro ' +
          'Stunde, Lektion, Termin oder pauschal.'
      else if Pos('person_lohn_kein_ueberlapp', E.Message) > 0 then
        Result := 'F' + #252 + 'r diesen Zeitraum gibt es bereits eine ' +
          'Vereinbarung derselben Lohnart. Bei einer Lohn' + #228 + 'nderung ' +
          'bitte die alte zuerst mit "g' + #252 + 'ltig bis" abschliessen.'
      else if Pos('lohn_zulage_einmalig_check', E.Message) > 0 then
        Result := 'Bei einer einmaligen Zulage m' + #252 + 'ssen Jahr und ' +
          'Monat angegeben werden.'
      else
        Result := E.Message;
  end;
end;

procedure TdmLohn.SatzAbbrechen(ADataSet: TDataSet);
begin
  if ADataSet.State in dsEditModes then
    ADataSet.Cancel;
end;

function TdmLohn.SatzLoeschen(ADataSet: TDataSet): string;
begin
  Result := '';
  if not ADataSet.Active or ADataSet.IsEmpty then
    Exit;
  try
    ADataSet.Delete;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

procedure TdmLohn.OpenLohn;
begin
  if not Conn.Connected then
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

  qryPersonen.Close;
  qryPersonen.ParamByName('m').AsInteger := FMandantId;
  qryPersonen.Open;

  WaehlePerson(0);
  LadeAbzuege;

  if not Assigned(frmLohn) then
    frmLohn := TfrmLohn.Create(Application);
  frmLohn.Show;
end;

end.
