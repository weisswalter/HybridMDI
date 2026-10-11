unit BenutzerDm;

// Benutzer, Anmeldung und Sitzungszustand.
//
// WALTERS MODELL (siehe sql/benutzer.sql):
//   Administrator im STAMMMANDANTEN = globaler Administrator, sieht alle
//   Mandanten und ordnet Personen zu. Alle anderen sehen genau die
//   Mandanten, denen sie zugeordnet sind — ein Coach in Mandant 3 kann nur
//   in Mandant 3 arbeiten.
//
// DIESES DATAMODULE HAELT DEN SITZUNGSZUSTAND: wer ist angemeldet, ist er
// globaler Administrator. Es ist damit das Gegenstueck zu TdmMandant, das
// den aktiven Mandanten haelt — zusammen ergeben beide den Arbeitskontext.
//
// GEPRUEFT WIRD IN DER DATENBANK, nicht hier: Passwoerter werden per bcrypt
// in fn_benutzer_anmelden verglichen, die Anwendung sieht den Hash nie. Ein
// Nachbau der Pruefung in Delphi waere eine zweite Wahrheit.
//
// NOTBREMSE: Solange KEIN Benutzer angelegt ist, verlangt das Programm keine
// Anmeldung (siehe AnmeldungErforderlich). Damit sperrt sich niemand aus,
// nur weil die Tabellen existieren — die Einfuehrung kann schrittweise
// passieren.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,
  // Im interface, weil die Zentral-Funktion unten den Typ zurueckgibt.
  ZentraleDatenDm,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmBenutzer = class(TdmModuleTemplate)
    // Kopien aus dem zentralen Datenmodul (Views bzw. mandant-Tabelle).
    qryBenutzer: TFDMemTable;
    dsBenutzer: TDataSource;
    tblBenutzerMandant: TFDMemTable;
    // E-Mail-Adressen je Person samt Markierung "gilt als Anmeldung".
    memPersonEmail: TFDMemTable;
    dsBenutzerMandant: TDataSource;
    qryPersonAuswahl: TFDMemTable;
    dsPersonAuswahl: TDataSource;
    qryMandantAuswahl: TFDMemTable;
    dsMandantAuswahl: TDataSource;
  private
    // ── Sitzungszustand ───────────────────────────────────────────────────
    FBenutzerId: Integer;
    FPersonId: Integer;
    FAnzeigename: string;
    FIstGlobalAdmin: Boolean;
    function Conn: TFDConnection;
    // Kurzform fuer das zentrale Datenmodul - wird hier oft gebraucht.
    function Zentral: TdmZentraleDaten;
    procedure AppBenutzerSetzen(const AName: string);
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen Datenmodul.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    procedure OpenBenutzer;

    property BenutzerId: Integer read FBenutzerId;
    property PersonId: Integer read FPersonId;
    property Anzeigename: string read FAnzeigename;
    property IstGlobalAdmin: Boolean read FIstGlobalAdmin;
    function Angemeldet: Boolean;

    // ── Anmeldung ─────────────────────────────────────────────────────────
    // Gibt es ueberhaupt Benutzer? Wenn nein, laeuft das Programm ohne
    // Anmeldung weiter (Erstinstallation / schrittweise Einfuehrung).
    function AnmeldungErforderlich: Boolean;
    // Anmeldepflicht ist ein ausdruecklicher Schalter, nicht mehr
    // "es gibt halt ein Konto".
    function AnmeldepflichtSetzen(AAn: Boolean): string;
    // Adressen der Person zum aktuell gewaehlten Konto.
    procedure LadeAnmeldeAdressen(AItems: TStrings;
      AMarkiert: TList<Boolean>);
    function AnmeldeAdresseSetzen(AEmailId: Integer;
      AJa: Boolean): string;
    function AktuellePersonId: Integer;
    function GibtEsGlobalenAdmin: Boolean;
    // Liefert '' bei Erfolg, sonst die Meldung aus der Datenbank.
    function Anmelden(const AName, APasswort: string): string;
    procedure Abmelden;
    function ErstenAdminAnlegen(const AName, APasswort: string): string;
    function PasswortAendern(const AAlt, ANeu: string): string;

    // ── Rechte ────────────────────────────────────────────────────────────
    // Ohne Anmeldung liefern beide True — sonst waere das Programm im
    // Notbremsen-Betrieb (kein Benutzer angelegt) unbedienbar.
    function DarfMandant(AMandantId: Integer): Boolean;
    function IstAdminIn(AMandantId: Integer): Boolean;
    // Fuellt AItems mit den erlaubten Mandanten (Objects = mandant_id).
    procedure LadeErlaubteMandanten(AItems: TStrings);

    // ── Verwaltung ────────────────────────────────────────────────────────
    procedure LadeBenutzer;
    procedure LadeZuordnungen(ABenutzerId: Integer);
    function BenutzerAnlegen(const AName, APasswort: string;
      APersonId, AMandantId: Integer; const ARolle: string): string;
    function PasswortZuruecksetzen(ABenutzerId: Integer;
      const ANeu: string): string;
    function AktivSetzen(ABenutzerId: Integer; AAktiv: Boolean): string;
    function MandantZuordnen(ABenutzerId, AMandantId: Integer;
      const ARolle: string): string;
    function ZuordnungEntfernen(ABenutzerId, AMandantId: Integer): string;
  end;

