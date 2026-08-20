unit VorgangFrm;

// Fenster zum Vorgang (Ticket). Links die Liste, rechts der gewaehlte
// Vorgang mit Verlauf und den verknuepften Vorgaengen.
//
// Das Fenster kennt keine Datenbank: jede Aenderung geht ueber dmVorgang,
// und dort ueber eine Datenbankfunktion. Was erlaubt ist, sagt die Datenbank
// (vorgang_uebergang) - die Auswahl "Naechster Schritt" zeigt nur, was von
// hier aus erreichbar ist.
//
// Ein abgeschlossener Vorgang laesst sich nicht mehr aendern. Statt ihn
// wieder zu oeffnen, legt "Nachfolger" einen neuen an, der auf ihn verweist.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls,
  Vcl.ComCtrls, Data.DB,
  JvExControls, JvNavigationPane, JvButton, JvSpeedButton, JvNavPanelButtonTop,
  JvComponentBase;

type
  TfrmVorgang = class(TForm)
    pnlOben: TPanel;
    btnNeu: TJvNavPanelButtonTop;
    btnSpeichern: TJvNavPanelButtonTop;
    btnWeiter: TJvNavPanelButtonTop;
    btnNachfolger: TJvNavPanelButtonTop;
    cboTyp: TComboBox;
    lblTyp: TLabel;
    pnlListe: TPanel;
    grdVorgang: TDBGrid;
    spl1: TSplitter;
    pnlRechts: TPanel;
    pnlKopf: TPanel;
    lblNummer: TLabel;
    edtNummer: TEdit;
    lblBezeichnung: TLabel;
    edtBezeichnung: TEdit;
    lblFaellig: TLabel;
    dtFaellig: TDateTimePicker;
    chkFaellig: TCheckBox;
    lblZustand: TLabel;
    edtZustand: TEdit;
    lblBeschreibung: TLabel;
    memBeschreibung: TMemo;
    pnlSchritt: TPanel;
    lblSchritt: TLabel;
    cboSchritt: TComboBox;
    lblBemerkung: TLabel;
    edtBemerkung: TEdit;
    pnlUnten: TPanel;
    pgcUnten: TPageControl;
    tsVerlauf: TTabSheet;
    grdVerlauf: TDBGrid;
    tsVerknuepft: TTabSheet;
    grdVerknuepft: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNeuClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure btnWeiterClick(Sender: TObject);
    procedure btnNachfolgerClick(Sender: TObject);
    procedure grdVerknuepftDblClick(Sender: TObject);
  private
    function GewaehlteId(ACombo: TComboBox): Integer;
    procedure SperrenSetzen;
  public
    // Wird von dmVorgang nach jedem Satzwechsel gerufen.
    procedure SatzAnzeigen;
  end;

var
  frmVorgang: TfrmVorgang;

implementation

{$R *.dfm}

uses
  VorgangDm;

procedure TfrmVorgang.FormCreate(Sender: TObject);
begin
  dmVorgang.TypenFuellen(cboTyp.Items);
  if cboTyp.Items.Count > 0 then
    cboTyp.ItemIndex := 0;
end;

procedure TfrmVorgang.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Wie in den anderen Modulen: das Fenster geht, das Datenmodul bleibt.
  Action := caFree;
  frmVorgang := nil;
end;

// Die ID haengt am Objects-Zeiger der Auswahlliste.
function TfrmVorgang.GewaehlteId(ACombo: TComboBox): Integer;
begin
  if ACombo.ItemIndex < 0 then
    Result := 0
  else
    Result := Integer(NativeInt(ACombo.Items.Objects[ACombo.ItemIndex]));
end;

procedure TfrmVorgang.SatzAnzeigen;
var
  LDs: TDataSet;
