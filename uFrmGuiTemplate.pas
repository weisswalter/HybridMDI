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
  uFrmModuleTemplate, JvComponentBase, RibbonPanel, System.ImageList,
  Vcl.ImgList, JvImageList, RibbonButtonBar;

type
  // Reihenfolge = Tag der Actions in beiden Leisten
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  TfrmGuiTemplate = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlStamm: TPanel;
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
    ActionListRechts1: TActionList;
    actErsterR1: TAction;
    actZurueckR1: TAction;
    actWeiterR1: TAction;
    actLetzterR1: TAction;
    actNeuR1: TAction;
    actAendernR1: TAction;
    actSpeichernR1: TAction;
    actAbbrechenR1: TAction;
    actNeuLadenR1: TAction;
    rbnpnl1: TRibbonPanel;
    ActionListRechts2: TActionList;
    actErsterR2: TAction;
    actZurueckR2: TAction;
    actWeiterR2: TAction;
    actLetzterR2: TAction;
    actNeuR2: TAction;
    actAendernR2: TAction;
    actSpeichernR2: TAction;
    actAbbrechenR2: TAction;
    actNeuLadenR2: TAction;
    ActionListRechts3: TActionList;
    actErsterR3: TAction;
    actZurueckR3: TAction;
    actWeiterR3: TAction;
    actLetzterR3: TAction;
    actNeuR3: TAction;
    actAendernR3: TAction;
    actSpeichernR3: TAction;
    actAbbrechenR3: TAction;
    actNeuLadenR3: TAction;
    rbtnbleft: TRibbonButtonBar;
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

    // Speichern und Loeschen gehen ueber diese beiden Haken, nicht mehr
    // direkt ueber Post/Delete des Datasets. Die Vorimplementierung ist das
    // bisherige Verhalten (nur Speicher), damit noch nicht umgebaute Module
    // unveraendert weiterlaufen. Ein Modul, das in die Datenbank schreibt,
    // ueberschreibt sie und ruft die Datenbankfunktion seines DataModules.
    function SatzSpeichern(ADataSet: TDataSet): Boolean; virtual;
    function SatzLoeschen(ADataSet: TDataSet): Boolean; virtual;
  public
  end;

var
  frmGuiTemplate: TfrmGuiTemplate;

implementation

{$R *.dfm}

function TfrmGuiTemplate.SatzSpeichern(ADataSet: TDataSet): Boolean;
begin
  Result := False;
  if not Assigned(ADataSet) then
    Exit;
  if ADataSet.State in dsEditModes then
    ADataSet.Post;
  Result := True;
end;

function TfrmGuiTemplate.SatzLoeschen(ADataSet: TDataSet): Boolean;
begin
  Result := False;
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit;
  ADataSet.Delete;
  Result := True;
end;

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
    naSpeichern:     SatzSpeichern(LDs.DataSet);
    naAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    naAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

// Sucht rekursiv nach einer TRibbonButtonBar mit passendem Tag - beginnend
// bei der aktiven Ribbon-Seite. So kann eine Leiste beliebig tief verschachtelt
// auf der Seite liegen (z.B. innerhalb eines weiteren Panels).
function FindeLeisteMitTag(AParent: TWinControl; ATag: Integer): TRibbonButtonBar;
var
  I: Integer;
  LControl: TControl;
begin
  Result := nil;
  if not Assigned(AParent) then
    Exit;
  for I := 0 to AParent.ControlCount - 1 do
  begin
    LControl := AParent.Controls[I];
    if (LControl is TRibbonButtonBar) and (LControl.Tag = ATag) then
      Exit(TRibbonButtonBar(LControl));
    if LControl is TWinControl then
    begin
      Result := FindeLeisteMitTag(TWinControl(LControl), ATag);
      if Assigned(Result) then
        Exit;
    end;
  end;
end;

// Gemeinsamer Handler der rechten (Ribbon-)Buttonleiste(n) — generisch ueber
// die DataSource der TRibbonButtonBar, die zur ausloesenden Action gehoert.
//
// WARUM NICHT GetDetailDataSource: Sender ist immer die Action selbst, nie
// der geklickte Button - der Weg vom Klick zur konkreten Leiste geht beim
// Umweg ueber eine geteilte Action verloren. Der Ausweg (Walter,
// 06.08.2026): jede der (bis zu drei) rechten ActionLists traegt ihre
// Gruppennummer im eigenen Tag (ActionListRechts1.Tag=1, ...2.Tag=2, ...),
// waehrend die einzelnen Actions weiterhin 0..8 tragen (Reihenfolge wie in
// TNavAktion, genau wie bei ActionListLinks). TAction.ActionList liefert die
// Gruppe, TAction.Tag den Nav-Typ - zwei getrennte Zahlen, kein Konflikt.
// Auf der aktiven Ribbon-Seite wird dann die TRibbonButtonBar mit demselben
// Tag gesucht und deren DataSource verwendet. Mehr als drei Detail-Bereiche
// je Formular sind laut Walter nicht vorgesehen; sollte doch mal ein
// vierter noetig sein, bekommt der eine eigene ActionList mit eigenem
// Handler statt hier mitzulaufen.
procedure TfrmGuiTemplate.ActionRechtsExecute(Sender: TObject);
var
  LAction: TAction;
  LGruppe: Integer;
  LLeiste: TRibbonButtonBar;
  LDs: TDataSource;
begin
  if not (Sender is TAction) then
    Exit;
  LAction := TAction(Sender);
  if not Assigned(LAction.ActionList) then
    Exit;
  LGruppe := LAction.ActionList.Tag;

  if not Assigned(rbnpnl1.PageControl.ActivePage) then
    Exit;
  LLeiste := FindeLeisteMitTag(rbnpnl1.PageControl.ActivePage, LGruppe);
  if not Assigned(LLeiste) then
    Exit;
  LDs := LLeiste.DataSource;

  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case TNavAktion(LAction.Tag) of
    naErster:        LDs.DataSet.First;
    naZurueck:       LDs.DataSet.Prior;
    naWeiter:        LDs.DataSet.Next;
    naLetzter:       LDs.DataSet.Last;
    naNeu:           LDs.DataSet.Append;
    naBearbeiten:    if not LDs.DataSet.IsEmpty then LDs.DataSet.Edit;
    naSpeichern:     SatzSpeichern(LDs.DataSet);
    naAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    naAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

end.