var
  dmBenutzer: TdmBenutzer;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs, System.Variants,
  BenutzerFrm, System.SyncObjs, uGridMemo;

var
  GSperreBenutzer: TCriticalSection;

class function TdmBenutzer.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmBenutzer) then
  begin
    GSperreBenutzer.Enter;
    try
      if not Assigned(dmBenutzer) then
        Application.CreateForm(TdmBenutzer, dmBenutzer);
    finally
      GSperreBenutzer.Leave;
    end;
  end;
  Result := dmBenutzer;
end;

// Die eine Verbindung des Programms. Bleibt als Funktion erhalten, damit die
// bestehenden Aufrufstellen unveraendert weiterlaufen.
function TdmBenutzer.Conn: TFDConnection;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
end;

function TdmBenutzer.Zentral: TdmZentraleDaten;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
end;


procedure TdmBenutzer.TabellenLaden;
begin
  Zentral.ModulFuellen([
    Zuordnung(qryBenutzer, 'v_benutzer_uebersicht'),
    Zuordnung(qryPersonAuswahl, 'v_person_auswahl'),
    Zuordnung(qryMandantAuswahl, 'mandant'),
    Zuordnung(tblBenutzerMandant, 'benutzer_mandant'),
    Zuordnung(memPersonEmail, 'v_person_email_anmeldung')]);
  // v_benutzer_uebersicht.mandanten/person sind zusammengesetzte Postgres
  // 'text'-Spalten - ohne das haette das Gitter dort nur "(WIDEMEMO)"
  // gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(qryBenutzer);
  qryBenutzer.IndexFieldNames := 'anmeldename';
  qryPersonAuswahl.IndexFieldNames := 'name';
  // Stammmandant zuerst, danach alphabetisch - wie das fruehere ORDER BY.
  qryMandantAuswahl.IndexFieldNames := 'ist_stammmandant:D;mandanten_name';
end;

function TdmBenutzer.Angemeldet: Boolean;
begin
  Result := FBenutzerId > 0;
end;

// ── Anmeldung ───────────────────────────────────────────────────────────────

function TdmBenutzer.AnmeldungErforderlich: Boolean;
begin
  Result := False;
  if not Conn.Connected then
    Exit;
  try
    Result := Zentral.SpAufrufen('fn_anmeldung_erforderlich', []) = True;
  except
    // Tabelle noch nicht angelegt: dann gibt es auch keine Anmeldepflicht
    Result := False;
  end;
end;

function TdmBenutzer.AnmeldepflichtSetzen(AAn: Boolean): string;
begin
  Result := '';
  try
    // Die Funktion weigert sich, ohne ein aktives Konto einzuschalten -
    // sonst waere die Anwendung ausgesperrt.
    Zentral.SpAufrufen('fn_anmeldepflicht_setzen', [AAn]);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmBenutzer.AktuellePersonId: Integer;
begin
  Result := 0;
  if qryBenutzer.Active and not qryBenutzer.IsEmpty then
    Result := qryBenutzer.FieldByName('person_id').AsInteger;
end;

procedure TdmBenutzer.LadeAnmeldeAdressen(AItems: TStrings;
  AMarkiert: TList<Boolean>);
