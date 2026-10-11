unit AnlagenFrm;

// Anlagevermoegen — Oberflaeche. Aufbau wie LohnFrm/MailFrm:
//   oben  Jahr + Aktionsleiste (Plan berechnen, alle berechnen, neu laden)
//   links Anlagenliste, direkt bearbeitbar
//   rechts TRibbonPanel mit zwei Reitern:
//     "Abschreibungsplan" — beide Wertreihen nebeneinander samt Differenz
//     "Zuordnung"         — Konten und Standort ueber Auswahllisten
//
// Warum die Zuordnung einen eigenen Reiter hat: Die Verweisfelder heissen
// alle *_id und werden von TdmModuleTemplate im Grid ausgeblendet — sonst
// muesste man dort Zahlen eintippen. Als Auswahlliste steht der Klartext da.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtDlgs, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmAnlagen = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actPlan: TAction;
    actPlanAlle: TAction;
    actNeuLaden: TAction;
    ActionListRechts: TActionList;
    actNeuR: TAction;
    actAendernR: TAction;
    actSpeichernR: TAction;
    actAbbrechenR: TAction;
    actLoeschenR: TAction;
    pnlTop: TPanel;
    lblJahr: TLabel;
    edtJahr: TEdit;
    btnPlan: TJvNavPanelButtonTop;
    btnPlanAlle: TJvNavPanelButtonTop;
    btnNeuLaden: TJvNavPanelButtonTop;
    pnlLeft: TPanel;
    dbgrdAnlagen: TDBGrid;
    lblKennzahl: TLabel;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsPlan: TTabSheet;
    tsZuordnung: TTabSheet;
    barPlan: TRibbonButtonBar;
    barZuordnung: TRibbonButtonBar;
    pnlPlan: TPanel;
    dbgrdPlan: TDBGrid;
    pnlPlanHinweis: TPanel;
    lblPlanHinweis: TLabel;
    pnlZuordnung: TPanel;
    lblKonto: TLabel;
    cboKonto: TDBLookupComboBox;
    lblAufwandKonto: TLabel;
    cboAufwandKonto: TDBLookupComboBox;
    lblRaum: TLabel;
    cboRaum: TDBLookupComboBox;
    lblArtikel: TLabel;
    cboArtikel: TDBLookupComboBox;
    lblZuordnungHinweis: TLabel;
    tsFotos: TTabSheet;
    pnlFotos: TPanel;
    lblFotoBeschr: TLabel;
    dbimgFoto: TDBImage;
    dbgrdFotos: TDBGrid;
    dbmmoBeschreibung: TDBMemo;
    btnFotoLaden: TButton;
    btnFotoLoeschen: TButton;
    dlgFoto: TOpenPictureDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actPlanExecute(Sender: TObject);
    procedure actPlanAlleExecute(Sender: TObject);
    procedure actNeuLadenExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure dbgrdAnlagenCellClick(Column: TColumn);
    procedure btnFotoLadenClick(Sender: TObject);
    procedure btnFotoLoeschenClick(Sender: TObject);
  private
    function Jahr: Integer;
    procedure KennzahlZeigen;
  end;

var
  frmAnlagen: TfrmAnlagen;

implementation

{$R *.dfm}

uses
  System.DateUtils,
  AnlagenDm;

procedure TfrmAnlagen.FormCreate(Sender: TObject);
begin
  edtJahr.Text := IntToStr(YearOf(Date));

  lblPlanHinweis.Caption :=
    'Links die bilanzielle Reihe (Abschluss), rechts die kalkulatorische ' +
    '(Preisfindung). Die Spalte "differenz" zeigt, was die Kalkulation ' +
    'ansetzt und die Buchhaltung nicht kennt - nach Ablauf der steuerlichen ' +
    'Nutzungsdauer ist das der volle kalkulatorische Betrag.';

  lblZuordnungHinweis.Caption :=
    'Konten sind nur f' + #252 + 'r die sp' + #228 + 'tere Buchhaltung ' +
    'n' + #246 + 'tig - die Kalkulation rechnet auch ohne sie. Der Raum ' +
    'entscheidet, auf welche Kostenstelle die kalkulatorischen Kosten dieser ' +
    'Anlage laufen.';

  KennzahlZeigen;
