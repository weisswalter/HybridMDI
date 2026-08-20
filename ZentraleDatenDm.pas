unit ZentraleDatenDm;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Variants, Vcl.Forms,
  System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.DB,
  FireDAC.VCLUI.Wait;

type
  // Ein Modul sagt, welche seiner MemTables aus welcher Tabelle gefuellt wird.
  TTabellenZuordnung = record
    Mem: TFDMemTable;
    Tabelle: string;
    // False = echte Kopie (Standard): das Modul hat eigene Daten.
    // True  = nur Verweis (CloneCursor): teilt sich den Datenbestand mit dem
    //         zentralen Datenmodul, hat aber eigenen Satzzeiger, Filter und
    //         Sortierung. Kostet kein Kopieren - fuer die grossen Tabellen,
    //         bei denen die Kopie zu lange dauert.
    NurVerweis: Boolean;
  end;

  // Meldet, welche Tabelle gerade geholt wird - frmMain haengt daran seine
  // Fortschrittsanzeige, damit beim Start nicht minutenlang nichts passiert.
  TLadeFortschrittEvent = procedure(Sender: TObject; const ATabelle: string;
    AIndex, AGesamt: Integer) of object;

  TdmZentraleDaten = class(TDataModule)
    FDConnection1: TFDConnection;
    
    // ====== Spalte 1 ======
    FDTableabwesenheit: TFDTable;
    FDTableabwesenheitsart: TFDTable;
    FDTableadresse: TFDTable;
    FDTableadressentyp: TFDTable;
    FDTableadressinfo: TFDTable;
    FDTableanlage: TFDTable;
    FDTableanlage_abschreibung: TFDTable;
    FDTableanlage_dokument: TFDTable;
    FDTableanonymisierung_protokoll: TFDTable;
    FDTableanwesenheit_check: TFDTable;
    FDTableanwesenheit_tag: TFDTable;
    FDTableartikel: TFDTable;
    FDTableartikel_artikel: TFDTable;
    FDTableartikel_barcode: TFDTable;
    FDTableartikel_fach: TFDTable;
    FDTableartikel_foto: TFDTable;
    
    // ====== Spalte 2 ======
    FDTableartikel_preis: TFDTable;
    FDTableartikel_variante: TFDTable;
    FDTableartikel_variante_typ: TFDTable;
    FDTableartikel_variante_wert: TFDTable;
    FDTableartikel_zugang: TFDTable;
    FDTableaudit_log: TFDTable;
    FDTableausstattung: TFDTable;
    FDTablebeleg: TFDTable;
    FDTablebeleg_position: TFDTable;
    FDTablebenutzer: TFDTable;
    FDTablebenutzer_mandant: TFDTable;
    FDTablebetriebs_ausnahme: TFDTable;
    FDTablebetriebszeit: TFDTable;
    FDTablebezirk: TFDTable;
    FDTablebuchung: TFDTable;
    FDTablebuchung_dokument: TFDTable;
    
    // ====== Spalte 3 ======
    FDTablebuchung_zeile: TFDTable;
    FDTablebudget: TFDTable;
    FDTablecontentweb: TFDTable;
    FDTablecontentweb_text: TFDTable;
    FDTabledatenschutz_kenntnisnahme: TFDTable;
    FDTabledatenschutz_vorfall: TFDTable;
    FDTabledatenschutzinformation: TFDTable;
    FDTabledokument: TFDTable;
    FDTabledokument_typ: TFDTable;
    FDTabeleinheit: TFDTable;
    FDTabeleinwilligung: TFDTable;
    FDTabelemail_anhang: TFDTable;
    FDTabelemail_konto: TFDTable;
    FDTabelemail_nachricht: TFDTable;
    FDTabelemail_option: TFDTable;
    FDTabelemail_ordner: TFDTable;
    
    // ====== Spalte 4 ======
    FDTableemailadresse: TFDTable;
    FDTableemailtyp: TFDTable;
    FDTableerfassungsraster: TFDTable;
    FDTablefeedback: TFDTable;
    FDTablefeiertag: TFDTable;
    FDTableferien_anspruch: TFDTable;
    FDTablegutsprache_abruf: TFDTable;
    FDTableheisenberg_deployment_log: TFDTable;
    FDTableheisenberg_kunde: TFDTable;
    FDTableheisenberg_script: TFDTable;
    FDTableheisenberg_version: TFDTable;
    FDTablekalkulation: TFDTable;
    FDTablekalkulation_dokument: TFDTable;
    FDTablekalkulation_position: TFDTable;
    FDTablekalkulation_risiko: TFDTable;
    FDTableklient: TFDTable;
    
    // ====== Spalte 5 ======
    FDTableklient_semester: TFDTable;
    FDTablekompetenz_typ: TFDTable;
    FDTablekonto: TFDTable;
    FDTablekostenart: TFDTable;
    FDTablekostengutsprache: TFDTable;
    FDTablekostenstelle: TFDTable;
    FDTablekostenstelle_wert: TFDTable;
    FDTablekostenwert_dokument: TFDTable;
    FDTablekunde: TFDTable;
    FDTablekurs: TFDTable;
    FDTablekurs_anwesenheit: TFDTable;
    FDTablekurs_ausstattung: TFDTable;
    FDTablekurs_durchfuehrung: TFDTable;
    FDTablekurs_kompetenz: TFDTable;
    FDTablekurs_kurs: TFDTable;
    FDTablekurs_material: TFDTable;
    
    // ====== Spalte 6 ======
    FDTablekurs_teilnehmer: TFDTable;
    FDTablekurs_termin: TFDTable;
    FDTablelager: TFDTable;
    FDTableland: TFDTable;
    FDTableleadquelle_typ: TFDTable;
    FDTableleistung: TFDTable;
    FDTablelohn_abzugsart: TFDTable;
    FDTablelohn_dokument: TFDTable;
    FDTablelohn_periode: TFDTable;
    FDTablelohn_periode_position: TFDTable;
    FDTablelohn_zulage: TFDTable;
    FDTablemandant: TFDTable;
    FDTablemandant_dokument: TFDTable;
    FDTablemarktpreis: TFDTable;
    FDTablenavbarweb: TFDTable;
    FDTablenavbarweb_text: TFDTable;
    
    // ====== Spalte 7 ======
    FDTablenavigation: TFDTable;
    FDTableperson: TFDTable;
    FDTableperson_adresse: TFDTable;
    FDTableperson_arbeitszeit: TFDTable;
    FDTableperson_beziehung: TFDTable;
    FDTableperson_dokument: TFDTable;
    FDTableperson_email: TFDTable;
    FDTableperson_kompetenz: TFDTable;
    FDTableperson_lohn: TFDTable;
    FDTableperson_mandant: TFDTable;
    FDTableperson_telefonnummer: TFDTable;
    FDTableperson_typ: TFDTable;
    FDTableraster_abschnitt: TFDTable;
    FDTableraum: TFDTable;
    FDTableraum_ausstattung: TFDTable;
    FDTablezeit_stempel: TFDTable;
    FDTablezugang_status: TFDTable;
    FDTablezuschlagssatz: TFDTable;
    FDTableumlage: TFDTable;
    FDTablevariante: TFDTable;
    FDTablevariante_variante: TFDTable;
    FDTableverarbeitungstaetigkeit: TFDTable;
    FDTablevorgang: TFDTable;
    FDTablevorgang_beleg: TFDTable;
    FDTablevorgang_dokument: TFDTable;
    FDTablevorgang_email: TFDTable;
    FDTablewaehrungskurs: TFDTable;
    FDTableweb_bild: TFDTable;
    FDTableweb_farbe: TFDTable;
    FDTableweb_seite: TFDTable;
    FDTableweb_text: TFDTable;
    FDTablewebinhalt: TFDTable;
    FDTabletermin_ausstattung: TFDTable;


    // ====== In der Datenbank vorhanden, im Modul bisher nicht ======
    FDTableregal: TFDTable;
    FDTableregal_fach: TFDTable;
    FDTablerolle_typ: TFDTable;
    FDTablesemester: TFDTable;
    FDTablesprache: TFDTable;
    FDTablesteuer_code: TFDTable;
    FDTabletelefonnummer: TFDTable;
    FDTabletelefonnummertyp: TFDTable;

    // ====== Vorgang als Ticket (sql/vorgang_ticket.sql) ======
    FDTablekategorie: TFDTable;
    FDTableartikel_kategorie: TFDTable;

    // ====== Anmeldung (sql/anmeldung.sql) ======
    FDTablesystemeinstellung: TFDTable;
    FDTablev_person_konto: TFDTable;
    FDTablev_person_email_anmeldung: TFDTable;

    // ====== Einstellungen je Mandant (sql/mandant_einstellung.sql) ======
    FDTablemandant_einstellung: TFDTable;
    FDTablev_shop_einstellung: TFDTable;

    // ====== Vorgang als Ticket (sql/vorgang_ticket.sql) ======
    FDTablevorgang_typ: TFDTable;
    FDTablevorgang_zustand: TFDTable;
    FDTablevorgang_uebergang: TFDTable;
    FDTablevorgang_verlauf: TFDTable;
    FDTablevorgang_vorgang: TFDTable;
    FDTablenummernkreis: TFDTable;

    // ====== Views (Lookups mit JOIN/Anzeigespalte) ======
    // Bewusst NICHT im Konstruktor mitgeoeffnet: ModulFuellen oeffnet
    // sie beim ersten Zugriff selbst, das haelt den Start kurz.
    FDTablev_adresse_anzeige: TFDTable;
    FDTablev_adressinfo_anzeige: TFDTable;
    FDTablev_raum_anzeige: TFDTable;
    FDTablev_regal_anzeige: TFDTable;
    FDTablev_kurs_termin_liste: TFDTable;
    FDTablev_kurs_coach: TFDTable;
    FDTablev_person_auswahl: TFDTable;
    FDTablev_benutzer_uebersicht: TFDTable;
    FDTablev_navbar_editor: TFDTable;
    FDTablev_content_editor: TFDTable;
    FDTablev_anlage_jahr: TFDTable;
    FDTablev_konto_auswahl: TFDTable;
    FDTablev_raum_auswahl_einfach: TFDTable;
    FDTablev_beleg_person_auswahl: TFDTable;
    FDTablev_rechnungstyp_auswahl: TFDTable;
    FDTablev_lehrer_liste: TFDTable;
    FDTablev_person_kompetenz_status: TFDTable;
    FDTablev_lehrer_kurs_eignung: TFDTable;
    // Ortshierarchie Adresse->Raum->Regal->Fach, eine Zeile je Fach.
    // Ohne Artikel - der haengt ueber artikel_fach am Fach.
    FDTablev_lagerort: TFDTable;

  private
    FOnLadeFortschritt: TLadeFortschrittEvent;
    FLadeIndex: Integer;
    FLadeGesamt: Integer;
    // ---- Aenderungserkennung (siehe Abschnitt "Nur laden, wenn sich etwas
    //      geaendert hat" unten in der Implementierung) ----
    // Tabelle -> Zaehlerstand, so wie ihn die Datenbank zuletzt gemeldet hat.
    FZaehler: TDictionary<string, string>;
    // Tabelle -> Zaehlerstand zu dem Zeitpunkt, als sie hier geladen wurde.
    FStandTabelle: TDictionary<string, string>;
    // MemTable eines Moduls -> Zaehlerstand ihrer Quelle beim Fuellen.
    FStandMem: TDictionary<Pointer, string>;
    // MemTable -> aus welcher Tabelle sie gefuellt wurde. Gebraucht, damit
    // TabelleAuffrischen nach einem erfolgreichen Schreibvorgang weiss,
    // welche MemTables wieder freigegeben werden duerfen.
    FMemTabelle: TDictionary<Pointer, string>;
    // Sicht -> Basistabellen (kommagetrennt). Eine Sicht hat keinen eigenen
    // Zaehler, ihr Stand ist der ihrer Basistabellen.
    FSichten: TDictionary<string, string>;
    // Tabelle -> Primaerschluessel (mehrspaltig mit ; getrennt). FireDAC
    // kennt ihn nicht, weil die Tabellen mit DirectExecute laufen.
    FSchluessel: TDictionary<string, string>;
    FKatalogGelesen: Boolean;
    // Zaehlt hoch, wenn wir selbst geschrieben haben. Noetig, weil der
    // Zaehler der Datenbank der eigenen Schreiboperation nachlaeuft.
    FEigeneRunde: TDictionary<string, Integer>;
    // False, wenn die Datenbank keine Zaehler fuehrt (track_counts = off).
    // Dann wird wie frueher jedes Mal neu geladen.
    FZaehlerNutzbar: Boolean;
    FZaehlerGeprueft: Boolean;
    FZaehlerZeit: Cardinal;
    // Bleibt bestehen, damit nicht bei jedem Aufruf PQprepare und
    // DEALLOCATE dazukommen (siehe ZaehlerLesen).
    FZaehlerQry: TFDQuery;
    // pg_stat_force_next_flush gibt es erst ab Postgres 15.
    FFlushMoeglich: Boolean;
    FImmerNeuNr: Integer;

    // Holt eine Tabelle vollstaendig und meldet sie an die Anzeige.
    procedure TabelleLaden(ATabelle: TFDTable);
    function TabellenGesamt: Integer;

    procedure FaehigkeitenPruefen;
    procedure ZaehlerLesen;
    procedure KatalogLesen;
    function ImmerNeu: string;
    // Zaehlerstand, wie ihn die Datenbank meldet (Sicht: der ihrer Basis).
    function ZaehlerVon(const ATabelle: string): string;
    // Wie ZaehlerVon, zusaetzlich um die eigenen Schreibvorgaenge ergaenzt.
    function StandVon(const ATabelle: string): string;
    procedure QuelleNachziehen(AQuelle: TFDTable);
    procedure MemFuellen(AMem: TFDMemTable; AQuelle: TFDTable);
    procedure MemAuffrischen(AMem: TFDMemTable; AQuelle: TFDTable;
      const ATabelle: string);
    // True, wenn im Speicher etwas haengt, das noch nicht in der Datenbank
    // angekommen ist - so eine MemTable darf nicht ueberschrieben werden.
    function HatOffeneAenderung(AMem: TFDMemTable): Boolean;
    function FelderPassen(AMem: TFDMemTable; AQuelle: TFDTable): Boolean;
    function SchluesselFelder(AMem: TFDMemTable;
      const ATabelle: string): string;
    function SchluesselWerte(AMem: TFDMemTable; const AFelder: string): Variant;
  public
    class function GetInstance: TObject;

    // Holt alle Tabellen. Bewusst NICHT mehr im Konstruktor: frmMain soll
    // vorher stehen und den Fortschritt zeigen koennen.
    procedure AlleTabellenLaden;
    // Die schweren Tabellen (dokument mit den PDF-Blobs) kommen hierueber
    // nach, wenn das Hauptfenster schon offen ist.
    procedure NachladenSchwere;

    property OnLadeFortschritt: TLadeFortschrittEvent
      read FOnLadeFortschritt write FOnLadeFortschritt;
    // Die einzige Verbindung im Programm. Module lesen sie nur, um ihren
    // Zustand zu pruefen - Abfragen laufen ueber SpAufrufen/ModulFuellen.
    property Verbindung: TFDConnection read FDConnection1;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Fuellt die MemTables eines Moduls per Kopie aus den hier bereits
    // geladenen Tabellen - kein zweiter Weg zur Datenbank.
    // Hat sich an einer Tabelle seit dem letzten Fuellen nichts geaendert,
    // bleibt die MemTable des Moduls unangetastet und offen.
    procedure ModulFuellen(const AZuordnung: array of TTabellenZuordnung);

    // Hat sich die Tabelle seit dem letzten Laden geaendert? Fragt die
    // Datenbank; fuer eine Sicht zaehlen deren Basistabellen.
    function TabelleGeaendert(const ATabelle: string): Boolean;

    // Die Quelltabelle zu einem Tabellennamen. Sucht ueber die
    // TableName-Property, nicht ueber den Komponentennamen - die Namen im
    // DFM sind teils verschrieben (FDTabeleinheit statt FDTableeinheit),
    // TableName stimmt dagegen immer.
    // Oeffentlich, seit die Module ihre Kopien ueber
    // TdmModuleTemplate.Kopiere holen.
    function TabelleFinden(const ATabelle: string): TFDTable;

    // Der einzige Schreibweg. Die Module haben keine eigene Query mehr, sie
    // rufen nur noch eine Datenbankfunktion mit Parametern auf. Rueckgabe ist
    // das Skalarergebnis der Funktion (bei fn_*_speichern die vergebene ID).
    function SpAufrufen(const AFunktion: string;
      const AWerte: array of Variant): Variant;

    // Dasselbe, aber mit einem Bild/Blob an der Stelle ABlobIndex in AWerte.
    // Ein Blob geht nicht als Variant durch: AsBlob ist RawByteString und
    // wuerde die Bytes als Zeichen umdeuten. Der Wert an dieser Stelle in
    // AWerte wird deshalb ignoriert (Null uebergeben) und der Parameter
    // stattdessen als Strom gebunden - Muster wie in MailGraph.AnhaengeHolen.
    // Leeres ABlob heisst NULL; die Funktionen lassen das Bild dann stehen.
    function SpAufrufenBlob(const AFunktion: string;
      const AWerte: array of Variant; ABlobIndex: Integer;
      const ABlob: TBytes): Variant;

    // Fuer Funktionen mit RETURNS TABLE bzw. mehreren Rueckgabespalten
    // (z.B. fn_benutzer_anmelden). Der Aufrufer bekommt eine gefuellte
    // MemTable und gibt sie selbst wieder frei.
    function SpAbfragen(const AFunktion: string;
      const AWerte: array of Variant): TFDMemTable;

    // Nach dem Schreiben: die betroffene Tabelle hier neu holen, damit alle
    // Module denselben Stand sehen. Holt IMMER, ohne Zaehlerpruefung - der
    // Zaehler der Datenbank hinkt der eigenen Schreiboperation um bis zu
    // einer Sekunde hinterher, so lange darf der Anwender aber nicht auf
    // seine eigene Eingabe warten.
    procedure TabelleAuffrischen(const ATabelle: string);

    // Kopie einer Tabelle als frische MemTable - fuer Listen, die einmal
    // durchlaufen und dann weggeworfen werden (Auswahl-Comboboxen). Der
    // Aufrufer gibt sie frei.
    function KopieHolen(const ATabelle: string): TFDMemTable;
  end;

