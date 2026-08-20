unit ArtikelStammFrm;

// Artikel-Stammdatenverwaltung.
//
//  Links (pnlStamm): Buttonleiste (ActionListLinks) und die Stammfelder
//    ueber dmArtikelStamm.dstblArtikel.
//  Rechts (rbnpnl1): fuenf Detailseiten - Kategorien, Fotos, Bestand,
//    Stueckliste, Varianten. ACHTUNG bei TRibbonPanel: HeaderButtons[i]
//    wird der Reihe nach mit dem i-ten TabSheet gepaart; ein TabSheet ohne
//    Kopfschalter ist unerreichbar.
//
// Das Formular haelt keine Daten und kennt keine Datenbank. Gelesen wird
// aus den DataSources des Datenmoduls, geschrieben ausschliesslich ueber
// dessen Methoden (die wiederum nur Datenbankfunktionen rufen).
//
// Die drei Baeume teilen sich einen Satz Handler; welche Wurzelliste
// gemeint ist, sagt der Tag des Baumes.

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes, System.Actions,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.CheckLst, Vcl.Mask,
  Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, Vcl.ExtDlgs,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Data.DB,
  VirtualTrees, VirtualTrees.Types, VirtualTrees.BaseTree,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.AncestorVCL,
  VirtualTrees.EditLink,
  RibbonPanel, RibbonButtonBar, BaumKnotenData, ArtikelBestandBaumData,
  JvComponentBase, JvExControls, JvButton, JvNavigationPane,
  JvNavPanelButtonTop;

