unit NotfallFrm;

// NOTFALLZUGANG ("Sicherheitstuer") — Herstellerzugang fuer Supportfaelle.
//
// AUFRUF: Strg+Alt+Umschalt+G im Hauptfenster. Bewusst NICHT Alt+AltGr+G:
// AltGr IST auf Windows die Kombination Strg+Alt, damit waere die Vorgabe
// effektiv Strg+Alt+G — das kollidiert leichter und loest eher versehentlich
// aus. Die Umschalttaste macht es eindeutig. Wer es anders will, aendert
// cNotfallTaste unten.
//
// WARUM NICHTS DAVON IN DER DATENBANK LIEGT (Walters Vorgabe): Dieser Zugang
// soll gerade dann noch funktionieren, wenn die Datenbank das Problem IST —
// und er soll sie auf einen Sicherungsstand zuruecksetzen koennen. Laege der
// Mechanismus in derselben Datenbank, wuerde er beim Zuruecksetzen
// mitgeloescht und waere im entscheidenden Moment weg.
//
// TAN-LISTE STATT FESTEM PASSWORT: Ein festes Passwort waere einmal
// weitergegeben und danach dauerhaft entwertet. Jede TAN gilt genau einmal;
// der Verbrauch steht in einer lokalen Datei (siehe cVerbrauchDatei), NICHT
// in der Datenbank — sonst waeren nach einem Zuruecksetzen alle TANs wieder
// gueltig, und die Sicherheitstuer stuende offen.
//
// WAS DIESER ZUGANG KANN:
//   - Sicherung ziehen (pg_dump), damit vor jedem Eingriff ein Stand da ist
//   - Datenbank auf den letzten Sicherungsstand zuruecksetzen
//
// EHRLICHE GRENZE: Die Hashes stehen im Programm. Wer die EXE hat und Zeit
// investiert, findet sie — schuetzen tut allein die Laenge der TAN
// (20 Zeichen). Das ist eine Huerde, kein Tresor. Fuer den Zweck (der Kunde
// soll anrufen statt selbst zu basteln) reicht es.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.IOUtils, System.Hash, System.DateUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls;

const
  // Die Tastenkombination haengt als ShortCut an der Action cmdNotfall in
  // uFrmMain (Strg+Alt+Umschalt+G = 57415). Ueber eine Action statt ueber
  // KeyPreview, weil KeyPreview am MDI-Hauptfenster nicht greift, sobald ein
  // Kindfenster den Fokus hat — der Zugang muss aber immer erreichbar sein.

  // SHA-256 der TANs. ERSETZEN mit der Ausgabe von Tools/tan_generator.py —
  // die hier eingetragenen sind ein PLATZHALTER aus einem Testlauf und
  // gehoeren vor dem Ausliefern getauscht.
  cTanAnzahl = 10;
  cTanHashes: array[1..cTanAnzahl] of string = (
    'afc1d7c1b648728a0e0ac93222b37309d9c35fe68e2362b8a391a2596b69ba69',
    'd2a378558ecad9f9823e1166250ad53894acd931c06dd8db86d440425c080aea',
    '0e61fea627c89aa954468c7e126b8793c297d80f059d8b46b6222a96ba8bd2bd',
    'c9d8d1cb13f67d65a9d78eed7eacbde96dbc57108f947ffd33c3be359eb6c34e',
    'c61f67b5c1cfaacd5489dccee98afe20b2c79239d93c0e082e0abaf55cadd19b',
    '82bad1aaa5c4f7ea2a47aabccf7dcd5629341b23a7450cd8a204d148e9cc99f7',
    '6432a8fa460c6751e936c258b5dbeec3544227041cf31c84cf7127fdf2f3f3c2',
    '6408abe16e0200b8561d50516dcb0610e2af541ce9e946a62b60dc41bca8d8d9',
    'e5d4c16932e4d063344a53b7606d3fe6e179644ba4a66677bffb353239768e9b',
    '571e20f9096ff176a6c66794722773f20596340f95b249e73cf5cf54e9d9aa8a'
  );

