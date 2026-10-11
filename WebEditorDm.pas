unit WebEditorDm;

{
  Pflege der Website-Seiten (navbarweb/contentweb, liegt in TRTHeisenberg
  neben den ERP-Tabellen, siehe [[project_dynamicwebsite_heisenberg]]).

  AUFBAU (Walter, 06.08.2026: "ich will TBL und Filter", keine Queries):
    tblNavbar          - eine Zeile je Website-Seite, aus v_navbar_editor:
                         der Seitentitel steht dort schon als Spalte
                         'bezeichnung' (je Sprache eine Zeile, siehe
                         SpracheSetzen) - kein Lookup-Feld noetig
    tblNavbarTextAlle  - alle Seitentitel EINER Sprache, ungefiltert nach
                         Seite
    tblNavbarText      - Master-Detail zu tblNavbar (navbarweb_id) + Sprache
                         gefiltert -> zum Bearbeiten des Titels der
                         gewaehlten Seite
    tblContent         - Master-Detail zu tblNavbar (navbarweb_id) -> Karten
                         der gewaehlten Seite, aus v_content_editor (Titel
                         und Text als Spalten)
    tblContentTextAlle - wie tblNavbarTextAlle, fuer Karten
    tblContentText     - Master-Detail zu tblContent (contentweb_id) +
                         Sprache gefiltert -> zum Bearbeiten von Titel/Text
                         der gewaehlten Karte

  Die "Alle"-Tabellen sind bewusst NICHT master-detail-verkettet: sie sollen
  alle Zeilen sehen, nicht nur die der aktuell gewaehlten Seite/Karte.

  SPRACHE: FSpracheId (Default 1 = 'de') steuert den Filter auf beiden
  "Alle"-Tabellen und den beiden Bearbeiten-Tabellen einheitlich. Umschalten
  siehe SpracheWechseln.
}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  Data.DB, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmWebEditor = class(TdmModuleTemplate)
    tblNavbar: TFDMemTable;
    dsNavbar: TDataSource;
    tblNavbarTextAlle: TFDMemTable;
    tblNavbarText: TFDMemTable;
    dsNavbarText: TDataSource;
    tblContent: TFDMemTable;
    dsContent: TDataSource;
    tblContentTextAlle: TFDMemTable;
    tblContentText: TFDMemTable;
    dsContentText: TDataSource;
    tblDokument: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    FSpracheId: Integer;
    procedure TabellenEinrichten;
    // Setzt den Sprachfilter auf allen vier Texttabellen. An einer Stelle,
    // damit die vier nicht auseinanderlaufen koennen.
    procedure SpracheSetzen;
  public
    class function GetInstance: TObject;
    procedure OpenWebEditor;
    // Oeffnet alle Tabellen. Getrennt von TabellenEinrichten, damit ein
    // erneuter Aufruf (z.B. nach Verbindungswechsel) moeglich bleibt.
    procedure AlleOeffnen;
    // Sprache fuer Anzeige/Bearbeitung wechseln (1=de, 2=en, 3=fr, 4=it).
    procedure SpracheWechseln(ASpracheId: Integer);
    property SpracheId: Integer read FSpracheId;
  end;

var
  dmWebEditor: TdmWebEditor;

implementation

{$R *.dfm}

uses
  WebEditorFrm, System.SyncObjs, ZentraleDatenDm, uGridMemo;

var
  GSperreWebEditor: TCriticalSection;

class function TdmWebEditor.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmWebEditor) then
  begin
    GSperreWebEditor.Enter;
    try
      if not Assigned(dmWebEditor) then
        Application.CreateForm(TdmWebEditor, dmWebEditor);
    finally
      GSperreWebEditor.Leave;
    end;
  end;
  Result := dmWebEditor;
end;

procedure TdmWebEditor.DataModuleCreate(Sender: TObject);
begin
  FSpracheId := 1; // de
  TabellenEinrichten;
end;

