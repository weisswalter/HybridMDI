unit KursAnwesenheitFrm;

// Kurs-Anwesenheit — Oberflaeche.
//   oben  Zeitraum (Vorgabe: laufender Monat) + Aktionsleiste
//   links Terminliste mit Kurs, Raum, Leiter und dem Stand "erfasst/erwartet"
//   rechts TRibbonPanel, ein Reiter "Teilnehmer" — abhaken, entschuldigt,
//         Fehlminuten, Bemerkung
//
// Der Ablauf ist bewusst dreistufig: Termin waehlen -> "Liste erzeugen"
// (holt die angemeldeten Teilnehmer) -> abhaken. Die Liste entsteht nicht
// automatisch, damit ein spaeter angemeldeter Teilnehmer bewusst nachgezogen
// wird (nochmal "Liste erzeugen" ergaenzt nur Fehlende, ueberschreibt nichts).

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
  TfrmKursAnwesenheit = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actLaden: TAction;
    actListeErzeugen: TAction;
    actAlleAnwesend: TAction;
    actAbschliessen: TAction;
    ActionListRechts: TActionList;
    actSpeichernR: TAction;
    actAbbrechenR: TAction;
    pnlTop: TPanel;
    lblVon: TLabel;
    edtVon: TDateTimePicker;
    lblBis: TLabel;
    edtBis: TDateTimePicker;
    lblCoach: TLabel;
    cboCoach: TDBLookupComboBox;
    btnAlleCoaches: TButton;
    btnLaden: TJvNavPanelButtonTop;
    btnListeErzeugen: TJvNavPanelButtonTop;
    btnAlleAnwesend: TJvNavPanelButtonTop;
    btnAbschliessen: TJvNavPanelButtonTop;
    pnlLeft: TPanel;
    dbgrdTermine: TDBGrid;
    lblStand: TLabel;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsTeilnehmer: TTabSheet;
    barTeilnehmer: TRibbonButtonBar;
    pnlTeilnehmer: TPanel;
    pnlHinweis: TPanel;
    lblHinweis: TLabel;
    dbgrdTeilnehmer: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdTermineCellClick(Column: TColumn);
    procedure actLadenExecute(Sender: TObject);
    procedure actListeErzeugenExecute(Sender: TObject);
    procedure actAlleAnwesendExecute(Sender: TObject);
    procedure actAbschliessenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure cboCoachCloseUp(Sender: TObject);
    procedure btnAlleCoachesClick(Sender: TObject);
  private
    function GewaehlterCoach: Integer;
    procedure StandZeigen;
  end;

var
  frmKursAnwesenheit: TfrmKursAnwesenheit;

implementation

{$R *.dfm}

uses
  KursAnwesenheitDm;

procedure TfrmKursAnwesenheit.FormCreate(Sender: TObject);
begin
  edtVon.Date := StartOfTheMonth(Date);
  edtBis.Date := EndOfTheMonth(Date);

  lblHinweis.Caption :=
    'Ablauf: Coach oben w' + #228 + 'hlen, Termin links w' + #228 + 'hlen, ' +
    'dann "Liste erzeugen" - das holt die angemeldeten Teilnehmer. Erneutes ' +
    'Erzeugen erg' + #228 + 'nzt nur Fehlende und '#252'berschreibt nichts. ' +
    '"Alle anwesend" setzt alle auf anwesend, danach die wenigen Fehlenden ' +
    'einzeln zur'#252'cknehmen. Der gew'#228'hlte Coach wird als Erfasser ' +
    'festgehalten.';

  StandZeigen;
end;

// 0 = kein Coach gewaehlt, dann werden alle Termine angezeigt.
function TfrmKursAnwesenheit.GewaehlterCoach: Integer;
begin
  if VarIsNull(cboCoach.KeyValue) then
    Result := 0
  else
    Result := cboCoach.KeyValue;
end;

procedure TfrmKursAnwesenheit.cboCoachCloseUp(Sender: TObject);
begin
  actLadenExecute(nil);
end;

procedure TfrmKursAnwesenheit.btnAlleCoachesClick(Sender: TObject);
begin
  cboCoach.KeyValue := Null;
  actLadenExecute(nil);
end;

procedure TfrmKursAnwesenheit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmKursAnwesenheit := nil;
end;

procedure TfrmKursAnwesenheit.StandZeigen;
var
  LQ: TDataSet;
begin
  LQ := dmKursAnwesenheit.qryTermine;
  if not LQ.Active or LQ.IsEmpty then
  begin
    lblStand.Caption := 'Kein Termin im gew' + #228 + 'hlten Zeitraum.';
    Exit;
  end;
  lblStand.Caption := Format('%s  |  %s  |  erfasst %d von %d Teilnehmern  |  Status: %s',
    [LQ.FieldByName('beginn').AsString,
     LQ.FieldByName('kurs').AsString,
     LQ.FieldByName('erfasst').AsInteger,
     LQ.FieldByName('erwartet').AsInteger,
     LQ.FieldByName('status').AsString]);
end;

procedure TfrmKursAnwesenheit.dbgrdTermineCellClick(Column: TColumn);
begin
  dmKursAnwesenheit.LadeAnwesenheit(dmKursAnwesenheit.AktuellerTermin);
  StandZeigen;
end;

procedure TfrmKursAnwesenheit.actLadenExecute(Sender: TObject);
begin
  if edtBis.Date < edtVon.Date then
  begin
    ShowMessage('Das Bis-Datum liegt vor dem Von-Datum.');
    Exit;
  end;
  dmKursAnwesenheit.LadeTermine(edtVon.Date, edtBis.Date, GewaehlterCoach);
  dmKursAnwesenheit.LadeAnwesenheit(dmKursAnwesenheit.AktuellerTermin);
  StandZeigen;
end;

procedure TfrmKursAnwesenheit.actListeErzeugenExecute(Sender: TObject);
begin
  ShowMessage(dmKursAnwesenheit.ListeErzeugen(dmKursAnwesenheit.AktuellerTermin));
  StandZeigen;
end;

procedure TfrmKursAnwesenheit.actAlleAnwesendExecute(Sender: TObject);
begin
  ShowMessage(dmKursAnwesenheit.AlleAnwesend(dmKursAnwesenheit.AktuellerTermin));
  StandZeigen;
end;

procedure TfrmKursAnwesenheit.actAbschliessenExecute(Sender: TObject);
begin
  ShowMessage(dmKursAnwesenheit.TerminAbschliessen(
    dmKursAnwesenheit.AktuellerTermin));
  StandZeigen;
end;

procedure TfrmKursAnwesenheit.ActionRechtsExecute(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := '';
  case (Sender as TComponent).Tag of
    0: LMeldung := dmKursAnwesenheit.SatzSpeichern;
    1: dmKursAnwesenheit.SatzAbbrechen;
  end;
  if LMeldung <> '' then
    ShowMessage(LMeldung);
  StandZeigen;
end;

end.
