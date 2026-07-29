unit BaumKnotenData;

// Knotendaten fuer rekursive Baeume im VirtualStringTree.
//
// Ausgangsbasis ist ArtikelBestandBaumData (Bestand-Baum im ArtikelStamm):
// dasselbe Muster mit Interfaces statt Objekten, weil der VST die Lebensdauer
// per Refcounting selbst regelt (Node.SetData / OnFreeNode).
//
// UNTERSCHIED zum Bestand-Baum: dessen Hierarchie ist FEST fuenfstufig
// (Adresse -> Gebaeude -> Raum -> Regal -> Fach) und wird per Control-Break
// ueber die ID-Spalten gruppiert. Hier ist die Tiefe BELIEBIG - Stuecklisten
// und Kursbaukaesten sind selbstbezueglich. Deshalb liefert die Datenbank
// eine Ebenenangabe mit (fn_artikel_stueckliste / fn_kurs_baukasten,
// sql/baum_rekursiv.sql), und der Aufbau laeuft ueber einen Stapel statt
// ueber verschachtelte Vergleiche.
//
// Die Spaltentexte werden BEIM AUFBAU fertig gemacht und im Knoten abgelegt.
// Der VST fragt sie im OnGetText nur noch ab - dort darf nichts gerechnet
// werden, die Methode feuert bei jedem Neuzeichnen fuer jede sichtbare Zelle.

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, Data.DB;

type
  IBaumKnoten = interface
    ['{7A1C3E52-9D64-4F0B-8E2A-5C7B1F3D6A88}']
    function GetId: Integer;
    function GetElternId: Integer;
    function GetEbene: Integer;
    function GetSpalte(AIndex: Integer): string;
    function GetSpaltenAnzahl: Integer;
    function GetKinder: TList<IBaumKnoten>;
    function GetIstZyklus: Boolean;
    function GetIstPlatzhalter: Boolean;

    // Fachliche Kennung des Knotens (kurs_id bzw. artikel_id)
    property Id: Integer read GetId;
    // Kennung des Elternknotens - fuer "Entfernen" braucht man beide Seiten
    property ElternId: Integer read GetElternId;
    property Ebene: Integer read GetEbene;
    // Fertige Zelltexte, Spalte 0 ist der Baumtext
    property Spalte[AIndex: Integer]: string read GetSpalte;
    property SpaltenAnzahl: Integer read GetSpaltenAnzahl;
    property Kinder: TList<IBaumKnoten> read GetKinder;
    // Datenfehler: dieser Knoten kommt im eigenen Pfad schon vor
    property IstZyklus: Boolean read GetIstZyklus;
    // Synthetischer "+ ..."-Knoten zum Anlegen - wie bkNeuEintrag
    // im Bestand-Baum. Traegt in ElternId den Knoten, unter dem
    // eingehaengt wird.
    property IstPlatzhalter: Boolean read GetIstPlatzhalter;
  end;

  TBaumKnoten = class(TInterfacedObject, IBaumKnoten)
  private
    FId: Integer;
    FElternId: Integer;
    FEbene: Integer;
    FSpalten: TArray<string>;
    FKinder: TList<IBaumKnoten>;
    FIstZyklus: Boolean;
    FIstPlatzhalter: Boolean;
  protected
    function GetId: Integer;
    function GetElternId: Integer;
    function GetEbene: Integer;
    function GetSpalte(AIndex: Integer): string;
    function GetSpaltenAnzahl: Integer;
    function GetKinder: TList<IBaumKnoten>;
    function GetIstZyklus: Boolean;
    function GetIstPlatzhalter: Boolean;
  public
    constructor Create(AId, AElternId, AEbene: Integer;
      const ASpalten: TArray<string>; AIstZyklus: Boolean;
      AIstPlatzhalter: Boolean = False);
    destructor Destroy; override;
  end;

// Baut die Wurzelliste aus einem FLACHEN, nach Pfad sortierten Ergebnis mit
// Ebenenspalte auf.
//
// ADataSet   bereits geoeffnet, sortiert wie von der DB geliefert
// AIdFeld    Feldname der eigenen Kennung
// AEbenenFeld Feldname der Ebene (0 = Wurzel)
// ASpalten   Feldnamen fuer die Zelltexte, Reihenfolge = Spaltenreihenfolge.
//            Numerische Felder werden ohne ueberfluessige Nachkommastellen
//            formatiert, leere Felder bleiben leer.
function BaueBaumAusEbenen(ADataSet: TDataSet;
  const AIdFeld, AEbenenFeld: string;
  const ASpalten: array of string;
  const AZyklusFeld: string = '';
  APlatzhalterText: string = ''): TList<IBaumKnoten>;

// Formatiert einen Feldwert fuer die Anzeige: Zahlen ohne unnoetige Nullen,
// Boolean als Ja/leer, NULL als Leerstring.
function FeldText(AFeld: TField): string;

implementation

{ TBaumKnoten }

constructor TBaumKnoten.Create(AId, AElternId, AEbene: Integer;
  const ASpalten: TArray<string>; AIstZyklus: Boolean;
  AIstPlatzhalter: Boolean);
begin
  inherited Create;
  FId := AId;
  FElternId := AElternId;
  FEbene := AEbene;
  FSpalten := ASpalten;
  FIstZyklus := AIstZyklus;
  FIstPlatzhalter := AIstPlatzhalter;
  FKinder := TList<IBaumKnoten>.Create;
end;

destructor TBaumKnoten.Destroy;
begin
  FKinder.Free;
  inherited Destroy;
