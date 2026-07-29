unit EinstellungenFrm;

// Zentrale Typ-Verwaltung (siehe EinstellungenDm fuer den Hintergrund).
// Aufbau wie in den uebrigen Modulen ueber TJvRibbonPanel: ein Reiter je
// Typ-Tabelle, jeder Reiter mit EIGENER Buttonleiste (Neu/Speichern/
// Abbrechen) und einem ContentPanel, das das zugehoerige DBGrid traegt.
//
// Die drei Actions sind fuer alle Reiter dieselben; welche Tabelle sie
// treffen, entscheidet dmEinstellungen.DataSourceFuerTab(ActivePageIndex)
// anhand des gerade aktiven Reiters.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvRibbonPanel,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmEinstellungen = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actNeu: TAction;
    actSpeichern: TAction;
    actAbbrechen: TAction;
    JvRibbonPanel1: TJvRibbonPanel;
    pnlPersonentyp: TPanel;
    dbgrdPersonentyp: TDBGrid;
    pnlRollentyp: TPanel;
    dbgrdRollentyp: TDBGrid;
    pnlAdressentyp: TPanel;
    dbgrdAdressentyp: TDBGrid;
    pnlEmailtyp: TPanel;
    dbgrdEmailtyp: TDBGrid;
    pnlTelefonnummertyp: TPanel;
    dbgrdTelefonnummertyp: TDBGrid;
    pnlRechnungstyp: TPanel;
    dbgrdRechnungstyp: TDBGrid;
    pnlLeadquellentyp: TPanel;
    dbgrdLeadquellentyp: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNeuClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
  end;

var
  frmEinstellungen: TfrmEinstellungen;

implementation

{$R *.dfm}

uses
  EinstellungenDm;

procedure TfrmEinstellungen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmEinstellungen := nil;
end;

procedure TfrmEinstellungen.btnNeuClick(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmEinstellungen.DataSourceFuerTab(JvRibbonPanel1.ActivePageIndex);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  LDs.DataSet.Append;
end;

procedure TfrmEinstellungen.btnSpeichernClick(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmEinstellungen.DataSourceFuerTab(JvRibbonPanel1.ActivePageIndex);
  if (LDs = nil) or (LDs.DataSet = nil) then
    Exit;
  if LDs.DataSet.State in dsEditModes then
    LDs.DataSet.Post;
end;

procedure TfrmEinstellungen.btnAbbrechenClick(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmEinstellungen.DataSourceFuerTab(JvRibbonPanel1.ActivePageIndex);
  if (LDs = nil) or (LDs.DataSet = nil) then
    Exit;
  if LDs.DataSet.State in dsEditModes then
    LDs.DataSet.Cancel;
end;

end.
