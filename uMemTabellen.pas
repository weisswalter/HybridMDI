unit uMemTabellen;

{
  Werkzeug fuer Module, die im Speicher arbeiten.

  GEDANKE (Walter, 03.08.2026): Laden darf dauern, Arbeiten muss sitzen. Also
  einmal alles holen, danach laeuft alles gegen den Speicher, und geschrieben
  wird gesammelt.

  WARUM DIE OPTIONEN IN `Laden` WICHTIG SIND — gemessen am 03.08.2026 gegen
  den Server (16 ms Latenz): Ohne sie kostete EINE Tabelle rund 780 ms, also
  etwa 48 Rundfahrten fuer eine einzige Abfrage. Mit ihnen sind es rund 90 ms.
  Nicht die Daten waren das Problem, sondern das, was FireDAC vor und nach
  jeder Abfrage noch alles fragt: Spalten-, Schluessel- und Indexinformationen
  (fiMeta), das Vorbereiten der Anweisung (Prepare), und die Metadaten fuers
  Zusammenbauen von Update-SQL.

  ZURUECKSCHREIBEN: Die Speichertabelle sammelt Aenderungen (CachedUpdates).
  `Zurueckschreiben` reicht dieses Delta an eine TFDQuery weiter, die eine
  Verbindung hat und daraus das Insert/Update/Delete baut. So bleibt der
  Netzverkehr auf eine Fahrt beim Speichern beschraenkt statt einer pro
  Tastendruck.
}

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.DB;

type
  // Beschreibt, wie eine Speichertabelle zur Datenbank zurueckfindet.
  TMemHerkunft = record
    Tabelle:     string;   // Zieltabelle in der Datenbank
    Schluessel:  string;   // Schluesselfelder, mit ; getrennt
    AutoInc:     string;   // serverseitig vergebene Spalte, meist *_id
    SQL:         string;   // Ladeabfrage; leer = SELECT * FROM Tabelle
  end;

// Setzt die Optionen, die ueber WAN den Unterschied machen. Getrennt
// herausgezogen, damit es auch auf bestehende TFDQuery angewandt werden kann.
procedure SchnellLesen(AQuery: TFDQuery);

// Fuellt eine Speichertabelle aus der Datenbank. Danach ist sie unabhaengig
// von der Verbindung und sammelt Aenderungen.
procedure Laden(AMem: TFDMemTable; AConn: TFDConnection; const ASQL: string;
  const AParamName: string = ''; AParamWert: Integer = 0);

// Fuellt aus einer bereits geladenen Quelle, ohne die Datenbank zu fragen.
// Teilt sich den Speicher mit der Quelle — kostet nichts.
procedure Klonen(AMem: TFDMemTable; AQuelle: TFDMemTable);

// Gibt es ueberhaupt etwas zu speichern?
function HatAenderungen(AMem: TFDMemTable): Boolean;

// Schreibt gesammelte Aenderungen zurueck. Ergebnis: Anzahl der
// uebertragenen Zeilen. Bei einem Fehler bleibt das Delta erhalten, damit
// nichts verloren geht.
function Zurueckschreiben(AMem: TFDMemTable; AConn: TFDConnection;
  const AHerkunft: TMemHerkunft): Integer;

// Bequemer Bau eines TMemHerkunft-Satzes.
function Herkunft(const ATabelle, ASchluessel: string;
  const AAutoInc: string = ''; const ASQL: string = ''): TMemHerkunft;

implementation

function Herkunft(const ATabelle, ASchluessel, AAutoInc,
  ASQL: string): TMemHerkunft;
begin
  Result.Tabelle    := ATabelle;
  Result.Schluessel := ASchluessel;
  Result.AutoInc    := AAutoInc;
  if ASQL <> '' then
    Result.SQL := ASQL
  else
    Result.SQL := 'SELECT * FROM ' + ATabelle;
end;

procedure SchnellLesen(AQuery: TFDQuery);
begin
  // Alles auf einmal holen statt haeppchenweise.
  AQuery.FetchOptions.Mode := fmAll;
  // Keine Spalten-, Schluessel- und Indexinformationen vom Server: hier wird
  // nur gelesen, die Struktur kommt mit dem Ergebnis ohnehin mit.
  AQuery.FetchOptions.Items := AQuery.FetchOptions.Items - [fiMeta];
  // Kein Prepare — das ist eine eigene Fahrt, und die Abfrage laeuft einmal.
  AQuery.ResourceOptions.DirectExecute := True;
  // Ohne Schreibrechte baut FireDAC kein Update-SQL zusammen und fragt
  // dafuer auch keine Schluesselmetadaten ab.
  AQuery.UpdateOptions.RequestLive  := False;
  AQuery.UpdateOptions.EnableInsert := False;
  AQuery.UpdateOptions.EnableUpdate := False;
  AQuery.UpdateOptions.EnableDelete := False;
end;

procedure Laden(AMem: TFDMemTable; AConn: TFDConnection; const ASQL: string;
  const AParamName: string; AParamWert: Integer);
var
  LQry: TFDQuery;