type
  // Reihenfolge = Tag der Actions in beiden Navigationsleisten.
  TNavAktion = (naErster, naZurueck, naWeiter, naLetzter,
    naNeu, naBearbeiten, naSpeichern, naAbbrechen, naAktualisieren);

  TfrmArtikelStamm = class(TForm)
    Splitter1: TSplitter;
    pnlStamm: TPanel;
    pnlStammButtons: TPanel;
    btnErsterStamm: TJvNavPanelButtonTop;
    btnZurueckStamm: TJvNavPanelButtonTop;
    btnWeiterStamm: TJvNavPanelButtonTop;
    btnLetzterStamm: TJvNavPanelButtonTop;
    btnNeuStamm: TJvNavPanelButtonTop;
    btnAendernStamm: TJvNavPanelButtonTop;
    btnSpeichernStamm: TJvNavPanelButtonTop;
    btnAbbrechenStamm: TJvNavPanelButtonTop;
    btnNeuLadenStamm: TJvNavPanelButtonTop;
    pnlStammFelder: TPanel;
    lblArtikelNr: TLabel;
    lblArtikelname: TLabel;
    lblSerienNr: TLabel;
    lblModulNr: TLabel;
    lblBeschreibung: TLabel;
    edtArtikelNr: TDBEdit;
    edtArtikelname: TDBEdit;
    edtSerienNr: TDBEdit;
    edtModulNr: TDBEdit;
    memBeschreibung: TDBMemo;
    rbnpnl1: TRibbonPanel;
    tsKategorien: TTabSheet;
    pnlKategorie: TPanel;
    lblKategorie: TLabel;
    clbKategorie: TCheckListBox;
    grdKategorie: TDBGrid;
    tsPhotos: TTabSheet;
    barFotos: TRibbonButtonBar;
    pnlFotos: TPanel;
    lblFotoBeschr: TLabel;
    lblZiehen: TLabel;
    dbimgFoto: TDBImage;
    btnFotoLaden: TButton;
    dbgrdFotos: TDBGrid;
    dbmmobeschreibung: TDBMemo;
    btnFotoLoeschen: TButton;
    tsBestandRP: TTabSheet;
    pnlBestand: TPanel;
    vstBestand: TVirtualStringTree;
    tsStuecklisteRP: TTabSheet;
    pnlStueckliste: TPanel;
    pnlStuecklisteAdd: TPanel;
    lblUnterArtikel: TLabel;
    lblStkMenge: TLabel;
    btnStkAdd: TJvNavPanelButtonTop;
    btnStkDel: TJvNavPanelButtonTop;
    cboUnterArtikel: TDBLookupComboBox;
    edtStkMenge: TEdit;
    vstStueckliste: TVirtualStringTree;
    tsVarianten: TTabSheet;
    barVarianten: TRibbonButtonBar;
    pnlAequivalenz: TPanel;
    lblAequivalenz: TLabel;
    lblGleich: TLabel;
    btnGleichsetzen: TJvNavPanelButtonTop;
    btnAequivalenzLoesen: TJvNavPanelButtonTop;
    cboAequivalenzA: TComboBox;
    cboAequivalenzB: TComboBox;
    pnlVarianten: TPanel;
    vstVarianten: TVirtualStringTree;
    PaneStyle1: TJvNavPaneStyleManager;
    PaneStyle2: TJvNavPaneStyleManager;
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
    ActionListVarianten: TActionList;
    actVarMerkmal: TAction;
    actVarUnterelement: TAction;
    actVarGleicheEbene: TAction;
    actVarLoeschen: TAction;
    actVarNeuLaden: TAction;
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
    dlgFoto: TOpenPictureDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ActionLinksExecute(Sender: TObject);
    procedure ActionRechtsExecute(Sender: TObject);
    procedure VariantenAktionExecute(Sender: TObject);
    procedure clbKategorieClickCheck(Sender: TObject);
    procedure btnFotoLadenClick(Sender: TObject);
    procedure btnFotoLoeschenClick(Sender: TObject);
    procedure btnStkAddClick(Sender: TObject);
    procedure btnStkDelClick(Sender: TObject);
    procedure btnGleichsetzenClick(Sender: TObject);
    procedure btnAequivalenzLoesenClick(Sender: TObject);
  private
    { Private-Deklarationen }
    // Waehrend KategorienAnzeigen die Haken setzt, darf OnClickCheck nicht
    // zurueckschlagen - sonst schreibt das Anzeigen in die Datenbank.
    FKategorieStumm: Boolean;
    // Die Wurzellisten der drei Baeume gehoeren dem Formular; die Knoten
    // darin halten nur Verweise darauf (Node.SetData).
    // Der Bestandbaum hat seine eigene Knotenklasse: sie traegt Kapazitaet,
    // Gesamtbestand und die "+ Neu..."-Platzhalter.
    FBestandWurzeln: TList<IBestandKnoten>;
    FStuecklisteWurzeln: TList<IBaumKnoten>;
    FVariantenWurzeln: TList<IBaumKnoten>;

    procedure ArtikelGewechselt(DataSet: TDataSet);
    procedure AuswahllistenFuellen;

    // Bilder aus dem Explorer auf das Fenster ziehen.
    procedure WMDropFiles(var AMsg: TWMDropFiles); message WM_DROPFILES;
    procedure DateienUebernehmen(const ADateien: TArray<string>);
    procedure FotoAnhaengen(const ADatei: string);

    // ── Baeume ────────────────────────────────────────────────────────
    procedure BaeumeEinrichten;
    procedure BaeumeAufbauen;
    function WurzelnVon(ASender: TBaseVirtualTree): TList<IBaumKnoten>;
    function GewaehlterKnoten(ABaum: TBaseVirtualTree): IBaumKnoten;
    procedure BaumInitNode(Sender: TBaseVirtualTree;
      ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure BaumInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var ChildCount: Cardinal);
    procedure BaumGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    // ── Bestandbaum (eigene Knotenklasse) ─────────────────────────────
    procedure BestandBaumAufbauen;
    procedure vstBestandInitNode(Sender: TBaseVirtualTree;
      ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstBestandInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstBestandGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstBestandEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vstBestandCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vstBestandDblClick(Sender: TObject);
    function FindeFachKnoten(const AKinder: TList<IBestandKnoten>;
      AFachId: Integer): IBestandKnoten;
    // ── Stuecklistenbaum: bearbeitbar wie der Bestandbaum ─────────────
    procedure vstStuecklisteEditing(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure vstStuecklisteCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vstStuecklisteDblClick(Sender: TObject);
    function ComboId(ACombo: TComboBox): Integer;
  public
    { Public-Deklarationen }
    // Oeffentlich, weil der Pruefstand sie aufruft.
    procedure KategorienAnzeigen;
    // Oeffentlich, weil der In-Place-Editor sie nach dem Speichern ruft.
    procedure GeheZuFach(AFachId: Integer);
    procedure BestandNeuAufbauen;
    // Oeffentlich, weil der Stuecklisten-Editor sie nach dem Speichern ruft.
    procedure BaeumeNeuAufbauen;
  end;

var
  frmArtikelStamm: TfrmArtikelStamm;

implementation

uses
  ArtikelStammDm, MandantDm;

{$R *.dfm}

// In-Place-Editor fuer vstBestand. Basisklasse TWinControlEditLink
// (VirtualTrees.EditLink) kuemmert sich generisch um BeginEdit/EndEdit/
// GetBounds/ProcessMessage fuer JEDEN TWinControl-Editor - Muster aus
// Virtual-TreeView\Demos\Advanced\Editors.pas.
//
// Bearbeitbar sind nur Faecher (Menge) und die "+ Neu..."-Platzhalter
// (Ort/Raum/Regal anlegen). Alles andere ist Anzeige.
type
  TBestandEditLink = class(TWinControlEditLink)
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure DoPrepareEdit(var Result: Boolean); override;
    procedure DoEndEdit(var Result: Boolean); override;
  end;

procedure TBestandEditLink.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;
        FTree.CancelEditNode;
      end;
    VK_RETURN:
      begin
        Key := 0;
        FTree.EndEditNode;
      end;
  end;
end;

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
            Edit := LCombo;
          end;
        bkRegal:
          begin
            // Kein Combo: ein bestehendes Regal auszuwaehlen braechte nichts
            // (es hat schon ein Fach), deshalb nur Texteingabe.
            LEdit := TEdit.Create(nil);
            LEdit.Visible := False;
            LEdit.Parent := FTree;
            LEdit.Text := '';
            LEdit.OnKeyDown := EditKeyDown;
            Edit := LEdit;
          end;
      else
        Result := False;
      end;
  else
    Result := False;
  end;
end;

// Uebernimmt die Eingabe. Bei den Platzhaltern wird nach der Auswahl per
// InputQuery weitergefragt, bis eine vollstaendige Kette bis zum Fach
// entsteht - sonst liefert v_lagerort dafuer nie eine Zeile (Joins bis
// regal_fach) und der neue Ort waere im Baum unsichtbar.
procedure TBestandEditLink.DoEndEdit(var Result: Boolean);
var
  LKnoten: IBestandKnoten;
  LNeueMenge: Double;
  LMandantId, LAdresseId, LRaumId: Integer;
  LCombo: TComboBox;
  LStrasse, LHausnr, LPlz, LOrt, LBezeichnung, LMeldung: string;
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
        // Die Kapazitaet ist eine Warnschwelle, keine Sperre.
        if LKnoten.HatKapazitaet and (LNeueMenge > LKnoten.Kapazitaet) then
          if MessageDlg(Format(
               'Die Kapazit'#228't dieses Fachs (%s) wird '#252'berschritten ' +
               '(neue Menge: %s).' + sLineBreak + 'Trotzdem speichern?',
               [FormatFloat('0.###', LKnoten.Kapazitaet),
                FormatFloat('0.###', LNeueMenge)]),
               mtWarning, [mbYes, mbNo], 0) <> mrYes then
            Exit;

        LMeldung := dmArtikelStamm.SetBestand(LKnoten.FachId, LNeueMenge);
        if LMeldung <> '' then
        begin
          ShowMessage(LMeldung);
          Exit;
        end;
        frmArtikelStamm.BestandNeuAufbauen;
        frmArtikelStamm.GeheZuFach(LKnoten.FachId);
      end;

    bkNeuEintrag:
      begin
        if MessageDlg(
             'Ort, Raum und Regal werden sofort gespeichert. Zum Regal ' +
             'entsteht' + sLineBreak +
             'automatisch ein "Fach 1".' + sLineBreak + sLineBreak +
             'Brechen Sie zwischendurch ab, bleibt das bereits Angelegte ' +
             'gespeichert --' + sLineBreak +
             'ohne Regal fehlt dann aber das Fach, und der Eintrag ' +
             'erscheint nicht' + sLineBreak +
             'im Baum. Aufr' + #228 + 'umen k' + #246 + 'nnen Sie ihn nur im ' +
             'Lagermodul.' + sLineBreak + sLineBreak +
             'Fortfahren?',
             mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
          Exit;

        case LKnoten.ZielArt of
          bkAdresse:
            begin
              LMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
              LCombo := TComboBox(Edit);
              if LCombo.ItemIndex >= 0 then
              begin
                LAdresseId :=
                  Integer(NativeInt(LCombo.Items.Objects[LCombo.ItemIndex]));
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
              if not InputQuery('Neuer Raum', 'Bezeichnung des Raums:',
                                LBezeichnung) then Exit;
              LRaumId := dmArtikelStamm.NeuerRaum(LAdresseId, LBezeichnung);

              LBezeichnung := '';
              if not InputQuery('Neues Regal', 'Bezeichnung des Regals:',
                                LBezeichnung) then Exit;
              dmArtikelStamm.NeuesRegal(LRaumId, LBezeichnung);
              frmArtikelStamm.BestandNeuAufbauen;
            end;

          bkRaum:
            begin
              LCombo := TComboBox(Edit);
              if LCombo.ItemIndex >= 0 then
                LRaumId :=
                  Integer(NativeInt(LCombo.Items.Objects[LCombo.ItemIndex]))
              else if Trim(LCombo.Text) <> '' then
                LRaumId := dmArtikelStamm.NeuerRaum(LKnoten.ElternId,
                                                    Trim(LCombo.Text))
              else
                Exit;

              LBezeichnung := '';
              if not InputQuery('Neues Regal', 'Bezeichnung des Regals:',
                                LBezeichnung) then Exit;
              dmArtikelStamm.NeuesRegal(LRaumId, LBezeichnung);
              frmArtikelStamm.BestandNeuAufbauen;
            end;

          bkRegal:
            begin
              LBezeichnung := Trim(TEdit(Edit).Text);
              if LBezeichnung = '' then
                Exit;
              dmArtikelStamm.NeuesRegal(LKnoten.ElternId, LBezeichnung);
              frmArtikelStamm.BestandNeuAufbauen;
            end;
        end;
      end;
  end;
end;

// ── Aufbau und Abbau ────────────────────────────────────────────────────────

// In-Place-Editor fuer den Stuecklistenbaum. Gleiche Basisklasse und
// dasselbe Muster wie TBestandEditLink - nur andere Werte:
//   Platzhalter "+ Bestandteil..." -> Auswahlliste aller Artikel
//   Menge eines Bestandteils       -> Zahlenfeld
type
  TStuecklisteEditLink = class(TWinControlEditLink)
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure DoPrepareEdit(var Result: Boolean); override;
    procedure DoEndEdit(var Result: Boolean); override;
  end;

procedure TStuecklisteEditLink.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;
        FTree.CancelEditNode;
      end;
    VK_RETURN:
      begin
        Key := 0;
        FTree.EndEditNode;
      end;
  end;
end;

procedure TStuecklisteEditLink.DoPrepareEdit(var Result: Boolean);
var
  LKnoten: IBaumKnoten;
  LCombo: TDBLookupComboBox;
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
    LCombo := TDBLookupComboBox.Create(nil);
    LCombo.Visible := False;
    LCombo.Parent := FTree;
    // Schrift ausdruecklich setzen: geerbt wird die des Baums, und ohne
    // feste Schrift bleibt die Zeilenhoehe der Klappliste 0 - die Liste
    // sieht dann leer aus, obwohl sie Zeilen hat.
    LCombo.ParentFont := False;
    LCombo.Font.Assign(FTree.Font);
    // Reihenfolge: erst die Feldnamen, dann die Quelle. Umgekehrt baut das
    // Steuerelement die Liste einmal ohne Anzeigefeld auf.
    LCombo.ListField := 'artikelname';
    LCombo.KeyField := 'artikel_id';
    LCombo.ListSource := dmArtikelStamm.dstblArtikelAuswahl;
    LCombo.DropDownRows := 12;
    LCombo.OnKeyDown := EditKeyDown;
    Edit := LCombo;
  end
  else
  begin
    LEdit := TEdit.Create(nil);
    LEdit.Visible := False;
    LEdit.Parent := FTree;
    LEdit.Text := LKnoten.Spalte[1];   // Menge
    LEdit.OnKeyDown := EditKeyDown;
    Edit := LEdit;
  end;
end;

procedure TStuecklisteEditLink.DoEndEdit(var Result: Boolean);
var
  LKnoten: IBaumKnoten;
  LCombo: TDBLookupComboBox;
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
    LCombo := TDBLookupComboBox(Edit);
    // KeyValue ist Null, solange nichts gewaehlt wurde.
    LUnterId := StrToIntDef(VarToStr(LCombo.KeyValue), 0);
    if LUnterId <= 0 then
      Exit;
    // ElternId des Platzhalters ist der Knoten, unter dem er haengt.
    LMeldung := dmArtikelStamm.StuecklisteHinzufuegen(LKnoten.ElternId,
                                                     LUnterId, 1);
  end
  else
  begin
    if not TryStrToFloat(TEdit(Edit).Text, LMenge) or (LMenge <= 0) then
    begin
      ShowMessage('Bitte eine Menge gr' + #246 + 'sser null angeben.');
      Exit;
    end;
    // Dieselbe Funktion aendert die Menge (ON CONFLICT DO UPDATE).
    LMeldung := dmArtikelStamm.StuecklisteHinzufuegen(LKnoten.ElternId,
                                                     LKnoten.Id, LMenge);
  end;

  if LMeldung <> '' then
    ShowMessage(LMeldung);
  frmArtikelStamm.BaeumeNeuAufbauen;
end;

procedure TfrmArtikelStamm.FormCreate(Sender: TObject);
begin
  // Bilder lassen sich aus dem Explorer direkt hierher ziehen.
  DragAcceptFiles(Handle, True);

  dmArtikelStamm.KategorienFuellen(clbKategorie.Items);
  AuswahllistenFuellen;
  BaeumeEinrichten;

  // Die Haken und die Baeume haengen am angezeigten Artikel, nicht an einer
  // DataSource - sie muessen bei jedem Wechsel nachgezogen werden.
  dmArtikelStamm.tblArtikel.AfterScroll := ArtikelGewechselt;
  KategorienAnzeigen;
  BaeumeAufbauen;
end;

procedure TfrmArtikelStamm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DragAcceptFiles(Handle, False);
  // Den Handler abhaengen: das Datenmodul ist ein Singleton und lebt
  // weiter, der Verweis zeigte sonst auf ein totes Formular.
  if Assigned(dmArtikelStamm) and Assigned(dmArtikelStamm.tblArtikel) then
    dmArtikelStamm.tblArtikel.AfterScroll := nil;

  // MDI-Kinder lassen sich nicht verstecken (caHide wirft, ShowWindow wird
  // vom MDI-Client wieder aufgehoben).
  Action := caFree;
  frmArtikelStamm := nil;
end;

procedure TfrmArtikelStamm.FormDestroy(Sender: TObject);
begin
  // Erst die Baeume leeren, dann die Wurzellisten freigeben - sonst zeigen
  // die Knoten auf freigegebenen Speicher.
  vstBestand.Clear;
  vstStueckliste.Clear;
  vstVarianten.Clear;
  FreeAndNil(FBestandWurzeln);
  FreeAndNil(FStuecklisteWurzeln);
  FreeAndNil(FVariantenWurzeln);
end;

procedure TfrmArtikelStamm.ArtikelGewechselt(DataSet: TDataSet);
begin
  KategorienAnzeigen;
  BaeumeAufbauen;
end;

procedure TfrmArtikelStamm.AuswahllistenFuellen;
begin
  // Unterartikel fuer die Stueckliste: die Kopie des Datenmoduls, ohne
  // eigene Abfrage.
  cboUnterArtikel.ListSource := dmArtikelStamm.dstblArtikelAuswahl;
  cboUnterArtikel.KeyField := 'artikel_id';
  cboUnterArtikel.ListField := 'artikelname';

  dmArtikelStamm.VariantenAuswahlFuellen(cboAequivalenzA.Items);
  dmArtikelStamm.VariantenAuswahlFuellen(cboAequivalenzB.Items);
end;

// ── Navigation links (Stammsatz) ────────────────────────────────────────────

procedure TfrmArtikelStamm.ActionLinksExecute(Sender: TObject);
var
  LDs: TDataSet;
  LMeldung: string;
  LId: Integer;
begin
  LDs := dmArtikelStamm.tblArtikel;
  if not LDs.Active then
    Exit;
  case TNavAktion((Sender as TComponent).Tag) of
    naErster:     LDs.First;
    naZurueck:    LDs.Prior;
    naWeiter:     LDs.Next;
    naLetzter:    LDs.Last;
    naNeu:        LDs.Append;
    naBearbeiten: if not LDs.IsEmpty then LDs.Edit;
    naSpeichern:
      // Ein Post auf die Kopie kaeme in der Datenbank nicht an - deshalb
      // ueber das Datenmodul (fn_artikel_speichern).
      if LDs.State in dsEditModes then
      begin
        LMeldung := dmArtikelStamm.ArtikelSpeichern(LId);
        if LMeldung <> '' then
          ShowMessage('Der Artikel konnte nicht gespeichert werden:' +
                      sLineBreak + LMeldung);
      end;
    naAbbrechen:  if LDs.State in dsEditModes then LDs.Cancel;
    naAktualisieren:
      begin
        dmArtikelStamm.DatenGeladen;
        dmArtikelStamm.KategorienFuellen(clbKategorie.Items);
        AuswahllistenFuellen;
        KategorienAnzeigen;
        BaeumeAufbauen;
      end;
  end;
end;

// ── Navigation rechts (Fotos) ───────────────────────────────────────────────

procedure TfrmArtikelStamm.ActionRechtsExecute(Sender: TObject);
var
  LDs: TDataSet;
  LAktion: TNavAktion;
  LMeldung: string;
begin
  LDs := dmArtikelStamm.tblArtikelFoto;
  if not LDs.Active then
    Exit;
  LAktion := TNavAktion((Sender as TComponent).Tag);

  // Die Leiste sitzt auf der Fotos-Seite. Bestand, Stueckliste und
  // Varianten haben ihre eigenen Knoepfe bzw. den Baum.
  case LAktion of
    naErster:     LDs.First;
    naZurueck:    LDs.Prior;
    naWeiter:     LDs.Next;
    naLetzter:    LDs.Last;
    naNeu:        ShowMessage('Ein neues Foto entsteht beim Laden einer ' +
                              'Datei - "Foto laden..." oder hierher ziehen.');
    naBearbeiten: if not LDs.IsEmpty then LDs.Edit;
    naSpeichern:
      // Nur Bezeichnung und Reihenfolge; das Bild bleibt, wie es ist.
      if not LDs.IsEmpty then
      begin
        if LDs.State in dsEditModes then
          LDs.UpdateRecord;
        LMeldung := dmArtikelStamm.FotoTextSpeichern(
          LDs.FieldByName('foto_id').AsInteger,
          LDs.FieldByName('beschreibung').AsString,
          LDs.FieldByName('reihenfolge').AsInteger);
        if LMeldung <> '' then
          ShowMessage(LMeldung);
      end;
    naAbbrechen:  if LDs.State in dsEditModes then LDs.Cancel;
    naAktualisieren: dmArtikelStamm.FotosNachladen;
  end;
end;

// ── Kategorien ──────────────────────────────────────────────────────────────

procedure TfrmArtikelStamm.KategorienAnzeigen;
var
  I, LId: Integer;
begin
  FKategorieStumm := True;
  try
    for I := 0 to clbKategorie.Items.Count - 1 do
    begin
      LId := Integer(NativeInt(clbKategorie.Items.Objects[I]));
      clbKategorie.Checked[I] := dmArtikelStamm.IstZugeordnet(LId);
    end;
  finally
    FKategorieStumm := False;
  end;
end;

procedure TfrmArtikelStamm.clbKategorieClickCheck(Sender: TObject);
var
  I, LId: Integer;
  LMeldung: string;
begin
  if FKategorieStumm then
    Exit;
  I := clbKategorie.ItemIndex;
  if I < 0 then
    Exit;

  LId := Integer(NativeInt(clbKategorie.Items.Objects[I]));
  LMeldung := dmArtikelStamm.KategorieSetzen(LId, clbKategorie.Checked[I]);
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    // Den Haken zurueckdrehen: in der Datenbank steht er nicht.
    FKategorieStumm := True;
    try
      clbKategorie.Checked[I] := not clbKategorie.Checked[I];
    finally
      FKategorieStumm := False;
    end;
  end;
end;

// ── Fotos ───────────────────────────────────────────────────────────────────

procedure TfrmArtikelStamm.FotoAnhaengen(const ADatei: string);
begin
  if dmArtikelStamm.FotoAnhaengen(ADatei,
       ChangeFileExt(ExtractFileName(ADatei), '')) = 0 then
    ShowMessage('Das Foto wurde nicht gespeichert.');
end;

procedure TfrmArtikelStamm.btnFotoLadenClick(Sender: TObject);
var
  LDateien: TArray<string>;
  I: Integer;
begin
  if dmArtikelStamm.tblArtikel.IsEmpty then
  begin
    ShowMessage('Bitte zuerst einen Artikel waehlen.');
    Exit;
  end;
  if not dlgFoto.Execute then
    Exit;

  SetLength(LDateien, dlgFoto.Files.Count);
  for I := 0 to dlgFoto.Files.Count - 1 do
    LDateien[I] := dlgFoto.Files[I];
  DateienUebernehmen(LDateien);
end;

procedure TfrmArtikelStamm.btnFotoLoeschenClick(Sender: TObject);
var
  LFotoId: Integer;
begin
  if not dmArtikelStamm.tblArtikelFoto.Active or
     dmArtikelStamm.tblArtikelFoto.IsEmpty then
    Exit;
  LFotoId := dmArtikelStamm.tblArtikelFoto.FieldByName('foto_id').AsInteger;
  if LFotoId <= 0 then
    Exit;
  if MessageDlg('Dieses Foto endgueltig entfernen?', mtConfirmation,
                [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    dmArtikelStamm.FotoLoeschen(LFotoId);
  except
    on E: Exception do
      ShowMessage('Das Foto konnte nicht entfernt werden:' + sLineBreak +
                  E.Message);
  end;
end;

// Windows meldet abgelegte Dateien mit WM_DROPFILES. Das Handle MUSS mit
// DragFinish freigegeben werden, sonst bleibt bei jedem Ablegen Speicher
// liegen.
procedure TfrmArtikelStamm.WMDropFiles(var AMsg: TWMDropFiles);
var
  LAnzahl, I, LLaenge: Integer;
  LName: string;
  LDateien: TArray<string>;
begin
  SetLength(LDateien, 0);
  try
    LAnzahl := DragQueryFile(AMsg.Drop, $FFFFFFFF, nil, 0);
    for I := 0 to LAnzahl - 1 do
    begin
      LLaenge := DragQueryFile(AMsg.Drop, I, nil, 0);
      if LLaenge <= 0 then
        Continue;
      SetLength(LName, LLaenge);
      // +1 fuer die abschliessende Null, die DragQueryFile mitschreibt.
      DragQueryFile(AMsg.Drop, I, PChar(LName), LLaenge + 1);
      LDateien := LDateien + [LName];
    end;
  finally
    DragFinish(AMsg.Drop);
  end;

  AMsg.Result := 0;
  if Length(LDateien) > 0 then
    DateienUebernehmen(LDateien);
end;

procedure TfrmArtikelStamm.DateienUebernehmen(const ADateien: TArray<string>);
var
  LUebersprungen: TArray<string>;
  LAnzahl: Integer;
begin
  if dmArtikelStamm.tblArtikel.IsEmpty then
  begin
    ShowMessage('Bitte zuerst einen Artikel waehlen.');
    Exit;
  end;

  // Abgelegt werden darf ueberall auf dem Fenster; sichtbar wird das
  // Ergebnis auf der Fotos-Seite.
  if rbnpnl1.ActivePageIndex <> 1 then
    rbnpnl1.ActivePageIndex := 1;

  Screen.Cursor := crHourGlass;
  try
    LAnzahl := dmArtikelStamm.FotosAusDateien(ADateien, LUebersprungen);
  finally
    Screen.Cursor := crDefault;
  end;

  if Length(LUebersprungen) > 0 then
    ShowMessage(Format('%d Bild(er) uebernommen.', [LAnzahl]) + sLineBreak +
      sLineBreak + 'Nicht lesbar als Bild, deshalb ausgelassen:' + sLineBreak +
      String.Join(sLineBreak, LUebersprungen))
  else if LAnzahl = 0 then
    ShowMessage('Es war kein lesbares Bild dabei.');
end;

// ── Stueckliste ─────────────────────────────────────────────────────────────

procedure TfrmArtikelStamm.btnStkAddClick(Sender: TObject);
var
  LMenge: Double;
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

  // Die Ringpruefung macht die Datenbank; hier kommt nur ihr Klartext an.
  LMeldung := dmArtikelStamm.StuecklisteHinzufuegen(
    dmArtikelStamm.tblArtikel.FieldByName('artikel_id').AsInteger,
    cboUnterArtikel.KeyValue, LMenge);
  if LMeldung <> '' then
    ShowMessage(LMeldung)
  else
    BaeumeAufbauen;
end;

procedure TfrmArtikelStamm.btnStkDelClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
  LMeldung: string;
begin
  LKnoten := GewaehlterKnoten(vstStueckliste);
  if LKnoten = nil then
  begin
    ShowMessage('Bitte im Baum den Unterartikel waehlen, der weg soll.');
    Exit;
  end;
  // ElternId ist der Knoten, unter dem der Bestandteil haengt - im Baum
  // kann das ein Unterartikel mehrere Ebenen tiefer sein.
  LMeldung := dmArtikelStamm.StuecklisteEntfernen(LKnoten.ElternId,
                                                  LKnoten.Id);
  if LMeldung <> '' then
    ShowMessage(LMeldung)
  else
    BaeumeAufbauen;
end;

// ── Varianten ───────────────────────────────────────────────────────────────

function TfrmArtikelStamm.ComboId(ACombo: TComboBox): Integer;
begin
  Result := 0;
  if ACombo.ItemIndex >= 0 then
    Result := Integer(NativeInt(ACombo.Items.Objects[ACombo.ItemIndex]));
end;

procedure TfrmArtikelStamm.VariantenAktionExecute(Sender: TObject);
var
  LKnoten: IBaumKnoten;
  LName, LMeldung: string;
  LId: Integer;
begin
  LKnoten := GewaehlterKnoten(vstVarianten);

  // Die Reihenfolge steht im Tag: 0 Merkmal, 1 Unterelement, 2 gleiche
  // Ebene, 3 loeschen, 4 neu laden.
  case (Sender as TComponent).Tag of
    0, 1, 2:
      begin
        LName := '';
        if not InputQuery('Merkmal', 'Bezeichnung:', LName) then
          Exit;
        if Trim(LName) = '' then
          Exit;
        case (Sender as TComponent).Tag of
          0: LMeldung := dmArtikelStamm.VarianteAnlegen(LName, 0, LId);
          1: if LKnoten = nil then
               LMeldung := 'Bitte zuerst das Merkmal waehlen, unter das der ' +
                           'Eintrag gehoert.'
             else
               LMeldung := dmArtikelStamm.VarianteAnlegen(LName, LKnoten.Id, LId);
          2: if LKnoten = nil then
               LMeldung := 'Bitte zuerst einen Eintrag waehlen.'
             else
               LMeldung := dmArtikelStamm.VarianteAnlegen(LName,
                             LKnoten.ElternId, LId);
        end;
      end;
    3:
      if LKnoten = nil then
        LMeldung := 'Bitte den Eintrag waehlen, der weg soll.'
      else
        LMeldung := dmArtikelStamm.VarianteLoeschen(LKnoten.Id);
    4:
      dmArtikelStamm.NachladenBaumdaten('variante');
  end;

  if LMeldung <> '' then
    ShowMessage(LMeldung);
  dmArtikelStamm.VariantenAuswahlFuellen(cboAequivalenzA.Items);
  dmArtikelStamm.VariantenAuswahlFuellen(cboAequivalenzB.Items);
  BaeumeAufbauen;
end;

procedure TfrmArtikelStamm.btnGleichsetzenClick(Sender: TObject);
var
  LMeldung: string;
begin
  if (ComboId(cboAequivalenzA) = 0) or (ComboId(cboAequivalenzB) = 0) then
  begin
    ShowMessage('Bitte zwei Merkmale waehlen.');
    Exit;
  end;
  LMeldung := dmArtikelStamm.VarianteGleichsetzen(ComboId(cboAequivalenzA),
                                                  ComboId(cboAequivalenzB));
  if LMeldung <> '' then
    ShowMessage(LMeldung)
  else
    BaeumeAufbauen;
end;

procedure TfrmArtikelStamm.btnAequivalenzLoesenClick(Sender: TObject);
var
  LMeldung: string;
begin
  if (ComboId(cboAequivalenzA) = 0) or (ComboId(cboAequivalenzB) = 0) then
  begin
    ShowMessage('Bitte zwei Merkmale waehlen.');
    Exit;
  end;
  LMeldung := dmArtikelStamm.AequivalenzAufheben(ComboId(cboAequivalenzA),
                                                 ComboId(cboAequivalenzB));
  if LMeldung <> '' then
    ShowMessage(LMeldung)
  else
    BaeumeAufbauen;
end;

// ── Baeume ──────────────────────────────────────────────────────────────────

procedure TfrmArtikelStamm.BaeumeEinrichten;

  procedure Einrichten(ABaum: TVirtualStringTree; ATag: Integer;
    const ASpalten: array of string; const ABreiten: array of Integer);
  var
    I: Integer;
  begin
    ABaum.Tag := ATag;
    ABaum.NodeDataSize := SizeOf(IInterface);
    ABaum.OnInitNode := BaumInitNode;
    ABaum.OnInitChildren := BaumInitChildren;
    ABaum.OnGetText := BaumGetText;
    ABaum.DefaultNodeHeight := 22;
    ABaum.Header.Height := 24;
    ABaum.Header.Options := ABaum.Header.Options + [hoVisible];
    ABaum.Header.Columns.Clear;
    for I := 0 to High(ASpalten) do
      with ABaum.Header.Columns.Add do
      begin
        Text := ASpalten[I];
        Width := ABreiten[I];
      end;
  end;

begin
  Einrichten(vstStueckliste, 2, ['Artikel', 'Menge', 'Einheit'], [360, 90, 90]);
  // Die Stueckliste laesst sich im Baum pflegen: Doppelklick oder F2 auf
  // "+ Bestandteil..." haengt an, auf einem Bestandteil aendert die Menge.
  vstStueckliste.OnEditing := vstStuecklisteEditing;
  vstStueckliste.OnCreateEditor := vstStuecklisteCreateEditor;
  vstStueckliste.OnDblClick := vstStuecklisteDblClick;
  vstStueckliste.TreeOptions.MiscOptions :=
    vstStueckliste.TreeOptions.MiscOptions + [TVTMiscOption.toEditable];
  Einrichten(vstVarianten, 3, ['Merkmal', 'Kurzzeichen'], [360, 140]);

  // Der Bestandbaum hat eigene Handler: andere Knotenklasse, und er ist
  // bearbeitbar.
  vstBestand.NodeDataSize := SizeOf(IInterface);
  vstBestand.OnInitNode := vstBestandInitNode;
  vstBestand.OnInitChildren := vstBestandInitChildren;
  vstBestand.OnGetText := vstBestandGetText;
  vstBestand.OnEditing := vstBestandEditing;
  vstBestand.OnCreateEditor := vstBestandCreateEditor;
  // VST startet per Doppelklick KEIN Editieren (der klappt nur auf/zu) -
  // muss explizit ausgeloest werden, sonst erscheint nie eine ComboBox.
  vstBestand.OnDblClick := vstBestandDblClick;
  // toEditable ist Pflicht, sonst feuern OnEditing/OnCreateEditor nie.
  vstBestand.TreeOptions.MiscOptions :=
    vstBestand.TreeOptions.MiscOptions + [TVTMiscOption.toEditable];
  vstBestand.DefaultNodeHeight := 22;
  vstBestand.Header.Height := 24;
  vstBestand.Header.Options := vstBestand.Header.Options + [hoVisible];
  vstBestand.Header.Columns.Clear;
  with vstBestand.Header.Columns.Add do
  begin
    Text := 'Ort';
    Width := 400;
  end;
  with vstBestand.Header.Columns.Add do
  begin
    Text := 'Gesamt';
    Width := 140;
  end;
end;

function TfrmArtikelStamm.WurzelnVon(
  ASender: TBaseVirtualTree): TList<IBaumKnoten>;
begin
  // Der Bestandbaum steht hier nicht: er hat eine eigene Knotenklasse und
  // eigene Handler (siehe vstBestandInitNode).
  case ASender.Tag of
    2: Result := FStuecklisteWurzeln;
    3: Result := FVariantenWurzeln;
  else
    Result := nil;
  end;
end;

procedure TfrmArtikelStamm.BaeumeAufbauen;

  procedure Fuellen(ABaum: TVirtualStringTree; var AWurzeln: TList<IBaumKnoten>;
    ANeu: TList<IBaumKnoten>);
  begin
    // Erst den Baum leeren: die Knoten zeigen auf die alte Liste.
    ABaum.Clear;
    FreeAndNil(AWurzeln);
    AWurzeln := ANeu;
    if Assigned(AWurzeln) then
      ABaum.RootNodeCount := AWurzeln.Count;
  end;

begin
  if dmArtikelStamm.tblArtikel.IsEmpty then
  begin
    vstBestand.Clear;
    vstStueckliste.Clear;
    vstVarianten.Clear;
    Exit;
  end;

  BestandBaumAufbauen;
  Fuellen(vstStueckliste, FStuecklisteWurzeln, dmArtikelStamm.StuecklisteBaum);
  Fuellen(vstVarianten, FVariantenWurzeln, dmArtikelStamm.VariantenBaum);
end;

function TfrmArtikelStamm.GewaehlterKnoten(
  ABaum: TBaseVirtualTree): IBaumKnoten;
begin
  Result := nil;
  if ABaum.FocusedNode <> nil then
    Result := ABaum.GetInterfaceFromNodeData<IBaumKnoten>(ABaum.FocusedNode);
end;

procedure TfrmArtikelStamm.BaumInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LEltern, LKnoten: IBaumKnoten;
  LWurzeln: TList<IBaumKnoten>;
begin
  if ParentNode = nil then
  begin
    LWurzeln := WurzelnVon(Sender);
    if not Assigned(LWurzeln) or (Integer(Node.Index) >= LWurzeln.Count) then
      Exit;
    LKnoten := LWurzeln[Node.Index];
  end
  else
  begin
    LEltern := Sender.GetInterfaceFromNodeData<IBaumKnoten>(ParentNode);
    if (LEltern = nil) or (Integer(Node.Index) >= LEltern.Kinder.Count) then
      Exit;
    LKnoten := LEltern.Kinder[Node.Index];
  end;

  Node.SetData(LKnoten);
  if LKnoten.Kinder.Count > 0 then
    Include(InitialStates, ivsHasChildren);
end;

procedure TfrmArtikelStamm.BaumInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  if LKnoten = nil then
    ChildCount := 0
  else
    ChildCount := LKnoten.Kinder.Count;
end;

procedure TfrmArtikelStamm.BaumGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  LKnoten: IBaumKnoten;
begin
  CellText := '';
  LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  if LKnoten = nil then
    Exit;
  if Column <= 0 then
  begin
    CellText := LKnoten.Spalte[0];
    // Ein Ring ist ein Datenfehler, kein Anzeigefehler - sichtbar machen.
    if LKnoten.IstZyklus then
      CellText := CellText + '   (RING!)';
  end
  else if Column < LKnoten.SpaltenAnzahl then
    CellText := LKnoten.Spalte[Column];
end;

// ── Stuecklistenbaum ────────────────────────────────────────────────────────

// Bearbeitbar sind der Platzhalter (Spalte 0) und die Menge (Spalte 1) -
// der Name eines Bestandteils gehoert dem Artikelstamm, nicht der Liste.
procedure TfrmArtikelStamm.vstStuecklisteEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := Sender.GetInterfaceFromNodeData<IBaumKnoten>(Node);
  Allowed := Assigned(LKnoten) and
             ((LKnoten.IstPlatzhalter and (Column <= 0)) or
              ((not LKnoten.IstPlatzhalter) and (Column = 1)));
end;

procedure TfrmArtikelStamm.vstStuecklisteCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TStuecklisteEditLink.Create;
end;

// VST startet per Doppelklick kein Editieren - explizit ausloesen, sonst
// erscheint nie eine Auswahlliste.
procedure TfrmArtikelStamm.vstStuecklisteDblClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
begin
  if not Assigned(vstStueckliste.FocusedNode) then
    Exit;
  LKnoten := vstStueckliste.GetInterfaceFromNodeData<IBaumKnoten>(
               vstStueckliste.FocusedNode);
  if LKnoten = nil then
    Exit;
  if LKnoten.IstPlatzhalter then
    vstStueckliste.EditNode(vstStueckliste.FocusedNode, 0)
  else
    vstStueckliste.EditNode(vstStueckliste.FocusedNode, 1);
end;

procedure TfrmArtikelStamm.BaeumeNeuAufbauen;
begin
  BaeumeAufbauen;
end;

// ── Bestandbaum ─────────────────────────────────────────────────────────────

procedure TfrmArtikelStamm.BestandBaumAufbauen;
begin
  vstBestand.Clear;
  FreeAndNil(FBestandWurzeln);
  if dmArtikelStamm.tblArtikel.IsEmpty then
    Exit;
  FBestandWurzeln := dmArtikelStamm.BestandBaum;
  if Assigned(FBestandWurzeln) then
    vstBestand.RootNodeCount := FBestandWurzeln.Count;
end;

procedure TfrmArtikelStamm.BestandNeuAufbauen;
begin
  BestandBaumAufbauen;
end;

procedure TfrmArtikelStamm.vstBestandInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LEltern, LKnoten: IBestandKnoten;
begin
  if ParentNode = nil then
  begin
    if not Assigned(FBestandWurzeln) or
       (Integer(Node.Index) >= FBestandWurzeln.Count) then
      Exit;
    LKnoten := FBestandWurzeln[Node.Index];
  end
  else
  begin
    LEltern := Sender.GetInterfaceFromNodeData<IBestandKnoten>(ParentNode);
    if (LEltern = nil) or (Integer(Node.Index) >= LEltern.Kinder.Count) then
      Exit;
    LKnoten := LEltern.Kinder[Node.Index];
  end;
  Node.SetData(LKnoten);
  if LKnoten.Kinder.Count > 0 then
    Include(InitialStates, ivsHasChildren);
end;

procedure TfrmArtikelStamm.vstBestandInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  LKnoten: IBestandKnoten;
begin
  if Node = nil then
  begin
    if Assigned(FBestandWurzeln) then
      ChildCount := FBestandWurzeln.Count
    else
      ChildCount := 0;
  end
  else
  begin
    LKnoten := Sender.GetInterfaceFromNodeData<IBestandKnoten>(Node);
    if LKnoten = nil then
      ChildCount := 0
    else
      ChildCount := LKnoten.Kinder.Count;
  end;
end;

procedure TfrmArtikelStamm.vstBestandGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  LKnoten: IBestandKnoten;
begin
  CellText := '';
  LKnoten := Sender.GetInterfaceFromNodeData<IBestandKnoten>(Node);
  if not Assigned(LKnoten) then
    Exit;
  case Column of
    0: CellText := LKnoten.AnzeigeText;
    1: // Gesamtbestand nur bei Standort und Raum - nicht bei Gebaeude,
       // Regal, Fach oder Platzhalter.
       if LKnoten.Art in [bkAdresse, bkRaum] then
         CellText := FormatFloat('0.###', LKnoten.GesamtBestand);
  end;
end;

// Nur Faecher und "+ Neu..."-Platzhalter sind bearbeitbar; Adresse,
// Gebaeude, Raum und Regal sind reine Anzeige.
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

procedure TfrmArtikelStamm.vstBestandDblClick(Sender: TObject);
begin
  if Assigned(vstBestand.FocusedNode) then
    vstBestand.EditNode(vstBestand.FocusedNode, 0);
end;

function TfrmArtikelStamm.FindeFachKnoten(const AKinder: TList<IBestandKnoten>;
  AFachId: Integer): IBestandKnoten;
var
  I: Integer;
begin
  Result := nil;
  if AKinder = nil then
    Exit;
  for I := 0 to AKinder.Count - 1 do
  begin
    if (AKinder[I].Art = bkFach) and (AKinder[I].FachId = AFachId) then
      Exit(AKinder[I]);
    Result := FindeFachKnoten(AKinder[I].Kinder, AFachId);
    if Result <> nil then
      Exit;
  end;
end;

// Nach dem Neuaufbau denselben Platz wieder anwaehlen: der Anwender soll
// dort stehen, wo er gerade gearbeitet hat.
procedure TfrmArtikelStamm.GeheZuFach(AFachId: Integer);
var
  LKnoten: PVirtualNode;
  LDaten: IBestandKnoten;
begin
  if not Assigned(FBestandWurzeln) then
    Exit;
  if FindeFachKnoten(FBestandWurzeln, AFachId) = nil then
    Exit;

  vstBestand.FullExpand;
  LKnoten := vstBestand.GetFirst;
  while LKnoten <> nil do
  begin
    LDaten := vstBestand.GetInterfaceFromNodeData<IBestandKnoten>(LKnoten);
    if Assigned(LDaten) and (LDaten.Art = bkFach) and
       (LDaten.FachId = AFachId) then
    begin
      vstBestand.FocusedNode := LKnoten;
      vstBestand.Selected[LKnoten] := True;
      vstBestand.ScrollIntoView(LKnoten, True);
      Exit;
    end;
    LKnoten := vstBestand.GetNext(LKnoten);
  end;
end;

end.
