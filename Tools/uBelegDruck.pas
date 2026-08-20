unit uBelegDruck;

// Druck eines Belegs ueber LuaLaTeX.
//
// Der Weg: Vorlage laden -> Platzhalter fuellen -> .tex in einen
// Arbeitsordner schreiben -> lualatex zweimal laufen lassen -> PDF.
// Kompiliert wird auf dem Arbeitsplatz, nicht auf dem Server: ein
// Mitarbeiter bearbeitet den Beleg und verschickt das PDF als Mail oder
// Brief.
//
// Gelesen wird aus den MemTables des Moduls, also aus dem, was der Anwender
// vor sich hat. Kein zweiter Weg zur Datenbank.

interface

uses
  System.SysUtils, System.Classes, Data.DB;

type
  TBelegDruck = class
  private
    FLuaLatex: string;
    FVorlage: string;
    FLog: string;
    function ArbeitsordnerAnlegen: string;
  public
    // ALuaLatexPfad leer = im PATH suchen.
    constructor Create(const AVorlagenDatei: string; const ALuaLatexPfad: string = '');

    // Baut die .tex-Quelle. AKopf steht auf dem zu druckenden Beleg,
    // APositionen ist die dazugehoerige Detailmenge (wird durchlaufen und
    // danach wieder auf den Ausgangssatz gestellt).
    function ErzeugeTex(AKopf, APositionen: TDataSet;
      const AAbsender: string): string;

    // Uebersetzt und liefert den Pfad zum PDF. False = fehlgeschlagen,
    // die Ursache steht dann in Log.
    function Kompiliere(const ATex, ADateiname: string;
      out APdfPfad: string): Boolean;

    property Log: string read FLog;
  end;

// Maskiert die Sonderzeichen von TeX. PFLICHT fuer jeden Wert aus der
// Datenbank: ein Kunde "Mueller & Co." laesst den Lauf sonst platzen, und
// zwar erst beim Kunden. Dieselbe Disziplin wie Parameter statt SQL-Text.
function TexMaskieren(const AText: string): string;

implementation

uses
  Winapi.Windows, System.IOUtils, System.StrUtils;

function TexMaskieren(const AText: string): string;
var
  C: Char;
begin
  Result := '';
  for C in AText do
    case C of
      '\': Result := Result + '\textbackslash{}';
      '&', '%', '$', '#', '_', '{', '}':
           Result := Result + '\' + C;
      '~': Result := Result + '\textasciitilde{}';
      '^': Result := Result + '\textasciicircum{}';
      // Zeilenumbrueche im Anschriftenblock werden zu LaTeX-Umbruechen.
      #13: ; // vom folgenden #10 miterledigt
      #10: Result := Result + '\\' + sLineBreak;
    else
      Result := Result + C;
    end;
end;

{ TBelegDruck }

constructor TBelegDruck.Create(const AVorlagenDatei, ALuaLatexPfad: string);
begin
  inherited Create;
  if not TFile.Exists(AVorlagenDatei) then
    raise Exception.CreateFmt('Vorlage "%s" gibt es nicht.', [AVorlagenDatei]);
  FVorlage := TFile.ReadAllText(AVorlagenDatei, TEncoding.UTF8);

  // Den Pfad nicht aus dem PATH raten: beim Kunden liegt TeX woanders oder
  // gar nicht. Der gehoert spaeter in die Einstellungen.
  FLuaLatex := ALuaLatexPfad;
  if FLuaLatex = '' then
    FLuaLatex := 'lualatex.exe';
end;

function TBelegDruck.ArbeitsordnerAnlegen: string;
var
  LGuid: TGUID;
begin
  // Nicht neben die Exe: unter Program Files darf niemand schreiben.
  CreateGUID(LGuid);
  Result := TPath.Combine(TPath.Combine(TPath.GetTempPath, 'Heisenberg'),
                          GUIDToString(LGuid));
  TDirectory.CreateDirectory(Result);
end;

function TBelegDruck.ErzeugeTex(AKopf, APositionen: TDataSet;
  const AAbsender: string): string;

  function Feld(ADs: TDataSet; const AName: string): string;
  var
    LFeld: TField;
  begin
    LFeld := ADs.FindField(AName);
    if Assigned(LFeld) and not LFeld.IsNull then
      Result := TexMaskieren(LFeld.AsString)
    else
      Result := '';
  end;

  function Zahl(ADs: TDataSet; const AName: string): Double;
  var
    LFeld: TField;
  begin
    LFeld := ADs.FindField(AName);
    if Assigned(LFeld) and not LFeld.IsNull then
      Result := LFeld.AsFloat
    else
      Result := 0;
  end;

var
  LZeilen: TStringBuilder;
  LMuster, LZeile: string;
  LAnfang, LEnde: Integer;
  LLesezeichen: TBookmark;
  LSumme, LBetrag: Double;
