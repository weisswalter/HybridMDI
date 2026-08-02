unit MailGraph;

// Microsoft Graph als Mailzugang — REINES DELPHI, ohne Bruecke.
//
// WARUM HIER KEINE C#-SEITE STEHT: Graph ist REST ueber HTTPS und liefert die
// Nachricht bereits zerlegt (Absender, Empfaenger, Text, Anhaenge als eigene
// Objekte). Damit entfaellt genau das, wofuer MailKit auf dem IMAP-Weg
// gebraucht wird — die MIME-Verarbeitung. TNetHTTPClient + System.JSON
// genuegen. MailKit ueber die Bruecke bleibt fuer IMAP/POP3 und Exchange
// on-premises zustaendig; welcher Weg gilt, entscheidet email_konto.protokoll
// (siehe MailDm.WegFuerKonto).
//
// ERGEBNIS LANDET IN DERSELBEN DATENBANK wie beim IMAP-Weg — email_ordner,
// email_nachricht, email_anhang, dokument. Die Oberflaeche merkt deshalb
// nicht, welcher Weg gelaufen ist. Zusaetzliche Spalten fuer diesen Weg:
// email_ordner.graph_id, email_nachricht.graph_id/conversation_id
// (sql/email_graph.sql).
//
// ANMELDUNG: Geraetecode-Verfahren (Device Code Flow). Der Anwender tippt
// einen kurzen Code auf einer Microsoft-Seite ein, das Programm wartet
// derweil. Bewusst so gewaehlt: kein eingebetteter Browser, kein lokaler
// Listener auf einem Port, keine Registrierung einer Rueckleit-Adresse.
// Das gespeicherte Ergebnis ist ein Refresh-Token — es ersetzt das Passwort
// und wird wie eines behandelt (sql/email_graph.sql).
//
// KEIN THREAD: Die Aufrufe laufen synchron im Hauptthread, wie schon der
// Bruecken-Weg. Damit das Fenster waehrend des Wartens auf den Geraetecode
// nicht einfriert, gibt es OnWarten — die Oberflaeche haengt dort ihr
// ProcessMessages ein und kann abbrechen.

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  FireDAC.Comp.Client;

type
  EGraphFehler = class(Exception);

  // Der Anwender muss diesen Code auf AUrl eintippen. AHinweis ist der
  // fertige Satz von Microsoft, in der Sprache des Kontos.
  TGraphCodeEvent = procedure(Sender: TObject;
    const AUserCode, AUrl, AHinweis: string) of object;

  // Wird waehrend des Wartens auf die Anmeldung wiederholt gerufen. Die
  // Oberflaeche soll hier die Zeit verstreichen lassen UND Nachrichten
  // verarbeiten. Setzt sie AAbbrechen, bricht die Anmeldung ab.
  TGraphWartenEvent = procedure(Sender: TObject; ASekunden: Integer;
    var AAbbrechen: Boolean) of object;

  TGraphStatusEvent = procedure(Sender: TObject; const AText: string) of object;

  // Was aus email_konto fuer diesen Weg gebraucht wird. Bewusst ein Record
  // und kein Datenmodul: die Klasse soll ohne Formular testbar bleiben.
  TGraphKonto = record
    KontoId: Integer;
    MandantId: Integer;
    EmailAdresse: string;
    AnzeigeName: string;
    Benutzername: string;
    Tenant: string;
    ClientId: string;
    Authority: string;
    BasisUrl: string;
    Scopes: string;
    Flow: string;
    MaxAbruf: Integer;
    MaxAnhangKb: Integer;
    TimeoutSek: Integer;
    NurKopfdaten: Boolean;
    OrdnerFilter: string;
    AbrufAbDatum: TDateTime;
  end;

  TGraphMail = class
  private
    FConn: TFDConnection;
    // Master-Schluessel der Sitzung. Leer heisst: Token liegen im Klartext
    // (Uebergangsweg, wie beim Passwort).
    FSchluessel: string;
    FKonto: TGraphKonto;
    FAccessToken: string;
    FTokenBis: TDateTime;         // UTC
    FAbbruch: Boolean;
    FOnCode: TGraphCodeEvent;
    FOnWarten: TGraphWartenEvent;
    FOnStatus: TGraphStatusEvent;

    procedure Melde(const AText: string); overload;
    procedure Melde(const AText: string; const AArgs: array of const); overload;
    procedure Warte(ASekunden: Integer);

    procedure LadeKonto(AKontoId: Integer);
    function  TenantOderCommon: string;
    function  TokenEndpunkt: string;

    // ── Datenbank ────────────────────────────────────────────────────────
    function  SqlWert(const ASql: string;
      const AParams: array of Variant): Variant;
    procedure SqlAus(const ASql: string; const AParams: array of Variant);
    function  RefreshTokenLesen: string;
    procedure TokenSpeichern(const ARefresh, AAccess: string;
      AGueltigBis: TDateTime);

    // ── HTTP ─────────────────────────────────────────────────────────────
    // Liefert den Antworttext und den Statuscode. Wirft nur bei
    // Transportfehlern — fachliche Fehler kommen als 4xx/5xx zurueck und
    // werden von den Aufrufern ausgewertet.
    function HttpFormular(const AUrl: string; AFelder: TStrings;
      out AStatus: Integer): string;
    function HttpJson(const AUrl, AMethode, ABody: string;
      out AStatus: Integer): string;

    // Graph-Aufruf mit Zugriffstoken. Erneuert das Token bei 401 einmal und
    // wiederholt. Wirft EGraphFehler mit der Klartextmeldung von Graph.
    function GraphGet(const APfadOderUrl: string): TJSONObject;
    function GraphPost(const APfad, ABody: string): TJSONObject;

    function  TokenSicherstellen: Boolean;
    function  TokenErneuern: Boolean;

    // ── Abrufbausteine ───────────────────────────────────────────────────
    function  OrdnerSpeichern(const AGraphId, AName, APfad: string;
      AParentId, AGesamt, AUngelesen: Integer): Integer;
    procedure OrdnerEbene(const AUrl, AElternPfad: string; AElternId: Integer;
      var AAnzahl: Integer);
    function  OrdnerAufnehmen(const APfad: string): Boolean;
    function  NachrichtSpeichern(AOrdnerId: Integer; AMsg: TJSONObject): Integer;
    procedure AnhaengeHolen(ANachrichtId: Integer; const AMsgGraphId: string;
      var AUebersprungen: Integer);
  public
    constructor Create(AConnection: TFDConnection; const ASchluessel: string);

    // Alle oeffentlichen Funktionen liefern 'OK: ...' oder 'FEHLER: ...' —
    // dasselbe Format wie die C#-Seite, damit die Oberflaeche beide Wege
    // gleich behandeln kann.
    function Anmelden(AKontoId: Integer): string;
    function Abmelden(AKontoId: Integer): string;
    function VerbindungTesten(AKontoId: Integer): string;
    function OrdnerAbgleichen(AKontoId: Integer): string;
    function PostfachAbrufen(AKontoId: Integer): string;
    function NachrichtSenden(ANachrichtId: Integer): string;

    // Statuszeile fuer die Maske, ohne Netzverkehr.
    function AnmeldeStatus(AKontoId: Integer): string;

    property Schluessel: string read FSchluessel write FSchluessel;
    property OnCode: TGraphCodeEvent read FOnCode write FOnCode;
    property OnWarten: TGraphWartenEvent read FOnWarten write FOnWarten;
    property OnStatus: TGraphStatusEvent read FOnStatus write FOnStatus;
  end;

