program TestArtikelStammBaeume;
{$APPTYPE CONSOLE}
// Die drei Baeume des Artikelstamms: Stueckliste, Varianten, Bestand.
//
// Alle drei werden im Speicher aus den Kopien gebaut. Geprueft wird gegen
// die Datenbank - Struktur UND Inhalt, nicht nur Knotenzahlen.
//
// Die Baumdaten liegen bei Mandant 3, nicht bei TRT (Mandant 1). Varianten
// gibt es noch keine; dafuer legt der Pruefstand eine kleine Hierarchie an
// und raeumt sie wieder weg.
uses
  System.SysUtils, System.Classes, System.StrUtils,
  System.Generics.Collections,
  Data.DB, Vcl.Forms, Vcl.Controls,
  FireDAC.Comp.Client,
  EventBus, UInterfaces, uMessageHandler,
  BaumKnotenData, VirtualTrees,
  udmModuleTemplate, ZentraleDatenDm, MandantDm, ArtikelStammDm,
  ArtikelStammFrm;

type
  // Das Modulfenster ist ein MDI-Kind und braucht einen Rahmen.
  TMdiRahmen = class(TForm)
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TMdiRahmen.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  FormStyle := fsMDIForm;
  Position := poDesigned;
  Left := -32000;
  Top := -32000;
  WindowState := wsMinimized;
end;

var
  LFehler: Integer = 0;
  LDm: TdmArtikelStamm;
  LQry: TFDQuery;
  LRahmen: TMdiRahmen;
  LSeite: Integer;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
begin
  Writeln(Format('%-46s %-5s %s', [ATitel, BoolToStr(AGut, True), AText]));
  if not AGut then
    Inc(LFehler);
end;

function Zaehle(const ASql: string): Integer;
begin
  LQry.Close;
  LQry.SQL.Text := ASql;
  LQry.Open;
  Result := LQry.Fields[0].AsInteger;
end;

procedure RufeAuf(const ASql: string);
begin
  LQry.Close;
  LQry.SQL.Text := ASql;
  LQry.Open;
  LQry.Close;
end;

// Alle Knoten eines Baumes zaehlen, ueber alle Ebenen.
function KnotenGesamt(AListe: TList<IBaumKnoten>): Integer;
var
  LKnoten: IBaumKnoten;
begin
  Result := 0;
  if AListe = nil then
    Exit;
  for LKnoten in AListe do
  begin
    Inc(Result);
    Result := Result + KnotenGesamt(LKnoten.Kinder);
  end;
end;

// Den Baum als Text, damit man Struktur UND Inhalt vergleichen kann.
function AlsText(AListe: TList<IBaumKnoten>; AEbene: Integer = 0): string;
var
  LKnoten: IBaumKnoten;
begin
  Result := '';
  if AListe = nil then
    Exit;
  for LKnoten in AListe do
  begin
    Result := Result + StringOfChar(' ', AEbene * 2) + LKnoten.Spalte[0];
    if (LKnoten.SpaltenAnzahl > 1) and (LKnoten.Spalte[1] <> '') then
      Result := Result + ' [' + LKnoten.Spalte[1] + ']';
    if LKnoten.IstZyklus then
      Result := Result + ' (RING)';
    Result := Result + sLineBreak;
    Result := Result + AlsText(LKnoten.Kinder, AEbene + 1);
  end;
end;

// Liest den Baum so aus, wie ihn der Anwender sieht: ueber OnGetText,
// Knoten fuer Knoten. Alles andere prueft nur die Datenhaltung.
function BaumImFenster(ABaum: TVirtualStringTree): string;
var
  LKnoten: PVirtualNode;
  LText: string;
  LEbene: Integer;
begin
  Result := '';
  ABaum.FullExpand;
  LKnoten := ABaum.GetFirst;
  while LKnoten <> nil do
  begin
    LEbene := ABaum.GetNodeLevel(LKnoten);
    LText := ABaum.Text[LKnoten, 0];
    if ABaum.Header.Columns.Count > 1 then
      if ABaum.Text[LKnoten, 1] <> '' then
        LText := LText + ' [' + ABaum.Text[LKnoten, 1] + ']';
    Result := Result + StringOfChar(' ', LEbene * 2) + LText + sLineBreak;
    LKnoten := ABaum.GetNext(LKnoten);
  end;
