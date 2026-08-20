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
  TdmAnlagen = class(TdmModuleTemplate)
    tblAnlage: TFDMemTable;
    dsAnlage: TDataSource;
    // Kopien aus dem zentralen Datenmodul.
    qryPlan: TFDMemTable;
    dsPlan: TDataSource;
    qryKonto: TFDMemTable;
    dsKonto: TDataSource;
    qryRaum: TFDMemTable;
    dsRaum: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblAnlageNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    function Conn: TFDConnection;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
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
  ZentraleDatenDm,
  System.DateUtils, System.Variants,
  Vcl.Dialogs,
  MandantDm,
  AnlagenFrm, System.SyncObjs;

var
  GSperreAnlagen: TCriticalSection;

class function TdmAnlagen.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmAnlagen) then
  begin
    GSperreAnlagen.Enter;
    try
      if not Assigned(dmAnlagen) then
        Application.CreateForm(TdmAnlagen, dmAnlagen);
    finally
      GSperreAnlagen.Leave;
    end;
  end;
  Result := dmAnlagen;
end;

function TdmAnlagen.Conn: TFDConnection;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
end;

procedure TdmAnlagen.DataModuleCreate(Sender: TObject);
begin
  // Kein Inline-SQL mehr: die drei Listen kommen als Kopie aus dem zentralen
  // Datenmodul (v_anlage_jahr / v_konto_auswahl / v_raum_auswahl_einfach),
  // gefiltert wird im Speicher.
  tblAnlage.UpdateOptions.AutoIncFields := 'anlage_id';
end;

function TdmAnlagen.AktuelleAnlage: Integer;
begin
  if tblAnlage.Active and not tblAnlage.IsEmpty then
    Result := tblAnlage.FieldByName('anlage_id').AsInteger
  else
    Result := 0;
end;

// Der Plan haengt per MasterSource/MasterFields an tblAnlage (im DFM
// eingetragen) - beim Blaettern zieht er von selbst nach. Hier ist nichts
// mehr zu tun; die Methode bleibt, weil das Formular sie ruft.
procedure TdmAnlagen.LadePlan(AAnlageId: Integer);
begin
  if not qryPlan.Active then
    TabellenLaden;
end;

function TdmAnlagen.PlanRechnen(AAnlageId: Integer): string;
var
  LZentral: TdmZentraleDaten;
