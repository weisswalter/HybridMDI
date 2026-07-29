unit LagerFrm;

// MDI-Child: Lagerverwaltung. Ribbon-Tab-Aufbau wie PersonenFrm:
//   Kopf (TJvNavPanelHeader-Buttons) ueberlagert ein PageControl mit
//   unsichtbaren Tabs — Lager, Raeume, Regale, Adressinfo, Ausstattung.
// Jedes Tabsheet traegt eine eigene Buttonleiste (TJvNavPanelButtonTop,
// gemeinsamer BtnNavClick-Handler, Aktion im Tag). Im Gegensatz zu
// PersonenFrm gibt es hier KEINE Bruecken-Neuanlage-Komplikation (StammNeu):
// lager/adressinfo/raum/ausstattung/regal haben alle eine eigene Sequenz
// ohne stoerende MasterSource-Vorbelegung — "Neu" ist ein simples Append.
//
// Einzige Ausnahme: der Ausstattung-Unterbereich im Raeume-Tab
// (pnlAusstattungBox) verwaltet raum_ausstattung, eine m:n-Bruecke
// (Detail von tblRaum). Der Kontext-Dispatch (KontextZuButton) loest daher
// nicht nur nach TabSheet auf, sondern prueft zuerst, ob der Button in
// einem dedizierten Unterbereich (Container) liegt, bevor er zum Tab-Default
// weitergeht — dadurch bekommt der Ausstattung-Bereich seine eigene
// Navigation, obwohl er nur ein Teil des Raeume-Tabs ist.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtDlgs, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Data.DB, Vcl.StdCtrls, Vcl.Mask,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvDBControls, JvDBLookup,
  uFrmModuleTemplate, JvComponentBase, JvExMask, JvToolEdit, JvMaskEdit;

