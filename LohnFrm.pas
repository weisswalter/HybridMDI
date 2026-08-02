unit LohnFrm;

// Lohnmodul — Oberflaeche. Aufbau wie MailFrm:
//   oben  Jahr/Monat + Aktionsleiste (Lohnlauf, Freigeben, Ausbezahlt)
//   links Personenliste, darunter die Abrechnungen des gewaehlten Monats
//   rechts TRibbonPanel mit vier Reitern:
//     "Abrechnung"  — die Einzelposten des gewaehlten Belegs
//     "Vereinbarung"— person_lohn der gewaehlten Person
//     "Zulagen"     — lohn_zulage der gewaehlten Person
//     "Abz'u'ge"    — lohn_abzugsart des Mandanten (AHV/ALV/BVG)
//
// Gerechnet wird hier NICHTS — der Lauf passiert in der Datenbank, dieses
// Fenster stoesst ihn an und zeigt das Ergebnis (siehe LohnDm).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmLohn = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actLohnlauf: TAction;
    actLohnlaufPerson: TAction;
    actNeuLaden: TAction;
    actFreigeben: TAction;
    actAusbezahlt: TAction;
    actLoeschen: TAction;
    ActionListRechts: TActionList;
    actNeuR: TAction;
    actAendernR: TAction;
    actSpeichernR: TAction;
    actAbbrechenR: TAction;
    actLoeschenR: TAction;
    pnlTop: TPanel;
    lblJahr: TLabel;
    edtJahr: TEdit;
    lblMonat: TLabel;
    cboMonat: TComboBox;
    btnLohnlauf: TJvNavPanelButtonTop;
    btnLohnlaufPerson: TJvNavPanelButtonTop;
    btnNeuLaden: TJvNavPanelButtonTop;
    btnFreigeben: TJvNavPanelButtonTop;
    btnAusbezahlt: TJvNavPanelButtonTop;
    btnLoeschen: TJvNavPanelButtonTop;
    pnlLeft: TPanel;
    dbgrdPersonen: TDBGrid;
    splLeft: TSplitter;
    dbgrdPerioden: TDBGrid;
    lblSummen: TLabel;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsAbrechnung: TTabSheet;
    tsVereinbarung: TTabSheet;
    tsZulagen: TTabSheet;
    tsAbzuege: TTabSheet;
    barAbrechnung: TRibbonButtonBar;
    barVereinbarung: TRibbonButtonBar;
    barZulagen: TRibbonButtonBar;
    barAbzuege: TRibbonButtonBar;
    pnlAbrechnung: TPanel;
    dbgrdPositionen: TDBGrid;
    pnlBeleg: TPanel;
    lblBeleg: TLabel;
    pnlVereinbarung: TPanel;
    dbgrdLohn: TDBGrid;
    pnlLohnHinweis: TPanel;
    lblLohnHinweis: TLabel;
    pnlZulagen: TPanel;
    dbgrdZulage: TDBGrid;
    pnlZulageHinweis: TPanel;
    lblZulageHinweis: TLabel;
    pnlAbzuege: TPanel;
    dbgrdAbzug: TDBGrid;
    pnlAbzugHinweis: TPanel;
    lblAbzugHinweis: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdPersonenCellClick(Column: TColumn);
    procedure dbgrdPeriodenCellClick(Column: TColumn);
    procedure actLohnlaufExecute(Sender: TObject);
    procedure actLohnlaufPersonExecute(Sender: TObject);
    procedure actNeuLadenExecute(Sender: TObject);
    procedure actFreigebenExecute(Sender: TObject);
    procedure actAusbezahltExecute(Sender: TObject);
    procedure actLoeschenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
  private
    function AktuellePerson: Integer;
    function AktuellePeriode: Integer;
    function Jahr: Integer;
    function Monat: Integer;
    // Welcher Reiter gerade offen ist, bestimmt, worauf Neu/Aendern/Speichern
    // wirken. Reiter 0 (Abrechnung) hat keine bearbeitbare Liste.
    function AktuellerDataSet: TDataSet;
    procedure PeriodeGewechselt;
    procedure SummenZeigen;
    procedure HinweiseSetzen;
  end;

var
  frmLohn: TfrmLohn;

implementation

{$R *.dfm}

uses
  System.DateUtils,
  LohnDm;

procedure TfrmLohn.FormCreate(Sender: TObject);
begin
  edtJahr.Text := IntToStr(YearOf(Date));
  // Vorgabe ist der VORmonat: abgerechnet wird, was vorbei ist.
  cboMonat.ItemIndex := MonthOf(IncMonth(Date, -1)) - 1;

  HinweiseSetzen;
  actNeuLadenExecute(nil);
end;

procedure TfrmLohn.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmLohn := nil;
end;

function TfrmLohn.Jahr: Integer;
begin
  Result := StrToIntDef(edtJahr.Text, YearOf(Date));
end;

