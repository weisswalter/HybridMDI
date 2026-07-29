unit AnwesenheitFrm;

// Anwesenheit / Zeiterfassung — Oberflaeche.
//   links  Datum + Tagesliste aller Personen mit Regime (Soll/Ist/Saldo)
//   rechts TJvRibbonPanel mit fuenf Reitern:
//     Check        — Abschnitte des Klienten abhaken (Vormittag/Nachmittag)
//     Stempel      — kommen/gehen/Pause des Lehrers, mit Korrekturmoeglichkeit
//     Abwesenheit  — Ferien, Krankheit, unentschuldigt (Zeitraeume)
//     Regime       — wie und mit welchem Pensum die Person erfasst wird
//     Monat        — Monatsuebersicht der Person plus Ferienstand
//
// Welcher Reiter fuer wen sinnvoll ist, sagt die Spalte "erfassungsart" in
// der Tagesliste: 'check' -> Klient, 'stempel' -> Lehrer. Beide Reiter bleiben
// bewusst immer sichtbar, damit ein Wechsel des Regimes nichts verbirgt.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.DateUtils, System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvRibbonPanel,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmAnwesenheit = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actListeErzeugen: TAction;
    actVerdichten: TAction;
    actFreigeben: TAction;
    actHeute: TAction;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    pnlLeft: TPanel;
    pnlKopf: TPanel;
    lblDatum: TLabel;
    dtpDatum: TDateTimePicker;
    btnTagZurueck: TButton;
    btnTagVor: TButton;
    pnlKopfButtons: TPanel;
    btnListeErzeugen: TJvNavPanelButtonTop;
    btnVerdichten: TJvNavPanelButtonTop;
    btnFreigeben: TJvNavPanelButtonTop;
    btnHeute: TJvNavPanelButtonTop;
    dbgrdTag: TDBGrid;
    Splitter1: TSplitter;
    JvRibbonPanel1: TJvRibbonPanel;
    // Reiter 0: Check
    pnlCheck: TPanel;
    dbgrdCheck: TDBGrid;
    pnlCheckAdd: TPanel;
    btnAnwesend: TButton;
    btnAbwesend: TButton;
    btnEntschuldigt: TButton;
    lblCheckGrund: TLabel;
    cboCheckGrund: TDBLookupComboBox;
    lblFehlminuten: TLabel;
    edtFehlminuten: TEdit;
    btnAlleAnwesend: TButton;
    // Reiter 1: Stempel
    pnlStempel: TPanel;
    dbgrdStempel: TDBGrid;
    pnlStempelAdd: TPanel;
    lblStempelZeit: TLabel;
    dtpStempelZeit: TDateTimePicker;
    btnKommen: TButton;
    btnGehen: TButton;
    btnPauseStart: TButton;
    btnPauseEnde: TButton;
    btnStempelDel: TButton;
    // Reiter 2: Abwesenheit
    pnlAbwesenheit: TPanel;
    dbgrdAbwesenheit: TDBGrid;
    pnlAbwesenheitAdd: TPanel;
    lblAbwGrund: TLabel;
    cboAbwGrund: TDBLookupComboBox;
    lblAbwVon: TLabel;
    dtpAbwVon: TDateTimePicker;
    lblAbwBis: TLabel;
    dtpAbwBis: TDateTimePicker;
    cbxHalbtags: TCheckBox;
    btnAbwAdd: TButton;
    btnAbwDel: TButton;
    btnAbwGenehmigen: TButton;
    // Reiter 3: Regime
    pnlRegime: TPanel;
    dbgrdRegime: TDBGrid;
    pnlRegimeAdd: TPanel;
    lblRegAb: TLabel;
    dtpRegAb: TDateTimePicker;
    lblRegArt: TLabel;
    cboRegArt: TComboBox;
    lblRegRaster: TLabel;
    cboRegRaster: TDBLookupComboBox;
    lblRegPensum: TLabel;
    edtRegPensum: TEdit;
    lblRegStandort: TLabel;
    cboRegStandort: TDBLookupComboBox;
    btnRegAdd: TButton;
    btnRegBeenden: TButton;
    // Reiter 4: Monat
    pnlMonat: TPanel;
    dbgrdMonat: TDBGrid;
    pnlMonatUnten: TPanel;
    lblFerien: TLabel;
    dbgrdFerien: TDBGrid;
    pnlMonatAdd: TPanel;
    lblFerJahr: TLabel;
    edtFerJahr: TEdit;
    lblFerTage: TLabel;
    edtFerTage: TEdit;
    lblFerUebertrag: TLabel;
    edtFerUebertrag: TEdit;
    btnFerSetzen: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdTagCellClick(Column: TColumn);
    procedure dtpDatumChange(Sender: TObject);
    procedure btnTagZurueckClick(Sender: TObject);
    procedure btnTagVorClick(Sender: TObject);
    procedure actHeuteExecute(Sender: TObject);
    procedure actListeErzeugenExecute(Sender: TObject);
    procedure actVerdichtenExecute(Sender: TObject);
    procedure actFreigebenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure btnAnwesendClick(Sender: TObject);
    procedure btnAbwesendClick(Sender: TObject);
    procedure btnEntschuldigtClick(Sender: TObject);
    procedure btnAlleAnwesendClick(Sender: TObject);
    procedure btnKommenClick(Sender: TObject);
    procedure btnGehenClick(Sender: TObject);
    procedure btnPauseStartClick(Sender: TObject);
    procedure btnPauseEndeClick(Sender: TObject);
    procedure btnStempelDelClick(Sender: TObject);
    procedure btnAbwAddClick(Sender: TObject);
    procedure btnAbwDelClick(Sender: TObject);
    procedure btnAbwGenehmigenClick(Sender: TObject);
    procedure btnRegAddClick(Sender: TObject);
    procedure btnRegBeendenClick(Sender: TObject);
    procedure btnFerSetzenClick(Sender: TObject);
  private
    function AktuellePerson: Integer;
    function AktuellerCheck: Integer;
    function LookupId(ACombo: TDBLookupComboBox): Integer;
    // Setzt den gewaehlten Abschnitt. Grund und Fehlminuten kommen aus der
    // Eingabezeile, damit ein Klick genuegt.
    procedure CheckSetzen(AAnwesend, AEntschuldigt: Boolean);
    procedure Stempeln(const AArt: string);
  end;

