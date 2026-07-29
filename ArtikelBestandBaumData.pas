unit ArtikelBestandBaumData;

// Knotendaten fuer den Bestand-Baum (VirtualStringTree) im ArtikelStamm-Modul.
// Hierarchie: Adresse -> Gebaeude/Eingang -> Raum -> Regal -> Fach.
// Interfaced statt Record/Objekt-mit-Free: VST verwaltet die Lebensdauer der
// Knoten selbst (Node.SetData/OnFreeNode raeumt per Refcounting auf), siehe
// Virtual-TreeView\Demos\Interfaces\myeventdata.pas als Vorlage.
//
// Datenquelle: fn_lagerort_bestand(p_artikel_id) (sql\fn_lagerort_bestand.sql)
// -- eine Zeile je Fach, mit allen Ebenen-Feldern wiederholt (klassisches
// flaches Join-Ergebnis). BaueBestandBaum gruppiert das per Control-Break
// (die Function liefert bereits sortiert nach adresse/gebaeude/raum/regal/fach).
//
// bkNeuEintrag (25.07.2026, Phase 2 Ueberarbeitung): synthetische "+ Neu..."
// Platzhalterknoten, je einer als letztes Kind von Wurzel/Adresse/Raum, damit
// man ueber den VirtualStringTree-EditLink (ComboBox statt Rechtsklick-Menue,
// siehe ArtikelStammFrm) direkt einen neuen Standort/Raum/Regal anlegen kann.
// ZielArt sagt, WAS der Platzhalter anlegt; ElternId ist die dafuer noetige
// Eltern-ID (adresse_id fuer einen neuen Raum, raum_id fuer ein neues Regal;
// bei einer neuen Adresse ungenutzt/0).

interface

uses
  System.Generics.Collections, Data.DB;

type
  TBestandKnotenArt = (bkAdresse, bkGebaeude, bkRaum, bkRegal, bkFach, bkNeuEintrag);

  IBestandKnoten = interface
    ['{B4E2B7B0-6E4A-4C1E-9C4A-2E1D6F6E9A31}']
    function GetArt: TBestandKnotenArt;
    function GetAnzeigeText: string;
    function GetKinder: TList<IBestandKnoten>;
    // Eigene DB-ID auf Adresse-/Raum-/Regal-Ebene (adresse_id/raum_id/regal_id).
    function GetEigeneId: Integer;
    // Nur auf Fach-Ebene gefuellt:
    function GetFachId: Integer;
    function GetArtikelFachId: Integer;
    function GetHatBestand: Boolean;
    function GetBestand: Double;
    function GetEinheitId: Integer;
    function GetKapazitaet: Double;
    function GetHatKapazitaet: Boolean;
    // Nur auf bkNeuEintrag-Platzhaltern gefuellt:
    function GetZielArt: TBestandKnotenArt;
    function GetElternId: Integer;
    // Summe von Bestand ueber alle Fach-Nachfahren -- fuer Spalte 2, die
    // Walter NUR bei Adresse/Raum angezeigt haben will (siehe ArtikelStammFrm
    // vstBestandGetText). Wird fuer JEDEN Knoten berechnet (billig), aber nur
    // fuer diese zwei Ebenen tatsaechlich dargestellt.
    function GetGesamtBestand: Double;

    property Art: TBestandKnotenArt read GetArt;
    property AnzeigeText: string read GetAnzeigeText;
    property Kinder: TList<IBestandKnoten> read GetKinder;
    property EigeneId: Integer read GetEigeneId;
    property FachId: Integer read GetFachId;
    property ArtikelFachId: Integer read GetArtikelFachId;
    property HatBestand: Boolean read GetHatBestand;
    property Bestand: Double read GetBestand;
    property EinheitId: Integer read GetEinheitId;
    // regal_fach.kapazitaet -- Warnschwelle fuers manuelle Einbuchen (Phase 2),
    // KEINE harte Sperre (Walters Vorgabe: kurzfristig ueberschreitbar).
    property Kapazitaet: Double read GetKapazitaet;
    property HatKapazitaet: Boolean read GetHatKapazitaet;
    property ZielArt: TBestandKnotenArt read GetZielArt;
    property ElternId: Integer read GetElternId;
    property GesamtBestand: Double read GetGesamtBestand;
  end;

  TBestandKnoten = class(TInterfacedObject, IBestandKnoten)
  private
    FArt: TBestandKnotenArt;
    FAnzeigeText: string;
    FKinder: TList<IBestandKnoten>;
    FEigeneId: Integer;
    FFachId: Integer;
    FArtikelFachId: Integer;
    FHatBestand: Boolean;
    FBestand: Double;
    FEinheitId: Integer;
    FKapazitaet: Double;
    FHatKapazitaet: Boolean;
    FZielArt: TBestandKnotenArt;
    FElternId: Integer;
    FGesamtBestand: Double;
  protected
    function GetArt: TBestandKnotenArt;
    function GetAnzeigeText: string;
    function GetKinder: TList<IBestandKnoten>;
    function GetEigeneId: Integer;
    function GetFachId: Integer;
    function GetArtikelFachId: Integer;
    function GetHatBestand: Boolean;
    function GetBestand: Double;
    function GetEinheitId: Integer;
    function GetKapazitaet: Double;
    function GetHatKapazitaet: Boolean;
    function GetZielArt: TBestandKnotenArt;
    function GetElternId: Integer;
    function GetGesamtBestand: Double;
  public
    constructor Create(AArt: TBestandKnotenArt; const AAnzeigeText: string);
    destructor Destroy; override;
  end;