var
  dmZentraleDaten: TdmZentraleDaten;

// Kopie - der Normalfall.
function Zuordnung(AMem: TFDMemTable; const ATabelle: string): TTabellenZuordnung;
// Verweis statt Kopie, fuer grosse Tabellen. Achtung: aendert ein Modul die
// Daten im Speicher, sehen es alle anderen sofort mit. Da geschrieben nur
// ueber die Datenbankfunktionen wird, ist das unkritisch.
function Verweis(AMem: TFDMemTable; const ATabelle: string): TTabellenZuordnung;
// Liefert Null statt eines Wertes, wenn das Feld leer ist oder gar nicht
// existiert. Die Datenbankfunktionen erwarten NULL, nicht 0 oder ''.
function FeldOderNull(ADataSet: TDataSet; const AFeld: string): Variant;
// Rueckgabewert einer Datenbankfunktion als Zahl; NULL wird zu 0.
function AlsZahl(const AWert: Variant): Integer;

// Die Meldung einer Datenbankfunktion so, wie sie einem Anwender zumutbar
// ist. FireDAC stellt jeder Meldung seinen Weg voran und Postgres haengt
// Kontextzeilen an; aus
//   [FireDAC][Phys][PG][libpq] FEHLER:  Bitte eine Bezeichnung angeben.
//   CONTEXT: PL/pgSQL function fn_artikel_speichern(...) line 21
// wird
//   Bitte eine Bezeichnung angeben.
function FehlerKlartext(E: Exception): string;

