unit MailFrm;

// Mailmodul — Oberflaeche. Aufbau wie KlientFrm/KundeFrm:
//   oben  Kontoauswahl + Aktionsleiste (TJvNavPanelButtonTop)
//   links Ordnerliste, darunter die Nachrichten des gewaehlten Ordners
//   rechts TRibbonPanel mit zwei Reitern:
//     "Nachricht" — Kopfdaten + Textkoerper
//     "Anhaenge"  — Liste der Anhaenge, Doppelklick oeffnet sie
//
// Es wird hier NICHTS dekodiert: Textkoerper und Anhaenge liegen bereits
// fertig in der Datenbank, die MIME-Verarbeitung hat die C#-Seite erledigt
// (siehe MailDm-Kommentar).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmMail = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actAbrufen: TAction;
    actNeuLaden: TAction;
    actGelesen: TAction;
    actGraphAnmelden: TAction;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    pnlTop: TPanel;
    lblKonto: TLabel;
    cboKonto: TDBLookupComboBox;
    btnAbrufen: TJvNavPanelButtonTop;
    btnNeuLaden: TJvNavPanelButtonTop;
    btnGelesen: TJvNavPanelButtonTop;
    pnlLeft: TPanel;
    dbgrdOrdner: TDBGrid;
    splLeft: TSplitter;
    dbgrdNachrichten: TDBGrid;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsNachricht: TTabSheet;
    tsAnhaenge: TTabSheet;
    tsKonto: TTabSheet;
    tsErweitert: TTabSheet;
    barNachricht: TRibbonButtonBar;
    barAnhaenge: TRibbonButtonBar;
    barKonto: TRibbonButtonBar;
    barErweitert: TRibbonButtonBar;
    // Reiter 0: Nachricht
    pnlNachricht: TPanel;
    pnlKopf: TPanel;
    lblVon: TLabel;
    edtVon: TDBEdit;
    lblAn: TLabel;
    edtAn: TDBEdit;
    lblBetreff: TLabel;
    edtBetreff: TDBEdit;
    lblDatum: TLabel;
    edtDatum: TDBEdit;
    memBody: TDBMemo;
    // Reiter 1: Anhaenge
    pnlAnhaenge: TPanel;
    dbgrdAnhaenge: TDBGrid;
    pnlAnhangInfo: TPanel;
    lblAnhangHinweis: TLabel;
    // Reiter 2: Konto (Server- und Zugangsdaten)
    pnlKonto: TPanel;
    pnlKontoButtons: TPanel;
    btnKNeu: TButton;
    btnKAendern: TButton;
    btnKSpeichern: TButton;
    btnKAbbrechen: TButton;
    btnKTesten: TButton;
    lblKBez: TLabel;
    edtKBez: TDBEdit;
    lblKEmail: TLabel;
    edtKEmail: TDBEdit;
    lblKAnzeige: TLabel;
    edtKAnzeige: TDBEdit;
    lblKMaxAbruf: TLabel;
    edtKMaxAbruf: TDBEdit;
    lblKImapHost: TLabel;
    edtKImapHost: TDBEdit;
    lblKImapPort: TLabel;
    edtKImapPort: TDBEdit;
    cbxKImapSsl: TDBCheckBox;
    lblKSmtpHost: TLabel;
    edtKSmtpHost: TDBEdit;
    lblKSmtpPort: TLabel;
    edtKSmtpPort: TDBEdit;
    cbxKSmtpTls: TDBCheckBox;
    lblKBenutzer: TLabel;
    edtKBenutzer: TDBEdit;
    cbxKStandard: TDBCheckBox;
    cbxKAktiv: TDBCheckBox;
    lblKPasswort: TLabel;
    edtKPasswort: TEdit;
    lblKSchluessel: TLabel;
    edtKSchluessel: TEdit;
    btnKPasswortSetzen: TButton;
    cbxKKlartext: TCheckBox;
    lblKSmtpBenutzer: TLabel;
    edtKSmtpBenutzer: TDBEdit;
    lblKSmtpPasswort: TLabel;
    edtKSmtpPasswort: TEdit;
    btnKSmtpPasswortSetzen: TButton;
    lblKSmtpStatus: TLabel;
    lblKPasswortStatus: TLabel;
    lblKHinweis: TLabel;
    // Nur fuer Graph-Konten von Belang — bei IMAP steht hier, welcher Weg gilt
    lblKGraphStatus: TLabel;
    btnKGraphAbmelden: TButton;
    // Reiter 3: Erweitert (alles einstellbar, nichts im Code entschieden)
    pnlErweitert: TPanel;
    lblEProt: TLabel;
    cboEProt: TDBLookupComboBox;
    lblEFlow: TLabel;
    cboEFlow: TDBLookupComboBox;
    lblEImapSich: TLabel;
    cboEImapSich: TDBLookupComboBox;
    lblEImapAuth: TLabel;
    cboEImapAuth: TDBLookupComboBox;
    lblESmtpSich: TLabel;
    cboESmtpSich: TDBLookupComboBox;
    lblESmtpAuth: TLabel;
    cboESmtpAuth: TDBLookupComboBox;
    lblEPopHost: TLabel;
    edtEPopHost: TDBEdit;
    lblEPopPort: TLabel;
    edtEPopPort: TDBEdit;
    lblEPopSich: TLabel;
    cboEPopSich: TDBLookupComboBox;
    cbxEPopDel: TDBCheckBox;
    lblETimeout: TLabel;
    edtETimeout: TDBEdit;
    cbxEZert: TDBCheckBox;
    cbxEKopf: TDBCheckBox;
    lblEAbDat: TLabel;
    edtEAbDat: TDBEdit;
    lblEMaxAnh: TLabel;
    edtEMaxAnh: TDBEdit;
    lblEFilter: TLabel;
    edtEFilter: TDBEdit;
    lblETenant: TLabel;
    edtETenant: TDBEdit;
    lblEClient: TLabel;
    edtEClient: TDBEdit;
    lblEAuthUrl: TLabel;
    edtEAuthUrl: TDBEdit;
    lblEGraph: TLabel;
    edtEGraph: TDBEdit;
    lblEScopes: TLabel;
    edtEScopes: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cboKontoCloseUp(Sender: TObject);
    procedure dbgrdOrdnerCellClick(Column: TColumn);
    procedure dbgrdNachrichtenCellClick(Column: TColumn);
    procedure dbgrdAnhaengeDblClick(Sender: TObject);
    procedure actAbrufenExecute(Sender: TObject);
    procedure actNeuLadenExecute(Sender: TObject);
    procedure actGelesenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure btnKNeuClick(Sender: TObject);
    procedure btnKAendernClick(Sender: TObject);
    procedure btnKSpeichernClick(Sender: TObject);
    procedure btnKAbbrechenClick(Sender: TObject);
    procedure btnKPasswortSetzenClick(Sender: TObject);
    procedure btnKTestenClick(Sender: TObject);
    procedure cbxKKlartextClick(Sender: TObject);
    procedure btnKSmtpPasswortSetzenClick(Sender: TObject);
    procedure actGraphAnmeldenExecute(Sender: TObject);
    procedure btnKGraphAbmeldenClick(Sender: TObject);
  private
    function AktuellesKonto: Integer;
    function AktuellerOrdner: Integer;
    function AktuelleNachricht: Integer;
    procedure NachrichtGewechselt;
    // Zeigt an, ob fuer das gewaehlte Konto ein Passwort hinterlegt ist —
    // ohne es zu entschluesseln, dafuer braucht es den Schluessel nicht.
    procedure PasswortStatusZeigen;
    // Stellt das Klartext-Haekchen auf das, was tatsaechlich gespeichert ist.
    // Ohne das steht es nach jedem Fensteroeffnen wieder auf "verschluesselt",
    // und man setzt das Passwort versehentlich in der falschen Form.
    procedure KlartextHaekchenNachfuehren;
    // Zeigt, welcher Abrufweg fuer das gewaehlte Konto gilt, und bei Graph
    // zusaetzlich den Anmeldezustand. Blendet die Passwortfelder aus, wenn
    // sie auf dem gewaehlten Weg keine Rolle spielen.
    procedure WegStatusZeigen;
  end;