end;

function KnotenImFenster(ABaum: TVirtualStringTree): Integer;
var
  LKnoten: PVirtualNode;
begin
  Result := 0;
  ABaum.FullExpand;
  LKnoten := ABaum.GetFirst;
  while LKnoten <> nil do
  begin
    Inc(Result);
    LKnoten := ABaum.GetNext(LKnoten);
  end;
end;

// ── Stueckliste ─────────────────────────────────────────────────────────────
procedure StuecklistePruefen;
var
  LBaum: TList<IBaumKnoten>;
  LArtikel, LSoll: Integer;
  LNr: string;
begin
  // Der Artikel mit den meisten direkten Unterartikeln.
  LQry.Close;
  LQry.SQL.Text :=
    'SELECT a.artikel_id, a.artikel_nr, count(*) FROM artikel_artikel aa ' +
    'JOIN artikel a ON a.artikel_id = aa.artikel_id ' +
    'WHERE aa.mandant_id = 3 GROUP BY 1,2 ORDER BY 3 DESC LIMIT 1';
  LQry.Open;
  if LQry.IsEmpty then
  begin
    Sag('Stueckliste', False, 'keine Kanten bei Mandant 3');
    Exit;
  end;
  LArtikel := LQry.Fields[0].AsInteger;
  LNr := LQry.Fields[1].AsString;

  if not LDm.tblArtikel.Locate('artikel_id', LArtikel, []) then
  begin
    Sag('Stueckliste: Artikel in der Kopie', False, LNr);
    Exit;
  end;

  LBaum := LDm.StuecklisteBaum;
  try
    LSoll := Zaehle(Format(
      'SELECT count(*) FROM artikel_artikel WHERE artikel_id=%d', [LArtikel]));
    Sag(LNr + ': direkte Unterartikel',
        (LBaum <> nil) and (LBaum.Count = LSoll),
        Format('%d von %d', [LBaum.Count, LSoll]));

    // Gesamtzahl gegen die rekursive Abfrage - so faellt auf, wenn der
    // Baum eine Ebene zu frueh aufhoert.
    LSoll := Zaehle(Format(
      'WITH RECURSIVE t AS ( ' +
      '  SELECT unter_artikel_id FROM artikel_artikel WHERE artikel_id=%d ' +
      '  UNION ALL ' +
      '  SELECT aa.unter_artikel_id FROM artikel_artikel aa ' +
      '    JOIN t ON t.unter_artikel_id = aa.artikel_id) ' +
      'SELECT count(*) FROM t', [LArtikel]));
    Sag('  ... Knoten ueber alle Ebenen', KnotenGesamt(LBaum) = LSoll,
        Format('%d von %d', [KnotenGesamt(LBaum), LSoll]));

    Sag('  ... Namen statt Nummern im Text',
        (LBaum.Count > 0) and (Length(LBaum[0].Spalte[0]) > 0) and
        (Pos(' ', Trim(LBaum[0].Spalte[0])) > 0),
        '"' + LBaum[0].Spalte[0] + '"');
    Sag('  ... Menge steht in Spalte 1',
        (LBaum.Count > 0) and (LBaum[0].Spalte[1] <> ''),
        '"' + LBaum[0].Spalte[1] + '"');
  finally
    LBaum.Free;
  end;
end;

// ── Varianten ───────────────────────────────────────────────────────────────
procedure VariantenPruefen;
var
  LBaum: TList<IBaumKnoten>;
  LWurzel, LKind1, LKind2: Integer;
  LText: string;
