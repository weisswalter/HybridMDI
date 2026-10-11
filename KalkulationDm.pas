unit KalkulationDm;

// Kalkulation — Delphi-Seite.
//
// Gerechnet wird in der Datenbank (sql/kalkulation.sql). Dieses DataModule
// legt Kalkulationen an, befuellt sie aus Stueckliste, Lohn und Anlagen und
// stoesst fn_kalkulation_rechnen an.
//
// Hier wohnen auch die STAMMDATEN der Kostenrechnung (Kostenarten,
// Kostenstellen, Zuschlagssaetze, Konten). Sie liegen bewusst in diesem
// Fenster und nicht in einem eigenen: Sie werden selten gepflegt, gehoeren
// fachlich zur Kalkulation, und ein eigenes Modul fuer vier Listen waere
// mehr Verwaltung als Nutzen. Sobald das Buchhaltungsmodul kommt, wandern
// die Konten dorthin.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
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
  TdmKalkulation = class(TdmModuleTemplate)
    tblKalkulation: TFDMemTable;
    dsKalkulation: TDataSource;
    tblPosition: TFDMemTable;
    dsPosition: TDataSource;
    qryBlatt: TFDQuery;
    dsBlatt: TDataSource;
    tblZuschlag: TFDMemTable;
    dsZuschlag: TDataSource;
    tblKostenart: TFDMemTable;
    dsKostenart: TDataSource;
    tblKostenstelle: TFDMemTable;
    dsKostenstelle: TDataSource;
    tblKonto: TFDMemTable;
    dsKonto: TDataSource;
    qryKontoLookup: TFDQuery;
    dsKontoLookup: TDataSource;
    qryArtikel: TFDQuery;
    dsArtikel: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblKalkulationAfterScroll(DataSet: TDataSet);
    procedure tblPositionNewRecord(DataSet: TDataSet);
    procedure tblZuschlagNewRecord(DataSet: TDataSet);
    procedure tblKostenartNewRecord(DataSet: TDataSet);
    procedure tblKostenstelleNewRecord(DataSet: TDataSet);
    procedure tblKontoNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    function Conn: TFDConnection;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    procedure OpenKalkulation;
    property MandantId: Integer read FMandantId;

    function AktuelleKalkulation: Integer;
    procedure LadeDetails(AKalkulationId: Integer);

    // Alle liefern 'OK: ...' / 'FEHLER: ...'
    function Neu(const ABezeichnung: string; AJahr: Integer; AMenge: Double;
      AArtikelId: Integer): string;
    function Rechnen(AKalkulationId: Integer): string;
    function MaterialUebernehmen(AKalkulationId: Integer): string;
    function LohnUebernehmen(AKalkulationId, APersonId: Integer;
      AStunden: Double): string;
    function MaschineUebernehmen(AKalkulationId, AAnlageId: Integer;
      AStunden: Double): string;
    function StatusSetzen(AKalkulationId: Integer; const AStatus: string): string;
    function KalkulationLoeschen(AKalkulationId: Integer): string;
    // Zuschlagssaetze fuer das Jahr aus den Kostenstellen ermitteln
    function SaetzeErmitteln(AJahr: Integer; AMaterial, ALoehne,
      AHerstellkosten: Double): string;
    function KontenrahmenAnlegen: string;
    function StandardKostenarten: string;

    function SatzNeu(ADataSet: TDataSet): string;
    function SatzAendern(ADataSet: TDataSet): string;
    function SatzSpeichern(ADataSet: TDataSet): string;
    procedure SatzAbbrechen(ADataSet: TDataSet);
    function SatzLoeschen(ADataSet: TDataSet): string;
  end;

var
  dmKalkulation: TdmKalkulation;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm, uGridMemo,
  System.DateUtils,
  Vcl.Dialogs,
  MandantDm,
  KalkulationFrm, System.SyncObjs;

var
  GSperreKalkulation: TCriticalSection;