type
  TfrmNotfall = class(TForm)
    lblTitel: TLabel;
    lblHinweis: TLabel;
    lblTan: TLabel;
    edtTan: TEdit;
    btnPruefen: TButton;
    pnlAktionen: TPanel;
    lblAktionen: TLabel;
    btnSicherung: TButton;
    btnWiederherstellen: TButton;
    lblStand: TLabel;
    memProtokoll: TMemo;
    btnSchliessen: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnPruefenClick(Sender: TObject);
    procedure btnSicherungClick(Sender: TObject);
    procedure btnWiederherstellenClick(Sender: TObject);
    procedure btnSchliessenClick(Sender: TObject);
  private
    FFreigegeben: Boolean;
    FVerwendeteTan: Integer;
    procedure Melde(const AText: string);
    procedure StandZeigen;
    function LetzteSicherung(out ADatei: string; out AZeit: TDateTime): Boolean;
  public
    class procedure Oeffnen;
  end;

// ── Ablageorte ───────────────────────────────────────────────────────────────
// Bewusst unter ProgramData und nicht neben der EXE: das Programmverzeichnis
// ist unter Windows fuer normale Benutzer schreibgeschuetzt, und die
// Verbrauchsliste muss beschreibbar sein.
function NotfallVerzeichnis: string;
function SicherungsVerzeichnis: string;

implementation

{$R *.dfm}

uses
  Winapi.ShellAPI,
  PGManagerDm;

const
  cVerbrauchDatei = 'notfall.dat';
  cProtokollDatei = 'notfall_protokoll.txt';

function NotfallVerzeichnis: string;
begin
  // ProgramData statt des Benutzerprofils: der TAN-Verbrauch gilt fuer die
  // Maschine, nicht fuer den angemeldeten Windows-Benutzer - sonst waere
  // dieselbe TAN unter einem zweiten Windows-Konto wieder gueltig.
  Result := TPath.Combine(GetEnvironmentVariable('ProgramData'), 'Heisenberg');
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);
end;

function SicherungsVerzeichnis: string;
begin
  Result := TPath.Combine(NotfallVerzeichnis, 'Sicherungen');
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);
end;

// ── TAN-Verwaltung ───────────────────────────────────────────────────────────

// Bindestriche, Leerzeichen und Kleinschreibung sind egal — die TAN wird oft
// am Telefon durchgegeben und dabei anders getippt als gedruckt.
function TanNormalisieren(const ATan: string): string;
begin
  Result := UpperCase(StringReplace(StringReplace(Trim(ATan), '-', '',
    [rfReplaceAll]), ' ', '', [rfReplaceAll]));
end;

function TanHash(const ATan: string): string;
begin
  Result := LowerCase(THashSHA2.GetHashString(TanNormalisieren(ATan),
    THashSHA2.TSHA2Version.SHA256));
end;

function VerbrauchDateiPfad: string;
begin
  Result := TPath.Combine(NotfallVerzeichnis, cVerbrauchDatei);
end;

// Liste der bereits verbrauchten TAN-Nummern
function VerbrauchteTans: TArray<string>;
begin
  if TFile.Exists(VerbrauchDateiPfad) then
    Result := TFile.ReadAllLines(VerbrauchDateiPfad)
  else
    Result := [];
end;

function IstVerbraucht(ANummer: Integer): Boolean;
var
  LZeile: string;
begin
  Result := False;
  for LZeile in VerbrauchteTans do
    if Trim(LZeile).StartsWith(IntToStr(ANummer) + ';') then
      Exit(True);
end;

procedure TanVerbrauchen(ANummer: Integer);
var
  LZeile: string;
begin
  LZeile := Format('%d;%s;%s', [ANummer,
    FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), GetEnvironmentVariable('COMPUTERNAME')]);
  TFile.AppendAllText(VerbrauchDateiPfad, LZeile + sLineBreak);
end;

// Sucht die eingegebene TAN in der Liste. Liefert die Nummer oder 0.
// Verbrauchte TANs zaehlen NICHT als Treffer — das ist der Kern des
// Einmal-Gedankens.
function TanPruefen(const AEingabe: string; out AVerbrauchtBereits: Boolean): Integer;
var
  LHash: string;
  I: Integer;
begin
  Result := 0;
  AVerbrauchtBereits := False;
  if Trim(AEingabe) = '' then
    Exit;

  LHash := TanHash(AEingabe);
  for I := 1 to cTanAnzahl do
    if SameText(LHash, cTanHashes[I]) then
    begin
      if IstVerbraucht(I) then
      begin
        AVerbrauchtBereits := True;
        Exit(0);
      end;
      Exit(I);
    end;
