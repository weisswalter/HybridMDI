unit ArtikelStammDm;

// Artikelstamm, neu aufgebaut ab 19.08.2026.
//
// Abgeleitet von TdmModuleTemplate. Das Modul hat keine Connection und
// setzt kein SQL ab: das zentrale Datenmodul laedt, meldet ueber den
// zentralen MessageHandler "DatenGeladen", und hier werden nur noch Kopien
// gezogen (TdmModuleTemplate.Kopiere).
//
// Master-Detail steht im DFM, nicht im Code: tblArtikelKategorie haengt
// ueber MasterSource/MasterFields an dstblArtikel.

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Variants,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  Data.DB, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet,
  Vcl.Forms, Vcl.Graphics, System.IOUtils,
  System.Generics.Collections,
  BaumKnotenData, ArtikelBestandBaumData,
  udmModuleTemplate, JvComponentBase, JvThread;

type
  TdmArtikelStamm = class(TdmModuleTemplate)
    // Stamm.
    tblArtikel: TFDMemTable;
    dstblArtikel: TDataSource;
    // Alle Kategorien des Mandanten - die Auswahlliste.
    tblKategorie: TFDMemTable;
    dstblKategorie: TDataSource;
    // Bruecke Artikel <-> Kategorie, als Detail an dstblArtikel (DFM).
    tblArtikelKategorie: TFDMemTable;
    dstblArtikelKategorie: TDataSource;
    // Persistente Felder, weil das Lookup eines braucht: die Bruecke
    // fuehrt nur zwei Schluessel, angezeigt wird die Bezeichnung aus
    // tblKategorie. Sobald EIN Feld persistent ist, muessen alle da sein -
    // sonst erzeugt FireDAC die uebrigen nicht mehr.
    tblArtikelKategorieartikel_id: TIntegerField;
    tblArtikelKategoriekategorie_id: TIntegerField;
    tblArtikelKategoriebezeichnung: TWideStringField;
    // Fotos des Artikels, ebenfalls Detail an dstblArtikel (DFM).
    tblArtikelFoto: TFDMemTable;
    dstblArtikelFoto: TDataSource;
    // ── fuer die drei Baeume ─────────────────────────────────────────
    // Stueckliste: alle Kanten des Mandanten, nicht nur die des Artikels -
    // der Baum steigt ueber mehrere Ebenen ab.
    memArtikelArtikel: TFDMemTable;
    // Merkmalsbaum: variante_variante mit bezug='child' zeigt vom Kind
    // (von_id) zum Elternteil (nach_id).
    memVariante: TFDMemTable;
    memVarianteKante: TFDMemTable;
    // Bestand: v_lagerort ist die Ortskette (eine Zeile je Fach),
    // tblArtikelFach der Bestand des angezeigten Artikels.
    memLagerort: TFDMemTable;
    memEinheit: TFDMemTable;
    tblArtikelFach: TFDMemTable;
    // Zweite Artikelkopie, nur zum Nachschlagen von Namen. NICHT tblArtikel
    // benutzen: ein Locate darauf bewegt den Satzzeiger des Masters und
    // feuert AfterScroll erneut - das laeuft sich im Kreis.
    memArtikelNachschlag: TFDMemTable;
    // Fuer die Unterartikel-Auswahl in der Stueckliste.
    dstblArtikelAuswahl: TDataSource;
    // Fuer die Auswahllisten beim Anlegen eines Lagerorts im Bestandbaum:
    // die Adresskette der Hauptperson und die vorhandenen Raeume/Regale.
    memPersonMandant: TFDMemTable;
    memPersonAdresse: TFDMemTable;
    memAdresse: TFDMemTable;
    memRaum: TFDMemTable;
    memRegal: TFDMemTable;
    // Eine Zeile je Fach, im Format von fn_lagerort_bestand - im Speicher
    // aus memLagerort, tblArtikelFach und memEinheit zusammengesetzt.
    // BaueBestandBaum (ArtikelBestandBaumData) liest daraus.
    memBestandZeilen: TFDMemTable;
  private
    { Private-Deklarationen }
    FMandantId: Integer;
    // FilterSetzen/MandantFilter gibt es nicht mehr: gefiltert wird an der
    // Quelle, bevor kopiert wird (siehe DatenGeladen).
    procedure FotoBeschreibungGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    // Artikelname/-nummer nachschlagen, ohne den Master zu bewegen.
    function ArtikelName(AArtikelId: Integer; out ANummer: string): string;
    // Baut memBestandZeilen im Format von fn_lagerort_bestand.
    procedure BestandZeilenBauen;
    // Ortskopien nach einer Neuanlage nachziehen.
    procedure NachladenOrte;
    // Elternteil einer Variante (child zeigt vom Kind zum Elternteil).
    function VarianteHatEltern(AVarianteId: Integer;
      out AElternId: Integer): Boolean;
  public
    { Public-Deklarationen }
    class function GetInstance: TObject;
    // Ruft der MessageHandler nach dem Laden aller zentralen Tabellen.
    procedure DatenGeladen; override;
    // Einstieg ueber den MessageHandler (mtModulCall).
    procedure OpenArtikelStamm;
    // ── Kategorien ──────────────────────────────────────────────────
    // Fuellt eine Stringliste mit den Kategorien des Mandanten; die
    // kategorie_id haengt an Items.Objects.
    procedure KategorienFuellen(AItems: TStrings);
    // Haengt der angezeigte Artikel an dieser Kategorie?
    function IstZugeordnet(AKategorieId: Integer): Boolean;
    // Haken setzen oder wegnehmen. Rueckgabe: leer bei Erfolg, sonst
    // Klartext. Geschrieben wird ueber fn_artikel_kategorie_setzen.
    function KategorieSetzen(AKategorieId: Integer;
      AZuordnen: Boolean): string;

    // ── Fotos ───────────────────────────────────────────────────────
    // Ein Bild aus einer Datei anhaengen. Legt IMMER einen neuen Satz an -
    // ein vorhandenes Bild wird nie ueberschrieben. Rueckgabe: foto_id.
    function FotoAnhaengen(const ADatei, ABeschreibung: string): Integer;
    // Beschreibung/Reihenfolge des angezeigten Fotos speichern.
    function FotoTextSpeichern(AFotoId: Integer;
      const ABeschreibung: string; AReihenfolge: Integer): string;
    procedure FotoLoeschen(AFotoId: Integer);
    // Mehrere Dateien auf einmal (Ziehen-und-Ablegen). Liefert die Zahl der
    // uebernommenen Bilder; was kein lesbares Bild war, steht in
    // AUebersprungen.
    function FotosAusDateien(const ADateien: TArray<string>;
      out AUebersprungen: TArray<string>): Integer;
    procedure FotosNachladen(AFotoId: Integer = 0);
    // Ein TEXT-Feld ist ein Memofeld, und ein DBGrid schreibt dafuer
    // "(WideMemo)" statt des Inhalts. Der Handler liefert den Text.
    procedure FotoTextEinrichten;

    // ── Baeume ──────────────────────────────────────────────────────
    // Alle drei werden aus den Kopien im Speicher aufgebaut, ohne Abfrage.
    // Der Aufrufer bekommt die Wurzelliste und gibt sie selbst frei.
    // Stueckliste des angezeigten Artikels, mehrstufig.
    function StuecklisteBaum: TList<IBaumKnoten>;
    // Merkmalsbaum des Mandanten (haengt nicht am Artikel).
    function VariantenBaum: TList<IBaumKnoten>;
    // Adresse > Raum > Regal > Fach mit dem Bestand des Artikels.
    // Der Bestandbaum ist der einzige mit eigener Knotenklasse: er traegt
    // Kapazitaet, Gesamtbestand und die "+ Neu..."-Platzhalter.
    function BestandBaum: TList<IBestandKnoten>;
    // Auswahllisten und Anlegen beim Bearbeiten im Baum.
    function HauptpersonVorhanden(AMandantId: Integer): Boolean;
    procedure LadeHauptpersonAdressen(AMandantId: Integer; AItems: TStrings);
    procedure LadeRaeumeFuerAdresse(AAdresseId: Integer; AItems: TStrings);
    function NeueAdresseFuerHauptperson(AMandantId: Integer;
      const AStrasse, AHausnummer, APlz, AOrt: string): Integer;
    procedure EnsureAlsLagerMarkiert(AMandantId, AAdresseId: Integer);
    function NeuerRaum(AAdresseId: Integer; const ABezeichnung: string): Integer;
    function NeuesRegal(ARaumId: Integer; const ABezeichnung: string): Integer;

    // ── Schreibwege, die das Stammfenster braucht ───────────────────
    // Alle gehen ueber Datenbankfunktionen; Rueckgabe leer = in Ordnung,
    // sonst Klartext fuer den Anwender.
    function ArtikelSpeichern(out AArtikelId: Integer): string;
    function SetBestand(AFachId: Integer; AMenge: Double): string;
    // AArtikelId ist der Knoten, UNTER den gehaengt wird - im Baum ist das
    // nicht zwingend der angezeigte Artikel, sondern kann ein Unterartikel
    // mehrere Ebenen tiefer sein.
    function StuecklisteHinzufuegen(AArtikelId, AUnterArtikelId: Integer;
      AMenge: Double): string;
    function StuecklisteEntfernen(AArtikelId, AUnterArtikelId: Integer): string;
    function VarianteAnlegen(const AName: string; AElternId: Integer;
      out AId: Integer): string;
    function VarianteUmbenennen(AVarianteId: Integer;
      const AName: string): string;
    function VarianteLoeschen(AVarianteId: Integer): string;
    function VarianteGleichsetzen(AIdA, AIdB: Integer): string;
    function AequivalenzAufheben(AIdA, AIdB: Integer): string;
    // Nach einer Aenderung an Varianten/Stueckliste/Bestand: nur die
    // betroffene Kopie nachziehen, nicht alles neu laden.
    procedure NachladenBaumdaten(const ATabelle: string);
    // Auswahlliste fuer die Stueckliste (Unterartikel) und die
    // Gleichwertigkeit (Merkmale).
    procedure ArtikelAuswahlFuellen(AItems: TStrings);
    procedure VariantenAuswahlFuellen(AItems: TStrings);

    property MandantId: Integer read FMandantId;
  end;

