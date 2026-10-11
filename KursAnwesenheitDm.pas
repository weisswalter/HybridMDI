unit KursAnwesenheitDm;

// Kurs-Anwesenheit — wer war bei welchem KURSTERMIN da.
//
// ABGRENZUNG ZUM BESTEHENDEN ANWESENHEITSMODUL: `AnwesenheitDm/Frm` erfasst
// die betriebliche ZEITERFASSUNG (Kommen/Gehen des Lehrers, Halbtags-Check
// des Klienten, Ferien/Krankheit) — Grundlage fuer Lohn und Ferienstand.
// DIESES Modul erfasst dagegen die Teilnahme an einem einzelnen Kurstermin
// (`kurs_anwesenheit`) — Grundlage fuer Kursabschluss und Nachweis. Beides
// nebeneinander ist Absicht, nicht doppelt: jemand kann anwesend im Betrieb
// und trotzdem im Kurs abwesend sein.
//
// ARBEITSWEISE: Termin links waehlen, rechts die Teilnehmerliste abhaken.
// Die Liste entsteht per Knopfdruck aus `kurs_teilnehmer` der zugehoerigen
// Durchfuehrung (`ListeErzeugen`) — nicht automatisch beim Oeffnen, damit ein
// nachtraeglich angemeldeter Teilnehmer bewusst nachgezogen wird und nichts
// still im Hintergrund entsteht.

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
  TdmKursAnwesenheit = class(TdmModuleTemplate)
    // Fruher Inline-Queries mit WHERE-Parametern, jetzt Kopien der Views
    // v_kurs_termin_liste / v_kurs_coach. Gefiltert wird im Speicher.
    qryTermine: TFDMemTable;
    dsTermine: TDataSource;
    tblAnwesenheit: TFDMemTable;
    dsAnwesenheit: TDataSource;
    qryCoach: TFDMemTable;
    dsCoach: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FMandantId: Integer;
    // Der gewaehlte Coach. 0 = alle Termine anzeigen. Wird beim Erfassen als
    // erfasst_von_person_id mitgeschrieben — Heisenberg hat kein Login, aus
    // dem sich das ableiten liesse.
    FCoachId: Integer;
    // Merkt sich den zuletzt geladenen Zeitraum, damit ein Neuladen nach dem
    // Schreiben denselben Ausschnitt wiederherstellt.
    FVon, FBis: TDateTime;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen Datenmodul.
    procedure TabellenLaden;
    // Setzt den Filter auf qryTermine nach Mandant, Zeitraum und Coach.
    procedure TermineFiltern;
  public
    class function GetInstance: TObject;
    procedure OpenKursAnwesenheit;
    property MandantId: Integer read FMandantId;
    property CoachId: Integer read FCoachId write FCoachId;

    function AktuellerTermin: Integer;
    // Termine eines Zeitraums laden. ACoachId = 0 heisst: alle Leiter.
    procedure LadeTermine(AVon, ABis: TDateTime; ACoachId: Integer = 0);
    procedure LadeAnwesenheit(ATerminId: Integer);

    // Liefern 'OK: ...' / 'FEHLER: ...'
    function ListeErzeugen(ATerminId: Integer): string;
    function AlleAnwesend(ATerminId: Integer): string;
    function TerminAbschliessen(ATerminId: Integer): string;

    function SatzSpeichern: string;
    procedure SatzAbbrechen;
  end;

var
  dmKursAnwesenheit: TdmKursAnwesenheit;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm, uGridMemo,
  System.DateUtils, System.Variants,
  Vcl.Dialogs,
  MandantDm,
  KursAnwesenheitFrm, System.SyncObjs;

var
  GSperreKursAnwesenheit: TCriticalSection;

class function TdmKursAnwesenheit.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmKursAnwesenheit) then
  begin
    GSperreKursAnwesenheit.Enter;
    try
      if not Assigned(dmKursAnwesenheit) then
        Application.CreateForm(TdmKursAnwesenheit, dmKursAnwesenheit);
    finally
      GSperreKursAnwesenheit.Leave;
    end;
  end;
  Result := dmKursAnwesenheit;
end;

procedure TdmKursAnwesenheit.DataModuleCreate(Sender: TObject);
begin
  // Keine eigene Verbindung und kein Inline-SQL mehr: die Listen kommen als
  // Kopie der Views aus dem zentralen Datenmodul, gefiltert wird im Speicher.
  tblAnwesenheit.UpdateOptions.AutoIncFields := '';