var
  frmMail: TfrmMail;

implementation

{$R *.dfm}

uses
  MailDm, GraphLoginFrm;

procedure TfrmMail.FormCreate(Sender: TObject);
begin
  // Erstes Konto vorwaehlen, damit das Fenster nicht leer aufgeht
  if not dmMail.tblKonto.IsEmpty then
  begin
    dmMail.tblKonto.First;
    cboKonto.KeyValue := dmMail.tblKonto.FieldByName('konto_id').AsInteger;
    cboKontoCloseUp(nil);
  end;
  KlartextHaekchenNachfuehren;
  PasswortStatusZeigen;
  WegStatusZeigen;
end;

procedure TfrmMail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmMail := nil;
end;

function TfrmMail.AktuellesKonto: Integer;
begin
  if VarIsNull(cboKonto.KeyValue) then
    Result := 0
  else
    Result := cboKonto.KeyValue;
end;

function TfrmMail.AktuellerOrdner: Integer;
begin
  if dmMail.qryOrdner.Active and not dmMail.qryOrdner.IsEmpty then
    Result := dmMail.qryOrdner.FieldByName('ordner_id').AsInteger
  else
    Result := 0;   // 0 = alle Ordner des Kontos
end;

function TfrmMail.AktuelleNachricht: Integer;
begin
  if dmMail.qryNachrichten.Active and not dmMail.qryNachrichten.IsEmpty then
    Result := dmMail.qryNachrichten.FieldByName('nachricht_id').AsInteger
  else
    Result := 0;
