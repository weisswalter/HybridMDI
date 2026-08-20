unit LehrerFrm;

// Lehrermodul - Oberflaeche. Aufbau wie MitarbeiterFrm/PersonenFrm:
//   links  Liste aller Lehrer des Mandanten + Stammfelder
//   rechts TRibbonPanel mit zwei Reitern
//     Kompetenzen - Nachweise der Person, mit Ablaufstatus
//     Kurse       - welche Kurse diese Person halten darf (Gegenprobe
//                   Kompetenz gegen kurs_kompetenz mit rolle='lehrer')
//
// In der Liste steht die ABGELEITETE Anstellungsart: Lohnmitarbeiter, wenn
// zusaetzlich ist_mitarbeiter gesetzt ist, sonst Honorarlehrer. Umgestellt
// wird das nicht hier, sondern im Personenmodul ueber die Haekchen - hier
// waere es eine zweite Bedienstelle fuer dieselbe Sache.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.DateUtils, System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmLehrer = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actAendern: TAction;
    actSpeichern: TAction;
    actAbbrechen: TAction;
    actNeuLaden: TAction;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    pnlLeft: TPanel;
    pnlEditButtons: TPanel;
    btnAendern: TJvNavPanelButtonTop;
    btnSpeichern: TJvNavPanelButtonTop;
    btnAbbrechen: TJvNavPanelButtonTop;
    btnNeuLaden: TJvNavPanelButtonTop;
    dbgrdLehrer: TDBGrid;
    pnlEditFelder: TPanel;
    lblVorname: TLabel;
    edtVorname: TDBEdit;
    lblNachname: TLabel;
    edtNachname: TDBEdit;
    lblTitel: TLabel;
    edtTitel: TDBEdit;
    lblGeburtsdatum: TLabel;
    edtGeburtsdatum: TDBEdit;
    lblBeschreibung: TLabel;
    memBeschreibung: TDBMemo;
    lblHinweis: TLabel;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsKompetenzen: TTabSheet;
    tsKurse: TTabSheet;
    barKompetenzen: TRibbonButtonBar;
    barKurse: TRibbonButtonBar;
    // Reiter 0: Kompetenzen
    pnlKompetenzen: TPanel;
    dbgrdKompetenzen: TDBGrid;
    pnlKompetenzAdd: TPanel;
    lblKompetenz: TLabel;
    cboKompetenz: TDBLookupComboBox;
    lblErworben: TLabel;
    dtpErworben: TDateTimePicker;
    lblGueltigBis: TLabel;
    dtpGueltigBis: TDateTimePicker;
    cbxUnbefristet: TCheckBox;
    lblBemerkung: TLabel;
    edtBemerkung: TEdit;
    btnKompetenzAdd: TButton;
    btnKompetenzDel: TButton;
    // Reiter 1: Kurse
    pnlKurse: TPanel;
    dbgrdKurse: TDBGrid;
    pnlKurseInfo: TPanel;
    lblKurseHinweis: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdLehrerCellClick(Column: TColumn);
    procedure actAendernExecute(Sender: TObject);
    procedure actSpeichernExecute(Sender: TObject);
    procedure actAbbrechenExecute(Sender: TObject);
    procedure actNeuLadenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure btnKompetenzAddClick(Sender: TObject);
    procedure btnKompetenzDelClick(Sender: TObject);
    procedure cbxUnbefristetClick(Sender: TObject);
  private
    function AktuellerLehrer: Integer;
    function AktuelleBeziehung: Integer;
    function LookupId(ACombo: TDBLookupComboBox): Integer;
  end;

var
  frmLehrer: TfrmLehrer;

implementation

{$R *.dfm}

uses
  LehrerDm;

procedure TfrmLehrer.FormCreate(Sender: TObject);
begin
  dtpErworben.Date := Date;
  dtpGueltigBis.Date := Date;
  cbxUnbefristet.Checked := True;
  cbxUnbefristetClick(nil);
end;

procedure TfrmLehrer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmLehrer := nil;
end;

function TfrmLehrer.AktuellerLehrer: Integer;
begin
  if dmLehrer.qryLehrer.Active and not dmLehrer.qryLehrer.IsEmpty then
    Result := dmLehrer.qryLehrer.FieldByName('person_id').AsInteger
  else
    Result := 0;
end;

function TfrmLehrer.AktuelleBeziehung: Integer;
begin
  if dmLehrer.qryLehrer.Active and not dmLehrer.qryLehrer.IsEmpty then
    Result := dmLehrer.qryLehrer.FieldByName('beziehungs_id').AsInteger
  else
    Result := 0;
end;

function TfrmLehrer.LookupId(ACombo: TDBLookupComboBox): Integer;
begin
  if VarIsNull(ACombo.KeyValue) then
    Result := 0
  else
    Result := ACombo.KeyValue;
end;

procedure TfrmLehrer.dbgrdLehrerCellClick(Column: TColumn);
begin
  if AktuellerLehrer > 0 then
    dmLehrer.LadeLehrer(AktuellerLehrer, AktuelleBeziehung);
end;

procedure TfrmLehrer.actAendernExecute(Sender: TObject);
begin
  dmLehrer.Bearbeiten;
end;

procedure TfrmLehrer.actSpeichernExecute(Sender: TObject);
begin
  dmLehrer.Speichern;
end;

procedure TfrmLehrer.actAbbrechenExecute(Sender: TObject);
begin
  dmLehrer.Abbrechen;
end;

procedure TfrmLehrer.actNeuLadenExecute(Sender: TObject);
begin
  dmLehrer.LadeListe;
end;

procedure TfrmLehrer.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: LDs := dmLehrer.qryKompetenzen;
    1: LDs := dmLehrer.qryKurse;
  else
    LDs := nil;
  end;
  if (LDs = nil) or not LDs.Active then
    Exit;
  case (Sender as TComponent).Tag of
    0: LDs.First;
    1: LDs.Prior;
    2: LDs.Next;
    3: LDs.Last;
  end;
end;

// ── Kompetenzen ─────────────────────────────────────────────────────────────

procedure TfrmLehrer.cbxUnbefristetClick(Sender: TObject);
begin
  dtpGueltigBis.Enabled := not cbxUnbefristet.Checked;
  lblGueltigBis.Enabled := not cbxUnbefristet.Checked;
end;

procedure TfrmLehrer.btnKompetenzAddClick(Sender: TObject);
var
  LBis: TDate;
  LMeldung: string;
begin
  // 0 heisst: kein Enddatum vorgeben. Die Datenbank rechnet dann selbst aus
  // gueltigkeit_monate hoch, falls am Typ eine Frist hinterlegt ist.
  if cbxUnbefristet.Checked then
    LBis := 0
  else
    LBis := dtpGueltigBis.Date;

  LMeldung := dmLehrer.KompetenzHinzufuegen(LookupId(cboKompetenz),
    dtpErworben.Date, LBis, edtBemerkung.Text);
  if LMeldung <> '' then
    ShowMessage(LMeldung)
  else
    edtBemerkung.Clear;
end;

procedure TfrmLehrer.btnKompetenzDelClick(Sender: TObject);
begin
  if dmLehrer.qryKompetenzen.IsEmpty then
    Exit;
  dmLehrer.KompetenzEntfernen(
    dmLehrer.qryKompetenzen.FieldByName('person_kompetenz_id').AsInteger);
end;

end.
