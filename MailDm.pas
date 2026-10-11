unit MailDm;

// Mailmodul — Delphi-Seite (Anzeige/Bedienung).
//
// ZWEI ABRUFWEGE, eine Datenbank (Stand 01.08.2026):
//   'graph' → MailGraph.pas, reines Delphi ueber HTTPS. Fuer Exchange Online
//             und outlook.com — dort ist Graph der Hauptweg, weil die
//             Zielgruppe ueberwiegend Exchange einsetzt.
//   'imap'/'pop3' → MailKit in C# ueber die BridgePOC-Bruecke.
//   'auto'  → anhand der Domain entscheiden (siehe WegFuerKonto).
//   Welcher Weg gilt, steht in email_konto.protokoll und wird im Reiter
//   "Erweitert" gepflegt. Beide Wege schreiben in dieselben Tabellen, die
//   Oberflaeche merkt den Unterschied deshalb nicht.
//
// ARBEITSTEILUNG (siehe sql/email_vorgang.sql):
//   Das Abholen per IMAP und die komplette MIME-Verarbeitung macht die
//   C#-Seite (MailKit ueber die BridgePOC-Bruecke) und schreibt das Ergebnis
//   in die Datenbank. Dieses DataModule LIEST nur — hier wird nichts
//   dekodiert. Anhaenge sind normale `dokument`-Saetze, verknuepft ueber
//   `email_anhang`; ihr Inhalt liegt fertig entpackt in dokument.pdf_blob.
//
//   Der Aufruf der C#-Seite laeuft ueber TdmCSharp.Call('mail_caller', ...)
//   — siehe CSharpDm.pas und Python/mail_caller.py. Die Bruecke IST verdrahtet
//   (Stand 28.07.2026); der frueher hier beschriebene Platzhalter
//   AbrufenNochNichtVerdrahtet existiert nicht mehr.
//
//   Server- und Zugangsdaten pflegt der Reiter "Konto" in MailFrm. Das
//   Passwort wird in der Datenbank per pgcrypto verschluesselt
//   (sql/email_konto_crypt.sql); der Master-Schluessel steht nur in
//   FSchluessel und nur fuer die Dauer der Sitzung.

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
  MailGraph,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmMail = class(TdmModuleTemplate)
    tblKonto: TFDMemTable;
    dstblKonto: TDataSource;
    qryOrdner: TFDQuery;
    dstblOrdner: TDataSource;
    qryNachrichten: TFDQuery;
    dstblNachrichten: TDataSource;
    qryAnhaenge: TFDQuery;
    dstblAnhaenge: TDataSource;
    tblDokument: TFDMemTable;
    dstblDokument: TDataSource;
    qryOptProtokoll: TFDQuery;
    dsOptProtokoll: TDataSource;
    qryOptSicherheit: TFDQuery;
    dsOptSicherheit: TDataSource;
    qryOptAuth: TFDQuery;
    dsOptAuth: TDataSource;
    qryOptFlow: TFDQuery;
    dsOptFlow: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblKontoNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    // Master-Schluessel fuer die Passwortablage. Wird NUR im Speicher und nur
    // fuer die Dauer der Sitzung gehalten — nie in DB, Registry oder INI
    // (siehe sql/email_konto_crypt.sql).
    FSchluessel: string;
    // Der Graph-Weg. Wird erst beim ersten Bedarf erzeugt, damit Konten ohne
    // Graph nichts davon merken.
    FGraph: TGraphMail;
    function Graph: TGraphMail;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    destructor Destroy; override;
    class function GetInstance: TObject;
    procedure OpenMail;
    property Schluessel: string read FSchluessel write FSchluessel;

    // ── Wegwahl ───────────────────────────────────────────────────────────
    // Liefert 'graph', 'imap' oder 'pop3'. Loest 'auto' auf.
    function WegFuerKonto(AKontoId: Integer): string;
    function IstGraphKonto(AKontoId: Integer): Boolean;
    // Darf die Microsoft-Anmeldung angeboten werden? (bei 'auto' ja)
    function GraphMoeglich(AKontoId: Integer): Boolean;

    // ── Microsoft-Anmeldung (nur Graph) ───────────────────────────────────
    // Die Ereignisse reicht die Oberflaeche durch: OnCode zeigt den
    // Geraetecode an, OnWarten haelt das Fenster waehrend des Wartens am
    // Leben und erlaubt den Abbruch.
    function GraphAnmelden(AKontoId: Integer; ACode: TGraphCodeEvent;
      AWarten: TGraphWartenEvent; AStatus: TGraphStatusEvent): string;
    function GraphAbmelden(AKontoId: Integer): string;
    function GraphStatus(AKontoId: Integer): string;

    // ── Kontopflege ───────────────────────────────────────────────────────
    procedure KontoWaehlen(AKontoId: Integer);
    procedure KontoNeu;
    procedure KontoAendern;
    function  KontoSpeichern: string;
    procedure KontoAbbrechen;
    // Verschluesselt ueber pgcrypto in der Datenbank. Leeres Passwort loescht.
    function PasswortSetzen(AKontoId: Integer;
      const APasswort, ASchluessel: string): string;
    // UEBERGANG: legt das Passwort unverschluesselt ab, weil MailBridge.cs
    // passwort_crypt derzeit noch als UTF8-Klartext liest. Nur zum
    // Ausprobieren — faellt weg, sobald die C#-Seite entschluesselt.
    function PasswortKlartextSetzen(AKontoId: Integer;
      const APasswort: string): string;
    function HatPasswort(AKontoId: Integer): Boolean;
    // 'keins' / 'klartext' / 'verschluesselt'
    function PasswortStatus(AKontoId: Integer): string;

    // ── Eigenes SMTP-Passwort ─────────────────────────────────────────────
    // Nur noetig, wenn der Postausgang andere Zugangsdaten verlangt als der
    // Abruf. Leer lassen heisst: die Daten des Kontos werden verwendet.
    function SmtpPasswortSetzen(AKontoId: Integer;
      const APasswort, ASchluessel: string; AKlartext: Boolean): string;
    function SmtpPasswortStatus(AKontoId: Integer): string;
    // Ordner des gewaehlten Kontos laden
    procedure LadeOrdner(AKontoId: Integer);
    // Nachrichten des gewaehlten Ordners laden (0 = alle des Kontos)
    procedure LadeNachrichten(AKontoId, AOrdnerId: Integer);
    // Anhaenge der gewaehlten Nachricht laden
    procedure LadeAnhaenge(ANachrichtId: Integer);
    // Anhang aus dokument.pdf_blob in eine Datei schreiben und oeffnen.
    // Hier wird NICHTS dekodiert — die Bytes liegen bereits entpackt in der
    // Datenbank (die C#-Seite hat MIME/Base64 beim Abruf aufgeloest).
    function AnhangOeffnen(ADokumentId: Integer): Boolean;
    // Als gelesen markieren
    procedure SetzeGelesen(ANachrichtId: Integer; AGelesen: Boolean);
    // ── Aufrufe an die C#-Seite (MailKit) ueber TdmCSharp ─────────────────
    // Liefern jeweils die Statusmeldung der C#-Seite ('OK: ...' / 'FEHLER: ...').
    function OrdnerAbgleichen(AKontoId: Integer): string;
    function PostfachAbrufen(AKontoId: Integer): string;
    function NachrichtSenden(ANachrichtId: Integer): string;
    function VerbindungTesten(AKontoId: Integer): string;
  end;