end;

procedure TfrmMail.cboKontoCloseUp(Sender: TObject);
var
  LKonto: Integer;
begin
  LKonto := AktuellesKonto;
  if LKonto = 0 then
    Exit;
  // Die Combo ist ein reiner Lookup und bewegt tblKonto nicht — ohne das
  // hier wuerde der Reiter "Konto" immer den ersten Satz bearbeiten.
  dmMail.KontoWaehlen(LKonto);
  KlartextHaekchenNachfuehren;
  PasswortStatusZeigen;
  WegStatusZeigen;
  dmMail.LadeOrdner(LKonto);
  dmMail.LadeNachrichten(LKonto, 0);   // erst alle, bis ein Ordner gewaehlt wird
  NachrichtGewechselt;
end;

// ── Reiter "Konto" ─────────────────────────────────────────────────────────

procedure TfrmMail.KlartextHaekchenNachfuehren;
var
  LAlt: TNotifyEvent;
begin
  // OnClick waehrend des Setzens abhaengen, sonst ruft es sich im Kreis
  LAlt := cbxKKlartext.OnClick;
  cbxKKlartext.OnClick := nil;
  try
    cbxKKlartext.Checked := dmMail.PasswortStatus(AktuellesKonto) = 'klartext';
  finally
    cbxKKlartext.OnClick := LAlt;
  end;
end;