// Baut die Baumstruktur (Liste der Wurzelknoten = Adressen) aus dem bereits
// geoeffneten fn_lagerort_bestand-Ergebnis, inkl. "+ Neu..."-Platzhaltern.
// ADataSet muss sortiert sein nach adresse_id, adressinfo_id, raum_id,
// regal_id, fach_id (die Function liefert das schon so).
function BaueBestandBaum(ADataSet: TDataSet): TList<IBestandKnoten>;

implementation

uses
  System.SysUtils, System.Variants;

{ TBestandKnoten }

constructor TBestandKnoten.Create(AArt: TBestandKnotenArt; const AAnzeigeText: string);
begin
  inherited Create;
  FArt := AArt;
  FAnzeigeText := AAnzeigeText;
  FKinder := TList<IBestandKnoten>.Create;
end;

destructor TBestandKnoten.Destroy;
begin
  FKinder.Free;
  inherited;
end;

function TBestandKnoten.GetArt: TBestandKnotenArt;
begin
  Result := FArt;
end;

function TBestandKnoten.GetAnzeigeText: string;
begin
  Result := FAnzeigeText;
end;

function TBestandKnoten.GetKinder: TList<IBestandKnoten>;
begin
  Result := FKinder;
end;

function TBestandKnoten.GetEigeneId: Integer;
begin
  Result := FEigeneId;
end;

function TBestandKnoten.GetFachId: Integer;
begin
  Result := FFachId;
end;

function TBestandKnoten.GetArtikelFachId: Integer;
begin
  Result := FArtikelFachId;
end;

function TBestandKnoten.GetHatBestand: Boolean;
begin
  Result := FHatBestand;
end;

function TBestandKnoten.GetBestand: Double;
begin
  Result := FBestand;
end;

function TBestandKnoten.GetEinheitId: Integer;
begin
  Result := FEinheitId;
end;

function TBestandKnoten.GetKapazitaet: Double;
begin
  Result := FKapazitaet;
end;

function TBestandKnoten.GetHatKapazitaet: Boolean;
begin
  Result := FHatKapazitaet;
end;

function TBestandKnoten.GetZielArt: TBestandKnotenArt;
begin
  Result := FZielArt;
end;

function TBestandKnoten.GetElternId: Integer;
begin
  Result := FElternId;
end;

function TBestandKnoten.GetGesamtBestand: Double;
begin
  Result := FGesamtBestand;
end;

// Formatiert die Fach-Anzeige inkl. Bestand/Einheit, oder "leer", wenn der
// aktuelle Artikel dort noch keinen Bestand hat (artikel_fach_id ist NULL).
function FormatFachText(ADataSet: TDataSet): string;
var
  LBezeichnung, LEinheit: string;
begin
  LBezeichnung := ADataSet.FieldByName('fach_bezeichnung').AsString;
  if ADataSet.FieldByName('artikel_fach_id').IsNull then
    Exit(Format('%s — leer', [LBezeichnung]));

  LEinheit := ADataSet.FieldByName('einheit_name').AsString;
  if LEinheit = '' then
    Result := Format('%s — %s', [LBezeichnung,
      FormatFloat('0.###', ADataSet.FieldByName('bestand').AsFloat)])
  else
    Result := Format('%s — %s %s', [LBezeichnung,
      FormatFloat('0.###', ADataSet.FieldByName('bestand').AsFloat), LEinheit]);
end;

function NeuPlatzhalter(const AText: string; AZielArt: TBestandKnotenArt;
  AElternId: Integer): TBestandKnoten;
begin
  Result := TBestandKnoten.Create(bkNeuEintrag, AText);
  Result.FZielArt := AZielArt;
  Result.FElternId := AElternId;
end;

