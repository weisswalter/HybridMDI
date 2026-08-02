unit uFrmMain;

// MDI-Hauptfenster. Kennt keine DataModule, keine Subforms — nur Events.
// Alle Aktionen gehen über den GlobalEventBus.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList, System.Actions,
  EventBus,
  uAppEvents,
  UInterfaces,
  // Ausnahme: frmMain hat kein eigenes DataModule, nutzt aber die geteilte
  // TdmModuleTemplate.OpenGui, um andere Module ueber den MessageHandler anzustossen.
  // MandantDm: Ausnahme #2 — Mandantenauswahl lebt direkt im Hauptfenster,
  // weil andere Module diesen Kontext brauchen, bevor sie geoeffnet werden.
  udmModuleTemplate, MandantDm, MandantNeuFrm, MandantWaehlenFrm, UIRibbon,
  // Ribbon\HeisenbergRibbon.xml -> RibbonCMDCompiler.exe -> .res + Registrierung
  // der Kommando-IDs. TUIRibbon mappt Ribbon-Kommandos automatisch auf
  // gleichnamige TAction-Komponenten (Actions-ActionList unten).
  HeisenbergRibbon, System.ImageList, Vcl.ImgList, JvImageList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.ComCtrls, JvExComCtrls,
  JvStatusBar, VCLTee.TeCanvas, VCLTee.TeeEdiGrad, JvExControls,
  JvNavigationPane, JvButton, JvComponentBase, JvPageList, JvSpeedButton,
  JvNavPanelButtonTop, JvGradient;

type
  TfrmMain = class(TForm)
    // Namen muessen exakt den Command-Names in HeisenbergRibbon.xml entsprechen
    cmdKunden: TAction;
    cmdArtikel: TAction;
    cmdDokumente: TAction;
    cmdPersonen: TAction;
    cmdLager: TAction;
    cmdScanner: TAction;
    cmdPGManager: TAction;
    cmdMandantNeu: TAction;
    cmdMandantWaehlen: TAction;
    cmdKunde: TAction;
    cmdKlient: TAction;
    cmdKundenBestellung: TAction;
    cmdLieferantenBestellung: TAction;
    cmdLagerEntnahme: TAction;
    cmdEinstellungen: TAction;
    cmdMitarbeiter: TAction;
    cmdMail: TAction;
    cmdLohn: TAction;
    NavPBtnTopLohn: TJvNavPanelButtonTop;
    cmdAnlagen: TAction;
    NavPBtnTopAnlagen: TJvNavPanelButtonTop;
    cmdKalkulation: TAction;
    NavPBtnTopKalkulation: TJvNavPanelButtonTop;
    cmdKurs: TAction;
    cmdAnwesenheit: TAction;
    cmdLehrer: TAction;
    ilstRibbonLI: TJvImageList;
    ActionManager: TActionManager;
    sbrMain: TJvStatusBar; ilstRibbonSI: TJvImageList;
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlRibbon: TPanel;
    pctrModule: TPageControl;
    tsDatei: TTabSheet;
    tsModule: TTabSheet;
    tsWerkzeuge: TTabSheet;
    jvnvpnlhdr1: TJvNavPanelHeader;
    jvnvpnlhdr2: TJvNavPanelHeader;
    jvnvpnlhdr3: TJvNavPanelHeader;
    NavPBtnTopactCnPrefixWizard: TJvNavPanelButtonTop;
    NavPBtnTopKunden: TJvNavPanelButtonTop;
    NavPBtnTopDok: TJvNavPanelButtonTop;
    JvNavPanelButtonTop1: TJvNavPanelButtonTop;
    NavPBtnTopLager: TJvNavPanelButtonTop;
    NavPBtnTopScanner: TJvNavPanelButtonTop;
    NavPBtnTopPGManager: TJvNavPanelButtonTop;
    NavPBtnTopMandantNeu: TJvNavPanelButtonTop;
    jvgrdnt1: TJvGradient;
    jvgrdnt2: TJvGradient;
    jvgrdnt3: TJvGradient;
    procedure cmdKundenExecute(Sender: TObject);
    procedure cmdArtikelExecute(Sender: TObject);
    procedure cmdDokumenteExecute(Sender: TObject);
    procedure cmdPersonenExecute(Sender: TObject);
    procedure cmdLagerExecute(Sender: TObject);
    procedure cmdScannerExecute(Sender: TObject);
    procedure cmdPGManagerExecute(Sender: TObject);
    procedure cmdMandantNeuExecute(Sender: TObject);
    procedure cmdMandantWaehlenExecute(Sender: TObject);
    procedure cmdKundeExecute(Sender: TObject);
    procedure cmdKlientExecute(Sender: TObject);
    procedure cmdKundenBestellungExecute(Sender: TObject);
    procedure cmdLieferantenBestellungExecute(Sender: TObject);
    procedure cmdLagerEntnahmeExecute(Sender: TObject);
    procedure cmdEinstellungenExecute(Sender: TObject);
    procedure cmdMitarbeiterExecute(Sender: TObject);
    procedure cmdMailExecute(Sender: TObject);
    procedure cmdLohnExecute(Sender: TObject);
    procedure cmdAnlagenExecute(Sender: TObject);
    procedure cmdKalkulationExecute(Sender: TObject);
    procedure cmdKursExecute(Sender: TObject);
    procedure cmdAnwesenheitExecute(Sender: TObject);
    procedure cmdLehrerExecute(Sender: TObject);
    procedure mnuKundenClick(Sender: TObject);
    procedure mnuArtikelClick(Sender: TObject);
    procedure mnuPyKundenClick(Sender: TObject);
    procedure mnuPyArtikelClick(Sender: TObject);
    procedure mnuDokumenteClick(Sender: TObject);
    procedure mnuPersonenClick(Sender: TObject);
    procedure mnuMandantNeuClick(Sender: TObject);
    procedure mnuPGManagerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure jvnvpnlhdr1Click(Sender: TObject);
  private
    FRibbonImagesInit: Boolean;
    // Zeigt den aktuell gewaehlten Mandanten (TdmMandant.CurrentMandantName)
    // in sbrMain an — einziger Ort, der die Statuszeile dafuer beschreibt.
    procedure UpdateMandantStatus;
  public
    [Subscribe(TThreadMode.Main)]
    procedure OnKundenResult(AEvent: IKundenResultEvent);
    [Subscribe(TThreadMode.Main)]
    procedure OnArtikelResult(AEvent: IArtikelResultEvent);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  GlobalEventBus.RegisterSubscriberForEvents(Self);
  UpdateMandantStatus;