const
  // Beschriftung der "+ Neu"-Zeile im Stuecklistenbaum. Steht hier, damit
  // Modul und Formular denselben Text verwenden.
  CPlatzhalterStueckliste = '+ Bestandteil...';

var
  dmArtikelStamm: TdmArtikelStamm;

implementation

uses
  MandantDm, ZentraleDatenDm, ArtikelStammFrm;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

var
  GSperreArtikelStamm: TCriticalSection;

class function TdmArtikelStamm.GetInstance: TObject;
begin
  // Doppelte Pruefung wie in den anderen Modulen: der Assigned-Test allein
  // ist nicht threadsicher.
  if not Assigned(dmArtikelStamm) then
  begin
    GSperreArtikelStamm.Enter;
    try
      if not Assigned(dmArtikelStamm) then
        Application.CreateForm(TdmArtikelStamm, dmArtikelStamm);
    finally
      GSperreArtikelStamm.Leave;
    end;
  end;
  Result := dmArtikelStamm;
end;

// Das zentrale Datenmodul ist fertig - Kopien ziehen.
//
// Reihenfolge: erst der Master, dann das Detail. Die Kopplung im DFM
// greift, sobald beide offen sind; Kopiere loest sie waehrend des Fuellens
// selbst.
procedure TdmArtikelStamm.DatenGeladen;
var
  LMandant: string;
begin
  // Der Mandant steht VOR dem Kopieren fest - er entscheidet, was ueberhaupt
  // geholt wird.
  FMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
  if FMandantId <= 0 then
    Exit;
  LMandant := 'mandant_id = ' + IntToStr(FMandantId);

  Kopiere(tblArtikel, 'artikel', LMandant);
  // Nur die benutzbaren Artikel-Kategorien dieses Mandanten.
  Kopiere(tblKategorie, 'kategorie',
          LMandant + ' and bereich = ''ARTIKEL'' and aktiv = True');
  // Die Bruecke traegt keine mandant_id - sie haengt am Artikel und wird
  // ueber Master-Detail eingegrenzt.
  Kopiere(tblArtikelKategorie, 'artikel_kategorie');
  Kopiere(tblArtikelFoto, 'artikel_foto', LMandant);

  // Fuer die Baeume.
  Kopiere(memArtikelNachschlag, 'artikel', LMandant);
  Kopiere(memArtikelArtikel, 'artikel_artikel', LMandant);
  Kopiere(memVariante, 'variante', LMandant);
  Kopiere(memVarianteKante, 'variante_variante', LMandant);
  Kopiere(memEinheit, 'einheit', LMandant);
  Kopiere(tblArtikelFach, 'artikel_fach', LMandant);
  Kopiere(memLagerort, 'v_lagerort', LMandant);
  // Fuer die Auswahllisten im Bestandbaum.
  Kopiere(memPersonMandant, 'person_mandant', LMandant);
  Kopiere(memPersonAdresse, 'person_adresse', LMandant);
  Kopiere(memAdresse, 'adresse');
  Kopiere(memRaum, 'raum');
  Kopiere(memRegal, 'regal');

  // Kein Nachfiltern mehr: in den Kopien steht nur noch, was hierher
  // gehoert. Bleibt die Sortierung der Auswahlliste.
  tblKategorie.IndexFieldNames := 'sortierung;bezeichnung';
  FotoTextEinrichten;