function TfrmLohn.Monat: Integer;
begin
  Result := cboMonat.ItemIndex + 1;
  if (Result < 1) or (Result > 12) then
    Result := MonthOf(Date);
end;

function TfrmLohn.AktuellePerson: Integer;
begin
  if dmLohn.qryPersonen.Active and not dmLohn.qryPersonen.IsEmpty then
    Result := dmLohn.qryPersonen.FieldByName('person_id').AsInteger
  else
    Result := 0;
end;

function TfrmLohn.AktuellePeriode: Integer;
begin
  if dmLohn.qryPerioden.Active and not dmLohn.qryPerioden.IsEmpty then
    Result := dmLohn.qryPerioden.FieldByName('periode_id').AsInteger
  else
    Result := 0;
end;

// Sagt dem Anwender, woran er gerade ist — besonders wichtig beim Reiter
// "Abzuege": ohne hinterlegte Saetze rechnet der Lauf mit der Pauschale aus
// der Lohnvereinbarung, und das sieht man den Zahlen sonst nicht an.
procedure TfrmLohn.HinweiseSetzen;
begin
  lblLohnHinweis.Caption :=
    'Eine Lohn' + #228 + 'nderung ist ein NEUER Satz ab dem Stichtag - die alte ' +
    'Vereinbarung bitte mit "g' + #252 + 'ltig bis" abschliessen, nicht ' +
    #252 + 'berschreiben. Sonst w' + #252 + 'rden vergangene Monate ' +
    'nachtr' + #228 + 'glich neu bewertet.';

  lblZulageHinweis.Caption :=
    'Sozialpflichtig = z' + #228 + 'hlt zum AHV-pflichtigen Lohn. Spesen und ' +
    'Kinderzulagen tun das NICHT, eine Pr' + #228 + 'mie schon. Falsch gesetzt ' +
    'verrechnet sich jeder Abzug.';

  if dmLohn.HatAbzugssaetze then
    lblAbzugHinweis.Caption :=
      'Beitrags' + #228 + 'tze gelten je Mandant und Zeitraum. ACHTUNG: Die ' +
      'Vorschlagswerte sind vor dem ersten echten Lohnlauf gegen die aktuelle ' +
      'AHV-/BVG-Mitteilung zu pr' + #252 + 'fen - die S' + #228 + 'tze ' +
      #228 + 'ndern j' + #228 + 'hrlich.'
  else
    lblAbzugHinweis.Caption :=
      'F' + #252 + 'r diesen Mandanten sind KEINE Beitrags' + #228 + 'tze ' +
      'hinterlegt. Der Lohnlauf rechnet deshalb mit der Pauschale aus der ' +
      'Lohnvereinbarung (Nebenkosten in %), nicht mit AHV/ALV/BVG im Einzelnen.';
end;

procedure TfrmLohn.dbgrdPersonenCellClick(Column: TColumn);
begin
  dmLohn.WaehlePerson(AktuellePerson);
end;

procedure TfrmLohn.dbgrdPeriodenCellClick(Column: TColumn);
begin
  PeriodeGewechselt;
end;

procedure TfrmLohn.PeriodeGewechselt;
begin
  dmLohn.LadePositionen(AktuellePeriode);
  SummenZeigen;
end;

// Die Kernzahlen im Klartext ueber den Positionen — das Grid allein
// beantwortet die Frage "was kostet die Stelle" nicht auf einen Blick.
procedure TfrmLohn.SummenZeigen;
var
  LQ: TDataSet;
begin
  LQ := dmLohn.qryPerioden;
  if not LQ.Active or LQ.IsEmpty then
  begin
    lblBeleg.Caption := 'Keine Abrechnung gew' + #228 + 'hlt.';
    lblSummen.Caption := '';
    Exit;
  end;

  lblBeleg.Caption := Format(
    '%s %s - %s (%s), %d/%d   |   Brutto %.2f   Abz' + #252 + 'ge %.2f   ' +
    'Netto %.2f   |   Arbeitgeber %.2f   Gesamtkosten %.2f %s',
    [LQ.FieldByName('nachname_firmenname').AsString,
     LQ.FieldByName('vorname').AsString,
     LQ.FieldByName('anstellungsart').AsString,
     LQ.FieldByName('lohnart').AsString,
     LQ.FieldByName('monat').AsInteger, LQ.FieldByName('jahr').AsInteger,
     LQ.FieldByName('brutto').AsFloat,
     LQ.FieldByName('abzuege_an').AsFloat,
     LQ.FieldByName('netto').AsFloat,
     LQ.FieldByName('abzuege_ag').AsFloat,
     LQ.FieldByName('kosten_gesamt').AsFloat,
     LQ.FieldByName('waehrung').AsString]);

  lblSummen.Caption := Format(
    'Soll %.1f h   Ist %.1f h   Abwesend %.1f h   ' + #220 + 'berstunden %.2f h ' +
    '(bezahlt %.1f h)   Status: %s',
    [LQ.FieldByName('soll_minuten').AsInteger / 60,
     LQ.FieldByName('ist_minuten').AsInteger / 60,
     LQ.FieldByName('abwesenheit_minuten').AsInteger / 60,
     LQ.FieldByName('ueber_stunden').AsFloat,
     LQ.FieldByName('ueber_minuten_bezahlt').AsInteger / 60,
     LQ.FieldByName('status').AsString]);