end;

function TdmKursAnwesenheit.AktuellerTermin: Integer;
begin
  if qryTermine.Active and not qryTermine.IsEmpty then
    Result := qryTermine.FieldByName('termin_id').AsInteger
  else
    Result := 0;
end;

procedure TdmKursAnwesenheit.LadeTermine(AVon, ABis: TDateTime;
  ACoachId: Integer = 0);
begin
  FCoachId := ACoachId;
  FVon := AVon;
  FBis := ABis;
  TabellenLaden;
  TermineFiltern;
end;

// Was frueher die WHERE-Klausel der Query war. Datumsliterale muessen im
// Filter in Hochkommas und im ISO-Format stehen, sonst versteht sie der
// Ausdrucksauswerter je nach Gebietsschema unterschiedlich.
procedure TdmKursAnwesenheit.TermineFiltern;
var
  LFilter: string;
begin
  LFilter := Format('mandant_id = %d and datum >= ''%s'' and datum <= ''%s''',
    [FMandantId, FormatDateTime('yyyy-mm-dd', FVon),
     FormatDateTime('yyyy-mm-dd', FBis)]);
  if FCoachId > 0 then
    LFilter := LFilter + Format(' and leiter_person_id = %d', [FCoachId]);

  qryTermine.Filtered := False;
  qryTermine.Filter := LFilter;
  qryTermine.Filtered := True;
  qryTermine.IndexFieldNames := 'datum';

  // Die Coach-Auswahl zeigt nur die Leiter des eigenen Mandanten.
  qryCoach.Filtered := False;
  qryCoach.Filter := Format('mandant_id = %d', [FMandantId]);
  qryCoach.Filtered := True;
  qryCoach.IndexFieldNames := 'name';
end;

// Die Anwesenheitsliste haengt per MasterSource/MasterFields am Termin (im
// DFM eingetragen) - sie zieht beim Wechsel des Termins von selbst nach.
procedure TdmKursAnwesenheit.LadeAnwesenheit(ATerminId: Integer);
begin
  if not tblAnwesenheit.Active then
    TabellenLaden;
end;

// Legt fuer jeden angemeldeten/bestaetigten Teilnehmer der Durchfuehrung eine
// Zeile an — ohne vorhandene zu ueberschreiben (ON CONFLICT DO NOTHING).
// Wer bereits abgehakt wurde, behaelt seinen Stand, auch wenn jemand den
// Knopf zweimal drueckt.
function TdmKursAnwesenheit.ListeErzeugen(ATerminId: Integer): string;
var
  LZentral: TdmZentraleDaten;
  LWert: Variant;
  LAnzahl: Integer;
