unit PersonenFrm;

// MDI-Child: Personenverwaltung.
// Aufbau nach dem Muster Unit2 / pnlRibbon aus frmMain — alles designtime
// im DFM (keine Laufzeit-Erzeugung):
//  Links: Personen-Stammdaten mit Buttonleiste im Ribbon-Stil
//    (TJvNavPanelButtonTop + TJvGradient-Fueller). Navigiert wird ueber die
//    Bruecke person_mandant (dstblPersonMandant), die Eingabefelder binden
//    an die aufgeloeste Person (dstblPerson).
//  Rechts: pnlRibbon wie in frmMain — TJvNavPanelHeader-Buttons ueberlagern
//    ein PageControl (Style tsFlatButtons, Tabs mit Margins.Top=25 und
//    TabVisible=False): Adressen, Emails, Telefon, Beziehungen sowie die
//    Typ-Tabellen. Jedes Tabsheet traegt dieselbe Buttonleiste wie links.
//  Die Typ-Seiten pflegen genau die Daten, die vorne in den
//  JvDBLookupCombo-Boxen zur Auswahl stehen.
// Alle Beschriftungen werden in SetzeBeschriftungen aus resourcestrings
// gesetzt (Buttons ueber ihren Tag) und sind damit uebersetzbar.

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
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  TSeitenInfo = record
    Seite: TTabSheet;
    NavDs: TDataSource;      // Datasource fuer Grid und Navigation
    StammDs: TDataSource;    // aufgeloeste Stammtabelle (nil bei Typ-Seiten)
  end;

  TfrmPersonen = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlStamm: TPanel;
    pnlStammButtons: TPanel;
    btnErsterStamm, btnZurueckStamm, btnWeiterStamm, btnLetzterStamm,
    btnNeuStamm, btnAendernStamm, btnSpeichernStamm, btnAbbrechenStamm,
    btnNeuLadenStamm: TJvNavPanelButtonTop;
    pnlStammFelder: TPanel;
    lblNr: TLabel;
    txtNr: TDBText;
    lblVorname: TLabel;
    edtVorname: TJvDBMaskEdit;
    lblNachname: TLabel;
    edtNachname: TJvDBMaskEdit;
    lblPersonTyp: TLabel;
    cboPersonTyp: TJvDBLookupCombo;
    lblErstellt: TLabel;
    txtErstellt: TDBText;
    cbxHauptperson: TDBCheckBox;
    lblBeschreibung: TLabel;
    memBeschreibung: TDBMemo;
    lblPhoto: TLabel;
    imgPhoto: TDBImage;
    btnPhotoLaden: TButton;
    dlgPhoto: TOpenPictureDialog;
    pnlRibbon: TPanel;
    pctrModule: TPageControl;
    tsAdressen: TTabSheet;
    pnlBtnAdr: TPanel;
    btnErsterAdr, btnZurueckAdr, btnWeiterAdr, btnLetzterAdr,
    btnNeuAdr, btnAendernAdr, btnSpeichernAdr, btnAbbrechenAdr,
    btnNeuLadenAdr: TJvNavPanelButtonTop;
    pnlFldAdressen: TPanel;
    lblStrasse: TLabel;
    edtStrasse: TJvDBMaskEdit;
    lblHausNr: TLabel;
    edtHausNr: TJvDBMaskEdit;
    lblPlz: TLabel;
    edtPlz: TJvDBMaskEdit;
    lblOrt: TLabel;
    edtOrt: TJvDBMaskEdit;
    lblAdressTyp: TLabel;
    cboAdressTyp: TJvDBLookupCombo;
    lblBestAdresse: TLabel;
    cboBestAdresse: TJvDBLookupCombo;
    lblLand: TLabel;
    cboLand: TJvDBLookupCombo;
    lblBezirk: TLabel;
    cboBezirk: TJvDBLookupCombo;
    grdAdressen: TDBGrid;
    tsEmails: TTabSheet;
    pnlBtnEml: TPanel;
    btnErsterEml, btnZurueckEml, btnWeiterEml, btnLetzterEml,
    btnNeuEml, btnAendernEml, btnSpeichernEml, btnAbbrechenEml,
    btnNeuLadenEml: TJvNavPanelButtonTop;
    pnlFldEmails: TPanel;
    lblEmail: TLabel;
    cboEmailAdr: TDBComboBox;
    lblEmailTyp: TLabel;
    cboEmailTyp: TJvDBLookupCombo;
    grdEmails: TDBGrid;
    tsTelefon: TTabSheet;
    pnlBtnTel: TPanel;
    btnErsterTel, btnZurueckTel, btnWeiterTel, btnLetzterTel,
    btnNeuTel, btnAendernTel, btnSpeichernTel, btnAbbrechenTel,
    btnNeuLadenTel: TJvNavPanelButtonTop;
    pnlFldTelefon: TPanel;
    lblNummer: TLabel;
    cboTelefonNr: TDBComboBox;
    lblTelefonTyp: TLabel;
    cboTelefonTyp: TJvDBLookupCombo;
    grdTelefon: TDBGrid;
    tsBeziehungen: TTabSheet;
    pnlBtnBez: TPanel;
    btnErsterBez, btnZurueckBez, btnWeiterBez, btnLetzterBez,
    btnNeuBez, btnAendernBez, btnSpeichernBez, btnAbbrechenBez,
    btnNeuLadenBez: TJvNavPanelButtonTop;
    pnlFldBeziehungen: TPanel;
    lblRolle: TLabel;
    cboRolle: TJvDBLookupCombo;
    lblZielPerson: TLabel;
    cboZielPerson: TJvDBLookupCombo;
    cbxMitarbeiter: TDBCheckBox;
    cbxKunde: TDBCheckBox;
    cbxKontakt: TDBCheckBox;
    grdBeziehungen: TDBGrid;
    tsPersonTypen: TTabSheet;
    pnlBtnPTyp: TPanel;
    btnErsterPTyp, btnZurueckPTyp, btnWeiterPTyp, btnLetzterPTyp,
    btnNeuPTyp, btnAendernPTyp, btnSpeichernPTyp, btnAbbrechenPTyp,
    btnNeuLadenPTyp: TJvNavPanelButtonTop;
    grdPersonTypen: TDBGrid;
    tsRollen: TTabSheet;
    pnlBtnRol: TPanel;
    btnErsterRol, btnZurueckRol, btnWeiterRol, btnLetzterRol,
    btnNeuRol, btnAendernRol, btnSpeichernRol, btnAbbrechenRol,
    btnNeuLadenRol: TJvNavPanelButtonTop;
    grdRollen: TDBGrid;
    tsAdressTypen: TTabSheet;
    pnlBtnATyp: TPanel;
    btnErsterATyp, btnZurueckATyp, btnWeiterATyp, btnLetzterATyp,
    btnNeuATyp, btnAendernATyp, btnSpeichernATyp, btnAbbrechenATyp,
    btnNeuLadenATyp: TJvNavPanelButtonTop;
    grdAdressTypen: TDBGrid;
    tsEmailTypen: TTabSheet;
    pnlBtnETyp: TPanel;
    btnErsterETyp, btnZurueckETyp, btnWeiterETyp, btnLetzterETyp,
    btnNeuETyp, btnAendernETyp, btnSpeichernETyp, btnAbbrechenETyp,
    btnNeuLadenETyp: TJvNavPanelButtonTop;
    grdEmailTypen: TDBGrid;
    tsTelefonTypen: TTabSheet;
    pnlBtnTTyp: TPanel;
    btnErsterTTyp, btnZurueckTTyp, btnWeiterTTyp, btnLetzterTTyp,
    btnNeuTTyp, btnAendernTTyp, btnSpeichernTTyp, btnAbbrechenTTyp,
    btnNeuLadenTTyp: TJvNavPanelButtonTop;
    grdTelefonTypen: TDBGrid;
    grdtStamm, grdtAdr, grdtEml, grdtTel, grdtBez, grdtPTyp, grdtRol,
    grdtATyp, grdtETyp, grdtTTyp: TJvGradient;
    hdrAdressen: TJvNavPanelHeader;
    hdrEmails: TJvNavPanelHeader;
    hdrTelefon: TJvNavPanelHeader;
    hdrBeziehungen: TJvNavPanelHeader;
    hdrPersonTypen: TJvNavPanelHeader;
    hdrRollen: TJvNavPanelHeader;
    hdrAdressTypen: TJvNavPanelHeader;
    hdrEmailTypen: TJvNavPanelHeader;
    hdrTelefonTypen: TJvNavPanelHeader;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure KopfClick(Sender: TObject);
    procedure BtnNavClick(Sender: TObject);
    procedure btnPhotoLadenClick(Sender: TObject);
  private
    FSeiten: array of TSeitenInfo;
    FKoepfe: array of TJvNavPanelHeader;
    procedure BaueSeiten;
    procedure SetzeBeschriftungen;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function KontextZuButton(AButton: TControl;
      out ANavDs, AStammDs: TDataSource): Boolean;
  public
  end;