type
  // Reihenfolge = Tag der Buttons in jeder Leiste
  TLagerAktion = (laErster, laZurueck, laWeiter, laLetzter,
    laNeu, laBearbeiten, laSpeichern, laAbbrechen, laAktualisieren);

  TSeitenInfo = record
    Container: TControl;   // TabSheet ODER ein Unterbereichs-Panel
    NavDs: TDataSource;
  end;

  TfrmLager = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlKopf: TPanel;
    hdrLager: TJvNavPanelHeader;
    hdrRaeume: TJvNavPanelHeader;
    hdrRegale: TJvNavPanelHeader;
    hdrAdressinfo: TJvNavPanelHeader;
    hdrAusstattung: TJvNavPanelHeader;
    pctrModule: TPageControl;

    tsLager: TTabSheet;
    pnlBtnLager: TPanel;
    btnErsterLager, btnZurueckLager, btnWeiterLager, btnLetzterLager,
    btnNeuLager, btnAendernLager, btnSpeichernLager, btnAbbrechenLager,
    btnNeuLadenLager: TJvNavPanelButtonTop;
    grdtLager: TJvGradient;
    pnlFldLager: TPanel;
    lblBarcode: TLabel;
    edtBarcode: TJvDBMaskEdit;
    lblRaum: TLabel;
    cboRaum: TJvDBLookupCombo;
    lblRegal: TLabel;
    cboRegal: TJvDBLookupCombo;
    lblAdresse: TLabel;
    cboAdresse: TJvDBLookupCombo;
    lblBeschreibung: TLabel;
    memBeschreibung: TDBMemo;
    lblPhoto: TLabel;
    imgPhoto: TDBImage;
    btnPhotoLaden: TButton;
    lblQrCode: TLabel;
    imgQrCode: TDBImage;
    btnQrLaden: TButton;
    grdLager: TDBGrid;

    tsRaeume: TTabSheet;
    pnlBtnRaeume: TPanel;
    btnErsterRaeume, btnZurueckRaeume, btnWeiterRaeume, btnLetzterRaeume,
    btnNeuRaeume, btnAendernRaeume, btnSpeichernRaeume, btnAbbrechenRaeume,
    btnNeuLadenRaeume: TJvNavPanelButtonTop;
    grdtRaeume: TJvGradient;
    pnlFldRaeume: TPanel;
    lblRaumAdresse: TLabel;
    cboRaumAdresse: TJvDBLookupCombo;
    lblRaumAdressinfo: TLabel;
    cboRaumAdressinfo: TJvDBLookupCombo;
    lblRaumBezeichnung: TLabel;
    edtRaumBezeichnung: TJvDBMaskEdit;
    lblLaenge: TLabel;
    edtLaenge: TJvDBMaskEdit;
    lblBreite: TLabel;
    edtBreite: TJvDBMaskEdit;
    lblHoehe: TLabel;
    edtHoehe: TJvDBMaskEdit;
    lblRaumBeschreibung: TLabel;
    memRaumBeschreibung: TDBMemo;
    pnlAusstattungBox: TPanel;
    lblAusstattungBox: TLabel;
    pnlBtnRaumAusstattung: TPanel;
    btnErsterRaumAusstattung, btnZurueckRaumAusstattung,
    btnWeiterRaumAusstattung, btnLetzterRaumAusstattung,
    btnNeuRaumAusstattung, btnAendernRaumAusstattung,
    btnSpeichernRaumAusstattung, btnAbbrechenRaumAusstattung,
    btnNeuLadenRaumAusstattung: TJvNavPanelButtonTop;
    grdtRaumAusstattung: TJvGradient;
    pnlFldRaumAusstattung: TPanel;
    lblAusstattungHinzu: TLabel;
    cboAusstattungHinzu: TJvDBLookupCombo;
    grdRaumAusstattung: TDBGrid;

    tsRegale: TTabSheet;
    pnlBtnRegale: TPanel;
    btnErsterRegale, btnZurueckRegale, btnWeiterRegale, btnLetzterRegale,
    btnNeuRegale, btnAendernRegale, btnSpeichernRegale, btnAbbrechenRegale,
    btnNeuLadenRegale: TJvNavPanelButtonTop;
    grdtRegale: TJvGradient;
    pnlFldRegale: TPanel;
    lblRegalRaum: TLabel;
    cboRegalRaum: TJvDBLookupCombo;
    lblRegalBezeichnung: TLabel;
    edtRegalBezeichnung: TJvDBMaskEdit;
    lblRegalBeschreibung: TLabel;
    memRegalBeschreibung: TDBMemo;
    pnlFaecherBox: TPanel;
    lblFaecherBox: TLabel;
    pnlBtnFaecher: TPanel;
    btnErsterFaecher, btnZurueckFaecher, btnWeiterFaecher, btnLetzterFaecher,
    btnNeuFaecher, btnAendernFaecher, btnSpeichernFaecher, btnAbbrechenFaecher,
    btnNeuLadenFaecher: TJvNavPanelButtonTop;
    grdtFaecher: TJvGradient;
    pnlFldFaecher: TPanel;
    lblFaecherBezeichnung: TLabel;
    edtFaecherBezeichnung: TJvDBMaskEdit;
    lblFaecherKapazitaet: TLabel;
    edtFaecherKapazitaet: TJvDBMaskEdit;
    lblFaecherEinheit: TLabel;
    cboFaecherEinheit: TJvDBLookupCombo;
    grdFaecher: TDBGrid;
    grdRegale: TDBGrid;

    tsAdressinfo: TTabSheet;
    pnlBtnAdressinfo: TPanel;
    btnErsterAdressinfo, btnZurueckAdressinfo, btnWeiterAdressinfo,
    btnLetzterAdressinfo, btnNeuAdressinfo, btnAendernAdressinfo,
    btnSpeichernAdressinfo, btnAbbrechenAdressinfo,
    btnNeuLadenAdressinfo: TJvNavPanelButtonTop;
    grdtAdressinfo: TJvGradient;
    pnlFldAdressinfo: TPanel;
    lblAdressinfoAdresse: TLabel;
    cboAdressinfoAdresse: TJvDBLookupCombo;
    lblAdressinfoBeschreibung: TLabel;
    memAdressinfoBeschreibung: TDBMemo;
    grdAdressinfo: TDBGrid;

    tsAusstattung: TTabSheet;
    pnlBtnAusstattung: TPanel;
    btnErsterAusstattung, btnZurueckAusstattung, btnWeiterAusstattung,
    btnLetzterAusstattung, btnNeuAusstattung, btnAendernAusstattung,
    btnSpeichernAusstattung, btnAbbrechenAusstattung,
    btnNeuLadenAusstattung: TJvNavPanelButtonTop;
    grdtAusstattung: TJvGradient;
    grdAusstattung: TDBGrid;

    dlgBild: TOpenPictureDialog;
    grdRaeume: TDBGrid;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure KopfClick(Sender: TObject);
    procedure BtnNavClick(Sender: TObject);
    procedure btnPhotoLadenClick(Sender: TObject);
    procedure btnQrLadenClick(Sender: TObject);
  private
    FSeiten: array of TSeitenInfo;
    FKoepfe: array of TJvNavPanelHeader;
    procedure BaueSeiten;
    procedure SetzeBeschriftungen;
    procedure LadeBild(const AFeld: string; ATbl: TObject);
    function KontextZuButton(AButton: TControl): TDataSource;
  public
  end;

var
  frmLager: TfrmLager;

implementation

{$R *.dfm}

uses
  LagerDm, FireDAC.Comp.Client;

