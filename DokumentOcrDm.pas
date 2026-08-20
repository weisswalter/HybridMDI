unit DokumentOcrDm;

// Bindet die Texterkennung (Python\dokument_ocr) an die Anwendung an.
//
//   Delphi  ->  Engine.ExecString('import ocr_caller; _ocr = ...')
//     |         Engine.EvalStringAsStr('_ocr')     -- Rueckgabe ist JSON
//     v
//   ocr_caller.py  ->  dokument_ocr\pipeline.py
//
// Aufbau wie CSharpDm: EINE PythonEngine im Prozess, die von PythonDm
// bereitgestellt wird. Dieses Modul erzeugt keine eigene.
//
// Die Zuordnung der erkannten Kategorie auf dokument.typ_id passiert NICHT
// hier im Code, sondern ueber dokument_typ.ocr_schluessel in der Datenbank
// (siehe sql\dokument_ocr_typen.sql). So laesst sich eine neue Dokumentart
// hinzufuegen, ohne etwas neu zu uebersetzen.

interface

uses
  System.SysUtils, System.Classes, System.JSON, Data.DB,
  FireDAC.Comp.Client, PythonEngine;

type
  // Ergebnis einer Erkennung. Felder, die das Dokument nicht hergibt,
  // bleiben leer bzw. 0 -- es wird nichts geraten.
  TOcrErgebnis = record
    Erfolg: Boolean;
    Fehler: string;
    Titel: string;
    OcrText: string;
    MimeTyp: string;
    Sprache: string;
    GroesseKb: Integer;
    Kategorie: string;
    KategorieText: string;
    KategorieSicher: Boolean;
    Begruendung: string;
    Zuversicht: Double;
    // Aus dem Text gezogene Werte
    Betrag: Double;
    Waehrung: string;
    Datum: string;
    RechnungsNr: string;
    Iban: string;
    QrReferenz: string;
  end;

  TdmDokumentOcr = class(TDataModule)
  private
    function Engine: TPythonEngine;
    function Rufe(const AAusdruck: string): string;
    function AusJson(const AJson: string): TOcrErgebnis;
  public
    // True, wenn EasyOCR installiert ist. Damit laesst sich der Menuepunkt
    // ausgrauen, statt dem Anwender erst nach dem Klick einen Fehler zu
    // zeigen.
    function OcrVerfuegbar: Boolean;
    // Eine Bilddatei oder ein PDF erkennen und einordnen.
    function DokumentLesen(const APfad: string): TOcrErgebnis;
    // Nur Text einordnen -- braucht kein EasyOCR. Fuer durchsuchbare PDFs
    // und fuer Mailtexte aus dem Mailmodul.
    function TextEinordnen(const AText: string): TOcrErgebnis;
    // typ_id zum Kategorie-Schluessel, 0 wenn nicht gepflegt.
    function TypIdZuKategorie(const AKategorie: string): Integer;
    // Schreibt das Ergebnis in eine dokument-Zeile. Der Datensatz muss im
    // Bearbeitungsmodus sein. Felder, die es im Dataset nicht gibt, werden
    // uebersprungen -- so bleibt es benutzbar, wenn die Abfrage nur einen
    // Teil der Spalten liefert.
    procedure InDatensatzSchreiben(ADataSet: TDataSet;
      const AErgebnis: TOcrErgebnis; ATypId: Integer = 0);
  end;

var
  dmDokumentOcr: TdmDokumentOcr;

implementation

uses
  System.Variants, PythonDm, ZentraleDatenDm;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TdmDokumentOcr.Engine: TPythonEngine;
begin
  if not Assigned(PythonDm.dmPython) then
    raise Exception.Create('TdmPython ist nicht erzeugt — im .dpr muss ' +
      'dmPython VOR dmDokumentOcr angelegt werden.');
  Result := PythonDm.dmPython.Engine;
end;

function TdmDokumentOcr.Rufe(const AAusdruck: string): string;
var
  LCode: string;