var
  frmAnwesenheit: TfrmAnwesenheit;

implementation

{$R *.dfm}

uses
  AnwesenheitDm;

procedure TfrmAnwesenheit.FormCreate(Sender: TObject);
begin
  dtpDatum.Date := dmAnwesenheit.Datum;
  dtpStempelZeit.DateTime := Now;
  dtpAbwVon.Date := Date;
  dtpAbwBis.Date := Date;
  dtpRegAb.Date := Date;

  cboRegArt.Items.Clear;
  cboRegArt.Items.Add('check');
  cboRegArt.Items.Add('stempel');
  cboRegArt.Items.Add('keine');
  cboRegArt.ItemIndex := 0;

  edtRegPensum.Text := '100';
  edtFerJahr.Text := IntToStr(YearOf(Date));
  edtFerTage.Text := '25';
  edtFerUebertrag.Text := '0';
end;

procedure TfrmAnwesenheit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmAnwesenheit := nil;
end;

function TfrmAnwesenheit.AktuellePerson: Integer;
begin
  if dmAnwesenheit.qryTag.Active and not dmAnwesenheit.qryTag.IsEmpty then
    Result := dmAnwesenheit.qryTag.FieldByName('person_id').AsInteger
  else
    Result := 0;
end;

function TfrmAnwesenheit.AktuellerCheck: Integer;
begin
  if dmAnwesenheit.qryCheck.Active and not dmAnwesenheit.qryCheck.IsEmpty then
    Result := dmAnwesenheit.qryCheck.FieldByName('check_id').AsInteger
  else
    Result := 0;
end;

function TfrmAnwesenheit.LookupId(ACombo: TDBLookupComboBox): Integer;
begin
  if VarIsNull(ACombo.KeyValue) then
    Result := 0
  else
    Result := ACombo.KeyValue;
end;

// ── Datum und Tagesliste ───────────────────────────────────────────────────

