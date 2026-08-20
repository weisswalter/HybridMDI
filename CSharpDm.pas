unit CSharpDm;

// Bruecke Delphi -> Python -> C#. Uebernimmt das in BridgePOC erprobte Muster
// (C:\Users\weiss\source\repos\BridgePOC) nach Heisenberg:
//
//   Delphi   FEngine.ExecString('import <modul>; _cs_result = <modul>.<fn>(args)')
//     |      FEngine.EvalStringAsStr('_cs_result')
//   Python   <modul>.py macht clr.AddReference(...) und ruft die C#-Klasse
//     |
//   C#       fuehrt die eigentliche Arbeit aus, gibt einen String zurueck
//
// WICHTIG — nur EINE PythonEngine pro Prozess: Dieses Modul erzeugt KEINE
// eigene Engine, sondern benutzt die von TdmPython (property Engine). Eine
// zweite TPythonEngine im selben Prozess fuehrt zu Abstuerzen.
//
// Ueber die Bruecke gehen bewusst nur STANDARDTYPEN (Integer, Int64, Double,
// String, Boolean) — grosse Datenmengen laufen ueber die Datenbank, nicht
// ueber den Call Stack (siehe Mailmodul: C# schreibt nach Postgres, Delphi
// liest von dort). Wer einen Record oder ein Objekt durchreichen will,
// bekommt eine klare Exception statt eines stillschweigenden 'None'.

interface

uses
  System.SysUtils, System.Classes, System.Rtti,
  PythonEngine,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmCSharp = class(TdmModuleTemplate)
  private
    function Engine: TPythonEngine;
  public
    class function GetInstance: TObject;
    // True, wenn die Python-Engine bereit ist (sonst laeuft gar nichts).
    function Verfuegbar: Boolean;
    // Ruft <AModul>.<AFunktion>(AArgs...) auf und liefert das Ergebnis als
    // String zurueck. Der Aufruf ist synchron — er kehrt erst zurueck, wenn
    // die C#-Seite fertig ist.
    function Call(const AModul, AFunktion: string;
      const AArgs: array of TValue): string;
    // Bequemer Kurzaufruf ohne Argumente
    function CallSimple(const AModul, AFunktion: string): string;
    // Selbsttest gegen die BridgePOC-Beispielfunktion — damit laesst sich
    // pruefen, ob die Kette Delphi->Python->C# ueberhaupt steht, bevor man
    // ein Fachmodul verdaechtigt.
    function TestAddition(A, B: Integer): string;
  end;

// Wandelt einen TValue in ein Python-Literal. Public, weil auch der
// mtCSharp-Zweig im MessageHandler darauf zugreift.
function TValueToPyLiteral(const AValue: TValue): string;

var
  dmCSharp: TdmCSharp;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs,
  PythonDm, System.SyncObjs, ZentraleDatenDm;

// Python-String-Literal: einfache Anfuehrungszeichen, Backslash und Umbrueche
// escapen. Ohne das zerlegt ein Apostroph im Text den ganzen Aufruf.
function PyQuote(const S: string): string;
var
  LTmp: string;
begin
  LTmp := StringReplace(S, '\', '\\', [rfReplaceAll]);
  LTmp := StringReplace(LTmp, '''', '\''', [rfReplaceAll]);
  LTmp := StringReplace(LTmp, #13#10, '\n', [rfReplaceAll]);
  LTmp := StringReplace(LTmp, #10, '\n', [rfReplaceAll]);
  LTmp := StringReplace(LTmp, #13, '\n', [rfReplaceAll]);
  Result := '''' + LTmp + '''';
end;

function TValueToPyLiteral(const AValue: TValue): string;
var
  LFmt: TFormatSettings;
begin
  case AValue.Kind of
    tkInteger, tkInt64:
      Result := AValue.ToString;
    tkFloat:
      begin
        // Punkt als Dezimaltrenner erzwingen — mit deutschem Komma waere
        // '1,5' in Python ein Tupel aus zwei Argumenten statt einer Zahl.
        LFmt := TFormatSettings.Invariant;
        Result := FloatToStr(AValue.AsExtended, LFmt);
      end;
    tkUString, tkString, tkLString, tkWString:
      Result := PyQuote(AValue.AsString);
    tkEnumeration:
      if AValue.TypeInfo = TypeInfo(Boolean) then
      begin
        if AValue.AsBoolean then Result := 'True' else Result := 'False';
      end
      else
        raise Exception.CreateFmt(
          'Aufzaehlungstyp %s kann nicht an die C#-Seite uebergeben werden. ' +
          'Bitte als Integer oder String uebergeben.', [AValue.TypeInfo.Name]);
  else
    raise Exception.CreateFmt(
      'Typ %s kann nicht ueber die C#-Bruecke uebergeben werden. ' +
      'Erlaubt sind Integer, Int64, Double, String und Boolean — groessere ' +
      'Strukturen gehoeren in die Datenbank, nicht in den Aufruf.',
      [AValue.TypeInfo.Name]);
  end;
end;

var
  GSperreCSharp: TCriticalSection;

class function TdmCSharp.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmCSharp) then
  begin
    GSperreCSharp.Enter;
    try
      if not Assigned(dmCSharp) then
        Application.CreateForm(TdmCSharp, dmCSharp);
    finally
      GSperreCSharp.Leave;
    end;
  end;
  Result := dmCSharp;
end;

function TdmCSharp.Engine: TPythonEngine;
begin
  if not Assigned(PythonDm.dmPython) then
    raise Exception.Create('TdmPython ist nicht erzeugt — im .dpr muss ' +
      'dmPython VOR dmCSharp angelegt werden.');
  Result := PythonDm.dmPython.Engine;
end;

function TdmCSharp.Verfuegbar: Boolean;
begin
  Result := Assigned(PythonDm.dmPython)
        and Assigned(PythonDm.dmPython.Engine)
        and PythonDm.dmPython.Engine.Initialized;
end;

function TdmCSharp.Call(const AModul, AFunktion: string;
  const AArgs: array of TValue): string;
var
  I: Integer;
  LArgs, LCode: string;
begin
  if not Verfuegbar then
    raise Exception.Create('Die Python-Engine ist nicht bereit — ohne sie ' +
      'kann die C#-Seite nicht aufgerufen werden.');

  LArgs := '';
  for I := Low(AArgs) to High(AArgs) do
  begin
    if LArgs <> '' then
      LArgs := LArgs + ', ';
    LArgs := LArgs + TValueToPyLiteral(AArgs[I]);
  end;

  LCode := Format('import %s%s_cs_result = %s.%s(%s)',
    [AModul, sLineBreak, AModul, AFunktion, LArgs]);
  try
    Engine.ExecString(LCode);
    Result := Engine.EvalStringAsStr('_cs_result');
  except
    on E: Exception do
      // Python-/CLR-Fehler verstaendlich weiterreichen: ohne den Aufruftext
      // sucht man sonst lange, welcher Aufruf gescheitert ist.
      raise Exception.CreateFmt(
        'Aufruf der C#-Seite fehlgeschlagen.'#13#10 +
        'Aufruf: %s.%s(%s)'#13#10'Fehler: %s',
        [AModul, AFunktion, LArgs, E.Message]);
  end;
end;

function TdmCSharp.CallSimple(const AModul, AFunktion: string): string;
begin
  Result := Call(AModul, AFunktion, []);
end;

function TdmCSharp.TestAddition(A, B: Integer): string;
begin
  Result := Call('cs_caller', 'call_cs_add', [A, B]);
end;



initialization
  GSperreCSharp := TCriticalSection.Create;

finalization
  GSperreCSharp.Free;

end.