begin
  if AAnlageId <= 0 then
    Exit('FEHLER: Bitte zuerst eine Anlage w' + #228 + 'hlen.');
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    Result := Format('OK: Plan '#252'ber %d Jahre berechnet.',
      [AlsZahl(LZentral.SpAufrufen('fn_anlage_plan', [AAnlageId]))]);
    // Der Plan ist neu geschrieben -> zentralen Stand nachziehen.
    LZentral.TabelleAuffrischen('v_anlage_jahr');
    TabellenLaden;
    LadePlan(AAnlageId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

function TdmAnlagen.PlanRechnenAlle: string;
var
  LZentral: TdmZentraleDaten;
begin
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    Result := Format('OK: %d Anlagen neu berechnet.',
      [AlsZahl(LZentral.SpAufrufen('fn_anlage_plan_alle', [FMandantId]))]);
    LZentral.TabelleAuffrischen('v_anlage_jahr');
    TabellenLaden;
    LadePlan(AktuelleAnlage);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

// Liefert einen fertigen Satz fuer die Anzeige. Ist kein Stundensatz
// ermittelbar, wird der Grund genannt statt einer Null — ein fehlender Wert
// soll auffallen, nicht die Kalkulation stillschweigend verbilligen.
function TdmAnlagen.Stundensatz(AAnlageId, AJahr: Integer): string;
var
  LWert: Variant;
begin
  if AAnlageId <= 0 then
    Exit('Keine Anlage gew' + #228 + 'hlt.');
  try
    LWert := TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_maschinenstundensatz', [AAnlageId, AJahr]);
    if VarIsNull(LWert) then
      // Die Funktion liefert NULL, wenn es keine Planzeile gibt ODER keine
      // Betriebsstunden hinterlegt sind - beides ist ein fehlender Wert,
      // der auffallen soll statt still als 0 durchzugehen.
      Result := Format('Kein Stundensatz f'#252'r %d: entweder fehlt die ' +
        'Planzeile (dann Plan berechnen) oder es sind keine Betriebsstunden ' +
        'hinterlegt.', [AJahr])
    else
      Result := Format('Maschinenstundensatz %d: %.2f pro Stunde',
        [AJahr, Double(LWert)]);
  except
    on E: Exception do
      Result := 'Stundensatz nicht lesbar: ' + E.Message;
  end;
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
    // Post bringt die Feldwerte nur aus dem Editiermodus in den Satz; in die
    // Datenbank geht es ueber fn_anlage_speichern.
    tblAnlage.Post;
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_anlage_speichern',
      [FeldOderNull(tblAnlage, 'anlage_id'), FMandantId,
       FeldOderNull(tblAnlage, 'bezeichnung'),
       FeldOderNull(tblAnlage, 'inventar_nr'),
       FeldOderNull(tblAnlage, 'gruppe'),
       FeldOderNull(tblAnlage, 'konto_id'),
       FeldOderNull(tblAnlage, 'aufwand_konto_id'),
       FeldOderNull(tblAnlage, 'anschaffung_datum'),
       FeldOderNull(tblAnlage, 'anschaffung_wert'),
       FeldOderNull(tblAnlage, 'restwert'),
       FeldOderNull(tblAnlage, 'nutzungsdauer_jahre'),
       FeldOderNull(tblAnlage, 'methode'),
       FeldOderNull(tblAnlage, 'degressiv_prozent'),
       FeldOderNull(tblAnlage, 'wiederbeschaffung_wert'),
       FeldOderNull(tblAnlage, 'inflation_prozent'),
       FeldOderNull(tblAnlage, 'kalk_nutzungsdauer_jahre'),
       FeldOderNull(tblAnlage, 'kalk_zins_prozent'),
       FeldOderNull(tblAnlage, 'betriebsstunden_jahr'),
       FeldOderNull(tblAnlage, 'unterhalt_jahr'),
       FeldOderNull(tblAnlage, 'energie_pro_stunde'),
       FeldOderNull(tblAnlage, 'raum_id'),
       FeldOderNull(tblAnlage, 'ausser_betrieb_am'),
       FeldOderNull(tblAnlage, 'aktiv'),
       FeldOderNull(tblAnlage, 'bemerkung')]);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).TabelleAuffrischen('anlage');
    TabellenLaden;
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
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_anlage_loeschen',
      [tblAnlage.FieldByName('anlage_id').AsInteger, FMandantId]);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).TabelleAuffrischen('anlage');
    TabellenLaden;
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


  tblAnlage.Filtered := False;
  // Speichertabellen kommen aus dem zentralen Datenmodul
  TabellenLaden;
  tblAnlage.Filter := Format('mandant_id=%d', [FMandantId]);
  tblAnlage.Filtered := True;

  LadePlan(AktuelleAnlage);

  if not Assigned(frmAnlagen) then
    frmAnlagen := TfrmAnlagen.Create(Application);
  frmAnlagen.Show;
end;


procedure TdmAnlagen.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblAnlage, 'anlage'),
    Zuordnung(qryPlan, 'v_anlage_jahr'),
    Zuordnung(qryKonto, 'v_konto_auswahl'),
    Zuordnung(qryRaum, 'v_raum_auswahl_einfach')]);

  // Konten sind mandantenbezogen, Raeume nicht (physische Gebaeudefakten).
  qryKonto.Filtered := False;
  qryKonto.Filter := Format('mandant_id = %d', [FMandantId]);
  qryKonto.Filtered := True;
  qryKonto.IndexFieldNames := 'nummer';
  qryRaum.IndexFieldNames := 'anzeige';
end;



initialization
  GSperreAnlagen := TCriticalSection.Create;

finalization
  GSperreAnlagen.Free;

end.
