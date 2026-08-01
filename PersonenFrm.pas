unit PersonenFrm;

// MDI-Child: Personenverwaltung.
//  Links: Personen-Stammdaten mit eigener Buttonleiste im Ribbon-Stil
//    (TJvNavPanelButtonTop + TJvGradient-Fueller, alles designtime im DFM).
//    Navigiert wird ueber die Bruecke person_mandant (dstblPersonMandant),
//    die Eingabefelder binden an die aufgeloeste Person (dstblPerson).
//  Rechts: TRibbonPanel (Tools\RibbonPanel.pas) mit vier Reitern —
//    Adressen, Emails, Telefon, Beziehungen. Jeder Reiter traegt seine eigene
//    Buttonleiste (dieselben neun Aktionen wie links, ActionTag = TNavAktion)
//    und ein ContentPanel mit Eingabefeldern (oben) und Grid (Rest).
//
//  Die Typ-Reiter (Personentyp/Rollentyp/Adresstyp/Emailtyp/Telefonnummertyp)
//  sind hier bewusst ENTFALLEN — sie werden zentral im Einstellungen-Fenster
//  gepflegt (EinstellungenFrm, Werkzeuge-Reiter im Hauptfenster), damit dieses
//  Formular nicht ueberfrachtet ist.
//
//  Beschriftungen kommen aus resourcestrings: die Buttons der Ribbon-Leisten
//  entstehen erst zur Laufzeit und gehoeren dem Ribbon-Panel (nicht diesem
//  Formular), werden deshalb in SetzeBeschriftungen rekursiv gesucht und
//  ueber ihren Tag beschriftet — genauso die Header-Buttons ueber ihren
//  Reiter-Index.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtDlgs, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Data.DB, Vcl.StdCtrls, Vcl.Mask,
  System.Actions, Vcl.ActnList,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  JvDBControls, JvDBLookup,
  uFrmModuleTemplate, JvComponentBase, JvExMask, JvToolEdit, JvMaskEdit;

type
  // Reihenfolge = Tag bzw. ActionTag der Buttons in jeder Leiste
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  // Je Ribbon-Reiter: welche Datasource navigiert wird und wo die
  // aufgeloeste Stammtabelle liegt (nil, wenn es keine Bruecke gibt).
  // Zugeordnet ueber den Reiter-Index, den die Action mitbringt
  // mitliefert — frueher lief das ueber die Parent-Kette zum TTabSheet,
  // das es zur Entwurfszeit nicht mehr gibt.
  TSeitenInfo = record
    NavDs: TDataSource;
    StammDs: TDataSource;
  end;

  TfrmPersonen = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    pnlStamm: TPanel;
    pnlStammButtons: TPanel;
    btnErsterStamm, btnZurueckStamm, btnWeiterStamm, btnLetzterStamm,
    btnNeuStamm, btnAendernStamm, btnSpeichernStamm, btnAbbrechenStamm,
    btnNeuLadenStamm: TJvNavPanelButtonTop;
    grdtStamm: TJvGradient;
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
    JvRibbonPanel1: TRibbonPanel;
    tsAdressen: TTabSheet;
    tsEmails: TTabSheet;
    tsTelefon: TTabSheet;
    tsBeziehungen: TTabSheet;
    barAdressen: TRibbonButtonBar;
    barEmails: TRibbonButtonBar;
    barTelefon: TRibbonButtonBar;
    barBeziehungen: TRibbonButtonBar;
    // Neun Aktionen fuer die Navigation, Tag = TNavAktion. Welcher Reiter
    // gemeint ist, kommt aus JvRibbonPanel1.ActivePageIndex -- genau wie
    // frueher, wo das alte Ribbon den Reiter-Index mitgeliefert hat.
    actlstPersonen: TActionList;
    actPersErster: TAction;
    actPersZurueck: TAction;
    actPersWeiter: TAction;
    actPersLetzter: TAction;
    actPersNeu: TAction;
    actPersBearbeiten: TAction;
    actPersSpeichern: TAction;
    actPersAbbrechen: TAction;
    actPersAktualisieren: TAction;
    // Reiter 0: Adressen
    pnlAdressen: TPanel;
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
    // Reiter 1: Emails
    pnlEmails: TPanel;
    pnlFldEmails: TPanel;
    lblEmail: TLabel;
    cboEmailAdr: TDBComboBox;
    lblEmailTyp: TLabel;
    cboEmailTyp: TJvDBLookupCombo;
    grdEmails: TDBGrid;
    // Reiter 2: Telefon
    pnlTelefon: TPanel;
    pnlFldTelefon: TPanel;
    lblNummer: TLabel;
    cboTelefonNr: TDBComboBox;
    lblTelefonTyp: TLabel;
    cboTelefonTyp: TJvDBLookupCombo;
    grdTelefon: TDBGrid;
    // Reiter 3: Beziehungen
    pnlBeziehungen: TPanel;
    pnlFldBeziehungen: TPanel;
    lblRolle: TLabel;
    cboRolle: TJvDBLookupCombo;
    lblZielPerson: TLabel;
    cboZielPerson: TJvDBLookupCombo;
    cbxMitarbeiter: TDBCheckBox;
    cbxKunde: TDBCheckBox;
    cbxKontakt: TDBCheckBox;
    cbxLehrer: TDBCheckBox;
    cbxKlient: TDBCheckBox;
    grdBeziehungen: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnNavClick(Sender: TObject);
    procedure PersNavExecute(Sender: TObject);
    procedure btnPhotoLadenClick(Sender: TObject);
  private
    FSeiten: array of TSeitenInfo;
    procedure BaueSeiten;
    procedure SetzeBeschriftungen;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    // Fuehrt eine Navigations-/Bearbeitungsaktion auf dem uebergebenen
    // Kontext aus. Frueher direkt in BtnNavClick — jetzt geteilt, weil es
    // zwei Aufrufer gibt: die Buttonleiste links (BtnNavClick) und die
    // Ribbon-Leisten rechts (RibbonButtonClick).
    procedure FuehreNavAktion(AAktion: TNavAktion;
      ANavDs, AStammDs: TDataSource);
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
  // Buttonleiste (links und auf jedem Reiter)
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

