unit TemplateFrm;

// Kopiervorlage fuer neue Heisenberg-Modul-Formulare (Form-Haelfte, siehe
// TemplateDm fuer die DataModule-Haelfte). Angelehnt an PersonenFrm/pnlRibbon
// aus frmMain, aber mit TJvRibbonPanel statt handgebautem PageControl +
// Header-Buttons:
//  Links (pnlStamm): Stammdaten-Buttonleiste (9x TJvNavPanelButtonTop) ueber
//    ActionListLinks, darunter ein leeres Feldpanel (pnlStammFelder) als
//    Platzhalter fuer die eigentlichen Stammdaten-Controls.
//  Splitter1: macht die linke Spalte in der Breite verstellbar.
//  Rechts (JvRibbonPanel1): ein Beispiel-Header ("Reiter 1") mit eigener
//    Buttonleiste ueber ActionListRechts — beim Duplizieren fuer ein echtes
//    Modul im Object Inspector weitere Headers[].Buttons-Items anlegen.
// Beide Buttonleisten sind Action-basiert (TAction.Tag = TNavAktion), ein
// gemeinsamer Handler pro Seite (ActionLinksExecute/ActionRechtsExecute)
// wirkt auf die jeweilige DataSource des DataModules (dstblStamm/dstblDetail).
//
// TODO beim Duplizieren fuer ein echtes Modul:
//  - pnlStammFelder mit echten Datenfeldern (JvDBMaskEdit etc.) fuellen
//  - JvRibbonPanel1.Headers erweitern (ein Item pro Tabsheet/Bereich)
//  - ActionRechtsExecute ggf. je Header-Tab unterschiedliche DataSources
//    ansteuern (siehe PersonenFrm.KontextZuButton fuer das Muster bei
//    mehreren Tabs mit unterschiedlichem Kontext)

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvRibbonPanel,
  uFrmModuleTemplate, JvComponentBase;

type
  // Reihenfolge = Tag der Actions in beiden Leisten
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  TfrmVorlage = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlStamm: TPanel;
    pnlStammButtons: TPanel;
    btnErsterStamm, btnZurueckStamm, btnWeiterStamm, btnLetzterStamm,
    btnNeuStamm, btnAendernStamm, btnSpeichernStamm, btnAbbrechenStamm,
    btnNeuLadenStamm: TJvNavPanelButtonTop;
    pnlStammFelder: TPanel;
    Splitter1: TSplitter;
    JvRibbonPanel1: TJvRibbonPanel;
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ActionLinksExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
  private
  public
  end;

var
  frmVorlage: TfrmVorlage;

implementation

{$R *.dfm}

uses
  TemplateDm;

procedure TfrmVorlage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmVorlage := nil;
end;

// Gemeinsamer Handler der linken (Stammdaten-)Buttonleiste — wirkt auf
// dmVorlage.dstblStamm. Analog TfrmPersonen.BtnNavClick, aber ohne die
// Bruecken-Sonderbehandlung (StammNeu/StammVerknuepfen) — die ist nur noetig,
// wenn Stammdaten sich mehrere Datensaetze teilen (siehe PersonenDm).
procedure TfrmVorlage.ActionLinksExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmVorlage.dstblStamm;
  if (LDs.DataSet = nil) or not LDs.DataSet.Active then
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

// Gemeinsamer Handler der rechten Ribbon-Buttonleiste(n) — wirkt auf
// dmVorlage.dstblDetail. Bei mehreren Headers/Tabs spaeter hier wie in
// PersonenFrm.KontextZuButton je nach aktivem Tab die passende DataSource
// waehlen (aktuell: nur ein Tab, daher fest auf dstblDetail).
procedure TfrmVorlage.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmVorlage.dstblDetail;
  if (LDs.DataSet = nil) or not LDs.DataSet.Active then
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
