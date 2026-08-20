program MemSchreibTest;

{
  Prueft den Weg "im Speicher arbeiten, gesammelt zurueckschreiben" gegen eine
  echte Datenbank — ohne GUI.

  Aufruf: MemSchreibTest <Host> <Port> <Benutzer> <Passwort> <Datenbank>

  Legt eine Testperson an, aendert sie, loescht sie wieder — und raeumt am
  Ende hinter sich auf.
}

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Diagnostics,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Data.DB,
  uMemTabellen in '..\uMemTabellen.pas';

var
  GConn: TFDConnection;
  GMem:  TFDMemTable;
  GHerk: TMemHerkunft;
  GUhr:  TStopwatch;
  GId:   Integer;

procedure Zeile(const S: string);
begin
  Writeln(S);
end;

function ZaehleInDb(const AWo: string): Integer;
var Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := GConn;
    Q.SQL.Text := 'SELECT count(*) FROM person WHERE ' + AWo;
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

begin
  if ParamCount < 5 then
  begin
    Zeile('Aufruf: MemSchreibTest <Host> <Port> <Benutzer> <Passwort> <DB>');
    Halt(1);
  end;

  GConn := TFDConnection.Create(nil);
  GMem  := TFDMemTable.Create(nil);
  try
    try
      GConn.LoginPrompt := False;
      GConn.Params.Values['DriverID']  := 'PG';
      GConn.Params.Values['Server']    := ParamStr(1);
      GConn.Params.Values['Port']      := ParamStr(2);
      GConn.Params.Values['User_Name'] := ParamStr(3);
      GConn.Params.Values['Password']  := ParamStr(4);
      GConn.Params.Values['Database']  := ParamStr(5);
      GConn.Connected := True;
      Zeile('Verbindung steht.');

      GHerk := Herkunft('person', 'person_id', 'person_id');

      // ── Laden ───────────────────────────────────────────────────────────
      GUhr := TStopwatch.StartNew;
      Laden(GMem, GConn, GHerk.SQL);
      Zeile(Format('Geladen: %d Zeilen in %d ms',
        [GMem.RecordCount, GUhr.ElapsedMilliseconds]));

      // ── Im Speicher arbeiten ────────────────────────────────────────────
      GUhr := TStopwatch.StartNew;
      GMem.Append;
      GMem.FieldByName('typ_id').AsInteger := 1;
      GMem.FieldByName('nachname_firmenname').AsString := 'MemTest_Weg';
      GMem.FieldByName('vorname').AsString := 'Probe';
      GMem.Post;
      Zeile(Format('Anlegen im Speicher: %d ms, offene Aenderungen: %d',
        [GUhr.ElapsedMilliseconds, GMem.ChangeCount]));

      Zeile(Format('In der Datenbank steht sie noch NICHT: %d Treffer',
        [ZaehleInDb('nachname_firmenname = ''MemTest_Weg''')]));

      // ── Gesammelt zurueckschreiben ──────────────────────────────────────
      GUhr := TStopwatch.StartNew;
      Zeile(Format('Zurueckgeschrieben: %d Zeilen in %d ms',
        [Zurueckschreiben(GMem, GConn, GHerk), GUhr.ElapsedMilliseconds]));
      Zeile(Format('Jetzt in der Datenbank: %d Treffer',
        [ZaehleInDb('nachname_firmenname = ''MemTest_Weg''')]));

      // ── Aendern ─────────────────────────────────────────────────────────
      if GMem.Locate('nachname_firmenname', 'MemTest_Weg', []) then
      begin
        GId := GMem.FieldByName('person_id').AsInteger;
        Zeile(Format('Vom Server vergebene ID im Speicher: %d', [GId]));
        GMem.Edit;
        GMem.FieldByName('vorname').AsString := 'Geaendert';
        GMem.Post;
        Zurueckschreiben(GMem, GConn, GHerk);
        Zeile(Format('Nach Aenderung in der Datenbank: %d Treffer',
          [ZaehleInDb('vorname = ''Geaendert'' AND nachname_firmenname = ''MemTest_Weg''')]));
      end
      else
        Zeile('FEHLER: angelegte Zeile im Speicher nicht wiedergefunden.');

      // ── Loeschen und aufraeumen ─────────────────────────────────────────
      if GMem.Locate('nachname_firmenname', 'MemTest_Weg', []) then
      begin
        GMem.Delete;
        Zurueckschreiben(GMem, GConn, GHerk);
      end;
      Zeile(Format('Nach dem Loeschen: %d Treffer (soll 0 sein)',
        [ZaehleInDb('nachname_firmenname = ''MemTest_Weg''')]));

      // Sicherheitsnetz, falls oben etwas schiefging
      GConn.ExecSQL('DELETE FROM person WHERE nachname_firmenname = ''MemTest_Weg''');
      Zeile('Aufgeraeumt.');
    except
      on E: Exception do
      begin
        Zeile('FEHLER: ' + E.ClassName + ': ' + E.Message);
        try
          GConn.ExecSQL('DELETE FROM person WHERE nachname_firmenname = ''MemTest_Weg''');
        except
        end;
        Halt(2);
      end;
    end;
  finally
    GMem.Free;
    GConn.Free;
  end;
end.