procedure TdmWebEditor.TabellenEinrichten;
begin
  tblNavbar.IndexFieldNames := 'parent_id;sortierung';
  dsNavbar.DataSet := tblNavbar;

  // Bearbeiten des Titels der gewaehlten Seite.
  tblNavbarText.MasterSource := dsNavbar;
  tblNavbarText.MasterFields := 'navbarweb_id';
  tblNavbarText.IndexFieldNames := 'navbarweb_id';
  dsNavbarText.DataSet := tblNavbarText;

  // Karten der gewaehlten Seite.
  tblContent.MasterSource := dsNavbar;
  tblContent.MasterFields := 'navbarweb_id';
  tblContent.IndexFieldNames := 'navbarweb_id;sortierung';
  dsContent.DataSet := tblContent;

  // Bearbeiten von Titel/Text der gewaehlten Karte.
  tblContentText.MasterSource := dsContent;
  tblContentText.MasterFields := 'contentweb_id';
  tblContentText.IndexFieldNames := 'contentweb_id';
  dsContentText.DataSet := tblContentText;

  // Fuer den HTML-Reiter: das Dokument der gewaehlten Seite, sofern eines
  // verknuepft ist (darstellung='HTML'/'PDF'/'JPG'). Bei TEXT-Seiten bleibt
  // dokument_id NULL, tblDokument zeigt dann leer - gewollt, siehe Check-
  // Constraint navbarweb_dokument_check.
  tblDokument.MasterSource := dsNavbar;
  tblDokument.MasterFields := 'dokument_id';
  tblDokument.IndexFieldNames := 'dokument_id';
end;

procedure TdmWebEditor.AlleOeffnen;
begin
  // Seite und Karte kommen aus den Editor-Views: die Bezeichnung bzw. der
  // Titel steht dort schon als normale Spalte, je Sprache eine Zeile. Damit
  // braucht es kein Lookup-Feld - und ein Lookup-Feld liesse sich an einer
  // gefuellten MemTable ohnehin nicht mehr anlegen.
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblNavbarTextAlle, 'navbarweb_text'),
    Zuordnung(tblContentTextAlle, 'contentweb_text'),
    Zuordnung(tblNavbar, 'v_navbar_editor'),
    Zuordnung(tblNavbarText, 'navbarweb_text'),
    Zuordnung(tblContent, 'v_content_editor'),
    Zuordnung(tblContentText, 'contentweb_text'),
    Zuordnung(tblDokument, 'dokument')]);
  // v_content_editor.text ist Postgres 'text' - ohne das haette das Gitter
  // dort nur "(WIDEMEMO)" gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(tblContent);

  SpracheSetzen;
end;

// Der Sprachfilter, an einer Stelle. Die "Alle"-Tabellen sind bewusst nicht
// master-detail-verkettet (siehe Unit-Kommentar), tragen aber denselben
// Sprachfilter wie die beiden Bearbeiten-Tabellen.
procedure TdmWebEditor.SpracheSetzen;
var
  LFilter: string;
begin
  LFilter := 'sprache_id=' + FSpracheId.ToString;

  // Die Editor-Views fuehren jede Seite/Karte je Sprache einmal - der
  // Filter macht daraus genau eine Zeile je Seite bzw. Karte.
  tblNavbar.Filter := LFilter;
  tblNavbar.Filtered := True;
  tblContent.Filter := LFilter;
  tblContent.Filtered := True;

  tblNavbarTextAlle.Filter := LFilter;
  tblNavbarTextAlle.Filtered := True;
  tblNavbarText.Filter := LFilter;
  tblNavbarText.Filtered := True;
  tblContentTextAlle.Filter := LFilter;
  tblContentTextAlle.Filtered := True;
  tblContentText.Filter := LFilter;
  tblContentText.Filtered := True;
end;

procedure TdmWebEditor.SpracheWechseln(ASpracheId: Integer);
begin
  if ASpracheId = FSpracheId then
    Exit;
  FSpracheId := ASpracheId;

  SpracheSetzen;
end;

procedure TdmWebEditor.OpenWebEditor;
begin
  if not Assigned(frmWebEditor) then
    Application.CreateForm(TfrmWebEditor, frmWebEditor);
  if not tblNavbar.Active then
    AlleOeffnen;
  frmWebEditor.Show;
end;


initialization
  GSperreWebEditor := TCriticalSection.Create;

finalization
  GSperreWebEditor.Free;

end.
