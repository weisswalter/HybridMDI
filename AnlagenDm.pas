unit AnlagenDm;

// Anlagevermoegen — Delphi-Seite.
//
// Gerechnet wird in der Datenbank (sql/anlage.sql). Dieses DataModule pflegt
// die Stammdaten und stoesst fn_anlage_plan an; der Abschreibungsplan wird
// nur gelesen.
//
// DER PUNKT DES MODULS sind die ZWEI Wertreihen: bilanziell fuer den
// Abschluss, kalkulatorisch fuer die Preisfindung. Die Sicht v_anlage_jahr
// zeigt beide nebeneinander samt Differenz — dort wird sichtbar, was eine
// Kalkulation nach Buchwerten verschenken wuerde.

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
  TdmAnlagen = class(TdmModuleTemplate)
    tblAnlage: TFDTable;
    dsAnlage: TDataSource;
    qryPlan: TFDQuery;
    dsPlan: TDataSource;
    qryKonto: TFDQuery;
    dsKonto: TDataSource;
    qryRaum: TFDQuery;
    dsRaum: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblAnlageNewRecord(DataSet: TDataSet);
    procedure tblAnlageAfterScroll(DataSet: TDataSet);
  private
    FMandantId: Integer;
    function Conn: TFDConnection;
  public
    class function GetInstance: TObject;
    procedure OpenAnlagen;
    property MandantId: Integer read FMandantId;

    function AktuelleAnlage: Integer;
    procedure LadePlan(AAnlageId: Integer);
    // Baut den Abschreibungsplan neu. Liefert 'OK: ...' / 'FEHLER: ...'.
    function PlanRechnen(AAnlageId: Integer): string;
    function PlanRechnenAlle: string;
    // Kennzahlen fuer die Anzeige, ohne dass das Formular rechnen muss.
    function Stundensatz(AAnlageId, AJahr: Integer): string;

    function SatzNeu: string;
    function SatzAendern: string;
    function SatzSpeichern: string;
    procedure SatzAbbrechen;
    function SatzLoeschen: string;
  end;

var
  dmAnlagen: TdmAnlagen;

implementation

{$R *.dfm}

uses
  System.DateUtils,
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  AnlagenFrm;

class function TdmAnlagen.GetInstance: TObject;
begin
  Result := dmAnlagen;
end;

function TdmAnlagen.Conn: TFDConnection;
begin
  Result := PGManagerDm.dmPGManager.FDConnection1;
end;