var
  LPerson: Integer;
  LMerker: TBookmark;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    AMarkiert.Clear;
    LPerson := AktuellePersonId;
    if (LPerson = 0) or not memPersonEmail.Active then
      Exit;

    LMerker := memPersonEmail.GetBookmark;
    try
      memPersonEmail.First;
      while not memPersonEmail.Eof do
      begin
        if memPersonEmail.FieldByName('person_id').AsInteger = LPerson then
        begin
          AItems.AddObject(memPersonEmail.FieldByName('email_adresse').AsString,
            TObject(NativeInt(memPersonEmail.FieldByName('email_id').AsInteger)));
          AMarkiert.Add(memPersonEmail.FieldByName('ist_anmeldename').AsBoolean);
        end;
        memPersonEmail.Next;
      end;
    finally
      if memPersonEmail.BookmarkValid(LMerker) then
        memPersonEmail.GotoBookmark(LMerker);
      memPersonEmail.FreeBookmark(LMerker);
    end;
  finally
    AItems.EndUpdate;
  end;
end;

function TdmBenutzer.AnmeldeAdresseSetzen(AEmailId: Integer;
  AJa: Boolean): string;
var
  LPerson, LMandant: Integer;
begin
  Result := '';
  LPerson := AktuellePersonId;
  if LPerson = 0 then
    Exit('Zu diesem Konto ist keine Person hinterlegt.');

  // Die Zuordnung Person/E-Mail haengt am Mandanten; genommen wird der
  // Mandant, unter dem die Adresse erfasst ist.
  LMandant := 0;
  if memPersonEmail.Active and
     memPersonEmail.Locate('person_id;email_id',
       VarArrayOf([LPerson, AEmailId]), []) then
    LMandant := memPersonEmail.FieldByName('mandant_id').AsInteger;
  if LMandant = 0 then
    Exit('Diese Adresse geh' + #246 + 'rt nicht zu dieser Person.');

  try
    Zentral.SpAufrufen('fn_email_anmeldename_setzen',
      [LPerson, AEmailId, LMandant, AJa]);
    Zentral.TabelleAuffrischen('person_email');
    TabellenLaden;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmBenutzer.GibtEsGlobalenAdmin: Boolean;
begin
  try
    Result := Zentral.SpAufrufen('fn_gibt_es_globalen_admin', []) = True;
  except
    Result := False;
  end;
end;

// Hinterlegt den angemeldeten Benutzer in der Datenbanksitzung. Ohne das
// steht im Audit-Log bei jedem Eintrag "postgres" — der ueberschriebene
// Wert waere rekonstruierbar, aber nicht, wer ihn ueberschrieben hat.
procedure TdmBenutzer.AppBenutzerSetzen(const AName: string);
var
  LConn: TFDConnection;
begin
  // Erst in eine Variable: Assigned(Conn) wuerde den Funktionszeiger
  // pruefen, nicht das Ergebnis.
  LConn := Conn;
  if not Assigned(LConn) or not LConn.Connected then
    Exit;
  try
    Zentral.SpAufrufen('fn_app_benutzer_setzen', [AName]);
  except
    // Fehlt die Funktion (Datenbank noch ohne audit_benutzer.sql), darf
    // die Anmeldung daran nicht scheitern. Dann bleibt es beim alten
    // Verhalten, und im Log steht weiterhin die Datenbankrolle.
    on E: Exception do
      ;
  end;
end;

function TdmBenutzer.Anmelden(const AName, APasswort: string): string;
var
  LMem: TFDMemTable;
begin
  Abmelden;
  // fn_benutzer_anmelden liefert mehrere Spalten -> SpAbfragen. Die
  // zurueckgegebene MemTable gehoert uns und muss freigegeben werden.
  LMem := nil;
  try
    try
      LMem := Zentral.SpAbfragen('fn_benutzer_anmelden', [AName, APasswort]);

      if LMem.IsEmpty or LMem.FieldByName('benutzer_id').IsNull then
      begin
        if LMem.IsEmpty then
          Result := 'Anmeldung nicht m' + #246 + 'glich.'
        else
          Result := LMem.FieldByName('meldung').AsString;
        Exit;
      end;

      FBenutzerId     := LMem.FieldByName('benutzer_id').AsInteger;
      FPersonId       := LMem.FieldByName('person_id').AsInteger;
      FAnzeigename    := LMem.FieldByName('anzeigename').AsString;
      FIstGlobalAdmin := LMem.FieldByName('ist_global_admin').AsBoolean;
      Result := '';
      AppBenutzerSetzen(AName);
    except
      on E: Exception do
        Result := 'Anmeldung fehlgeschlagen: ' + E.Message;
    end;
  finally
    LMem.Free;
  end;
end;

procedure TdmBenutzer.Abmelden;
begin
  FBenutzerId := 0;
  FPersonId := 0;
  FAnzeigename := '';
  FIstGlobalAdmin := False;
  // Leerer Name -> ab jetzt wieder die Datenbankrolle im Audit-Log.
  AppBenutzerSetzen('');
end;

function TdmBenutzer.ErstenAdminAnlegen(const AName, APasswort: string): string;
begin
  try
    Zentral.SpAufrufen('fn_ersten_admin_anlegen', [AName, APasswort]);
    Result := '';
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmBenutzer.PasswortAendern(const AAlt, ANeu: string): string;
var
  LMem: TFDMemTable;
  LName: string;
begin
  if not Angemeldet then
    Exit('Es ist niemand angemeldet.');

  // Das alte Passwort wird ueber einen echten Anmeldeversuch geprueft -
  // damit gilt dieselbe Pruefung wie beim Anmelden, ohne sie zu wiederholen.
  // Der Anmeldename kommt aus der bereits geladenen Benutzerliste, statt
  // dafuer noch einmal in die Datenbank zu gehen.
  if not qryBenutzer.Active then
    TabellenLaden;
  if not qryBenutzer.Locate('benutzer_id', FBenutzerId, []) then
    Exit('Der angemeldete Benutzer ist in der Liste nicht auffindbar.');
  LName := qryBenutzer.FieldByName('anmeldename').AsString;

  LMem := nil;
  try
    try
      LMem := Zentral.SpAbfragen('fn_benutzer_anmelden', [LName, AAlt]);
      if LMem.IsEmpty or LMem.FieldByName('benutzer_id').IsNull then
        Exit('Das bisherige Passwort stimmt nicht.');
    except
      on E: Exception do
        Exit('Das bisherige Passwort konnte nicht geprueft werden: ' +
             E.Message);
    end;
  finally
    LMem.Free;
  end;

  try
    Zentral.SpAufrufen('fn_benutzer_passwort_setzen',
      [FBenutzerId, ANeu, False]);
    Result := '';
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

// ── Rechte ──────────────────────────────────────────────────────────────────

function TdmBenutzer.DarfMandant(AMandantId: Integer): Boolean;
begin
  // Notbremsen-Betrieb: ohne Anmeldung ist alles offen, sonst waere das
  // Programm bei einer Erstinstallation nicht bedienbar.
  if not Angemeldet then
    Exit(True);
  if FIstGlobalAdmin then
    Exit(True);

  Result := Zentral.SpAufrufen('fn_benutzer_darf_mandant',
    [FBenutzerId, AMandantId]) = True;
end;

function TdmBenutzer.IstAdminIn(AMandantId: Integer): Boolean;
begin
  if not Angemeldet then
    Exit(True);
  if FIstGlobalAdmin then
    Exit(True);

  Result := Zentral.SpAufrufen('fn_benutzer_ist_admin',
    [FBenutzerId, AMandantId]) = True;
end;

procedure TdmBenutzer.LadeErlaubteMandanten(AItems: TStrings);
var
  LMem: TFDMemTable;
  LEigene: Boolean;
begin
  LEigene := Angemeldet;
  LMem := nil;
  try
    if LEigene then
      LMem := Zentral.SpAbfragen('fn_benutzer_mandanten', [FBenutzerId])
    else
    begin
      // Ohne Anmeldung alle - Notbremsen-Betrieb. Die Liste liegt schon im
      // Speicher, dafuer muss niemand in die Datenbank.
      if not qryMandantAuswahl.Active then
        TabellenLaden;
      qryMandantAuswahl.First;
    end;

    AItems.BeginUpdate;
    try
      AItems.Clear;
      if LEigene then
        while not LMem.Eof do
        begin
          AItems.AddObject(LMem.FieldByName('mandanten_name').AsString,
            TObject(NativeInt(LMem.FieldByName('mandant_id').AsInteger)));
          LMem.Next;
        end
      else
        while not qryMandantAuswahl.Eof do
        begin
          AItems.AddObject(
            qryMandantAuswahl.FieldByName('mandanten_name').AsString,
            TObject(NativeInt(
              qryMandantAuswahl.FieldByName('mandant_id').AsInteger)));
          qryMandantAuswahl.Next;
        end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LMem.Free;
  end;
end;

// ── Verwaltung ──────────────────────────────────────────────────────────────

procedure TdmBenutzer.LadeBenutzer;
begin
  // Erst den zentralen Stand nachziehen, dann die eigene Kopie neu fuellen -
  // sonst zeigt die Liste nach dem Schreiben noch den alten Stand.
  Zentral.TabelleAuffrischen('v_benutzer_uebersicht');
  TabellenLaden;
end;

procedure TdmBenutzer.LadeZuordnungen(ABenutzerId: Integer);
begin
  tblBenutzerMandant.Filtered := False;
  if not tblBenutzerMandant.Active then
    // Speichertabellen kommen aus dem zentralen Datenmodul
    TabellenLaden;
  tblBenutzerMandant.Filter := Format('benutzer_id=%d', [ABenutzerId]);
  tblBenutzerMandant.Filtered := True;
end;

function TdmBenutzer.BenutzerAnlegen(const AName, APasswort: string;
  APersonId, AMandantId: Integer; const ARolle: string): string;
var
  LPerson, LMandant: Variant;
begin
  // 0 heisst "nicht gesetzt" -> als NULL weitergeben, nicht als 0.
  if APersonId > 0 then LPerson := APersonId else LPerson := Null;
  if AMandantId > 0 then LMandant := AMandantId else LMandant := Null;

  try
    Zentral.SpAufrufen('fn_benutzer_anlegen',
      [AName, APasswort, LPerson, LMandant, ARolle]);
    LadeBenutzer;
    Result := '';
  except
    on E: Exception do
      if (Pos('benutzer_anmeldename_key', E.Message) > 0) or
         (Pos('ux_benutzer_name_ci', E.Message) > 0) then
        Result := 'Diesen Anmeldenamen gibt es bereits.'
      else
        Result := E.Message;
  end;
end;

function TdmBenutzer.PasswortZuruecksetzen(ABenutzerId: Integer;
  const ANeu: string): string;
begin
  try
    // true = der Benutzer muss es beim naechsten Anmelden selbst aendern
    Zentral.SpAufrufen('fn_benutzer_passwort_setzen',
      [ABenutzerId, ANeu, True]);
    LadeBenutzer;
    Result := '';
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmBenutzer.AktivSetzen(ABenutzerId: Integer; AAktiv: Boolean): string;
begin
  if (ABenutzerId = FBenutzerId) and not AAktiv then
    Exit('Das eigene Konto kann nicht deaktiviert werden.');

  try
    Zentral.SpAufrufen('fn_benutzer_aktiv_setzen', [ABenutzerId, AAktiv]);
    LadeBenutzer;
    Result := '';
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmBenutzer.MandantZuordnen(ABenutzerId, AMandantId: Integer;
  const ARolle: string): string;
begin
  if (ABenutzerId <= 0) or (AMandantId <= 0) then
    Exit('Bitte Benutzer und Mandant w' + #228 + 'hlen.');

  try
    Zentral.SpAufrufen('fn_benutzer_mandant_setzen',
      [ABenutzerId, AMandantId, ARolle]);
    Zentral.TabelleAuffrischen('benutzer_mandant');
    LadeBenutzer;
    LadeZuordnungen(ABenutzerId);
    Result := '';
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmBenutzer.ZuordnungEntfernen(ABenutzerId, AMandantId: Integer): string;
begin
  try
    Zentral.SpAufrufen('fn_benutzer_mandant_loeschen',
      [ABenutzerId, AMandantId]);
    Zentral.TabelleAuffrischen('benutzer_mandant');
    LadeBenutzer;
    LadeZuordnungen(ABenutzerId);
    Result := '';
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

procedure TdmBenutzer.OpenBenutzer;
begin
  if not Conn.Connected then
  begin
    ShowMessage('Bitte zuerst im PGManager die Datenbankverbindung herstellen.', '');
    Exit;
  end;

  // Nur Administratoren duerfen Konten verwalten. Im Notbremsen-Betrieb
  // (niemand angemeldet, weil es noch keine Benutzer gibt) bleibt es offen,
  // sonst koennte nie jemand den ersten Zugang anlegen.
  if Angemeldet and not FIstGlobalAdmin then
  begin
    ShowMessage('Die Benutzerverwaltung steht nur dem globalen ' +
      'Administrator offen.', '');
    Exit;
  end;

  LadeBenutzer;
  LadeZuordnungen(0);

  if not Assigned(frmBenutzer) then
    frmBenutzer := TfrmBenutzer.Create(Application);
  frmBenutzer.Show;
end;


initialization
  GSperreBenutzer := TCriticalSection.Create;

finalization
  GSperreBenutzer.Free;

end.