begin
  // Testhierarchie: Wurzel > zwei Kinder, das zweite mit einem Enkel.
  LWurzel := Zaehle('SELECT fn_variante_anlegen(3, ''ZZPruef Farbe'', NULL)');
  LKind1  := Zaehle(Format('SELECT fn_variante_anlegen(3, ''ZZPruef rot'', %d)',
                           [LWurzel]));
  LKind2  := Zaehle(Format('SELECT fn_variante_anlegen(3, ''ZZPruef blau'', %d)',
                           [LWurzel]));
  Zaehle(Format('SELECT fn_variante_anlegen(3, ''ZZPruef hellblau'', %d)',
                [LKind2]));
  try
    // Kopien nachziehen, wie es das Modul nach einer Aenderung tut.
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).TabelleAuffrischen('variante');
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).TabelleAuffrischen('variante_variante');
    LDm.DatenGeladen;

    LBaum := LDm.VariantenBaum;
    try
      LText := AlsText(LBaum);
      Sag('Variantenbaum: vier Knoten', KnotenGesamt(LBaum) = 4,
          Format('%d', [KnotenGesamt(LBaum)]));
      Sag('  ... eine Wurzel', (LBaum <> nil) and (LBaum.Count = 1),
          Format('%d', [LBaum.Count]));
      Sag('  ... Wurzel heisst richtig',
          (LBaum.Count = 1) and (LBaum[0].Spalte[0] = 'ZZPruef Farbe'),
          '"' + LBaum[0].Spalte[0] + '"');
      Sag('  ... zwei Kinder darunter',
          (LBaum.Count = 1) and (LBaum[0].Kinder.Count = 2),
          Format('%d', [LBaum[0].Kinder.Count]));
      Sag('  ... und ein Enkel in der dritten Ebene',
          Pos('hellblau', LText) > 0);
      Writeln(LText);
    finally
      LBaum.Free;
    end;
  finally
    // Von unten nach oben wegraeumen - Loeschen mit Kindern lehnt die
    // Datenbank ab.
    RufeAuf('SELECT fn_variante_loeschen(v.variante_id) FROM variante v ' +
            'WHERE v.name = ''ZZPruef hellblau''');
    RufeAuf('SELECT fn_variante_loeschen(v.variante_id) FROM variante v ' +
            'WHERE v.name IN (''ZZPruef rot'', ''ZZPruef blau'')');
    RufeAuf('SELECT fn_variante_loeschen(v.variante_id) FROM variante v ' +
            'WHERE v.name = ''ZZPruef Farbe''');
    Sag('Testvarianten wieder weg',
        Zaehle('SELECT count(*) FROM variante WHERE name LIKE ''ZZPruef%''') = 0);
  end;
end;

// ── Bestand ─────────────────────────────────────────────────────────────────
procedure BestandPruefen;
var
  LBaum: TList<IBaumKnoten>;
  LArtikel: Integer;
  LNr, LText: string;