end;

procedure Protokollieren(const AText: string);
begin
  TFile.AppendAllText(TPath.Combine(NotfallVerzeichnis, cProtokollDatei),
    Format('%s  %s  %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
      GetEnvironmentVariable('COMPUTERNAME'), AText]) + sLineBreak);
end;

// ── Formular ─────────────────────────────────────────────────────────────────

class procedure TfrmNotfall.Oeffnen;
var
  LFrm: TfrmNotfall;
begin
  LFrm := TfrmNotfall.Create(nil);
  try
    LFrm.ShowModal;
  finally
    LFrm.Free;
  end;
end;

procedure TfrmNotfall.FormCreate(Sender: TObject);
begin
  FFreigegeben := False;
  FVerwendeteTan := 0;
  pnlAktionen.Enabled := False;

  lblHinweis.Caption :=
    'Dieser Zugang ist f' + #252 + 'r St' + #246 + 'rungsf' + #228 + 'lle ' +
    'gedacht und wird protokolliert. Jede TAN gilt genau EINMAL. Nach dem ' +
    'Verbrauch aller TANs muss eine neue Liste ins Programm eingespielt werden.';

  Protokollieren('Notfalldialog geoeffnet');
  StandZeigen;
end;

procedure TfrmNotfall.Melde(const AText: string);
begin
  memProtokoll.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
  memProtokoll.SelStart := Length(memProtokoll.Text);
  memProtokoll.Update;
end;

function TfrmNotfall.LetzteSicherung(out ADatei: string;
  out AZeit: TDateTime): Boolean;
var
  LDateien: TArray<string>;
  LDatei: string;
  LZeit: TDateTime;
begin
  Result := False;
  ADatei := '';
  AZeit := 0;
  if not TDirectory.Exists(SicherungsVerzeichnis) then
    Exit;

  LDateien := TDirectory.GetFiles(SicherungsVerzeichnis, '*.sql');
  for LDatei in LDateien do
  begin
    LZeit := TFile.GetLastWriteTime(LDatei);
    if LZeit > AZeit then
    begin
      AZeit := LZeit;
      ADatei := LDatei;
      Result := True;
    end;
  end;
end;

procedure TfrmNotfall.StandZeigen;
var
  LDatei: string;
  LZeit: TDateTime;
  LOffen, I: Integer;
begin
  LOffen := 0;
  for I := 1 to cTanAnzahl do
    if not IstVerbraucht(I) then
      Inc(LOffen);

  if LetzteSicherung(LDatei, LZeit) then
    lblStand.Caption := Format(
      'Letzte Sicherung: %s (%s)   |   noch %d von %d TANs offen',
      [FormatDateTime('dd.mm.yyyy hh:nn', LZeit), ExtractFileName(LDatei),
       LOffen, cTanAnzahl])
  else
    lblStand.Caption := Format(
      'Noch KEINE Sicherung vorhanden   |   noch %d von %d TANs offen',
      [LOffen, cTanAnzahl]);
end;

procedure TfrmNotfall.btnPruefenClick(Sender: TObject);
var
  LNummer: Integer;
  LVerbraucht: Boolean;