end;

procedure TfrmLohn.actNeuLadenExecute(Sender: TObject);
begin
  dmLohn.LadePerioden(Jahr, Monat);
  PeriodeGewechselt;
end;

procedure TfrmLohn.actLohnlaufExecute(Sender: TObject);
var
  LMeldung: string;
begin
  if MessageDlg(Format('Lohnlauf f' + #252 + 'r %d/%d starten?' + sLineBreak +
    sLineBreak + 'Bereits freigegebene oder ausbezahlte Abrechnungen bleiben ' +
    'unver' + #228 + 'ndert.', [Monat, Jahr]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    LMeldung := dmLohn.Lohnlauf(Jahr, Monat);
  finally
    Screen.Cursor := crDefault;
  end;
  actNeuLadenExecute(nil);
  ShowMessage(LMeldung);
end;

procedure TfrmLohn.actLohnlaufPersonExecute(Sender: TObject);
var
  LMeldung: string;
begin
  Screen.Cursor := crHourGlass;
  try
    LMeldung := dmLohn.LohnlaufPerson(AktuellePerson, Jahr, Monat);
  finally
    Screen.Cursor := crDefault;
  end;
  actNeuLadenExecute(nil);
  ShowMessage(LMeldung);
end;

procedure TfrmLohn.actFreigebenExecute(Sender: TObject);
begin
  if AktuellePeriode = 0 then
  begin
    ShowMessage('Bitte zuerst eine Abrechnung w' + #228 + 'hlen.');
    Exit;
  end;
  // Freigabe ist der Punkt, ab dem ein erneuter Lauf den Beleg in Ruhe laesst
  if MessageDlg('Diese Abrechnung freigeben?' + sLineBreak + sLineBreak +
    'Danach ' + #228 + 'ndert ein weiterer Lohnlauf sie nicht mehr.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ShowMessage(dmLohn.StatusSetzen(AktuellePeriode, 'freigegeben'));
  actNeuLadenExecute(nil);
end;

procedure TfrmLohn.actAusbezahltExecute(Sender: TObject);
begin
  if AktuellePeriode = 0 then
  begin
    ShowMessage('Bitte zuerst eine Abrechnung w' + #228 + 'hlen.');
    Exit;
  end;
  ShowMessage(dmLohn.StatusSetzen(AktuellePeriode, 'ausbezahlt'));
  actNeuLadenExecute(nil);
end;

procedure TfrmLohn.actLoeschenExecute(Sender: TObject);
begin
  if AktuellePeriode = 0 then
    Exit;
  if MessageDlg('Diese Abrechnung l' + #246 + 'schen?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ShowMessage(dmLohn.PeriodeLoeschen(AktuellePeriode));
  actNeuLadenExecute(nil);
end;

// Reiter 0 zeigt einen berechneten Beleg — der wird nicht von Hand bearbeitet,
// sondern neu berechnet. Deshalb dort kein DataSet.
function TfrmLohn.AktuellerDataSet: TDataSet;
begin
  case JvRibbonPanel1.ActivePageIndex of
    1: Result := dmLohn.tblLohn;
    2: Result := dmLohn.tblZulage;
    3: Result := dmLohn.tblAbzug;
  else
    Result := nil;
  end;
end;

procedure TfrmLohn.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
  LMeldung: string;
begin
  LDs := AktuellerDataSet;
  if LDs = nil then
  begin
    ShowMessage('Eine berechnete Abrechnung wird nicht von Hand ge' + #228 +
      'ndert - bitte die Vereinbarung anpassen und den Lohnlauf erneut starten.');
    Exit;
  end;

  LMeldung := '';
  case (Sender as TComponent).Tag of
    0: LMeldung := dmLohn.SatzNeu(LDs);
    1: LMeldung := dmLohn.SatzAendern(LDs);
    2: LMeldung := dmLohn.SatzSpeichern(LDs);
    3: dmLohn.SatzAbbrechen(LDs);
    4: if MessageDlg('Diesen Satz l' + #246 + 'schen?', mtConfirmation,
         [mbYes, mbNo], 0) = mrYes then
         LMeldung := dmLohn.SatzLoeschen(LDs);
  end;

  if LMeldung <> '' then
    ShowMessage(LMeldung);

  // Beitragssaetze wirken auf den Hinweistext im Reiter "Abzuege"
  if LDs = dmLohn.tblAbzug then
    HinweiseSetzen;
end;

end.
