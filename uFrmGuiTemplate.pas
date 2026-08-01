unit uFrmGuiTemplate;

// Vererbbare Basis-Vorlage fuer alle Stammdaten-Fenster mit Ribbon-Detail
// (z.B. ArtikelStamm, kuenftige KundenStamm, LieferantenStamm, ...).
// Deckt strukturell ab, was bisher per Copy-Paste aus TemplateFrm dupliziert
// wurde — jetzt als ECHTE Delphi-Formularvererbung:
// Datei -> Neu -> Andere... -> Vererbbare Elemente -> TfrmGuiTemplate.
//
// Enthaelt bereits fertig verdrahtet:
//  - pnlStamm (links): 9x TJvNavPanelButtonTop (Erster/Zurueck/Weiter/
//    Letzter/Neu/Aendern/Speichern/Abbrechen/Neu laden) ueber
//    ActionListLinks, darunter leeres pnlStammFelder als Platzhalter fuer
//    die Stammdaten-Felder des jeweiligen Moduls (im Nachfahren einfach
//    Labels/DBEdits HINEIN ziehen — ein geerbtes TPanel darf man mit neuen
//    Kindkontrollen befuellen).
//  - Splitter1: linke Spalte in der Breite verstellbar.
//  - rbnpnl1 (rechts): OHNE vordefinierte Headers — die legt jedes
//    Modul selbst im Object Inspector an (Headers/Buttons/ContentPanel,
//    siehe Tools/RibbonPanel.pas).
//
// WICHTIG fuer Nachfahren: GetStammDataSource / GetDetailDataSource sind
// abstract — jedes Modul MUSS sie ueberschreiben und auf sein eigenes
// DataModule zeigen. GetDetailDataSource bekommt den Ribbon-Tab-Index
// (0-basiert = rbnpnl1.HeaderButtons[i]), damit Module mit mehreren Tabs
// je Tab eine andere DataSource liefern koennen (analog
// PersonenFrm.KontextZuButton, nur generisch ueber den Tab-Index statt
// Parent-Kette).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  uFrmModuleTemplate, JvComponentBase, RibbonPanel;

type
  // Reihenfolge = Tag der Actions in beiden Leisten
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  TfrmGuiTemplate = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlStamm: TPanel;
    pnlStammButtons: TPanel;
    btnErsterStamm, btnZurueckStamm, btnWeiterStamm, btnLetzterStamm,
    btnNeuStamm, btnAendernStamm, btnSpeichernStamm, btnAbbrechenStamm,
    btnNeuLadenStamm: TJvNavPanelButtonTop;
    pnlStammFelder: TPanel;
    Splitter1: TSplitter;
    ActionListLinks: TActionList;
    actErsterL: TAction;
    actZurueckL: TAction;
    actWeiterL: TAction;
    actLetzterL: TAction;
    actNeuL: TAction;
    actAendernL: TAction;
    actSpeichernL: TAction;
    actAbbrechenL: TAction;
    actNeuLadenL: TAction;
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
    rbnpnl1: TRibbonPanel;
    procedure ActionLinksExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
  protected
    // Von jedem Nachfahren zu ueberschreiben — zeigt auf die
    // Stammdaten-DataSource des eigenen DataModules.
    function GetStammDataSource: TDataSource; virtual; abstract;
    // Von jedem Nachfahren zu ueberschreiben — liefert die DataSource fuer
    // den Ribbon-Tab mit Index AHeaderIndex. Module mit nur einem Tab
    // koennen den Parameter ignorieren.
    function GetDetailDataSource(AHeaderIndex: Integer): TDataSource; virtual; abstract;
  public
  end;

var
  frmGuiTemplate: TfrmGuiTemplate;

implementation

{$R *.dfm}

// Gemeinsamer Handler der linken (Stammdaten-)Buttonleiste — generisch ueber
// GetStammDataSource, das jeder Nachfahre ueberschreibt.
procedure TfrmGuiTemplate.ActionLinksExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := GetStammDataSource;
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case TNavAktion((Sender as TComponent).Tag) of
    naErster:        LDs.DataSet.First;
    naZurueck:       LDs.DataSet.Prior;
    naWeiter:        LDs.DataSet.Next;
    naLetzter:       LDs.DataSet.Last;
    naNeu:           LDs.DataSet.Append;
    naBearbeiten:    if not LDs.DataSet.IsEmpty then LDs.DataSet.Edit;
    naSpeichern:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Post;
    naAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    naAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

// Gemeinsamer Handler der rechten (Ribbon-)Buttonleiste(n) — generisch ueber
// GetDetailDataSource(aktueller Tab-Index), das jeder Nachfahre ueberschreibt.
procedure TfrmGuiTemplate.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
 // LDs := GetDetailDataSource(rbnpnl1.ActivePageIndex);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case TNavAktion((Sender as TComponent).Tag) of
    naErster:        LDs.DataSet.First;
    naZurueck:       LDs.DataSet.Prior;
    naWeiter:        LDs.DataSet.Next;
    naLetzter:       LDs.DataSet.Last;
    naNeu:           LDs.DataSet.Append;
    naBearbeiten:    if not LDs.DataSet.IsEmpty then LDs.DataSet.Edit;
    naSpeichern:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Post;
    naAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    naAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

end.
