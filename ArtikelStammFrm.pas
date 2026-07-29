unit ArtikelStammFrm;

// Artikel-Stammdatenverwaltung.
//  Links (pnlStamm): Artikel-Stammfelder (Nr., Name, Serien-Nr., Modul-Nr.,
//    Beschreibung) ueber ActionListLinks/dmArtikelStamm.dstblArtikel.
//    Artikel-/Serien-/Modulnummer sind varchar + TDBEdit -> nehmen auch
//    Buchstaben an.
//  Rechts (JvRibbonPanel1): zwei Detailseiten
//    - Header 0 "Fotos"   -> dstblArtikelFoto (mehrere Bilder je Artikel)
//    - Header 1 "Bestand" -> vstBestand (VirtualStringTree, read-only Baum
//      Adresse->Gebaeude/Eingang->Raum->Regal->Fach, aus fn_lagerort_bestand
//      via dmArtikelStamm.qryBestandBaum; siehe ArtikelBestandBaumData.pas).
//      Baum wird bei jedem Artikelwechsel automatisch neu aufgebaut
//      (dmArtikelStamm.qryBestandBaum.AfterOpen -> BestandBaumNeuAufbauen).
//    Beide Seiten sind als eigenes designtime-Panel (ContentPanel) im DFM
//    gestaltet; TJvRibbonPanel haengt sie zur Laufzeit in ihr Tabsheet.
//    Die gemeinsame Buttonleiste (Erster/Neu/Speichern/...) wirkt ueber
//    ActionRechtsExecute je nach aktiver Seite auf die passende DataSource
//    (fuer die Bestand-Seite aktuell nur noch fuer die Fotos-Seite sinnvoll,
//    da der Baum rein lesend ist -- Bearbeiten/Ablegen an anderem Ort ist
//    ein eigener, noch offener Ausbauschritt).
//
//  Phase 2 (27.07.2026, GEBAUT, ComboBox statt Menue): vstBestand ist ueber
//  einen IVTEditLink (TBestandEditLink, s.u.) editierbar. Fach-Blaetter
//  zeigen ein Zahlenfeld fuer die Bestandsmenge (warnt bei Ueberschreitung
//  von regal_fach.kapazitaet, blockt aber nicht). "+ Neu..."-Platzhalter
//  (bkNeuEintrag, siehe ArtikelBestandBaumData.pas) zeigen eine ComboBox:
//  - "+ Neue Adresse..." (Wurzel): Adressen der HAUPTPERSON des Mandanten
//    (NICHT die schon-als-Lager-markierten) -- das ist der Adresspool der
//    Firma. Ohne Hauptperson ist die Neuanlage gesperrt. Tippen legt eine
//    neue Adresse an (verknuepft mit der Hauptperson, als Lager markiert).
//  - "+ Neuer Raum..." (je Adresse): bestehende Raeume dieser Adresse zur
//    Auswahl, oder Tippen fuer einen neuen.
//  - "+ Neues Regal..." (je Raum): reine Texteingabe fuer ein neues Regal
//    (legt automatisch ein erstes Fach mit an -- ein Regal hat immer
//    mindestens ein Fach).
//  Nach jeder Neuanlage folgen ggf. weitere InputQuery-Abfragen (Raum-/
//  Regal-Bezeichnung), damit sofort ein vollstaendiger, sichtbarer Zweig
//  entsteht (fn_lagerort_bestand liefert sonst keine Zeile fuer eine
//  Adresse ohne Raum/Regal/Fach).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.Actions, Vcl.ActnList, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvRibbonPanel,
  VirtualTrees, VirtualTrees.Types, VirtualTrees.EditLink,
  ArtikelBestandBaumData, BaumKnotenData,
  uFrmModuleTemplate, JvComponentBase, Vcl.Mask, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL;

