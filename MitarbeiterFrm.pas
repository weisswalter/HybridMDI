unit MitarbeiterFrm;

// Mitarbeiter-Verwaltung (Mitarbeiter der Hauptperson, siehe MitarbeiterDm).
// Wie KlientFrm/KundeFrm bewusst NICHT von TfrmGuiTemplate abgeleitet --
// Person und person_beziehung (Rolle) sind zwei unabhaengige, gemeinsam
// bearbeitete Tabellen. Links: Browse-Grid + Vorname/Nachname/Titel/
// Geburtsdatum (person) / Rolle (person_beziehung.rolle_id). Rechts
// (JvRibbon): "Kontaktdaten" (read-only Uebersicht E-Mail/Telefon/Adresse --
// Bearbeiten weiterhin im bestehenden Personen-Modul).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmMitarbeiter = class(TfrmTemplate)
    pnlLeft: TPanel;
    dbgrdMitarbeiter: TDBGrid;
    pnlEdit: TPanel;
    pnlEditButtons: TPanel;
    btnNeu: TJvNavPanelButtonTop;
    btnAendern: TJvNavPanelButtonTop;
    btnSpeichern: TJvNavPanelButtonTop;
    btnAbbrechen: TJvNavPanelButtonTop;
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actNeu: TAction;
    actAendern: TAction;
    actSpeichern: TAction;
    actAbbrechen: TAction;
    pnlEditFelder: TPanel;
    lblVorname: TLabel;
    edtVorname: TDBEdit;
    lblNachname: TLabel;
    edtNachname: TDBEdit;
    lblTitel: TLabel;
    edtTitel: TDBEdit;
    lblGeburtsdatum: TLabel;
    edtGeburtsdatum: TDBEdit;
    lblRolle: TLabel;
    cboRolle: TDBLookupComboBox;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsKontaktdaten: TTabSheet;
    barKontaktdaten: TRibbonButtonBar;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    pnlKontaktdaten: TPanel;
    dbgrdEmail: TDBGrid;
    dbgrdTelefon: TDBGrid;
    dbgrdAdresse: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdMitarbeiterCellClick(Column: TColumn);
    procedure btnNeuClick(Sender: TObject);
    procedure btnAendernClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
  end;

var
  frmMitarbeiter: TfrmMitarbeiter;

implementation

{$R *.dfm}

uses
  MitarbeiterDm;

procedure TfrmMitarbeiter.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmMitarbeiter := nil;
end;

procedure TfrmMitarbeiter.dbgrdMitarbeiterCellClick(Column: TColumn);
begin
  if dmMitarbeiter.qryMitarbeiter.IsEmpty then
    Exit;
  dmMitarbeiter.LadeMitarbeiter(dmMitarbeiter.qryMitarbeiter.FieldByName('person_id').AsInteger,
    dmMitarbeiter.qryMitarbeiter.FieldByName('beziehungs_id').AsInteger);
end;

procedure TfrmMitarbeiter.btnNeuClick(Sender: TObject);
begin
  dmMitarbeiter.NeuerMitarbeiter;
end;

procedure TfrmMitarbeiter.btnAendernClick(Sender: TObject);
begin
  dmMitarbeiter.BearbeitenMitarbeiter;
end;

procedure TfrmMitarbeiter.btnSpeichernClick(Sender: TObject);
begin
  dmMitarbeiter.SpeichernMitarbeiter;
end;

procedure TfrmMitarbeiter.btnAbbrechenClick(Sender: TObject);
begin
  dmMitarbeiter.AbbrechenMitarbeiter;
end;

// Gemeinsamer Handler der Ribbon-Buttonleiste — Tag der Action bestimmt die
// Navigation (0=Erster, 1=Zurueck, 2=Weiter, 3=Letzter). Nur ein Reiter
// (Kontaktdaten), fuehrendes Grid ist die E-Mail-Uebersicht.
procedure TfrmMitarbeiter.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmMitarbeiter.dstblEmailUebersicht;
  if (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case (Sender as TComponent).Tag of
    0: LDs.DataSet.First;
    1: LDs.DataSet.Prior;
    2: LDs.DataSet.Next;
    3: LDs.DataSet.Last;
  end;
end;

end.