begin
  Result := FVorlage;

  // Der Positionsblock steht in der Vorlage zwischen zwei Marken und wird
  // je Zeile einmal wiederholt.
  LAnfang := Pos('%%POSITIONEN_ANFANG%%', Result);
  LEnde   := Pos('%%POSITIONEN_ENDE%%', Result);
  if (LAnfang = 0) or (LEnde = 0) or (LEnde < LAnfang) then
    raise Exception.Create(
      'In der Vorlage fehlen die Marken %%POSITIONEN_ANFANG%% / %%POSITIONEN_ENDE%%.');

  LMuster := Copy(Result, LAnfang + Length('%%POSITIONEN_ANFANG%%'),
                  LEnde - LAnfang - Length('%%POSITIONEN_ANFANG%%'));

  LZeilen := TStringBuilder.Create;
  try
    LSumme := 0;
    APositionen.DisableControls;
    LLesezeichen := APositionen.GetBookmark;
    try
      APositionen.First;
      while not APositionen.Eof do
      begin
        LBetrag := Zahl(APositionen, 'menge') * Zahl(APositionen, 'einzelpreis');
        LSumme  := LSumme + LBetrag;

        LZeile := LMuster;
        LZeile := StringReplace(LZeile, '@POS@',
                    Feld(APositionen, 'position_nr'), [rfReplaceAll]);
        LZeile := StringReplace(LZeile, '@BEZEICHNUNG@',
                    Feld(APositionen, 'bezeichnung'), [rfReplaceAll]);
        LZeile := StringReplace(LZeile, '@MENGE@',
                    FormatFloat('#,##0.###', Zahl(APositionen, 'menge')),
                    [rfReplaceAll]);
        LZeile := StringReplace(LZeile, '@EINHEIT@',
                    Feld(APositionen, 'einheit_text'), [rfReplaceAll]);
        LZeile := StringReplace(LZeile, '@EINZELPREIS@',
                    FormatFloat('#,##0.00', Zahl(APositionen, 'einzelpreis')),
                    [rfReplaceAll]);
        LZeile := StringReplace(LZeile, '@BETRAG@',
                    FormatFloat('#,##0.00', LBetrag), [rfReplaceAll]);
        LZeilen.Append(LZeile);
        APositionen.Next;
      end;
    finally
      if APositionen.BookmarkValid(LLesezeichen) then
        APositionen.GotoBookmark(LLesezeichen);
      APositionen.FreeBookmark(LLesezeichen);
      APositionen.EnableControls;
    end;

    Result := Copy(Result, 1, LAnfang - 1) + LZeilen.ToString +
              Copy(Result, LEnde + Length('%%POSITIONEN_ENDE%%'), MaxInt);
  finally
    LZeilen.Free;
  end;

  // Kopfdaten. AAbsender wird schon fertig maskiert uebergeben, weil er
  // zur Druckzeit aus der Hauptperson aufgeloest wird und nicht im Beleg
  // steht - eine Firma kann verkauft oder umbenannt werden.
  Result := StringReplace(Result, '@ABSENDER@',   AAbsender, [rfReplaceAll]);
  Result := StringReplace(Result, '@EMPFAENGER@',
              Feld(AKopf, 'empfaenger_text'), [rfReplaceAll]);
  Result := StringReplace(Result, '@BELEGART@',
              Feld(AKopf, 'belegart'), [rfReplaceAll]);
  Result := StringReplace(Result, '@BELEGNR@',
              Feld(AKopf, 'beleg_nr'), [rfReplaceAll]);
  Result := StringReplace(Result, '@DATUM@',
              Feld(AKopf, 'beleg_datum'), [rfReplaceAll]);
  Result := StringReplace(Result, '@BEMERKUNG@',
              Feld(AKopf, 'bemerkung'), [rfReplaceAll]);
  Result := StringReplace(Result, '@SUMME@',
              FormatFloat('#,##0.00', LSumme), [rfReplaceAll]);
end;

function TBelegDruck.Kompiliere(const ATex, ADateiname: string;
  out APdfPfad: string): Boolean;
var
  LOrdner, LTexPfad, LBefehl, LLogPfad: string;
  LStart: TStartupInfo;
  LProzess: TProcessInformation;
  I: Integer;
begin
  Result := False;
  FLog := '';
  LOrdner  := ArbeitsordnerAnlegen;
  LTexPfad := TPath.Combine(LOrdner, ADateiname + '.tex');
  APdfPfad := TPath.Combine(LOrdner, ADateiname + '.pdf');
  LLogPfad := TPath.Combine(LOrdner, ADateiname + '.log');

  // UTF-8 ohne BOM - LuaTeX erwartet UTF-8, und ein BOM stoert.
  TFile.WriteAllText(LTexPfad, ATex, TEncoding.UTF8);

  // -interaction=nonstopmode und -halt-on-error sind NICHT optional: sonst
  // bleibt lualatex bei einem Fehler stehen und wartet auf eine Eingabe,
  // die nie kommt - der Aufruf haengt dann bis zum Timeout.
  LBefehl := Format('"%s" -interaction=nonstopmode -halt-on-error ' +
                    '-output-directory="%s" "%s"',
                    [FLuaLatex, LOrdner, LTexPfad]);

  // Zweimal: die Gesamtseitenzahl fuer "Seite 1 von 3" steht erst nach dem
  // ersten Durchgang fest.
  for I := 1 to 2 do
  begin
    FillChar(LStart, SizeOf(LStart), 0);
    LStart.cb := SizeOf(LStart);
    LStart.dwFlags := STARTF_USESHOWWINDOW;
    LStart.wShowWindow := SW_HIDE;

    if not CreateProcess(nil, PChar(LBefehl), nil, nil, False,
                         CREATE_NO_WINDOW, nil, PChar(LOrdner),
                         LStart, LProzess) then
    begin
      FLog := Format('lualatex laesst sich nicht starten (%s). Pfad: %s',
                     [SysErrorMessage(GetLastError), FLuaLatex]);
      Exit;
    end;
    try
      WaitForSingleObject(LProzess.hProcess, INFINITE);
    finally
      CloseHandle(LProzess.hThread);
      CloseHandle(LProzess.hProcess);
    end;
  end;

  // Der Rueckgabewert allein genuegt nicht - es zaehlt, ob ein PDF da ist.
  Result := TFile.Exists(APdfPfad);
  if not Result then
  begin
    if TFile.Exists(LLogPfad) then
      FLog := TFile.ReadAllText(LLogPfad)
    else
      FLog := 'Kein PDF und kein Protokoll in ' + LOrdner;
  end;
end;

end.
