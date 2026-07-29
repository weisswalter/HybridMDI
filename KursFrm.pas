unit KursFrm;

// Kursmodul — Oberflaeche.
//   links  Kursliste (Curriculum) + Stammfelder
//   rechts TJvRibbonPanel mit sechs Reitern:
//     Unterkurse    — Baukasten (kurs_kurs)
//     Kompetenzen   — was der Lehrer koennen muss / was vermittelt wird /
//                     was vorausgesetzt wird
//     Material      — Bedarf je Kurs, plus "Entnahme erzeugen"
//     Durchfuehrung — die konkreten Runden (Semester, Leiter, Raum)
//     Termine       — Stundenplan der gewaehlten Durchfuehrung, mit Serienanlage
//     Teilnehmer    — Anmeldungen der gewaehlten Durchfuehrung
//
// Termine/Teilnehmer haengen bewusst an der DURCHFUEHRUNG, nicht am Kurs —
// deshalb muss dort erst eine Zeile gewaehlt sein.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.DateUtils, System.Actions, Vcl.ActnList,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvRibbonPanel,
  GanttPanel,
  VirtualTrees, VirtualTrees.Types, VirtualTrees.BaseTree,
  BaumKnotenData,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmKurs = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actNeu: TAction;
    actAendern: TAction;
    actSpeichern: TAction;
    actAbbrechen: TAction;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    pnlLeft: TPanel;
    dbgrdKurse: TDBGrid;
    pnlEdit: TPanel;
    pnlEditButtons: TPanel;
    btnNeu: TJvNavPanelButtonTop;
    btnAendern: TJvNavPanelButtonTop;
    btnSpeichern: TJvNavPanelButtonTop;
    btnAbbrechen: TJvNavPanelButtonTop;
    pnlEditFelder: TPanel;
    lblKursNr: TLabel;
    edtKursNr: TDBEdit;
    lblBezeichnung: TLabel;
    edtBezeichnung: TDBEdit;
    lblStunden: TLabel;
    edtStunden: TDBEdit;
    lblMinTn: TLabel;
    edtMinTn: TDBEdit;
    lblMaxTn: TLabel;
    edtMaxTn: TDBEdit;
    lblPreis: TLabel;
    edtPreis: TDBEdit;
    lblLernziele: TLabel;
    memLernziele: TDBMemo;
    lblBeschreibung: TLabel;
    memBeschreibung: TDBMemo;
    Splitter1: TSplitter;
    JvRibbonPanel1: TJvRibbonPanel;
    // Reiter 0: Unterkurse
    pnlUnterkurse: TPanel;
    vstUnterkurse: TVirtualStringTree;
    pnlUnterkurseAdd: TPanel;
    lblUnterkurs: TLabel;
    cboUnterkurs: TDBLookupComboBox;
    cbxPflicht: TCheckBox;
    btnUnterkursAdd: TButton;
    btnUnterkursDel: TButton;
    // Reiter 1: Kompetenzen
    pnlKompetenzen: TPanel;
    dbgrdKompetenzen: TDBGrid;
    pnlKompetenzenAdd: TPanel;
    lblKompetenz: TLabel;
    cboKompetenz: TDBLookupComboBox;
    lblRolle: TLabel;
    cboRolle: TComboBox;
    btnKompetenzAdd: TButton;
    btnKompetenzDel: TButton;
    // Reiter 2: Material
    pnlMaterial: TPanel;
    dbgrdMaterial: TDBGrid;
    pnlMaterialAdd: TPanel;
    lblArtikel: TLabel;
    cboArtikel: TDBLookupComboBox;
    lblPauschal: TLabel;
    edtPauschal: TEdit;
    lblProTn: TLabel;
    edtProTn: TEdit;
    cbxRueckgabe: TCheckBox;
    btnMaterialAdd: TButton;
    btnMaterialDel: TButton;
    btnEntnahme: TButton;
    // Reiter 3: Durchfuehrungen
    pnlDurchfuehrung: TPanel;
    dbgrdDurchfuehrung: TDBGrid;
    pnlDurchfuehrungAdd: TPanel;
    lblDfBez: TLabel;
    edtDfBez: TEdit;
    lblSemester: TLabel;
    cboSemester: TDBLookupComboBox;
    lblLeiter: TLabel;
    cboLeiter: TDBLookupComboBox;
    lblRaum: TLabel;
    cboRaum: TDBLookupComboBox;
    btnDfAdd: TButton;
    // Reiter 4: Termine
    pnlTermine: TPanel;
    pnlGanttKopf: TPanel;
    lblGanttTag: TLabel;
    btnGanttZurueck: TButton;
    btnGanttVor: TButton;
    btnGanttHeute: TButton;
    btnGanttAktualisieren: TButton;
    pnlTermineAdd: TPanel;
    lblStart: TLabel;
    edtStart: TEdit;
    lblDauer: TLabel;
    edtDauer: TEdit;
    lblAnzahl: TLabel;
    edtAnzahl: TEdit;
    lblAbstand: TLabel;
    edtAbstand: TEdit;
    lblThema: TLabel;
    edtThema: TEdit;
    btnTerminAdd: TButton;
    btnSerieAdd: TButton;
    btnTerminDel: TButton;
    // Reiter 5: Teilnehmer
    pnlTeilnehmer: TPanel;
    dbgrdTeilnehmer: TDBGrid;
    pnlTeilnehmerAdd: TPanel;
    lblPerson: TLabel;
    cboPerson: TDBLookupComboBox;
    btnTnAdd: TButton;
    btnTnDel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdKurseCellClick(Column: TColumn);
    procedure dbgrdDurchfuehrungCellClick(Column: TColumn);
    procedure actNeuExecute(Sender: TObject);
    procedure actAendernExecute(Sender: TObject);
    procedure actSpeichernExecute(Sender: TObject);
    procedure actAbbrechenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure vstUnterkurseInitNode(Sender: TBaseVirtualTree;
      ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstUnterkurseInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstUnterkurseGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure btnUnterkursAddClick(Sender: TObject);
    procedure btnUnterkursDelClick(Sender: TObject);
    procedure btnKompetenzAddClick(Sender: TObject);
    procedure btnKompetenzDelClick(Sender: TObject);
    procedure btnMaterialAddClick(Sender: TObject);
    procedure btnMaterialDelClick(Sender: TObject);
    procedure btnEntnahmeClick(Sender: TObject);
    procedure btnDfAddClick(Sender: TObject);
    procedure btnTerminAddClick(Sender: TObject);
    procedure btnSerieAddClick(Sender: TObject);
    procedure btnTerminDelClick(Sender: TObject);
    procedure btnTnAddClick(Sender: TObject);
    procedure btnTnDelClick(Sender: TObject);
    procedure btnGanttZurueckClick(Sender: TObject);
    procedure btnGanttVorClick(Sender: TObject);
    procedure btnGanttHeuteClick(Sender: TObject);
    procedure btnGanttAktualisierenClick(Sender: TObject);
    procedure edtStartChange(Sender: TObject);
    procedure GanttBalkenClick(Sender: TObject; AZeile: TGanttZeile;
      ABalken: TGanttBalken);
  private
    // Wurzelknoten des Baukasten-Baums. Haelt die Interface-Kette am
    // Leben - der VST raeumt seine Knoten per Refcounting selbst auf.
    FBaukastenWurzeln: TList<IBaumKnoten>;
    // Die Belegungsansicht ersetzt das fruehere Termine-Grid. Zur Laufzeit
    // erzeugt, damit das Formular unabhaengig davon compiliert, ob das
    // Package mit der Komponente gerade in der IDE installiert ist.
    FGantt: TGanttPanel;
    FGanttTag: TDate;
    procedure BaukastenBaumAufbauen;
    // Der im Baum markierte Knoten - Bezugsgroesse fuer Hinzufuegen
    // und Entfernen, nicht mehr die Kursliste links.
    function GewaehlterBaumKnoten: IBaumKnoten;
    procedure GanttAufbauen;
    // Liest Startzeit und Dauer aus der Eingabezeile und legt daraus das
    // Bedarfsband. Liefert False, wenn die Eingabe (noch) unvollstaendig ist.
    function BedarfLesen(out AVon, ABis: TDateTime): Boolean;
    function AktuellerKurs: Integer;
    function AktuelleDurchfuehrung: Integer;
    function LookupId(ACombo: TDBLookupComboBox): Integer;
    function StartZeit(out AWert: TDateTime): Boolean;
  end;

var
  frmKurs: TfrmKurs;

implementation

{$R *.dfm}

uses
  KursDm;

procedure TfrmKurs.FormCreate(Sender: TObject);
begin
  cboRolle.Items.Clear;
  cboRolle.Items.Add('lehrer');
  cboRolle.Items.Add('vermittelt');
  cboRolle.Items.Add('voraussetzung');
  cboRolle.ItemIndex := 0;
  edtDauer.Text   := '90';
  edtAnzahl.Text  := '12';
  edtAbstand.Text := '1';
  edtStart.Text   := FormatDateTime('dd.mm.yyyy hh:nn', Now);

  // Spalten per Code statt im DFM - dieselbe Entscheidung wie bei
  // vstBestand im ArtikelStamm (vermeidet DFM-Property-Fallstricke).
  vstUnterkurse.Header.Columns.Clear;
  vstUnterkurse.Header.Columns.Add.Text := 'Kurs';
  vstUnterkurse.Header.Columns[0].Width := 300;
  vstUnterkurse.Header.Columns.Add.Text := 'Kurs-Nr';
  vstUnterkurse.Header.Columns[1].Width := 90;
  vstUnterkurse.Header.Columns.Add.Text := 'Std';
  vstUnterkurse.Header.Columns[2].Width := 60;
  vstUnterkurse.Header.Columns[2].Alignment := taRightJustify;
  vstUnterkurse.Header.Columns.Add.Text := 'Summe';
  vstUnterkurse.Header.Columns[3].Width := 70;
  vstUnterkurse.Header.Columns[3].Alignment := taRightJustify;
  vstUnterkurse.Header.Columns.Add.Text := 'Pflicht';
  vstUnterkurse.Header.Columns[4].Width := 60;
  vstUnterkurse.Header.AutoSizeIndex := 0;
  // hoAutoResize ist Pflicht, sonst bleibt die Spalte bei 50px und der
  // Baumtext wird auf ein Zeichen abgeschnitten (siehe ArtikelStammFrm).
  vstUnterkurse.Header.Options := vstUnterkurse.Header.Options
    + [TVTHeaderOption.hoVisible, TVTHeaderOption.hoAutoResize];
  vstUnterkurse.TreeOptions.PaintOptions :=
    vstUnterkurse.TreeOptions.PaintOptions
    - [TVTPaintOption.toShowRoot]
    + [TVTPaintOption.toShowTreeLines, TVTPaintOption.toShowButtons];
  vstUnterkurse.TreeOptions.SelectionOptions :=
    vstUnterkurse.TreeOptions.SelectionOptions
    + [TVTSelectionOption.toFullRowSelect];
  vstUnterkurse.Font.Size := 10;

  // Ereignisse per Code binden - wie bei vstBestand im ArtikelStamm
  vstUnterkurse.OnInitChildren := vstUnterkurseInitChildren;
  vstUnterkurse.OnInitNode := vstUnterkurseInitNode;
  vstUnterkurse.OnGetText := vstUnterkurseGetText;

  // Baum gleich beim Oeffnen fuellen - dmKurs.OpenKurs hat die Daten
  // vor dem Erzeugen des Formulars schon geladen. Ohne das bleibt der
  // Reiter leer, bis man in die Kursliste klickt.
  BaukastenBaumAufbauen;

  FGantt := TGanttPanel.Create(Self);
  FGantt.Parent := pnlTermine;
  FGantt.Align := alClient;
  FGantt.OnBalkenClick := GanttBalkenClick;
  FGanttTag := Date;
end;

procedure TfrmKurs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FBaukastenWurzeln);
  Action := caFree;
  frmKurs := nil;
