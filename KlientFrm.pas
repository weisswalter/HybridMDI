unit KlientFrm;

// Klient-Verwaltung. Bewusst NICHT von TfrmGuiTemplate abgeleitet (das
// Template geht von EINER Stamm-DataSource aus) -- hier sind Person und
// Klient zwei unabhaengige Tabellen, die gemeinsam bearbeitet werden
// (Neu/Aendern/Speichern/Abbrechen wirken auf beide gleichzeitig, siehe
// dmKlient.BearbeitenKlient/SpeichernKlient/AbbrechenKlient).
//
// Oben: Semester-Filter (filtert die Liste links). Links: Browse-Grid +
// Bearbeitungsfelder (Vorname/Nachname/Titel/Geburtsdatum -> person;
// Abteilung/Kundenname/Lead-Quelle/Besitzer -> klient). Rechts (JvRibbon):
// "Kontaktdaten" (read-only Uebersicht E-Mail/Telefon/Adresse -- Bearbeiten
// weiterhin im bestehenden Personen-Modul) und "Semester" (Zuordnung zu
// Zeitabschnitten, klient_semester).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase, Vcl.Mask;

type
  TfrmKlient = class(TfrmTemplate)
    pnlTop: TPanel;
    lblSemesterFilter: TLabel;
    cboSemesterFilter: TDBLookupComboBox;
    pnlLeft: TPanel;
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
    lblAbteilung: TLabel;
    edtAbteilung: TDBEdit;
    lblKunde: TLabel;
    cboKunde: TDBLookupComboBox;
    lblLeadquelle: TLabel;
    cboLeadquelle: TDBLookupComboBox;
    lblBesitzer: TLabel;
    cboBesitzer: TDBLookupComboBox;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsKontaktdaten: TTabSheet;
    tsSemester: TTabSheet;
    barKontaktdaten: TRibbonButtonBar;
    barSemester: TRibbonButtonBar;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    actNeuR: TAction;
    actAendernR: TAction;
    actSpeichernR: TAction;
    actAbbrechenR: TAction;
    actNeuLadenR: TAction;
    // Detailseite "Kontaktdaten"
    pnlKontaktdaten: TPanel;
    dbgrdEmail: TDBGrid;
    dbgrdTelefon: TDBGrid;
    dbgrdAdresse: TDBGrid;
    // Detailseite "Semester"
    pnlSemester: TPanel;
    pnlSemesterAdd: TPanel;
    cboSemesterHinzufuegen: TDBLookupComboBox;
    btnSemesterHinzufuegen: TButton;
    btnSemesterEntfernen: TButton;
    dbgrdSemester: TDBGrid;
    dbgrdKlienten: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cboSemesterFilterChange(Sender: TObject);
    procedure dbgrdKlientenCellClick(Column: TColumn);
    procedure btnNeuClick(Sender: TObject);
    procedure btnAendernClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
    procedure btnSemesterHinzufuegenClick(Sender: TObject);
    procedure btnSemesterEntfernenClick(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
  private
    // DataSource der aktuell sichtbaren Ribbon-Detailseite (Muster wie
    // ArtikelStammFrm.AktiveDetailDs) -- 0 = Kontaktdaten, 1 = Semester.
    function AktiveDetailDs: TDataSource;
  end;

var
  frmKlient: TfrmKlient;

implementation

{$R *.dfm}

uses
  KlientDm;

procedure TfrmKlient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmKlient := nil;
end;

// cboSemesterFilter ist reiner Auswahl-Lookup (kein DataField gebunden) --
// KeyValue liefert die semester_id, 0 bei "kein Eintrag gewaehlt" (= Alle).
procedure TfrmKlient.cboSemesterFilterChange(Sender: TObject);
var
  LId: Integer;
begin
  if cboSemesterFilter.KeyValue = Null then
    LId := 0
  else
    LId := cboSemesterFilter.KeyValue;
  dmKlient.LadeListe(LId);
end;

procedure TfrmKlient.dbgrdKlientenCellClick(Column: TColumn);
begin
  if dmKlient.qryKlienten.IsEmpty then
    Exit;
  dmKlient.LadeKlient(dmKlient.qryKlienten.FieldByName('person_id').AsInteger,
    dmKlient.qryKlienten.FieldByName('klient_id').AsInteger);
end;

procedure TfrmKlient.btnNeuClick(Sender: TObject);
begin
  dmKlient.NeuerKlient;
end;

procedure TfrmKlient.btnAendernClick(Sender: TObject);
begin
  dmKlient.BearbeitenKlient;
end;

procedure TfrmKlient.btnSpeichernClick(Sender: TObject);
begin
  dmKlient.SpeichernKlient;
end;

procedure TfrmKlient.btnAbbrechenClick(Sender: TObject);
begin
  dmKlient.AbbrechenKlient;
end;

procedure TfrmKlient.btnSemesterHinzufuegenClick(Sender: TObject);
begin
  if cboSemesterHinzufuegen.KeyValue = Null then
  begin
    ShowMessage('Bitte ein Semester ausw'#228'hlen.');
    Exit;
  end;
  dmKlient.FuegeSemesterHinzu(cboSemesterHinzufuegen.KeyValue);
end;

procedure TfrmKlient.btnSemesterEntfernenClick(Sender: TObject);
begin
  if dmKlient.qryKlientSemester.IsEmpty then
    Exit;
  dmKlient.EntferneSemester(dmKlient.qryKlientSemester.FieldByName('semester_id').AsInteger);
end;

// 0 = Kontaktdaten (E-Mail-Uebersicht als fuehrendes Grid), 1 = Semester
function TfrmKlient.AktiveDetailDs: TDataSource;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: Result := dmKlient.dstblEmailUebersicht;
    1: Result := dmKlient.dstblKlientSemester;
  else
    Result := nil;
  end;
end;

// Gemeinsamer Handler der Ribbon-Buttonleiste — Tag der Action bestimmt die
// Navigation (0=Erster, 1=Zurueck, 2=Weiter, 3=Letzter), wie in
// ArtikelStammFrm/uFrmGuiTemplate.
procedure TfrmKlient.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := AktiveDetailDs;
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case (Sender as TComponent).Tag of
    0: LDs.DataSet.First;
    1: LDs.DataSet.Prior;
    2: LDs.DataSet.Next;
    3: LDs.DataSet.Last;
  end;
end;

end.