implementation

{$R *.dfm}

uses
  EventBus, UInterfaces, uMessageHandler;   // fuer den Broadcast am Ende
                                            // von AlleTabellenLaden

var
  GInstanceSperre: TCriticalSection;

class function TdmZentraleDaten.GetInstance: TObject;
begin
  if not Assigned(dmZentraleDaten) then
  begin
    GInstanceSperre.Enter;
    try
      if not Assigned(dmZentraleDaten) then
        Application.CreateForm(TdmZentraleDaten, dmZentraleDaten);
    finally
      GInstanceSperre.Leave;
    end;
  end;
  Result := dmZentraleDaten;
end;

constructor TdmZentraleDaten.Create(AOwner: TComponent);
begin
  FZaehler := TDictionary<string, string>.Create;
  FStandTabelle := TDictionary<string, string>.Create;
  FStandMem := TDictionary<Pointer, string>.Create;
  FMemTabelle := TDictionary<Pointer, string>.Create;
  FSichten := TDictionary<string, string>.Create;
  FSchluessel := TDictionary<string, string>.Create;
  FEigeneRunde := TDictionary<string, Integer>.Create;
  inherited Create(AOwner);
  FDConnection1.Connected := True;
  // Die Tabellen holt AlleTabellenLaden - erst wenn frmMain steht und
  // den Fortschritt anzeigen kann.
end;

destructor TdmZentraleDaten.Destroy;
begin
  // Erst inherited, dann die eigenen Objekte - wie in TDataModuleForDelphi.
  // TDataModule.Destroy raeumt die Komponenten ab, und daran haengt in der
  // IDE der Object Inspector.
  inherited;
  FEigeneRunde.Free;
  FSchluessel.Free;
  FSichten.Free;
  FMemTabelle.Free;
  FStandMem.Free;
  FStandTabelle.Free;
  FZaehler.Free;
end;

function Zuordnung(AMem: TFDMemTable; const ATabelle: string): TTabellenZuordnung;
begin
  Result.Mem := AMem;
  Result.Tabelle := ATabelle;
  Result.NurVerweis := False;
end;

function Verweis(AMem: TFDMemTable; const ATabelle: string): TTabellenZuordnung;
begin
  Result.Mem := AMem;
  Result.Tabelle := ATabelle;
  Result.NurVerweis := True;
end;

function AlsZahl(const AWert: Variant): Integer;
begin
  if VarIsNull(AWert) or VarIsEmpty(AWert) then
    Result := 0
  else
    try
      Result := AWert;
    except
      Result := 0;
    end;
end;

function FehlerKlartext(E: Exception): string;
var
  LZeilen: TArray<string>;
  LPos: Integer;