class function TdmKalkulation.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmKalkulation) then
  begin
    GSperreKalkulation.Enter;
    try
      if not Assigned(dmKalkulation) then
        Application.CreateForm(TdmKalkulation, dmKalkulation);
    finally
      GSperreKalkulation.Leave;
    end;
  end;
  Result := dmKalkulation;
end;

function TdmKalkulation.Conn: TFDConnection;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
end;

procedure TdmKalkulation.DataModuleCreate(Sender: TObject);
begin
  qryBlatt.Connection        := Conn;
  qryKontoLookup.Connection  := Conn;
  qryArtikel.Connection      := Conn;

  tblKalkulation.UpdateOptions.AutoIncFields  := 'kalkulation_id';
  tblPosition.UpdateOptions.AutoIncFields     := 'position_id';
  tblZuschlag.UpdateOptions.AutoIncFields     := 'satz_id';
  tblKostenart.UpdateOptions.AutoIncFields    := 'kostenart_id';
  tblKostenstelle.UpdateOptions.AutoIncFields := 'kostenstelle_id';
  tblKonto.UpdateOptions.AutoIncFields        := 'konto_id';

  // Das Blatt kommt fertig aufbereitet aus der Datenbank — hier wird nichts
  // nachgerechnet, damit Anzeige und Rechnung nicht auseinanderlaufen.
  qryBlatt.SQL.Text := 'SELECT * FROM fn_kalkulation_blatt(:k)';
  // fn_kalkulation_blatt.bezeichnung ist Postgres 'text' - ohne das haette
  // das Gitter dort nur "(WIDEMEMO)" gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(qryBlatt);

  qryKontoLookup.SQL.Text :=
    'SELECT konto_id, nummer || '' '' || bezeichnung AS anzeige ' +
    'FROM konto WHERE mandant_id = :m AND aktiv AND NOT ist_sammelkonto ' +
    'ORDER BY nummer';

  qryArtikel.SQL.Text :=
    'SELECT artikel_id, artikel_nr || '' - '' || artikelname AS anzeige ' +
    'FROM artikel WHERE mandant_id = :m ORDER BY artikel_nr';
end;

function TdmKalkulation.AktuelleKalkulation: Integer;
begin
  if tblKalkulation.Active and not tblKalkulation.IsEmpty then
    Result := tblKalkulation.FieldByName('kalkulation_id').AsInteger
  else
    Result := 0;
end;

procedure TdmKalkulation.LadeDetails(AKalkulationId: Integer);
begin
  tblPosition.Filtered := False;
  if not tblPosition.Active then
    // Speichertabellen kommen aus dem zentralen Datenmodul
    TabellenLaden;
  tblPosition.Filter := Format('kalkulation_id=%d', [AKalkulationId]);
  tblPosition.Filtered := True;

  qryBlatt.Close;
  qryBlatt.ParamByName('k').AsInteger := AKalkulationId;
  qryBlatt.Open;
end;

procedure TdmKalkulation.tblKalkulationAfterScroll(DataSet: TDataSet);
begin
  if tblKalkulation.Active and not (tblKalkulation.State in dsEditModes) then
    LadeDetails(AktuelleKalkulation);
end;

// ── Kalkulation anlegen und rechnen ─────────────────────────────────────────

function TdmKalkulation.Neu(const ABezeichnung: string; AJahr: Integer;
  AMenge: Double; AArtikelId: Integer): string;
var
  LQry: TFDQuery;
  LId: Integer;