var
  dmMail: TdmMail;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm, uGridMemo,
  Winapi.ShellAPI, Winapi.Windows,
  Vcl.Dialogs,
  MandantDm,
  CSharpDm,
  MailFrm, System.SyncObjs;

var
  GSperreMail: TCriticalSection;

class function TdmMail.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmMail) then
  begin
    GSperreMail.Enter;
    try
      if not Assigned(dmMail) then
        Application.CreateForm(TdmMail, dmMail);
    finally
      GSperreMail.Leave;
    end;
  end;
  Result := dmMail;
end;

procedure TdmMail.DataModuleCreate(Sender: TObject);
begin
  qryOptProtokoll.Connection  := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryOptSicherheit.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryOptAuth.Connection       := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryOptFlow.Connection       := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

  // Auswahllisten kommen aus email_option, nicht als feste Items im Formular.
  // Neue Werte lassen sich damit ohne Neuuebersetzung ergaenzen.
  qryOptProtokoll.SQL.Text :=
    'SELECT wert, anzeige FROM email_option WHERE feld = ''protokoll'' ORDER BY reihenfolge';
  qryOptSicherheit.SQL.Text :=
    'SELECT wert, anzeige FROM email_option WHERE feld = ''sicherheit'' ORDER BY reihenfolge';
  qryOptAuth.SQL.Text :=
    'SELECT wert, anzeige FROM email_option WHERE feld = ''auth'' ORDER BY reihenfolge';
  qryOptFlow.SQL.Text :=
    'SELECT wert, anzeige FROM email_option WHERE feld = ''oauth_flow'' ORDER BY reihenfolge';

  qryOrdner.Connection      := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryNachrichten.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryAnhaenge.Connection    := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

  tblKonto.UpdateOptions.AutoIncFields := 'konto_id';

  qryOrdner.SQL.Text :=
    'SELECT ordner_id, parent_id, name, voller_pfad, anzahl_gesamt, ' +
    '       anzahl_ungelesen, letzter_abruf ' +
    'FROM email_ordner WHERE konto_id = :k ORDER BY voller_pfad';

  // :o = 0 bedeutet "alle Ordner dieses Kontos"
  qryNachrichten.SQL.Text :=
    'SELECT n.nachricht_id, n.gelesen, n.hat_anhang, n.richtung, ' +
    '       n.von_name, n.von_adresse, n.an_adressen, n.betreff, ' +
    '       n.gesendet_am, n.body_text, n.body_html, ' +
    '       n.person_id, n.beleg_id, o.name AS ordner_name ' +
    'FROM email_nachricht n ' +
    'LEFT JOIN email_ordner o ON o.ordner_id = n.ordner_id ' +
    'WHERE n.konto_id = :k AND (:o = 0 OR n.ordner_id = :o) ' +
    'ORDER BY n.gesendet_am DESC NULLS LAST';

  qryAnhaenge.SQL.Text :=
    'SELECT a.dokument_id, a.dateiname, a.inline, ' +
    '       d.mime_type, d.dateigroesse_kb, d.titel ' +
    'FROM email_anhang a ' +
    'JOIN dokument d ON d.dokument_id = a.dokument_id ' +
    'WHERE a.nachricht_id = :n ORDER BY a.dateiname';

  // email_nachricht.an_adressen/body_text/body_html sind Postgres 'text' -
  // ohne das haette das Gitter dort nur "(WIDEMEMO)" gezeigt. Siehe
  // uGridMemo.
  MemosLesbarMachen(qryNachrichten);
