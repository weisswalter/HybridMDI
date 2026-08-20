program ZentralLaderTest;

{
  Testlader fuer das zentrale Datenmodul — ohne IDE, ohne GUI.

  Zweck: messen, wie lange das Laden aller Tabellen wirklich dauert, und
  zwar gegen die lokale Datenbank UND gegen den Server. Ohne diese zwei
  Zahlen nebeneinander ist die ganze Idee nur eine Behauptung.

  Aufruf:
    ZentralLaderTest <Host> <Port> <Benutzer> <Passwort> <Datenbank> [Threads]

  Beispiel lokal:   ZentralLaderTest localhost 5432 postgres postgres TRTHeisenberg 4
  Beispiel Server:  ZentralLaderTest localhost 5455 postgres GEHEIM  TRTHeisenberg 4
                    (5455 = SSH-Tunnel auf den netcup-Server)
}

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  Vcl.Forms,
  FireDAC.Comp.Client,
  ZentraleDatenDm in '..\ZentraleDatenDm.pas' {dmZentraleDaten: TDataModule};

var
  GModul: TdmZentraleDaten;

// Diese Tabellen bleiben absichtlich draussen: Blob-Traeger und alles, was
// unbegrenzt waechst. Die holt man einzeln, wenn sie jemand anschaut.
function Ausnahmen: TArray<string>;
begin
  Result := ['dokument', 'artikel_foto', 'email_nachricht', 'email_anhang',
             'audit_log'];
end;

procedure Zeile(const S: string);
begin
  Writeln(S);
end;

procedure TabellenAusgeben;
var
  LNamen: TStringList;
  LName:  string;
  LTab:   TFDMemTable;
  LSumme: Integer;
begin
  LNamen := TStringList.Create;
  try
    GModul.TabellenNamen(LNamen);
    LSumme := 0;
    for LName in LNamen do
    begin
      LTab := GModul.Tabelle(LName);
      if Assigned(LTab) and (LTab.RecordCount > 0) then
      begin
        Zeile(Format('  %-34s %7d Zeilen', [LName, LTab.RecordCount]));
        Inc(LSumme, LTab.RecordCount);
      end;
    end;
    Zeile('');
    Zeile(Format('  %-34s %7d Tabellen, %d Zeilen gesamt',
      ['SUMME (nur nicht-leere gelistet)', LNamen.Count, LSumme]));
  finally
    LNamen.Free;
  end;
end;

// Der eigentliche Beweis: Ein Klon filtert, ohne das Original zu bewegen.
procedure KlonProbe(const ATabelle: string);
var
  LOriginal, LKlonA, LKlonB: TFDMemTable;
begin
  Zeile('');
  Zeile('--- Klonprobe auf ' + ATabelle + ' ---');
  LOriginal := GModul.Tabelle(ATabelle);
  if not Assigned(LOriginal) or (LOriginal.RecordCount = 0) then
  begin
    Zeile('  uebersprungen (Tabelle leer oder nicht geladen)');
    Exit;
  end;

  LKlonA := GModul.HoleKlon(ATabelle);
  LKlonB := GModul.HoleKlon(ATabelle);
  try
    Zeile(Format('  Original: %d Zeilen, Satz %d',
      [LOriginal.RecordCount, LOriginal.RecNo]));

    // Klon A springt ans Ende, Klon B bleibt vorne
    LKlonA.Last;
    Zeile(Format('  Klon A nach Last:  Satz %d von %d',
      [LKlonA.RecNo, LKlonA.RecordCount]));
    Zeile(Format('  Klon B unberuehrt: Satz %d von %d',
      [LKlonB.RecNo, LKlonB.RecordCount]));
    Zeile(Format('  Original immer noch: Satz %d', [LOriginal.RecNo]));
    Zeile('  -> eigener Satzzeiger je Klon, gemeinsame Daten');
  finally
    LKlonA.Free;
    LKlonB.Free;
  end;
end;

var
  LHost, LPort, LUser, LPass, LDb: string;
  LThreads: Integer;
  LUhr: TStopwatch;
  LGesamt: Int64;
begin
  try
    if ParamCount < 5 then
    begin
      Zeile('Aufruf: ZentralLaderTest <Host> <Port> <Benutzer> <Passwort> ' +
            '<Datenbank> [Threads]');
      Halt(1);
    end;

    LHost := ParamStr(1);
    LPort := ParamStr(2);
    LUser := ParamStr(3);
    LPass := ParamStr(4);
    LDb   := ParamStr(5);
    if ParamCount >= 6 then
      LThreads := StrToIntDef(ParamStr(6), 4)
    else
      LThreads := 4;

    Zeile('== Zentrales Datenmodul — Ladetest ==');
    Zeile(Format('Ziel: %s:%s/%s als %s, %d Threads',
      [LHost, LPort, LDb, LUser, LThreads]));
    Zeile('');

    GModul := TdmZentraleDaten.Create(nil);
    try
      GModul.AnzahlKanaele := LThreads;

      LUhr := TStopwatch.StartNew;
      GModul.StartenMit(LHost, LPort, LUser, LPass, LDb);
      Zeile(Format('Verbindung steht nach %d ms', [LUhr.ElapsedMilliseconds]));

      LUhr := TStopwatch.StartNew;
      GModul.RegistriereAlle(Ausnahmen);
      Zeile(Format('Tabellenliste geholt nach %d ms',
        [LUhr.ElapsedMilliseconds]));

      Zeile('');
      Zeile('Laden laeuft ...');
      LUhr := TStopwatch.StartNew;
      GModul.LadenStarten;
      GModul.AufEndeWarten;
      LGesamt := LUhr.ElapsedMilliseconds;

      Zeile('');
      TabellenAusgeben;
      Zeile('');
      Zeile(Format('LADEZEIT GESAMT: %d ms  (%d Threads)',
        [LGesamt, LThreads]));

      KlonProbe('person');
      KlonProbe('konto');
    finally
      GModul.Free;
    end;
  except
    on E: Exception do
    begin
      Zeile('FEHLER: ' + E.ClassName + ': ' + E.Message);
      Halt(2);
    end;
  end;
end.