end;

procedure TfrmMain.UpdateMandantStatus;
var
  LName: string;
begin
  LName := TdmMandant(TdmMandant.GetInstance).CurrentMandantName;
  if LName = '' then
    sbrMain.Panels[0].Text := 'Kein Mandant gewählt'
  else
    sbrMain.Panels[0].Text := 'Mandant: ' + LName;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  GlobalEventBus.UnregisterForEvents(Self);
end;

// Icons kommen aus den ImageLists (Option roAssignImagesFromActionManager).
// Der Ribbon weist sie erst zu, wenn die ImageList ein Change-Ereignis feuert.
// Das stossen wir hier EINMALIG nach dem Laden an — OnLoaded waere zu frueh
// (feuert vor der Registrierung der Change-Links im Framework).
procedure TfrmMain.FormShow(Sender: TObject);
begin
  if FRibbonImagesInit then
    Exit;
  FRibbonImagesInit := True;
  // Stoesst die Icon-Zuweisung aus den ImageLists an. WICHTIG: Es duerfen nur so
  // viele Actions einen ImageIndex >= 0 haben, wie die jeweilige ImageList Bilder
  // hat — sonst extrahiert das Framework aus einem leeren Slot (EInvalidGraphic).
  // try/except + Count-Pruefung halten den Start trotzdem am Leben.
  try
    if ilstRibbonLI.Count > 0 then
      ilstRibbonLI.Change;   // 32x32 -> LargeImage der Ribbon-Commands
  except
  end;
  try
    if ilstRibbonSI.Count > 0 then
      ilstRibbonSI.Change;   // 16x16 -> SmallImage der Ribbon-Commands
  except
  end;
  jvnvpnlhdr1Click(jvnvpnlhdr1);
end;

procedure TfrmMain.jvnvpnlhdr1Click(Sender: TObject);
begin
  jvnvpnlhdr1.StyleManager := PaneStyle2;
  jvnvpnlhdr2.StyleManager := PaneStyle2;
  jvnvpnlhdr3.StyleManager := PaneStyle2;
  (Sender as TJvNavPanelHeader).StyleManager := PaneStyle1 ;
  pctrModule.ActivePageIndex := (Sender as TJvNavPanelHeader).Tag;
end;

// Diese Execute-Methoden sind die einzige Stelle mit der eigentlichen Logik —
// sowohl Menue (unten) als auch Ribbon (per Namensgleichheit) loesen sie aus.
procedure TfrmMain.cmdKundenExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Kunden');
end;

procedure TfrmMain.cmdArtikelExecute(Sender: TObject);
begin
  // Altes ArtikelDm/ArtikelFrm war nur der Python-Demo-Baustein ohne echte
  // DB-Anbindung — der Ribbon-Button oeffnet jetzt direkt das echte
  // ArtikelStamm-Modul (ArtikelStammDm/ArtikelStammFrm).
  TdmModuleTemplate.OpenGui('ArtikelStamm');
