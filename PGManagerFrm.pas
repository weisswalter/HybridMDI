unit PGManagerFrm;

// GUI des DB-Managers (MDI-Child) — aus PostgresTest1 (uFrmMain) uebernommen,
// umbenannt (Kollision mit Heisenbergs TfrmMain), von TfrmTemplate abgeleitet.
// Alle DB-Komponenten liegen in der BL (PGManagerDm/TdmPGManager); die Form
// bindet ihre Grids/Navigatoren in FormCreate an deren DataSources.
// Tabs: SQL / Database / Verbindungen / Tabelle. Statuszeile zeigt die aktive DB.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Data.DB,
  JvExStdCtrls, JvMemo, JvDBControls,
  uFrmModuleTemplate, PGManagerDm;

type
  TfrmPGManager = class(TfrmTemplate)
    PageControl1: TPageControl;
    // --- TabSheet1: SQL ---
    TabSheet1: TTabSheet;
    JvMemo1: TJvMemo;
    btnSQL: TButton;
    btnQuery: TButton;
    btnLoadSQL: TButton;
    DBGrid1: TDBGrid;
    JvDBNavigator1: TJvDBNavigator;
    OpenDialogSQL: TOpenDialog;
    // --- TabSheet2: Database ---
    TabSheet2: TTabSheet;
    grpTablespace: TGroupBox;
    lblTsName: TLabel;
    lblTsPath: TLabel;
    edtTsName: TEdit;
    edtTsPath: TEdit;
    btnCreateTablespace: TButton;
    grpDatabase: TGroupBox;
    lblDbName: TLabel;
    lblDbTs: TLabel;
    edtDbName: TEdit;
    edtDbTablespace: TEdit;
    btnCreateDatabase: TButton;
    MemoLog: TMemo;
    // --- TabSheet3: Verbindungen ---
    TabSheet3: TTabSheet;
    grpConn: TGroupBox;
    lblHost: TLabel;
    lblPort: TLabel;
    lblUser: TLabel;
    lblPwd: TLabel;
    lblDatabase: TLabel;
    lblTablespace: TLabel;
    lblProfileName: TLabel;
    lblConnStatus: TLabel;
    edtHost: TEdit;
    edtPort: TEdit;
    edtUser: TEdit;
    edtPassword: TEdit;
    edtDatabase: TEdit;
    edtTablespace: TEdit;
    edtProfileName: TEdit;
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnTestConnection: TButton;
    btnSaveProfile: TButton;
    btnSaveJSON: TButton;
    btnLoadJSON: TButton;
    grpDatabases: TGroupBox;
    DBGrid3: TDBGrid;
    btnLoadDatabases: TButton;
    grpTablespaces: TGroupBox;
    DBGrid4: TDBGrid;
    btnLoadTablespaces: TButton;
    grpProfiles: TGroupBox;
    DBGrid2: TDBGrid;
    btnUseProfile: TButton;
    btnDeleteProfile: TButton;
    // --- TabSheet4: Tabelle ---
    TabSheet4: TTabSheet;
    pnlTableTop: TPanel;
    lblTableName: TLabel;
    edtTableName: TEdit;
    btnOpenTable: TButton;
    navTable: TJvDBNavigator;
    DBGrid5: TDBGrid;
    chkConnected: TCheckBox;
    btnLoadTables: TButton;
    pnlTablesLeft: TPanel;
    dgTables: TDBGrid;
    // --- Statuszeile ---
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSQLClick(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure btnLoadSQLClick(Sender: TObject);
    procedure btnCreateTablespaceClick(Sender: TObject);
    procedure btnCreateDatabaseClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnSaveProfileClick(Sender: TObject);
    procedure btnSaveJSONClick(Sender: TObject);
    procedure btnLoadJSONClick(Sender: TObject);
    procedure btnLoadDatabasesClick(Sender: TObject);
    procedure btnLoadTablespacesClick(Sender: TObject);
    procedure btnUseProfileClick(Sender: TObject);
    procedure btnDeleteProfileClick(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
    procedure DBGrid3DblClick(Sender: TObject);
    procedure DBGrid4DblClick(Sender: TObject);
    procedure btnOpenTableClick(Sender: TObject);
    procedure btnLoadTablesClick(Sender: TObject);
    procedure dgTablesDblClick(Sender: TObject);
  private
    procedure Log(const AMsg: string);
    procedure UpdateStatus;
    function  CurrentDb: string;   // edtDatabase oder 'postgres'
  end;

var
  frmPGManager: TfrmPGManager;

implementation

{$R *.dfm}

procedure TfrmPGManager.Log(const AMsg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss] ', Now) + AMsg);
  MemoLog.Perform(EM_SCROLL, SB_BOTTOM, 0);
end;

procedure TfrmPGManager.UpdateStatus;
begin
  StatusBar1.SimpleText := '  Datenbank: ' + dmPGManager.ActiveDatabase;
  chkConnected.Checked := dmPGManager.IsConnected;
  if dmPGManager.IsConnected then
  begin
    lblConnStatus.Caption := 'verbunden: ' + dmPGManager.ActiveDatabase;
    lblConnStatus.Font.Color := clGreen;
  end
  else
  begin
    lblConnStatus.Caption := 'getrennt';
    lblConnStatus.Font.Color := clRed;
  end;
end;

function TfrmPGManager.CurrentDb: string;
begin
  Result := Trim(edtDatabase.Text);
  if Result = '' then
    Result := 'postgres';
end;

procedure TfrmPGManager.FormCreate(Sender: TObject);
begin
  // Grids/Navigatoren an die DataSources der BL binden
  DBGrid1.DataSource        := dmPGManager.dsQuery;       // SQL-Ergebnis (SELECT)
  JvDBNavigator1.DataSource := dmPGManager.dsQuery;
  DBGrid2.DataSource        := dmPGManager.DataSource2;   // Profile
  DBGrid3.DataSource        := dmPGManager.DataSource3;   // Datenbanken
  DBGrid4.DataSource        := dmPGManager.DataSource4;   // Tablespaces
  DBGrid5.DataSource        := dmPGManager.DataSource1;   // Tabelle (FDTable1)
  navTable.DataSource       := dmPGManager.DataSource1;
  dgTables.DataSource       := dmPGManager.DataSource5;   // Liste aller Tabellennamen

  // Logging der BL entfernt — spaeter Log-Thread/-Server (siehe PGManagerDm).
  // dmPGManager.OnLog := Log;

  edtHost.Text     := 'localhost';
  edtPort.Text     := '5432';
  edtUser.Text     := 'postgres';
  edtPassword.Text := '';
  edtDatabase.Text := 'postgres';
  UpdateStatus;
end;

procedure TfrmPGManager.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmPGManager := nil;
end;

// --- TabSheet1: SQL --------------------------------------------------------

procedure TfrmPGManager.btnSQLClick(Sender: TObject);
begin
  // "Skript ausfuehren" — mehrere Statements (DDL, CREATE FUNCTION ...)
  dmPGManager.RunScript(JvMemo1.Lines.Text);
end;

procedure TfrmPGManager.btnQueryClick(Sender: TObject);
begin
  // "Abfrage (SELECT)" — Ergebnis erscheint im Grid
  dmPGManager.OpenQuery(JvMemo1.Lines.Text);
end;

procedure TfrmPGManager.btnLoadSQLClick(Sender: TObject);
begin
  if OpenDialogSQL.Execute then
    dmPGManager.RunScriptFile(OpenDialogSQL.FileName);
end;

// --- TabSheet2: Database ---------------------------------------------------

procedure TfrmPGManager.btnCreateTablespaceClick(Sender: TObject);
begin
  if Trim(edtTsName.Text) = '' then begin ShowMessage('Bitte Name eingeben.'); Exit; end;
  if Trim(edtTsPath.Text) = '' then begin ShowMessage('Bitte Pfad eingeben.'); Exit; end;
  dmPGManager.CreateTablespace(Trim(edtTsName.Text), Trim(edtTsPath.Text));
end;

procedure TfrmPGManager.btnCreateDatabaseClick(Sender: TObject);
begin
  if Trim(edtDbName.Text) = '' then begin ShowMessage('Bitte Name eingeben.'); Exit; end;
  dmPGManager.CreateDatabase(Trim(edtDbName.Text), Trim(edtDbTablespace.Text));
end;

// --- TabSheet3: Verbindungen -----------------------------------------------

procedure TfrmPGManager.btnConnectClick(Sender: TObject);
begin
  try
    dmPGManager.ConnectDB(edtHost.Text, edtPort.Text, edtUser.Text,
      edtPassword.Text, CurrentDb);
    Log('Verbunden: ' + CurrentDb + '@' + edtHost.Text + ' als ' + edtUser.Text);
    dmPGManager.LoadDatabases;
    dmPGManager.LoadTablespaces;
    dmPGManager.LoadTableNames;
  except
    on E: Exception do Log('FEHLER: ' + E.Message);
  end;
  UpdateStatus;
end;

procedure TfrmPGManager.btnDisconnectClick(Sender: TObject);
begin
  dmPGManager.Disconnect;
  Log('Verbindung getrennt.');
  UpdateStatus;
end;

procedure TfrmPGManager.btnTestConnectionClick(Sender: TObject);
begin
  dmPGManager.TestConnection(edtHost.Text, edtPort.Text, edtUser.Text,
    edtPassword.Text, CurrentDb);
end;

procedure TfrmPGManager.btnSaveProfileClick(Sender: TObject);
begin
  if Trim(edtProfileName.Text) = '' then begin ShowMessage('Bitte Profil-Name eingeben.'); Exit; end;
  dmPGManager.SaveProfile(
    edtProfileName.Text, edtHost.Text, edtPort.Text, edtUser.Text,
    edtPassword.Text, Trim(edtDatabase.Text), Trim(edtTablespace.Text));
end;

procedure TfrmPGManager.btnSaveJSONClick(Sender: TObject);
begin
  dmPGManager.SaveProfilesToJSON;
end;

procedure TfrmPGManager.btnLoadJSONClick(Sender: TObject);
begin
  dmPGManager.LoadProfilesFromJSON;
end;

procedure TfrmPGManager.btnLoadDatabasesClick(Sender: TObject);
begin
  if not dmPGManager.IsConnected then begin Log('Nicht verbunden.'); Exit; end;
  dmPGManager.LoadDatabases;
end;

procedure TfrmPGManager.btnLoadTablespacesClick(Sender: TObject);
begin
  if not dmPGManager.IsConnected then begin Log('Nicht verbunden.'); Exit; end;
  dmPGManager.LoadTablespaces;
end;

// "Profil verwenden" = Felder fuellen (Passwort entschluesselt) und gleich
// zur Profil-Datenbank verbinden; ZuletztVerwendet aktualisieren.
procedure TfrmPGManager.btnUseProfileClick(Sender: TObject);
var
  LDb: string;
begin
  if dmPGManager.FDMemTable_Profiles.IsEmpty then begin ShowMessage('Kein Profil ausgew'#228'hlt.'); Exit; end;
  edtHost.Text        := dmPGManager.FDMemTable_Profiles.FieldByName('Host').AsString;
  edtPort.Text        := dmPGManager.FDMemTable_Profiles.FieldByName('Port').AsString;
  edtUser.Text        := dmPGManager.FDMemTable_Profiles.FieldByName('Benutzer').AsString;
  edtPassword.Text    := dmPGManager.Deobfuscate(
                           dmPGManager.FDMemTable_Profiles.FieldByName('Passwort').AsString);
  edtDatabase.Text    := dmPGManager.FDMemTable_Profiles.FieldByName('Datenbank').AsString;
  edtTablespace.Text  := dmPGManager.FDMemTable_Profiles.FieldByName('Tablespace').AsString;
  edtProfileName.Text := dmPGManager.FDMemTable_Profiles.FieldByName('ProfilName').AsString;

  dmPGManager.TouchCurrentProfile;

  LDb := CurrentDb;
  try
    dmPGManager.ConnectDB(edtHost.Text, edtPort.Text, edtUser.Text, edtPassword.Text, LDb);
    Log('Profil "' + edtProfileName.Text + '" -> verbunden: ' + LDb + '@' + edtHost.Text);
    dmPGManager.LoadDatabases;
    dmPGManager.LoadTablespaces;
    dmPGManager.LoadTableNames;
  except
    on E: Exception do Log('FEHLER: ' + E.Message);
  end;
  UpdateStatus;
end;

procedure TfrmPGManager.DBGrid2DblClick(Sender: TObject);
begin
  btnUseProfileClick(Sender);
end;

// Doppelklick auf eine Datenbank: mit den aktuellen Zugangsdaten dorthin verbinden
procedure TfrmPGManager.DBGrid3DblClick(Sender: TObject);
var
  LDb: string;
begin
  if dmPGManager.FDMemTable_DB.IsEmpty then Exit;
  LDb := dmPGManager.FDMemTable_DB.FieldByName('Datenbank').AsString;
  if LDb = '' then Exit;
  edtDatabase.Text := LDb;
  try
    dmPGManager.ConnectDB(edtHost.Text, edtPort.Text, edtUser.Text, edtPassword.Text, LDb);
    Log('Verbunden: ' + LDb + '@' + edtHost.Text);
    dmPGManager.LoadTableNames;
  except
    on E: Exception do Log('FEHLER: ' + E.Message);
  end;
  UpdateStatus;
end;

// Doppelklick auf einen Tablespace: Namen ins Feld (fuer Profil-Speicherung)
procedure TfrmPGManager.DBGrid4DblClick(Sender: TObject);
var
  LTs: string;
begin
  if dmPGManager.FDMemTable_TS.IsEmpty then Exit;
  LTs := dmPGManager.FDMemTable_TS.FieldByName('Tablespace').AsString;
  if LTs = '' then Exit;
  edtTablespace.Text := LTs;
end;

procedure TfrmPGManager.btnDeleteProfileClick(Sender: TObject);
var
  LName: string;
begin
  if dmPGManager.FDMemTable_Profiles.IsEmpty then Exit;
  LName := dmPGManager.FDMemTable_Profiles.FieldByName('ProfilName').AsString;
  if MessageDlg('Profil "' + LName + '" l'#246'schen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dmPGManager.DeleteCurrentProfile;
    Log('Profil gel'#246'scht.');
  end;
end;

// --- TabSheet4: Tabelle ----------------------------------------------------

procedure TfrmPGManager.btnOpenTableClick(Sender: TObject);
begin
  if Trim(edtTableName.Text) = '' then begin ShowMessage('Bitte Tabellenname eingeben.'); Exit; end;
  if not dmPGManager.IsConnected then begin Log('Nicht verbunden (Tab "Verbindungen").'); Exit; end;
  dmPGManager.OpenTable(Trim(edtTableName.Text));
end;

procedure TfrmPGManager.btnLoadTablesClick(Sender: TObject);
begin
  if not dmPGManager.IsConnected then begin Log('Nicht verbunden (Tab "Verbindungen").'); Exit; end;
  dmPGManager.LoadTableNames;
end;

// Doppelklick auf einen Tabellennamen: schliessen -> Namen uebernehmen -> oeffnen
procedure TfrmPGManager.dgTablesDblClick(Sender: TObject);
var
  LName: string;
begin
  if dmPGManager.FDMemTable_Tables.IsEmpty then Exit;
  LName := dmPGManager.FDMemTable_Tables.FieldByName('Tabelle').AsString;
  if LName = '' then Exit;
  edtTableName.Text := LName;
  dmPGManager.OpenTable(LName);   // Close -> TableName -> Open (in der BL)
end;

end.