function KopfCaption(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := SKopfAdressen;
    1: Result := SKopfEmails;
    2: Result := SKopfTelefon;
    3: Result := SKopfBeziehungen;
  else
    Result := '';
  end;
end;

procedure TfrmPersonen.FormCreate(Sender: TObject);
begin
  BaueSeiten;
  SetzeBeschriftungen;
  // Dropdown der Email-/Telefon-Combos mit den vorhandenen (poolweiten) Werten
  // fuellen, damit man einen bestehenden (geteilten) Satz waehlen oder neu
  // tippen kann. Bei Adressen uebernimmt cboBestAdresse denselben Zweck.
  dmPersonen.FuelleEmailAdressen(cboEmailAdr.Items);
  dmPersonen.FuelleTelefonNummern(cboTelefonNr.Items);
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

// Alle Beschriftungen aus resourcestrings. Die Buttons der linken Leiste sind
// normale DFM-Komponenten (Components[] dieses Formulars); die Buttons und
// Header der Ribbon-Reiter erzeugt TRibbonPanel dagegen zur Laufzeit mit
// sich selbst als Owner — die findet man nur ueber die Control-Hierarchie,
// deshalb der rekursive Durchlauf.
procedure TfrmPersonen.SetzeBeschriftungen;

  procedure Durchlaufe(AParent: TWinControl);
  var
    I: Integer;
    C: TControl;
  begin
    for I := 0 to AParent.ControlCount - 1 do
    begin
      C := AParent.Controls[I];
      if C is TJvNavPanelButtonTop then
        TJvNavPanelButtonTop(C).Caption := NavCaption(TNavAktion(C.Tag))
      else if C is TJvNavPanelHeader then
        TJvNavPanelHeader(C).Caption := KopfCaption(C.Tag);
      if C is TWinControl then
        Durchlaufe(TWinControl(C));
    end;
  end;

var
  I: Integer;
begin
  Caption := SFormCaption;
  // linke Leiste: normale DFM-Buttons
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TJvNavPanelButtonTop then
      TJvNavPanelButtonTop(Components[I]).Caption :=
        NavCaption(TNavAktion(Components[I].Tag));
  // Rechte Leisten: die Schaltflaechen haengen jetzt an Actions und holen
  // ihre Beschriftung von dort -- es genuegt, die Action zu beschriften.
  // Der Tag der Action ist die TNavAktion.
  for I := 0 to actlstPersonen.ActionCount - 1 do
    if actlstPersonen.Actions[I] is TCustomAction then
      TCustomAction(actlstPersonen.Actions[I]).Caption :=
        NavCaption(TNavAktion(actlstPersonen.Actions[I].Tag));

  // Reiterbeschriftungen des Ribbons
  for I := 0 to JvRibbonPanel1.HeaderButtons.Count - 1 do
    JvRibbonPanel1.HeaderButtons[I].Caption := KopfCaption(I);

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

// Reiter-Metadaten: welcher Reiter haengt an welcher Datasource, und wo ist
// die aufgeloeste Stammtabelle (fuer Neu/Speichern ueber die Bruecke).
// Reihenfolge = Reihenfolge der HeaderButtons in JvRibbonPanel1.
procedure TfrmPersonen.BaueSeiten;

  procedure S(AIndex: Integer; ANavDs, AStammDs: TDataSource);
  begin
    FSeiten[AIndex].NavDs   := ANavDs;
    FSeiten[AIndex].StammDs := AStammDs;
  end;

begin
  SetLength(FSeiten, 4);
  S(0, dmPersonen.dstblPersonAdresse,       dmPersonen.dstblAdresse);
  S(1, dmPersonen.dstblPersonEmail,         dmPersonen.dstblEmailadresse);
  S(2, dmPersonen.dstblPersonTelefonnummer, dmPersonen.dstblTelefonnummer);
  S(3, dmPersonen.dstblPersonBeziehung,     nil);
end;

// Buttonleiste LINKS (pnlStamm): Kontext ist immer person_mandant
// (Navigation) und person (Bearbeitung).
procedure TfrmPersonen.BtnNavClick(Sender: TObject);
begin
  FuehreNavAktion(TNavAktion((Sender as TComponent).Tag),
    dmPersonen.dstblPersonMandant, dmPersonen.dstblPerson);
end;

// Buttonleisten RECHTS: eine Action je Navigationsschritt, der Reiter
// kommt aus ActivePageIndex.
procedure TfrmPersonen.PersNavExecute(Sender: TObject);
var
  LSeite: Integer;
begin
  // Frueher lieferte das alte Ribbon den Reiter-Index im Ereignis mit.
  // Die neue Buttonleiste kennt nur Actions, also wird der sichtbare
  // Reiter direkt abgefragt -- fachlich dasselbe: die Leiste, die man
  // anklickt, gehoert immer zum sichtbaren Reiter.
  LSeite := JvRibbonPanel1.ActivePageIndex;
  if (LSeite < 0) or (LSeite > High(FSeiten)) then
    Exit;
  FuehreNavAktion(TNavAktion((Sender as TComponent).Tag),
    FSeiten[LSeite].NavDs, FSeiten[LSeite].StammDs);
end;

// Gemeinsame Logik beider Leisten (unveraendert aus dem bisherigen
// BtnNavClick uebernommen).
procedure TfrmPersonen.FuehreNavAktion(AAktion: TNavAktion;
  ANavDs, AStammDs: TDataSource);
var
  LZielDs: TDataSource;
begin
  if (ANavDs = nil) or (ANavDs.DataSet = nil) or not ANavDs.DataSet.Active then
    Exit;  // z.B. person_beziehung noch nicht angelegt

  case AAktion of
    naErster:  ANavDs.DataSet.First;
    naZurueck: ANavDs.DataSet.Prior;
    naWeiter:  ANavDs.DataSet.Next;
    naLetzter: ANavDs.DataSet.Last;
    naNeu:
      if AStammDs <> nil then
        dmPersonen.StammNeu(AStammDs, ANavDs)  // Stamm + Bruecke gleich mit im Insert
      else
        ANavDs.DataSet.Append;            // Beziehungen: direkt
    naBearbeiten:
      begin
        if AStammDs <> nil then
          LZielDs := AStammDs
        else
          LZielDs := ANavDs;
        if (LZielDs.DataSet <> nil) and LZielDs.DataSet.Active
          and not LZielDs.DataSet.IsEmpty then
          LZielDs.DataSet.Edit;
      end;
    naSpeichern:
      begin
        // Bei Stamm+Bruecke (AStammDs <> nil) darf ein noch OFFENER
        // dsInsert-Satz der Bruecke NUR ueber die AfterPost-Kaskade
        // (StammVerknuepfen) gepostet werden -- der stammt aus einer noch
        // unvollstaendigen Stamm-Neuanlage (StammNeu haengt Stamm+Bruecke
        // gleichzeitig an) und haette noch keine Fremdschluessel-ID
        // (person_id/adresse_id), siehe feedback_personendm_stamm_bruecke_bug.
        // EIN BESTEHENDER Bruecken-Satz (dsEdit -- z.B. nur das
        // Hauptperson-Haekchen an einer schon verknuepften person_mandant-
        // Zeile geaendert, OHNE die Person selbst anzufassen) ist dagegen
        // schon korrekt verknuepft und muss trotzdem gepostet werden, sonst
        // geht genau diese Aenderung verloren.
        if (AStammDs <> nil) and (AStammDs.DataSet <> nil) then
        begin
          dmPersonen.StammSpeichern(AStammDs);  // Post + Email-Resolve, AfterPost verknuepft die Bruecke
          if ANavDs.DataSet.State = dsEdit then
            ANavDs.DataSet.Post;
        end
        else if ANavDs.DataSet.State in dsEditModes then
          ANavDs.DataSet.Post;  // reine Bruecken-Bearbeitung ohne Stamm-Neuanlage
      end;
    naAbbrechen:
      begin
        if AStammDs <> nil then
          dmPersonen.StammAbbrechen(AStammDs);
        if ANavDs.DataSet.State in dsEditModes then
          ANavDs.DataSet.Cancel;
      end;
    naAktualisieren:
      if ANavDs.DataSet.State = dsBrowse then
        ANavDs.DataSet.Refresh;
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