resourcestring
  SFormCaption      = 'Lager';
  SBtnErster        = 'Erster';
  SBtnZurueck       = 'Zur'#252'ck';
  SBtnWeiter        = 'Weiter';
  SBtnLetzter       = 'Letzter';
  SBtnNeu           = 'Neu';
  SBtnBearbeiten    = #196'ndern';
  SBtnSpeichern     = 'Speichern';
  SBtnAbbrechen     = 'Abbrechen';
  SBtnAktualisieren = 'Neu laden';
  SKopfLager        = 'Lager';
  SKopfRaeume       = 'R'#228'ume';
  SKopfRegale       = 'Regale';
  SKopfAdressinfo   = 'Adressinfo';
  SKopfAusstattung  = 'Ausstattung';
  SLblBarcode       = 'Barcode';
  SLblRaum          = 'Raum';
  SLblRegal         = 'Regal';
  SLblAdresse       = 'Adresse';
  SLblBeschreibung  = 'Beschreibung';
  SLblPhoto         = 'Photo';
  SLblQrCode        = 'QR-Code';
  SBtnBildLaden     = 'Bild laden...';
  SLblRaumAdresse   = 'Adresse';
  SLblRaumAdressinfo = 'Adressinfo (optional)';
  SLblRaumBezeichnung = 'Bezeichnung';
  SLblLaenge        = 'L'#228'nge (m)';
  SLblBreite        = 'Breite (m)';
  SLblHoehe         = 'H'#246'he (m)';
  SLblAusstattungBox = 'Ausstattung dieses Raums (mehrere gleichzeitig m'#246'glich)';
  SLblAusstattungHinzu = 'Merkmal';
  SLblRegalRaum     = 'Raum';
  SLblRegalBezeichnung = 'Bezeichnung';
  SLblFaecherBox    = 'F'#228'cher dieses Regals';
  SLblFaecherKapazitaet = 'Kapazit'#228't';
  SLblFaecherEinheit = 'Einheit';
  SLblAdressinfoAdresse = 'Adresse';
  SLblAdressinfoBeschreibung = 'Beschreibung (Eingang/Stockwerk)';

function NavCaption(A: TLagerAktion): string;
begin
  case A of
    laErster:        Result := SBtnErster;
    laZurueck:       Result := SBtnZurueck;
    laWeiter:        Result := SBtnWeiter;
    laLetzter:       Result := SBtnLetzter;
    laNeu:           Result := SBtnNeu;
    laBearbeiten:    Result := SBtnBearbeiten;
    laSpeichern:     Result := SBtnSpeichern;
    laAbbrechen:     Result := SBtnAbbrechen;
    laAktualisieren: Result := SBtnAktualisieren;
  else
    Result := '';
  end;
end;

procedure TfrmLager.FormCreate(Sender: TObject);
begin
  SetzeBeschriftungen;
  BaueSeiten;
  FKoepfe := [hdrLager, hdrRaeume, hdrRegale, hdrAdressinfo, hdrAusstattung];
  KopfClick(hdrLager);
end;

procedure TfrmLager.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmLager := nil;
end;

procedure TfrmLager.SetzeBeschriftungen;
var
  I: Integer;
begin
  Caption := SFormCaption;
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TJvNavPanelButtonTop then
      TJvNavPanelButtonTop(Components[I]).Caption :=
        NavCaption(TLagerAktion(Components[I].Tag));
  hdrLager.Caption        := SKopfLager;
  hdrRaeume.Caption       := SKopfRaeume;
  hdrRegale.Caption       := SKopfRegale;
  hdrAdressinfo.Caption   := SKopfAdressinfo;
  hdrAusstattung.Caption  := SKopfAusstattung;

  lblBarcode.Caption      := SLblBarcode;
  lblRaum.Caption         := SLblRaum;
  lblRegal.Caption        := SLblRegal;
  lblAdresse.Caption      := SLblAdresse;
  lblBeschreibung.Caption := SLblBeschreibung;
  lblPhoto.Caption        := SLblPhoto;
  lblQrCode.Caption       := SLblQrCode;
  btnPhotoLaden.Caption   := SBtnBildLaden;
  btnQrLaden.Caption      := SBtnBildLaden;

  lblRaumAdresse.Caption      := SLblRaumAdresse;
  lblRaumAdressinfo.Caption   := SLblRaumAdressinfo;
  lblRaumBezeichnung.Caption  := SLblRaumBezeichnung;
  lblLaenge.Caption           := SLblLaenge;
  lblBreite.Caption           := SLblBreite;
  lblHoehe.Caption            := SLblHoehe;
  lblRaumBeschreibung.Caption := SLblBeschreibung;
  lblAusstattungBox.Caption   := SLblAusstattungBox;
  lblAusstattungHinzu.Caption := SLblAusstattungHinzu;

  lblRegalRaum.Caption        := SLblRegalRaum;
  lblRegalBezeichnung.Caption := SLblRegalBezeichnung;
  lblRegalBeschreibung.Caption := SLblBeschreibung;

  lblFaecherBox.Caption        := SLblFaecherBox;
  lblFaecherBezeichnung.Caption := SLblRegalBezeichnung;
  lblFaecherKapazitaet.Caption := SLblFaecherKapazitaet;
  lblFaecherEinheit.Caption    := SLblFaecherEinheit;

  lblAdressinfoAdresse.Caption      := SLblAdressinfoAdresse;
  lblAdressinfoBeschreibung.Caption := SLblAdressinfoBeschreibung;
