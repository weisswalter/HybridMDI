unit WebEditorFrm;

{
  Website-Seiten pflegen (navbarweb/contentweb). Erbt von TfrmGuiTemplate:
  die linke Navigationsleiste (Erster/Zurueck/.../Neu laden) kommt fertig
  verdrahtet vom Vorfahren, siehe GetStammDataSource.

  ACHTUNG fuer weitere Nachfahren von TfrmGuiTemplate: dessen
  ActionRechtsExecute ruft GetDetailDataSource nicht auf (Zeile ist
  auskommentiert) - die rechte Navigationsleiste (ActionListRechts) ist
  daher zurzeit wirkungslos. Dieses Formular verlaesst sich deshalb NICHT
  darauf, sondern hat eigene Knoepfe fuer die Karten-Verwaltung.

  DREI REITER RECHTS:
    Karten    - contentweb-Zeilen der gewaehlten Seite (nur relevant bei
                darstellung=TEXT)
    Vorschau  - zeigt die echte, laufende Seite im Edge-Browser
    HTML      - fuer darstellung=HTML: Rohtext von dokument.html, ueber
                denselben contenteditable-Ansatz wie zuvor in diesem Modul
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.JSON, System.NetEncoding,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls,
  Vcl.Edge, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvComponentBase, RibbonPanel,
  uFrmGuiTemplate, uFrmModuleTemplate, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Mask, System.ImageList, Vcl.ImgList, JvImageList, System.Actions,
  Vcl.ActnList, RibbonButtonBar;

type
  TfrmWebEditor = class(TfrmGuiTemplate)
    cboSprache: TComboBox;
    dbgrdNavbar: TDBGrid;
    lblBezeichnung: TLabel;
    edtBezeichnung: TDBEdit;
    tsKarten: TTabSheet;
    dbgrdKarten: TDBGrid;
    pnlKartenEdit: TPanel;
    lblTitel: TLabel;
    edtTitel: TDBEdit;
    lblText: TLabel;
    memText: TDBMemo;
    lblGruppe: TLabel;
    edtGruppe: TDBEdit;
    lblZielSlug: TLabel;
    edtZielSlug: TDBEdit;
    chkKarteAktiv: TDBCheckBox;
    btnKarteNeu: TButton;
    btnKarteSpeichern: TButton;
    btnKarteAbbrechen: TButton;
    btnKarteLoeschen: TButton;
    tsVorschau: TTabSheet;
    BrowserVorschau: TEdgeBrowser;
    btnVorschauAktualisieren: TButton;
    tsHtml: TTabSheet;
    BrowserHtml: TEdgeBrowser;
    btnHtmlSpeichern: TButton;
    lblHtmlHinweis: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cboSpracheChange(Sender: TObject);
    procedure dbgrdNavbarCellClick(Column: TColumn);
    procedure rbnpnl1ButtonClick(Sender: TRibbonPanel; AButtonTag: Integer);
    procedure btnKarteNeuClick(Sender: TObject);
    procedure btnKarteSpeichernClick(Sender: TObject);
    procedure btnKarteAbbrechenClick(Sender: TObject);
    procedure btnKarteLoeschenClick(Sender: TObject);
    procedure btnVorschauAktualisierenClick(Sender: TObject);
    procedure btnHtmlSpeichernClick(Sender: TObject);
    procedure BrowserHtmlExecuteScript(Sender: TCustomEdgeBrowser;
      AResult: HRESULT; const AResultObjectAsJson: string);
  private
    // Basis-URL der laufenden Website fuer die Vorschau. Lokal per Default;
    // spaeter ggf. konfigurierbar machen, wenn gegen den Server geprueft
    // werden soll (siehe [[feedback-web-gegen-ausgelieferte-seite-pruefen]]:
    // eine echte Freigabe-Pruefung braucht die Server-URL, nicht diese).
    FVorschauBasis: string;
    procedure VorschauLaden;
    procedure HtmlLaden;
  protected
    function GetStammDataSource: TDataSource; override;
    function GetDetailDataSource(AHeaderIndex: Integer): TDataSource; override;
  public
    class function GetInstance: TObject;
  end;

var
  frmWebEditor: TfrmWebEditor;

implementation

{$R *.dfm}

uses
  WebEditorDm;

class function TfrmWebEditor.GetInstance: TObject;
begin
  Result := frmWebEditor;
end;

function TfrmWebEditor.GetStammDataSource: TDataSource;
begin
  Result := dmWebEditor.dsNavbar;
end;

function TfrmWebEditor.GetDetailDataSource(AHeaderIndex: Integer): TDataSource;
begin
  // Siehe Hinweis am Unit-Kopf: wird vom Vorfahren zurzeit nicht gerufen.
  // Trotzdem korrekt implementiert, falls das dort behoben wird.
  case AHeaderIndex of
    0: Result := dmWebEditor.dsContent;
  else
    Result := nil;
  end;
end;

procedure TfrmWebEditor.FormCreate(Sender: TObject);
begin
  FVorschauBasis := 'http://localhost:5099';

  cboSprache.Items.Clear;
  cboSprache.Items.Add('Deutsch');
  cboSprache.Items.Add('English');
  cboSprache.Items.Add('Fran'#231'ais');
  cboSprache.Items.Add('Italiano');
  cboSprache.ItemIndex := 0;

  dbgrdNavbar.DataSource := dmWebEditor.dsNavbar;
  edtBezeichnung.DataSource := dmWebEditor.dsNavbarText;
  edtBezeichnung.DataField := 'bezeichnung';

  dbgrdKarten.DataSource := dmWebEditor.dsContent;
  edtTitel.DataSource := dmWebEditor.dsContentText;
  edtTitel.DataField := 'titel';
  memText.DataSource := dmWebEditor.dsContentText;
  memText.DataField := 'text';
  edtGruppe.DataSource := dmWebEditor.dsContent;
  edtGruppe.DataField := 'gruppe';
  edtZielSlug.DataSource := dmWebEditor.dsContent;
  edtZielSlug.DataField := 'ziel_slug';
  chkKarteAktiv.DataSource := dmWebEditor.dsContent;
  chkKarteAktiv.DataField := 'aktiv';

  dmWebEditor.OpenWebEditor;
end;

procedure TfrmWebEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmWebEditor := nil;
end;

procedure TfrmWebEditor.cboSpracheChange(Sender: TObject);
begin
  // Reihenfolge der Combo = Reihenfolge in sprache.reihenfolge = sprache_id.
  dmWebEditor.SpracheWechseln(cboSprache.ItemIndex + 1);
end;

procedure TfrmWebEditor.dbgrdNavbarCellClick(Column: TColumn);
begin
  case rbnpnl1.ActivePageIndex of
    1: VorschauLaden;
    2: HtmlLaden;
  end;
end;

// Reagiert aufs Wechseln des Tabs selbst (nicht nur auf einen neuen Klick
// im Navbar-Grid) - Tab-Index entspricht der Reihenfolge in HeaderButtons:
// 0=Karten, 1=Vorschau, 2=HTML.
procedure TfrmWebEditor.rbnpnl1ButtonClick(Sender: TRibbonPanel; AButtonTag: Integer);
begin
  case AButtonTag of
    1: VorschauLaden;
    2: HtmlLaden;
  end;
end;

// ── Karten (Tab 1) ──────────────────────────────────────────────────────

procedure TfrmWebEditor.btnKarteNeuClick(Sender: TObject);
begin
  if dmWebEditor.tblNavbar.IsEmpty then
  begin
    ShowMessage('Bitte zuerst links eine Seite w'#228'hlen.');
    Exit;
  end;
  dmWebEditor.tblContent.Append;
  dmWebEditor.tblContent.FieldByName('sortierung').AsInteger := 100;
  dmWebEditor.tblContent.FieldByName('aktiv').AsBoolean := True;
  dmWebEditor.tblContent.Post;
  dmWebEditor.tblContentText.Append;
  dmWebEditor.tblContentText.FieldByName('sprache_id').AsInteger := dmWebEditor.SpracheId;
  dmWebEditor.tblContentText.FieldByName('titel').AsString := 'Neue Karte';
end;

procedure TfrmWebEditor.btnKarteSpeichernClick(Sender: TObject);
begin
  if dmWebEditor.tblContentText.State in dsEditModes then
    dmWebEditor.tblContentText.Post;
  if dmWebEditor.tblContent.State in dsEditModes then
    dmWebEditor.tblContent.Post;
  ShowMessage('Gespeichert.');
end;

procedure TfrmWebEditor.btnKarteAbbrechenClick(Sender: TObject);
begin
  if dmWebEditor.tblContentText.State in dsEditModes then
    dmWebEditor.tblContentText.Cancel;
  if dmWebEditor.tblContent.State in dsEditModes then
    dmWebEditor.tblContent.Cancel;
end;

procedure TfrmWebEditor.btnKarteLoeschenClick(Sender: TObject);
begin
  if dmWebEditor.tblContent.IsEmpty then
    Exit;
  if MessageDlg('Karte wirklich l'#246'schen?', mtConfirmation,
                [mbYes, mbNo], 0) = mrYes then
    dmWebEditor.tblContent.Delete;
end;

// ── Vorschau (Tab 2) ────────────────────────────────────────────────────

procedure TfrmWebEditor.VorschauLaden;
var
  LSlug: string;
begin
  if dmWebEditor.tblNavbar.IsEmpty then
    Exit;
  LSlug := dmWebEditor.tblNavbar.FieldByName('route_slug').AsString;
  BrowserVorschau.Navigate(FVorschauBasis + '/' + LSlug);
end;

procedure TfrmWebEditor.btnVorschauAktualisierenClick(Sender: TObject);
begin
  VorschauLaden;
end;

// ── HTML (Tab 3) ────────────────────────────────────────────────────────
// Nur sinnvoll bei darstellung='HTML': dann verweist navbarweb.dokument_id
// auf dokument.html. tblDokument ist master-detail an dsNavbar gehaengt
// (siehe WebEditorDm), zeigt also automatisch das richtige Dokument.

procedure TfrmWebEditor.HtmlLaden;
const
  CVorlage =
    '<!DOCTYPE html><html><head><meta charset="utf-8">' +
    '<style>' +
    ' body{font-family:Segoe UI,sans-serif;font-size:14px;margin:0;padding:0}' +
    ' #leiste{position:sticky;top:0;background:#f3f3f3;border-bottom:1px solid #ccc;padding:6px}' +
    ' #leiste button{margin-right:4px;padding:3px 8px}' +
    ' #inhalt{padding:12px;min-height:60vh;outline:none}' +
    '</style></head><body>' +
    '<div id="leiste">' +
    '<button onclick="B(''bold'')"><b>F</b></button>' +
    '<button onclick="B(''italic'')"><i>K</i></button>' +
    '<button onclick="B(''formatBlock'',''h2'')">H2</button>' +
    '<button onclick="B(''formatBlock'',''h3'')">H3</button>' +
    '<button onclick="B(''formatBlock'',''p'')">Absatz</button>' +
    '<button onclick="B(''insertUnorderedList'')">Liste</button>' +
    '<button onclick="B(''removeFormat'')">Format weg</button>' +
    '</div>' +
    '<div id="inhalt" contenteditable="true">%s</div>' +
    '<script>' +
    ' function B(c,v){document.execCommand(c,false,v||null);' +
    '   document.getElementById("inhalt").focus();}' +
    '</script></body></html>';
var
  LHtml: string;
begin
  if dmWebEditor.tblNavbar.IsEmpty or
     (dmWebEditor.tblNavbar.FieldByName('darstellung').AsString <> 'HTML') then
  begin
    lblHtmlHinweis.Caption := 'Die gew'#228'hlte Seite ist nicht vom Typ HTML.';
    BrowserHtml.NavigateToString('<body></body>');
    Exit;
  end;
  lblHtmlHinweis.Caption := '';
  LHtml := dmWebEditor.tblDokument.FieldByName('html').AsString;
  BrowserHtml.NavigateToString(Format(CVorlage, [LHtml]));
end;

procedure TfrmWebEditor.btnHtmlSpeichernClick(Sender: TObject);
begin
  BrowserHtml.ExecuteScript('document.getElementById("inhalt").innerHTML');
end;

procedure TfrmWebEditor.BrowserHtmlExecuteScript(Sender: TCustomEdgeBrowser;
  AResult: HRESULT; const AResultObjectAsJson: string);
var
  LWert: TJSONValue;
  LHtml: string;
begin
  if AResult <> S_OK then
  begin
    ShowMessage('Der Editor hat nicht geantwortet.');
    Exit;
  end;
  LWert := TJSONObject.ParseJSONValue(AResultObjectAsJson);
  try
    if not (LWert is TJSONString) then
      Exit;
    LHtml := TJSONString(LWert).Value;
  finally
    LWert.Free;
  end;

  if dmWebEditor.tblDokument.IsEmpty then
  begin
    ShowMessage('Kein Dokument verkn'#252'pft.');
    Exit;
  end;
  dmWebEditor.tblDokument.Edit;
  dmWebEditor.tblDokument.FieldByName('html').AsString := LHtml;
  dmWebEditor.tblDokument.Post;
  ShowMessage('Gespeichert.');
end;

end.