begin
  LDs := dmVorgang.tblVorgang;
  if not LDs.Active or LDs.IsEmpty then
  begin
    edtNummer.Clear;
    edtBezeichnung.Clear;
    edtZustand.Clear;
    memBeschreibung.Clear;
    chkFaellig.Checked := False;
    cboSchritt.Items.Clear;
    SperrenSetzen;
    Exit;
  end;

  edtNummer.Text      := LDs.FieldByName('vorgang_nr').AsString;
  edtBezeichnung.Text := LDs.FieldByName('bezeichnung').AsString;
  edtZustand.Text     := LDs.FieldByName('zustand_bezeichnung').AsString +
                         '   (' + LDs.FieldByName('typ_bezeichnung').AsString + ')';
  memBeschreibung.Text := LDs.FieldByName('beschreibung').AsString;

  chkFaellig.Checked := not LDs.FieldByName('faellig_am').IsNull;
  if chkFaellig.Checked then
    dtFaellig.Date := LDs.FieldByName('faellig_am').AsDateTime
  else
    dtFaellig.Date := Date;

  dmVorgang.SchritteFuellen(cboSchritt.Items);
  if cboSchritt.Items.Count > 0 then
    cboSchritt.ItemIndex := 0;
  edtBemerkung.Clear;

  SperrenSetzen;
end;

// Ein abgeschlossener Vorgang ist zu. Das sperrt hier die Eingaben, damit es
// gar nicht erst zur Fehlermeldung aus der Datenbank kommt - die zweite
// Sicherung sitzt dort und bleibt bestehen.
procedure TfrmVorgang.SperrenSetzen;
var
  LZu: Boolean;
  LDa: Boolean;
begin
  LDa := dmVorgang.AktuelleId > 0;
  LZu := LDa and dmVorgang.IstAbgeschlossen;

  edtBezeichnung.ReadOnly  := LZu or not LDa;
  memBeschreibung.ReadOnly := LZu or not LDa;
  dtFaellig.Enabled        := LDa and not LZu;
  chkFaellig.Enabled       := LDa and not LZu;
  cboSchritt.Enabled       := LDa and not LZu and (cboSchritt.Items.Count > 0);
  edtBemerkung.Enabled     := cboSchritt.Enabled;
  btnSpeichern.Enabled     := LDa and not LZu;
  btnWeiter.Enabled        := cboSchritt.Enabled;
  btnNachfolger.Enabled    := LDa;
end;

procedure TfrmVorgang.btnNeuClick(Sender: TObject);
var
  LText, LMeldung: string;
  LNeu: Integer;
begin
  LText := '';
  if not InputQuery('Neuer Vorgang',
       'Worum geht es? (' + cboTyp.Text + ')', LText) then
    Exit;

  LMeldung := dmVorgang.Anlegen(GewaehlteId(cboTyp), LText, LNeu);
  if LMeldung <> '' then
    MessageDlg(LMeldung, mtWarning, [mbOK], 0)
  else
    SatzAnzeigen;
end;

procedure TfrmVorgang.btnSpeichernClick(Sender: TObject);
var
  LMeldung: string;
  LFaellig: TDateTime;
begin
  if chkFaellig.Checked then
    LFaellig := dtFaellig.Date
  else
    LFaellig := 0;

  LMeldung := dmVorgang.Speichern(edtBezeichnung.Text, memBeschreibung.Text,
                                  LFaellig);
  if LMeldung <> '' then
    MessageDlg(LMeldung, mtWarning, [mbOK], 0)
  else
    SatzAnzeigen;
end;

procedure TfrmVorgang.btnWeiterClick(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := dmVorgang.Weiter(GewaehlteId(cboSchritt), edtBemerkung.Text);
  if LMeldung <> '' then
    MessageDlg(LMeldung, mtWarning, [mbOK], 0)
  else
    SatzAnzeigen;
end;

procedure TfrmVorgang.btnNachfolgerClick(Sender: TObject);
var
  LText, LMeldung: string;
  LNeu: Integer;
begin
  LText := '';
  if not InputQuery('Neuer Vorgang mit Bezug auf ' + edtNummer.Text,
       'Worum geht es?', LText) then
    Exit;

  LMeldung := dmVorgang.Nachfolger(LText, LNeu);
  if LMeldung <> '' then
    MessageDlg(LMeldung, mtWarning, [mbOK], 0)
  else
    SatzAnzeigen;
end;

// Doppelklick auf einen verknuepften Vorgang springt dorthin.
procedure TfrmVorgang.grdVerknuepftDblClick(Sender: TObject);
var
  LZiel: Integer;
begin
  if not dmVorgang.tblVerknuepft.Active or dmVorgang.tblVerknuepft.IsEmpty then
    Exit;
  LZiel := dmVorgang.tblVerknuepft.FieldByName('vorgang_id').AsInteger;
  if LZiel > 0 then
    dmVorgang.tblVorgang.Locate('vorgang_id', LZiel, []);
end;

end.