end;

function TfrmKurs.AktuellerKurs: Integer;
begin
  if dmKurs.tblKurs.Active and not dmKurs.tblKurs.IsEmpty then
    Result := dmKurs.tblKurs.FieldByName('kurs_id').AsInteger
  else
    Result := 0;
end;

function TfrmKurs.AktuelleDurchfuehrung: Integer;
begin
  if dmKurs.qryDurchfuehrungen.Active and not dmKurs.qryDurchfuehrungen.IsEmpty then
    Result := dmKurs.qryDurchfuehrungen.FieldByName('durchfuehrung_id').AsInteger
  else
    Result := 0;
end;

function TfrmKurs.LookupId(ACombo: TDBLookupComboBox): Integer;
begin
  if VarIsNull(ACombo.KeyValue) then
    Result := 0
  else
    Result := ACombo.KeyValue;
end;

function TfrmKurs.StartZeit(out AWert: TDateTime): Boolean;
begin
  Result := TryStrToDateTime(edtStart.Text, AWert);
  if not Result then
    ShowMessage('Bitte Startzeit als TT.MM.JJJJ HH:MM eingeben.');
end;

procedure TfrmKurs.dbgrdKurseCellClick(Column: TColumn);
begin
  if AktuellerKurs > 0 then
  begin
    dmKurs.LadeDetails(AktuellerKurs);
    BaukastenBaumAufbauen;
  end;
