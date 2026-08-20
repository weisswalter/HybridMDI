unit KundeFrm;

// Kunde-Verwaltung. Wie KlientFrm bewusst NICHT von TfrmGuiTemplate abgeleitet
// (Person+Kunde sind zwei unabhaengige, gemeinsam bearbeitete Tabellen).
// Links: Browse-Grid + Name (person) / Kunden-Besitzer (kunde). Rechts
// (JvRibbon): "Kontakte" (verknuepfte Klienten, siehe KlientDm) und
// "Kontaktdaten" (read-only Uebersicht E-Mail/Telefon/Adresse -- Bearbeiten
// weiterhin im bestehenden Personen-Modul).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase, Vcl.Mask;

type
  TfrmKunde = class(TfrmTemplate)
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
    lblName: TLabel;
    edtName: TDBEdit;
    lblBesitzer: TLabel;
    cboBesitzer: TDBLookupComboBox;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsKontakte: TTabSheet;
    tsKontaktdaten: TTabSheet;
    barKontakte: TRibbonButtonBar;
    barKontaktdaten: TRibbonButtonBar;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    // Detailseite "Kontakte"
    pnlKontakte: TPanel;
    dbgrdKontakte: TDBGrid;
    // Detailseite "Kontaktdaten"
    pnlKontaktdaten: TPanel;
    dbgrdEmail: TDBGrid;
    dbgrdTelefon: TDBGrid;
    dbgrdAdresse: TDBGrid;
    dbgrdKunden: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdKundenCellClick(Column: TColumn);
    procedure btnNeuClick(Sender: TObject);
    procedure btnAendernClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
  private
    // DataSource der aktuell sichtbaren Ribbon-Detailseite (Muster wie
    // ArtikelStammFrm.AktiveDetailDs) -- 0 = Kontakte, 1 = Kontaktdaten.
    function AktiveDetailDs: TDataSource;
  end;

var
  frmKunde: TfrmKunde;

implementation

{$R *.dfm}

uses
  KundeDm;

procedure TfrmKunde.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmKunde := nil;
end;

procedure TfrmKunde.dbgrdKundenCellClick(Column: TColumn);
begin
  if dmKunde.qryKunden.IsEmpty then
    Exit;
  dmKunde.LadeKunde(dmKunde.qryKunden.FieldByName('person_id').AsInteger);
end;

procedure TfrmKunde.btnNeuClick(Sender: TObject);
begin
  dmKunde.NeuerKunde;
end;

procedure TfrmKunde.btnAendernClick(Sender: TObject);
begin
  dmKunde.BearbeitenKunde;
end;

procedure TfrmKunde.btnSpeichernClick(Sender: TObject);
begin
  dmKunde.SpeichernKunde;
end;

procedure TfrmKunde.btnAbbrechenClick(Sender: TObject);
begin
  dmKunde.AbbrechenKunde;
end;

// 0 = Kontakte (verknuepfte Klienten), 1 = Kontaktdaten (E-Mail-Uebersicht
// als fuehrendes Grid)
function TfrmKunde.AktiveDetailDs: TDataSource;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: Result := dmKunde.dstblKontakte;
    1: Result := dmKunde.dstblEmailUebersicht;
  else
    Result := nil;
  end;
end;

// Gemeinsamer Handler der Ribbon-Buttonleiste — Tag der Action bestimmt die
// Navigation (0=Erster, 1=Zurueck, 2=Weiter, 3=Letzter).
procedure TfrmKunde.ActionRechtsExecute(Sender: TObject);
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