var
  frmPersonen: TfrmPersonen;

implementation

{$R *.dfm}

uses
  PersonenDm, Vcl.Clipbrd;

resourcestring
  SFormCaption      = 'Personen';
  // Buttonleiste (links und auf jedem Tabsheet)
  SBtnErster        = 'Erster';
  SBtnZurueck       = 'Zur'#252'ck';
  SBtnWeiter        = 'Weiter';
  SBtnLetzter       = 'Letzter';
  SBtnNeu           = 'Neu';
  SBtnBearbeiten    = #196'ndern';
  SBtnSpeichern     = 'Speichern';
  SBtnAbbrechen     = 'Abbrechen';
  SBtnAktualisieren = 'Neu laden';
  // Header-Buttons rechts
  SKopfAdressen     = 'Adressen';
  SKopfEmails       = 'Emails';
  SKopfTelefon      = 'Telefon';
  SKopfBeziehungen  = 'Beziehungen';
  SKopfPersonTypen  = 'Personentypen';
  SKopfRollen       = 'Rollen';
  SKopfAdressTypen  = 'Adresstypen';
  SKopfEmailTypen   = 'Emailtypen';
  SKopfTelefonTypen = 'Telefontypen';
  // Feldbeschriftungen
  SLblNr            = 'Nr.';
  SLblVorname       = 'Vorname';
  SLblNachname      = 'Name / Firma';
  SLblPersonTyp     = 'Personentyp';
  SLblErstellt      = 'Erstellt am';
  SLblStrasse       = 'Stra'#223'e';
  SLblHausNr        = 'Nr.';
  SLblPlz           = 'PLZ';
  SLblOrt           = 'Ort';
  SLblAdressTyp     = 'Adresstyp';
  SLblEmail         = 'E-Mail-Adresse';
  SLblEmailTyp      = 'Emailtyp';
  SLblNummer        = 'Nummer';
  SLblTelefonTyp    = 'Telefontyp';
  SLblRolle         = 'Rolle';
  SLblZielPerson    = 'Zielperson';
  SLblBestAdresse   = 'oder bestehende w'#228'hlen';
  SLblLand          = 'Land';
  SLblBezirk        = 'Bezirk';