end;

procedure TfrmKurs.dbgrdDurchfuehrungCellClick(Column: TColumn);
begin
  if AktuelleDurchfuehrung > 0 then
    dmKurs.LadeDurchfuehrungsdetails(AktuelleDurchfuehrung);
end;

// ── Stammdaten ─────────────────────────────────────────────────────────────
procedure TfrmKurs.actNeuExecute(Sender: TObject);
begin
  dmKurs.tblKurs.Append;
end;

procedure TfrmKurs.actAendernExecute(Sender: TObject);
begin
  if not dmKurs.tblKurs.IsEmpty then
    dmKurs.tblKurs.Edit;
end;

procedure TfrmKurs.actSpeichernExecute(Sender: TObject);
begin
  if dmKurs.tblKurs.State in dsEditModes then
    dmKurs.tblKurs.Post;
end;

procedure TfrmKurs.actAbbrechenExecute(Sender: TObject);
begin
  if dmKurs.tblKurs.State in dsEditModes then
    dmKurs.tblKurs.Cancel;
end;

procedure TfrmKurs.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: LDs := dmKurs.qryUnterkurse;
    1: LDs := dmKurs.qryKompetenzen;
    2: LDs := dmKurs.qryMaterial;
    3: LDs := dmKurs.qryDurchfuehrungen;
    4: LDs := dmKurs.qryTermine;
    5: LDs := dmKurs.qryTeilnehmer;
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
  if LDs = dmKurs.qryDurchfuehrungen then
    dbgrdDurchfuehrungCellClick(nil);