end;


// ── Schreibwege ─────────────────────────────────────────────────────────────
//
// Immer nach demselben Muster: Datenbankfunktion rufen, Fehler als Klartext
// zurueckgeben, danach nur die betroffene Kopie nachziehen.

procedure TdmArtikelStamm.NachladenBaumdaten(const ATabelle: string);
var
  LZentral: TdmZentraleDaten;
  LMandant: string;
begin
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  LZentral.TabelleAuffrischen(ATabelle);
  LMandant := 'mandant_id = ' + IntToStr(FMandantId);

  if SameText(ATabelle, 'artikel_artikel') then
    Kopiere(memArtikelArtikel, 'artikel_artikel', LMandant)
  else if SameText(ATabelle, 'variante') then
    Kopiere(memVariante, 'variante', LMandant)
  else if SameText(ATabelle, 'variante_variante') then
    Kopiere(memVarianteKante, 'variante_variante', LMandant)
  else if SameText(ATabelle, 'artikel_fach') then
    Kopiere(tblArtikelFach, 'artikel_fach', LMandant)
  else if SameText(ATabelle, 'artikel') then
  begin
    Kopiere(tblArtikel, 'artikel', LMandant);
    Kopiere(memArtikelNachschlag, 'artikel', LMandant);
  end;
end;

function TdmArtikelStamm.ArtikelSpeichern(out AArtikelId: Integer): string;

  function LeerIstNull(const AFeld: string): Variant;
  begin
    if Trim(tblArtikel.FieldByName(AFeld).AsString) = '' then
      Result := Null
    else
      Result := tblArtikel.FieldByName(AFeld).AsString;
  end;

var
  LId: Integer;
begin
  Result := '';
  AArtikelId := 0;
  if not tblArtikel.Active then
    Exit('Der Artikelstamm ist nicht geoeffnet.');
  // Was in den Eingabefeldern steht, ist noch im Control.
  if tblArtikel.State in dsEditModes then
    tblArtikel.UpdateRecord;
  if tblArtikel.IsEmpty and (tblArtikel.State = dsBrowse) then
    Exit('Es ist kein Artikel angezeigt.');

  LId := tblArtikel.FieldByName('artikel_id').AsInteger;
  try
    // Erloeskonto, Aufwandskonto und im_shop stehen nicht in diesem Fenster
    // und werden bewusst NICHT mitgeschickt - die Funktion laesst sie dann
    // stehen. Sonst naehme jedes Speichern einen Artikel aus dem Shop.
    AArtikelId := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
      .SpAufrufen('fn_artikel_speichern',
        [FMandantId, LId,
         tblArtikel.FieldByName('artikel_nr').AsString,
         tblArtikel.FieldByName('artikelname').AsString,
         LeerIstNull('serien_nr'), LeerIstNull('modul_nr'),
         LeerIstNull('beschreibung')]));
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;

  if tblArtikel.State in dsEditModes then
    tblArtikel.Cancel;
  NachladenBaumdaten('artikel');
  if AArtikelId > 0 then
    tblArtikel.Locate('artikel_id', AArtikelId, []);
end;

function TdmArtikelStamm.SetBestand(AFachId: Integer; AMenge: Double): string;
begin
  Result := '';
  if tblArtikel.IsEmpty then
    Exit('Es ist kein Artikel angezeigt.');
  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_artikel_fach_speichern',
      [FMandantId, tblArtikel.FieldByName('artikel_id').AsInteger,
       AFachId, AMenge]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('artikel_fach');
end;

function TdmArtikelStamm.StuecklisteHinzufuegen(AArtikelId,
  AUnterArtikelId: Integer; AMenge: Double): string;
begin
  Result := '';
  if AArtikelId <= 0 then
    Exit('Es ist kein Artikel gewaehlt.');
  try
    // Die Ringpruefung macht die Datenbank.
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_stueckliste_hinzufuegen',
      [FMandantId, AArtikelId, AUnterArtikelId, AMenge]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('artikel_artikel');
end;

function TdmArtikelStamm.StuecklisteEntfernen(AArtikelId,
  AUnterArtikelId: Integer): string;
begin
  Result := '';
  if AArtikelId <= 0 then
    Exit('Es ist kein Artikel gewaehlt.');
  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_stueckliste_entfernen', [AArtikelId, AUnterArtikelId]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('artikel_artikel');
end;

function TdmArtikelStamm.VarianteAnlegen(const AName: string;
  AElternId: Integer; out AId: Integer): string;
var
  LEltern: Variant;
begin
  Result := '';
  AId := 0;
  if AElternId > 0 then
    LEltern := AElternId
  else
    LEltern := Null;
  try
    AId := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
      .SpAufrufen('fn_variante_anlegen', [FMandantId, Trim(AName), LEltern]));
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('variante');
  NachladenBaumdaten('variante_variante');
end;

function TdmArtikelStamm.VarianteUmbenennen(AVarianteId: Integer;
  const AName: string): string;
begin
  Result := '';
  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_variante_umbenennen', [AVarianteId, Trim(AName)]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('variante');
end;

function TdmArtikelStamm.VarianteLoeschen(AVarianteId: Integer): string;
begin
  Result := '';
  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_variante_loeschen', [AVarianteId]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('variante');
  NachladenBaumdaten('variante_variante');
end;

function TdmArtikelStamm.VarianteGleichsetzen(AIdA, AIdB: Integer): string;
begin
  Result := '';
  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_variante_gleichsetzen', [FMandantId, AIdA, AIdB]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('variante_variante');
end;

function TdmArtikelStamm.AequivalenzAufheben(AIdA, AIdB: Integer): string;
begin
  Result := '';
  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_aequivalenz_aufheben', [AIdA, AIdB]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;
  NachladenBaumdaten('variante_variante');