end;

procedure TfrmAnlagen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmAnlagen := nil;
end;

function TfrmAnlagen.Jahr: Integer;
begin
  Result := StrToIntDef(edtJahr.Text, YearOf(Date));
end;

procedure TfrmAnlagen.KennzahlZeigen;
begin
  lblKennzahl.Caption := dmAnlagen.Stundensatz(dmAnlagen.AktuelleAnlage, Jahr);
end;

procedure TfrmAnlagen.dbgrdAnlagenCellClick(Column: TColumn);
begin
  KennzahlZeigen;
  // Fotoliste folgt der Auswahl - Master-Detail filtert im Speicher, nur
  // der Satzzeiger von tblAnlage muss auf der neuen Zeile stehen (steht er
  // schon, CellClick kommt nach dem Zeilenwechsel).
  dmAnlagen.FotosNachladen;
end;

// ── Fotos ───────────────────────────────────────────────────────────────────

procedure TfrmAnlagen.btnFotoLadenClick(Sender: TObject);
var
  I: Integer;
begin
  if dmAnlagen.tblAnlage.IsEmpty then
  begin
    ShowMessage('Bitte zuerst eine Anlage w' + #228 + 'hlen.');
    Exit;
  end;
  if not dlgFoto.Execute then
    Exit;

  for I := 0 to dlgFoto.Files.Count - 1 do
    if dmAnlagen.FotoAnhaengen(dlgFoto.Files[I],
         ChangeFileExt(ExtractFileName(dlgFoto.Files[I]), '')) = 0 then
      ShowMessage('Das Foto wurde nicht gespeichert: ' + dlgFoto.Files[I]);
end;

procedure TfrmAnlagen.btnFotoLoeschenClick(Sender: TObject);
var
  LFotoId: Integer;
begin
  if not dmAnlagen.tblAnlageFoto.Active or dmAnlagen.tblAnlageFoto.IsEmpty then
    Exit;
  LFotoId := dmAnlagen.tblAnlageFoto.FieldByName('foto_id').AsInteger;
  if LFotoId <= 0 then
    Exit;
  if MessageDlg('Dieses Foto endg' + #252 + 'ltig entfernen?', mtConfirmation,
       [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    dmAnlagen.FotoLoeschen(LFotoId);
  except
    on E: Exception do
      ShowMessage('Das Foto konnte nicht entfernt werden:' + sLineBreak +
                  E.Message);
  end;
end;

procedure TfrmAnlagen.actPlanExecute(Sender: TObject);
begin
  ShowMessage(dmAnlagen.PlanRechnen(dmAnlagen.AktuelleAnlage));
  KennzahlZeigen;
end;

procedure TfrmAnlagen.actPlanAlleExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    ShowMessage(dmAnlagen.PlanRechnenAlle);
  finally
    Screen.Cursor := crDefault;
  end;
  KennzahlZeigen;
end;

procedure TfrmAnlagen.actNeuLadenExecute(Sender: TObject);
begin
  dmAnlagen.LadePlan(dmAnlagen.AktuelleAnlage);
  KennzahlZeigen;
end;

procedure TfrmAnlagen.ActionRechtsExecute(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := '';
  case (Sender as TComponent).Tag of
    0: LMeldung := dmAnlagen.SatzNeu;
    1: LMeldung := dmAnlagen.SatzAendern;
    2: LMeldung := dmAnlagen.SatzSpeichern;
    3: dmAnlagen.SatzAbbrechen;
    4: if MessageDlg('Diese Anlage mit ihrem gesamten Abschreibungsplan ' +
         'l' + #246 + 'schen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
         LMeldung := dmAnlagen.SatzLoeschen;
  end;
  if LMeldung <> '' then
    ShowMessage(LMeldung);
  KennzahlZeigen;
end;

end.