begin
  // Ein Artikel mit Bestand.
  LQry.Close;
  LQry.SQL.Text :=
    'SELECT a.artikel_id, a.artikel_nr FROM artikel_fach af ' +
    'JOIN artikel a ON a.artikel_id = af.artikel_id ' +
    'WHERE af.mandant_id = 3 AND af.bestand > 0 ORDER BY af.bestand DESC LIMIT 1';
  LQry.Open;
  if LQry.IsEmpty then
  begin
    Sag('Bestand', False, 'keine Bestandszeile bei Mandant 3');
    Exit;
  end;
  LArtikel := LQry.Fields[0].AsInteger;
  LNr := LQry.Fields[1].AsString;
  LDm.tblArtikel.Locate('artikel_id', LArtikel, []);

  LBaum := LDm.BestandBaum;
  try
    Sag('Bestandbaum: Adressen',
        (LBaum <> nil) and (LBaum.Count =
          Zaehle('SELECT count(DISTINCT adresse_id) FROM v_lagerort WHERE mandant_id=3')),
        Format('%d', [LBaum.Count]));

    Sag('  ... Faecher insgesamt (Blattebene)',
        KnotenGesamt(LBaum) =
          Zaehle('SELECT count(DISTINCT adresse_id) + count(DISTINCT raum_id) + ' +
                 '       count(DISTINCT regal_id) + count(*) ' +
                 'FROM v_lagerort WHERE mandant_id=3'),
        Format('%d Knoten', [KnotenGesamt(LBaum)]));

    LText := AlsText(LBaum);
    Sag('  ... Bestand steht am Fach', Pos('[', LText) > 0);
    Writeln(LText);
  finally
    LBaum.Free;
  end;
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TdmMessageHandler, dmMessageHandler);

    Application.CreateForm(TMdiRahmen, LRahmen);
    LDm := TdmArtikelStamm(TdmArtikelStamm.GetInstance);
    // Die Baumdaten haengen an Mandant 3.
    TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 3;
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;

    LQry := TFDQuery.Create(nil);
    try
      LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

      Sag('Kopien fuer die Baeume sind da',
          LDm.memArtikelArtikel.Active and LDm.memVariante.Active and
          LDm.memLagerort.Active and LDm.tblArtikelFach.Active and
          LDm.memArtikelNachschlag.Active);
      Writeln;

      StuecklistePruefen;
      Writeln;
      VariantenPruefen;
      Writeln;
      BestandPruefen;

      // ── und jetzt dasselbe im Fenster ────────────────────────────────
      Writeln;
      Writeln('--- im Fenster ------------------------------------------');
      LDm.OpenArtikelStamm;
      Application.ProcessMessages;
      if not Assigned(frmArtikelStamm) then
      begin
        Sag('Fenster geoeffnet', False);
        Halt(0);
      end;

      // Die Falle bei TRibbonPanel: HeaderButtons und TabSheets muessen
      // gleich viele sein, sonst ist eine Seite unerreichbar.
      Sag('Ribbon: Kopfschalter und Seiten passen',
          (frmArtikelStamm.rbnpnl1.HeaderButtons.Count = 5) and
          (frmArtikelStamm.rbnpnl1.ControlCount > 0),
          Format('%d Schalter',
                 [frmArtikelStamm.rbnpnl1.HeaderButtons.Count]));

      Sag('  ... Spalten der Baeume gesetzt',
          (frmArtikelStamm.vstBestand.Header.Columns.Count = 2) and
          (frmArtikelStamm.vstStueckliste.Header.Columns.Count = 3) and
          (frmArtikelStamm.vstVarianten.Header.Columns.Count = 2));

      // Auf den Artikel mit Stueckliste stellen.
      LQry.Close;
      LQry.SQL.Text :=
        'SELECT a.artikel_id FROM artikel_artikel aa ' +
        'JOIN artikel a ON a.artikel_id = aa.artikel_id ' +
        'WHERE aa.mandant_id = 3 GROUP BY 1 ORDER BY count(*) DESC LIMIT 1';
      LQry.Open;
      LDm.tblArtikel.Locate('artikel_id', LQry.Fields[0].AsInteger, []);
      Application.ProcessMessages;

      Sag('Stuecklistenbaum im Fenster gefuellt',
          KnotenImFenster(frmArtikelStamm.vstStueckliste) =
            KnotenGesamt(LDm.StuecklisteBaum),
          Format('%d Knoten', [KnotenImFenster(frmArtikelStamm.vstStueckliste)]));

      Sag('Bestandbaum im Fenster gefuellt',
          KnotenImFenster(frmArtikelStamm.vstBestand) > 0,
          Format('%d Knoten', [KnotenImFenster(frmArtikelStamm.vstBestand)]));

      Sag('  ... und zeigt lesbaren Text, keine IDs',
          Pos('Fach', BaumImFenster(frmArtikelStamm.vstBestand)) > 0);

      // Jede Ribbon-Seite anwaehlen - eine unerreichbare faellt hier auf.
      for LSeite := 0 to 4 do
      begin
        frmArtikelStamm.rbnpnl1.ActivePageIndex := LSeite;
        Application.ProcessMessages;
        Sag(Format('  ... Seite %d anwaehlbar', [LSeite]),
            frmArtikelStamm.rbnpnl1.ActivePageIndex = LSeite);
      end;

      Writeln;
      Writeln('So sieht der Bestandbaum im Fenster aus:');
      Write(BaumImFenster(frmArtikelStamm.vstBestand));

      frmArtikelStamm.Close;
      Application.ProcessMessages;
    finally
      LQry.Free;
    end;

    Writeln;
    if LFehler = 0 then
      Writeln('Alles in Ordnung.')
    else
      Writeln(LFehler, ' Pruefung(en) fehlgeschlagen.');
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