begin
  LNummer := TanPruefen(edtTan.Text, LVerbraucht);

  if LVerbraucht then
  begin
    Protokollieren('TAN abgewiesen: bereits verbraucht');
    ShowMessage('Diese TAN wurde bereits verwendet. Jede TAN gilt nur ' +
      'einmal - bitte die n' + #228 + 'chste verwenden.');
    edtTan.Clear;
    Exit;
  end;

  if LNummer = 0 then
  begin
    Protokollieren('TAN abgewiesen: unbekannt');
    ShowMessage('Diese TAN ist nicht g' + #252 + 'ltig.');
    edtTan.Clear;
    Exit;
  end;

  // Erst hier verbrauchen - eine abgewiesene TAN soll nicht verfallen
  TanVerbrauchen(LNummer);
  Protokollieren(Format('TAN %d akzeptiert - Zugang freigegeben', [LNummer]));

  FFreigegeben := True;
  FVerwendeteTan := LNummer;
  pnlAktionen.Enabled := True;
  edtTan.Enabled := False;
  btnPruefen.Enabled := False;

  Melde(Format('Zugang mit TAN %d freigegeben.', [LNummer]));
  StandZeigen;
end;

// ── Sicherung ziehen ─────────────────────────────────────────────────────────
// Ruft pg_dump als eigenen Prozess auf. Bewusst das Kommandozeilenwerkzeug
// und kein SQL: einen vollstaendigen, wiedereinspielbaren Stand bekommt man
// nur so — ueber die Datenbankverbindung liesse sich das Schema nicht
// sauber mitziehen.
function ProzessAusfuehren(const AProgramm, AParameter, APasswort: string;
  out AAusgabe: string): Cardinal;
var
  LStartInfo: TStartupInfo;
  LProcInfo: TProcessInformation;
  LKommando: string;
  LExit: Cardinal;
begin
  Result := Cardinal(-1);
  AAusgabe := '';

  // Das Passwort geht ueber die Umgebungsvariable, nicht ueber die
  // Kommandozeile - Kommandozeilen sind fuer andere Prozesse sichtbar.
  SetEnvironmentVariable('PGPASSWORD', PChar(APasswort));
  try
    LKommando := '"' + AProgramm + '" ' + AParameter;

    FillChar(LStartInfo, SizeOf(LStartInfo), 0);
    LStartInfo.cb := SizeOf(LStartInfo);
    LStartInfo.dwFlags := STARTF_USESHOWWINDOW;
    LStartInfo.wShowWindow := SW_HIDE;

    if not CreateProcess(nil, PChar(LKommando), nil, nil, False,
      CREATE_NO_WINDOW, nil, nil, LStartInfo, LProcInfo) then
    begin
      AAusgabe := SysErrorMessage(GetLastError);
      Exit;
    end;

    try
      WaitForSingleObject(LProcInfo.hProcess, 10 * 60 * 1000);   // max 10 Min
      GetExitCodeProcess(LProcInfo.hProcess, LExit);
      Result := LExit;
    finally
      CloseHandle(LProcInfo.hThread);
      CloseHandle(LProcInfo.hProcess);
    end;
  finally
    SetEnvironmentVariable('PGPASSWORD', nil);
  end;
end;

// Sucht pg_dump/psql. PostgreSQL liegt unter Windows ueblicherweise in
// C:\Program Files\PostgreSQL\<version>\bin — die hoechste gefundene Version
// gewinnt, weil neuere Werkzeuge auch aeltere Server bedienen koennen,
// umgekehrt aber nicht.
function PostgresWerkzeug(const AName: string): string;
var
  LBasis, LVerzeichnis: string;
  LVerzeichnisse: TArray<string>;
  I: Integer;
begin
  Result := '';
  LBasis := TPath.Combine(GetEnvironmentVariable('ProgramFiles'), 'PostgreSQL');
  if not TDirectory.Exists(LBasis) then
    Exit;

  LVerzeichnisse := TDirectory.GetDirectories(LBasis);
  for I := High(LVerzeichnisse) downto Low(LVerzeichnisse) do
  begin
    LVerzeichnis := TPath.Combine(LVerzeichnisse[I], 'bin');
    if TFile.Exists(TPath.Combine(LVerzeichnis, AName)) then
      Exit(TPath.Combine(LVerzeichnis, AName));
  end;
end;

procedure TfrmNotfall.btnSicherungClick(Sender: TObject);
var
  LDump, LZiel, LAusgabe: string;
  LExit: Cardinal;
begin
  if not FFreigegeben then
    Exit;

  LDump := PostgresWerkzeug('pg_dump.exe');
  if LDump = '' then
  begin
    ShowMessage('pg_dump wurde nicht gefunden. Bitte pr' + #252 + 'fen, ob ' +
      'PostgreSQL unter "Program Files\PostgreSQL" installiert ist.');
    Exit;
  end;

  LZiel := TPath.Combine(SicherungsVerzeichnis,
    'TRTHeisenberg_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.sql');

  Melde('Sicherung wird erstellt ...');
  Screen.Cursor := crHourGlass;
  try
    LExit := ProzessAusfuehren(LDump,
      Format('-h localhost -p 5455 -U postgres -d TRTHeisenberg ' +
             '--clean --if-exists -f "%s"', [LZiel]),
      'postgres', LAusgabe);
  finally
    Screen.Cursor := crDefault;
  end;

  if (LExit = 0) and TFile.Exists(LZiel) then
  begin
    Melde('Sicherung erstellt: ' + ExtractFileName(LZiel));
    Protokollieren('Sicherung erstellt: ' + LZiel);
  end
  else
  begin
    Melde('FEHLER beim Sichern (Code ' + IntToStr(LExit) + ') ' + LAusgabe);
    Protokollieren('Sicherung fehlgeschlagen, Code ' + IntToStr(LExit));
  end;
  StandZeigen;
end;

// ── Wiederherstellen ─────────────────────────────────────────────────────────
procedure TfrmNotfall.btnWiederherstellenClick(Sender: TObject);
var
  LDatei, LAusgabe, LPsql: string;
  LZeit: TDateTime;
  LExit: Cardinal;
begin
  if not FFreigegeben then
    Exit;

  if not LetzteSicherung(LDatei, LZeit) then
  begin
    ShowMessage('Es liegt keine Sicherung vor. Ohne Sicherungsstand kann ' +
      'nichts wiederhergestellt werden.');
    Exit;
  end;

  if MessageDlg(
    'Die Datenbank wird auf den Stand vom ' +
    FormatDateTime('dd.mm.yyyy hh:nn', LZeit) + ' zur' + #252 + 'ckgesetzt.' +
    sLineBreak + sLineBreak +
    'ALLE seither erfassten Daten gehen verloren. Vorher unbedingt eine ' +
    'aktuelle Sicherung ziehen, damit dieser Schritt selbst r' + #252 +
    'ckg' + #228 + 'ngig gemacht werden kann.' + sLineBreak + sLineBreak +
    'Wirklich fortfahren?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  LPsql := PostgresWerkzeug('psql.exe');
  if LPsql = '' then
  begin
    ShowMessage('psql wurde nicht gefunden.');
    Exit;
  end;

  // Verbindung trennen: eine Datenbank laesst sich nicht zurueckspielen,
  // solange die Anwendung selbst darauf haelt.
  Melde('Verbindung wird getrennt ...');
  try
    PGManagerDm.dmPGManager.Disconnect;
  except
    // Wenn schon nicht verbunden, ist auch gut
  end;

  Melde('Sicherung wird eingespielt: ' + ExtractFileName(LDatei));
  Screen.Cursor := crHourGlass;
  try
    // Der Dump wurde mit --clean --if-exists erzeugt, raeumt also selbst auf
    LExit := ProzessAusfuehren(LPsql,
      Format('-h localhost -p 5455 -U postgres -d TRTHeisenberg ' +
             '-v ON_ERROR_STOP=1 -f "%s"', [LDatei]),
      'postgres', LAusgabe);
  finally
    Screen.Cursor := crDefault;
  end;

  if LExit = 0 then
  begin
    Melde('Wiederherstellung abgeschlossen.');
    Protokollieren(Format('Wiederhergestellt aus %s (TAN %d)',
      [LDatei, FVerwendeteTan]));
    ShowMessage('Die Datenbank wurde auf den Stand vom ' +
      FormatDateTime('dd.mm.yyyy hh:nn', LZeit) + ' zur' + #252 +
      'ckgesetzt.' + sLineBreak + sLineBreak +
      'Heisenberg sollte jetzt beendet und neu gestartet werden.');
  end
  else
  begin
    Melde('FEHLER beim Einspielen (Code ' + IntToStr(LExit) + ') ' + LAusgabe);
    Protokollieren('Wiederherstellung fehlgeschlagen, Code ' + IntToStr(LExit));
    ShowMessage('Die Wiederherstellung ist fehlgeschlagen. Die Datenbank ' +
      'kann jetzt in einem unvollst' + #228 + 'ndigen Zustand sein - bitte ' +
      'das Protokoll pr' + #252 + 'fen:' + sLineBreak + NotfallVerzeichnis);
  end;
end;

procedure TfrmNotfall.btnSchliessenClick(Sender: TObject);
begin
  Protokollieren('Notfalldialog geschlossen');
  Close;
end;

end.
