unit KalkulationFrm;

// Kalkulation — Oberflaeche.
//   oben  Anlegen (Bezeichnung, Jahr, Menge, Artikel) + Aktionsleiste
//   links Kalkulationsliste, darunter die Kernzahlen im Klartext
//   rechts TRibbonPanel:
//     "Positionen"    — Material, Loehne, Maschinen; von Hand oder uebernommen
//     "Blatt"         — die Aufstellung vom Material bis zum Angebotspreis
//     "Zuschlaege"    — Gemeinkostensaetze je Jahr und Bereich
//     "Kostenarten"   — fix/variabel, einzel/gemein, kalkulatorisch
//     "Kostenstellen" — Vor- und Hauptkostenstellen
//     "Konten"        — der Kontenrahmen
//
// Gerechnet wird nichts hier: Jede Zahl kommt aus der Datenbank. Das ist
// Absicht — eine zweite Rechenlogik im Formular waere die sicherste Art,
// Anzeige und Ergebnis auseinanderlaufen zu lassen.

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
  TfrmKalkulation = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actNeu: TAction;
    actRechnen: TAction;
    actMaterial: TAction;
    actFreigeben: TAction;
    actLoeschen: TAction;
    actNeuLaden: TAction;
    ActionListRechts: TActionList;
    actNeuR: TAction;
    actAendernR: TAction;
    actSpeichernR: TAction;
    actAbbrechenR: TAction;
    actLoeschenR: TAction;
    pnlTop: TPanel;
    lblBez: TLabel;
    edtBez: TEdit;
    lblJahr: TLabel;
    edtJahr: TEdit;
    lblMenge: TLabel;
    edtMenge: TEdit;
    lblArtikel: TLabel;
    cboArtikel: TDBLookupComboBox;
    btnNeu: TJvNavPanelButtonTop;
    btnRechnen: TJvNavPanelButtonTop;
    btnMaterial: TJvNavPanelButtonTop;
    btnFreigeben: TJvNavPanelButtonTop;
    btnLoeschen: TJvNavPanelButtonTop;
    btnNeuLaden: TJvNavPanelButtonTop;
    pnlLeft: TPanel;
    dbgrdKalkulation: TDBGrid;
    lblSummen: TLabel;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsPositionen: TTabSheet;
    tsBlatt: TTabSheet;
    tsZuschlaege: TTabSheet;
    tsKostenarten: TTabSheet;
    tsKostenstellen: TTabSheet;
    tsKonten: TTabSheet;
    barPositionen: TRibbonButtonBar;
    barBlatt: TRibbonButtonBar;
    barZuschlaege: TRibbonButtonBar;
    barKostenarten: TRibbonButtonBar;
    barKostenstellen: TRibbonButtonBar;
    barKonten: TRibbonButtonBar;
    pnlPositionen: TPanel;
    dbgrdPositionen: TDBGrid;
    pnlPosHinweis: TPanel;
    lblPosHinweis: TLabel;
    pnlBlatt: TPanel;
    dbgrdBlatt: TDBGrid;
    pnlZuschlaege: TPanel;
    dbgrdZuschlag: TDBGrid;
    pnlZuschlagHinweis: TPanel;
    lblZuschlagHinweis: TLabel;
    pnlKostenarten: TPanel;
    dbgrdKostenart: TDBGrid;
    pnlKostenartUnten: TPanel;
    lblKaKonto: TLabel;
    cboKaKonto: TDBLookupComboBox;
    lblKaHinweis: TLabel;
    pnlKostenstellen: TPanel;
    dbgrdKostenstelle: TDBGrid;
    pnlKostenstelleHinweis: TPanel;
    lblKsHinweis: TLabel;
    pnlKonten: TPanel;
    dbgrdKonto: TDBGrid;
    pnlKontoHinweis: TPanel;
    lblKontoHinweis: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNeuExecute(Sender: TObject);
    procedure actRechnenExecute(Sender: TObject);
    procedure actMaterialExecute(Sender: TObject);
    procedure actFreigebenExecute(Sender: TObject);
    procedure actLoeschenExecute(Sender: TObject);
    procedure actNeuLadenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure dbgrdKalkulationCellClick(Column: TColumn);
  private
    function Jahr: Integer;
    function Menge: Double;
    function GewaehlterArtikel: Integer;
    function AktuellerDataSet: TDataSet;
    procedure SummenZeigen;
  end;