function NavCaption(A: TNavAktion): string;
begin
  case A of
    naErster:        Result := SBtnErster;
    naZurueck:       Result := SBtnZurueck;
    naWeiter:        Result := SBtnWeiter;
    naLetzter:       Result := SBtnLetzter;
    naNeu:           Result := SBtnNeu;
    naBearbeiten:    Result := SBtnBearbeiten;
    naSpeichern:     Result := SBtnSpeichern;
    naAbbrechen:     Result := SBtnAbbrechen;
    naAktualisieren: Result := SBtnAktualisieren;
  else
    Result := '';
  end;
end;

procedure TfrmPersonen.FormCreate(Sender: TObject);
begin
  SetzeBeschriftungen;
  BaueSeiten;
  FKoepfe := [hdrAdressen, hdrEmails, hdrTelefon, hdrBeziehungen,
    hdrPersonTypen, hdrRollen, hdrAdressTypen, hdrEmailTypen, hdrTelefonTypen];
  // Dropdown der Email-/Telefon-Combos mit den vorhandenen (poolweiten) Werten
  // fuellen, damit man einen bestehenden (geteilten) Satz waehlen oder neu
  // tippen kann. Bei Adressen uebernimmt cboBestAdresse denselben Zweck.
  dmPersonen.FuelleEmailAdressen(cboEmailAdr.Items);
  dmPersonen.FuelleTelefonNummern(cboTelefonNr.Items);
  KopfClick(hdrAdressen);
  KeyPreview := True;
  OnKeyDown := FormKeyDown;   // WICHTIG!