// HIER STAND EINE DOMAINERKENNUNG — sie ist ersatzlos entfernt.
//
// Die Idee war: ein GET auf
// login.microsoftonline.com/{domain}/.well-known/openid-configuration, und
// 200 heisst "Microsoft-Tenant". Am 01.08.2026 gemessen — die Annahme ist
// falsch. Der Endpunkt antwortet fuer JEDE Domain mit 200 und einer
// Tenant-Kennung, auch fuer gmx.de. Der zweite Kandidat (getuserrealm.srf)
// meldet arcor.de als "Managed", weil Vodafone einen Microsoft-Tenant
// betreibt — Walters Postfach liegt trotzdem bei imap.vodafonemail.de.
//
// Der Grund ist grundsaetzlich, nicht technisch: dass eine Domain zu einem
// Microsoft-Tenant gehoert, sagt nichts darueber, wo das POSTFACH liegt.
// Eine Erkennung, die das behauptet, wuerde ein funktionierendes IMAP-Konto
// stillschweigend auf Graph umleiten.
//
// Stattdessen entscheidet ein eindeutiges Signal: Ist fuer das Konto eine
// Microsoft-Anmeldung hinterlegt, laeuft es ueber Graph — siehe
// MailDm.WegFuerKonto. Wer sich angemeldet hat, hat die Frage beantwortet.

// Grobe Textfassung einer HTML-Mail fuer die Vorschau. Das Original bleibt
// unangetastet in body_html — das hier fuellt nur body_text, damit im
// Nachrichtenfenster etwas Lesbares steht. Bewusst simpel: kein Parser,
// nur Tags raus und die haeufigsten Entitaeten aufloesen.
function HtmlZuText(const AHtml: string): string;

implementation

uses
  System.DateUtils, System.NetEncoding, System.Variants,
  System.Generics.Collections, System.NetConsts,
  System.Net.HttpClient, System.Net.URLClient,
  FireDAC.Stan.Param,
  Data.DB;

const
  // Zeitpuffer: ein Token, das in weniger als zwei Minuten ablaeuft, wird
  // sofort erneuert. Sonst laeuft es mitten im Abruf eines grossen Postfachs
  // ab und die Haelfte der Nachrichten fehlt.
  CTokenPuffer = 2 / (24 * 60);

  // Fallback, wenn im Konto keine Anwendungskennung steht: die oeffentliche
  // Kennung von Microsofts eigenem Kommandozeilenwerkzeug (Azure CLI). Sie
  // ist in jedem Tenant vorregistriert und erlaubt den Geraetecode — damit
  // laesst sich der Weg ausprobieren, BEVOR jemand eine eigene Anwendung
  // registriert. Fuer den Dauerbetrieb gehoert eine eigene Kennung ins Konto:
  // nur dann kann der Kunde die Rechte selbst festlegen und wieder entziehen.
  CClientIdFallback = '04b07795-8ddb-461a-bbee-02f9e1bf7b46';

{ ── Freistehende Hilfen ─────────────────────────────────────────────────── }

function HtmlZuText(const AHtml: string): string;
var
  I, LLen: Integer;
  LImTag: Boolean;
  LSB: TStringBuilder;