end;

// Auswahllisten: der Schluessel haengt an Items.Objects, damit der Aufrufer
// ihn ohne weitere Abfrage zurueckbekommt.
procedure TdmArtikelStamm.ArtikelAuswahlFuellen(AItems: TStrings);
var
  LMerker: TBookmark;
begin
  AItems.Clear;
  if not memArtikelNachschlag.Active then
    Exit;
  memArtikelNachschlag.DisableControls;
  LMerker := memArtikelNachschlag.GetBookmark;
  try
    memArtikelNachschlag.First;
    while not memArtikelNachschlag.Eof do
    begin
      AItems.AddObject(
        Trim(memArtikelNachschlag.FieldByName('artikel_nr').AsString + '  ' +
             memArtikelNachschlag.FieldByName('artikelname').AsString),
        TObject(NativeInt(
          memArtikelNachschlag.FieldByName('artikel_id').AsInteger)));
      memArtikelNachschlag.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      memArtikelNachschlag.GotoBookmark(LMerker);
      memArtikelNachschlag.FreeBookmark(LMerker);
    end;
    memArtikelNachschlag.EnableControls;
  end;
end;

procedure TdmArtikelStamm.VariantenAuswahlFuellen(AItems: TStrings);
var
  LMerker: TBookmark;
begin
  AItems.Clear;
  if not memVariante.Active then
    Exit;
  memVariante.DisableControls;
  LMerker := memVariante.GetBookmark;
  try
    memVariante.First;
    while not memVariante.Eof do
    begin
      AItems.AddObject(memVariante.FieldByName('name').AsString,
        TObject(NativeInt(memVariante.FieldByName('variante_id').AsInteger)));
      memVariante.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      memVariante.GotoBookmark(LMerker);
      memVariante.FreeBookmark(LMerker);
    end;
    memVariante.EnableControls;
  end;
end;

// ── Fotos ───────────────────────────────────────────────────────────────────
//
// Geschrieben wird ueber fn_artikel_foto_speichern. Die Funktion prueft, dass
// das Foto zum uebergebenen Artikel gehoert - ohne diese Pruefung hat ein
// falsch stehender Satzzeiger frueher das Bild eines FREMDEN Artikels
// ueberschrieben, und danach zeigten alle Artikel dasselbe Foto.

// == Baeume ==================================================================
//
// Alle drei entstehen im Speicher aus den Kopien, ohne eine einzige Abfrage.
// Gemeinsames Muster: eine lokale Funktion sammelt die Kinder eines Knotens
// und steigt ab. Der bereits begangene Pfad wird mitgefuehrt, damit ein
// Datenfehler (Ring) nicht zur Endlosschleife wird, sondern als Knoten mit
// IstZyklus sichtbar bleibt.

// Artikelnamen nachschlagen, ohne den Satzzeiger des Masters zu bewegen:
// ein Locate auf tblArtikel wuerde AfterScroll erneut ausloesen.
function TdmArtikelStamm.ArtikelName(AArtikelId: Integer;
  out ANummer: string): string;
begin
  Result := '';
  ANummer := '';
  if not memArtikelNachschlag.Active then
    Exit;
  if memArtikelNachschlag.Locate('artikel_id', AArtikelId, []) then
  begin
    ANummer := memArtikelNachschlag.FieldByName('artikel_nr').AsString;
    Result  := memArtikelNachschlag.FieldByName('artikelname').AsString;
  end;
end;

// Hat diese Variante ueberhaupt ein Elternteil? (child zeigt vom Kind zum
// Elternteil: von_id = Kind, nach_id = Elternteil.)
function TdmArtikelStamm.VarianteHatEltern(AVarianteId: Integer;
  out AElternId: Integer): Boolean;
var
  LMerker: TBookmark;
begin
  Result := False;
  AElternId := 0;
  if not memVarianteKante.Active then
    Exit;
  memVarianteKante.DisableControls;
  LMerker := memVarianteKante.GetBookmark;
  try
    memVarianteKante.First;
    while not memVarianteKante.Eof do
    begin
      if (memVarianteKante.FieldByName('bezug').AsString = 'child') and
         (memVarianteKante.FieldByName('von_id').AsInteger = AVarianteId) then
      begin
        AElternId := memVarianteKante.FieldByName('nach_id').AsInteger;
        Exit(True);
      end;
      memVarianteKante.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      memVarianteKante.GotoBookmark(LMerker);
      memVarianteKante.FreeBookmark(LMerker);
    end;
    memVarianteKante.EnableControls;
  end;
end;

function TdmArtikelStamm.StuecklisteBaum: TList<IBaumKnoten>;
var
  LWurzelId: Integer;
  LSpalten: TArray<string>;

  function Kinder(AArtikelId, AEbene: Integer;
    const APfad: TArray<Integer>): TList<IBaumKnoten>;
  var
    LMerker: TBookmark;
    LUnterId, I: Integer;
    LName, LNummer, LEinheit: string;
    LMenge: Double;
    LSpalten: TArray<string>;
    LZyklus: Boolean;
    LNeu: IBaumKnoten;
  begin
    Result := TList<IBaumKnoten>.Create;
    if not memArtikelArtikel.Active then
      Exit;

    memArtikelArtikel.DisableControls;
    LMerker := memArtikelArtikel.GetBookmark;
    try
      memArtikelArtikel.First;
      while not memArtikelArtikel.Eof do
      begin
        if memArtikelArtikel.FieldByName('artikel_id').AsInteger = AArtikelId then
        begin
          LUnterId := memArtikelArtikel.FieldByName('unter_artikel_id').AsInteger;
          LMenge   := memArtikelArtikel.FieldByName('menge').AsFloat;
          LName    := ArtikelName(LUnterId, LNummer);

          LEinheit := '';
          if not memArtikelArtikel.FieldByName('einheit_id').IsNull and
             memEinheit.Active then
            if memEinheit.Locate('einheit_id',
                 memArtikelArtikel.FieldByName('einheit_id').AsInteger, []) then
              LEinheit := memEinheit.FieldByName('name').AsString;

          // Kommt der Unterartikel im eigenen Pfad schon vor, ist es ein
          // Ring: anzeigen und NICHT weiter absteigen.
          LZyklus := False;
          for I := 0 to High(APfad) do
            if APfad[I] = LUnterId then
              LZyklus := True;

          SetLength(LSpalten, 3);
          LSpalten[0] := Trim(LNummer + ' ' + LName);
          LSpalten[1] := FormatFloat('0.###', LMenge);
          LSpalten[2] := LEinheit;

          LNeu := TBaumKnoten.Create(LUnterId, AArtikelId, AEbene, LSpalten,
                                     LZyklus, False);
          Result.Add(LNeu);
          if not LZyklus then
            LNeu.Kinder.AddRange(Kinder(LUnterId, AEbene + 1,
                                        APfad + [LUnterId]));
        end;
        memArtikelArtikel.Next;
      end;
    finally
      if Assigned(LMerker) then
      begin
        memArtikelArtikel.GotoBookmark(LMerker);
        memArtikelArtikel.FreeBookmark(LMerker);
      end;
      memArtikelArtikel.EnableControls;
    end;
  end;