end;

// ── Unterkurse ─────────────────────────────────────────────────────────────
function TfrmKurs.GewaehlterBaumKnoten: IBaumKnoten;
begin
  Result := nil;
  if Assigned(vstUnterkurse.FocusedNode) then
    Result := vstUnterkurse.GetInterfaceFromNodeData<IBaumKnoten>(
      vstUnterkurse.FocusedNode);
end;

// Der neue Unterkurs haengt unter dem im BAUM markierten Knoten - damit
// laesst sich auf jeder Ebene einhaengen, nicht nur unter dem Hauptkurs.
procedure TfrmKurs.btnUnterkursAddClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
  LEltern: Integer;
begin
  if LookupId(cboUnterkurs) = 0 then
  begin
    ShowMessage('Bitte unten einen Kurs w' + #228 + 'hlen.');
    Exit;
  end;

  LKnoten := GewaehlterBaumKnoten;
  if Assigned(LKnoten) then
    LEltern := LKnoten.Id
  else
    LEltern := AktuellerKurs;

  if LEltern = 0 then
  begin
    ShowMessage('Bitte im Baum den Kurs markieren, unter dem eingeh' +
      #228 + 'ngt werden soll.');
    Exit;
  end;

  dmKurs.UnterkursHinzufuegen(LEltern, LookupId(cboUnterkurs),
    cbxPflicht.Checked);
  BaukastenBaumAufbauen;
end;

// Haengt den markierten Knoten von SEINEM Elternknoten aus. Der Kurs
// selbst bleibt bestehen.
procedure TfrmKurs.btnUnterkursDelClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := GewaehlterBaumKnoten;
  if not Assigned(LKnoten) then
  begin
    ShowMessage('Bitte im Baum den Unterkurs markieren.');
    Exit;
  end;
  if LKnoten.Ebene = 0 then
  begin
    ShowMessage('Das ist der Hauptkurs selbst.');
    Exit;
  end;

  dmKurs.UnterkursEntfernen(LKnoten.ElternId, LKnoten.Id);
  BaukastenBaumAufbauen;
end;

// ── Kompetenzen ────────────────────────────────────────────────────────────
procedure TfrmKurs.btnKompetenzAddClick(Sender: TObject);
begin
  if (AktuellerKurs = 0) or (LookupId(cboKompetenz) = 0) then
  begin
    ShowMessage('Bitte einen Kurs und eine Kompetenz w'#228'hlen.');
    Exit;
  end;
  dmKurs.KompetenzHinzufuegen(AktuellerKurs, LookupId(cboKompetenz),
    cboRolle.Text);
end;

procedure TfrmKurs.btnKompetenzDelClick(Sender: TObject);
begin
  if dmKurs.qryKompetenzen.IsEmpty then Exit;
  dmKurs.KompetenzEntfernen(AktuellerKurs,
    dmKurs.qryKompetenzen.FieldByName('kompetenz_id').AsInteger,
    dmKurs.qryKompetenzen.FieldByName('rolle').AsString);
end;

// ── Material ───────────────────────────────────────────────────────────────
procedure TfrmKurs.btnMaterialAddClick(Sender: TObject);
var
  LP, LT: Double;
begin
  if (AktuellerKurs = 0) or (LookupId(cboArtikel) = 0) then
  begin
    ShowMessage('Bitte einen Kurs und einen Artikel w'#228'hlen.');
    Exit;
  end;
  if not TryStrToFloat(edtPauschal.Text, LP) then LP := 0;
  if not TryStrToFloat(edtProTn.Text, LT) then LT := 0;
  if (LP = 0) and (LT = 0) then
  begin
    ShowMessage('Bitte eine Menge angeben — pauschal oder pro Teilnehmer.');
    Exit;
  end;
  dmKurs.MaterialHinzufuegen(AktuellerKurs, LookupId(cboArtikel), LP, LT,
    cbxRueckgabe.Checked);
end;

procedure TfrmKurs.btnMaterialDelClick(Sender: TObject);
begin
  if dmKurs.qryMaterial.IsEmpty then Exit;
  dmKurs.MaterialEntfernen(AktuellerKurs,
    dmKurs.qryMaterial.FieldByName('artikel_id').AsInteger);
end;

// Erzeugt den Entnahme-Beleg fuer die gewaehlte Durchfuehrung. Die Menge
// rechnet die Datenbank (v_kurs_materialbedarf): pauschal + pro Teilnehmer.
procedure TfrmKurs.btnEntnahmeClick(Sender: TObject);
var
  LDf: Integer;
begin
  LDf := AktuelleDurchfuehrung;
  if LDf = 0 then
  begin
    ShowMessage('Bitte zuerst im Reiter "Durchf'#252'hrung" eine Runde w'#228'hlen — ' +
      'der Materialbedarf h'#228'ngt an der Teilnehmerzahl.');
    Exit;
  end;
  ShowMessage(dmKurs.EntnahmeErzeugen(LDf));
end;

// ── Durchfuehrung ──────────────────────────────────────────────────────────
procedure TfrmKurs.btnDfAddClick(Sender: TObject);
begin
  if AktuellerKurs = 0 then
  begin
    ShowMessage('Bitte zuerst einen Kurs w'#228'hlen.');
    Exit;
  end;
  dmKurs.DurchfuehrungAnlegen(AktuellerKurs, LookupId(cboSemester),
    LookupId(cboLeiter), LookupId(cboRaum), edtDfBez.Text);
  edtDfBez.Clear;
end;

// ── Termine ────────────────────────────────────────────────────────────────
procedure TfrmKurs.btnTerminAddClick(Sender: TObject);
var
  LVon: TDateTime;
  LDauer: Integer;
  LMeldung: string;
begin
  if AktuelleDurchfuehrung = 0 then
  begin
    ShowMessage('Bitte zuerst eine Durchf'#252'hrung w'#228'hlen.');
    Exit;
  end;
  if not StartZeit(LVon) then Exit;
  if not TryStrToInt(edtDauer.Text, LDauer) then LDauer := 90;

  LMeldung := dmKurs.TerminAnlegen(AktuelleDurchfuehrung, LVon,
    IncMinute(LVon, LDauer), edtThema.Text);
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

procedure TfrmKurs.btnSerieAddClick(Sender: TObject);
var
  LVon: TDateTime;
  LDauer, LAnzahl, LAbstand: Integer;
begin
  if AktuelleDurchfuehrung = 0 then
  begin
    ShowMessage('Bitte zuerst eine Durchf'#252'hrung w'#228'hlen.');
    Exit;
  end;
  if not StartZeit(LVon) then Exit;
  if not TryStrToInt(edtDauer.Text, LDauer) then LDauer := 90;
  if not TryStrToInt(edtAnzahl.Text, LAnzahl) then LAnzahl := 1;
  if not TryStrToInt(edtAbstand.Text, LAbstand) then LAbstand := 1;

  ShowMessage(dmKurs.SerieAnlegen(AktuelleDurchfuehrung, LVon, LDauer,
    LAnzahl, LAbstand, edtThema.Text));
end;

procedure TfrmKurs.btnTerminDelClick(Sender: TObject);
begin
  if dmKurs.qryTermine.IsEmpty then Exit;
  dmKurs.TerminEntfernen(dmKurs.qryTermine.FieldByName('termin_id').AsInteger);
end;

// ── Teilnehmer ─────────────────────────────────────────────────────────────
procedure TfrmKurs.btnTnAddClick(Sender: TObject);
begin
  if (AktuelleDurchfuehrung = 0) or (LookupId(cboPerson) = 0) then
  begin
    ShowMessage('Bitte eine Durchf'#252'hrung und eine Person w'#228'hlen.');
    Exit;
  end;
  dmKurs.TeilnehmerHinzufuegen(AktuelleDurchfuehrung, LookupId(cboPerson));
end;

procedure TfrmKurs.btnTnDelClick(Sender: TObject);
begin
  if dmKurs.qryTeilnehmer.IsEmpty then Exit;
  dmKurs.TeilnehmerEntfernen(AktuelleDurchfuehrung,
    dmKurs.qryTeilnehmer.FieldByName('person_id').AsInteger);
end;

// -- Belegungsansicht (Reiter "Termine") ------------------------------
// Zeigt den gewaehlten Tag mit drei Gruppen: die Termine DIESER
// Durchfuehrung, darunter die beteiligten Lehrer und Raeume mit ihrer
// GESAMTEN Belegung. Erst dadurch sieht man, ob ein Leiter oder Raum schon
// anderweitig verplant ist - eine reine Liste der eigenen Termine kann das
// nicht zeigen.
function TfrmKurs.BedarfLesen(out AVon, ABis: TDateTime): Boolean;
var
  LDauer: Integer;
begin
  AVon := 0;
  ABis := 0;
  Result := TryStrToDateTime(edtStart.Text, AVon);
  if not Result then
    Exit;
  if not TryStrToInt(edtDauer.Text, LDauer) then
    LDauer := 90;
  ABis := IncMinute(AVon, LDauer);
end;

// -- Belegungsansicht (Reiter "Termine") ------------------------------
// Zwei Betriebsarten:
//   OHNE Bedarf  - es erscheinen nur die Ressourcen, die an dem Tag
//                  tatsaechlich verplant sind.
//   MIT Bedarf   - Startzeit und Dauer sind eingegeben: dann kommen die
//                  Zeilen aus fn_raum_auswahl/fn_lehrer_auswahl, also ALLE
//                  Raeume und Lehrer mit Begruendung, und das Bedarfsband
//                  liegt senkrecht darueber. Nicht geeignete Zeilen werden
//                  blass gezeichnet - man sieht sie, kann sie aber nicht
//                  versehentlich waehlen.
procedure TfrmKurs.GanttAufbauen;
var
  LZeile: TGanttZeile;
  LSchluessel, LTitel: string;
  LStatus: TGanttStatus;
  LDf, LKurs: Integer;
  LVon, LBis: TDateTime;
  LHatBedarf: Boolean;
begin
  if not Assigned(FGantt) then
    Exit;

  lblGanttTag.Caption := FormatDateTime('dddd, dd.mm.yyyy', FGanttTag);
  LDf := AktuelleDurchfuehrung;
  LKurs := AktuellerKurs;

  LHatBedarf := BedarfLesen(LVon, LBis) and (LKurs > 0);
  if LHatBedarf then
  begin
    // Der Tag richtet sich nach dem geplanten Termin, nicht umgekehrt
    FGanttTag := Trunc(LVon);
    lblGanttTag.Caption := FormatDateTime('dddd, dd.mm.yyyy', FGanttTag);
    dmKurs.LadeEignung(LKurs, LVon, LBis);
  end;

  dmKurs.LadeBelegung(FGanttTag);
  FGantt.Datum := FGanttTag;

  FGantt.BeginUpdate;
  try
    FGantt.Leeren;

    FGantt.GruppeHinzufuegen('Diese Durchf' + #252 + 'hrung');
    FGantt.ZeileHinzufuegen('df', 'Termine', LDf).Auswaehlbar := True;

    FGantt.GruppeHinzufuegen('Lehrer');
    if LHatBedarf and dmKurs.qryLehrerEignung.Active then
    begin
      dmKurs.qryLehrerEignung.First;
      while not dmKurs.qryLehrerEignung.Eof do
      begin
        LZeile := FGantt.ZeileHinzufuegen(
          'lehrer:' + dmKurs.qryLehrerEignung.FieldByName('person_id').AsString,
          dmKurs.qryLehrerEignung.FieldByName('name').AsString,
          dmKurs.qryLehrerEignung.FieldByName('person_id').AsInteger);
        LZeile.Auswaehlbar := dmKurs.qryLehrerEignung.FieldByName('geeignet').AsBoolean;
        LZeile.Zusatz := dmKurs.qryLehrerEignung.FieldByName('anstellungsart').AsString + ' - ' +
                         dmKurs.qryLehrerEignung.FieldByName('begruendung').AsString;
        dmKurs.qryLehrerEignung.Next;
      end;
    end;

    FGantt.GruppeHinzufuegen('R' + #228 + 'ume');
    if LHatBedarf and dmKurs.qryRaumEignung.Active then
    begin
      dmKurs.qryRaumEignung.First;
      while not dmKurs.qryRaumEignung.Eof do
      begin
        LZeile := FGantt.ZeileHinzufuegen(
          'raum:' + dmKurs.qryRaumEignung.FieldByName('raum_id').AsString,
          dmKurs.qryRaumEignung.FieldByName('bezeichnung').AsString,
          dmKurs.qryRaumEignung.FieldByName('raum_id').AsInteger);
        LZeile.Auswaehlbar := dmKurs.qryRaumEignung.FieldByName('geeignet').AsBoolean;
        LZeile.Zusatz := dmKurs.qryRaumEignung.FieldByName('begruendung').AsString;
        dmKurs.qryRaumEignung.Next;
      end;
    end;

    // Balken aus der tatsaechlichen Belegung ueber die Zeilen legen.
    // Fehlt eine Zeile (ohne Bedarf sind noch keine da), wird sie hier
    // nachgetragen - so bleibt die Ansicht in beiden Betriebsarten voll.
    dmKurs.qryBelegung.First;
    while not dmKurs.qryBelegung.Eof do
    begin
      LTitel := dmKurs.qryBelegung.FieldByName('kurs').AsString;
      if dmKurs.qryBelegung.FieldByName('thema').AsString <> '' then
        LTitel := LTitel + ' - ' + dmKurs.qryBelegung.FieldByName('thema').AsString;

      if dmKurs.qryBelegung.FieldByName('status').AsString = 'ausgefallen' then
        LStatus := gsGesperrt
      else if dmKurs.qryBelegung.FieldByName('status').AsString = 'geplant' then
        LStatus := gsGewuenscht
      else
        LStatus := gsBelegt;

      if dmKurs.qryBelegung.FieldByName('durchfuehrung_id').AsInteger = LDf then
      begin
        LZeile := FGantt.ZeileNach('df');
        if Assigned(LZeile) then
          LZeile.BalkenHinzufuegen(LTitel,
            dmKurs.qryBelegung.FieldByName('beginn').AsDateTime,
            dmKurs.qryBelegung.FieldByName('ende').AsDateTime,
            LStatus).Kennung := dmKurs.qryBelegung.FieldByName('termin_id').AsInteger;
      end;

      if not dmKurs.qryBelegung.FieldByName('leiter_person_id').IsNull then
      begin
        LSchluessel := 'lehrer:' + dmKurs.qryBelegung.FieldByName('leiter_person_id').AsString;
        LZeile := FGantt.ZeileNach(LSchluessel);
        if not Assigned(LZeile) then
        begin
          LZeile := FGantt.ZeileHinzufuegen(LSchluessel,
            dmKurs.qryBelegung.FieldByName('leiter').AsString,
            dmKurs.qryBelegung.FieldByName('leiter_person_id').AsInteger);
          LZeile.Auswaehlbar := not LHatBedarf;
        end;
        LZeile.BalkenHinzufuegen(LTitel,
          dmKurs.qryBelegung.FieldByName('beginn').AsDateTime,
          dmKurs.qryBelegung.FieldByName('ende').AsDateTime,
          LStatus).Kennung := dmKurs.qryBelegung.FieldByName('termin_id').AsInteger;
      end;

      if not dmKurs.qryBelegung.FieldByName('raum_id').IsNull then
      begin
        LSchluessel := 'raum:' + dmKurs.qryBelegung.FieldByName('raum_id').AsString;
        LZeile := FGantt.ZeileNach(LSchluessel);
        if not Assigned(LZeile) then
        begin
          LZeile := FGantt.ZeileHinzufuegen(LSchluessel,
            dmKurs.qryBelegung.FieldByName('raum').AsString,
            dmKurs.qryBelegung.FieldByName('raum_id').AsInteger);
          LZeile.Auswaehlbar := not LHatBedarf;
        end;
        LZeile.BalkenHinzufuegen(LTitel,
          dmKurs.qryBelegung.FieldByName('beginn').AsDateTime,
          dmKurs.qryBelegung.FieldByName('ende').AsDateTime,
          LStatus).Kennung := dmKurs.qryBelegung.FieldByName('termin_id').AsInteger;
      end;

      dmKurs.qryBelegung.Next;
    end;
  finally
    FGantt.EndUpdate;
  end;

  if LHatBedarf then
  begin
    FGantt.BedarfSetzen(LVon, LBis);
    FGantt.ZeigeZeit(LVon);
  end
  else
  begin
    FGantt.BedarfLoeschen;
    FGantt.ZeigeZeit(Trunc(FGanttTag) + EncodeTime(8, 0, 0, 0));
  end;
end;

// Jede Aenderung an Startzeit oder Dauer verschiebt das Bedarfsband und
// rechnet die Eignung neu - deshalb haengen beide Felder hier drauf.
procedure TfrmKurs.edtStartChange(Sender: TObject);
begin
  if JvRibbonPanel1.ActivePageIndex = 4 then
    GanttAufbauen;
end;

procedure TfrmKurs.btnGanttZurueckClick(Sender: TObject);
begin
  FGanttTag := IncDay(FGanttTag, -1);
  GanttAufbauen;
end;

procedure TfrmKurs.btnGanttVorClick(Sender: TObject);
begin
  FGanttTag := IncDay(FGanttTag, 1);
  GanttAufbauen;
end;

procedure TfrmKurs.btnGanttHeuteClick(Sender: TObject);
begin
  FGanttTag := Date;
  GanttAufbauen;
end;

procedure TfrmKurs.btnGanttAktualisierenClick(Sender: TObject);
begin
  GanttAufbauen;
end;

// Klick auf einen Balken springt in der Terminliste auf den Satz - so
// bleibt die Bearbeitung unten an dieselbe Auswahl gekoppelt.
procedure TfrmKurs.GanttBalkenClick(Sender: TObject; AZeile: TGanttZeile;
  ABalken: TGanttBalken);
begin
  if (ABalken.Kennung > 0) and dmKurs.qryTermine.Active then
    dmKurs.qryTermine.Locate('termin_id', ABalken.Kennung, []);
end;

// -- Baukasten-Baum (Reiter "Unterkurse") -----------------------------
// Muster 1:1 wie vstBestand im ArtikelStamm: die Wurzelliste haelt die
// Interface-Kette, der VST holt sich pro Knoten nur die Referenz.
procedure TfrmKurs.BaukastenBaumAufbauen;
begin
  vstUnterkurse.BeginUpdate;
  try
    vstUnterkurse.Clear;
    FreeAndNil(FBaukastenWurzeln);
    FBaukastenWurzeln := BaueBaumAusEbenen(dmKurs.qryBaukasten,
      'kurs_id', 'ebene',
      ['bezeichnung', 'kurs_nr', 'unterrichtsstunden', 'stunden_summe',
       'pflicht'],
      'ist_zyklus');
    if Assigned(FBaukastenWurzeln) then
      vstUnterkurse.RootNodeCount := FBaukastenWurzeln.Count;
  finally
    vstUnterkurse.EndUpdate;
  end;
  vstUnterkurse.FullExpand;
end;

procedure TfrmKurs.vstUnterkurseInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LEltern, LKnoten: IBaumKnoten;
begin
  if ParentNode = nil then
  begin
    if not Assigned(FBaukastenWurzeln) then
      Exit;
    LKnoten := FBaukastenWurzeln[Node.Index];
  end
  else
  begin
    LEltern := Sender.GetInterfaceFromNodeData<IBaumKnoten>(ParentNode);
    LKnoten := LEltern.Kinder[Node.Index];
  end;
  Node.SetData(LKnoten);
  if LKnoten.Kinder.Count > 0 then
    Include(InitialStates, ivsHasChildren);
end;

procedure TfrmKurs.vstUnterkurseInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  LKnoten: IBaumKnoten;
begin
  if Node = nil then
  begin
    // Sicherheitsnetz: solange nie geladen wurde, ist die Liste nil
    if Assigned(FBaukastenWurzeln) then
      ChildCount := FBaukastenWurzeln.Count
    else
      ChildCount := 0;
  end
  else
  begin
    LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
    ChildCount := LKnoten.Kinder.Count;
  end;
end;

procedure TfrmKurs.vstUnterkurseGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  if LKnoten = nil then
    Exit;
  if Column <= 0 then
  begin
    CellText := LKnoten.Spalte[0];
    // Datenfehler sichtbar machen statt still abzubrechen
    if LKnoten.IstZyklus then
      CellText := CellText + '  (ZYKLUS!)';
  end
  else
    CellText := LKnoten.Spalte[Column];
end;

end.