begin
  if not Assigned(AMem) then
    raise Exception.Create('Keine Speichertabelle uebergeben.');
  if not Assigned(AConn) or not AConn.Connected then
    raise Exception.Create('Keine offene Verbindung zum Laden.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConn;
    SchnellLesen(LQry);
    LQry.SQL.Text := ASQL;
    if AParamName <> '' then
      LQry.ParamByName(AParamName).AsInteger := AParamWert;
    LQry.Open;
    LQry.FetchAll;

    AMem.Close;
    AMem.CachedUpdates := True;
    AMem.Data := LQry.Data;               // oeffnet die Tabelle mit
    // Ohne das gilt der geladene Bestand selbst als Aenderung: ChangeCount
    // stand nach dem Laden von 16 Zeilen auf 16, und der erste Speicher-
    // vorgang haette versucht, alles neu einzufuegen.
    AMem.CommitUpdates;
  finally
    LQry.Free;
  end;
end;

procedure Klonen(AMem: TFDMemTable; AQuelle: TFDMemTable);
begin
  if not Assigned(AMem) or not Assigned(AQuelle) then
    raise Exception.Create('Quelle oder Ziel fehlt.');
  AMem.Close;
  // Teilt sich den Datenbestand, hat aber eigenen Satzzeiger, eigenen
  // Filter und eigene Sortierung.
  AMem.CloneCursor(AQuelle, True);
end;

function HatAenderungen(AMem: TFDMemTable): Boolean;
begin
  Result := Assigned(AMem) and AMem.Active and AMem.CachedUpdates
        and (AMem.ChangeCount > 0);
end;

function Zurueckschreiben(AMem: TFDMemTable; AConn: TFDConnection;
  const AHerkunft: TMemHerkunft): Integer;
var
  LQry: TFDQuery;
  LHatNeue: Boolean;
begin
  Result := 0;
  if not HatAenderungen(AMem) then
    Exit;
  if not Assigned(AConn) or not AConn.Connected then
    raise Exception.Create('Keine offene Verbindung zum Speichern.');

  // Sind Neuanlagen dabei? Dann muss hinterher nachgeladen werden — die vom
  // Server per SERIAL vergebene ID landet naemlich in der Abfrage, nicht in
  // der Speichertabelle. Ohne das Nachladen steht dort weiter 0, und das
  // naechste Aendern oder Loeschen trifft keine Zeile. (Gemessen am
  // 03.08.2026: Anlegen ging durch, Aendern und Loeschen liefen ins Leere.)
  // Unit qualifiziert: `rtInserted` gibt es auch in Data.DB, und weil das
  // spaeter in der uses-Liste steht, gewinnt es sonst — mit einem
  // Typfehler, der aussieht, als waere die Zuweisung selbst falsch.
  AMem.FilterChanges := [FireDAC.Comp.DataSet.rtInserted];
  LHatNeue := AMem.RecordCount > 0;
  AMem.FilterChanges := [FireDAC.Comp.DataSet.rtUnmodified,
                         FireDAC.Comp.DataSet.rtModified,
                         FireDAC.Comp.DataSet.rtInserted];

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConn;
    LQry.SQL.Text := AHerkunft.SQL;
    // Struktur holen, aber moeglichst keine Daten — gespeichert wird das
    // Delta, nicht der Bestand.
    LQry.FetchOptions.RecsMax := 1;
    LQry.UpdateOptions.UpdateTableName := AHerkunft.Tabelle;
    LQry.UpdateOptions.KeyFields       := AHerkunft.Schluessel;
    // PostgreSQL vergibt die *_id-Spalten per SERIAL. Ohne diese Angabe
    // schreibt FireDAC sie ins INSERT und holt den erzeugten Wert nicht
    // per RETURNING zurueck — dann bleibt die ID im Datensatz leer.
    if AHerkunft.AutoInc <> '' then
      LQry.UpdateOptions.AutoIncFields := AHerkunft.AutoInc;
    LQry.CachedUpdates := True;

    // Bewusst KEIN Open davor: an eine geoeffnete Datenmenge laesst sich
    // `Data` nicht zuweisen ("Operation bei geoeffneter Datenmenge nicht
    // ausfuehrbar"). Die Zuweisung bringt Struktur und Zeilen mit und
    // oeffnet die Abfrage selbst — die Verbindung braucht sie nur, um
    // daraus Insert/Update/Delete zu bauen.
    Result := AMem.ChangeCount;
    LQry.Data := AMem.Delta;
    LQry.ApplyUpdates(0);
    if LQry.RowsAffected < 0 then
      raise Exception.Create('Speichern fehlgeschlagen: ' + AHerkunft.Tabelle);
    LQry.CommitUpdates;

    // Erst wenn der Server bestaetigt hat, gilt das Delta als erledigt.
    AMem.CommitUpdates;
  finally
    LQry.Free;
  end;

  // Nach Neuanlagen einmal frisch holen, damit die Schluessel stimmen.
  // Das ist eine Fahrt beim Speichern — nicht beim Arbeiten.
  if LHatNeue then
    Laden(AMem, AConn, AHerkunft.SQL);
end;

end.