begin
  Result := TList<IBaumKnoten>.Create;
  if tblArtikel.IsEmpty then
    Exit;
  LWurzelId := tblArtikel.FieldByName('artikel_id').AsInteger;
  Result.AddRange(Kinder(LWurzelId, 0, [LWurzelId]));

  // "+ Bestandteil..."-Platzhalter: an jeden vorhandenen Knoten einen, und
  // einen auf der obersten Ebene fuer den angezeigten Artikel selbst.
  // Darueber laeuft das Anhaengen im Baum (siehe TStuecklisteEditLink).
  PlatzhalterAnhaengen(Result, CPlatzhalterStueckliste);
  SetLength(LSpalten, 3);
  LSpalten[0] := CPlatzhalterStueckliste;
  LSpalten[1] := '';
  LSpalten[2] := '';
  Result.Add(TBaumKnoten.Create(0, LWurzelId, 0, LSpalten, False, True));
end;

function TdmArtikelStamm.VariantenBaum: TList<IBaumKnoten>;

  // AElternId 0 = Wurzelebene: alle Varianten ohne Elternteil.
  function Kinder(AElternId, AEbene: Integer;
    const APfad: TArray<Integer>): TList<IBaumKnoten>;
  var
    LMerker: TBookmark;
    LId, I, LEltern: Integer;
    LSpalten: TArray<string>;
    LZyklus, LGehoertHierher: Boolean;
    LNeu: IBaumKnoten;
  begin
    Result := TList<IBaumKnoten>.Create;
    if not memVariante.Active then
      Exit;

    memVariante.DisableControls;
    LMerker := memVariante.GetBookmark;
    try
      memVariante.First;
      while not memVariante.Eof do
      begin
        LId := memVariante.FieldByName('variante_id').AsInteger;
        if VarianteHatEltern(LId, LEltern) then
          LGehoertHierher := LEltern = AElternId
        else
          LGehoertHierher := AElternId = 0;

        if LGehoertHierher then
        begin
          LZyklus := False;
          for I := 0 to High(APfad) do
            if APfad[I] = LId then
              LZyklus := True;

          SetLength(LSpalten, 2);
          LSpalten[0] := memVariante.FieldByName('name').AsString;
          LSpalten[1] := memVariante.FieldByName('kurzzeichen').AsString;

          LNeu := TBaumKnoten.Create(LId, AElternId, AEbene, LSpalten,
                                     LZyklus, False);
          Result.Add(LNeu);
          if not LZyklus then
            LNeu.Kinder.AddRange(Kinder(LId, AEbene + 1, APfad + [LId]));
        end;
        memVariante.Next;
      end;
    finally
      if Assigned(LMerker) then
      begin
        memVariante.GotoBookmark(LMerker);
        memVariante.FreeBookmark(LMerker);
      end;
      memVariante.EnableControls;
    end;
  end;

begin
  Result := TList<IBaumKnoten>.Create;
  Result.AddRange(Kinder(0, 0, []));
end;

// Bestand: eine Zeile je Fach, genau im Format von fn_lagerort_bestand -
// nur eben im Speicher zusammengesetzt statt abgefragt. memLagerort liefert
// die Ortskette, tblArtikelFach den Bestand des angezeigten Artikels,
// memEinheit den Einheitennamen.
//
// Damit bleibt ArtikelBestandBaumData unveraendert nutzbar: Kapazitaet,
// Gesamtbestand und die "+ Neu..."-Platzhalter kommen von dort.
procedure TdmArtikelStamm.BestandZeilenBauen;
var
  LMerker: TBookmark;