// Entfernt rekursiv alle Zweige, die fuer den aktuellen Artikel keinen
// Bestand haben (Walters Wunsch: nur Orte zeigen, wo der Artikel tatsaechlich
// liegt, statt jedes leere Fach im ganzen Lager mitzuschleppen). Laeuft VOR
// FuegeNeuEintraegeHinzu -- die "+ Neu..."-Platzhalter bleiben davon
// unberuehrt und stehen weiterhin an jeder (verbliebenen) Adresse/jedem Raum
// zur Verfuegung, ausserdem immer an der Wurzel ("+ Neue Adresse...").
function HatBestandImUnterbaum(AKnoten: IBestandKnoten): Boolean;
var
  I: Integer;
begin
  if AKnoten.Art = bkFach then
    Exit(AKnoten.HatBestand);
  Result := False;
  for I := AKnoten.Kinder.Count - 1 downto 0 do
    if HatBestandImUnterbaum(AKnoten.Kinder[I]) then
      Result := True
    else
      AKnoten.Kinder.Delete(I);
end;

procedure EntferneLeereZweige(AWurzeln: TList<IBestandKnoten>);
var
  I: Integer;
begin
  for I := AWurzeln.Count - 1 downto 0 do
    if not HatBestandImUnterbaum(AWurzeln[I]) then
      AWurzeln.Delete(I);
end;

// Summiert Bestand ueber alle Fach-Nachfahren und traegt das Ergebnis in
// FGesamtBestand ein (Cast auf TBestandKnoten, da dieselbe Unit). Wird fuer
// jeden Knoten berechnet, angezeigt aber nur fuer Adresse/Raum (Walters
// Vorgabe, siehe ArtikelStammFrm.vstBestandGetText). Muss NACH
// EntferneLeereZweige und VOR FuegeNeuEintraegeHinzu laufen (die "+ Neu..."-
// Platzhalter sollen nicht mitgezaehlt werden -- sie haben ohnehin keine
// Kinder, tragen also 0 bei, aber sauberer, sie erst danach anzuhaengen).
function BerechneGesamtbestand(AKnoten: IBestandKnoten): Double;
var
  I: Integer;
begin
  if AKnoten.Art = bkFach then
  begin
    if AKnoten.HatBestand then
      Result := AKnoten.Bestand
    else
      Result := 0;
  end
  else
  begin
    Result := 0;
    for I := 0 to AKnoten.Kinder.Count - 1 do
      Result := Result + BerechneGesamtbestand(AKnoten.Kinder[I]);
  end;
  (AKnoten as TBestandKnoten).FGesamtBestand := Result;
end;

// Haengt "+ Neu..."-Platzhalter an: einen fuer eine neue Adresse an der
// Wurzel, je einen fuer einen neuen Raum an jeder Adresse, je einen fuer ein
// neues Regal an jedem Raum. Kein Platzhalter fuer neue Faecher -- das bleibt
// Aufgabe des Lager-Moduls (Faecher-Tab), hier wird nur Bestand eingetragen.
procedure FuegeNeuEintraegeHinzu(AWurzeln: TList<IBestandKnoten>);
var
  LAdresse, LGebaeude, LRaum: IBestandKnoten;
begin
  AWurzeln.Add(NeuPlatzhalter('+ Neue Adresse...', bkAdresse, 0));

  for LAdresse in AWurzeln do
  begin
    if LAdresse.Art <> bkAdresse then
      Continue;
    LAdresse.Kinder.Add(NeuPlatzhalter('+ Neuer Raum...', bkRaum, LAdresse.EigeneId));

    for LGebaeude in LAdresse.Kinder do
    begin
      if LGebaeude.Art <> bkGebaeude then
        Continue;
      for LRaum in LGebaeude.Kinder do
      begin
        if LRaum.Art <> bkRaum then
          Continue;
        LRaum.Kinder.Add(NeuPlatzhalter('+ Neues Regal...', bkRegal, LRaum.EigeneId));
      end;
    end;
  end;
end;

function BaueBestandBaum(ADataSet: TDataSet): TList<IBestandKnoten>;
var
  LWurzeln: TList<IBestandKnoten>;
  LAktAdresse, LAktGebaeude, LAktRaum, LAktRegal: IBestandKnoten;
  LLetzteAdresseId, LLetzteGebaeudeId, LLetzteRaumId, LLetzteRegalId: Variant;
  LAdresseId, LGebaeudeId, LRaumId, LRegalId: Variant;
  LFach: TBestandKnoten;
  LNeuAdresse, LNeuRaum, LNeuRegal: TBestandKnoten;