type
  // Reihenfolge = Tag der Actions in beiden Leisten
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  TfrmArtikelStamm = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
    pnlStamm: TPanel;
    pnlStammButtons: TPanel;
    btnErsterStamm, btnZurueckStamm, btnWeiterStamm, btnLetzterStamm,
    btnNeuStamm, btnAendernStamm, btnSpeichernStamm, btnAbbrechenStamm,
    btnNeuLadenStamm: TJvNavPanelButtonTop;
    pnlStammFelder: TPanel;
    lblArtikelNr: TLabel;
    edtArtikelNr: TDBEdit;
    lblArtikelname: TLabel;
    edtArtikelname: TDBEdit;
    lblSerienNr: TLabel;
    edtSerienNr: TDBEdit;
    lblModulNr: TLabel;
    edtModulNr: TDBEdit;
    lblBeschreibung: TLabel;
    memBeschreibung: TDBMemo;
    Splitter1: TSplitter;
    JvRibbonPanel1: TJvRibbonPanel;
    ActionListLinks: TActionList;
    actErsterL: TAction;
    actZurueckL: TAction;
    actWeiterL: TAction;
    actLetzterL: TAction;
    actNeuL: TAction;
    actAendernL: TAction;
    actSpeichernL: TAction;
    actAbbrechenL: TAction;
    actNeuLadenL: TAction;
    ActionListRechts: TActionList;
    actErsterR: TAction;
    actZurueckR: TAction;
    actWeiterR: TAction;
    actLetzterR: TAction;
    actNeuR: TAction;
    actAendernR: TAction;
    actSpeichernR: TAction;
    actAbbrechenR: TAction;
    actNeuLadenR: TAction;
    // Detailseite 0 "Fotos"
    pnlFotos: TPanel;
    pnlFotoKopf: TPanel;
    btnFotoLaden: TButton;
    lblFotoBeschr: TLabel;
    memFotoBeschr: TDBMemo;
    dbimgFoto: TDBImage;
    dbgrdFotos: TDBGrid;
    dlgFoto: TOpenPictureDialog;
    // Detailseite 1 "Bestand"
    // Detailseite 2 "Stueckliste" (artikel_artikel)

    pnlStueckliste: TPanel;

    vstStueckliste: TVirtualStringTree;

    pnlStuecklisteAdd: TPanel;

    lblUnterArtikel: TLabel;

    cboUnterArtikel: TDBLookupComboBox;

    lblStkMenge: TLabel;

    edtStkMenge: TEdit;

    btnStkAdd: TJvNavPanelButtonTop;
    btnStkDel: TJvNavPanelButtonTop;

    pnlBestand: TPanel;
    vstBestand: TVirtualStringTree;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionLinksExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure btnFotoLadenClick(Sender: TObject);
    procedure vstBestandInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var ChildCount: Cardinal);
    procedure vstBestandInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure vstBestandGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstBestandEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vstBestandCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vstBestandDblClick(Sender: TObject);

    procedure vstStuecklisteInitNode(Sender: TBaseVirtualTree;
      ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstStuecklisteInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstStuecklisteDblClick(Sender: TObject);
    procedure vstStuecklisteEditing(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure vstStuecklisteCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vstStuecklisteGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure btnStkAddClick(Sender: TObject);

    procedure btnStkDelClick(Sender: TObject);
  private
    // Wurzelknoten (Adressen) des Bestand-Baums, aufgebaut aus
    // dmArtikelStamm.qryBestandBaum -- haelt die IBestandKnoten-Kette am
    // Leben (Interfaces raeumen sich beim Freigeben der Liste selbst auf).
    FBestandWurzeln: TList<IBestandKnoten>;
    // Wurzel der Stueckliste. Wie FBestandWurzeln haelt die Liste die
    // Interface-Kette am Leben.
    FStuecklisteWurzeln: TList<IBaumKnoten>;
    procedure StuecklisteBaumNeuAufbauen(DataSet: TDataSet);
    function GewaehlterStkKnoten: IBaumKnoten;
    // liefert die DataSource der aktuell sichtbaren Ribbon-Detailseite
    function AktiveDetailDs: TDataSource;
    procedure BestandBaumNeuAufbauen(DataSet: TDataSet);
    function FindeIndexPfad(const AKinder: TList<IBestandKnoten>; AFachId: Integer;
      out APfad: TArray<Integer>): Boolean;
  public
    // Sucht rekursiv das Fach-Blatt mit passender fach_id im aktuellen Baum
    // bzw. den Geschwister-Index-Pfad dahin (Node.Index entspricht 1:1 dem
    // Kinder-Listenindex, siehe vstBestandInitNode) und springt im Baum
    // dorthin. Public, da TBestandEditLink (selbes Unit, implementation-
    // Abschnitt) das nach jeder Aenderung braucht.
    function FindeFachKnoten(const AKinder: TList<IBestandKnoten>; AFachId: Integer): IBestandKnoten;
    procedure GeheZuFach(AFachId: Integer);
  end;

var
  frmArtikelStamm: TfrmArtikelStamm;

implementation

{$R *.dfm}

uses
  ArtikelStammDm, MandantDm;

// ComboBox/Edit-basierter In-Place-Editor fuer vstBestand (Phase 2, siehe
// Unit-Kommentar oben). Basisklasse TWinControlEditLink (VirtualTrees.
// EditLink.pas) kuemmert sich generisch um BeginEdit/EndEdit/GetBounds/
// ProcessMessage fuer JEDEN TWinControl-Editor (TEdit UND TComboBox) --
// Muster 1:1 aus Virtual-TreeView\Demos\Advanced\Editors.pas uebernommen.
type
  TBestandEditLink = class(TWinControlEditLink)
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure SetBounds(R: TRect); override; stdcall;
    procedure DoPrepareEdit(var Result: Boolean); override;
    procedure DoEndEdit(var Result: Boolean); override;
  end;

procedure TBestandEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LCanAdvance: Boolean;
begin
  case Key of
    VK_RETURN:
      begin
        FTree.EndEditNode;
        Key := 0;
      end;
    VK_UP, VK_DOWN:
      begin
        LCanAdvance := Shift = [];
        if FEdit is TComboBox then
          LCanAdvance := LCanAdvance and not TComboBox(FEdit).DroppedDown;
        if LCanAdvance then
        begin
          PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
          Key := 0;
        end;
      end;
  end;
end;

procedure TBestandEditLink.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    FTree.CancelEditNode;
    Key := 0;
  end;
end;

// Grid-Erweiterungen sind in vstBestand nicht aktiv, deshalb Edit-Breite
// manuell auf die Spaltenbreite setzen (Muster aus TBasePropertyEditLink).
procedure TBestandEditLink.SetBounds(R: TRect);
var
  LDummy: Integer;
begin
  FTree.Header.Columns.GetColumnBounds(FColumn, LDummy, R.Right);
  FEdit.BoundsRect := R;
end;

// Waehlt je nach Knotenart den passenden Editor: Fach-Blaetter bekommen ein
// Zahlenfeld (Bestandsmenge); "+ Neu..."-Platzhalter je nach ZielArt eine
// ComboBox (Adresse/Raum) oder ein reines Textfeld (Regal, siehe Unit-
// Kommentar). Bestehende Adresse/Gebaeude/Raum/Regal-Knoten sind ueber
// vstBestandEditing gar nicht erst editierbar -- Result bleibt hier dann
// unbenutzt fuer diese Faelle.
procedure TBestandEditLink.DoPrepareEdit(var Result: Boolean);
var
  LKnoten: IBestandKnoten;
  LCombo: TComboBox;
  LEdit: TEdit;
  LMandantId: Integer;
begin
  inherited;
  LKnoten := FTree.GetInterfaceFromNodeData<IBestandKnoten>(Node);
  if LKnoten = nil then
  begin
    Result := False;
    Exit;
  end;

  case LKnoten.Art of
    bkFach:
      begin
        LEdit := TEdit.Create(nil);
        LEdit.Visible := False;
        LEdit.Parent := FTree;
        LEdit.Text := FormatFloat('0.###', LKnoten.Bestand);
        LEdit.OnKeyDown := EditKeyDown;
        LEdit.OnKeyUp := EditKeyUp;
        Edit := LEdit;
      end;
    bkNeuEintrag:
      case LKnoten.ZielArt of
        bkAdresse:
          begin
            LMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
            if not dmArtikelStamm.HauptpersonVorhanden(LMandantId) then
            begin
              ShowMessage('F'#252'r diesen Mandanten ist noch keine Hauptperson ' +
                'angelegt.' + sLineBreak +
                'Bitte zuerst im Personen-Modul eine Hauptperson festlegen.');
              Result := False;
              Exit;
            end;
            LCombo := TComboBox.Create(nil);
            LCombo.Visible := False;
            LCombo.Parent := FTree;
            LCombo.Style := csDropDown;
            dmArtikelStamm.LadeHauptpersonAdressen(LMandantId, LCombo.Items);
            LCombo.OnKeyDown := EditKeyDown;
            LCombo.OnKeyUp := EditKeyUp;
            Edit := LCombo;
          end;
        bkRaum:
          begin
            LCombo := TComboBox.Create(nil);
            LCombo.Visible := False;
            LCombo.Parent := FTree;
            LCombo.Style := csDropDown;
            dmArtikelStamm.LadeRaeumeFuerAdresse(LKnoten.ElternId, LCombo.Items);
            LCombo.OnKeyDown := EditKeyDown;
            LCombo.OnKeyUp := EditKeyUp;
            Edit := LCombo;
          end;
        bkRegal:
          begin
            // Kein Combo: ein bestehendes Regal auszuwaehlen braechte hier
            // nichts (hat schon mindestens ein Fach), deshalb nur Texteingabe
            // fuer ein neues Regal.
            LEdit := TEdit.Create(nil);
            LEdit.Visible := False;
            LEdit.Parent := FTree;
            LEdit.Text := '';
            LEdit.OnKeyDown := EditKeyDown;
            LEdit.OnKeyUp := EditKeyUp;
            Edit := LEdit;
          end;
      else
        Result := False;
      end;
  else
    Result := False;
  end;
end;

// Uebernimmt die Eingabe/Auswahl. Bei "+ Neu..."-Platzhaltern wird nach der
// Adress-/Raum-Auswahl per InputQuery weitergefragt, bis ein vollstaendiger
// Zweig (mind. bis Regal+Fach) entsteht -- sonst liefert fn_lagerort_bestand
// dafuer nie eine Zeile (INNER JOINs bis regal_fach) und der neue Ort waere
// im Baum unsichtbar.
procedure TBestandEditLink.DoEndEdit(var Result: Boolean);
var
  LKnoten: IBestandKnoten;
  LNeueMenge: Double;
  LMandantId, LAdresseId, LRaumId: Integer;
  LCombo: TComboBox;
  LStrasse, LHausnr, LPlz, LOrt, LBezeichnung: string;
  LArtikelId: Integer;
begin
  inherited;
  LKnoten := FTree.GetInterfaceFromNodeData<IBestandKnoten>(Node);
  if LKnoten = nil then
    Exit;

  case LKnoten.Art of
    bkFach:
      begin
        if not TryStrToFloat(TEdit(Edit).Text, LNeueMenge) then
        begin
          ShowMessage('Ung'#252'ltige Zahl.');
          Exit;
        end;
        if LKnoten.HatKapazitaet and (LNeueMenge > LKnoten.Kapazitaet) then
          if MessageDlg(Format(
               'Die Kapazit'#228't dieses Fachs (%s) wird '#252'berschritten ' +
               '(neue Menge: %s).' + sLineBreak + 'Trotzdem speichern?',
               [FormatFloat('0.###', LKnoten.Kapazitaet), FormatFloat('0.###', LNeueMenge)]),
               mtWarning, [mbYes, mbNo], 0) <> mrYes then
            Exit;
        dmArtikelStamm.SetBestand(LKnoten.FachId, LNeueMenge);
        frmArtikelStamm.GeheZuFach(LKnoten.FachId);
      end;

    bkNeuEintrag:
      begin
        LArtikelId := dmArtikelStamm.tblArtikel.FieldByName('artikel_id').AsInteger;
        case LKnoten.ZielArt of
          bkAdresse:
            begin
              LMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
              LCombo := TComboBox(Edit);
              if LCombo.ItemIndex >= 0 then
              begin
                LAdresseId := Integer(NativeInt(LCombo.Items.Objects[LCombo.ItemIndex]));
                dmArtikelStamm.EnsureAlsLagerMarkiert(LMandantId, LAdresseId);
              end
              else if Trim(LCombo.Text) <> '' then
              begin
                LStrasse := Trim(LCombo.Text);
                LHausnr := '';
                LPlz := '';
                LOrt := '';
                if not InputQuery('Neue Adresse', 'Hausnummer:', LHausnr) then Exit;
                if not InputQuery('Neue Adresse', 'PLZ:', LPlz) then Exit;
                if not InputQuery('Neue Adresse', 'Ort:', LOrt) then Exit;
                LAdresseId := dmArtikelStamm.NeueAdresseFuerHauptperson(
                  LMandantId, LStrasse, LHausnr, LPlz, LOrt);
              end
              else
                Exit;

              LBezeichnung := '';
              if not InputQuery('Neuer Raum', 'Bezeichnung des Raums:', LBezeichnung) then Exit;
              LRaumId := dmArtikelStamm.NeuerRaum(LAdresseId, LBezeichnung);

              LBezeichnung := '';
              if not InputQuery('Neues Regal', 'Bezeichnung des Regals:', LBezeichnung) then Exit;
              dmArtikelStamm.NeuesRegal(LRaumId, LBezeichnung);

              dmArtikelStamm.LadeBestandBaum(LArtikelId);
            end;

          bkRaum:
            begin
              LCombo := TComboBox(Edit);
              if LCombo.ItemIndex >= 0 then
                LRaumId := Integer(NativeInt(LCombo.Items.Objects[LCombo.ItemIndex]))
              else if Trim(LCombo.Text) <> '' then
                LRaumId := dmArtikelStamm.NeuerRaum(LKnoten.ElternId, Trim(LCombo.Text))
              else
                Exit;

              LBezeichnung := '';
              if not InputQuery('Neues Regal', 'Bezeichnung des Regals:', LBezeichnung) then Exit;
              dmArtikelStamm.NeuesRegal(LRaumId, LBezeichnung);

              dmArtikelStamm.LadeBestandBaum(LArtikelId);
            end;

          bkRegal:
            begin
              LBezeichnung := Trim(TEdit(Edit).Text);
              if LBezeichnung = '' then
                Exit;
              dmArtikelStamm.NeuesRegal(LKnoten.ElternId, LBezeichnung);
              dmArtikelStamm.LadeBestandBaum(LArtikelId);
            end;
        end;
      end;
  end;
end;

// In-Place-Editor fuer den Stuecklisten-Baum. Gleiche Basisklasse und
// dasselbe Muster wie TBestandEditLink oben - nur andere Werte:
//   Platzhalter "+ Bestandteil..."  -> ComboBox mit allen Artikeln
//   Spalte Menge eines Bestandteils -> Zahlenfeld
type
  TStuecklisteEditLink = class(TWinControlEditLink)
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure SetBounds(R: TRect); override; stdcall;
    procedure DoPrepareEdit(var Result: Boolean); override;
    procedure DoEndEdit(var Result: Boolean); override;
  end;

procedure TStuecklisteEditLink.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  LCanAdvance: Boolean;
begin
  case Key of
    VK_RETURN:
      begin
        FTree.EndEditNode;
        Key := 0;
      end;
    VK_UP, VK_DOWN:
      begin
        LCanAdvance := Shift = [];
        if FEdit is TComboBox then
          LCanAdvance := LCanAdvance and not TComboBox(FEdit).DroppedDown;
        if LCanAdvance then
        begin
          PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
          Key := 0;
        end;
      end;
  end;
end;

procedure TStuecklisteEditLink.EditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    FTree.CancelEditNode;
    Key := 0;
  end;
end;

procedure TStuecklisteEditLink.SetBounds(R: TRect);
var
  LDummy: Integer;
begin
  FTree.Header.Columns.GetColumnBounds(FColumn, LDummy, R.Right);
  FEdit.BoundsRect := R;
end;

procedure TStuecklisteEditLink.DoPrepareEdit(var Result: Boolean);
var
  LKnoten: IBaumKnoten;
  LCombo: TComboBox;
  LEdit: TEdit;
begin
  inherited;
  LKnoten := FTree.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  if LKnoten = nil then
  begin
    Result := False;
    Exit;
  end;

  if LKnoten.IstPlatzhalter then
  begin
    // Alle Artikel des Mandanten zur Auswahl - die ID haengt am
    // Items.Objects, wie im Bestand-Baum.
    LCombo := TComboBox.Create(nil);
    LCombo.Visible := False;
    LCombo.Parent := FTree;
    LCombo.Style := csDropDownList;
    dmArtikelStamm.FuelleArtikelListe(LCombo.Items);
    LCombo.OnKeyDown := EditKeyDown;
    LCombo.OnKeyUp := EditKeyUp;
    Edit := LCombo;
  end
  else
  begin
    LEdit := TEdit.Create(nil);
    LEdit.Visible := False;
    LEdit.Parent := FTree;
    LEdit.Text := LKnoten.Spalte[2];   // Menge
    LEdit.OnKeyDown := EditKeyDown;
    LEdit.OnKeyUp := EditKeyUp;
    Edit := LEdit;
  end;
end;

procedure TStuecklisteEditLink.DoEndEdit(var Result: Boolean);
var
  LKnoten: IBaumKnoten;
  LCombo: TComboBox;
  LUnterId: Integer;
  LMenge: Double;
  LMeldung: string;
begin
  inherited;
  LKnoten := FTree.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  if LKnoten = nil then
    Exit;

  if LKnoten.IstPlatzhalter then
  begin
    LCombo := TComboBox(Edit);
    if LCombo.ItemIndex < 0 then
      Exit;
    LUnterId := Integer(NativeInt(LCombo.Items.Objects[LCombo.ItemIndex]));
    // ElternId des Platzhalters ist der Knoten, unter dem er haengt
    LMeldung := dmArtikelStamm.StuecklisteHinzufuegen(LKnoten.ElternId,
      LUnterId, 1);
    if LMeldung <> EmptyStr then
      ShowMessage(LMeldung);
  end
  else
  begin
    if not TryStrToFloat(TEdit(Edit).Text, LMenge) or (LMenge <= 0) then
    begin
      ShowMessage('Bitte eine Menge gr' + #246 + 'sser null angeben.');
      Exit;
    end;
    dmArtikelStamm.StuecklisteHinzufuegen(LKnoten.ElternId, LKnoten.Id,
      LMenge);
  end;
end;

procedure TfrmArtikelStamm.FormCreate(Sender: TObject);
var
  LGesamtSpalte: TColumnIndex;
begin
  // Spalte/Events per Code statt im DFM (wie im VirtualTreeView-Demo
  // Demos\Interfaces\myevents.pas) -- vermeidet DFM-Property-Fallstricke.
  vstBestand.Header.Columns.Add;   // Spalte 0: Baum/Text
  // Spalte 1: Gesamtbestand, nur fuer Adresse/Raum befuellt (siehe
  // vstBestandGetText) -- Walters Vorgabe.
  LGesamtSpalte := vstBestand.Header.Columns.Add.Index;
  vstBestand.Header.Columns[LGesamtSpalte].Text := 'Gesamt';
  vstBestand.Header.Columns[LGesamtSpalte].Width := 110;
  vstBestand.Header.Columns[LGesamtSpalte].Alignment := taRightJustify;
  vstBestand.Header.AutoSizeIndex := 0;
  // hoAutoResize ist Pflicht, sonst bleibt die Spalte bei der Standardbreite
  // von 50px (VirtualTrees.Header.pas: FDefaultWidth := 50) und der Baumtext
  // wird auf ein einziges Zeichen abgeschnitten.
  vstBestand.Header.Options := vstBestand.Header.Options
    + [TVTHeaderOption.hoVisible, TVTHeaderOption.hoAutoResize];
  vstBestand.TreeOptions.PaintOptions := vstBestand.TreeOptions.PaintOptions
    - [TVTPaintOption.toShowRoot] + [TVTPaintOption.toShowTreeLines, TVTPaintOption.toShowButtons];
  // toEditable ist Pflicht, sonst feuern OnEditing/OnCreateEditor nie.
  vstBestand.TreeOptions.MiscOptions := vstBestand.TreeOptions.MiscOptions
    + [TVTMiscOption.toEditable];
  // Groessere Schrift, damit man den Baum ohne Adleraugen lesen kann --
  // Zeilenhoehe/Header wachsen entsprechend mit.
  vstBestand.Font.Size := 12;
  vstBestand.DefaultNodeHeight := 24;
  vstBestand.Header.Height := 24;
  vstBestand.OnInitChildren := vstBestandInitChildren;
  vstBestand.OnInitNode := vstBestandInitNode;
  vstBestand.OnGetText := vstBestandGetText;
  vstBestand.OnEditing := vstBestandEditing;
  vstBestand.OnCreateEditor := vstBestandCreateEditor;
  vstBestand.OnDblClick := vstBestandDblClick;

  // Stueckliste-Baum - gleiche Einrichtung wie vstBestand darueber
  vstStueckliste.Header.Columns.Clear;
  vstStueckliste.Header.Columns.Add.Text := 'Artikel';
  vstStueckliste.Header.Columns[0].Width := 240;
  vstStueckliste.Header.Columns.Add.Text := 'Artikel-Nr';
  vstStueckliste.Header.Columns[1].Width := 90;
  vstStueckliste.Header.Columns.Add.Text := 'Menge';
  vstStueckliste.Header.Columns[2].Width := 70;
  vstStueckliste.Header.Columns[2].Alignment := taRightJustify;
  vstStueckliste.Header.Columns.Add.Text := 'Einheit';
  vstStueckliste.Header.Columns[3].Width := 70;
  vstStueckliste.Header.AutoSizeIndex := 0;
  vstStueckliste.Header.Options := vstStueckliste.Header.Options
    + [TVTHeaderOption.hoVisible, TVTHeaderOption.hoAutoResize];
  vstStueckliste.TreeOptions.PaintOptions :=
    vstStueckliste.TreeOptions.PaintOptions
    - [TVTPaintOption.toShowRoot]
    + [TVTPaintOption.toShowTreeLines, TVTPaintOption.toShowButtons];
  vstStueckliste.TreeOptions.SelectionOptions :=
    vstStueckliste.TreeOptions.SelectionOptions
    + [TVTSelectionOption.toFullRowSelect];
  vstStueckliste.Font.Size := 12;
  vstStueckliste.OnInitChildren := vstStuecklisteInitChildren;
  vstStueckliste.OnInitNode := vstStuecklisteInitNode;
  vstStueckliste.OnGetText := vstStuecklisteGetText;
  vstStueckliste.OnEditing := vstStuecklisteEditing;
  vstStueckliste.OnCreateEditor := vstStuecklisteCreateEditor;
  // Ohne das laesst sich die Bearbeitung im Baum gar nicht
  // ausloesen - genau wie beim Bestandsbaum daneben.
  vstStueckliste.OnDblClick := vstStuecklisteDblClick;
  vstStueckliste.DefaultNodeHeight := 24;
  vstStueckliste.Header.Height := 24;
  // toEditable ist Pflicht, sonst feuern OnEditing/OnCreateEditor nie.
  vstStueckliste.TreeOptions.MiscOptions :=
    vstStueckliste.TreeOptions.MiscOptions
    + [TVTMiscOption.toEditable];

  dmArtikelStamm.qryBestandBaum.AfterOpen := BestandBaumNeuAufbauen;
  dmArtikelStamm.qryStuecklisteBaum.AfterOpen := StuecklisteBaumNeuAufbauen;
end;

procedure TfrmArtikelStamm.FormDestroy(Sender: TObject);
begin
  dmArtikelStamm.qryBestandBaum.AfterOpen := nil;
  FBestandWurzeln.Free;
end;

// Baut den Bestand-Baum aus dem aktuellen qryBestandBaum-Ergebnis neu auf.
// Wird ueber dmArtikelStamm.qryBestandBaum.AfterOpen bei jedem Artikelwechsel
// automatisch aufgerufen (siehe TdmArtikelStamm.tblArtikelAfterScroll).
procedure TfrmArtikelStamm.BestandBaumNeuAufbauen(DataSet: TDataSet);
begin
  FBestandWurzeln.Free;
  FBestandWurzeln := BaueBestandBaum(DataSet);
  vstBestand.RootNodeCount := 0;
  vstBestand.RootNodeCount := FBestandWurzeln.Count;
end;

procedure TfrmArtikelStamm.vstBestandInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  LKnoten: IBestandKnoten;
begin
  if Node = nil then
  begin
    // Sicherheitsnetz: FBestandWurzeln ist nil, solange der Baum noch nie
    // aufgebaut wurde (z.B. falls VST vor dem ersten LadeBestandBaum-Aufruf
    // gemalt wird) -- dann einfach als leerer Baum behandeln statt AV.
    if Assigned(FBestandWurzeln) then
      ChildCount := FBestandWurzeln.Count
    else
      ChildCount := 0;
  end
  else
  begin
    LKnoten := Sender.GetInterfaceFromNodeData<IBestandKnoten>(Node);
    ChildCount := LKnoten.Kinder.Count;
  end;
end;

procedure TfrmArtikelStamm.vstBestandInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LParentKnoten, LKnoten: IBestandKnoten;
begin
  if ParentNode = nil then
  begin
    if not Assigned(FBestandWurzeln) then
      Exit;
    LKnoten := FBestandWurzeln[Node.Index];
  end
  else
  begin
    LParentKnoten := Sender.GetInterfaceFromNodeData<IBestandKnoten>(ParentNode);
    LKnoten := LParentKnoten.Kinder[Node.Index];
  end;
  Node.SetData(LKnoten);
  if LKnoten.Kinder.Count > 0 then
    Include(InitialStates, ivsHasChildren);
end;

procedure TfrmArtikelStamm.vstBestandGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LKnoten: IBestandKnoten;
begin
  LKnoten := Sender.GetInterfaceFromNodeData<IBestandKnoten>(Node);
  if not Assigned(LKnoten) then
    Exit;
  case Column of
    0: CellText := LKnoten.AnzeigeText;
    1: // Gesamtbestand -- Walters Vorgabe: NUR bei Adresse (Standort) und
       // Raum, nicht bei Gebaeude/Regal/Fach/"+ Neu...".
       if LKnoten.Art in [bkAdresse, bkRaum] then
         CellText := FormatFloat('0.###', LKnoten.GesamtBestand)
       else
         CellText := '';
  end;
end;

// Nur Fach-Blaetter und "+ Neu..."-Platzhalter sind editierbar -- bestehende
// Adresse/Gebaeude/Raum/Regal-Knoten sind reine Anzeige (siehe Unit-Kommentar).
procedure TfrmArtikelStamm.vstBestandEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  LKnoten: IBestandKnoten;
begin
  LKnoten := Sender.GetInterfaceFromNodeData<IBestandKnoten>(Node);
  Allowed := Assigned(LKnoten) and (LKnoten.Art in [bkFach, bkNeuEintrag]);
end;

procedure TfrmArtikelStamm.vstBestandCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TBestandEditLink.Create;
end;

// VST startet per Doppelklick standardmaessig KEIN Editieren (Doppelklick
// klappt nur auf/zu, siehe HandleMouseDblClick in VirtualTrees.BaseTree.pas)
// -- muss explizit ausgeloest werden, sonst erscheint nie eine ComboBox.
// F2 auf einem fokussierten Knoten funktioniert bereits ueber die VST-eigene
// Tastaturbehandlung, ist aber nicht selbsterklaerend -- Doppelklick zusaetzlich.
procedure TfrmArtikelStamm.vstBestandDblClick(Sender: TObject);
begin
  if Assigned(vstBestand.FocusedNode) then
    vstBestand.EditNode(vstBestand.FocusedNode, 0);
end;

// Sucht rekursiv das Fach-Blatt mit passender fach_id im aktuellen Baum.
function TfrmArtikelStamm.FindeFachKnoten(const AKinder: TList<IBestandKnoten>;
  AFachId: Integer): IBestandKnoten;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to AKinder.Count - 1 do
  begin
    if (AKinder[I].Art = bkFach) and (AKinder[I].FachId = AFachId) then
      Exit(AKinder[I]);
    Result := FindeFachKnoten(AKinder[I].Kinder, AFachId);
    if Result <> nil then
      Exit;
  end;
end;

// Liefert den Geschwister-Index-Pfad (Wurzel bis Fach) zur fach_id -- wird
// gebraucht, um denselben Knoten nach einem Baum-Rebuild in vstBestand
// wiederzufinden (Node.Index entspricht 1:1 dem Kinder-Listenindex, siehe
// vstBestandInitNode).
function TfrmArtikelStamm.FindeIndexPfad(const AKinder: TList<IBestandKnoten>;
  AFachId: Integer; out APfad: TArray<Integer>): Boolean;
var
  I: Integer;
  LUnterPfad: TArray<Integer>;
begin
  for I := 0 to AKinder.Count - 1 do
  begin
    if (AKinder[I].Art = bkFach) and (AKinder[I].FachId = AFachId) then
    begin
      APfad := [I];
      Exit(True);
    end;
    if FindeIndexPfad(AKinder[I].Kinder, AFachId, LUnterPfad) then
    begin
      APfad := [I] + LUnterPfad;
      Exit(True);
    end;
  end;
  Result := False;
end;

// Klappt vstBestand entlang des Index-Pfads auf und selektiert das Fach.
procedure TfrmArtikelStamm.GeheZuFach(AFachId: Integer);
var
  LPfad: TArray<Integer>;
  LNode: PVirtualNode;
  LEbene, I: Integer;
begin
  if not FindeIndexPfad(FBestandWurzeln, AFachId, LPfad) then
    Exit;

  LNode := nil;
  for LEbene := 0 to High(LPfad) do
  begin
    if LNode = nil then
      LNode := vstBestand.GetFirst
    else
    begin
      vstBestand.Expanded[LNode] := True;
      LNode := vstBestand.GetFirstChild(LNode);
    end;
    for I := 1 to LPfad[LEbene] do
      if Assigned(LNode) then
        LNode := vstBestand.GetNextSibling(LNode);
    if LNode = nil then
      Exit;
  end;

  vstBestand.FocusedNode := LNode;
  vstBestand.Selected[LNode] := True;
  vstBestand.ScrollIntoView(LNode, True);
end;

// 0 = Fotos-Seite, 1 = Bestand-Seite (Reihenfolge wie JvRibbonPanel1.Headers)
function TfrmArtikelStamm.AktiveDetailDs: TDataSource;
begin
  case JvRibbonPanel1.ActivePageIndex of
    0: Result := dmArtikelStamm.dstblArtikelFoto;
    1: Result := dmArtikelStamm.dstblArtikelFach;

    2: Result := dmArtikelStamm.dstblStueckliste;
  else
    Result := nil;
  end;
end;

procedure TfrmArtikelStamm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmArtikelStamm := nil;
end;

// Gemeinsamer Handler der linken (Stammdaten-)Buttonleiste.
procedure TfrmArtikelStamm.ActionLinksExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmArtikelStamm.dstblArtikel;
  if (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case TNavAktion((Sender as TComponent).Tag) of
    naErster:        LDs.DataSet.First;
    naZurueck:       LDs.DataSet.Prior;
    naWeiter:        LDs.DataSet.Next;
    naLetzter:       LDs.DataSet.Last;
    naNeu:           LDs.DataSet.Append;
    naBearbeiten:    if not LDs.DataSet.IsEmpty then LDs.DataSet.Edit;
    naSpeichern:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Post;
    naAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    naAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

// Gemeinsamer Handler der rechten (Detail-)Buttonleiste — wirkt je nach
// aktiver Ribbon-Seite auf Fotos oder Bestand.
procedure TfrmArtikelStamm.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := AktiveDetailDs;
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  case TNavAktion((Sender as TComponent).Tag) of
    naErster:        LDs.DataSet.First;
    naZurueck:       LDs.DataSet.Prior;
    naWeiter:        LDs.DataSet.Next;
    naLetzter:       LDs.DataSet.Last;
    naNeu:           LDs.DataSet.Append;
    naBearbeiten:    if not LDs.DataSet.IsEmpty then LDs.DataSet.Edit;
    naSpeichern:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Post;
    naAbbrechen:     if LDs.DataSet.State in dsEditModes then LDs.DataSet.Cancel;
    naAktualisieren: if LDs.DataSet.State = dsBrowse then LDs.DataSet.Refresh;
  end;
end;

// Bild aus einer Datei in das foto-Blob des aktuellen artikel_foto-Satzes
// laden. Vcl.Imaging.jpeg/pngimage in uses sorgen dafuer, dass TDBImage
// JPG/PNG anzeigen kann. Gibt es noch keinen Foto-Satz, wird einer angelegt.
procedure TfrmArtikelStamm.btnFotoLadenClick(Sender: TObject);
begin
  if (dmArtikelStamm.tblArtikel.State = dsInactive) or dmArtikelStamm.tblArtikel.IsEmpty then
    Exit;  // ohne Artikel kein Foto
  if not dlgFoto.Execute then
    Exit;
  if dmArtikelStamm.tblArtikelFoto.IsEmpty then
    dmArtikelStamm.tblArtikelFoto.Append   // erster Foto-Satz -> Master fuellt artikel_id
  else if not (dmArtikelStamm.tblArtikelFoto.State in dsEditModes) then
    dmArtikelStamm.tblArtikelFoto.Edit;
  TBlobField(dmArtikelStamm.tblArtikelFoto.FieldByName('foto')).LoadFromFile(dlgFoto.FileName);
end;



// Stueckliste: Unterartikel hinzufuegen. Die Zykluspruefung macht die

// Datenbank (Trigger), TdmArtikelStamm uebersetzt deren Fehler.

procedure TfrmArtikelStamm.btnStkAddClick(Sender: TObject);

var

  LMenge: Double;

  LUnter, LOber: Integer;

  LKnoten: IBaumKnoten;

  LMeldung: string;

begin

  if dmArtikelStamm.tblArtikel.IsEmpty then

    Exit;

  if VarIsNull(cboUnterArtikel.KeyValue) then

  begin

    ShowMessage('Bitte einen Unterartikel waehlen.');

    Exit;

  end;

  if not TryStrToFloat(edtStkMenge.Text, LMenge) or (LMenge <= 0) then

  begin

    ShowMessage('Bitte eine Menge groesser null angeben.');

    Exit;

  end;

  LUnter := cboUnterArtikel.KeyValue;

  // Der neue Bestandteil haengt unter dem im BAUM markierten Knoten -
  // damit laesst sich auf jeder Ebene einbauen, nicht nur ganz oben.
  // Ohne Markierung gilt der Artikel aus der Liste links.
  LKnoten := GewaehlterStkKnoten;
  if Assigned(LKnoten) and LKnoten.IstPlatzhalter then
    // Platzhalter selbst hat keine Id - der Oberartikel ist sein Elternknoten
    LOber := LKnoten.ElternId
  else if Assigned(LKnoten) then
    LOber := LKnoten.Id
  else
    LOber := dmArtikelStamm.tblArtikel.FieldByName('artikel_id').AsInteger;

  LMeldung := dmArtikelStamm.StuecklisteHinzufuegen(LOber, LUnter, LMenge);

  if LMeldung <> EmptyStr then

    ShowMessage(LMeldung);

end;



// Haengt den markierten Knoten von SEINEM Oberartikel aus. Der Artikel
// selbst bleibt bestehen.
procedure TfrmArtikelStamm.btnStkDelClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := GewaehlterStkKnoten;
  if not Assigned(LKnoten) then
  begin
    ShowMessage('Bitte im Baum den Bestandteil markieren.');
    Exit;
  end;
  if LKnoten.IstPlatzhalter or (LKnoten.Ebene = 0) then
  begin
    ShowMessage('Bitte einen echten Bestandteil markieren.');
    Exit;
  end;
  dmArtikelStamm.StuecklisteEntfernen(LKnoten.ElternId, LKnoten.Id);
end;

// -- Stueckliste als Baum ---------------------------------------------
// Muster wie vstBestand. Anders als dort ruft die Abfrage immer dieselbe
// Tabelle (artikel) rekursiv auf - dafuer darf es in einem Ast keine
// Wiederholung geben. Dagegen schuetzt zweifach: der Trigger auf
// artikel_artikel beim Schreiben und der Pfad-Array in
// fn_artikel_stueckliste beim Lesen.
procedure TfrmArtikelStamm.StuecklisteBaumNeuAufbauen(DataSet: TDataSet);
begin
  vstStueckliste.BeginUpdate;
  try
    vstStueckliste.Clear;
    FreeAndNil(FStuecklisteWurzeln);
    FStuecklisteWurzeln := BaueBaumAusEbenen(
      dmArtikelStamm.qryStuecklisteBaum, 'artikel_id', 'ebene',
      ['artikelname', 'artikel_nr', 'menge', 'einheit'], 'ist_zyklus',
      '+ Bestandteil...');
    if Assigned(FStuecklisteWurzeln) then
      vstStueckliste.RootNodeCount := FStuecklisteWurzeln.Count;
  finally
    vstStueckliste.EndUpdate;
  end;
  vstStueckliste.FullExpand;
end;

function TfrmArtikelStamm.GewaehlterStkKnoten: IBaumKnoten;
begin
  Result := nil;
  if Assigned(vstStueckliste.FocusedNode) then
    Result := vstStueckliste.GetInterfaceFromNodeData<IBaumKnoten>(
      vstStueckliste.FocusedNode);
end;

procedure TfrmArtikelStamm.vstStuecklisteInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LEltern, LKnoten: IBaumKnoten;
begin
  if ParentNode = nil then
  begin
    if not Assigned(FStuecklisteWurzeln) then
      Exit;
    LKnoten := FStuecklisteWurzeln[Node.Index];
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

procedure TfrmArtikelStamm.vstStuecklisteInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  LKnoten: IBaumKnoten;
begin
  if Node = nil then
  begin
    if Assigned(FStuecklisteWurzeln) then
      ChildCount := FStuecklisteWurzeln.Count
    else
      ChildCount := 0;
  end
  else
  begin
    LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
    ChildCount := LKnoten.Kinder.Count;
  end;
end;

procedure TfrmArtikelStamm.vstStuecklisteGetText(Sender: TBaseVirtualTree;
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
    if LKnoten.IstZyklus then
      CellText := CellText + '  (ZYKLUS!)';
  end
  else
    CellText := LKnoten.Spalte[Column];
end;

// Editierbar sind nur die Platzhalter (dort waehlt man den Artikel) und
// die Mengenspalte echter Bestandteile. Der Wurzelknoten ist der Artikel
// selbst - er hat keine Menge und keinen Oberartikel.
procedure TfrmArtikelStamm.vstStuecklisteEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  Allowed := Assigned(LKnoten)
    and (LKnoten.IstPlatzhalter
         or ((Column = 2) and (LKnoten.Ebene > 0)));
end;

procedure TfrmArtikelStamm.vstStuecklisteCreateEditor(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  out EditLink: IVTEditLink);
begin
  EditLink := TStuecklisteEditLink.Create;
end;

// Doppelklick startet die Bearbeitung - auf einem Platzhalter oeffnet
// das die Artikelauswahl, auf einem Bestandteil das Mengenfeld.
procedure TfrmArtikelStamm.vstStuecklisteDblClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
begin
  if not Assigned(vstStueckliste.FocusedNode) then
    Exit;
  LKnoten := GewaehlterStkKnoten;
  if not Assigned(LKnoten) then
    Exit;
  if LKnoten.IstPlatzhalter then
    vstStueckliste.EditNode(vstStueckliste.FocusedNode, 0)
  else if LKnoten.Ebene > 0 then
    // Menge sitzt in Spalte 2
    vstStueckliste.EditNode(vstStueckliste.FocusedNode, 2);
end;

end.