procedure TfrmMail.PasswortStatusZeigen;
begin
  if AktuellesKonto = 0 then
  begin
    lblKPasswortStatus.Caption := 'Kein Konto gew' + #228 + 'hlt.';
    Exit;
  end;

  // Der Master-Schluessel wird nur gebraucht, wenn auch verschluesselt wird
  edtKSchluessel.Enabled := not cbxKKlartext.Checked;
  lblKSchluessel.Enabled := not cbxKKlartext.Checked;

  // Der Hinweistext muss zum gewaehlten Weg passen, sonst behauptet er
  // Verschluesselung, waehrend Klartext geschrieben wird.
  if cbxKKlartext.Checked then
    lblKHinweis.Caption :=
      'KLARTEXT: Das Passwort wird unverschl' + #252 + 'sselt in der Datenbank ' +
      'abgelegt - wer sie lesen kann, liest es mit. Nur zum Ausprobieren, ' +
      'solange die C#-Seite noch nicht entschl' + #252 + 'sselt. Nach dem Eintippen ' +
      'unbedingt "Passwort setzen" dr' + #252 + 'cken, sonst steht es nur im Feld.'
  else
    lblKHinweis.Caption :=
      'Das Passwort wird in der Datenbank verschl' + #252 + 'sselt abgelegt ' +
      '(pgcrypto). Der Master-Schl' + #252 + 'ssel wird NICHT gespeichert - er gilt ' +
      'nur f' + #252 + 'r diese Sitzung. Nach dem Eintippen "Passwort setzen" ' +
      'dr' + #252 + 'cken, sonst steht es nur im Feld.';

  // Postausgang: leer heisst "dieselben Daten wie oben" — das ist der
  // Regelfall und muss ohne Eingabe funktionieren.
  if dmMail.SmtpPasswortStatus(AktuellesKonto) = 'keins' then
    lblKSmtpStatus.Caption := 'Postausgang: verwendet die Zugangsdaten von oben.'
  else
    lblKSmtpStatus.Caption := 'Postausgang: eigenes Passwort hinterlegt (' +
      dmMail.SmtpPasswortStatus(AktuellesKonto) + ').';

  if dmMail.PasswortStatus(AktuellesKonto) = 'verschluesselt' then
    lblKPasswortStatus.Caption := 'Passwort hinterlegt: verschl' + #252 + 'sselt.'
  else if dmMail.PasswortStatus(AktuellesKonto) = 'klartext' then
    lblKPasswortStatus.Caption := 'Passwort hinterlegt: KLARTEXT ' +
      '(nur zum Ausprobieren gedacht).'
  else
    lblKPasswortStatus.Caption := 'Noch kein Passwort hinterlegt.';
end;

procedure TfrmMail.cbxKKlartextClick(Sender: TObject);
begin
  PasswortStatusZeigen;
end;

// ── Reiter "Konto": Graph-Teil ─────────────────────────────────────────────
// Bei Graph gibt es kein Passwort — der Zugang ist ein Refresh-Token, das aus
// der Anmeldung entsteht. Passwortfelder waeren dort nicht nur ueberfluessig,
// sondern irrefuehrend, deshalb werden sie abgeschaltet.

procedure TfrmMail.WegStatusZeigen;
var
  LKonto: Integer;
  LWeg: string;
  LIstGraph: Boolean;
begin
  LKonto := AktuellesKonto;
  if LKonto = 0 then
  begin
    lblKGraphStatus.Caption := '';
    actGraphAnmelden.Enabled := False;
    btnKGraphAbmelden.Enabled := False;
    Exit;
  end;

  LWeg := dmMail.WegFuerKonto(LKonto);
  LIstGraph := LWeg = 'graph';

  // Anmelden muss auch dann moeglich sein, wenn der Weg noch nicht auf Graph
  // steht — die Anmeldung ist ja gerade das, was ihn umstellt.
  actGraphAnmelden.Enabled := dmMail.GraphMoeglich(LKonto);
  btnKGraphAbmelden.Enabled := LIstGraph;

  // Die Zugangsdaten des jeweils anderen Weges nicht bedienbar lassen
  edtKPasswort.Enabled := not LIstGraph;
  btnKPasswortSetzen.Enabled := not LIstGraph;
  cbxKKlartext.Enabled := not LIstGraph;
  edtKSmtpPasswort.Enabled := not LIstGraph;
  btnKSmtpPasswortSetzen.Enabled := not LIstGraph;

  // Ausdruecklich sagen, WARUM dieser Weg gilt — sonst raet der Anwender.
  if LIstGraph then
    lblKGraphStatus.Caption := 'Weg: Microsoft Graph (kein Passwort n' + #246 +
      'tig). ' + dmMail.GraphStatus(LKonto)
  else if dmMail.GraphMoeglich(LKonto) then
    lblKGraphStatus.Caption := 'Weg: IMAP '#252'ber die C#-Br'#252'cke. F'#252'r Exchange ' +
      'stattdessen oben "Microsoft-Anmeldung" - danach l'#228'uft dieses Konto ' +
      #252'ber Graph.'
  else
    lblKGraphStatus.Caption := 'Weg: ' + UpperCase(LWeg) +
      ' '#252'ber die C#-Br'#252'cke (MailKit) - im Reiter "Erweitert" fest eingestellt.';
end;

