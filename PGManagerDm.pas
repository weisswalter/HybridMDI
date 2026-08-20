unit PGManagerDm;

// BL des DB-Managers — aus PostgresTest1 (uDmPGManager) uebernommen und an die
// Heisenberg-Modulkonvention angepasst: von TdmModuleTemplate abgeleitet,
// GetInstance + OpenPGManager als MessageHandler-Einstieg (OpenGui('PGManager')).
// GUI-Gegenstueck: PGManagerFrm (TfrmPGManager).
//
// Die Verbindung ist bewusst die EIGENE des Managers (Server-Ebene). Ueber
// ConnectDB kann gezielt eine Datenbank gewaehlt werden (z.B. TRTHeisenberg),
// damit Skripte/Tabellen dort laufen. Profile in JSON, Passwort leicht
// verschleiert (Pitch — echte Verschluesselung spaeter).
//
// LOGGING: bewusst ENTFERNT. Die frueheren OnLog-Callbacks sind als
// "// LOG:"-Marker stehengeblieben. Hier kommt spaeter der zentrale
// Log-Thread/-Server rein (asynchrone Queue -> EventBus/mtException/mtMessage).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
  uTunnel,
  Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin,
  Vcl.Forms,
  udmModuleTemplate, FireDAC.Stan.Util, System.NetEncoding;

type
  TdmPGManager = class(TdmModuleTemplate)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDTable1: TFDTable;
    DataSource1: TDataSource;
    FDMemTable_Profiles: TFDMemTable;
    FDMemTable_DB: TFDMemTable;
    FDMemTable_TS: TFDMemTable;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    DataSource4: TDataSource;
    FDMemTable_Tables: TFDMemTable;
    DataSource5: TDataSource;
    fdScript: TFDScript;
    dsQuery: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FActiveDatabase: string;
    FTunnel: TSshTunnel;
    procedure InitMemTables;
    // Baut den SSH-Tunnel auf, falls noch keiner steht, und liefert den
    // lokalen Port zurueck. 0 = kein Tunnel zustande gekommen.
    function TunnelOeffnen(const AServer, ABenutzer,
      ASchluessel: string): Integer;
  public
    // Heisenberg-Modul-Einstieg (OpenGui('PGManager') / mtModulCall)
    class function GetInstance: TObject;
    procedure OpenPGManager;

    // Verbindung
    procedure Connect(const AHost, APort, AUser, APassword: string);
    procedure ConnectDB(const AHost, APort, AUser, APassword, ADatabase: string);
    function  TestConnection(const AHost, APort, AUser, APassword, ADatabase: string): Boolean;
    procedure Disconnect;
    procedure ConnectToPostgres;
    function  IsConnected: Boolean;
    function  ActiveDatabase: string;

    // Datenbanken / Tablespaces / Tabellennamen laden
    procedure LoadDatabases;
    procedure LoadTablespaces;
    procedure LoadTableNames;   // alle Tabellen der aktuellen DB (public)

    // Datenbank / Tablespace anlegen
    procedure CreateTablespace(const AName, APath: string);
    procedure CreateDatabase(const AName, ATablespace: string);

    // SQL / Skript / Tabelle
    procedure RunScript(const ASQL: string);          // mehrere Statements (TFDScript)
    procedure RunScriptFile(const APath: string);      // .sql-Datei -> RunScript
    procedure OpenQuery(const ASQL: string);           // SELECT -> Ergebnis in dsQuery
    procedure OpenTable(const ATableName: string);     // Tabelle per Name, live editierbar

    // Profile (JSON)
    function  GetJSONPath: string;
    procedure SaveProfile(const AName, AHost, APort, AUser, APassword,
                          ADatabase, ATablespace: string);
    procedure SaveProfilesToJSON;
    procedure LoadProfilesFromJSON;
    procedure DeleteCurrentProfile;
    procedure TouchCurrentProfile;   // ZuletztVerwendet = jetzt, speichern
    // leichte, portable Verschleierung (Pitch) — echte Verschluesselung spaeter
    function  Obfuscate(const S: string): string;
    function  Deobfuscate(const S: string): string;
  end;