begin
  if not memBestandZeilen.Active then
  begin
    memBestandZeilen.FieldDefs.Clear;
    memBestandZeilen.FieldDefs.Add('adresse_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('strasse', ftWideString, 200);
    memBestandZeilen.FieldDefs.Add('hausnummer', ftWideString, 50);
    memBestandZeilen.FieldDefs.Add('plz', ftWideString, 20);
    memBestandZeilen.FieldDefs.Add('ort', ftWideString, 200);
    memBestandZeilen.FieldDefs.Add('adressinfo_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('gebaeude_beschreibung', ftWideString, 200);
    memBestandZeilen.FieldDefs.Add('raum_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('raum_bezeichnung', ftWideString, 200);
    memBestandZeilen.FieldDefs.Add('regal_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('regal_bezeichnung', ftWideString, 200);
    memBestandZeilen.FieldDefs.Add('fach_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('fach_bezeichnung', ftWideString, 200);
    memBestandZeilen.FieldDefs.Add('fach_kapazitaet', ftFloat);
    memBestandZeilen.FieldDefs.Add('artikel_fach_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('bestand', ftFloat);
    memBestandZeilen.FieldDefs.Add('einheit_id', ftInteger);
    memBestandZeilen.FieldDefs.Add('einheit_name', ftWideString, 100);
    memBestandZeilen.CreateDataSet;
  end;

  memBestandZeilen.DisableControls;
  try
    memBestandZeilen.EmptyDataSet;
    if not memLagerort.Active then
      Exit;

    memLagerort.DisableControls;
    LMerker := memLagerort.GetBookmark;
    try
      memLagerort.First;
      while not memLagerort.Eof do
      begin
        memBestandZeilen.Append;
        memBestandZeilen.FieldByName('adresse_id').AsInteger :=
          memLagerort.FieldByName('adresse_id').AsInteger;
        memBestandZeilen.FieldByName('strasse').AsString :=
          memLagerort.FieldByName('strasse').AsString;
        memBestandZeilen.FieldByName('hausnummer').AsString :=
          memLagerort.FieldByName('hausnummer').AsString;
        memBestandZeilen.FieldByName('plz').AsString :=
          memLagerort.FieldByName('plz').AsString;
        memBestandZeilen.FieldByName('ort').AsString :=
          memLagerort.FieldByName('ort').AsString;
        memBestandZeilen.FieldByName('adressinfo_id').AsInteger :=
          memLagerort.FieldByName('adressinfo_id').AsInteger;
        memBestandZeilen.FieldByName('gebaeude_beschreibung').AsString :=
          memLagerort.FieldByName('gebaeude_beschreibung').AsString;
        memBestandZeilen.FieldByName('raum_id').AsInteger :=
          memLagerort.FieldByName('raum_id').AsInteger;
        memBestandZeilen.FieldByName('raum_bezeichnung').AsString :=
          memLagerort.FieldByName('raum_bezeichnung').AsString;
        memBestandZeilen.FieldByName('regal_id').AsInteger :=
          memLagerort.FieldByName('regal_id').AsInteger;
        memBestandZeilen.FieldByName('regal_bezeichnung').AsString :=
          memLagerort.FieldByName('regal_bezeichnung').AsString;
        memBestandZeilen.FieldByName('fach_id').AsInteger :=
          memLagerort.FieldByName('fach_id').AsInteger;
        memBestandZeilen.FieldByName('fach_bezeichnung').AsString :=
          memLagerort.FieldByName('fach_bezeichnung').AsString;
        if not memLagerort.FieldByName('fach_kapazitaet').IsNull then
          memBestandZeilen.FieldByName('fach_kapazitaet').AsFloat :=
            memLagerort.FieldByName('fach_kapazitaet').AsFloat;
        memBestandZeilen.FieldByName('einheit_name').AsString :=
          memLagerort.FieldByName('fach_einheit_name').AsString;

        // Der Bestand des ANGEZEIGTEN Artikels in diesem Fach.
        if tblArtikelFach.Active and
           tblArtikelFach.Locate('fach_id',
             memLagerort.FieldByName('fach_id').AsInteger, []) then
        begin
          memBestandZeilen.FieldByName('artikel_fach_id').AsInteger :=
            tblArtikelFach.FieldByName('artikel_fach_id').AsInteger;
          memBestandZeilen.FieldByName('bestand').AsFloat :=
            tblArtikelFach.FieldByName('bestand').AsFloat;
          if not tblArtikelFach.FieldByName('einheit_id').IsNull then
          begin
            memBestandZeilen.FieldByName('einheit_id').AsInteger :=
              tblArtikelFach.FieldByName('einheit_id').AsInteger;
            if memEinheit.Active and memEinheit.Locate('einheit_id',
                 tblArtikelFach.FieldByName('einheit_id').AsInteger, []) then
              memBestandZeilen.FieldByName('einheit_name').AsString :=
                memEinheit.FieldByName('name').AsString;
          end;
        end;
        memBestandZeilen.Post;
        memLagerort.Next;
      end;
    finally
      if Assigned(LMerker) then
      begin
        memLagerort.GotoBookmark(LMerker);
        memLagerort.FreeBookmark(LMerker);
      end;
      memLagerort.EnableControls;
    end;

    // BaueBestandBaum erwartet die Sortierung der Datenbankfunktion.
    memBestandZeilen.IndexFieldNames :=
      'adresse_id;adressinfo_id;raum_id;regal_id;fach_id';
    memBestandZeilen.First;
  finally
    memBestandZeilen.EnableControls;
  end;
end;

function TdmArtikelStamm.BestandBaum: TList<IBestandKnoten>;
begin
  BestandZeilenBauen;
  Result := BaueBestandBaum(memBestandZeilen);
end;

// ── Lagerort anlegen (aus dem Bestandbaum heraus) ───────────────────────────

function TdmArtikelStamm.HauptpersonVorhanden(AMandantId: Integer): Boolean;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance)
              .SpAufrufen('fn_hat_hauptperson', [AMandantId]) = True;
end;

// Adressen der Hauptperson dieses Mandanten. Der Schluessel haengt an
// Items.Objects. Gelesen wird aus den Kopien, ohne eigene Abfrage.
procedure TdmArtikelStamm.LadeHauptpersonAdressen(AMandantId: Integer;
  AItems: TStrings);
var
  LPersonId, LAdresseId: Integer;
  LMerker: TBookmark;
  LText: string;
begin
  AItems.Clear;
  if not (memPersonMandant.Active and memPersonAdresse.Active and
          memAdresse.Active) then
    Exit;

  // Die Hauptperson des Mandanten.
  LPersonId := 0;
  memPersonMandant.DisableControls;
  LMerker := memPersonMandant.GetBookmark;
  try
    memPersonMandant.First;
    while not memPersonMandant.Eof do
    begin
      if (memPersonMandant.FieldByName('mandant_id').AsInteger = AMandantId) and
         memPersonMandant.FieldByName('ist_hauptperson').AsBoolean then
      begin
        LPersonId := memPersonMandant.FieldByName('person_id').AsInteger;
        Break;
      end;
      memPersonMandant.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      memPersonMandant.GotoBookmark(LMerker);
      memPersonMandant.FreeBookmark(LMerker);
    end;
    memPersonMandant.EnableControls;
  end;
  if LPersonId = 0 then
    Exit;

  // Ihre Adressen.
  memPersonAdresse.DisableControls;
  LMerker := memPersonAdresse.GetBookmark;
  try
    memPersonAdresse.First;
    while not memPersonAdresse.Eof do
    begin
      if memPersonAdresse.FieldByName('person_id').AsInteger = LPersonId then
      begin
        LAdresseId := memPersonAdresse.FieldByName('adresse_id').AsInteger;
        if memAdresse.Locate('adresse_id', LAdresseId, []) then
        begin
          LText := Trim(memAdresse.FieldByName('strasse').AsString + ' ' +
                        memAdresse.FieldByName('hausnummer').AsString + ', ' +
                        memAdresse.FieldByName('plz').AsString + ' ' +
                        memAdresse.FieldByName('ort').AsString);
          AItems.AddObject(LText, TObject(NativeInt(LAdresseId)));
        end;
      end;
      memPersonAdresse.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      memPersonAdresse.GotoBookmark(LMerker);
      memPersonAdresse.FreeBookmark(LMerker);
    end;
    memPersonAdresse.EnableControls;
  end;
end;

procedure TdmArtikelStamm.LadeRaeumeFuerAdresse(AAdresseId: Integer;
  AItems: TStrings);
var
  LMerker: TBookmark;
begin
  AItems.Clear;
  if not memRaum.Active then
    Exit;
  memRaum.DisableControls;
  LMerker := memRaum.GetBookmark;
  try
    memRaum.First;
    while not memRaum.Eof do
    begin
      if memRaum.FieldByName('adresse_id').AsInteger = AAdresseId then
        AItems.AddObject(memRaum.FieldByName('bezeichnung').AsString,
          TObject(NativeInt(memRaum.FieldByName('raum_id').AsInteger)));
      memRaum.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      memRaum.GotoBookmark(LMerker);
      memRaum.FreeBookmark(LMerker);
    end;
    memRaum.EnableControls;
  end;
end;

function TdmArtikelStamm.NeueAdresseFuerHauptperson(AMandantId: Integer;
  const AStrasse, AHausnummer, APlz, AOrt: string): Integer;
begin
  // Adresse, Verknuepfung zur Hauptperson und Lager-Eintrag in einem Rutsch -
  // entweder alle drei oder keiner.
  Result := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufen('fn_adresse_fuer_hauptperson',
      [AMandantId, AStrasse, AHausnummer, APlz, AOrt]));
  NachladenOrte;
end;

// Eine schon vorhandene Adresse als Lagerort fuehren.
procedure TdmArtikelStamm.EnsureAlsLagerMarkiert(AMandantId, AAdresseId: Integer);
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen('fn_lager_speichern',
    [0, AMandantId, AAdresseId, Null, Null, Null,
     'Aus dem Bestandbaum als Lagerort uebernommen']);
  NachladenOrte;
end;

function TdmArtikelStamm.NeuerRaum(AAdresseId: Integer;
  const ABezeichnung: string): Integer;
begin
  Result := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufen('fn_raum_speichern', [0, AAdresseId, Null, ABezeichnung]));
  NachladenOrte;
end;

// Ein Regal ohne Fach waere im Baum unsichtbar (v_lagerort fuehrt eine Zeile
// je FACH). Deshalb entsteht gleich ein "Fach 1" mit.
function TdmArtikelStamm.NeuesRegal(ARaumId: Integer;
  const ABezeichnung: string): Integer;
var
  LZentral: TdmZentraleDaten;
begin
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  Result := AlsZahl(LZentral.SpAufrufen('fn_regal_speichern',
    [0, ARaumId, ABezeichnung]));
  if Result > 0 then
    LZentral.SpAufrufen('fn_regal_fach_speichern',
      [0, FMandantId, Result, 'Fach 1']);
  NachladenOrte;
end;

// Nach jeder Neuanlage: die Ortskopien und die Sicht nachziehen.
procedure TdmArtikelStamm.NachladenOrte;
var
  LZentral: TdmZentraleDaten;
  LMandant: string;
begin
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  LMandant := 'mandant_id = ' + IntToStr(FMandantId);
  LZentral.TabelleAuffrischen('adresse');
  LZentral.TabelleAuffrischen('raum');
  LZentral.TabelleAuffrischen('regal');
  LZentral.TabelleAuffrischen('regal_fach');
  LZentral.TabelleAuffrischen('lager');
  LZentral.TabelleAuffrischen('person_adresse');
  Kopiere(memAdresse, 'adresse');
  Kopiere(memRaum, 'raum');
  Kopiere(memRegal, 'regal');
  Kopiere(memPersonAdresse, 'person_adresse', LMandant);
  Kopiere(memLagerort, 'v_lagerort', LMandant);
end;

// ── Fotos ───────────────────────────────────────────────────────────────────
//
// Geschrieben wird ueber fn_artikel_foto_speichern. Die Funktion prueft, dass
// das Foto zum uebergebenen Artikel gehoert - ohne diese Pruefung hat ein
// falsch stehender Satzzeiger frueher das Bild eines FREMDEN Artikels
// ueberschrieben, und danach zeigten alle Artikel dasselbe Foto.

function TdmArtikelStamm.FotoAnhaengen(const ADatei,
  ABeschreibung: string): Integer;
var
  LBytes: TBytes;
  LBeschreibung: Variant;
begin
  Result := 0;
  if tblArtikel.IsEmpty or (ADatei = '') then
    Exit;

  LBytes := TFile.ReadAllBytes(ADatei);
  if Trim(ABeschreibung) = '' then
    LBeschreibung := Null
  else
    LBeschreibung := ABeschreibung;

  // foto_id 0 heisst anlegen. Mit Datei wird nie geaendert - ein vorhandenes
  // Bild ueberschreibt man nicht versehentlich.
  Result := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufenBlob('fn_artikel_foto_speichern',
      [FMandantId, tblArtikel.FieldByName('artikel_id').AsInteger, 0,
       Null, LBeschreibung, Null], 3, LBytes));

  FotosNachladen(Result);
end;

function TdmArtikelStamm.FotoTextSpeichern(AFotoId: Integer;
  const ABeschreibung: string; AReihenfolge: Integer): string;
var
  LBeschreibung, LReihenfolge: Variant;
begin
  Result := '';
  if (AFotoId <= 0) or tblArtikel.IsEmpty then
    Exit('Es ist kein gespeichertes Foto angezeigt.');

  if Trim(ABeschreibung) = '' then
    LBeschreibung := Null
  else
    LBeschreibung := ABeschreibung;
  if AReihenfolge <= 0 then
    LReihenfolge := Null
  else
    LReihenfolge := AReihenfolge;

  try
    // Ohne Bild: die Funktion laesst das vorhandene stehen (COALESCE).
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_artikel_foto_speichern',
      [FMandantId, tblArtikel.FieldByName('artikel_id').AsInteger, AFotoId,
       Null, LBeschreibung, LReihenfolge]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;

  FotosNachladen(AFotoId);
end;

procedure TdmArtikelStamm.FotoLoeschen(AFotoId: Integer);
begin
  if AFotoId <= 0 then
    Exit;
  TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufen('fn_artikel_foto_loeschen', [AFotoId, FMandantId]);
  FotosNachladen(0);
end;

// Jede Datei wird vorher geoeffnet: was TPicture nicht lesen kann, darf gar
// nicht erst in die Datenbank. Ein Blob, das kein darstellbares Bild ist,
// laesst das Fenster beim naechsten Zeichnen mit EInvalidGraphic fliegen.
function TdmArtikelStamm.FotosAusDateien(const ADateien: TArray<string>;
  out AUebersprungen: TArray<string>): Integer;
var
  LDatei: string;
  LProbe: TPicture;
  LLetzte: Integer;
begin
  Result := 0;
  LLetzte := 0;
  SetLength(AUebersprungen, 0);
  if tblArtikel.IsEmpty then
    Exit;

  for LDatei in ADateien do
  begin
    if not TFile.Exists(LDatei) then
    begin
      AUebersprungen := AUebersprungen + [LDatei];
      Continue;
    end;

    LProbe := TPicture.Create;
    try
      try
        LProbe.LoadFromFile(LDatei);
      except
        // Kein lesbares Bild - merken und weitermachen, nicht abbrechen.
        AUebersprungen := AUebersprungen + [LDatei];
        Continue;
      end;
    finally
      LProbe.Free;
    end;

    LLetzte := FotoAnhaengen(LDatei,
                             TPath.GetFileNameWithoutExtension(LDatei));
    if LLetzte > 0 then
      Inc(Result);
  end;

  if LLetzte > 0 then
    FotosNachladen(LLetzte);
end;

procedure TdmArtikelStamm.FotosNachladen(AFotoId: Integer);
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).TabelleAuffrischen('artikel_foto');
  Kopiere(tblArtikelFoto, 'artikel_foto',
          'mandant_id = ' + IntToStr(FMandantId));
  FotoTextEinrichten;
  if (AFotoId > 0) and tblArtikelFoto.Active then
    tblArtikelFoto.Locate('foto_id', AFotoId, []);
end;

// Die Felder entstehen bei jedem Kopieren neu - der Handler muss danach
// wieder gesetzt werden.
procedure TdmArtikelStamm.FotoTextEinrichten;
var
  LFeld: TField;
begin
  if not tblArtikelFoto.Active then
    Exit;
  LFeld := tblArtikelFoto.FindField('beschreibung');
  if Assigned(LFeld) then
    LFeld.OnGetText := FotoBeschreibungGetText;
end;

// beschreibung ist ein TEXT-Feld, also ein Memofeld - ein DBGrid schreibt
// dafuer sonst "(WideMemo)" statt des Inhalts.
procedure TdmArtikelStamm.FotoBeschreibungGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := Sender.AsString;
  if not DisplayText then
    Exit;
  // Eine Zeile daraus machen: im Gitter ist nur eine Zeile Platz.
  Text := StringReplace(Text, #13#10, ' ', [rfReplaceAll]);
  Text := StringReplace(Text, #10, ' ', [rfReplaceAll]);
  if Length(Text) > 60 then
    Text := Copy(Text, 1, 57) + '...';
end;

// ── Kategorien ──────────────────────────────────────────────────────────────

procedure TdmArtikelStamm.KategorienFuellen(AItems: TStrings);
var
  LMerker: TBookmark;
begin
  AItems.Clear;
  if not tblKategorie.Active then
    Exit;

  tblKategorie.DisableControls;
  LMerker := tblKategorie.GetBookmark;
  try
    tblKategorie.First;
    while not tblKategorie.Eof do
    begin
      AItems.AddObject(tblKategorie.FieldByName('bezeichnung').AsString,
        TObject(NativeInt(tblKategorie.FieldByName('kategorie_id').AsInteger)));
      tblKategorie.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      tblKategorie.GotoBookmark(LMerker);
      tblKategorie.FreeBookmark(LMerker);
    end;
    tblKategorie.EnableControls;
  end;
end;

function TdmArtikelStamm.IstZugeordnet(AKategorieId: Integer): Boolean;
var
  LArtikel: Integer;
begin
  Result := False;
  if not (tblArtikelKategorie.Active and tblArtikel.Active) or
     tblArtikel.IsEmpty then
    Exit;
  LArtikel := tblArtikel.FieldByName('artikel_id').AsInteger;
  // Locate auf der Bruecke, nicht auf tblArtikel: dessen Satzzeiger waehlt
  // den angezeigten Artikel und darf sich hier nicht bewegen.
  Result := tblArtikelKategorie.Locate('artikel_id;kategorie_id',
              VarArrayOf([LArtikel, AKategorieId]), []);
end;

function TdmArtikelStamm.KategorieSetzen(AKategorieId: Integer;
  AZuordnen: Boolean): string;
var
  LZentral: TdmZentraleDaten;
  LArtikel: Integer;
begin
  Result := '';
  if tblArtikel.IsEmpty then
    Exit('Es ist kein Artikel angezeigt.');
  LArtikel := tblArtikel.FieldByName('artikel_id').AsInteger;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    LZentral.SpAufrufen('fn_artikel_kategorie_setzen',
      [LArtikel, AKategorieId, AZuordnen]);
  except
    on E: Exception do
      Exit(FehlerKlartext(E));
  end;

  // Nur die Bruecke nachziehen - der Rest hat sich nicht geaendert.
  LZentral.TabelleAuffrischen('artikel_kategorie');
  Kopiere(tblArtikelKategorie, 'artikel_kategorie');
end;

// Einstieg ueber den MessageHandler: OpenGui('ArtikelStamm') postet
// mtModulCall an 'TdmArtikelStamm'/'OpenArtikelStamm', der Handler holt die
// Instanz ueber GetInstance und ruft hier herein.
procedure TdmArtikelStamm.OpenArtikelStamm;
begin
  if not TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung.Connected then
  begin
    ShowMessage('Bitte zuerst im PGManager die Datenbankverbindung herstellen.', '');
    Exit;
  end;

  // Beim ersten Oeffnen kann der Broadcast laengst durch sein - dann sind
  // die Kopien noch leer und werden hier nachgeholt.
  // Immer nachladen: der Mandant kann seit dem Broadcast gewechselt haben,
  // und dann stehen in den Kopien die Daten des falschen.
  DatenGeladen;

  if FMandantId <= 0 then
  begin
    ShowMessage('Bitte zuerst oben im Hauptfenster einen Mandanten w'#228'hlen.', '');
    Exit;
  end;

  if not Assigned(frmArtikelStamm) then
    Application.CreateForm(TfrmArtikelStamm, frmArtikelStamm);
  frmArtikelStamm.Show;
end;

initialization
  // Persistente Felder im DFM: der Reader sucht die Feldklassen im
  // Klassenregister. Zur Laufzeit meldet die niemand an - das tut sonst nur
  // die IDE. Ohne diese Zeile: "Klasse TIntegerField nicht gefunden".
  RegisterClasses([TIntegerField, TWideStringField]);
  GSperreArtikelStamm := TCriticalSection.Create;

finalization
  GSperreArtikelStamm.Free;

end.