end;

procedure TfrmPersonen.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('V')) and (Shift = [ssCtrl]) then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
      ImgPhoto.Picture.Assign(Clipboard);
  end;
end;

procedure TfrmPersonen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmPersonen := nil;
end;

// Alle Beschriftungen aus resourcestrings — die Buttons ueber ihren Tag,
// damit die 10 Leisten nicht einzeln gepflegt werden muessen.
procedure TfrmPersonen.SetzeBeschriftungen;
var
  I: Integer;
begin
  Caption := SFormCaption;
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TJvNavPanelButtonTop then
      TJvNavPanelButtonTop(Components[I]).Caption :=
        NavCaption(TNavAktion(Components[I].Tag));
  hdrAdressen.Caption     := SKopfAdressen;
  hdrEmails.Caption       := SKopfEmails;
  hdrTelefon.Caption      := SKopfTelefon;
  hdrBeziehungen.Caption  := SKopfBeziehungen;
  hdrPersonTypen.Caption  := SKopfPersonTypen;
  hdrRollen.Caption       := SKopfRollen;
  hdrAdressTypen.Caption  := SKopfAdressTypen;
  hdrEmailTypen.Caption   := SKopfEmailTypen;
  hdrTelefonTypen.Caption := SKopfTelefonTypen;
  lblNr.Caption         := SLblNr;
  lblVorname.Caption    := SLblVorname;
  lblNachname.Caption   := SLblNachname;
  lblPersonTyp.Caption  := SLblPersonTyp;
  lblErstellt.Caption   := SLblErstellt;
  lblStrasse.Caption    := SLblStrasse;
  lblHausNr.Caption     := SLblHausNr;
  lblPlz.Caption        := SLblPlz;
  lblOrt.Caption        := SLblOrt;
  lblAdressTyp.Caption  := SLblAdressTyp;
  lblEmail.Caption      := SLblEmail;
  lblEmailTyp.Caption   := SLblEmailTyp;
  lblNummer.Caption     := SLblNummer;
  lblTelefonTyp.Caption := SLblTelefonTyp;
  lblRolle.Caption      := SLblRolle;
  lblZielPerson.Caption := SLblZielPerson;
  lblBestAdresse.Caption := SLblBestAdresse;
  lblLand.Caption       := SLblLand;
  lblBezirk.Caption     := SLblBezirk;
end;

// Seiten-Metadaten: welcher Tab haengt an welcher Datasource, und wo ist
// die aufgeloeste Stammtabelle (fuer Neu/Speichern ueber die Bruecke).
procedure TfrmPersonen.BaueSeiten;

  procedure S(AIndex: Integer; ASeite: TTabSheet;
    ANavDs, AStammDs: TDataSource);
  begin
    FSeiten[AIndex].Seite   := ASeite;
    FSeiten[AIndex].NavDs   := ANavDs;
    FSeiten[AIndex].StammDs := AStammDs;
  end;

begin
  SetLength(FSeiten, 9);
  S(0, tsAdressen,     dmPersonen.dstblPersonAdresse,       dmPersonen.dstblAdresse);
  S(1, tsEmails,       dmPersonen.dstblPersonEmail,         dmPersonen.dstblEmailadresse);
  S(2, tsTelefon,      dmPersonen.dstblPersonTelefonnummer, dmPersonen.dstblTelefonnummer);
  S(3, tsBeziehungen,  dmPersonen.dstblPersonBeziehung,     nil);
  S(4, tsPersonTypen,  dmPersonen.dstblPersonTyp,           nil);
  S(5, tsRollen,       dmPersonen.dstblRolleTyp,            nil);
  S(6, tsAdressTypen,  dmPersonen.dstblAdressentyp,         nil);
  S(7, tsEmailTypen,   dmPersonen.dstblEmailtyp,            nil);
  S(8, tsTelefonTypen, dmPersonen.dstblTelefonnummertyp,    nil);
end;

// Header-Klick wie jvnvpnlhdr1Click in frmMain: aktiver Header PaneStyle1,
// alle anderen PaneStyle2, Tag = Seitenindex.
procedure TfrmPersonen.KopfClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FKoepfe) do
    FKoepfe[I].StyleManager := PaneStyle2;
  (Sender as TJvNavPanelHeader).StyleManager := PaneStyle1;
  pctrModule.ActivePageIndex := (Sender as TJvNavPanelHeader).Tag;