var
  dmPGManager: TdmPGManager;

implementation

{$R *.dfm}

uses
  PGManagerFrm, System.SyncObjs, ZentraleDatenDm;

const
  OBF_KEY = 'Heisenberg-DBMgr-Key-2026';

var
  GSperrePGManager: TCriticalSection;

class function TdmPGManager.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmPGManager) then
  begin
    GSperrePGManager.Enter;
    try
      if not Assigned(dmPGManager) then
        Application.CreateForm(TdmPGManager, dmPGManager);
    finally
      GSperrePGManager.Leave;
    end;
  end;
  Result := dmPGManager;
end;

procedure TdmPGManager.OpenPGManager;
begin
  if not Assigned(frmPGManager) then
    frmPGManager := TfrmPGManager.Create(Application);
  frmPGManager.Show;
end;

procedure TdmPGManager.DataModuleCreate(Sender: TObject);
{$IFDEF DEBUG}
var
  LPort: Integer;
{$ENDIF}
begin
  InitMemTables;
  DataSource2.DataSet := FDMemTable_Profiles;
  DataSource3.DataSet := FDMemTable_DB;
  DataSource4.DataSet := FDMemTable_TS;
  DataSource5.DataSet := FDMemTable_Tables;
  dsQuery.DataSet     := FDQuery1;   // SQL-Ergebnis-Grid (SELECT)

  if FileExists(GetJSONPath) then
    LoadProfilesFromJSON;

  // ── SSH-Tunnel stillgelegt ────────────────────────────────────────────────
  // Seit dem Umbau haelt das zentrale Datenmodul die einzige Verbindung, und
  // die geht direkt ueber Tailscale. Der Tunnel darunter wuerde nur noch eine
  // zweite, langsamere Leitung aufmachen, die niemand benutzt - samt eigener
  // ssh.exe bei jedem Debug-Start.
  //
  // Der Code bleibt bewusst stehen: wer kein Tailscale hat, kommt ueber den
  // Tunnel an den Server. Zum Reaktivieren einfach dieses Exit loeschen.
  Exit;

  {$IFDEF DEBUG}
  // Entwicklungsphase: automatisch mit der lokalen Heisenberg-DB verbinden,
  // damit sich Module (ArtikelStamm, Personen, Lager, ...) ohne den manuellen
  // PGManager-Schritt oeffnen lassen. NUR im Debug-Build aktiv — im
  // Release-Build erfolgt die Verbindung ueber die PGManager-GUI/Profile.
  try
    // Entwicklungszugang auf den netcup-Server. Erst den Tunnel, dann
    // ueber DESSEN Port -- frueher stand hier fest '5455', und wenn dort
    // zufaellig etwas anderes horchte, verband sich Heisenberg
    // stillschweigend dorthin.
    LPort := TunnelOeffnen('159.195.218.117', 'wwe123',
      GetEnvironmentVariable('USERPROFILE') + '\.ssh\id_ed25519');
    if LPort = 0 then
      raise Exception.Create('Tunnel kam nicht zustande: ' + FTunnel.Fehler);
    ConnectDB('localhost', IntToStr(LPort), 'wwe123',
      'a4cX7pAp29WRK7XHkGHBzs4DIhjAM14Z', 'TRTHeisenberg');
  except
    // DB nicht erreichbar (z.B. Postgres nicht gestartet) -> stillschweigend
    // weiter; der "Bitte zuerst verbinden"-Hinweis in den Modulen greift dann
    // wie gehabt.
  end;
  {$ENDIF}
end;

// Baut den Tunnel selbst auf, statt sich auf einen zufaellig offenen zu
// verlassen. Der lokale Port wird gesucht, nicht geraten: ein belegter
// Port laesst den Tunnel still scheitern, und die Anwendung landet dann
// unbemerkt auf einer anderen Datenbank.
function TdmPGManager.TunnelOeffnen(const AServer, ABenutzer,
  ASchluessel: string): Integer;