var
  frmKalkulation: TfrmKalkulation;

implementation

{$R *.dfm}

uses
  System.DateUtils,
  KalkulationDm;

procedure TfrmKalkulation.FormCreate(Sender: TObject);
begin
  edtJahr.Text := IntToStr(YearOf(Date));
  edtMenge.Text := '1';

  lblPosHinweis.Caption :=
    'Material l' + #228 + 'sst sich mit "Material" aus der St' + #252 +
    'ckliste holen. L' + #246 + 'hne und Maschinen werden hier von Hand ' +
    'erfasst - Art "lohn" bzw. "maschine", Menge in Stunden. Nach jeder ' +
    #196 + 'nderung "Rechnen" dr' + #252 + 'cken.';

  lblZuschlagHinweis.Caption :=
    'Die S' + #228 + 'tze gelten je Jahr. Eine neue Kalkulation ' + #252 +
    'bernimmt sie und friert sie ein - sp' + #228 + 'tere ' + #196 +
    'nderungen wirken deshalb nicht r' + #252 + 'ckwirkend.';

  lblKaHinweis.Caption :=
    'Kalkulatorische Kostenarten (kalk. Abschreibung, Zins, Wagnis) d' + #252 +
    'rfen KEIN Konto tragen - sie haben in der Buchhaltung kein Gegenst' +
    #252 + 'ck. Fix/variabel entscheidet, was in den Deckungsbeitrag geht.';

  lblKsHinweis.Caption :=
    'Vorkostenstellen (Geb' + #228 + 'ude, Allgemeines) werden auf die ' +
    'Hauptkostenstellen umgelegt. Der Bereich bestimmt, in welchen ' +
    'Zuschlagssatz die Stelle einfliesst.';

  lblKontoHinweis.Caption :=
    'Kontenrahmen KMU. Auf Sammelkonten wird nicht gebucht - sie gliedern ' +
    'nur. Solange kein Buchhaltungsmodul l' + #228 + 'uft, dienen die Konten ' +
    'nur der Zuordnung.';

  SummenZeigen;
end;

procedure TfrmKalkulation.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmKalkulation := nil;
end;

function TfrmKalkulation.Jahr: Integer;
begin
  Result := StrToIntDef(edtJahr.Text, YearOf(Date));
end;

function TfrmKalkulation.Menge: Double;
begin
  Result := StrToFloatDef(edtMenge.Text, 1);
  if Result <= 0 then
    Result := 1;
end;

function TfrmKalkulation.GewaehlterArtikel: Integer;
begin
  if VarIsNull(cboArtikel.KeyValue) then
    Result := 0
  else
    Result := cboArtikel.KeyValue;
end;

// Die Kernzahlen im Klartext. Das Grid allein beantwortet die Frage
// "was kostet es und was verlangen wir" nicht auf einen Blick.
procedure TfrmKalkulation.SummenZeigen;
var
  LQ: TDataSet;
begin
  LQ := dmKalkulation.tblKalkulation;
  if not LQ.Active or LQ.IsEmpty then
  begin
    lblSummen.Caption := 'Keine Kalkulation gew' + #228 + 'hlt.';
    Exit;
  end;

  lblSummen.Caption := Format(
    'Herstellkosten %.2f   Selbstkosten %.2f   Angebot %.2f   ' +
    'je Einheit %.2f   Deckungsbeitrag %.2f   [%s]',
    [LQ.FieldByName('herstellkosten').AsFloat,
     LQ.FieldByName('selbstkosten').AsFloat,
     LQ.FieldByName('angebotspreis').AsFloat,
     LQ.FieldByName('preis_pro_einheit').AsFloat,
     LQ.FieldByName('deckungsbeitrag').AsFloat,
     LQ.FieldByName('status').AsString]);