end;

// Kontext eines Buttons bestimmen: liegt er auf einem Tabsheet, gelten die
// Datasources dieser Seite; liegt er im linken Stammbereich, gelten
// person_mandant (Navigation) und person (Bearbeitung).
function TfrmPersonen.KontextZuButton(AButton: TControl;
  out ANavDs, AStammDs: TDataSource): Boolean;
var
  LParent: TControl;
  I: Integer;
begin
  Result   := False;
  ANavDs   := nil;
  AStammDs := nil;
  LParent  := AButton;
  while LParent <> nil do
  begin
    if LParent is TTabSheet then
    begin
      for I := 0 to High(FSeiten) do
        if FSeiten[I].Seite = LParent then
        begin
          ANavDs   := FSeiten[I].NavDs;
          AStammDs := FSeiten[I].StammDs;
          Exit(True);
        end;
      Exit(False);
    end;
    if LParent = pnlStamm then
    begin
      ANavDs   := dmPersonen.dstblPersonMandant;
      AStammDs := dmPersonen.dstblPerson;
      Exit(True);
    end;
    LParent := LParent.Parent;
  end;
end;

// Gemeinsamer Handler aller Leisten-Buttons; die Aktion steckt im Tag.
procedure TfrmPersonen.BtnNavClick(Sender: TObject);
var
  LNavDs, LStammDs, LZielDs: TDataSource;
begin
  if not KontextZuButton(Sender as TControl, LNavDs, LStammDs) then
    Exit;
  if (LNavDs = nil) or (LNavDs.DataSet = nil) or not LNavDs.DataSet.Active then
    Exit;  // z.B. person_beziehung noch nicht angelegt

  case TNavAktion((Sender as TComponent).Tag) of
    naErster:  LNavDs.DataSet.First;
    naZurueck: LNavDs.DataSet.Prior;
    naWeiter:  LNavDs.DataSet.Next;
    naLetzter: LNavDs.DataSet.Last;
    naNeu:
      if LStammDs <> nil then
        dmPersonen.StammNeu(LStammDs, LNavDs)  // Stamm + Bruecke gleich mit im Insert
      else
        LNavDs.DataSet.Append;            // Typ-Seiten/Beziehungen: direkt
    naBearbeiten:
      begin
        if LStammDs <> nil then
          LZielDs := LStammDs
        else
          LZielDs := LNavDs;
        if (LZielDs.DataSet <> nil) and LZielDs.DataSet.Active
          and not LZielDs.DataSet.IsEmpty then
          LZielDs.DataSet.Edit;
      end;
    naSpeichern:
      begin
        if (LStammDs <> nil) and (LStammDs.DataSet <> nil) then
          dmPersonen.StammSpeichern(LStammDs);  // Post + Email-Resolve, AfterPost verknuepft
        if LNavDs.DataSet.State in dsEditModes then
          LNavDs.DataSet.Post;              // Bruecke posten, falls nicht schon geschehen
      end;
    naAbbrechen:
      begin
        if LStammDs <> nil then
          dmPersonen.StammAbbrechen(LStammDs);
        if LNavDs.DataSet.State in dsEditModes then
          LNavDs.DataSet.Cancel;
      end;
    naAktualisieren:
      if LNavDs.DataSet.State = dsBrowse then
        LNavDs.DataSet.Refresh;
  end;
end;

// Foto aus einer Bilddatei in das photo-Blob der aktuellen Person laden.
// Vcl.Imaging.jpeg/pngimage in uses sorgen dafuer, dass TDBImage JPG/PNG
// anzeigen kann. Gespeichert wird beim naechsten "Speichern" der Person.
procedure TfrmPersonen.btnPhotoLadenClick(Sender: TObject);
begin
  if (dmPersonen.tblPerson.State = dsInactive) or dmPersonen.tblPerson.IsEmpty then
    Exit;
  if not dlgPhoto.Execute then
    Exit;
  if not (dmPersonen.tblPerson.State in dsEditModes) then
    dmPersonen.tblPerson.Edit;
  TBlobField(dmPersonen.tblPerson.FieldByName('photo')).LoadFromFile(dlgPhoto.FileName);
end;

end.