end;

// Kontext-Zuordnung: welches Datenset gehoert zu welchem Container.
// pnlAusstattungBox liegt INNERHALB von tsRaeume, pnlFaecherBox INNERHALB
// von tsRegale — beide werden deshalb zuerst geprueft (KontextZuButton
// laeuft die Parent-Kette von innen nach aussen ab) — Buttons darin loesen
// also auf raum_ausstattung/regal_fach auf, nicht auf raum/regal.
procedure TfrmLager.BaueSeiten;
begin
  SetLength(FSeiten, 7);
  FSeiten[0].Container := tsLager;           FSeiten[0].NavDs := dmLager.dstblLager;
  FSeiten[1].Container := pnlAusstattungBox; FSeiten[1].NavDs := dmLager.dstblRaumAusstattung;
  FSeiten[2].Container := tsRaeume;          FSeiten[2].NavDs := dmLager.dstblRaum;
  FSeiten[3].Container := pnlFaecherBox;     FSeiten[3].NavDs := dmLager.dstblRegalFach;
  FSeiten[4].Container := tsRegale;          FSeiten[4].NavDs := dmLager.dstblRegal;
  FSeiten[5].Container := tsAdressinfo;      FSeiten[5].NavDs := dmLager.dstblAdressinfo;
  FSeiten[6].Container := tsAusstattung;     FSeiten[6].NavDs := dmLager.dstblAusstattung;
end;

procedure TfrmLager.KopfClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FKoepfe) do
    FKoepfe[I].StyleManager := PaneStyle2;
  (Sender as TJvNavPanelHeader).StyleManager := PaneStyle1;
  pctrModule.ActivePageIndex := (Sender as TJvNavPanelHeader).Tag;
end;

function TfrmLager.KontextZuButton(AButton: TControl): TDataSource;
var
  LParent: TControl;
  I: Integer;
begin
  Result := nil;
  LParent := AButton;
  while LParent <> nil do
  begin
    for I := 0 to High(FSeiten) do
      if FSeiten[I].Container = LParent then
        Exit(FSeiten[I].NavDs);
    LParent := LParent.Parent;
  end;
end;

// Gemeinsamer Handler aller Leisten-Buttons — keine Bruecken-Sonderlogik
// noetig (siehe Unit-Kommentar): jede Tabelle hat ihre eigene Sequenz ohne
// stoerende MasterSource-ID-Vorbelegung, "Neu" ist ueberall ein simples
// Append.
procedure TfrmLager.BtnNavClick(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := KontextZuButton(Sender as TControl);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;

  case TLagerAktion((Sender as TComponent).Tag) of
    laErster:        LDs.DataSet.First;
    laZurueck:       LDs.DataSet.Prior;
    laWeiter:        LDs.DataSet.Next;
    laLetzter:       LDs.DataSet.Last;
    laNeu:           LDs.DataSet.Append;
    laBearbeiten:    if not LDs.DataSet.IsEmpty then LDs.DataSet.Edit;
    laSpeichern:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Post;
    laAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    laAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

// Bilddatei in ein Blob-Feld laden. Vcl.Imaging.jpeg/pngimage in uses ->
// TDBImage zeigt JPG/PNG an. ATbl wird als TFDTable erwartet (tblLager).
procedure TfrmLager.LadeBild(const AFeld: string; ATbl: TObject);
var
  LTbl: TFDTable;
begin
  LTbl := TFDTable(ATbl);
  if LTbl.IsEmpty and not (LTbl.State in dsEditModes) then
    Exit;
  if not dlgBild.Execute then
    Exit;
  if not (LTbl.State in dsEditModes) then
    LTbl.Edit;
  TBlobField(LTbl.FieldByName(AFeld)).LoadFromFile(dlgBild.FileName);
end;

procedure TfrmLager.btnPhotoLadenClick(Sender: TObject);
begin
  LadeBild('photo', dmLager.tblLager);
end;

procedure TfrmLager.btnQrLadenClick(Sender: TObject);
begin
  LadeBild('qrcode', dmLager.tblLager);
end;

end.