procedure TdmAnlagen.DataModuleCreate(Sender: TObject);
begin
  tblAnlage.Connection := Conn;
  qryPlan.Connection   := Conn;
  qryKonto.Connection  := Conn;
  qryRaum.Connection   := Conn;

  tblAnlage.UpdateOptions.AutoIncFields := 'anlage_id';

  // Die Sicht liefert beide Reihen und die Differenz bereits ausgerechnet
  qryPlan.SQL.Text :=
    'SELECT jahr, nutzungsjahr, buchwert_anfang, abschreibung_bilanz, ' +
    '       buchwert_ende, kalk_basis, abschreibung_kalk, kalk_zins, ' +
    '       kalk_gesamt, differenz, stundensatz ' +
    'FROM v_anlage_jahr WHERE anlage_id = :a ORDER BY jahr';

  // Nur bebuchbare Konten anbieten — auf Sammelkonten wird nicht gebucht
  qryKonto.SQL.Text :=
    'SELECT konto_id, nummer || '' '' || bezeichnung AS anzeige ' +
    'FROM konto WHERE mandant_id = :m AND aktiv AND NOT ist_sammelkonto ' +
    'ORDER BY nummer';

  qryRaum.SQL.Text :=
    'SELECT r.raum_id, r.bezeichnung || COALESCE('' ('' || a.ort || '')'', '''') ' +
    '       AS anzeige ' +
    'FROM raum r LEFT JOIN adresse a ON a.adresse_id = r.adresse_id ' +
    'ORDER BY 2';
end;

function TdmAnlagen.AktuelleAnlage: Integer;
begin
  if tblAnlage.Active and not tblAnlage.IsEmpty then
    Result := tblAnlage.FieldByName('anlage_id').AsInteger
  else
    Result := 0;
end;

procedure TdmAnlagen.LadePlan(AAnlageId: Integer);
begin
  qryPlan.Close;
  qryPlan.ParamByName('a').AsInteger := AAnlageId;
  qryPlan.Open;
end;

// Beim Blaettern durch die Anlagen zieht der Plan automatisch nach — sonst
// zeigt er die Zahlen der vorher gewaehlten Anlage und niemand merkt es.
procedure TdmAnlagen.tblAnlageAfterScroll(DataSet: TDataSet);
begin
  if tblAnlage.Active and not (tblAnlage.State in dsEditModes) then
    LadePlan(AktuelleAnlage);
end;

function TdmAnlagen.PlanRechnen(AAnlageId: Integer): string;
var
  LQry: TFDQuery;
begin
  if AAnlageId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Anlage w' + #228 + 'hlen.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_anlage_plan(:a)';
    LQry.ParamByName('a').AsInteger := AAnlageId;
    LQry.Open;
    Result := Format('OK: Plan '#252'ber %d Jahre berechnet.',
      [LQry.Fields[0].AsInteger]);
    LadePlan(AAnlageId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

function TdmAnlagen.PlanRechnenAlle: string;
var
  LQry: TFDQuery;
  LAnzahl: Integer;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text :=
      'SELECT count(fn_anlage_plan(anlage_id)) FROM anlage ' +
      'WHERE mandant_id = :m AND aktiv';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    LAnzahl := LQry.Fields[0].AsInteger;
    Result := Format('OK: %d Anlagen neu berechnet.', [LAnzahl]);
    LadePlan(AktuelleAnlage);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LQry.Free;
end;

// Liefert einen fertigen Satz fuer die Anzeige. Ist kein Stundensatz
// ermittelbar, wird der Grund genannt statt einer Null — ein fehlender Wert
// soll auffallen, nicht die Kalkulation stillschweigend verbilligen.
function TdmAnlagen.Stundensatz(AAnlageId, AJahr: Integer): string;
var
  LQry: TFDQuery;
begin
  if AAnlageId <= 0 then
    Exit('Keine Anlage gew' + #228 + 'hlt.');
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Conn;
    LQry.SQL.Text := 'SELECT fn_maschinenstundensatz(:a, :j)';
    LQry.ParamByName('a').AsInteger := AAnlageId;
    LQry.ParamByName('j').AsInteger := AJahr;
    LQry.Open;
    if LQry.IsEmpty then
      Result := Format('F'#252'r %d gibt es keine Planzeile - bitte den Plan ' +
        'berechnen.', [AJahr])
    else if LQry.Fields[0].IsNull then
      Result := 'Kein Stundensatz: es sind keine Betriebsstunden hinterlegt.'
    else
      Result := Format('Maschinenstundensatz %d: %.2f pro Stunde',
        [AJahr, LQry.Fields[0].AsFloat]);
  except
    on E: Exception do
      Result := 'Stundensatz nicht lesbar: ' + E.Message;
  end;
  LQry.Free;
end;

procedure TdmAnlagen.tblAnlageNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('anschaffung_datum').AsDateTime := Date;
  DataSet.FieldByName('anschaffung_wert').AsFloat := 0;
  DataSet.FieldByName('restwert').AsFloat := 0;
  DataSet.FieldByName('nutzungsdauer_jahre').AsFloat := 5;
  DataSet.FieldByName('methode').AsString := 'linear';
  DataSet.FieldByName('inflation_prozent').AsFloat := 0;
  DataSet.FieldByName('kalk_zins_prozent').AsFloat := 0;
  DataSet.FieldByName('unterhalt_jahr').AsFloat := 0;
  DataSet.FieldByName('energie_pro_stunde').AsFloat := 0;
  DataSet.FieldByName('aktiv').AsBoolean := True;
end;

function TdmAnlagen.SatzNeu: string;
begin
  Result := '';
  if not tblAnlage.Active then
    Exit('Die Liste ist nicht ge' + #246 + 'ffnet.');
  tblAnlage.Append;
end;

function TdmAnlagen.SatzAendern: string;
begin
  Result := '';
  if not tblAnlage.Active or tblAnlage.IsEmpty then
    Exit('Es gibt nichts zu ' + #228 + 'ndern.');
  tblAnlage.Edit;
end;

// Die Bedingungen der Datenbank in verstaendliche Saetze uebersetzen
function TdmAnlagen.SatzSpeichern: string;
var
  LId: Integer;
begin
  Result := '';
  if not (tblAnlage.State in dsEditModes) then
    Exit;
  try
    tblAnlage.Post;
  except
    on E: Exception do
    begin
      if Pos('anlage_degressiv_check', E.Message) > 0 then
        Result := 'Bei der degressiven Methode muss ein Prozentsatz ' +
          'angegeben werden.'
      else if Pos('anlage_mandant_id_inventar_nr_key', E.Message) > 0 then
        Result := 'Diese Inventarnummer gibt es bereits.'
      else if Pos('nutzungsdauer_jahre_check', E.Message) > 0 then
        Result := 'Die Nutzungsdauer muss gr' + #246 + 'sser als null sein.'
      else
        Result := E.Message;
      Exit;
    end;
  end;

  // Nach jeder Aenderung an den Stammdaten ist der alte Plan hinfaellig.
  // Ihn stehen zu lassen waere die gefaehrlichere Variante: Man saehe Zahlen,
  // die nicht mehr zu den Eingaben passen.
  LId := AktuelleAnlage;
  if LId > 0 then
    PlanRechnen(LId);
end;

procedure TdmAnlagen.SatzAbbrechen;
begin
  if tblAnlage.State in dsEditModes then
    tblAnlage.Cancel;
end;

function TdmAnlagen.SatzLoeschen: string;
begin
  Result := '';
  if not tblAnlage.Active or tblAnlage.IsEmpty then
    Exit;
  try
    // anlage_abschreibung haengt mit ON DELETE CASCADE dran
    tblAnlage.Delete;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

procedure TdmAnlagen.OpenAnlagen;
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

  qryKonto.Close;
  qryKonto.ParamByName('m').AsInteger := FMandantId;
  qryKonto.Open;
  qryRaum.Open;

  tblAnlage.Filtered := False;
  tblAnlage.Open;
  tblAnlage.Filter := Format('mandant_id=%d', [FMandantId]);
  tblAnlage.Filtered := True;

  LadePlan(AktuelleAnlage);

  if not Assigned(frmAnlagen) then
    frmAnlagen := TfrmAnlagen.Create(Application);
  frmAnlagen.Show;
end;

end.