procedure TfrmAnwesenheit.dbgrdTagCellClick(Column: TColumn);
begin
  if AktuellePerson > 0 then
    dmAnwesenheit.LadeDetails(AktuellePerson);
end;

procedure TfrmAnwesenheit.dtpDatumChange(Sender: TObject);
begin
  dmAnwesenheit.SetzeDatum(dtpDatum.Date);
end;

procedure TfrmAnwesenheit.btnTagZurueckClick(Sender: TObject);
begin
  dtpDatum.Date := IncDay(dtpDatum.Date, -1);
end;

procedure TfrmAnwesenheit.btnTagVorClick(Sender: TObject);
begin
  dtpDatum.Date := IncDay(dtpDatum.Date, 1);
end;

procedure TfrmAnwesenheit.actHeuteExecute(Sender: TObject);
begin
  dtpDatum.Date := Date;
end;

procedure TfrmAnwesenheit.actListeErzeugenExecute(Sender: TObject);
begin
  ShowMessage(dmAnwesenheit.ListeErzeugen);
end;

procedure TfrmAnwesenheit.actVerdichtenExecute(Sender: TObject);
begin
  ShowMessage(dmAnwesenheit.VerdichtenAlle);
end;

procedure TfrmAnwesenheit.actFreigebenExecute(Sender: TObject);
begin
  ShowMessage(dmAnwesenheit.TagFreigeben(AktuellePerson));
end;

procedure TfrmAnwesenheit.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: LDs := dmAnwesenheit.qryCheck;
    1: LDs := dmAnwesenheit.qryStempel;
    2: LDs := dmAnwesenheit.qryAbwesenheit;
    3: LDs := dmAnwesenheit.qryRegime;
    4: LDs := dmAnwesenheit.qryMonat;
  else
    LDs := nil;
  end;
  if (LDs = nil) or not LDs.Active then
    Exit;
  case (Sender as TComponent).Tag of
    0: LDs.First;
    1: LDs.Prior;
    2: LDs.Next;
    3: LDs.Last;
  end;
end;

// ── Check (Klienten) ───────────────────────────────────────────────────────

procedure TfrmAnwesenheit.CheckSetzen(AAnwesend, AEntschuldigt: Boolean);
var
  LFehl: Integer;
begin
  if AktuellerCheck = 0 then
  begin
    ShowMessage('Für diesen Tag gibt es noch keine Abschnitte. Bitte links ' +
      'auf "Liste erzeugen" klicken.');
    Exit;
  end;
  if not TryStrToInt(edtFehlminuten.Text, LFehl) then
    LFehl := 0;

  dmAnwesenheit.CheckSetzen(AktuellerCheck, AAnwesend, AEntschuldigt,
    LookupId(cboCheckGrund), LFehl, '');
end;

procedure TfrmAnwesenheit.btnAnwesendClick(Sender: TObject);
begin
  CheckSetzen(True, False);
end;

procedure TfrmAnwesenheit.btnAbwesendClick(Sender: TObject);
begin
  CheckSetzen(False, False);
end;

procedure TfrmAnwesenheit.btnEntschuldigtClick(Sender: TObject);
begin
  if LookupId(cboCheckGrund) = 0 then
  begin
    ShowMessage('Bitte einen Grund wählen - "entschuldigt" ohne Grund ist ' +
      'für den Nachweis wertlos.');
    Exit;
  end;
  CheckSetzen(False, True);
end;

procedure TfrmAnwesenheit.btnAlleAnwesendClick(Sender: TObject);
var
  LAnzahl: Integer;
begin
  if AktuellePerson = 0 then Exit;
  LAnzahl := dmAnwesenheit.AlleAnwesend(AktuellePerson);
  if LAnzahl = 0 then
    ShowMessage('Es waren keine offenen Abschnitte mehr da.');
end;

// ── Stempel (Lehrer) ───────────────────────────────────────────────────────

procedure TfrmAnwesenheit.Stempeln(const AArt: string);
var
  LZeit: TDateTime;
  LMeldung: string;