end;

procedure TfrmKalkulation.dbgrdKalkulationCellClick(Column: TColumn);
begin
  SummenZeigen;
end;

procedure TfrmKalkulation.actNeuExecute(Sender: TObject);
begin
  ShowMessage(dmKalkulation.Neu(edtBez.Text, Jahr, Menge, GewaehlterArtikel));
  SummenZeigen;
end;

procedure TfrmKalkulation.actRechnenExecute(Sender: TObject);
begin
  ShowMessage(dmKalkulation.Rechnen(dmKalkulation.AktuelleKalkulation));
  SummenZeigen;
end;

procedure TfrmKalkulation.actMaterialExecute(Sender: TObject);
begin
  ShowMessage(dmKalkulation.MaterialUebernehmen(
    dmKalkulation.AktuelleKalkulation));
  SummenZeigen;
end;

procedure TfrmKalkulation.actFreigebenExecute(Sender: TObject);
begin
  if dmKalkulation.AktuelleKalkulation = 0 then
  begin
    ShowMessage('Bitte zuerst eine Kalkulation w' + #228 + 'hlen.');
    Exit;
  end;
  if MessageDlg('Diese Kalkulation freigeben?' + sLineBreak + sLineBreak +
    'Danach wird sie nicht mehr neu gerechnet.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ShowMessage(dmKalkulation.StatusSetzen(dmKalkulation.AktuelleKalkulation,
    'freigegeben'));
  SummenZeigen;
end;

procedure TfrmKalkulation.actLoeschenExecute(Sender: TObject);
begin
  if dmKalkulation.AktuelleKalkulation = 0 then
    Exit;
  if MessageDlg('Diese Kalkulation mit allen Positionen l' + #246 + 'schen?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ShowMessage(dmKalkulation.KalkulationLoeschen(
    dmKalkulation.AktuelleKalkulation));
  SummenZeigen;
end;

procedure TfrmKalkulation.actNeuLadenExecute(Sender: TObject);
begin
  dmKalkulation.tblKalkulation.Refresh;
  dmKalkulation.LadeDetails(dmKalkulation.AktuelleKalkulation);
  SummenZeigen;
end;

// Welcher Reiter offen ist, bestimmt, worauf Neu/Aendern/Speichern wirken.
// Das Blatt ist eine reine Ableitung und wird nicht bearbeitet.
function TfrmKalkulation.AktuellerDataSet: TDataSet;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: Result := dmKalkulation.tblPosition;
    2: Result := dmKalkulation.tblZuschlag;
    3: Result := dmKalkulation.tblKostenart;
    4: Result := dmKalkulation.tblKostenstelle;
    5: Result := dmKalkulation.tblKonto;
  else
    Result := nil;      // Reiter 1 = Blatt, reine Ableitung
  end;
end;

procedure TfrmKalkulation.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
  LMeldung: string;
begin
  LDs := AktuellerDataSet;
  if LDs = nil then
  begin
    ShowMessage('Das Blatt ist eine Aufstellung der berechneten Werte und ' +
      'wird nicht bearbeitet - bitte die Positionen ' + #228 + 'ndern und ' +
      'neu rechnen.');
    Exit;
  end;

  LMeldung := '';
  case (Sender as TComponent).Tag of
    0: LMeldung := dmKalkulation.SatzNeu(LDs);
    1: LMeldung := dmKalkulation.SatzAendern(LDs);
    2: LMeldung := dmKalkulation.SatzSpeichern(LDs);
    3: dmKalkulation.SatzAbbrechen(LDs);
    4: if MessageDlg('Diesen Satz l' + #246 + 'schen?', mtConfirmation,
         [mbYes, mbNo], 0) = mrYes then
         LMeldung := dmKalkulation.SatzLoeschen(LDs);
  end;

  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

end.