begin
  if Trim(ABezeichnung) = '' then
    Exit('FEHLER: Bitte eine Bezeichnung angeben.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kalkulation_neu(:m, :b, :j, :menge, :a)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('b').AsString := ABezeichnung;
    LQry.ParamByName('j').AsInteger := AJahr;
    LQry.ParamByName('menge').AsFloat := AMenge;
    if AArtikelId > 0 then
      LQry.ParamByName('a').AsInteger := AArtikelId
    else
      LQry.ParamByName('a').Clear;
    LQry.Open;
    LId := LQry.Fields[0].AsInteger;
    Result := Format('OK: Kalkulation %d angelegt. Die Zuschlagss'#228'tze des ' +
      'Jahres %d wurden '#252'bernommen und eingefroren.', [LId, AJahr]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;

  // Speichertabelle neu aus dem zentralen Bestand holen

  TabellenLaden;
  if tblKalkulation.Locate('kalkulation_id', LId, []) then
    LadeDetails(LId);
end;

function TdmKalkulation.Rechnen(AKalkulationId: Integer): string;
var
  LQry: TFDQuery;
begin
  if AKalkulationId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Kalkulation w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kalkulation_rechnen(:k)';
    LQry.ParamByName('k').AsInteger := AKalkulationId;
    LQry.Open;
    Result := Format('OK: Angebotspreis %.2f', [LQry.Fields[0].AsFloat]);
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    LadeDetails(AKalkulationId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.MaterialUebernehmen(AKalkulationId: Integer): string;
var
  LQry: TFDQuery;
begin
  if AKalkulationId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Kalkulation w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kalkulation_material(:k)';
    LQry.ParamByName('k').AsInteger := AKalkulationId;
    LQry.Open;
    Result := Format('OK: %d Materialpositionen aus der St'#252'ckliste ' +
      #252'bernommen. Positionen ohne hinterlegten Preis sind in der ' +
      'Bemerkung gekennzeichnet.', [LQry.Fields[0].AsInteger]);
    LadeDetails(AKalkulationId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.LohnUebernehmen(AKalkulationId, APersonId: Integer;
  AStunden: Double): string;
var
  LQry: TFDQuery;
begin
  if (AKalkulationId <= 0) or (APersonId <= 0) then
    Exit('FEHLER: Bitte Kalkulation und Person w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kalkulation_lohn(:k, :p, :s)';
    LQry.ParamByName('k').AsInteger := AKalkulationId;
    LQry.ParamByName('p').AsInteger := APersonId;
    LQry.ParamByName('s').AsFloat := AStunden;
    LQry.Open;
    Result := Format('OK: %.2f als Fertigungslohn '#252'bernommen ' +
      '(einschliesslich Sozialleistungen).', [LQry.Fields[0].AsFloat]);
    LadeDetails(AKalkulationId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.MaschineUebernehmen(AKalkulationId, AAnlageId: Integer;
  AStunden: Double): string;
var
  LQry: TFDQuery;
begin
  if (AKalkulationId <= 0) or (AAnlageId <= 0) then
    Exit('FEHLER: Bitte Kalkulation und Anlage w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kalkulation_maschine(:k, :a, :s)';
    LQry.ParamByName('k').AsInteger := AKalkulationId;
    LQry.ParamByName('a').AsInteger := AAnlageId;
    LQry.ParamByName('s').AsFloat := AStunden;
    LQry.Open;
    Result := Format('OK: %.2f Maschinenkosten '#252'bernommen.',
      [LQry.Fields[0].AsFloat]);
    LadeDetails(AKalkulationId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.StatusSetzen(AKalkulationId: Integer;
  const AStatus: string): string;
var
  LQry: TFDQuery;
begin
  if AKalkulationId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Kalkulation w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'UPDATE kalkulation SET status = :s WHERE kalkulation_id = :k';
    LQry.ParamByName('s').AsString := AStatus;
    LQry.ParamByName('k').AsInteger := AKalkulationId;
    LQry.ExecSQL;
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    if AStatus = 'freigegeben' then
      Result := 'OK: Freigegeben. Die Kalkulation wird jetzt nicht mehr neu ' +
        'gerechnet - so bleibt ein hinausgegangenes Angebot nachvollziehbar.'
    else
      Result := 'OK: Status auf "' + AStatus + '" gesetzt.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.KalkulationLoeschen(AKalkulationId: Integer): string;
var
  LQry: TFDQuery;
begin
  if AKalkulationId <= 0 then
    Exit('');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    // Positionen haengen mit ON DELETE CASCADE dran
    LQry.SQL.Text := 'DELETE FROM kalkulation WHERE kalkulation_id = :k';
    LQry.ParamByName('k').AsInteger := AKalkulationId;
    LQry.ExecSQL;
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    LadeDetails(AktuelleKalkulation);
    Result := 'OK: Kalkulation gel' + #246 + 'scht.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.SaetzeErmitteln(AJahr: Integer; AMaterial, ALoehne,
  AHerstellkosten: Double): string;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text :=
      'SELECT fn_zuschlagssaetze_ermitteln(:m, :j, :mat, :loe, :hk)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('j').AsInteger := AJahr;
    if AMaterial > 0 then
      LQry.ParamByName('mat').AsFloat := AMaterial
    else
      LQry.ParamByName('mat').Clear;
    if ALoehne > 0 then
      LQry.ParamByName('loe').AsFloat := ALoehne
    else
      LQry.ParamByName('loe').Clear;
    if AHerstellkosten > 0 then
      LQry.ParamByName('hk').AsFloat := AHerstellkosten
    else
      LQry.ParamByName('hk').Clear;
    LQry.Open;
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    Result := Format('OK: %d Bereiche ermittelt. Von Hand gesetzte S'#228'tze ' +
      'bleiben unver'#228'ndert.', [LQry.Fields[0].AsInteger]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.KontenrahmenAnlegen: string;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kontenrahmen_kmu(:m)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    qryKontoLookup.Close;
    qryKontoLookup.Open;
    Result := Format('OK: %d Konten erg'#228'nzt. Vorhandene bleiben unver'#228'ndert.',
      [LQry.Fields[0].AsInteger]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmKalkulation.StandardKostenarten: string;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_kostenarten_standard(:m)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    // Speichertabelle neu aus dem zentralen Bestand holen
    TabellenLaden;
    Result := Format('OK: %d Kostenarten und -stellen erg'#228'nzt.',
      [LQry.Fields[0].AsInteger]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

// ── Neue Saetze vorbelegen ──────────────────────────────────────────────────

procedure TdmKalkulation.tblPositionNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('kalkulation_id').AsInteger := AktuelleKalkulation;
  DataSet.FieldByName('art').AsString := 'material';
  DataSet.FieldByName('menge').AsFloat := 1;
  DataSet.FieldByName('satz').AsFloat := 0;
  DataSet.FieldByName('betrag').AsFloat := 0;
end;

procedure TdmKalkulation.tblZuschlagNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('jahr').AsInteger := YearOf(Date);
  DataSet.FieldByName('bereich').AsString := 'material';
  DataSet.FieldByName('prozent').AsFloat := 0;
  // Von Hand angelegt heisst: nicht von der Ermittlung ueberschreiben
  DataSet.FieldByName('manuell').AsBoolean := True;
end;

procedure TdmKalkulation.tblKostenartNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('typ').AsString := 'gemein';
  DataSet.FieldByName('verhalten').AsString := 'fix';
  DataSet.FieldByName('variabler_anteil_prozent').AsFloat := 0;
  DataSet.FieldByName('kalkulatorisch').AsBoolean := False;
  DataSet.FieldByName('aktiv').AsBoolean := True;
end;

procedure TdmKalkulation.tblKostenstelleNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('art').AsString := 'haupt';
  DataSet.FieldByName('bereich').AsString := 'allgemein';
  DataSet.FieldByName('aktiv').AsBoolean := True;
end;

procedure TdmKalkulation.tblKontoNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('typ').AsString := 'aufwand';
  DataSet.FieldByName('ist_sammelkonto').AsBoolean := False;
  DataSet.FieldByName('aktiv').AsBoolean := True;
end;

// ── Bearbeiten ──────────────────────────────────────────────────────────────

function TdmKalkulation.SatzNeu(ADataSet: TDataSet): string;
begin
  Result := '';
  if not ADataSet.Active then
    Exit('Die Liste ist nicht ge' + #246 + 'ffnet.');
  if (ADataSet = tblPosition) and (AktuelleKalkulation = 0) then
    Exit('Bitte zuerst links eine Kalkulation w' + #228 + 'hlen.');
  ADataSet.Append;
end;

function TdmKalkulation.SatzAendern(ADataSet: TDataSet): string;
begin
  Result := '';
  if not ADataSet.Active or ADataSet.IsEmpty then
    Exit('Es gibt nichts zu ' + #228 + 'ndern.');
  ADataSet.Edit;
end;

function TdmKalkulation.SatzSpeichern(ADataSet: TDataSet): string;
begin
  Result := '';
  if not (ADataSet.State in dsEditModes) then
    Exit;
  try
    ADataSet.Post;
  except
    on E: Exception do
      if Pos('kostenart_kalk_ohne_konto', E.Message) > 0 then
        Result := 'Eine kalkulatorische Kostenart darf kein Konto tragen - ' +
          'sie hat in der Buchhaltung kein Gegenst' + #252 + 'ck. Entweder ' +
          'das H' + #228 + 'kchen "kalkulatorisch" entfernen oder das Konto leeren.'
      else if Pos('zuschlagssatz_mandant_id_jahr_bereich_key', E.Message) > 0 then
        Result := 'F' + #252 + 'r dieses Jahr gibt es zu diesem Bereich ' +
          'bereits einen Satz.'
      else if Pos('konto_mandant_id_nummer_key', E.Message) > 0 then
        Result := 'Diese Kontonummer gibt es bereits.'
      else if Pos('kostenart_mandant_id_nummer_key', E.Message) > 0 then
        Result := 'Diese Kostenartennummer gibt es bereits.'
      else
        Result := E.Message;
  end;
end;

procedure TdmKalkulation.SatzAbbrechen(ADataSet: TDataSet);
begin
  if ADataSet.State in dsEditModes then
    ADataSet.Cancel;
end;

function TdmKalkulation.SatzLoeschen(ADataSet: TDataSet): string;
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

procedure TdmKalkulation.OpenKalkulation;
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

  qryKontoLookup.Close;
  qryKontoLookup.ParamByName('m').AsInteger := FMandantId;
  qryKontoLookup.Open;

  qryArtikel.Close;
  qryArtikel.ParamByName('m').AsInteger := FMandantId;
  qryArtikel.Open;

  tblKalkulation.Filtered := False;
  tblKalkulation.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKalkulation.Filtered := True;

  tblZuschlag.Filtered := False;
  tblZuschlag.Filter := Format('mandant_id=%d', [FMandantId]);
  tblZuschlag.Filtered := True;

  tblKostenart.Filtered := False;
  tblKostenart.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKostenart.Filtered := True;

  tblKostenstelle.Filtered := False;
  tblKostenstelle.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKostenstelle.Filtered := True;

  tblKonto.Filtered := False;
  tblKonto.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKonto.Filtered := True;

  LadeDetails(AktuelleKalkulation);

  if not Assigned(frmKalkulation) then
    frmKalkulation := TfrmKalkulation.Create(Application);
  frmKalkulation.Show;
end;


procedure TdmKalkulation.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblKalkulation, 'kalkulation'),
    Zuordnung(tblKonto, 'konto'),
    Zuordnung(tblKostenart, 'kostenart'),
    Zuordnung(tblKostenstelle, 'kostenstelle'),
    Zuordnung(tblPosition, 'kalkulation_position'),
    Zuordnung(tblZuschlag, 'zuschlagssatz')]);
  // Alle sechs Tabellen tragen ein 'bemerkung'-Feld vom Typ Postgres 'text' -
  // ohne das haetten die Gitter dort nur "(WIDEMEMO)" gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(tblKalkulation);
  MemosLesbarMachen(tblKonto);
  MemosLesbarMachen(tblKostenart);
  MemosLesbarMachen(tblKostenstelle);
  MemosLesbarMachen(tblPosition);
  MemosLesbarMachen(tblZuschlag);
end;



initialization
  GSperreKalkulation := TCriticalSection.Create;

finalization
  GSperreKalkulation.Free;

end.