end;

procedure TfrmMain.cmdDokumenteExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Dokumente');
end;

procedure TfrmMain.cmdPersonenExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Personen');
end;

procedure TfrmMain.cmdLagerExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Lager');
end;

procedure TfrmMain.cmdScannerExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Scanner');
end;

procedure TfrmMain.cmdPGManagerExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('PGManager');
end;

procedure TfrmMain.cmdKundeExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Kunde');
end;

procedure TfrmMain.cmdKlientExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Klient');
end;

procedure TfrmMain.cmdKundenBestellungExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('KundenBestellung');
end;

procedure TfrmMain.cmdLieferantenBestellungExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('LieferantenBestellung');
end;

procedure TfrmMain.cmdLagerEntnahmeExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('LagerEntnahme');
end;

procedure TfrmMain.cmdEinstellungenExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Einstellungen');
end;

procedure TfrmMain.cmdMitarbeiterExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Mitarbeiter');
end;

procedure TfrmMain.cmdMailExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Mail');
end;

procedure TfrmMain.cmdLohnExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Lohn');
end;

procedure TfrmMain.cmdAnlagenExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Anlagen');
end;

procedure TfrmMain.cmdKalkulationExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Kalkulation');
end;

procedure TfrmMain.cmdKursExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Kurs');
end;

procedure TfrmMain.cmdAnwesenheitExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Anwesenheit');
end;

procedure TfrmMain.cmdLehrerExecute(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('Lehrer');
end;

procedure TfrmMain.mnuKundenClick(Sender: TObject);
begin
  cmdKunden.Execute;
end;

procedure TfrmMain.mnuArtikelClick(Sender: TObject);
begin
  cmdArtikel.Execute;
end;

procedure TfrmMain.mnuPyKundenClick(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('PyKunden');
end;

procedure TfrmMain.mnuPyArtikelClick(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('PyArtikel');
end;

procedure TfrmMain.mnuDokumenteClick(Sender: TObject);
begin
  cmdDokumente.Execute;
end;

procedure TfrmMain.mnuPersonenClick(Sender: TObject);
begin
  cmdPersonen.Execute;
end;

procedure TfrmMain.mnuMandantNeuClick(Sender: TObject);
begin
  cmdMandantNeu.Execute;
end;

// Einzige Stelle mit der eigentlichen Logik — Ribbon-Button (Datei-Tab) und
// klassisches Menue (falls noch vorhanden) loesen beide dies hier aus.
procedure TfrmMain.cmdMandantNeuExecute(Sender: TObject);
var
  LDlg: TfrmMandantNeu;
  LNewId: Integer;
begin
  LDlg := TfrmMandantNeu.Create(Self);
  try
    if LDlg.ShowModal = mrOk then
    begin
      if LDlg.MandantenName = '' then
      begin
        ShowMessage('Bitte einen Mandantennamen eingeben.');
        Exit;
      end;
      LNewId := TdmMandant(TdmMandant.GetInstance).CreateMandant(LDlg.MandantenName);
      TdmMandant(TdmMandant.GetInstance).CurrentMandantId := LNewId;
      TdmMandant(TdmMandant.GetInstance).CurrentMandantName := LDlg.MandantenName;
      UpdateMandantStatus;
    end;
  finally
    LDlg.Free;
  end;
end;

// Oeffnet den Auswahl-Dialog, uebernimmt die Auswahl als aktiven Mandanten
// (TdmMandant.CurrentMandantId) und haelt die vorhandene ComboBox in
// pnlMandant synchron (RefreshMandantCombo), solange die noch existiert.
procedure TfrmMain.cmdMandantWaehlenExecute(Sender: TObject);
var
  LDlg: TfrmMandantWaehlen;
begin
  LDlg := TfrmMandantWaehlen.Create(Self);
  try
    if LDlg.ShowModal = mrOk then
    begin
      TdmMandant(TdmMandant.GetInstance).CurrentMandantId := LDlg.SelectedMandantId;
      TdmMandant(TdmMandant.GetInstance).CurrentMandantName := LDlg.SelectedMandantName;
      UpdateMandantStatus;
    end;
  finally
    LDlg.Free;
  end;
end;

procedure TfrmMain.mnuPGManagerClick(Sender: TObject);
begin
  TdmModuleTemplate.OpenGui('PGManager');
end;

procedure TfrmMain.OnKundenResult(AEvent: IKundenResultEvent);
begin
  Caption := 'HybridMDI — ' + AEvent.ResultText;
end;

procedure TfrmMain.OnArtikelResult(AEvent: IArtikelResultEvent);
begin
  Caption := 'HybridMDI — ' + AEvent.ResultText;
end;

end.