begin
  LCode := 'import ocr_caller' + sLineBreak + '_ocr = ' + AAusdruck;
  try
    Engine.ExecString(LCode);
    Result := Engine.EvalStringAsStr('_ocr');
  except
    on E: Exception do
      raise Exception.CreateFmt(
        'Die Texterkennung konnte nicht aufgerufen werden.'#13#10 +
        'Aufruf: %s'#13#10'Fehler: %s', [AAusdruck, E.Message]);
  end;
end;

function TdmDokumentOcr.OcrVerfuegbar: Boolean;
begin
  try
    // Python liefert True/False als Text
    Result := SameText(Trim(Rufe('ocr_caller.ocr_verfuegbar()')), 'True');
  except
    // Fehlt die Python-Umgebung ganz, ist die Erkennung eben nicht da --
    // das ist kein Grund, die Oberflaeche mit einer Ausnahme zu behelligen.
    Result := False;
  end;
end;

function TdmDokumentOcr.AusJson(const AJson: string): TOcrErgebnis;
var
  LWurzel: TJSONObject;

  function Text(const AName: string): string;
  var
    LWert: TJSONValue;
  begin
    Result := '';
    LWert := LWurzel.FindValue(AName);
    if Assigned(LWert) and not (LWert is TJSONNull) then
      Result := LWert.Value;
  end;

  function Zahl(const AName: string): Double;
  var
    LWert: TJSONValue;
  begin
    Result := 0;
    LWert := LWurzel.FindValue(AName);
    if Assigned(LWert) and not (LWert is TJSONNull) then
      // Python schreibt Zahlen mit Punkt, unabhaengig von den
      // Laendereinstellungen des Rechners
      Result := StrToFloatDef(LWert.Value, 0, TFormatSettings.Invariant);
  end;

  function JaNein(const AName: string): Boolean;
  begin
    Result := SameText(Text(AName), 'true');
  end;

begin
  Result := Default(TOcrErgebnis);
  LWurzel := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  if not Assigned(LWurzel) then
  begin
    Result.Fehler := 'Die Texterkennung hat keine lesbare Antwort geliefert.';
    Exit;
  end;
  try
    Result.Erfolg          := JaNein('ok');
    Result.Fehler          := Text('fehler');
    Result.Titel           := Text('titel');
    Result.OcrText         := Text('ocr_text');
    Result.MimeTyp         := Text('mime_type');
    Result.Sprache         := Text('sprache');
    Result.GroesseKb       := Round(Zahl('dateigroesse_kb'));
    Result.Kategorie       := Text('kategorie');
    Result.KategorieText   := Text('kategorie_bezeichnung');
    Result.KategorieSicher := JaNein('kategorie_sicher');
    Result.Begruendung     := Text('kategorie_begruendung');
    Result.Zuversicht      := Zahl('ocr_zuversicht');
    Result.Betrag          := Zahl('betrag');
    Result.Waehrung        := Text('betrag_waehrung');
    Result.Datum           := Text('datum');
    Result.RechnungsNr     := Text('rechnungsnummer');
    Result.Iban            := Text('iban');
    Result.QrReferenz      := Text('qr_referenz');

    // "ok" fehlt bei text_einordnen -- dort zaehlt, dass kein Fehler kam
    if not Result.Erfolg and (Result.Fehler = '') then
      Result.Erfolg := Result.Kategorie <> '';
  finally
    LWurzel.Free;
  end;
end;

function TdmDokumentOcr.DokumentLesen(const APfad: string): TOcrErgebnis;
begin
  // r"..." als Python-Rohtext: Backslashes im Windows-Pfad bleiben stehen,
  // ohne dass jeder einzeln verdoppelt werden muss.
  Result := AusJson(Rufe(Format('ocr_caller.dokument_lesen(r"%s")', [APfad])));
end;

function TdmDokumentOcr.TextEinordnen(const AText: string): TOcrErgebnis;
var
  LSicher: string;
begin
  // Anfuehrungszeichen und Zeilenumbrueche entschaerfen, sonst zerreisst
  // der Text den Python-Ausdruck.
  LSicher := StringReplace(AText, '\', '\\', [rfReplaceAll]);
  LSicher := StringReplace(LSicher, '"', '\"', [rfReplaceAll]);
  LSicher := StringReplace(LSicher, #13#10, '\n', [rfReplaceAll]);
  LSicher := StringReplace(LSicher, #10, '\n', [rfReplaceAll]);
  LSicher := StringReplace(LSicher, #13, '\n', [rfReplaceAll]);
  Result := AusJson(Rufe(Format('ocr_caller.text_einordnen("%s")', [LSicher])));
end;

// Keine eigene Query mehr: die Datenbankfunktion wird ueber das zentrale
// Datenmodul gerufen, das als einziges noch eine Verbindung haelt.
function TdmDokumentOcr.TypIdZuKategorie(const AKategorie: string): Integer;
var
  LWert: Variant;
begin
  Result := 0;
  if (AKategorie = '') or (AKategorie = 'unbekannt') then
    Exit;

  LWert := TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
    'fn_dokument_typ_zu_ocr', [AKategorie]);
  if not VarIsNull(LWert) then
    Result := LWert;
end;

procedure TdmDokumentOcr.InDatensatzSchreiben(ADataSet: TDataSet;
  const AErgebnis: TOcrErgebnis; ATypId: Integer);

  procedure Setze(const AFeld, AWert: string);
  var
    LFeld: TField;
  begin
    if AWert = '' then
      Exit;
    LFeld := ADataSet.FindField(AFeld);
    if Assigned(LFeld) then
      LFeld.AsString := AWert;
  end;

var
  LFeld: TField;
begin
  if not Assigned(ADataSet) or not (ADataSet.State in dsEditModes) then
    raise Exception.Create('Der Datensatz ist nicht im Bearbeitungsmodus.');

  Setze('ocr_text', AErgebnis.OcrText);
  Setze('titel', AErgebnis.Titel);
  Setze('mime_type', AErgebnis.MimeTyp);
  Setze('sprache', AErgebnis.Sprache);

  LFeld := ADataSet.FindField('dateigroesse_kb');
  if Assigned(LFeld) and (AErgebnis.GroesseKb > 0) then
    LFeld.AsInteger := AErgebnis.GroesseKb;

  LFeld := ADataSet.FindField('scan_datum');
  if Assigned(LFeld) and LFeld.IsNull then
    LFeld.AsDateTime := Now;

  // typ_id nur setzen, wenn die Erkennung sicher war UND der Schluessel
  // gepflegt ist. Eine unsichere Vermutung soll keinen falschen Typ
  // festschreiben -- lieber leer lassen und den Anwender waehlen lassen.
  LFeld := ADataSet.FindField('typ_id');
  if Assigned(LFeld) and (ATypId > 0) and AErgebnis.KategorieSicher then
    LFeld.AsInteger := ATypId;
end;

end.