end;

function TBaumKnoten.GetId: Integer;
begin
  Result := FId;
end;

function TBaumKnoten.GetElternId: Integer;
begin
  Result := FElternId;
end;

function TBaumKnoten.GetEbene: Integer;
begin
  Result := FEbene;
end;

function TBaumKnoten.GetSpalte(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < Length(FSpalten)) then
    Result := FSpalten[AIndex]
  else
    Result := '';
end;

function TBaumKnoten.GetSpaltenAnzahl: Integer;
begin
  Result := Length(FSpalten);
end;

function TBaumKnoten.GetKinder: TList<IBaumKnoten>;
begin
  Result := FKinder;
end;

function TBaumKnoten.GetIstZyklus: Boolean;
begin
  Result := FIstZyklus;
end;

function TBaumKnoten.GetIstPlatzhalter: Boolean;
begin
  Result := FIstPlatzhalter;
end;

{ Hilfsfunktionen }

function FeldText(AFeld: TField): string;
var
  LWert: Double;
begin
  Result := '';
  if (AFeld = nil) or AFeld.IsNull then
    Exit;

  if AFeld.DataType = ftBoolean then
  begin
    if AFeld.AsBoolean then
      Result := 'Ja';
    Exit;
  end;

  if AFeld.DataType in [ftFloat, ftBCD, ftFMTBcd, ftCurrency, ftExtended] then
  begin
    LWert := AFeld.AsFloat;
    // 6.000 sieht in einer Stueckliste albern aus, 6 reicht - Nachkommastellen
    // nur zeigen, wenn welche da sind.
    if Frac(LWert) = 0 then
      Result := FormatFloat('0', LWert)
    else
      Result := FormatFloat('0.###', LWert);
    Exit;
  end;

  Result := AFeld.AsString;
end;

procedure PlatzhalterAnhaengen(AKinder: TList<IBaumKnoten>;
  const AText: string);
var
  I: Integer;
  LSpalten: TArray<string>;
begin
  for I := AKinder.Count - 1 downto 0 do
  begin
    if AKinder[I].IstPlatzhalter then
      Continue;
    PlatzhalterAnhaengen(AKinder[I].Kinder, AText);
    SetLength(LSpalten, 1);
    LSpalten[0] := AText;
    AKinder[I].Kinder.Add(TBaumKnoten.Create(0, AKinder[I].Id,
      AKinder[I].Ebene + 1, LSpalten, False, True));
  end;
end;

function BaueBaumAusEbenen(ADataSet: TDataSet;
  const AIdFeld, AEbenenFeld: string;
  const ASpalten: array of string;
  const AZyklusFeld: string;
  APlatzhalterText: string): TList<IBaumKnoten>;
var
  LWurzeln: TList<IBaumKnoten>;
  // Stapel: an Position N steht der zuletzt gesehene Knoten der Ebene N.
  // Ein neuer Knoten der Ebene N haengt an Stapel[N-1].
  LStapel: TList<IBaumKnoten>;
  LKnoten: IBaumKnoten;
  LEbene, LElternId, I: Integer;
  LSpalten: TArray<string>;
  LZyklus: Boolean;
begin
  LWurzeln := TList<IBaumKnoten>.Create;
  LStapel := TList<IBaumKnoten>.Create;
  try
    if (ADataSet = nil) or not ADataSet.Active then
      Exit(LWurzeln);

    ADataSet.First;
    while not ADataSet.Eof do
    begin
      LEbene := ADataSet.FieldByName(AEbenenFeld).AsInteger;

      SetLength(LSpalten, Length(ASpalten));
      for I := 0 to High(ASpalten) do
        LSpalten[I] := FeldText(ADataSet.FindField(ASpalten[I]));

      LZyklus := (AZyklusFeld <> '')
                 and (ADataSet.FindField(AZyklusFeld) <> nil)
                 and ADataSet.FieldByName(AZyklusFeld).AsBoolean;

      // eltern_id ist optional - fehlt es, bleibt 0
      if ADataSet.FindField('eltern_id') <> nil then
        LElternId := ADataSet.FieldByName('eltern_id').AsInteger
      else
        LElternId := 0;

      LKnoten := TBaumKnoten.Create(
        ADataSet.FieldByName(AIdFeld).AsInteger, LElternId,
        LEbene, LSpalten, LZyklus);

      // Stapel auf die aktuelle Ebene zurechtstutzen. Springt die Ebene
      // zurueck (Ende eines Astes), fallen die tieferen Eintraege weg.
      while LStapel.Count > LEbene do
        LStapel.Delete(LStapel.Count - 1);

      if LEbene = 0 then
        LWurzeln.Add(LKnoten)
      else if LStapel.Count = LEbene then
        LStapel[LEbene - 1].Kinder.Add(LKnoten)
      else
        // Ebenensprung ohne Elternknoten - kann nur bei kaputten Daten
        // passieren. Lieber als Wurzel zeigen als still verschlucken.
        LWurzeln.Add(LKnoten);

      LStapel.Add(LKnoten);
      ADataSet.Next;
    end;

    // Platzhalter "+ ..." als letztes Kind jedes echten Knotens -
    // erst dadurch laesst sich direkt im Baum einhaengen, ohne
    // Eingabefelder darunter (Muster bkNeuEintrag im Bestand-Baum).
    if APlatzhalterText <> '' then
      PlatzhalterAnhaengen(LWurzeln, APlatzhalterText);

    Result := LWurzeln;
  finally
    LStapel.Free;
  end;
end;

end.