begin
  if ATerminId <= 0 then
    Exit('FEHLER: Bitte zuerst links einen Termin w' + #228 + 'hlen.');

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    // erfasst_von: der gewaehlte Coach; ist keiner gewaehlt, setzt der
    // Trigger den Leiter des Termins ein (siehe sql/kurs_anwesenheit_coach.sql)
    LWert := LZentral.SpAufrufen('fn_kurs_anwesenheit_liste_erzeugen',
      [ATerminId, FCoachId]);
    if VarIsNull(LWert) then
      LAnzahl := 0
    else
      LAnzahl := LWert;

    if LAnzahl = 0 then
      Result := 'OK: Nichts erg' + #228 + 'nzt - entweder ist die Liste ' +
        'bereits vollst' + #228 + 'ndig, oder f' + #252 + 'r diese ' +
        'Durchf' + #252 + 'hrung sind keine Teilnehmer angemeldet.'
    else
      Result := Format('OK: %d Teilnehmer erg'#228'nzt.', [LAnzahl]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LZentral.TabelleAuffrischen('kurs_anwesenheit');
  LadeTermine(FVon, FBis, FCoachId);
  qryTermine.Locate('termin_id', ATerminId, []);
  LadeAnwesenheit(ATerminId);
end;

// Der haeufige Fall: fast alle sind da. Einmal alle auf anwesend setzen,
// danach die wenigen Fehlenden einzeln zuruecknehmen — schneller als jeden
// Anwesenden abzuhaken.
function TdmKursAnwesenheit.AlleAnwesend(ATerminId: Integer): string;
var
  LZentral: TdmZentraleDaten;
  LWert: Variant;
begin
  if ATerminId <= 0 then
    Exit('FEHLER: Bitte zuerst einen Termin w' + #228 + 'hlen.');
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    LWert := LZentral.SpAufrufen('fn_kurs_anwesenheit_alle_da',
      [ATerminId, FCoachId]);
    Result := Format('OK: %d Zeilen auf anwesend gesetzt.',
      [AlsZahl(LWert)]);
    LZentral.TabelleAuffrischen('kurs_anwesenheit');
    LadeAnwesenheit(ATerminId);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

// Setzt den Termin auf 'stattgefunden' — das ist der Status, den die
// Honorarabrechnung auswertet (fn_honorar_einheiten zaehlt NUR
// stattgefundene Termine, siehe sql/person_lohn.sql). Deshalb gehoert der
// Knopf hierher: wer die Anwesenheit erfasst, weiss, dass der Termin lief.
function TdmKursAnwesenheit.TerminAbschliessen(ATerminId: Integer): string;
var
  LZentral: TdmZentraleDaten;
  LWert: Variant;
begin
  if ATerminId <= 0 then
    Exit('FEHLER: Bitte zuerst einen Termin w' + #228 + 'hlen.');
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    LWert := LZentral.SpAufrufen('fn_kurs_termin_abschliessen', [ATerminId]);
    if AlsZahl(LWert) = 0 then
      Result := 'FEHLER: Der Termin ist als ausgefallen gekennzeichnet - ' +
        'ein ausgefallener Termin wird nicht als stattgefunden gebucht.'
    else
      Result := 'OK: Termin als stattgefunden gekennzeichnet. Er z' + #228 +
        'hlt damit f' + #252 + 'r die Honorarabrechnung.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
  LZentral.TabelleAuffrischen('kurs_termin');
  LadeTermine(FVon, FBis, FCoachId);
  qryTermine.Locate('termin_id', ATerminId, []);
end;

function TdmKursAnwesenheit.SatzSpeichern: string;
var
  LZentral: TdmZentraleDaten;
  LTerminId: Integer;
begin
  Result := '';
  if not (tblAnwesenheit.State in dsEditModes) then
    Exit;
  LTerminId := AktuellerTermin;
  try
    // Post bringt die Feldwerte nur aus dem Editiermodus in den Satz; in die
    // Datenbank geht es ueber die Funktion.
    tblAnwesenheit.Post;
    LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
    LZentral.SpAufrufen('fn_kurs_anwesenheit_speichern',
      [tblAnwesenheit.FieldByName('anwesenheit_id').AsInteger,
       tblAnwesenheit.FieldByName('anwesend').AsBoolean,
       FeldOderNull(tblAnwesenheit, 'fehlminuten'),
       FeldOderNull(tblAnwesenheit, 'bemerkung')]);
    LZentral.TabelleAuffrischen('kurs_anwesenheit');
    if LTerminId > 0 then
      LadeAnwesenheit(LTerminId);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

procedure TdmKursAnwesenheit.SatzAbbrechen;
begin
  if tblAnwesenheit.State in dsEditModes then
    tblAnwesenheit.Cancel;
end;

procedure TdmKursAnwesenheit.OpenKursAnwesenheit;
begin
  if not TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung.Connected then
  begin
    ShowMessage('Keine Datenbankverbindung.', '');
    Exit;
  end;

  FMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
  if FMandantId <= 0 then
  begin
    ShowMessage('Bitte zuerst oben im Hauptfenster einen Mandanten w'#228'hlen.', '');
    Exit;
  end;


  LadeTermine(StartOfTheMonth(Date), EndOfTheMonth(Date), 0);
  LadeAnwesenheit(AktuellerTermin);

  if not Assigned(frmKursAnwesenheit) then
    frmKursAnwesenheit := TfrmKursAnwesenheit.Create(Application);
  frmKursAnwesenheit.Show;
end;


procedure TdmKursAnwesenheit.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblAnwesenheit, 'kurs_anwesenheit'),
    Zuordnung(qryTermine, 'v_kurs_termin_liste'),
    Zuordnung(qryCoach, 'v_kurs_coach')]);
  // kurs_anwesenheit.bemerkung ist Postgres 'text' - ohne das haette das
  // Gitter dort nur "(WIDEMEMO)" gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(tblAnwesenheit);
end;



initialization
  GSperreKursAnwesenheit := TCriticalSection.Create;

finalization
  GSperreKursAnwesenheit.Free;

end.