begin
  Result := 0;
  if not Assigned(FTunnel) then
    FTunnel := TSshTunnel.Create;
  if FTunnel.Laeuft then
    Exit(FTunnel.LokalerPort);

  FTunnel.Server      := AServer;
  FTunnel.Benutzer    := ABenutzer;
  FTunnel.Schluessel  := ASchluessel;
  FTunnel.ZielHost    := '127.0.0.1';
  FTunnel.ZielPort    := 5432;
  FTunnel.LokalerPort := 0;          // 0 = freien Port suchen

  if FTunnel.Oeffnen(15000) then
    Result := FTunnel.LokalerPort;
end;

procedure TdmPGManager.DataModuleDestroy(Sender: TObject);
begin
  // Ohne das bleibt ssh.exe stehen und belegt den Port beim naechsten Start.
  FreeAndNil(FTunnel);
  if FDMemTable_Profiles.RecordCount > 0 then
  try
    FDMemTable_Profiles.SaveToFile(GetJSONPath, sfJSON);
  except
  end;
end;

procedure TdmPGManager.InitMemTables;
begin
  with FDMemTable_Profiles do
  begin
    FieldDefs.Add('ProfilName',       ftString,  80);
    FieldDefs.Add('Host',             ftString, 100);
    FieldDefs.Add('Port',             ftInteger);
    FieldDefs.Add('Benutzer',         ftString,  80);
    FieldDefs.Add('Passwort',         ftString, 200);  // verschleiert (Base64)
    FieldDefs.Add('Datenbank',        ftString, 100);
    FieldDefs.Add('Tablespace',       ftString, 100);
    FieldDefs.Add('ZuletztVerwendet', ftDateTime);
    CreateDataSet;
    FieldByName('Passwort').Visible := False;          // nicht im Grid zeigen
    IndexFieldNames := 'ZuletztVerwendet:D';           // zuletzt genutztes oben
  end;

  with FDMemTable_DB do
  begin
    FieldDefs.Add('Datenbank',    ftString, 100);
    FieldDefs.Add('Eigent'#252'mer', ftString,  80);
    FieldDefs.Add('Encoding',     ftString,  30);
    FieldDefs.Add('Gr'#246#223'e',      ftString,  30);
    CreateDataSet;
  end;

  with FDMemTable_TS do
  begin
    FieldDefs.Add('Tablespace',   ftString, 100);
    FieldDefs.Add('Eigent'#252'mer', ftString,  80);
    FieldDefs.Add('Pfad',         ftString, 255);
    CreateDataSet;
  end;

  with FDMemTable_Tables do
  begin
    FieldDefs.Add('Tabelle', ftString, 100);
    CreateDataSet;
  end;
end;

procedure TdmPGManager.ConnectDB(const AHost, APort, AUser, APassword, ADatabase: string);
begin
  if FDConnection1.Connected then
    FDConnection1.Connected := False;
  FDConnection1.Params.Values['Server']    := AHost;
  FDConnection1.Params.Values['Port']      := APort;
  FDConnection1.Params.Values['User_Name'] := AUser;
  FDConnection1.Params.Values['Password']  := APassword;
  FDConnection1.Params.Values['Database']  := ADatabase;
  FDConnection1.Connected := True;
  FActiveDatabase := ADatabase;
end;

procedure TdmPGManager.Connect(const AHost, APort, AUser, APassword: string);
begin
  ConnectDB(AHost, APort, AUser, APassword, 'postgres');
end;

function TdmPGManager.TestConnection(const AHost, APort, AUser, APassword, ADatabase: string): Boolean;
var
  C: TFDConnection;
begin
  Result := False;
  C := TFDConnection.Create(nil);
  try
    C.LoginPrompt := False;
    C.Params.Values['DriverID']  := 'PG';
    C.Params.Values['Server']    := AHost;
    C.Params.Values['Port']      := APort;
    C.Params.Values['User_Name'] := AUser;
    C.Params.Values['Password']  := APassword;
    C.Params.Values['Database']  := ADatabase;
    try
      C.Connected := True;
      Result := C.Connected;
      C.Connected := False;
      // LOG: 'Verbindungstest OK: ' + ADatabase + '@' + AHost
    except
      on E: Exception do
      begin
        // LOG: 'Verbindungstest FEHLER: ' + E.Message
      end;
    end;
  finally
    C.Free;
  end;
end;

procedure TdmPGManager.Disconnect;
begin
  FDConnection1.Connected := False;
end;

procedure TdmPGManager.ConnectToPostgres;
begin
  if FDConnection1.Connected then
    FDConnection1.Connected := False;
  FDConnection1.Params.Values['Database'] := 'postgres';
  FDConnection1.Connected := True;
  FActiveDatabase := 'postgres';
end;

function TdmPGManager.IsConnected: Boolean;
begin
  Result := FDConnection1.Connected;
end;

function TdmPGManager.ActiveDatabase: string;
begin
  if FDConnection1.Connected then
    Result := FActiveDatabase
  else
    Result := '(nicht verbunden)';
end;

function TdmPGManager.GetJSONPath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'pg_connections.json');
end;

procedure TdmPGManager.LoadDatabases;
var
  LQry: TFDQuery;
begin
  FDMemTable_DB.EmptyDataSet;
  LQry := TFDQuery.Create(nil);
  try
    try
      LQry.Connection := FDConnection1;
      LQry.SQL.Text :=
        'SELECT d.datname, r.rolname, ' +
        '       pg_encoding_to_char(d.encoding), ' +
        '       pg_size_pretty(pg_database_size(d.datname)) ' +
        'FROM pg_database d ' +
        'JOIN pg_roles r ON r.oid = d.datdba ' +
        'WHERE d.datistemplate = false ORDER BY d.datname';
      LQry.Open;
      while not LQry.Eof do
      begin
        FDMemTable_DB.Append;
        FDMemTable_DB.FieldByName('Datenbank').AsString    := LQry.Fields[0].AsString;
        FDMemTable_DB.FieldByName('Eigent'#252'mer').AsString  := LQry.Fields[1].AsString;
        FDMemTable_DB.FieldByName('Encoding').AsString     := LQry.Fields[2].AsString;
        FDMemTable_DB.FieldByName('Gr'#246#223'e').AsString      := LQry.Fields[3].AsString;
        FDMemTable_DB.Post;
        LQry.Next;
      end;
      // LOG: IntToStr(FDMemTable_DB.RecordCount) + ' Datenbank(en) gefunden.'
    except
      on E: Exception do
      begin
        // LOG: 'FEHLER Datenbanken: ' + E.Message
      end;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmPGManager.LoadTablespaces;
var
  LQry: TFDQuery;
begin
  FDMemTable_TS.EmptyDataSet;
  LQry := TFDQuery.Create(nil);
  try
    try
      LQry.Connection := FDConnection1;
      LQry.SQL.Text :=
        'SELECT t.spcname, r.rolname, pg_tablespace_location(t.oid) ' +
        'FROM pg_tablespace t ' +
        'JOIN pg_roles r ON r.oid = t.spcowner ORDER BY t.spcname';
      LQry.Open;
      while not LQry.Eof do
      begin
        FDMemTable_TS.Append;
        FDMemTable_TS.FieldByName('Tablespace').AsString   := LQry.Fields[0].AsString;
        FDMemTable_TS.FieldByName('Eigent'#252'mer').AsString  := LQry.Fields[1].AsString;
        FDMemTable_TS.FieldByName('Pfad').AsString         := LQry.Fields[2].AsString;
        FDMemTable_TS.Post;
        LQry.Next;
      end;
      // LOG: IntToStr(FDMemTable_TS.RecordCount) + ' Tablespace(s) gefunden.'
    except
      on E: Exception do
      begin
        // LOG: 'FEHLER Tablespaces: ' + E.Message
      end;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmPGManager.LoadTableNames;
var
  LQry: TFDQuery;
begin
  FDMemTable_Tables.EmptyDataSet;
  LQry := TFDQuery.Create(nil);
  try
    try
      LQry.Connection := FDConnection1;
      LQry.SQL.Text :=
        'SELECT table_name FROM information_schema.tables ' +
        'WHERE table_schema = ''public'' AND table_type = ''BASE TABLE'' ' +
        'ORDER BY table_name';
      LQry.Open;
      while not LQry.Eof do
      begin
        FDMemTable_Tables.Append;
        FDMemTable_Tables.FieldByName('Tabelle').AsString := LQry.Fields[0].AsString;
        FDMemTable_Tables.Post;
        LQry.Next;
      end;
      // LOG: IntToStr(FDMemTable_Tables.RecordCount) + ' Tabelle(n).'
    except
      on E: Exception do
      begin
        // LOG: 'FEHLER Tabellennamen: ' + E.Message
      end;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmPGManager.CreateTablespace(const AName, APath: string);
var
  LSQL: string;
begin
  if not DirectoryExists(APath) then
    ForceDirectories(APath);
  LSQL := Format('CREATE TABLESPACE %s LOCATION ''%s''', [AName, APath]);
  // LOG: 'Ausfuehren: ' + LSQL
  try
    ConnectToPostgres;
    FDConnection1.ExecSQL(LSQL);
    // LOG: 'Tablespace "' + AName + '" angelegt.'
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER: ' + E.Message
    end;
  end;
end;

procedure TdmPGManager.CreateDatabase(const AName, ATablespace: string);
var
  LSQL: string;
begin
  if ATablespace <> '' then
    LSQL := Format('CREATE DATABASE %s TABLESPACE %s', [AName, ATablespace])
  else
    LSQL := Format('CREATE DATABASE %s', [AName]);
  LSQL := LSQL + ' ENCODING ''UTF8''';
  // LOG: 'Ausfuehren: ' + LSQL
  try
    ConnectToPostgres;
    FDConnection1.ExecSQL(LSQL);
    // LOG: 'Datenbank "' + AName + '" angelegt.'
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER: ' + E.Message
      // LOG: 'Hinweis: Tablespace muss vorher existieren.'
    end;
  end;
end;

// --- SQL / Skript / Tabelle ------------------------------------------------

procedure TdmPGManager.RunScript(const ASQL: string);
begin
  fdScript.SQLScripts.Clear;
  fdScript.SQLScripts.Add.SQL.Text := ASQL;
  try
    fdScript.ExecuteAll;
    // LOG: 'Skript ausgefuehrt.'
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER Skript: ' + E.Message
    end;
  end;
end;

procedure TdmPGManager.RunScriptFile(const APath: string);
begin
  if not FileExists(APath) then
  begin
    // LOG: 'Datei nicht gefunden: ' + APath
    Exit;
  end;
  // LOG: 'Lade Skript: ' + APath
  RunScript(TFile.ReadAllText(APath));
end;

procedure TdmPGManager.OpenQuery(const ASQL: string);
begin
  try
    FDQuery1.Close;
    FDQuery1.SQL.Text := ASQL;
    FDQuery1.Open;
    // LOG: IntToStr(FDQuery1.RecordCount) + ' Zeile(n).'
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER Abfrage: ' + E.Message
    end;
  end;
end;

procedure TdmPGManager.OpenTable(const ATableName: string);
begin
  try
    FDTable1.Close;
    FDTable1.TableName := ATableName;
    FDTable1.Open;
    // LOG: 'Tabelle "' + ATableName + '" geoeffnet (' + IntToStr(FDTable1.RecordCount) + ' Zeilen).'
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER Tabelle: ' + E.Message
    end;
  end;
end;

// --- Profile ---------------------------------------------------------------

procedure TdmPGManager.SaveProfile(const AName, AHost, APort, AUser, APassword,
  ADatabase, ATablespace: string);
begin
  FDMemTable_Profiles.First;
  while not FDMemTable_Profiles.Eof do
  begin
    if FDMemTable_Profiles.FieldByName('ProfilName').AsString = AName then
    begin
      FDMemTable_Profiles.Delete;
      Break;
    end;
    FDMemTable_Profiles.Next;
  end;
  FDMemTable_Profiles.Append;
  FDMemTable_Profiles.FieldByName('ProfilName').AsString         := AName;
  FDMemTable_Profiles.FieldByName('Host').AsString               := AHost;
  FDMemTable_Profiles.FieldByName('Port').AsInteger              := StrToIntDef(APort, 5455);
  FDMemTable_Profiles.FieldByName('Benutzer').AsString           := AUser;
  FDMemTable_Profiles.FieldByName('Passwort').AsString           := Obfuscate(APassword);
  FDMemTable_Profiles.FieldByName('Datenbank').AsString          := ADatabase;
  FDMemTable_Profiles.FieldByName('Tablespace').AsString         := ATablespace;
  FDMemTable_Profiles.FieldByName('ZuletztVerwendet').AsDateTime := Now;
  FDMemTable_Profiles.Post;
  SaveProfilesToJSON;
  // LOG: 'Profil "' + AName + '" gespeichert.'
end;

procedure TdmPGManager.SaveProfilesToJSON;
begin
  try
    FDMemTable_Profiles.SaveToFile(GetJSONPath, sfJSON);
    // LOG: 'Profile gespeichert: ' + GetJSONPath
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER beim Speichern: ' + E.Message
    end;
  end;
end;

procedure TdmPGManager.LoadProfilesFromJSON;
begin
  try
    FDMemTable_Profiles.LoadFromFile(GetJSONPath, sfJSON);
    // LOG: 'Profile geladen (' + IntToStr(FDMemTable_Profiles.RecordCount) + ')'
  except
    on E: Exception do
    begin
      // LOG: 'FEHLER beim Laden: ' + E.Message
    end;
  end;
end;

procedure TdmPGManager.DeleteCurrentProfile;
begin
  if not FDMemTable_Profiles.IsEmpty then
  begin
    FDMemTable_Profiles.Delete;
    SaveProfilesToJSON;
  end;
end;

procedure TdmPGManager.TouchCurrentProfile;
begin
  if FDMemTable_Profiles.IsEmpty then Exit;
  FDMemTable_Profiles.Edit;
  FDMemTable_Profiles.FieldByName('ZuletztVerwendet').AsDateTime := Now;
  FDMemTable_Profiles.Post;
  SaveProfilesToJSON;
end;

function TdmPGManager.Obfuscate(const S: string): string;
var
  b, key: TBytes;
  i: Integer;
begin
  if S = '' then Exit('');
  b   := TEncoding.UTF8.GetBytes(S);
  key := TEncoding.UTF8.GetBytes(OBF_KEY);
  for i := 0 to High(b) do
    b[i] := b[i] xor key[i mod Length(key)];
  Result := TNetEncoding.Base64.EncodeBytesToString(b);
end;

function TdmPGManager.Deobfuscate(const S: string): string;
var
  b, key: TBytes;
  i: Integer;
begin
  if S = '' then Exit('');
  try
    b   := TNetEncoding.Base64.DecodeStringToBytes(S);
    key := TEncoding.UTF8.GetBytes(OBF_KEY);
    for i := 0 to High(b) do
      b[i] := b[i] xor key[i mod Length(key)];
    Result := TEncoding.UTF8.GetString(b);
  except
    Result := S;   // Altbestand im Klartext -> unveraendert zurueck
  end;
end;


initialization
  GSperrePGManager := TCriticalSection.Create;

finalization
  GSperrePGManager.Free;

end.
