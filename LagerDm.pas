unit LagerDm;

// DataModule fuer die Lagerverwaltung — Tabelle lager (TRTHeisenberg).
// Flache Tabelle, mandantengefiltert ueber Master-Detail an tblMandant.
// lager_id ist serial -> AutoIncFields (RETURNING), mandant_id wird im
// OnNewRecord vorbelegt (Master-Detail-Vorbelegung greift bei leerem
// Detail-Set nicht zuverlaessig, siehe PersonenDm/TypOnNewRecord).

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
  TdmLager = class(TdmModuleTemplate)
    FDConnection: TFDConnection;
    tblMandant: TFDTable;
    tblLager: TFDTable;
    qryAdressen: TFDQuery;
    dstblMandant: TDataSource;
    dstblLager: TDataSource;
    dsAdressen: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FMandantId: Integer;
    procedure SetupConnection;
    procedure LagerOnNewRecord(DataSet: TDataSet);
  public
    class function GetInstance: TObject;
    procedure OpenLager;
  end;

var
  dmLager: TdmLager;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  MandantDm,
  LagerFrm;

procedure TdmLager.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
end;

procedure TdmLager.DataModuleDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TFDDataSet then
      TFDDataSet(Components[I]).Close;
  if FDConnection.Connected then FDConnection.Close;
end;

class function TdmLager.GetInstance: TObject;
begin
  Result := dmLager;
end;

procedure TdmLager.SetupConnection;
begin
  FDConnection.Params.DriverID  := 'PG';
  FDConnection.Params.Database  := 'TRTHeisenberg';
  FDConnection.Params.UserName  := 'postgres';
  FDConnection.Params.Password  := 'postgres';
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('Port=5432');
  FDConnection.LoginPrompt := False;

  tblLager.UpdateOptions.AutoIncFields := 'lager_id';
  tblLager.OnNewRecord := LagerOnNewRecord;

  // Adress-Lookup: Anzeige als ein Feld. CAST auf varchar noetig, sonst
  // liefert PostgreSQL "text" -> FireDAC-Memo -> Combo zeigt "(WIDEMEMO)".
  qryAdressen.Connection := FDConnection;
  qryAdressen.SQL.Text :=
    'SELECT adresse_id, ' +
    '  CAST(COALESCE(strasse, '''') || '' '' || COALESCE(hausnummer, '''') || ' +
    '    '', '' || COALESCE(plz, '''') || '' '' || COALESCE(ort, '''') ' +
    '    AS varchar(300)) AS anzeige ' +
    'FROM adresse ORDER BY strasse, hausnummer';
  dsAdressen.DataSet := qryAdressen;
end;

procedure TdmLager.LagerOnNewRecord(DataSet: TDataSet);
begin
  if FMandantId > 0 then
    DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
end;

procedure TdmLager.OpenLager;
var
  LMandantId: Integer;
begin
  LMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
  if LMandantId <= 0 then
  begin
    ShowMessage('Bitte zuerst oben im Hauptfenster einen Mandanten waehlen.', '');
    Exit;
  end;
  FMandantId := LMandantId;

  try
    if not FDConnection.Connected then
      FDConnection.Open;
    tblMandant.Open;
    tblMandant.Locate('mandant_id', LMandantId, []);
    tblLager.Open;      // Detail von tblMandant -> nur Lager des Mandanten
    qryAdressen.Close;
    qryAdressen.Open;
  except
    on E: Exception do
    begin
      Vcl.Dialogs.ShowMessage('DB-Verbindung fehlgeschlagen:' + sLineBreak + E.Message);
      Exit;
    end;
  end;

  if not Assigned(frmLager) then
    frmLager := TfrmLager.Create(Application);
  frmLager.Show;
end;

end.
