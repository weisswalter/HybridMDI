unit MandantDm;

// Mandanten-Verwaltung — haelt den aktuell gewaehlten Mandanten (CurrentMandantId)
// als zentralen Kontext, den andere Module (z.B. Personen) verwenden.
// Keine eigene GUI: frmMain bindet dieses Modul direkt ein (Ausnahme, wie
// bei udmModuleTemplate) und zeigt die Auswahl als ComboBox im Hauptfenster.

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,
  udmModuleTemplate;

type
  TdmMandant = class(TdmModuleTemplate)
    FDConnection: TFDConnection;
    qryMandant: TFDQuery;
    dsMandant: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FCurrentMandantId: Integer;
    procedure SetupConnection;
  public
    class function GetInstance: TObject;
    // Oeffnet qryMandant (Liste aller Mandanten) — von frmMain zum Fuellen
    // der ComboBox genutzt.
    procedure LoadMandanten;
    // Legt einen neuen Mandanten an und gibt dessen mandant_id zurueck.
    function CreateMandant(const AName: string): Integer;
    property CurrentMandantId: Integer read FCurrentMandantId write FCurrentMandantId;
  end;

var
  dmMandant: TdmMandant;

implementation

{$R *.dfm}

procedure TdmMandant.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
  FCurrentMandantId := 0;
end;

procedure TdmMandant.DataModuleDestroy(Sender: TObject);
begin
  if qryMandant.Active then
    qryMandant.Close;
  if FDConnection.Connected then
    FDConnection.Close;
end;

class function TdmMandant.GetInstance: TObject;
begin
  Result := dmMandant;
end;

procedure TdmMandant.SetupConnection;
begin
  FDConnection.Params.DriverID  := 'PG';
  FDConnection.Params.Database  := 'TRTHeisenberg';
  FDConnection.Params.UserName  := 'postgres';
  FDConnection.Params.Password  := 'postgres';
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('Port=5432');
  FDConnection.LoginPrompt := False;

  qryMandant.Connection := FDConnection;
  qryMandant.SQL.Text   :=
    'SELECT mandant_id, mandanten_name FROM mandant ORDER BY mandanten_name';

  dsMandant.DataSet := qryMandant;
end;

procedure TdmMandant.LoadMandanten;
begin
  if not FDConnection.Connected then
    FDConnection.Open;
  if not qryMandant.Active then
    qryMandant.Open;
end;

function TdmMandant.CreateMandant(const AName: string): Integer;
begin
  if not FDConnection.Connected then
    FDConnection.Open;

  Result := FDConnection.ExecSQLScalar(
    'INSERT INTO mandant (mandanten_name) VALUES (:n) RETURNING mandant_id',
    [AName]);

  if qryMandant.Active then
    qryMandant.Refresh;
end;

end.