begin
  if AHtml = '' then
    Exit('');

  LSB := TStringBuilder.Create;
  try
    LLen := Length(AHtml);
    LImTag := False;
    I := 1;
    while I <= LLen do
    begin
      if AHtml[I] = '<' then
      begin
        // Zeilenumbrueche der haeufigsten Blockelemente erhalten, sonst
        // klebt der ganze Text in einer Zeile
        if (I + 3 <= LLen) and (LowerCase(Copy(AHtml, I, 4)) = '<br ') then
          LSB.AppendLine
        else if (I + 3 <= LLen) and (LowerCase(Copy(AHtml, I, 4)) = '<br>') then
          LSB.AppendLine
        else if (I + 2 <= LLen) and (LowerCase(Copy(AHtml, I, 3)) = '<p ') then
          LSB.AppendLine
        else if (I + 2 <= LLen) and (LowerCase(Copy(AHtml, I, 3)) = '<p>') then
          LSB.AppendLine
        else if (I + 3 <= LLen) and (LowerCase(Copy(AHtml, I, 4)) = '</p>') then
          LSB.AppendLine
        else if (I + 4 <= LLen) and (LowerCase(Copy(AHtml, I, 5)) = '</div') then
          LSB.AppendLine
        else if (I + 4 <= LLen) and (LowerCase(Copy(AHtml, I, 5)) = '</tr>') then
          LSB.AppendLine;
        LImTag := True;
      end
      else if AHtml[I] = '>' then
        LImTag := False
      else if not LImTag then
        LSB.Append(AHtml[I]);
      Inc(I);
    end;
    Result := LSB.ToString;
  finally
    LSB.Free;
  end;

  // Die Entitaeten, die praktisch in jeder Mail vorkommen. Mehr braucht eine
  // Vorschau nicht — wer das Original will, hat body_html.
  Result := StringReplace(Result, '&nbsp;', ' ', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&amp;', '&', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&lt;', '<', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&gt;', '>', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&quot;', '"', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&#39;', '''', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&auml;', 'ä', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&ouml;', 'ö', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&uuml;', 'ü', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '&szlig;', 'ß', [rfReplaceAll, rfIgnoreCase]);

  Result := Result.Trim;
end;

// Nur die Felder holen, die wirklich gebraucht werden — das haelt die Antwort
// klein und macht den Abruf spuerbar schneller.
function JsonStr(AObj: TJSONObject; const AName: string): string;
var
  LWert: TJSONValue;
begin
  Result := '';
  if AObj = nil then
    Exit;
  LWert := AObj.Values[AName];
  if (LWert = nil) or (LWert is TJSONNull) then
    Exit;
  Result := LWert.Value;
end;

function JsonInt(AObj: TJSONObject; const AName: string; AVorgabe: Integer = 0): Integer;
var
  LWert: TJSONValue;
begin
  Result := AVorgabe;
  if AObj = nil then
    Exit;
  LWert := AObj.Values[AName];
  if (LWert = nil) or (LWert is TJSONNull) then
    Exit;
  Result := StrToIntDef(LWert.Value, AVorgabe);
end;

function JsonBool(AObj: TJSONObject; const AName: string): Boolean;
var
  LWert: TJSONValue;
begin
  Result := False;
  if AObj = nil then
    Exit;
  LWert := AObj.Values[AName];
  Result := (LWert is TJSONTrue) or
            ((LWert <> nil) and SameText(LWert.Value, 'true'));
end;

function JsonObj(AObj: TJSONObject; const AName: string): TJSONObject;
var
  LWert: TJSONValue;
begin
  Result := nil;
  if AObj = nil then
    Exit;
  LWert := AObj.Values[AName];
  if LWert is TJSONObject then
    Result := TJSONObject(LWert);
end;

function JsonArr(AObj: TJSONObject; const AName: string): TJSONArray;
var
  LWert: TJSONValue;
begin
  Result := nil;
  if AObj = nil then
    Exit;
  LWert := AObj.Values[AName];
  if LWert is TJSONArray then
    Result := TJSONArray(LWert);
end;

// Graph liefert Zeitpunkte immer als ISO 8601 in UTC ("2026-08-01T09:12:33Z").
// UTC wird auch gespeichert — die C#-Seite tut dasselbe (msg.Date.UtcDateTime),
// sonst haetten die beiden Wege unterschiedliche Zeiten in derselben Spalte.
function GraphZeit(const AIso: string): TDateTime;
begin
  Result := 0;
  if AIso = '' then
    Exit;
  try
    Result := ISO8601ToDate(AIso, True);
  except
    Result := 0;
  end;
end;

// Adressliste aus einem Graph-Empfaengerfeld: [{emailAddress:{name,address}}]
function GraphAdressen(AArr: TJSONArray): string;
var
  I: Integer;
  LEintrag, LAdr: TJSONObject;
  LName, LMail: string;
begin
  Result := '';
  if AArr = nil then
    Exit;
  for I := 0 to AArr.Count - 1 do
  begin
    if not (AArr.Items[I] is TJSONObject) then
      Continue;
    LEintrag := TJSONObject(AArr.Items[I]);
    LAdr := JsonObj(LEintrag, 'emailAddress');
    if LAdr = nil then
      Continue;
    LName := JsonStr(LAdr, 'name');
    LMail := JsonStr(LAdr, 'address');
    if LMail = '' then
      Continue;
    if Result <> '' then
      Result := Result + ', ';
    if (LName <> '') and not SameText(LName, LMail) then
      Result := Result + LName + ' <' + LMail + '>'
    else
      Result := Result + LMail;
  end;
end;

function Kuerze(const AText: string; AMax: Integer): string;
begin
  if Length(AText) <= AMax then
    Result := AText
  else
    Result := Copy(AText, 1, AMax);
end;

{ ── TGraphMail ──────────────────────────────────────────────────────────── }

constructor TGraphMail.Create(AConnection: TFDConnection;
  const ASchluessel: string);
begin
  inherited Create;
  FConn := AConnection;
  FSchluessel := ASchluessel;
end;

procedure TGraphMail.Melde(const AText: string);
begin
  if Assigned(FOnStatus) then
    FOnStatus(Self, AText);
end;

procedure TGraphMail.Melde(const AText: string; const AArgs: array of const);
begin
  Melde(Format(AText, AArgs));
end;

procedure TGraphMail.Warte(ASekunden: Integer);
begin
  if Assigned(FOnWarten) then
    FOnWarten(Self, ASekunden, FAbbruch)
  else
    Sleep(ASekunden * 1000);
end;

{ ── Datenbank ───────────────────────────────────────────────────────────── }

function TGraphMail.SqlWert(const ASql: string;
  const AParams: array of Variant): Variant;
var
  LQry: TFDQuery;
  I: Integer;
begin
  Result := Null;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FConn;
    LQry.SQL.Text := ASql;
    for I := 0 to High(AParams) do
      LQry.Params[I].Value := AParams[I];
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.Fields[0].AsVariant;
  finally
    LQry.Free;
  end;
end;

procedure TGraphMail.SqlAus(const ASql: string; const AParams: array of Variant);
var
  LQry: TFDQuery;
  I: Integer;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FConn;
    LQry.SQL.Text := ASql;
    for I := 0 to High(AParams) do
      LQry.Params[I].Value := AParams[I];
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TGraphMail.LadeKonto(AKontoId: Integer);
var
  LQry: TFDQuery;
begin
  FKonto := Default(TGraphKonto);
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FConn;
    // Ueber Spaltennamen lesen, nicht ueber Indizes: email_konto ist an einem
    // einzigen Tag dreimal gewachsen — mit Indizes verschiebt sich bei jeder
    // neuen Spalte still alles. (Dieselbe Lehre wie in MailBridge.cs.)
    LQry.SQL.Text :=
      'SELECT konto_id, mandant_id, email_adresse, anzeige_name, benutzername, ' +
      '       oauth_tenant, oauth_client_id, oauth_authority, graph_basis_url, ' +
      '       oauth_scopes, oauth_flow, max_abruf, max_anhang_kb, ' +
      '       timeout_sekunden, nur_kopfdaten, ordner_filter, abruf_ab_datum ' +
      'FROM email_konto WHERE konto_id = :k';
    LQry.ParamByName('k').AsInteger := AKontoId;
    LQry.Open;
    if LQry.IsEmpty then
      raise EGraphFehler.CreateFmt('Konto %d gibt es nicht.', [AKontoId]);

    FKonto.KontoId      := LQry.FieldByName('konto_id').AsInteger;
    FKonto.MandantId    := LQry.FieldByName('mandant_id').AsInteger;
    FKonto.EmailAdresse := LQry.FieldByName('email_adresse').AsString;
    FKonto.AnzeigeName  := LQry.FieldByName('anzeige_name').AsString;
    FKonto.Benutzername := LQry.FieldByName('benutzername').AsString;
    FKonto.Tenant       := LQry.FieldByName('oauth_tenant').AsString.Trim;
    FKonto.ClientId     := LQry.FieldByName('oauth_client_id').AsString.Trim;
    FKonto.Authority    := LQry.FieldByName('oauth_authority').AsString.Trim;
    FKonto.BasisUrl     := LQry.FieldByName('graph_basis_url').AsString.Trim;
    FKonto.Scopes       := LQry.FieldByName('oauth_scopes').AsString.Trim;
    FKonto.Flow         := LQry.FieldByName('oauth_flow').AsString.Trim;
    FKonto.MaxAbruf     := LQry.FieldByName('max_abruf').AsInteger;
    FKonto.MaxAnhangKb  := LQry.FieldByName('max_anhang_kb').AsInteger;
    FKonto.TimeoutSek   := LQry.FieldByName('timeout_sekunden').AsInteger;
    FKonto.NurKopfdaten := LQry.FieldByName('nur_kopfdaten').AsBoolean;
    FKonto.OrdnerFilter := LQry.FieldByName('ordner_filter').AsString.Trim;
    if not LQry.FieldByName('abruf_ab_datum').IsNull then
      FKonto.AbrufAbDatum := LQry.FieldByName('abruf_ab_datum').AsDateTime;
  finally
    LQry.Free;
  end;

  // Vorbelegungen, damit ein leeres Feld nicht zum Abbruch fuehrt
  if FKonto.Authority = '' then
    FKonto.Authority := 'https://login.microsoftonline.com';
  if FKonto.BasisUrl = '' then
    FKonto.BasisUrl := 'https://graph.microsoft.com/v1.0';
  if FKonto.Scopes = '' then
    FKonto.Scopes := 'offline_access https://graph.microsoft.com/Mail.ReadWrite ' +
      'https://graph.microsoft.com/Mail.Send';
  if FKonto.ClientId = '' then
    FKonto.ClientId := CClientIdFallback;
  if FKonto.TimeoutSek <= 0 then
    FKonto.TimeoutSek := 60;

  FKonto.Authority := FKonto.Authority.TrimRight(['/']);
  FKonto.BasisUrl := FKonto.BasisUrl.TrimRight(['/']);

  // Ein Token aus einer frueheren Sitzung koennte noch gelten
  FAccessToken := '';
  FTokenBis := 0;
end;

function TGraphMail.TenantOderCommon: string;
begin
  Result := FKonto.Tenant;
  if Result = '' then
    // 'organizations' statt 'common': Postfaecher liegen bei Firmenkunden im
    // Tenant, nicht in einem privaten Microsoft-Konto. Wer beides braucht,
    // traegt 'common' im Feld Tenant ein.
    Result := 'organizations';
end;

function TGraphMail.TokenEndpunkt: string;
begin
  Result := FKonto.Authority + '/' + TenantOderCommon + '/oauth2/v2.0/token';
end;

function TGraphMail.RefreshTokenLesen: string;
var
  LWert: Variant;
begin
  LWert := SqlWert('SELECT fn_konto_oauth_refresh_lesen(:k, :s)',
    [FKonto.KontoId, FSchluessel]);
  if VarIsNull(LWert) then
    Result := ''
  else
    Result := VarToStr(LWert);
end;

procedure TGraphMail.TokenSpeichern(const ARefresh, AAccess: string;
  AGueltigBis: TDateTime);
begin
  SqlAus('SELECT fn_konto_oauth_setzen(:k, :r, :a, :g, :s)',
    [FKonto.KontoId, ARefresh, AAccess, AGueltigBis, FSchluessel]);
end;

{ ── HTTP ────────────────────────────────────────────────────────────────── }

function TGraphMail.HttpFormular(const AUrl: string; AFelder: TStrings;
  out AStatus: Integer): string;
var
  LClient: THTTPClient;
  LResp: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  try
    LClient.ConnectionTimeout := FKonto.TimeoutSek * 1000;
    LClient.ResponseTimeout := FKonto.TimeoutSek * 1000;
    LClient.AcceptCharSet := 'utf-8';
    LResp := LClient.Post(AUrl, AFelder, nil, TEncoding.UTF8);
    AStatus := LResp.StatusCode;
    Result := LResp.ContentAsString(TEncoding.UTF8);
  finally
    LClient.Free;
  end;
end;

function TGraphMail.HttpJson(const AUrl, AMethode, ABody: string;
  out AStatus: Integer): string;
var
  LClient: THTTPClient;
  LResp: IHTTPResponse;
  LStrom: TStringStream;
  LKopf: TNetHeaders;
begin
  LClient := THTTPClient.Create;
  LStrom := nil;
  try
    LClient.ConnectionTimeout := FKonto.TimeoutSek * 1000;
    LClient.ResponseTimeout := FKonto.TimeoutSek * 1000;
    LClient.AcceptCharSet := 'utf-8';

    LKopf := [TNetHeader.Create('Authorization', 'Bearer ' + FAccessToken),
              TNetHeader.Create('Accept', 'application/json')];

    if SameText(AMethode, 'GET') then
      LResp := LClient.Get(AUrl, nil, LKopf)
    else
    begin
      LKopf := LKopf + [TNetHeader.Create('Content-Type', 'application/json')];
      LStrom := TStringStream.Create(ABody, TEncoding.UTF8);
      if SameText(AMethode, 'PATCH') then
        LResp := LClient.Patch(AUrl, LStrom, nil, LKopf)
      else
        LResp := LClient.Post(AUrl, LStrom, nil, LKopf);
    end;

    AStatus := LResp.StatusCode;
    Result := LResp.ContentAsString(TEncoding.UTF8);
  finally
    LStrom.Free;
    LClient.Free;
  end;
end;

// Holt die Fehlermeldung aus einer Graph-Antwort. Graph antwortet im Fehlerfall
// mit {"error":{"code":"...","message":"..."}} — die message ist brauchbarer
// Klartext und gehoert deshalb in die Meldung an den Anwender.
function GraphFehlertext(const AInhalt: string; AStatus: Integer): string;
var
  LWert: TJSONValue;
  LFehler: TJSONObject;
begin
  Result := '';
  LWert := TJSONObject.ParseJSONValue(AInhalt);
  try
    if LWert is TJSONObject then
    begin
      LFehler := JsonObj(TJSONObject(LWert), 'error');
      if LFehler <> nil then
        Result := JsonStr(LFehler, 'message');
      if Result = '' then
      begin
        // Der Anmeldeserver antwortet anders als Graph selbst
        Result := JsonStr(TJSONObject(LWert), 'error_description');
        if Result = '' then
          Result := JsonStr(TJSONObject(LWert), 'error');
      end;
    end;
  finally
    LWert.Free;
  end;
  if Result = '' then
    Result := Format('HTTP %d: %s', [AStatus, Kuerze(AInhalt, 300)]);
end;

function TGraphMail.GraphGet(const APfadOderUrl: string): TJSONObject;
var
  LUrl, LInhalt: string;
  LStatus: Integer;
  LWert: TJSONValue;
  LZweiterVersuch: Boolean;
begin
  if APfadOderUrl.StartsWith('http', True) then
    LUrl := APfadOderUrl                      // Folgeseite aus @odata.nextLink
  else
    LUrl := FKonto.BasisUrl + APfadOderUrl;

  LZweiterVersuch := False;
  repeat
    if not TokenSicherstellen then
      raise EGraphFehler.Create('Kein gueltiges Zugriffstoken. Bitte erst anmelden.');

    LInhalt := HttpJson(LUrl, 'GET', '', LStatus);

    // 401 heisst fast immer: Token abgelaufen. Einmal erneuern und wiederholen
    // — nicht oefter, sonst dreht sich das im Kreis, wenn die Berechtigung
    // wirklich fehlt.
    if (LStatus = 401) and not LZweiterVersuch then
    begin
      LZweiterVersuch := True;
      FAccessToken := '';
      FTokenBis := 0;
      Continue;
    end;
    Break;
  until False;

  if LStatus >= 400 then
    raise EGraphFehler.Create(GraphFehlertext(LInhalt, LStatus));

  LWert := TJSONObject.ParseJSONValue(LInhalt);
  if not (LWert is TJSONObject) then
  begin
    LWert.Free;
    raise EGraphFehler.Create('Unerwartete Antwort von Graph (kein JSON-Objekt).');
  end;
  Result := TJSONObject(LWert);
end;

function TGraphMail.GraphPost(const APfad, ABody: string): TJSONObject;
var
  LInhalt: string;
  LStatus: Integer;
  LWert: TJSONValue;
begin
  Result := nil;
  if not TokenSicherstellen then
    raise EGraphFehler.Create('Kein gueltiges Zugriffstoken. Bitte erst anmelden.');

  LInhalt := HttpJson(FKonto.BasisUrl + APfad, 'POST', ABody, LStatus);
  if LStatus >= 400 then
    raise EGraphFehler.Create(GraphFehlertext(LInhalt, LStatus));

  // sendMail antwortet mit 202 und leerem Rumpf — das ist kein Fehler
  if LInhalt.Trim = '' then
    Exit;
  LWert := TJSONObject.ParseJSONValue(LInhalt);
  if LWert is TJSONObject then
    Result := TJSONObject(LWert)
  else
    LWert.Free;
end;

{ ── Token ───────────────────────────────────────────────────────────────── }

function TGraphMail.TokenSicherstellen: Boolean;
begin
  if (FAccessToken <> '') and (FTokenBis > TTimeZone.Local.ToUniversalTime(Now) + CTokenPuffer) then
    Exit(True);
  Result := TokenErneuern;
end;

// Tauscht das Refresh-Token gegen ein frisches Zugriffstoken. Microsoft gibt
// dabei fast immer auch ein NEUES Refresh-Token aus — das muss gespeichert
// werden, sonst laeuft der Zugang irgendwann still aus.
function TGraphMail.TokenErneuern: Boolean;
var
  LFelder: TStringList;
  LInhalt, LRefreshAlt, LRefreshNeu: string;
  LStatus: Integer;
  LAntwort: TJSONValue;
  LObj: TJSONObject;
begin
  Result := False;
  LRefreshAlt := RefreshTokenLesen;
  if LRefreshAlt = '' then
    Exit;

  LFelder := TStringList.Create;
  try
    LFelder.Values['client_id'] := FKonto.ClientId;
    LFelder.Values['grant_type'] := 'refresh_token';
    LFelder.Values['refresh_token'] := LRefreshAlt;
    LFelder.Values['scope'] := FKonto.Scopes;
    LInhalt := HttpFormular(TokenEndpunkt, LFelder, LStatus);
  finally
    LFelder.Free;
  end;

  if LStatus >= 400 then
  begin
    // Das Refresh-Token ist verbraucht oder widerrufen. Es stehen zu lassen
    // waere irrefuehrend — die Maske soll "nicht angemeldet" zeigen.
    Melde('Anmeldung abgelaufen: %s', [GraphFehlertext(LInhalt, LStatus)]);
    SqlAus('SELECT fn_konto_oauth_loeschen(:k)', [FKonto.KontoId]);
    Exit;
  end;

  LAntwort := TJSONObject.ParseJSONValue(LInhalt);
  try
    if not (LAntwort is TJSONObject) then
      Exit;
    LObj := TJSONObject(LAntwort);
    FAccessToken := JsonStr(LObj, 'access_token');
    if FAccessToken = '' then
      Exit;
    FTokenBis := TTimeZone.Local.ToUniversalTime(Now) +
      JsonInt(LObj, 'expires_in', 3600) / SecsPerDay;

    LRefreshNeu := JsonStr(LObj, 'refresh_token');
    if LRefreshNeu = '' then
      LRefreshNeu := LRefreshAlt;
    TokenSpeichern(LRefreshNeu, FAccessToken, FTokenBis);
    Result := True;
  finally
    LAntwort.Free;
  end;
end;

{ ── Anmeldung per Geraetecode ───────────────────────────────────────────── }

function TGraphMail.Anmelden(AKontoId: Integer): string;
var
  LFelder: TStringList;
  LInhalt, LDeviceCode, LFehlerCode: string;
  LStatus, LIntervall, LGesamtSek, LVerstrichen: Integer;
  LAntwort: TJSONValue;
  LObj: TJSONObject;
begin
  FAbbruch := False;
  try
    LadeKonto(AKontoId);

    if not SameText(FKonto.Flow, 'device') then
      Exit('FEHLER: Nur das Geraetecode-Verfahren ist gebaut. Im Reiter ' +
        '"Erweitert" bitte OAuth-Verfahren auf "Geraetecode" stellen.');

    // Schritt 1: Code anfordern
    LFelder := TStringList.Create;
    try
      LFelder.Values['client_id'] := FKonto.ClientId;
      LFelder.Values['scope'] := FKonto.Scopes;
      LInhalt := HttpFormular(FKonto.Authority + '/' + TenantOderCommon +
        '/oauth2/v2.0/devicecode', LFelder, LStatus);
    finally
      LFelder.Free;
    end;

    if LStatus >= 400 then
      Exit('FEHLER: ' + GraphFehlertext(LInhalt, LStatus));

    LAntwort := TJSONObject.ParseJSONValue(LInhalt);
    try
      if not (LAntwort is TJSONObject) then
        Exit('FEHLER: Unerwartete Antwort des Anmeldeservers.');
      LObj := TJSONObject(LAntwort);
      LDeviceCode := JsonStr(LObj, 'device_code');
      LIntervall := JsonInt(LObj, 'interval', 5);
      LGesamtSek := JsonInt(LObj, 'expires_in', 900);

      if Assigned(FOnCode) then
        FOnCode(Self, JsonStr(LObj, 'user_code'),
          JsonStr(LObj, 'verification_uri'), JsonStr(LObj, 'message'));
    finally
      LAntwort.Free;
    end;

    if LDeviceCode = '' then
      Exit('FEHLER: Der Anmeldeserver hat keinen Geraetecode geliefert.');

    // Schritt 2: warten, bis der Anwender den Code eingetippt hat.
    // Das Intervall gibt der Server vor — schnelleres Fragen quittiert er mit
    // 'slow_down', dann wird der Abstand vergroessert.
    LVerstrichen := 0;
    while LVerstrichen < LGesamtSek do
    begin
      Warte(LIntervall);
      Inc(LVerstrichen, LIntervall);
      if FAbbruch then
        Exit('FEHLER: Anmeldung abgebrochen.');

      LFelder := TStringList.Create;
      try
        LFelder.Values['client_id'] := FKonto.ClientId;
        LFelder.Values['grant_type'] := 'urn:ietf:params:oauth:grant-type:device_code';
        LFelder.Values['device_code'] := LDeviceCode;
        LInhalt := HttpFormular(TokenEndpunkt, LFelder, LStatus);
      finally
        LFelder.Free;
      end;

      LAntwort := TJSONObject.ParseJSONValue(LInhalt);
      try
        if not (LAntwort is TJSONObject) then
          Continue;
        LObj := TJSONObject(LAntwort);

        if LStatus < 400 then
        begin
          FAccessToken := JsonStr(LObj, 'access_token');
          FTokenBis := TTimeZone.Local.ToUniversalTime(Now) +
            JsonInt(LObj, 'expires_in', 3600) / SecsPerDay;
          TokenSpeichern(JsonStr(LObj, 'refresh_token'), FAccessToken, FTokenBis);

          if JsonStr(LObj, 'refresh_token') = '' then
            Exit('OK: Angemeldet - aber OHNE Dauerzugang. Es fehlt die ' +
              'Berechtigung "offline_access" in den Scopes; nach etwa einer ' +
              'Stunde muss neu angemeldet werden.');
          Exit('OK: Angemeldet. Der Zugang bleibt bestehen, bis er im ' +
            'Microsoft-Konto widerrufen wird.');
        end;

        LFehlerCode := JsonStr(LObj, 'error');
        if SameText(LFehlerCode, 'authorization_pending') then
          Melde('Warte auf die Eingabe des Codes ...')
        else if SameText(LFehlerCode, 'slow_down') then
          Inc(LIntervall, 5)
        else if SameText(LFehlerCode, 'expired_token') then
          Exit('FEHLER: Der Geraetecode ist abgelaufen. Bitte noch einmal.')
        else if SameText(LFehlerCode, 'authorization_declined') then
          Exit('FEHLER: Die Anmeldung wurde abgelehnt.')
        else
          Exit('FEHLER: ' + GraphFehlertext(LInhalt, LStatus));
      finally
        LAntwort.Free;
      end;
    end;

    Result := 'FEHLER: Zeit abgelaufen, der Code wurde nicht eingegeben.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

function TGraphMail.Abmelden(AKontoId: Integer): string;
begin
  try
    LadeKonto(AKontoId);
    SqlAus('SELECT fn_konto_oauth_loeschen(:k)', [AKontoId]);
    FAccessToken := '';
    FTokenBis := 0;
    // Ehrlich bleiben: geloescht ist nur die lokale Kopie.
    Result := 'OK: Die gespeicherte Anmeldung wurde entfernt. Der Zugang ' +
      'selbst besteht beim Anbieter weiter - wer ihn wirklich entziehen will, ' +
      'muss das im Microsoft-Konto unter "Apps mit Zugriff" tun.';
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

function TGraphMail.AnmeldeStatus(AKontoId: Integer): string;
var
  LStatus: Variant;
  LBis: Variant;
begin
  try
    LStatus := SqlWert('SELECT fn_konto_oauth_status(:k)', [AKontoId]);
    if VarIsNull(LStatus) or (VarToStr(LStatus) = 'keins') then
      Exit('Graph: nicht angemeldet.');

    LBis := SqlWert('SELECT oauth_gueltig_bis FROM email_konto WHERE konto_id = :k',
      [AKontoId]);
    Result := 'Graph: angemeldet (Token ' + VarToStr(LStatus) + ' abgelegt)';
    if not VarIsNull(LBis) then
      Result := Result + ', Zugriffstoken gilt bis ' +
        FormatDateTime('dd.mm.yyyy hh:nn', TTimeZone.Local.ToLocalTime(VarToDateTime(LBis))) + ' Uhr';
    Result := Result + '.';
  except
    on E: Exception do
      Result := 'Graph: Status nicht lesbar (' + E.Message + ')';
  end;
end;

function TGraphMail.VerbindungTesten(AKontoId: Integer): string;
var
  LObj: TJSONObject;
begin
  try
    LadeKonto(AKontoId);
    if RefreshTokenLesen = '' then
      Exit('FEHLER: Fuer dieses Konto ist noch keine Anmeldung hinterlegt. ' +
        'Bitte zuerst auf "Bei Microsoft anmelden" klicken.');

    LObj := GraphGet('/me');
    try
      Result := Format('OK: Verbunden als %s (%s).',
        [JsonStr(LObj, 'displayName'),
         JsonStr(LObj, 'userPrincipalName')]);
      // Ein Postfach im falschen Konto ist ein haeufiger und teurer Irrtum
      if (FKonto.EmailAdresse <> '') and
         not SameText(JsonStr(LObj, 'userPrincipalName'), FKonto.EmailAdresse) and
         not SameText(JsonStr(LObj, 'mail'), FKonto.EmailAdresse) then
        Result := Result + ' ACHTUNG: Das angemeldete Postfach ist NICHT ' +
          FKonto.EmailAdresse + ' - abgerufen wird das angemeldete.';
    finally
      LObj.Free;
    end;
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

{ ── Ordner ──────────────────────────────────────────────────────────────── }

function TGraphMail.OrdnerSpeichern(const AGraphId, AName, APfad: string;
  AParentId, AGesamt, AUngelesen: Integer): Integer;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FConn;
    // Upsert auf den bestehenden Schluessel (konto_id, voller_pfad): so
    // bekommen auch Ordner, die frueher ueber IMAP angelegt wurden, ihre
    // Graph-Kennung nachtraeglich und werden nicht doppelt gefuehrt.
    LQry.SQL.Text :=
      'INSERT INTO email_ordner (konto_id, parent_id, name, voller_pfad, ' +
      '                          graph_id, anzahl_gesamt, anzahl_ungelesen, ' +
      '                          letzter_abruf) ' +
      'VALUES (:k, :p, :n, :pf, :g, :ges, :ung, now()) ' +
      'ON CONFLICT (konto_id, voller_pfad) DO UPDATE SET ' +
      '  parent_id = EXCLUDED.parent_id, name = EXCLUDED.name, ' +
      '  graph_id = EXCLUDED.graph_id, anzahl_gesamt = EXCLUDED.anzahl_gesamt, ' +
      '  anzahl_ungelesen = EXCLUDED.anzahl_ungelesen, ' +
      '  letzter_abruf = now() ' +
      'RETURNING ordner_id';
    LQry.ParamByName('k').AsInteger := FKonto.KontoId;
    if AParentId > 0 then
      LQry.ParamByName('p').AsInteger := AParentId
    else
      LQry.ParamByName('p').Clear;
    LQry.ParamByName('n').AsString := Kuerze(AName, 200);
    LQry.ParamByName('pf').AsString := Kuerze(APfad, 500);
    LQry.ParamByName('g').AsString := Kuerze(AGraphId, 300);
    LQry.ParamByName('ges').AsInteger := AGesamt;
    LQry.ParamByName('ung').AsInteger := AUngelesen;
    LQry.Open;
    if LQry.IsEmpty then
      Result := 0
    else
      Result := LQry.Fields[0].AsInteger;
  finally
    LQry.Free;
  end;
end;

// Ein Ordner zaehlt als gewuenscht, wenn ordner_filter leer ist oder sein
// Pfad einen der aufgezaehlten Namen enthaelt. Ohne diesen Filter zieht ein
// gewachsenes Archiv jedes Mal mit.
function TGraphMail.OrdnerAufnehmen(const APfad: string): Boolean;
var
  LTeile: TArray<string>;
  LTeil: string;
begin
  if FKonto.OrdnerFilter = '' then
    Exit(True);
  Result := False;
  LTeile := FKonto.OrdnerFilter.Split([',', ';']);
  for LTeil in LTeile do
    if (LTeil.Trim <> '') and
       (Pos(LowerCase(LTeil.Trim), LowerCase(APfad)) > 0) then
      Exit(True);
end;

procedure TGraphMail.OrdnerEbene(const AUrl, AElternPfad: string;
  AElternId: Integer; var AAnzahl: Integer);
var
  LSeite: TJSONObject;
  LWerte: TJSONArray;
  LOrdner: TJSONObject;
  I, LId: Integer;
  LPfad, LNaechste, LName: string;
begin
  LNaechste := AUrl;
  while LNaechste <> '' do
  begin
    LSeite := GraphGet(LNaechste);
    try
      LWerte := JsonArr(LSeite, 'value');
      if LWerte <> nil then
        for I := 0 to LWerte.Count - 1 do
        begin
          if not (LWerte.Items[I] is TJSONObject) then
            Continue;
          LOrdner := TJSONObject(LWerte.Items[I]);
          LName := JsonStr(LOrdner, 'displayName');
          if AElternPfad = '' then
            LPfad := LName
          else
            LPfad := AElternPfad + '/' + LName;

          LId := OrdnerSpeichern(JsonStr(LOrdner, 'id'), LName, LPfad,
            AElternId, JsonInt(LOrdner, 'totalItemCount'),
            JsonInt(LOrdner, 'unreadItemCount'));
          Inc(AAnzahl);

          // Unterordner nachziehen. childFolderCount erspart den Aufruf bei
          // Ordnern ohne Kinder — das ist die Mehrzahl.
          if JsonInt(LOrdner, 'childFolderCount') > 0 then
            OrdnerEbene('/me/mailFolders/' +
              TNetEncoding.URL.Encode(JsonStr(LOrdner, 'id')) +
              '/childFolders?$top=100', LPfad, LId, AAnzahl);
        end;
      LNaechste := JsonStr(LSeite, '@odata.nextLink');
    finally
      LSeite.Free;
    end;
  end;
end;

function TGraphMail.OrdnerAbgleichen(AKontoId: Integer): string;
var
  LAnzahl: Integer;
begin
  try
    LadeKonto(AKontoId);
    if RefreshTokenLesen = '' then
      Exit('FEHLER: Fuer dieses Konto ist noch keine Anmeldung hinterlegt. ' +
        'Bitte zuerst auf "Bei Microsoft anmelden" klicken.');

    LAnzahl := 0;
    Melde('Ordner werden abgeglichen ...');
    OrdnerEbene('/me/mailFolders?$top=100', '', 0, LAnzahl);
    Result := Format('OK: %d Ordner abgeglichen.', [LAnzahl]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

{ ── Nachrichten ─────────────────────────────────────────────────────────── }

function TGraphMail.NachrichtSpeichern(AOrdnerId: Integer;
  AMsg: TJSONObject): Integer;
var
  LQry: TFDQuery;
  LVon: TJSONObject;
  LKoerper: TJSONObject;
  LText, LHtml, LTyp: string;
begin
  Result := 0;

  LKoerper := JsonObj(AMsg, 'body');
  LText := '';
  LHtml := '';
  if LKoerper <> nil then
  begin
    LTyp := LowerCase(JsonStr(LKoerper, 'contentType'));
    if LTyp = 'html' then
    begin
      LHtml := JsonStr(LKoerper, 'content');
      // body_text zusaetzlich fuellen, sonst bleibt das Textfeld im Fenster
      // leer — die Anzeige haengt daran. Das Original bleibt in body_html.
      LText := HtmlZuText(LHtml);
    end
    else
      LText := JsonStr(LKoerper, 'content');
  end;
  if LText = '' then
    LText := JsonStr(AMsg, 'bodyPreview');

  LVon := JsonObj(AMsg, 'from');
  if LVon <> nil then
    LVon := JsonObj(LVon, 'emailAddress');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FConn;
    // uid bleibt leer — das ist ein IMAP-Begriff. Der Duplikatschutz laeuft
    // hier ueber (konto_id, graph_id), siehe sql/email_graph.sql.
    LQry.SQL.Text :=
      'INSERT INTO email_nachricht ' +
      '  (mandant_id, konto_id, ordner_id, graph_id, conversation_id, ' +
      '   message_id, richtung, von_adresse, von_name, an_adressen, ' +
      '   cc_adressen, betreff, gesendet_am, empfangen_am, body_text, ' +
      '   body_html, gelesen, hat_anhang) ' +
      'VALUES (:m, :k, :o, :gid, :cid, :mid, :ri, :vona, :vonn, :an, :cc, ' +
      '        :betreff, :ges, :emp, :text, :html, :gel, :anh) ' +
      'ON CONFLICT (konto_id, graph_id) DO NOTHING ' +
      'RETURNING nachricht_id';
    LQry.ParamByName('m').AsInteger := FKonto.MandantId;
    LQry.ParamByName('k').AsInteger := FKonto.KontoId;
    LQry.ParamByName('o').AsInteger := AOrdnerId;
    LQry.ParamByName('gid').AsString := Kuerze(JsonStr(AMsg, 'id'), 300);
    LQry.ParamByName('cid').AsString := Kuerze(JsonStr(AMsg, 'conversationId'), 300);
    LQry.ParamByName('mid').AsString := Kuerze(JsonStr(AMsg, 'internetMessageId'), 500);
    // Richtung aus dem Absender ableiten: was von der eigenen Adresse kommt,
    // liegt im Gesendet-Ordner und ist ausgehend.
    if SameText(JsonStr(LVon, 'address'), FKonto.EmailAdresse) then
      LQry.ParamByName('ri').AsString := 'ausgehend'
    else
      LQry.ParamByName('ri').AsString := 'eingehend';
    LQry.ParamByName('vona').AsString := Kuerze(JsonStr(LVon, 'address'), 320);
    LQry.ParamByName('vonn').AsString := Kuerze(JsonStr(LVon, 'name'), 200);
    LQry.ParamByName('an').AsString := GraphAdressen(JsonArr(AMsg, 'toRecipients'));
    LQry.ParamByName('cc').AsString := GraphAdressen(JsonArr(AMsg, 'ccRecipients'));
    LQry.ParamByName('betreff').AsString := Kuerze(JsonStr(AMsg, 'subject'), 998);
    LQry.ParamByName('ges').AsDateTime := GraphZeit(JsonStr(AMsg, 'sentDateTime'));
    LQry.ParamByName('emp').AsDateTime := GraphZeit(JsonStr(AMsg, 'receivedDateTime'));
    LQry.ParamByName('text').AsString := LText;
    LQry.ParamByName('html').AsString := LHtml;
    LQry.ParamByName('gel').AsBoolean := JsonBool(AMsg, 'isRead');
    LQry.ParamByName('anh').AsBoolean := JsonBool(AMsg, 'hasAttachments');
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.Fields[0].AsInteger;
  finally
    LQry.Free;
  end;
end;

// Anhaenge in ZWEI Schritten: erst die Liste OHNE Inhalt, dann nur die, die
// unter der Groessengrenze liegen, einzeln mit Inhalt. Holte man alles auf
// einmal, kaeme eine 30-MB-Praesentation als Base64 mit, obwohl sie gar nicht
// gespeichert werden soll.
procedure TGraphMail.AnhaengeHolen(ANachrichtId: Integer;
  const AMsgGraphId: string; var AUebersprungen: Integer);
var
  LListe, LAnhang, LVoll: TJSONObject;
  LWerte: TJSONArray;
  I, LGroesse, LDokId: Integer;
  LTyp, LName, LMime, LInhalt: string;
  LBytes: TBytes;
  LStrom: TBytesStream;
  LQry: TFDQuery;
begin
  LListe := GraphGet('/me/messages/' + TNetEncoding.URL.Encode(AMsgGraphId) +
    '/attachments?$select=id,name,contentType,size,isInline,contentId');
  try
    LWerte := JsonArr(LListe, 'value');
    if LWerte = nil then
      Exit;

    for I := 0 to LWerte.Count - 1 do
    begin
      if not (LWerte.Items[I] is TJSONObject) then
        Continue;
      LAnhang := TJSONObject(LWerte.Items[I]);
      LTyp := JsonStr(LAnhang, '@odata.type');
      LName := JsonStr(LAnhang, 'name');
      LGroesse := JsonInt(LAnhang, 'size');

      // itemAttachment ist eine eingebettete Mail oder ein Termin, kein
      // Dateianhang — die hat keine contentBytes und wird uebersprungen.
      if Pos('fileattachment', LowerCase(LTyp)) = 0 then
      begin
        Inc(AUebersprungen);
        Continue;
      end;

      if (FKonto.MaxAnhangKb > 0) and (LGroesse > FKonto.MaxAnhangKb * 1024) then
      begin
        Inc(AUebersprungen);
        Continue;
      end;

      LVoll := GraphGet('/me/messages/' + TNetEncoding.URL.Encode(AMsgGraphId) +
        '/attachments/' + TNetEncoding.URL.Encode(JsonStr(LAnhang, 'id')));
      try
        LInhalt := JsonStr(LVoll, 'contentBytes');
        if LInhalt = '' then
        begin
          Inc(AUebersprungen);
          Continue;
        end;
        LBytes := TNetEncoding.Base64.DecodeStringToBytes(LInhalt);
        LMime := JsonStr(LVoll, 'contentType');
      finally
        LVoll.Free;
      end;

      // Anhang wird ein normaler dokument-Satz — genau wie auf dem
      // IMAP-Weg (MailBridge.cs). Dadurch liegt er im Dokumentenmanagement
      // und kann spaeter per OCR durchsucht werden.
      LQry := TFDQuery.Create(nil);
      try
        LQry.Connection := FConn;
        LQry.SQL.Text :=
          'INSERT INTO dokument (typ_id, titel, pdf_blob, mime_type, ' +
          '                      dateigroesse_kb, quelle, scan_datum) ' +
          'VALUES ((SELECT typ_id FROM dokument_typ ' +
          '          WHERE bezeichnung = ''E-Mail-Anhang'' ' +
          '            AND mandant_id IS NULL LIMIT 1), ' +
          '        :t, :b, :m, :kb, ''email'', now()) ' +
          'RETURNING dokument_id';
        LQry.ParamByName('t').AsString := Kuerze(LName, 300);
        // Ueber einen Strom, NICHT ueber AsBlob: AsBlob ist RawByteString und
        // wuerde die Bytes als Zeichen umdeuten; AsBytes ist bei TFDParam eine
        // indizierte Eigenschaft (fuer Array-Bindung) und passt hier nicht.
        LStrom := TBytesStream.Create(LBytes);
        try
          LQry.ParamByName('b').LoadFromStream(LStrom, ftBlob);
        finally
          LStrom.Free;
        end;
        LQry.ParamByName('m').AsString := Kuerze(LMime, 100);
        LQry.ParamByName('kb').AsInteger := Length(LBytes) div 1024;
        LQry.Open;
        if LQry.IsEmpty then
          Continue;
        LDokId := LQry.Fields[0].AsInteger;
      finally
        LQry.Free;
      end;

      SqlAus('INSERT INTO email_anhang (nachricht_id, dokument_id, dateiname, ' +
             '                          inline, content_id) ' +
             'VALUES (:n, :d, :f, :i, :c) ON CONFLICT DO NOTHING',
        [ANachrichtId, LDokId, Kuerze(LName, 300),
         JsonBool(LAnhang, 'isInline'), Kuerze(JsonStr(LAnhang, 'contentId'), 200)]);
    end;
  finally
    LListe.Free;
  end;
end;

function TGraphMail.PostfachAbrufen(AKontoId: Integer): string;
var
  LQry: TFDQuery;
  LSeite: TJSONObject;
  LWerte: TJSONArray;
  LMsg: TJSONObject;
  I, LOrdnerId, LNeu, LUebersprungen, LAnhaengeUeber: Integer;
  LGraphOrdner, LUrl, LAuswahl, LFilter: string;
  LNachrichtId: Integer;
begin
  try
    LadeKonto(AKontoId);
    if RefreshTokenLesen = '' then
      Exit('FEHLER: Fuer dieses Konto ist noch keine Anmeldung hinterlegt. ' +
        'Bitte zuerst auf "Bei Microsoft anmelden" klicken.');

    // Nur die Felder anfordern, die gespeichert werden. Ohne $select liefert
    // Graph jedes Mal den vollen Datensatz samt Rohkopfzeilen.
    LAuswahl := 'id,conversationId,internetMessageId,subject,from,' +
                'toRecipients,ccRecipients,sentDateTime,receivedDateTime,' +
                'isRead,hasAttachments,bodyPreview';
    if not FKonto.NurKopfdaten then
      LAuswahl := LAuswahl + ',body';

    LFilter := '';
    if FKonto.AbrufAbDatum > 0 then
      LFilter := '&$filter=receivedDateTime ge ' +
        FormatDateTime('yyyy-mm-dd', FKonto.AbrufAbDatum) + 'T00:00:00Z';

    LNeu := 0;
    LUebersprungen := 0;
    LAnhaengeUeber := 0;

    LQry := TFDQuery.Create(nil);
    try
      LQry.Connection := FConn;
      LQry.SQL.Text :=
        'SELECT ordner_id, graph_id, voller_pfad FROM email_ordner ' +
        'WHERE konto_id = :k AND graph_id IS NOT NULL ORDER BY voller_pfad';
      LQry.ParamByName('k').AsInteger := AKontoId;
      LQry.Open;

      if LQry.IsEmpty then
        Exit('FEHLER: Es sind noch keine Graph-Ordner bekannt. Bitte zuerst ' +
          'die Ordner abgleichen.');

      while not LQry.Eof do
      begin
        LOrdnerId := LQry.FieldByName('ordner_id').AsInteger;
        LGraphOrdner := LQry.FieldByName('graph_id').AsString;

        if not OrdnerAufnehmen(LQry.FieldByName('voller_pfad').AsString) then
        begin
          LQry.Next;
          Continue;
        end;

        Melde('Hole %s ...', [LQry.FieldByName('voller_pfad').AsString]);

        // Die NEUESTEN max_abruf Nachrichten. Dieselbe Bedeutung wie auf dem
        // IMAP-Weg: aeltere Post wird uebersprungen und spaeter NICHT
        // nachgeholt. Wer die Historie will, setzt max_abruf hoch.
        LUrl := '/me/mailFolders/' + TNetEncoding.URL.Encode(LGraphOrdner) +
          '/messages?$select=' + LAuswahl +
          '&$orderby=receivedDateTime desc' + LFilter;
        if FKonto.MaxAbruf > 0 then
          LUrl := LUrl + '&$top=' + IntToStr(FKonto.MaxAbruf)
        else
          LUrl := LUrl + '&$top=100';

        LSeite := GraphGet(LUrl);
        try
          LWerte := JsonArr(LSeite, 'value');
          if LWerte <> nil then
            for I := 0 to LWerte.Count - 1 do
            begin
              if not (LWerte.Items[I] is TJSONObject) then
                Continue;
              LMsg := TJSONObject(LWerte.Items[I]);

              LNachrichtId := NachrichtSpeichern(LOrdnerId, LMsg);
              if LNachrichtId = 0 then
              begin
                // Schon vorhanden — kein Fehler, nur nichts zu tun
                Inc(LUebersprungen);
                Continue;
              end;
              Inc(LNeu);

              if JsonBool(LMsg, 'hasAttachments') and not FKonto.NurKopfdaten then
                AnhaengeHolen(LNachrichtId, JsonStr(LMsg, 'id'), LAnhaengeUeber);
            end;
        finally
          LSeite.Free;
        end;

        LQry.Next;
      end;
    finally
      LQry.Free;
    end;

    Result := Format('OK: %d neue Nachrichten, %d bereits vorhanden.',
      [LNeu, LUebersprungen]);
    if LAnhaengeUeber > 0 then
      Result := Result + Format(' %d Anhaenge ausgelassen (zu gross oder ' +
        'eingebettete Nachricht).', [LAnhaengeUeber]);
  except
    on E: Exception do
      Result := 'FEHLER: ' + E.Message;
  end;
end;

{ ── Senden ──────────────────────────────────────────────────────────────── }

// Baut den Empfaengerteil, den Graph erwartet:
// [{"emailAddress":{"address":"..."}}]. Die Anzeigenamen aus "Name <adresse>"
// werden weggelassen — Graph setzt sie ohnehin selbst aus dem Verzeichnis.
function EmpfaengerArray(const AListe: string): TJSONArray;
var
  LTeile: TArray<string>;
  LTeil, LAdr: string;
  LPos: Integer;
  LObj, LInner: TJSONObject;
begin
  Result := TJSONArray.Create;
  LTeile := AListe.Split([',', ';']);
  for LTeil in LTeile do
  begin
    LAdr := LTeil.Trim;
    if LAdr = '' then
      Continue;
    LPos := Pos('<', LAdr);
    if LPos > 0 then
      LAdr := Copy(LAdr, LPos + 1, MaxInt).Replace('>', '').Trim;
    if Pos('@', LAdr) = 0 then
      Continue;
    LInner := TJSONObject.Create;
    LInner.AddPair('address', LAdr);
    LObj := TJSONObject.Create;
    LObj.AddPair('emailAddress', LInner);
    Result.AddElement(LObj);
  end;
end;

function TGraphMail.NachrichtSenden(ANachrichtId: Integer): string;
var
  LQry: TFDQuery;
  LKonto: Integer;
  LBetreff, LText, LHtml, LAn, LCc: string;
  LNachricht, LKoerper, LRumpf: TJSONObject;
  LEmpfaenger: TJSONArray;
begin
  try
    LQry := TFDQuery.Create(nil);
    try
      LQry.Connection := FConn;
      LQry.SQL.Text :=
        'SELECT konto_id, betreff, body_text, body_html, an_adressen, ' +
        '       cc_adressen, versand_status ' +
        'FROM email_nachricht WHERE nachricht_id = :n';
      LQry.ParamByName('n').AsInteger := ANachrichtId;
      LQry.Open;
      if LQry.IsEmpty then
        Exit('FEHLER: Diese Nachricht gibt es nicht.');
      if SameText(LQry.FieldByName('versand_status').AsString, 'gesendet') then
        Exit('FEHLER: Diese Nachricht wurde bereits versendet.');

      LKonto    := LQry.FieldByName('konto_id').AsInteger;
      LBetreff  := LQry.FieldByName('betreff').AsString;
      LText     := LQry.FieldByName('body_text').AsString;
      LHtml     := LQry.FieldByName('body_html').AsString;
      LAn       := LQry.FieldByName('an_adressen').AsString;
      LCc       := LQry.FieldByName('cc_adressen').AsString;
    finally
      LQry.Free;
    end;

    LadeKonto(LKonto);
    if RefreshTokenLesen = '' then
      Exit('FEHLER: Fuer dieses Konto ist noch keine Anmeldung hinterlegt.');

    LEmpfaenger := EmpfaengerArray(LAn);
    if LEmpfaenger.Count = 0 then
    begin
      LEmpfaenger.Free;
      Exit('FEHLER: Es ist kein gueltiger Empfaenger eingetragen.');
    end;

    LKoerper := TJSONObject.Create;
    if LHtml <> '' then
    begin
      LKoerper.AddPair('contentType', 'HTML');
      LKoerper.AddPair('content', LHtml);
    end
    else
    begin
      LKoerper.AddPair('contentType', 'Text');
      LKoerper.AddPair('content', LText);
    end;

    LNachricht := TJSONObject.Create;
    LNachricht.AddPair('subject', LBetreff);
    LNachricht.AddPair('body', LKoerper);
    LNachricht.AddPair('toRecipients', LEmpfaenger);
    if LCc.Trim <> '' then
      LNachricht.AddPair('ccRecipients', EmpfaengerArray(LCc));

    LRumpf := TJSONObject.Create;
    try
      LRumpf.AddPair('message', LNachricht);
      // Die gesendete Mail gehoert ins Postfach des Anwenders — sonst fehlt
      // sie in Outlook und am Handy.
      LRumpf.AddPair('saveToSentItems', TJSONBool.Create(True));

      // sendMail antwortet mit 202 und leerem Rumpf; GraphPost liefert dann nil.
      GraphPost('/me/sendMail', LRumpf.ToJSON).Free;
    finally
      LRumpf.Free;
    end;

    SqlAus('UPDATE email_nachricht SET versand_status = ''gesendet'', ' +
           '       versendet_am = now(), versand_fehler = NULL ' +
           ' WHERE nachricht_id = :n', [ANachrichtId]);
    Result := 'OK: Nachricht versendet.';
  except
    on E: Exception do
    begin
      // Den Fehler an der Nachricht festhalten, sonst steht sie ewig auf
      // "neu" und niemand weiss, warum sie nicht rausging.
      try
        SqlAus('UPDATE email_nachricht SET versand_status = ''fehler'', ' +
               '       versand_fehler = :f WHERE nachricht_id = :n',
          [Kuerze(E.Message, 2000), ANachrichtId]);
      except
        // Wenn nicht einmal das geht, hilft nur die Meldung an den Anwender
      end;
      Result := 'FEHLER: ' + E.Message;
    end;
  end;
end;

end.
