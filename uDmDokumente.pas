unit uDmDokumente;

// DataModule für Dokumentenverwaltung — TRTHeisenberg PostgreSQL via FireDAC.
// Öffnet die Dokument-Tabelle als live-editierbares Dataset.

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
  FireDAC.Comp.DataSet;

type
  TdmDokumente = class(TDataModule)
    FDConnection: TFDConnection;
    qryDokumente: TFDQuery;
    dsDokumente: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure SetupConnection;
  public
    class function GetInstance: TObject;
    procedure OpenDokumente;
  end;

var
  dmDokumente: TdmDokumente;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  uFrmDokumente;

procedure TdmDokumente.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
end;

procedure TdmDokumente.DataModuleDestroy(Sender: TObject);
begin
  if qryDokumente.Active then
    qryDokumente.Close;
  if FDConnection.Connected then
    FDConnection.Close;
end;

class function TdmDokumente.GetInstance: TObject;
begin
  Result := dmDokumente;
end;

procedure TdmDokumente.SetupConnection;
begin
  FDConnection.Params.DriverID  := 'PG';
  FDConnection.Params.Database  := 'TRTHeisenberg';
  FDConnection.Params.UserName  := 'postgres';
  FDConnection.Params.Password  := 'postgres';
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('Port=5432');
  FDConnection.LoginPrompt := False;

  qryDokumente.Connection := FDConnection;
  qryDokumente.SQL.Text   :=
    'SELECT dokument_id, typ_id, titel, ocr_text, ' +
    '       mime_type, quelle, dateigroesse_kb, sprache, ' +
    '       scan_datum, created_at ' +
    'FROM dokument ' +
    'ORDER BY dokument_id';
  // UpdateOptions damit Navigator Edit/Post funktioniert
  qryDokumente.UpdateOptions.UpdateTableName := 'dokument';
  qryDokumente.UpdateOptions.KeyFields       := 'dokument_id';

  dsDokumente.DataSet := qryDokumente;
end;

procedure TdmDokumente.OpenDokumente;
begin
  try
    if not FDConnection.Connected then
      FDConnection.Open;
    if not qryDokumente.Active then
      qryDokumente.Open;
  except
    on E: Exception do
    begin
      Vcl.Dialogs.ShowMessage('DB-Verbindung fehlgeschlagen:' + sLineBreak + E.Message);
      Exit;
    end;
  end;

  if not Assigned(frmDokumente) then
    frmDokumente := TfrmDokumente.Create(Application);
  frmDokumente.SetDataSource(dsDokumente);
  frmDokumente.Show;
end;

end.