begin
  // Uhrzeit aus dem Picker, Datum aus der Tagesauswahl — sonst stempelt man
  // beim Nacherfassen versehentlich auf heute.
  LZeit := Trunc(dmAnwesenheit.Datum) + Frac(dtpStempelZeit.DateTime);
  LMeldung := dmAnwesenheit.StempelSetzen(AktuellePerson, AArt, LZeit);
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

procedure TfrmAnwesenheit.btnKommenClick(Sender: TObject);
begin
  Stempeln('kommen');
end;

procedure TfrmAnwesenheit.btnGehenClick(Sender: TObject);
begin
  Stempeln('gehen');
end;

procedure TfrmAnwesenheit.btnPauseStartClick(Sender: TObject);
begin
  Stempeln('pause_start');
end;

procedure TfrmAnwesenheit.btnPauseEndeClick(Sender: TObject);
begin
  Stempeln('pause_ende');
end;

procedure TfrmAnwesenheit.btnStempelDelClick(Sender: TObject);
begin
  if dmAnwesenheit.qryStempel.IsEmpty then Exit;
  dmAnwesenheit.StempelEntfernen(
    dmAnwesenheit.qryStempel.FieldByName('stempel_id').AsInteger);
end;

// ── Abwesenheit ────────────────────────────────────────────────────────────

procedure TfrmAnwesenheit.btnAbwAddClick(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := dmAnwesenheit.AbwesenheitAnlegen(AktuellePerson,
    LookupId(cboAbwGrund), dtpAbwVon.Date, dtpAbwBis.Date,
    cbxHalbtags.Checked, '');
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

procedure TfrmAnwesenheit.btnAbwDelClick(Sender: TObject);
begin
  if dmAnwesenheit.qryAbwesenheit.IsEmpty then Exit;
  dmAnwesenheit.AbwesenheitEntfernen(
    dmAnwesenheit.qryAbwesenheit.FieldByName('abwesenheit_id').AsInteger);
end;

procedure TfrmAnwesenheit.btnAbwGenehmigenClick(Sender: TObject);
begin
  if dmAnwesenheit.qryAbwesenheit.IsEmpty then Exit;
  // Genehmiger ist vorerst die Person selbst — ein echter Freigabe-Workflow
  // braucht erst die Rollenpruefung aus dem Rechtekonzept.
  dmAnwesenheit.AbwesenheitGenehmigen(
    dmAnwesenheit.qryAbwesenheit.FieldByName('abwesenheit_id').AsInteger,
    AktuellePerson);
end;

// ── Regime ─────────────────────────────────────────────────────────────────

procedure TfrmAnwesenheit.btnRegAddClick(Sender: TObject);
var
  LPensum: Double;
  LMeldung: string;
begin
  if not TryStrToFloat(edtRegPensum.Text, LPensum) then
    LPensum := 100;

  LMeldung := dmAnwesenheit.RegimeAnlegen(AktuellePerson, dtpRegAb.Date,
    cboRegArt.Text, LookupId(cboRegRaster), LPensum, LookupId(cboRegStandort));
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

procedure TfrmAnwesenheit.btnRegBeendenClick(Sender: TObject);
begin
  if dmAnwesenheit.qryRegime.IsEmpty then Exit;
  dmAnwesenheit.RegimeBeenden(
    dmAnwesenheit.qryRegime.FieldByName('arbeitszeit_id').AsInteger,
    dtpRegAb.Date);
end;

// ── Ferienanspruch ─────────────────────────────────────────────────────────

procedure TfrmAnwesenheit.btnFerSetzenClick(Sender: TObject);
var
  LJahr: Integer;
  LTage, LUeber: Double;
begin
  if AktuellePerson = 0 then
  begin
    ShowMessage('Bitte zuerst eine Person wählen.');
    Exit;
  end;
  if not TryStrToInt(edtFerJahr.Text, LJahr) then LJahr := YearOf(Date);
  if not TryStrToFloat(edtFerTage.Text, LTage) then LTage := 0;
  if not TryStrToFloat(edtFerUebertrag.Text, LUeber) then LUeber := 0;

  dmAnwesenheit.FerienAnspruchSetzen(AktuellePerson, LJahr, LTage, LUeber);
end;

end.