end;

procedure TdmMail.LadeOrdner(AKontoId: Integer);
begin
  qryOrdner.Close;
  qryOrdner.ParamByName('k').AsInteger := AKontoId;
  qryOrdner.Open;
end;

procedure TdmMail.LadeNachrichten(AKontoId, AOrdnerId: Integer);
begin
  qryNachrichten.Close;
  qryNachrichten.ParamByName('k').AsInteger := AKontoId;
  qryNachrichten.ParamByName('o').AsInteger := AOrdnerId;
  qryNachrichten.Open;
end;

procedure TdmMail.LadeAnhaenge(ANachrichtId: Integer);
begin
  qryAnhaenge.Close;
  qryAnhaenge.ParamByName('n').AsInteger := ANachrichtId;
  qryAnhaenge.Open;
end;

// Schreibt den Blob in den TEMP-Ordner und uebergibt ihn der Shell.
// Dateiname aus dokument.titel; fehlt eine Endung, wird aus dem MIME-Typ
// eine ergaenzt, sonst weiss Windows nicht, womit es oeffnen soll.
function TdmMail.AnhangOeffnen(ADokumentId: Integer): Boolean;
var
  LZiel, LName, LExt, LMime: string;
  LBlob: TBlobField;
begin
  Result := False;
  if not tblDokument.Active then
    // Speichertabellen kommen aus dem zentralen Datenmodul
    TabellenLaden;
  if not tblDokument.Locate('dokument_id', ADokumentId, []) then
  begin
    ShowMessage('Dokument nicht gefunden.', '');
    Exit;
  end;

  LBlob := TBlobField(tblDokument.FieldByName('pdf_blob'));
  if LBlob.IsNull then
  begin
    // Grosse Medien liegen als Datei, nicht als Blob (siehe SQL-Kommentar)
    LZiel := tblDokument.FieldByName('datei_pfad').AsString;
    if (LZiel <> '') and FileExists(LZiel) then
    begin
      ShellExecute(0, 'open', PChar(LZiel), nil, nil, SW_SHOWNORMAL);
      Exit(True);
    end;
    ShowMessage('Dieser Anhang hat weder Inhalt noch g'#252'ltigen Dateipfad.', '');
    Exit;
  end;

  LName := tblDokument.FieldByName('titel').AsString;
  if LName = '' then
    LName := Format('anhang_%d', [ADokumentId]);
  LExt := ExtractFileExt(LName);
  if LExt = '' then
  begin
    LMime := LowerCase(tblDokument.FieldByName('mime_type').AsString);
    if Pos('pdf', LMime) > 0 then LExt := '.pdf'
    else if Pos('png', LMime) > 0 then LExt := '.png'
    else if (Pos('jpeg', LMime) > 0) or (Pos('jpg', LMime) > 0) then LExt := '.jpg'
    else if Pos('zip', LMime) > 0 then LExt := '.zip'
    else if Pos('text', LMime) > 0 then LExt := '.txt'
    else LExt := '.bin';
    LName := LName + LExt;
  end;

  LZiel := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + LName;
  LBlob.SaveToFile(LZiel);
  ShellExecute(0, 'open', PChar(LZiel), nil, nil, SW_SHOWNORMAL);
  Result := True;
end;

procedure TdmMail.SetzeGelesen(ANachrichtId: Integer; AGelesen: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'UPDATE email_nachricht SET gelesen = :g WHERE nachricht_id = :n';
    LQry.ParamByName('g').AsBoolean := AGelesen;
    LQry.ParamByName('n').AsInteger := ANachrichtId;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

// ── Kontopflege ─────────────────────────────────────────────────────────────
// Der Reiter "Konto" bearbeitet immer den AKTUELLEN Satz von tblKonto. Die
// Auswahlcombo oben ist ein reiner Lookup und bewegt den Cursor NICHT — ohne
// KontoWaehlen wuerde man deshalb immer den ersten Satz bearbeiten.

procedure TdmMail.KontoWaehlen(AKontoId: Integer);
begin
  if tblKonto.Active and (AKontoId > 0) then
    tblKonto.Locate('konto_id', AKontoId, []);
end;

procedure TdmMail.tblKontoNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  // Voreinstellungen, die fuer die grosse Mehrheit der Anbieter stimmen
  DataSet.FieldByName('imap_port').AsInteger := 993;
  DataSet.FieldByName('imap_ssl').AsBoolean := True;
  DataSet.FieldByName('smtp_port').AsInteger := 587;
  DataSet.FieldByName('smtp_starttls').AsBoolean := True;
  DataSet.FieldByName('aktiv').AsBoolean := True;
  DataSet.FieldByName('ist_standard').AsBoolean := False;
  // Obergrenze je Ordner und Abruf. Ohne sie zieht der Erstabruf eines
  // gewachsenen Postfachs alles auf einmal.
  DataSet.FieldByName('max_abruf').AsInteger := 200;
end;

procedure TdmMail.KontoNeu;
begin
  tblKonto.Append;
end;

procedure TdmMail.KontoAendern;
begin
  if not tblKonto.IsEmpty then
    tblKonto.Edit;
end;

function TdmMail.KontoSpeichern: string;
begin
  Result := '';
  if not (tblKonto.State in dsEditModes) then
    Exit;
  try
    tblKonto.Post;
  except
    on E: Exception do
      // Den partiellen Unique-Index auf ist_standard uebersetzen
      if Pos('ux_email_konto_standard', E.Message) > 0 then
        Result := 'Es kann pro Mandant nur EIN Standardkonto geben - ' +
          'bitte das Haekchen beim bisherigen Standardkonto zuerst entfernen.'
      else if Pos('email_konto_mandant_id_bezeichnung_key', E.Message) > 0 then
        Result := 'Eine Kontobezeichnung darf pro Mandant nur einmal vorkommen.'
      else
        Result := E.Message;
  end;
end;

procedure TdmMail.KontoAbbrechen;
begin
  if tblKonto.State in dsEditModes then
    tblKonto.Cancel;
end;

function TdmMail.PasswortSetzen(AKontoId: Integer;
  const APasswort, ASchluessel: string): string;
var
  LQry: TFDQuery;
begin
  if AKontoId <= 0 then
    Exit('Bitte zuerst ein Konto w' + #228 + 'hlen und speichern.');
  if ASchluessel = '' then
    Exit('Ohne Schl' + #252 + 'ssel kann nicht verschl' + #252 + 'sselt werden.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT fn_konto_passwort_setzen(:k, :p, :s)';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.ParamByName('p').AsString := APasswort;
    LQry.ParamByName('s').AsString := ASchluessel;
    LQry.Open;
  finally
    LQry.Free;
  end;

  // Schluessel fuer die Sitzung merken, damit die C#-Seite ihn beim Abruf
  // mitbekommt, ohne dass er erneut eingegeben werden muss.
  FSchluessel := ASchluessel;

  if APasswort = '' then
    Result := 'Das Passwort wurde entfernt.'
  else
    Result := 'Passwort verschl' + #252 + 'sselt gespeichert.';
end;

function TdmMail.PasswortKlartextSetzen(AKontoId: Integer;
  const APasswort: string): string;
var
  LQry: TFDQuery;
begin
  if AKontoId <= 0 then
    Exit('Bitte zuerst ein Konto w' + #228 + 'hlen und speichern.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT fn_konto_passwort_klartext(:k, :p)';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.ParamByName('p').AsString := APasswort;
    LQry.Open;
  finally
    LQry.Free;
  end;

  if APasswort = '' then
    Result := 'Das Passwort wurde entfernt.'
  else
    Result := 'Passwort im KLARTEXT gespeichert - nur zum Ausprobieren. ' +
      'Wer die Datenbank lesen kann, liest es mit.';
end;

function TdmMail.PasswortStatus(AKontoId: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := 'keins';
  if AKontoId <= 0 then
    Exit;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT fn_konto_passwort_status(:k)';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.Open;
    if not LQry.IsEmpty and not LQry.Fields[0].IsNull then
      Result := LQry.Fields[0].AsString;
  finally
    LQry.Free;
  end;
end;

function TdmMail.SmtpPasswortSetzen(AKontoId: Integer;
  const APasswort, ASchluessel: string; AKlartext: Boolean): string;
var
  LQry: TFDQuery;
begin
  if AKontoId <= 0 then
    Exit('Bitte zuerst ein Konto waehlen und speichern.');
  if not AKlartext and (ASchluessel = '') then
    Exit('Ohne Schluessel kann nicht verschluesselt werden.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    if AKlartext then
    begin
      LQry.SQL.Text := 'SELECT fn_konto_smtp_passwort_klartext(:k, :p)';
      LQry.ParamByName('k').AsInteger := AKontoId;
      LQry.ParamByName('p').AsString := APasswort;
    end
    else
    begin
      LQry.SQL.Text := 'SELECT fn_konto_smtp_passwort_setzen(:k, :p, :s)';
      LQry.ParamByName('k').AsInteger := AKontoId;
      LQry.ParamByName('p').AsString := APasswort;
      LQry.ParamByName('s').AsString := ASchluessel;
      FSchluessel := ASchluessel;
    end;
    LQry.Open;
  finally
    LQry.Free;
  end;

  if APasswort = '' then
    Result := 'Eigenes SMTP-Passwort entfernt - es gelten wieder die ' +
      'Zugangsdaten des Kontos.'
  else if AKlartext then
    Result := 'SMTP-Passwort im KLARTEXT gespeichert.'
  else
    Result := 'SMTP-Passwort verschluesselt gespeichert.';
end;

function TdmMail.SmtpPasswortStatus(AKontoId: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := 'keins';
  if AKontoId <= 0 then
    Exit;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT fn_konto_smtp_passwort_status(:k)';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.Open;
    if not LQry.IsEmpty and not LQry.Fields[0].IsNull then
      Result := LQry.Fields[0].AsString;
  finally
    LQry.Free;
  end;
end;

function TdmMail.HatPasswort(AKontoId: Integer): Boolean;
var
  LQry: TFDQuery;
begin
  Result := False;
  if AKontoId <= 0 then
    Exit;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT fn_konto_hat_passwort(:k)';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.Open;
    Result := not LQry.Fields[0].IsNull and LQry.Fields[0].AsBoolean;
  finally
    LQry.Free;
  end;
end;

// ── Wegwahl: Graph oder Bruecke ─────────────────────────────────────────────

destructor TdmMail.Destroy;
begin
  FGraph.Free;
  inherited;
end;

function TdmMail.Graph: TGraphMail;
begin
  if FGraph = nil then
    FGraph := TGraphMail.Create(TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung, FSchluessel);
  // Der Schluessel kann sich waehrend der Sitzung noch aendern (der Anwender
  // tippt ihn erst beim ersten Passwort ein) — deshalb jedes Mal nachziehen.
  FGraph.Schluessel := FSchluessel;
  Result := FGraph;
end;

// 'auto' heisst NICHT "die Domain befragen". Das wurde am 01.08.2026 gemessen
// und verworfen: login.microsoftonline.com antwortet fuer jede Domain mit
// einer Tenant-Kennung (auch gmx.de), und arcor.de gilt dort als "Managed",
// weil Vodafone einen Microsoft-Tenant hat — Walters Postfach liegt trotzdem
// bei imap.vodafonemail.de. Eine solche Erkennung haette ein funktionierendes
// IMAP-Konto stillschweigend auf Graph umgeleitet.
//
// 'auto' heisst stattdessen: Graph nimmt, WENN fuer das Konto eine
// Microsoft-Anmeldung hinterlegt ist. Das ist kein Raten, sondern eine
// Willensbekundung — jemand hat sich fuer dieses Konto angemeldet. Solange
// das nicht passiert ist, bleibt alles beim bisherigen Weg.
function TdmMail.WegFuerKonto(AKontoId: Integer): string;
var
  LQry: TFDQuery;
  LProtokoll: string;
  LAngemeldet: Boolean;
begin
  Result := 'imap';
  if AKontoId <= 0 then
    Exit;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text :=
      'SELECT protokoll, (oauth_refresh_crypt IS NOT NULL) AS angemeldet ' +
      'FROM email_konto WHERE konto_id = :k';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.Open;
    if LQry.IsEmpty then
      Exit;
    LProtokoll := LowerCase(LQry.FieldByName('protokoll').AsString.Trim);
    LAngemeldet := LQry.FieldByName('angemeldet').AsBoolean;
  finally
    LQry.Free;
  end;

  // Eine ausdrueckliche Einstellung hat immer Vorrang
  if (LProtokoll <> '') and (LProtokoll <> 'auto') then
    Exit(LProtokoll);

  if LAngemeldet then
    Result := 'graph';
end;

function TdmMail.IstGraphKonto(AKontoId: Integer): Boolean;
begin
  Result := WegFuerKonto(AKontoId) = 'graph';
end;

// Darf fuer dieses Konto eine Microsoft-Anmeldung angeboten werden? Bei
// 'auto' ja — sonst kaeme man nie zur ersten Anmeldung, die 'auto' erst auf
// Graph umstellt. Bei ausdruecklich eingestelltem imap/pop3 nein.
function TdmMail.GraphMoeglich(AKontoId: Integer): Boolean;
var
  LQry: TFDQuery;
  LProtokoll: string;
begin
  Result := False;
  if AKontoId <= 0 then
    Exit;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT protokoll FROM email_konto WHERE konto_id = :k';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.Open;
    if LQry.IsEmpty then
      Exit;
    LProtokoll := LowerCase(LQry.Fields[0].AsString.Trim);
  finally
    LQry.Free;
  end;
  Result := (LProtokoll = 'graph') or (LProtokoll = 'auto') or (LProtokoll = '');
end;

function TdmMail.GraphAnmelden(AKontoId: Integer; ACode: TGraphCodeEvent;
  AWarten: TGraphWartenEvent; AStatus: TGraphStatusEvent): string;
begin
  Graph.OnCode := ACode;
  Graph.OnWarten := AWarten;
  Graph.OnStatus := AStatus;
  try
    Result := Graph.Anmelden(AKontoId);
  finally
    // Die Ereignisse zeigen auf Methoden des Formulars — sie duerfen nicht
    // haengen bleiben, wenn das Formular geschlossen wird.
    Graph.OnCode := nil;
    Graph.OnWarten := nil;
    Graph.OnStatus := nil;
  end;
end;

function TdmMail.GraphAbmelden(AKontoId: Integer): string;
begin
  Result := Graph.Abmelden(AKontoId);
end;

function TdmMail.GraphStatus(AKontoId: Integer): string;
begin
  Result := Graph.AnmeldeStatus(AKontoId);
end;

// ── Abruf: leitet an den Weg des Kontos weiter ──────────────────────────────
// Der eigentliche IMAP-/SMTP-Verkehr passiert in MailLib (MailKit), der
// Graph-Verkehr in MailGraph.pas; hier wird nur der Auftrag abgesetzt.
// Ergebnisdaten kommen bei BEIDEN Wegen NICHT ueber den Rueckgabewert,
// sondern ueber die Datenbank — deshalb nach jedem Abruf neu laden.

function TdmMail.OrdnerAbgleichen(AKontoId: Integer): string;
begin
  if WegFuerKonto(AKontoId) = 'graph' then
    Result := Graph.OrdnerAbgleichen(AKontoId)
  else
    Result := TdmCSharp(TdmCSharp.GetInstance).Call('mail_caller', 'fetch_folders', [AKontoId]);
end;

function TdmMail.PostfachAbrufen(AKontoId: Integer): string;
begin
  if WegFuerKonto(AKontoId) = 'graph' then
    Result := Graph.PostfachAbrufen(AKontoId)
  else
    Result := TdmCSharp(TdmCSharp.GetInstance).Call('mail_caller', 'fetch_inbox', [AKontoId]);
end;

// Hier entscheidet das KONTO der Nachricht, nicht ein uebergebenes — deshalb
// wird es zuerst nachgeschlagen.
function TdmMail.NachrichtSenden(ANachrichtId: Integer): string;
var
  LKonto: Integer;
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT konto_id FROM email_nachricht WHERE nachricht_id = :n';
    LQry.ParamByName('n').AsInteger := ANachrichtId;
    LQry.Open;
    if LQry.IsEmpty then
      Exit('FEHLER: Diese Nachricht gibt es nicht.');
    LKonto := LQry.Fields[0].AsInteger;
  finally
    LQry.Free;
  end;

  if WegFuerKonto(LKonto) = 'graph' then
    Result := Graph.NachrichtSenden(ANachrichtId)
  else
    Result := TdmCSharp(TdmCSharp.GetInstance).Call('mail_caller', 'send_mail', [ANachrichtId]);
end;

function TdmMail.VerbindungTesten(AKontoId: Integer): string;
begin
  if WegFuerKonto(AKontoId) = 'graph' then
    Result := Graph.VerbindungTesten(AKontoId)
  else
    Result := TdmCSharp(TdmCSharp.GetInstance).Call('mail_caller', 'test_connection', [AKontoId]);
end;

procedure TdmMail.OpenMail;
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

  qryOptProtokoll.Open;
  qryOptSicherheit.Open;
  qryOptAuth.Open;
  qryOptFlow.Open;

  tblKonto.Filtered := False;
  tblKonto.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKonto.Filtered := True;


  if not Assigned(frmMail) then
    frmMail := TfrmMail.Create(Application);
  frmMail.Show;
end;


procedure TdmMail.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblDokument, 'dokument'),
    Zuordnung(tblKonto, 'email_konto')]);
end;



initialization
  GSperreMail := TCriticalSection.Create;

finalization
  GSperreMail.Free;

end.