begin
  Result := Trim(E.Message);

  // Nur die erste Zeile: darunter stehen CONTEXT/ZEILE/HINT.
  LZeilen := Result.Split([sLineBreak, #10], TStringSplitOptions.None);
  if Length(LZeilen) > 0 then
    Result := Trim(LZeilen[0]);

  // Fuehrende [FireDAC][Phys][PG][libpq]-Klammern wegnehmen.
  while (Result <> '') and (Result[1] = '[') do
  begin
    LPos := Pos(']', Result);
    if LPos = 0 then
      Break;
    Result := Trim(Copy(Result, LPos + 1, MaxInt));
  end;

  // Postgres schreibt je nach Spracheinstellung FEHLER: oder ERROR:.
  if Result.StartsWith('FEHLER:', True) then
    Result := Trim(Copy(Result, Length('FEHLER:') + 1, MaxInt))
  else if Result.StartsWith('ERROR:', True) then
    Result := Trim(Copy(Result, Length('ERROR:') + 1, MaxInt));

  if Result = '' then
    Result := E.Message;
end;

function FeldOderNull(ADataSet: TDataSet; const AFeld: string): Variant;
var
  LFeld: TField;
begin
  if not Assigned(ADataSet) then
    Exit(Null);
  LFeld := ADataSet.FindField(AFeld);
  if not Assigned(LFeld) or LFeld.IsNull then
    Result := Null
  else
    Result := LFeld.AsVariant;
end;

function TdmZentraleDaten.TabelleFinden(const ATabelle: string): TFDTable;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TFDTable) and
       SameText(TFDTable(Components[I]).TableName, ATabelle) then
      Exit(TFDTable(Components[I]));
end;

function TdmZentraleDaten.SpAufrufen(const AFunktion: string;
  const AWerte: array of Variant): Variant;
begin
  // Der gewoehnliche Aufruf ist der Blob-Aufruf ohne Blob - eine Wahrheit,
  // nicht zwei fast gleiche Routinen.
  Result := SpAufrufenBlob(AFunktion, AWerte, -1, nil);
end;

function TdmZentraleDaten.SpAufrufenBlob(const AFunktion: string;
  const AWerte: array of Variant; ABlobIndex: Integer;
  const ABlob: TBytes): Variant;
var
  LQry: TFDQuery;
  LStrom: TBytesStream;
  I: Integer;
  LPlatzhalter: string;
  LBlobDa: Boolean;
begin
  FaehigkeitenPruefen;

  // Ein leeres Blob wird behandelt wie jeder andere leere Wert: NULL.
  LBlobDa := (ABlobIndex >= Low(AWerte)) and (ABlobIndex <= High(AWerte)) and
             (Length(ABlob) > 0);

  // SELECT fn_x(:p0, :p1, ...) - die Werte gehen als Parameter raus, nie als
  // zusammengebauter SQL-Text. Sonst waere jedes Hochkomma in einem
  // Beschreibungstext eine offene Tuer.
  // Ein leerer Wert wird als blankes NULL in den Text geschrieben, nicht als
  // Parameter: ein geleerter Parameter hat keinen Datentyp, und FireDAC
  // bricht dann mit "Datentyp des Parameters ist unbekannt" ab. NULL im Text
  // ist ungefaehrlich - es kommt kein Wert von aussen hinein - und Postgres
  // holt den Typ aus der Signatur der Funktion.
  LPlatzhalter := '';
  for I := Low(AWerte) to High(AWerte) do
  begin
    if LPlatzhalter <> '' then
      LPlatzhalter := LPlatzhalter + ', ';
    if I = ABlobIndex then
    begin
      if LBlobDa then
        LPlatzhalter := LPlatzhalter + ':p' + IntToStr(I)
      else
        LPlatzhalter := LPlatzhalter + 'NULL';
    end
    else if VarIsNull(AWerte[I]) or VarIsEmpty(AWerte[I]) then
      LPlatzhalter := LPlatzhalter + 'NULL'
    else
      LPlatzhalter := LPlatzhalter + ':p' + IntToStr(I);
  end;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FDConnection1;
    LQry.SQL.Text := 'SELECT ' + AFunktion + '(' + LPlatzhalter + ') AS ergebnis';
    for I := Low(AWerte) to High(AWerte) do
      if I = ABlobIndex then
      begin
        if LBlobDa then
        begin
          LStrom := TBytesStream.Create(ABlob);
          try
            LQry.ParamByName('p' + IntToStr(I)).LoadFromStream(LStrom, ftBlob);
          finally
            LStrom.Free;
          end;
        end;
      end
      else if not (VarIsNull(AWerte[I]) or VarIsEmpty(AWerte[I])) then
        LQry.ParamByName('p' + IntToStr(I)).Value := AWerte[I];
    LQry.Open;
    if LQry.IsEmpty then
      Result := Null
    else
      Result := LQry.Fields[0].AsVariant;
    LQry.Close;

    // Postgres meldet seine Zaehler normalerweise erst nach etwa einer
    // Sekunde weiter. Die Aenderungserkennung wuerde diesen Schreibvorgang
    // deshalb kurz nicht sehen und die Anzeige nicht auffrischen. Ein Stoss
    // hier, und der Zaehler steht sofort richtig.
    if FFlushMoeglich then
    begin
      LQry.SQL.Text := 'SELECT pg_stat_force_next_flush()';
      LQry.Open;
      LQry.Close;
      // Der zwischengespeicherte Stand ist damit ueberholt.
      FZaehlerZeit := 0;
      FZaehler.Clear;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmZentraleDaten.SpAbfragen(const AFunktion: string;
  const AWerte: array of Variant): TFDMemTable;
var
  LQry: TFDQuery;
  I: Integer;
  LPlatzhalter: string;
begin
  // Ein leerer Wert wird als blankes NULL in den Text geschrieben, nicht als
  // Parameter: ein geleerter Parameter hat keinen Datentyp, und FireDAC
  // bricht dann mit "Datentyp des Parameters ist unbekannt" ab. NULL im Text
  // ist ungefaehrlich - es kommt kein Wert von aussen hinein - und Postgres
  // holt den Typ aus der Signatur der Funktion.
  LPlatzhalter := '';
  for I := Low(AWerte) to High(AWerte) do
  begin
    if LPlatzhalter <> '' then
      LPlatzhalter := LPlatzhalter + ', ';
    if VarIsNull(AWerte[I]) or VarIsEmpty(AWerte[I]) then
      LPlatzhalter := LPlatzhalter + 'NULL'
    else
      LPlatzhalter := LPlatzhalter + ':p' + IntToStr(I);
  end;

  Result := TFDMemTable.Create(nil);
  LQry := TFDQuery.Create(nil);
  try
    try
      LQry.Connection := FDConnection1;
      LQry.SQL.Text := 'SELECT * FROM ' + AFunktion + '(' + LPlatzhalter + ')';
      for I := Low(AWerte) to High(AWerte) do
        if not (VarIsNull(AWerte[I]) or VarIsEmpty(AWerte[I])) then
          LQry.ParamByName('p' + IntToStr(I)).Value := AWerte[I];
      LQry.Open;
      LQry.FetchAll;
      Result.Data := LQry.Data;
    except
      Result.Free;
      raise;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmZentraleDaten.KopieHolen(const ATabelle: string): TFDMemTable;
begin
  Result := TFDMemTable.Create(nil);
  try
    ModulFuellen([Zuordnung(Result, ATabelle)]);
    // Die MemTable gehoert dem Aufrufer und wird von ihm freigegeben. Beide
    // Eintraege muessen weg: bleibt der in FMemTabelle stehen, greift
    // TabelleAuffrischen spaeter auf freigegebenen Speicher zu, und die
    // naechste MemTable koennte dieselbe Adresse bekommen und faelschlich
    // als aktuell gelten.
    FStandMem.Remove(Pointer(Result));
    FMemTabelle.Remove(Pointer(Result));
  except
    Result.Free;
    raise;
  end;
end;

// ===========================================================================
// Nur laden, wenn sich etwas geaendert hat
//
// Frueher hat ModulFuellen bei jedem Modulaufruf jede MemTable geschlossen
// und neu befuellt. Das kostete Zeit, und die Anzeige sprang jedes Mal auf
// den ersten Satz zurueck. Jetzt wird vorher gefragt, ob sich in der
// Datenbank ueberhaupt etwas getan hat.
//
// Gefragt wird pg_stat_user_tables: Postgres fuehrt dort je Tabelle mit,
// wie viele Zeilen eingefuegt, geaendert und geloescht wurden. Warum nicht
// audit_log: das haengt nur an 18 der 138 Tabellen, und es auf alle
// auszuweiten hiesse 131 Trigger auf Tabellen anzulegen, die postgres
// gehoeren (wwe123 darf das nicht) - und jede Schreiboperation wuerde die
// komplette Zeile zusaetzlich als JSON mitschreiben. Die Zaehler kosten
// nichts, gibt es fuer alle Tabellen, und sie sehen auch Aenderungen, die
// gar nicht aus Heisenberg kommen (psql, die Website).
//
// Zwei Eigenheiten der Zaehler, die hier beruecksichtigt sind:
//  - Sie laufen der eigenen Schreiboperation bis zu eine Sekunde hinterher.
//    Deshalb zaehlt TabelleAuffrischen zusaetzlich eine eigene Runde hoch;
//    auf die eigene Eingabe wartet niemand auf den Zaehler.
//  - Ein pg_stat_reset() setzt sie zurueck. Deshalb gilt "ungleich" als
//    geaendert, nicht "groesser".
// ===========================================================================

procedure TdmZentraleDaten.FaehigkeitenPruefen;
var
  LQry: TFDQuery;
begin
  if FZaehlerGeprueft then
    Exit;
  FZaehlerGeprueft := True;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FDConnection1;
    // Ohne track_counts stehen alle Zaehler auf 0 und wuerden sich nie
    // aendern - dann waere jede Anzeige stillschweigend veraltet. Lieber
    // wie frueher jedes Mal neu laden.
    // pg_stat_force_next_flush gibt es erst ab Postgres 15; to_regproc
    // liefert NULL statt eines Fehlers, wenn es die Funktion nicht gibt.
    LQry.SQL.Text :=
      'SELECT current_setting(''track_counts'') AS zaehler, ' +
      '       (to_regproc(''pg_stat_force_next_flush'') IS NOT NULL) AS flush';
    LQry.Open;
    FZaehlerNutzbar := not LQry.IsEmpty and
      SameText(LQry.FieldByName('zaehler').AsString, 'on');
    FFlushMoeglich := not LQry.IsEmpty and
      LQry.FieldByName('flush').AsBoolean;
  finally
    LQry.Free;
  end;
end;

procedure TdmZentraleDaten.ZaehlerLesen;
var
  LQry: TFDQuery;
  LJetzt: Cardinal;
begin
  FaehigkeitenPruefen;
  if not FZaehlerNutzbar then
    Exit;

  // Mehrere Aufrufe kurz hintereinander (ein Modul frischt mehrere Tabellen
  // auf) sollen nicht jedes Mal zur Datenbank.
  LJetzt := TThread.GetTickCount;
  if (FZaehler.Count > 0) and (LJetzt - FZaehlerZeit < 250) then
    Exit;

  // Diese Auskunft wird bei jedem Modulwechsel geholt. Ueber eine Leitung
  // mit Laufzeit (Tailscale) kostet nicht die Abfrage etwas, sondern die
  // Zahl der Fahrten: FireDAC macht daraus sonst PQprepare, DECLARE CURSOR,
  // BEGIN, FETCH, CLOSE, COMMIT und zwei DEALLOCATE - acht Fahrten fuer eine
  // Auskunft, gemessen rund 400 ms. DirectExecute schickt sie als eine.
  // Das Abfrageobjekt bleibt bestehen, sonst kaeme das DEALLOCATE-Paar bei
  // jedem Aufruf wieder dazu.
  if not Assigned(FZaehlerQry) then
  begin
    FZaehlerQry := TFDQuery.Create(Self);
    FZaehlerQry.Connection := FDConnection1;
    FZaehlerQry.ResourceOptions.DirectExecute := True;
    FZaehlerQry.FetchOptions.Mode := fmAll;
    FZaehlerQry.FetchOptions.Unidirectional := True;
    FZaehlerQry.SQL.Text :=
      'SELECT relname, ' +
      '       (n_tup_ins + n_tup_upd + n_tup_del)::text ' +
      '       || ''/'' || n_live_tup::text AS stand ' +
      'FROM pg_stat_user_tables WHERE schemaname = ''public''';
  end;

  LQry := FZaehlerQry;
  LQry.Close;
  LQry.Open;
  try
    FZaehler.Clear;
    while not LQry.Eof do
    begin
      FZaehler.AddOrSetValue(LowerCase(LQry.Fields[0].AsString),
        LQry.Fields[1].AsString);
      LQry.Next;
    end;
    FZaehlerZeit := TThread.GetTickCount;
  finally
    LQry.Close;
  end;
end;

procedure TdmZentraleDaten.KatalogLesen;
var
  LQry: TFDQuery;
begin
  if FKatalogGelesen then
    Exit;
  FKatalogGelesen := True;

  // Eine Sicht hat keinen eigenen Zaehler. Sie gilt als geaendert, wenn sich
  // eine ihrer Basistabellen geaendert hat - die stehen in pg_depend. Die
  // Rekursion loest Sichten auf, die auf Sichten aufsetzen.
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FDConnection1;
    LQry.SQL.Text :=
      'WITH RECURSIVE kante AS ( ' +
      '  SELECT DISTINCT v.relname AS sicht, t.relname AS quelle, t.relkind ' +
      '  FROM pg_depend d ' +
      '  JOIN pg_rewrite r ON r.oid = d.objid ' +
      '  JOIN pg_class v ON v.oid = r.ev_class AND v.relkind IN (''v'',''m'') ' +
      '  JOIN pg_class t ON t.oid = d.refobjid ' +
      '       AND t.relkind IN (''r'',''v'',''m'',''p'') ' +
      '  JOIN pg_namespace n ON n.oid = v.relnamespace ' +
      '       AND n.nspname = ''public'' ' +
      '  WHERE d.classid = ''pg_rewrite''::regclass ' +
      '    AND d.refclassid = ''pg_class''::regclass ' +
      '    AND v.relname <> t.relname), ' +
      'aufloesen(sicht, quelle, relkind) AS ( ' +
      '  SELECT sicht, quelle, relkind FROM kante ' +
      '  UNION ' +
      '  SELECT a.sicht, k.quelle, k.relkind ' +
      '  FROM aufloesen a JOIN kante k ON k.sicht = a.quelle) ' +
      'SELECT sicht, string_agg(quelle, '','' ORDER BY quelle) AS basis ' +
      'FROM aufloesen WHERE relkind IN (''r'',''p'') GROUP BY sicht';
    LQry.Open;
    while not LQry.Eof do
    begin
      FSichten.AddOrSetValue(LowerCase(LQry.Fields[0].AsString),
        LowerCase(LQry.Fields[1].AsString));
      LQry.Next;
    end;
    LQry.Close;

    // Und die Primaerschluessel. FireDAC kennt sie nicht: die Tabellen
    // laufen mit ResourceOptions.DirectExecute, dabei holt es keine
    // Metadaten, und pfInKey bleibt an allen Feldern leer. Gebraucht werden
    // sie, um nach dem Auffrischen wieder auf denselben Satz zu kommen -
    // und sie sind hier oft mehrspaltig.
    LQry.SQL.Text :=
      'SELECT c.relname AS tabelle, ' +
      '       string_agg(a.attname, '';'' ORDER BY k.ord) AS schluessel ' +
      'FROM pg_index i ' +
      'JOIN pg_class c ON c.oid = i.indrelid ' +
      'JOIN pg_namespace n ON n.oid = c.relnamespace ' +
      '     AND n.nspname = ''public'' ' +
      'CROSS JOIN LATERAL unnest(i.indkey) WITH ORDINALITY AS k(attnum, ord) ' +
      'JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = k.attnum ' +
      'WHERE i.indisprimary ' +
      'GROUP BY c.relname';
    LQry.Open;
    while not LQry.Eof do
    begin
      FSchluessel.AddOrSetValue(LowerCase(LQry.Fields[0].AsString),
        LQry.Fields[1].AsString);
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmZentraleDaten.ImmerNeu: string;
begin
  // Ein Wert, der sich garantiert von jedem frueheren unterscheidet: damit
  // faellt die Pruefung auf das alte Verhalten zurueck (immer neu laden).
  Inc(FImmerNeuNr);
  Result := '*' + IntToStr(FImmerNeuNr);
end;

function TdmZentraleDaten.ZaehlerVon(const ATabelle: string): string;
var
  LName: string;
  LBasis: string;
  LTeil: string;
  LStand: string;
begin
  if not FZaehlerNutzbar then
    Exit(ImmerNeu);

  LName := LowerCase(ATabelle);
  if FZaehler.TryGetValue(LName, Result) then
    Exit;

  // Keine Basistabelle - dann eine Sicht, die haengt an ihren Quellen.
  KatalogLesen;
  if FSichten.TryGetValue(LName, LBasis) then
  begin
    Result := '';
    for LTeil in LBasis.Split([',']) do
      if FZaehler.TryGetValue(LTeil, LStand) then
        Result := Result + LTeil + '=' + LStand + ';';
    if Result <> '' then
      Exit;
  end;

  // Weder Tabelle noch bekannte Sicht: nicht raten, sondern neu laden.
  Result := ImmerNeu;
end;

function TdmZentraleDaten.StandVon(const ATabelle: string): string;
var
  LName: string;
  LBasis: string;
  LTeil: string;
  LRunde: Integer;
  LSumme: Integer;
begin
  Result := ZaehlerVon(ATabelle);

  // Die eigenen Schreibvorgaenge dazu: TabelleAuffrischen zaehlt sie hoch,
  // weil der Zaehler der Datenbank sie erst eine Sekunde spaeter meldet.
  LName := LowerCase(ATabelle);
  LSumme := 0;
  if FEigeneRunde.TryGetValue(LName, LRunde) then
    Inc(LSumme, LRunde);
  // Bei einer Sicht zaehlen die Runden ihrer Basistabellen mit.
  if FSichten.TryGetValue(LName, LBasis) then
    for LTeil in LBasis.Split([',']) do
      if FEigeneRunde.TryGetValue(LTeil, LRunde) then
        Inc(LSumme, LRunde);

  if LSumme > 0 then
    Result := Result + '#' + IntToStr(LSumme);
end;

procedure TdmZentraleDaten.TabelleAuffrischen(const ATabelle: string);
var
  LTable: TFDTable;
  LRunde: Integer;
  LSchluessel: Pointer;
  LMem: TFDMemTable;
begin
  LTable := TabelleFinden(ATabelle);
  if not Assigned(LTable) then
    Exit;
  if LTable.Active then
    LTable.Refresh
  else
    LTable.Open;

  ZaehlerLesen;
  FStandTabelle.AddOrSetValue(LTable.TableName, ZaehlerVon(LTable.TableName));

  // Eigene Runde hochzaehlen: die MemTables der Module muessen sich diese
  // Aenderung holen, auch wenn der Zaehler der Datenbank noch nichts davon
  // weiss. KatalogLesen, damit StandVon die abhaengigen Sichten kennt.
  KatalogLesen;
  FEigeneRunde.TryGetValue(LowerCase(ATabelle), LRunde);
  FEigeneRunde.AddOrSetValue(LowerCase(ATabelle), LRunde + 1);

  // Dieser Aufruf ist die Quittung "geschrieben und angekommen". Damit
  // duerfen die MemTables, die aus dieser Tabelle gefuellt sind, wieder
  // aufgefrischt werden - vorher haelt HatOffeneAenderung sie fest. Ohne
  // das bliebe die vom Server vergebene ID draussen.
  for LSchluessel in FMemTabelle.Keys do
    if SameText(FMemTabelle[LSchluessel], ATabelle) then
    begin
      LMem := TFDMemTable(LSchluessel);
      if LMem.Active and LMem.CachedUpdates and
         not (LMem.State in dsEditModes) and (LMem.ChangeCount > 0) then
        LMem.CommitUpdates;
    end;
end;

function TdmZentraleDaten.TabelleGeaendert(const ATabelle: string): Boolean;
var
  LAlt: string;
begin
  ZaehlerLesen;
  Result := not (FStandTabelle.TryGetValue(ATabelle, LAlt) and
                 (LAlt = ZaehlerVon(ATabelle)));
end;

procedure TdmZentraleDaten.QuelleNachziehen(AQuelle: TFDTable);
var
  LName: string;
  LStand: string;
  LAlt: string;
begin
  LName := AQuelle.TableName;
  LStand := ZaehlerVon(LName);

  if not AQuelle.Active then
  begin
    AQuelle.Open;
    FStandTabelle.AddOrSetValue(LName, LStand);
    Exit;
  end;

  if FStandTabelle.TryGetValue(LName, LAlt) and (LAlt = LStand) then
    Exit;

  // Refresh, nicht Close/Open: an einer offenen Tabelle koennen Verweise
  // (CloneCursor) haengen, die ein Close ins Leere laufen liesse.
  AQuelle.Refresh;
  FStandTabelle.AddOrSetValue(LName, LStand);
end;

function TdmZentraleDaten.HatOffeneAenderung(AMem: TFDMemTable): Boolean;
begin
  // Zwei Faelle, beide heissen "Finger weg":
  //  - der Anwender tippt gerade (dsEdit/dsInsert),
  //  - er hat schon gepostet, aber die Datenbankfunktion war noch nicht
  //    erfolgreich. Das Modul postet bewusst zuerst in die MemTable, damit
  //    sofort weitergearbeitet werden kann; wuerde hier dazwischen
  //    aufgefrischt, waere die Eingabe still weg.
  // Der Post landet wegen CachedUpdates als Aenderung im Protokoll der
  // MemTable - genau daran ist er zu erkennen.
  Result := (AMem.State in dsEditModes) or
            (AMem.CachedUpdates and (AMem.ChangeCount > 0));
end;

function TdmZentraleDaten.FelderPassen(AMem: TFDMemTable;
  AQuelle: TFDTable): Boolean;
var
  I: Integer;
begin
  // Reicht die vorhandene Feldstruktur der MemTable, um alle Spalten der
  // Quelle aufzunehmen? Wenn nicht, muss sie doch geschlossen und ueber
  // Data neu aufgebaut werden - nur das legt Felder an.
  Result := False;
  if not AQuelle.Active then
    Exit;
  for I := 0 to AQuelle.FieldCount - 1 do
    if AMem.FindField(AQuelle.Fields[I].FieldName) = nil then
      Exit;
  Result := True;
end;

function TdmZentraleDaten.SchluesselFelder(AMem: TFDMemTable;
  const ATabelle: string): string;
var
  I: Integer;
  LName: string;
begin
  // Nach dem Auffrischen soll der Satzzeiger wieder auf derselben Zeile
  // stehen. Ein Lesezeichen ueberlebt das Neubefuellen nicht, der
  // Schluesselwert schon.
  // Nicht ueber den Namen raten: der Schluessel ist hier oft mehrspaltig
  // (abwesenheitsart = mandant_id + art_id).
  KatalogLesen;
  if FSchluessel.TryGetValue(LowerCase(ATabelle), Result) then
  begin
    // Nur nehmen, wenn die MemTable alle Schluesselspalten auch fuehrt.
    for LName in Result.Split([';']) do
      if AMem.FindField(LName) = nil then
      begin
        Result := '';
        Break;
      end;
    if Result <> '' then
      Exit;
  end;

  // Eine Sicht hat keinen Primaerschluessel. Dort bleibt nur der Name.
  if Assigned(AMem.FindField(ATabelle + '_id')) then
    Exit(ATabelle + '_id');
  for I := 0 to AMem.FieldCount - 1 do
    if (AMem.Fields[I].FieldKind = fkData) and
       AMem.Fields[I].FieldName.EndsWith('_id', True) then
      Exit(AMem.Fields[I].FieldName);
end;

function TdmZentraleDaten.SchluesselWerte(AMem: TFDMemTable;
  const AFelder: string): Variant;
var
  LNamen: TArray<string>;
  I: Integer;
begin
  LNamen := AFelder.Split([';']);
  if Length(LNamen) = 1 then
    Exit(AMem.FieldByName(LNamen[0]).AsVariant);
  Result := VarArrayCreate([0, High(LNamen)], varVariant);
  for I := 0 to High(LNamen) do
    Result[I] := AMem.FieldByName(LNamen[I]).AsVariant;
end;

procedure TdmZentraleDaten.MemFuellen(AMem: TFDMemTable; AQuelle: TFDTable);
begin
  // Der einzige Weg, der die Feldstruktur mitbringt - verlangt aber eine
  // geschlossene Datenmenge (TFDDataSet.SetData ruft CheckInactive).
  // Deshalb nur beim ersten Fuellen und wenn sich die Struktur geaendert hat.
  AMem.Close;
  AMem.CachedUpdates := True;
  AMem.Data := AQuelle.Data;
  AMem.CommitUpdates;
end;

procedure TdmZentraleDaten.MemAuffrischen(AMem: TFDMemTable; AQuelle: TFDTable;
  const ATabelle: string);
var
  LSchluessel: string;
  LWert: Variant;
  LGefiltert: Boolean;
  LNurLesen: TArray<Boolean>;
  I: Integer;
begin
  if not FelderPassen(AMem, AQuelle) then
  begin
    MemFuellen(AMem, AQuelle);
    Exit;
  end;

  LSchluessel := SchluesselFelder(AMem, ATabelle);
  LWert := Null;
  if (LSchluessel <> '') and not AMem.IsEmpty and not AMem.Eof then
    LWert := SchluesselWerte(AMem, LSchluessel)
  else
    LSchluessel := '';

  AMem.DisableControls;
  LGefiltert := AMem.Filtered;
  // CopyDataSet haengt die Saetze ueber Append/Post an. Schreibgeschuetzte
  // Felder und Zaehlerfelder wuerden dabei ablehnen - beim Weg ueber Data
  // stellt FireDAC das selbst ab, ohne coStructure muessen wir es tun.
  SetLength(LNurLesen, AMem.FieldCount);
  for I := 0 to AMem.FieldCount - 1 do
  begin
    LNurLesen[I] := AMem.Fields[I].ReadOnly;
    AMem.Fields[I].ReadOnly := False;
    if AMem.Fields[I] is TFDAutoIncField then
      TFDAutoIncField(AMem.Fields[I]).IdentityInsert := True;
  end;
  try
    // Der Filter muss waehrend des Fuellens aus: sonst verschwindet jeder
    // gerade angehaengte Satz, der nicht dazu passt, sofort wieder.
    AMem.Filtered := False;
    // EmptyDataSet leert, ohne zu schliessen - darum geht es hier. Die
    // Felder bleiben stehen, und damit auch die Spalten der Grids, die
    // Sortierung und die Master-Detail-Verdrahtung.
    AMem.EmptyDataSet;
    AMem.CopyDataSet(AQuelle, [coRestart, coAppend]);
    if AMem.CachedUpdates then
      AMem.CommitUpdates;
  finally
    for I := 0 to AMem.FieldCount - 1 do
      if I <= High(LNurLesen) then
        AMem.Fields[I].ReadOnly := LNurLesen[I];
    AMem.Filtered := LGefiltert;
    if (LSchluessel <> '') and not VarIsNull(LWert) then
      AMem.Locate(LSchluessel, LWert, []);
    AMem.EnableControls;
  end;
end;

procedure TdmZentraleDaten.ModulFuellen(
  const AZuordnung: array of TTabellenZuordnung);
var
  I: Integer;
  LQuelle: TFDTable;
  LMaster: array of TDataSource;
  LMasterFields: array of string;
  LStand: string;
  LAlt: string;
begin
  // Einmal nachsehen, was sich in der Datenbank getan hat - eine Abfrage
  // fuer alle Tabellen, nicht eine je Tabelle.
  ZaehlerLesen;

  SetLength(LMaster, Length(AZuordnung));
  SetLength(LMasterFields, Length(AZuordnung));
  for I := Low(AZuordnung) to High(AZuordnung) do
    if Assigned(AZuordnung[I].Mem) then
    begin
      // ─── Master-Detail AUS DEM DFM lesen ───
      LMaster[I] := AZuordnung[I].Mem.MasterSource;
      LMasterFields[I] := AZuordnung[I].Mem.MasterFields;
      AZuordnung[I].Mem.MasterSource := nil;
    end;

  try
    for I := Low(AZuordnung) to High(AZuordnung) do
    begin
      if not Assigned(AZuordnung[I].Mem) then
        Continue;

      LQuelle := TabelleFinden(AZuordnung[I].Tabelle);
      if not Assigned(LQuelle) then
        raise Exception.CreateFmt(
          'Tabelle "%s" gibt es im zentralen Datenmodul nicht.',
          [AZuordnung[I].Tabelle]);

      begin
        // HIER WIRD NICHT GEFILTERT, und das ist Absicht.
        //
        // Am 19.08.2026 stand hier ein Block, der die Quelltabelle vor dem
        // Kopieren auf den aktuellen Satz des Masters filterte. Das nimmt
        // Master-Detail die Grundlage: die Kopie enthielt danach nur noch
        // die Saetze EINES Artikels, und beim Wechsel auf den naechsten
        // blieb das Detailgitter leer. Gemessen mit TestMasterDetail:
        // "Kopie artikel_foto 2 (soll 6 gesamt)".
        //
        // Die Kopie muss die ganze Tabelle enthalten. Gefiltert wird erst
        // im Speicher - ueber MasterSource/MasterFields und den Index der
        // MemTable. Ein Filter auf der Quelle waere ausserdem doppelt
        // gefaehrlich: die Quelle gehoert allen Modulen gemeinsam.

        QuelleNachziehen(LQuelle);
        LStand := StandVon(AZuordnung[I].Tabelle);

        if AZuordnung[I].NurVerweis then
        begin
          if not AZuordnung[I].Mem.Active then
            AZuordnung[I].Mem.CloneCursor(LQuelle, True);
        end
        else if not AZuordnung[I].Mem.Active then
        begin
          if AZuordnung[I].Mem.FieldCount > 0 then
          begin
            AZuordnung[I].Mem.CreateDataSet;
            MemAuffrischen(AZuordnung[I].Mem, LQuelle, AZuordnung[I].Tabelle);
          end
          else
            MemFuellen(AZuordnung[I].Mem, LQuelle);
        end
        else if HatOffeneAenderung(AZuordnung[I].Mem) then
        begin
          Continue;
        end
        else if not (FStandMem.TryGetValue(Pointer(AZuordnung[I].Mem), LAlt) and
                     (LAlt = LStand)) then
          MemAuffrischen(AZuordnung[I].Mem, LQuelle, AZuordnung[I].Tabelle);

        FStandMem.AddOrSetValue(Pointer(AZuordnung[I].Mem), LStand);
        FMemTabelle.AddOrSetValue(Pointer(AZuordnung[I].Mem), LowerCase(AZuordnung[I].Tabelle));

      end;
    end;
  finally
    for I := Low(AZuordnung) to High(AZuordnung) do
      if Assigned(AZuordnung[I].Mem) and Assigned(LMaster[I]) then
      begin
        AZuordnung[I].Mem.MasterSource := LMaster[I];
        // MasterFields kann beim Abhaengen verlorengehen; ohne die Felder
        // waere die Kopplung zwar wieder da, wuerde aber nichts filtern.
        if AZuordnung[I].Mem.MasterFields <> LMasterFields[I] then
          AZuordnung[I].Mem.MasterFields := LMasterFields[I];
      end;
  end;
end;

procedure TdmZentraleDaten.TabelleLaden(ATabelle: TFDTable);
begin
  Inc(FLadeIndex);
  if Assigned(FOnLadeFortschritt) then
    FOnLadeFortschritt(Self, ATabelle.TableName, FLadeIndex, FLadeGesamt);
  if not ATabelle.Active then
    ATabelle.Open;
  // Last erzwingt, dass wirklich alle Saetze da sind und nicht nur der
  // erste Block - danach zurueck an den Anfang.
  ATabelle.Last;
  ATabelle.First;
  // Zaehlerstand festhalten, sonst gilt beim ersten ModulFuellen alles als
  // geaendert und wird ein zweites Mal geholt.
  FStandTabelle.AddOrSetValue(ATabelle.TableName,
    ZaehlerVon(ATabelle.TableName));
end;

function TdmZentraleDaten.TabellenGesamt: Integer;
var
  I: Integer;
begin
  // Gezaehlt statt festgeschrieben. Die feste 129 stimmte nicht mehr mit der
  // Liste unten ueberein, und die Anzeige lief entsprechend daneben.
  Result := 0;
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TFDTable then
      Inc(Result);
end;

procedure TdmZentraleDaten.AlleTabellenLaden;
var
  I: Integer;
  LEreignis: IMyEvent;
begin
  FLadeIndex := 0;
  FLadeGesamt := TabellenGesamt;
  if not FDConnection1.Connected then
    FDConnection1.Connected := True;
  // Einmal die Zaehler holen, TabelleLaden schreibt sie dann je Tabelle mit.
  ZaehlerLesen;

  TabelleLaden(FDTableabwesenheit);
  TabelleLaden(FDTableabwesenheitsart);
  TabelleLaden(FDTableadresse);
  TabelleLaden(FDTableadressentyp);
  TabelleLaden(FDTableadressinfo);
  TabelleLaden(FDTableanlage);
  TabelleLaden(FDTableanlage_abschreibung);
  TabelleLaden(FDTableanlage_dokument);
  TabelleLaden(FDTableanonymisierung_protokoll);
  TabelleLaden(FDTableanwesenheit_check);
  TabelleLaden(FDTableanwesenheit_tag);
  TabelleLaden(FDTableartikel);
  TabelleLaden(FDTableartikel_artikel);
  TabelleLaden(FDTableartikel_barcode);
  TabelleLaden(FDTableartikel_fach);
  TabelleLaden(FDTableartikel_foto);
  TabelleLaden(FDTableartikel_preis);
  TabelleLaden(FDTableartikel_variante);
  TabelleLaden(FDTableartikel_variante_typ);
  TabelleLaden(FDTableartikel_variante_wert);
  TabelleLaden(FDTableartikel_zugang);
  TabelleLaden(FDTableaudit_log);
  TabelleLaden(FDTableausstattung);
  TabelleLaden(FDTablebeleg);
  TabelleLaden(FDTablebeleg_position);
  TabelleLaden(FDTablebenutzer);
  TabelleLaden(FDTablebenutzer_mandant);
  TabelleLaden(FDTablebetriebs_ausnahme);
  TabelleLaden(FDTablebetriebszeit);
  TabelleLaden(FDTablebezirk);
  TabelleLaden(FDTablebuchung);
  TabelleLaden(FDTablebuchung_dokument);
  TabelleLaden(FDTablebuchung_zeile);
  TabelleLaden(FDTablebudget);
  TabelleLaden(FDTablecontentweb);
  TabelleLaden(FDTablecontentweb_text);
  TabelleLaden(FDTabledatenschutz_kenntnisnahme);
  TabelleLaden(FDTabledatenschutz_vorfall);
  TabelleLaden(FDTabledatenschutzinformation);
  TabelleLaden(FDTabledokument_typ);
  TabelleLaden(FDTableemailadresse);
  TabelleLaden(FDTableemailtyp);
  TabelleLaden(FDTableerfassungsraster);
  TabelleLaden(FDTablefeedback);
  TabelleLaden(FDTablefeiertag);
  TabelleLaden(FDTableferien_anspruch);
  TabelleLaden(FDTablegutsprache_abruf);
  TabelleLaden(FDTableheisenberg_deployment_log);
  TabelleLaden(FDTableheisenberg_kunde);
  TabelleLaden(FDTableheisenberg_script);
  TabelleLaden(FDTableheisenberg_version);
  TabelleLaden(FDTablekalkulation);
  TabelleLaden(FDTablekalkulation_dokument);
  TabelleLaden(FDTablekalkulation_position);
  TabelleLaden(FDTablekalkulation_risiko);
  TabelleLaden(FDTableklient);
  TabelleLaden(FDTableklient_semester);
  TabelleLaden(FDTablekompetenz_typ);
  TabelleLaden(FDTablekonto);
  TabelleLaden(FDTablekostenart);
  TabelleLaden(FDTablekostengutsprache);
  TabelleLaden(FDTablekostenstelle);
  TabelleLaden(FDTablekostenstelle_wert);
  TabelleLaden(FDTablekostenwert_dokument);
  TabelleLaden(FDTablekunde);
  TabelleLaden(FDTablekurs);
  TabelleLaden(FDTablekurs_anwesenheit);
  TabelleLaden(FDTablekurs_ausstattung);
  TabelleLaden(FDTablekurs_durchfuehrung);
  TabelleLaden(FDTablekurs_kompetenz);
  TabelleLaden(FDTablekurs_kurs);
  TabelleLaden(FDTablekurs_material);
  TabelleLaden(FDTablekurs_teilnehmer);
  TabelleLaden(FDTablekurs_termin);
  TabelleLaden(FDTablelager);
  TabelleLaden(FDTableland);
  TabelleLaden(FDTableleadquelle_typ);
  TabelleLaden(FDTableleistung);
  TabelleLaden(FDTablelohn_abzugsart);
  TabelleLaden(FDTablelohn_dokument);
  TabelleLaden(FDTablelohn_periode);
  TabelleLaden(FDTablelohn_periode_position);
  TabelleLaden(FDTablelohn_zulage);
  TabelleLaden(FDTablemandant);
  TabelleLaden(FDTablemandant_dokument);
  TabelleLaden(FDTablemarktpreis);
  TabelleLaden(FDTablenavbarweb);
  TabelleLaden(FDTablenavbarweb_text);
  TabelleLaden(FDTablenavigation);
  TabelleLaden(FDTableperson);
  TabelleLaden(FDTableperson_adresse);
  TabelleLaden(FDTableperson_arbeitszeit);
  TabelleLaden(FDTableperson_beziehung);
  TabelleLaden(FDTableperson_dokument);
  TabelleLaden(FDTableperson_email);
  TabelleLaden(FDTableperson_kompetenz);
  TabelleLaden(FDTableperson_lohn);
  TabelleLaden(FDTableperson_mandant);
  TabelleLaden(FDTableperson_telefonnummer);
  TabelleLaden(FDTableperson_typ);
  TabelleLaden(FDTableraster_abschnitt);
  TabelleLaden(FDTableraum);
  TabelleLaden(FDTableraum_ausstattung);
  TabelleLaden(FDTablezeit_stempel);
  TabelleLaden(FDTablezugang_status);
  TabelleLaden(FDTablezuschlagssatz);
  TabelleLaden(FDTableumlage);
  TabelleLaden(FDTablevariante);
  TabelleLaden(FDTablevariante_variante);
  TabelleLaden(FDTableverarbeitungstaetigkeit);
  TabelleLaden(FDTablevorgang);
  TabelleLaden(FDTablevorgang_beleg);
  TabelleLaden(FDTablevorgang_dokument);
  TabelleLaden(FDTablevorgang_email);
  TabelleLaden(FDTablewaehrungskurs);
  TabelleLaden(FDTableweb_bild);
  TabelleLaden(FDTableweb_farbe);
  TabelleLaden(FDTableweb_seite);
  TabelleLaden(FDTableweb_text);
  TabelleLaden(FDTablewebinhalt);
  TabelleLaden(FDTabletermin_ausstattung);
  TabelleLaden(FDTableregal);
  TabelleLaden(FDTableregal_fach);
  TabelleLaden(FDTablerolle_typ);
  TabelleLaden(FDTablesemester);
  TabelleLaden(FDTablesprache);
  TabelleLaden(FDTablesteuer_code);
  TabelleLaden(FDTabletelefonnummer);
  TabelleLaden(FDTabletelefonnummertyp);

  // Was oben nicht namentlich steht, wird hier eingesammelt: die Sichten und
  // sechs Tabellen, deren Komponenten sich "FDTabel..." statt "FDTable..."
  // schreiben (einheit, einwilligung, email_*) und die deshalb beim
  // Abtippen der Liste durchgerutscht sind. Sie fehlten beim Start und
  // wurden dann beim ersten Oeffnen eines Moduls nachgeholt - dort, wo keine
  // Anzeige mitlaeuft und es als Haenger auffaellt.
  // dokument bleibt aussen vor, das holt NachladenSchwere nach dem
  // Hauptfenster.
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TFDTable) and not TFDTable(Components[I]).Active and
       (Components[I] <> FDTabledokument) then
      TabelleLaden(TFDTable(Components[I]));

  // Alles geladen - jetzt duerfen sich die Module ihre Kopien holen.
  // Der Broadcast geht ueber den zentralen MessageHandler an jedes erzeugte
  // Modul (mtBroadcast, Methode 'DatenGeladen'). Kein Modul wird hier
  // namentlich genannt, und keines muss hier eingetragen werden.
  //
  // Das Ereignis MUSS in einer Schnittstellenvariablen stehen (Muster wie
  // TdmModuleTemplate.OpenGui). Direkt in den Post-Aufruf geschrieben ist
  // es ein temporaeres Objekt, und der Empfaenger sieht nichts mehr.
  LEreignis := TMyEvent.Create(
    'DatenGeladen', '', '', '', '', '', '', False, mtBroadcast, Now, False, 0, []);
  GlobalEventBus.Post(LEreignis);
end;

// dokument traegt die PDF-Blobs und ist damit um Groessenordnungen
// schwerer als der Rest. Deshalb erst hier, nach dem Hauptfenster.
procedure TdmZentraleDaten.NachladenSchwere;
begin
  ZaehlerLesen;
  TabelleLaden(FDTabledokument);
end;

initialization
  GInstanceSperre := TCriticalSection.Create;

finalization
  GInstanceSperre.Free;

end.