procedure TfrmMail.actGraphAnmeldenExecute(Sender: TObject);
var
  LKonto: Integer;
  LMeldung: string;
begin
  LKonto := AktuellesKonto;
  if LKonto = 0 then
  begin
    ShowMessage('Bitte zuerst ein Konto w' + #228 + 'hlen.');
    Exit;
  end;
  if dmMail.tblKonto.State in dsEditModes then
  begin
    ShowMessage('Bitte das Konto zuerst speichern.');
    Exit;
  end;

  // Waehrend der Anmeldung laeuft im Anmeldefenster ein ProcessMessages —
  // ohne diese Sperre koennte man hier gleichzeitig einen Abruf starten.
  Enabled := False;
  try
    LMeldung := TfrmGraphLogin.Anmelden(LKonto);
  finally
    Enabled := True;
  end;

  ShowMessage(LMeldung);
  WegStatusZeigen;
end;

procedure TfrmMail.btnKGraphAbmeldenClick(Sender: TObject);
begin
  if AktuellesKonto = 0 then
    Exit;
  if MessageDlg('Die gespeicherte Anmeldung f' + #252 + 'r dieses Konto entfernen?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ShowMessage(dmMail.GraphAbmelden(AktuellesKonto));
  WegStatusZeigen;
end;

procedure TfrmMail.btnKNeuClick(Sender: TObject);
begin
  dmMail.KontoNeu;
end;

procedure TfrmMail.btnKAendernClick(Sender: TObject);
begin
  dmMail.KontoAendern;
end;

procedure TfrmMail.btnKSpeichernClick(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := dmMail.KontoSpeichern;
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    Exit;
  end;
  PasswortStatusZeigen;
end;

procedure TfrmMail.btnKAbbrechenClick(Sender: TObject);
begin
  dmMail.KontoAbbrechen;
end;

// Passwort und Schluessel gehen an die Datenbank, verschluesselt wird dort
// (pgcrypto). Der Schluessel wird nirgends gespeichert, nur fuer die Sitzung
// im DataModule gehalten.
procedure TfrmMail.btnKPasswortSetzenClick(Sender: TObject);
var
  LMeldung: string;
begin
  if dmMail.tblKonto.State in dsEditModes then
  begin
    ShowMessage('Bitte das Konto zuerst speichern.');
    Exit;
  end;

  // Klartext ist der Uebergangsweg, solange MailBridge.cs nicht entschluesselt
  if cbxKKlartext.Checked then
    LMeldung := dmMail.PasswortKlartextSetzen(AktuellesKonto, edtKPasswort.Text)
  else
    LMeldung := dmMail.PasswortSetzen(AktuellesKonto, edtKPasswort.Text,
      edtKSchluessel.Text);
  ShowMessage(LMeldung);

  // Klartext nicht laenger als noetig im Formular stehen lassen
  edtKPasswort.Clear;
  PasswortStatusZeigen;
end;

// Eigenes Passwort fuer den Postausgang. Leeres Feld entfernt es wieder,
// dann gelten die Zugangsdaten des Kontos.
procedure TfrmMail.btnKSmtpPasswortSetzenClick(Sender: TObject);
begin
  if dmMail.tblKonto.State in dsEditModes then
  begin
    ShowMessage('Bitte das Konto zuerst speichern.');
    Exit;
  end;

  ShowMessage(dmMail.SmtpPasswortSetzen(AktuellesKonto, edtKSmtpPasswort.Text,
    edtKSchluessel.Text, cbxKKlartext.Checked));

  edtKSmtpPasswort.Clear;
  PasswortStatusZeigen;
end;

procedure TfrmMail.btnKTestenClick(Sender: TObject);
begin
  if AktuellesKonto = 0 then
  begin
    ShowMessage('Bitte zuerst ein Konto w' + #228 + 'hlen.');
    Exit;
  end;

  // Der Test liest das Passwort aus der DATENBANK, nicht aus dem Eingabefeld.
  // Ohne diese Pruefung meldet MailKit nur "Value cannot be null
  // (Parameter 'password')" — technisch richtig, aber nicht hilfreich.
  // Bei Graph gibt es kein Passwort; dort pruefen die Aufrufe selbst, ob eine
  // Anmeldung hinterlegt ist.
  if not dmMail.IstGraphKonto(AktuellesKonto) and
     (dmMail.PasswortStatus(AktuellesKonto) = 'keins') then
  begin
    if edtKPasswort.Text <> '' then
      ShowMessage('Das Passwort steht erst im Eingabefeld, aber noch nicht in ' +
        'der Datenbank. Bitte zuerst auf "Passwort setzen" klicken - der Test ' +
        'liest es von dort.')
    else
      ShowMessage('F' + #252 + 'r dieses Konto ist kein Passwort hinterlegt.');
    Exit;
  end;
  Screen.Cursor := crHourGlass;
  try
    ShowMessage(dmMail.VerbindungTesten(AktuellesKonto));
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMail.dbgrdOrdnerCellClick(Column: TColumn);
begin
  dmMail.LadeNachrichten(AktuellesKonto, AktuellerOrdner);
  NachrichtGewechselt;
end;

procedure TfrmMail.dbgrdNachrichtenCellClick(Column: TColumn);
begin
  NachrichtGewechselt;
end;

// Anhangsliste zur gerade markierten Nachricht nachziehen
procedure TfrmMail.NachrichtGewechselt;
begin
  dmMail.LadeAnhaenge(AktuelleNachricht);
end;

procedure TfrmMail.dbgrdAnhaengeDblClick(Sender: TObject);
begin
  if dmMail.qryAnhaenge.IsEmpty then
    Exit;
  dmMail.AnhangOeffnen(dmMail.qryAnhaenge.FieldByName('dokument_id').AsInteger);
end;

// Ruft ueber die Bruecke die C#-Seite (MailKit) auf: erst Ordner abgleichen,
// dann Nachrichten holen. Die Daten kommen NICHT als Rueckgabewert zurueck,
// sondern landen in der Datenbank — deshalb danach neu laden.
procedure TfrmMail.actAbrufenExecute(Sender: TObject);
var
  LKonto: Integer;
  LMeldung: string;
begin
  LKonto := AktuellesKonto;
  if LKonto = 0 then
  begin
    ShowMessage('Bitte zuerst ein Konto w'#228'hlen.');
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    LMeldung := dmMail.OrdnerAbgleichen(LKonto);
    if LMeldung.StartsWith('FEHLER') then
    begin
      ShowMessage(LMeldung);
      Exit;
    end;
    LMeldung := dmMail.PostfachAbrufen(LKonto);
  finally
    Screen.Cursor := crDefault;
  end;

  actNeuLadenExecute(nil);
  ShowMessage(LMeldung);
end;

procedure TfrmMail.actNeuLadenExecute(Sender: TObject);
begin
  if AktuellesKonto = 0 then
    Exit;
  dmMail.LadeOrdner(AktuellesKonto);
  dmMail.LadeNachrichten(AktuellesKonto, AktuellerOrdner);
  NachrichtGewechselt;
end;

procedure TfrmMail.actGelesenExecute(Sender: TObject);
var
  LId: Integer;
begin
  LId := AktuelleNachricht;
  if LId = 0 then
    Exit;
  dmMail.SetzeGelesen(LId, not dmMail.qryNachrichten.FieldByName('gelesen').AsBoolean);
  actNeuLadenExecute(nil);
end;

// Navigation der Ribbon-Leiste: wirkt auf die Anhangsliste (Reiter 1) bzw.
// auf die Nachrichtenliste (Reiter 0).
procedure TfrmMail.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
begin
  case JvRibbonPanel1.ActivePageIndex of
    1: LDs := dmMail.qryAnhaenge;
    // Reiter "Konto" und "Erweitert" zeigen beide denselben Kontosatz
    2, 3: LDs := dmMail.tblKonto;
  else
    LDs := dmMail.qryNachrichten;
  end;
  if (LDs = nil) or not LDs.Active then
    Exit;
  case (Sender as TComponent).Tag of
    0: LDs.First;
    1: LDs.Prior;
    2: LDs.Next;
    3: LDs.Last;
  end;
  if LDs = dmMail.qryNachrichten then
    NachrichtGewechselt;
end;

end.