begin
  LWurzeln := TList<IBestandKnoten>.Create;

  LLetzteAdresseId  := Null;
  LLetzteGebaeudeId := Null;
  LLetzteRaumId     := Null;
  LLetzteRegalId    := Null;

  ADataSet.First;
  while not ADataSet.Eof do
  begin
    LAdresseId  := ADataSet.FieldByName('adresse_id').Value;
    LGebaeudeId := ADataSet.FieldByName('adressinfo_id').Value;   // darf NULL sein
    LRaumId     := ADataSet.FieldByName('raum_id').Value;
    LRegalId    := ADataSet.FieldByName('regal_id').Value;

    if (LAktAdresse = nil) or (LAdresseId <> LLetzteAdresseId) then
    begin
      LNeuAdresse := TBestandKnoten.Create(bkAdresse, Format('%s %s, %s %s',
        [ADataSet.FieldByName('strasse').AsString, ADataSet.FieldByName('hausnummer').AsString,
         ADataSet.FieldByName('plz').AsString, ADataSet.FieldByName('ort').AsString]));
      LNeuAdresse.FEigeneId := ADataSet.FieldByName('adresse_id').AsInteger;
      LAktAdresse := LNeuAdresse;
      LWurzeln.Add(LAktAdresse);
      LLetzteAdresseId := LAdresseId;
      // neue Adresse -> alle darunterliegenden Ebenen erzwingen Neuaufbau
      LLetzteGebaeudeId := Null;
      LLetzteRaumId := Null;
      LLetzteRegalId := Null;
      LAktGebaeude := nil;
      LAktRaum := nil;
      LAktRegal := nil;
    end;

    if (LAktGebaeude = nil) or (VarToStrDef(LGebaeudeId, '') <> VarToStrDef(LLetzteGebaeudeId, '')) then
    begin
      if ADataSet.FieldByName('adressinfo_id').IsNull then
        LAktGebaeude := TBestandKnoten.Create(bkGebaeude, '(kein Eingang angegeben)')
      else
        LAktGebaeude := TBestandKnoten.Create(bkGebaeude, ADataSet.FieldByName('gebaeude_beschreibung').AsString);
      LAktAdresse.Kinder.Add(LAktGebaeude);
      LLetzteGebaeudeId := LGebaeudeId;
      LLetzteRaumId := Null;
      LLetzteRegalId := Null;
      LAktRaum := nil;
      LAktRegal := nil;
    end;

    if (LAktRaum = nil) or (LRaumId <> LLetzteRaumId) then
    begin
      LNeuRaum := TBestandKnoten.Create(bkRaum, ADataSet.FieldByName('raum_bezeichnung').AsString);
      LNeuRaum.FEigeneId := ADataSet.FieldByName('raum_id').AsInteger;
      LAktRaum := LNeuRaum;
      LAktGebaeude.Kinder.Add(LAktRaum);
      LLetzteRaumId := LRaumId;
      LLetzteRegalId := Null;
      LAktRegal := nil;
    end;

    if (LAktRegal = nil) or (LRegalId <> LLetzteRegalId) then
    begin
      LNeuRegal := TBestandKnoten.Create(bkRegal, ADataSet.FieldByName('regal_bezeichnung').AsString);
      LNeuRegal.FEigeneId := ADataSet.FieldByName('regal_id').AsInteger;
      LAktRegal := LNeuRegal;
      LAktRaum.Kinder.Add(LAktRegal);
      LLetzteRegalId := LRegalId;
    end;

    // Fach-Blatt: eine Zeile im Ergebnis = genau ein Fach
    LFach := TBestandKnoten.Create(bkFach, FormatFachText(ADataSet));
    LFach.FFachId := ADataSet.FieldByName('fach_id').AsInteger;
    if not ADataSet.FieldByName('fach_kapazitaet').IsNull then
    begin
      LFach.FHatKapazitaet := True;
      LFach.FKapazitaet := ADataSet.FieldByName('fach_kapazitaet').AsFloat;
    end;
    if not ADataSet.FieldByName('artikel_fach_id').IsNull then
    begin
      LFach.FArtikelFachId := ADataSet.FieldByName('artikel_fach_id').AsInteger;
      LFach.FHatBestand := True;
      LFach.FBestand := ADataSet.FieldByName('bestand').AsFloat;
      LFach.FEinheitId := ADataSet.FieldByName('einheit_id').AsInteger;
    end;
    LAktRegal.Kinder.Add(LFach);

    ADataSet.Next;
  end;

  EntferneLeereZweige(LWurzeln);
  for LAktAdresse in LWurzeln do
    BerechneGesamtbestand(LAktAdresse);
  FuegeNeuEintraegeHinzu(LWurzeln);
  Result := LWurzeln;
end;

end.
