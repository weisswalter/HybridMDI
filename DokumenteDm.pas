unit DokumenteDm;

// DataModule für Dokumentenverwaltung — TRTHeisenberg PostgreSQL via FireDAC.
// Öffnet die Dokument-Tabelle als live-editierbares Dataset.

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Variants,
  ComObj, ActiveX,
  WIA_TLB,
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

const
  // WIA-Format-GUID JPEG — aus C:\Users\weiss\Documents\Embarcadero\Studio\Projekte\tWAIN\Project3
  wiaFormatJPEG: WideString = '{B96B3CAA-0728-11D3-9D7B-0000F81EF32E}';

type
  TdmDokumente = class(TdmModuleTemplate)
    FDConnection: TFDConnection;
    qryDokumente: TFDQuery;
    dsDokumente: TDataSource;
    qryDokumentedokument_id: TIntegerField;
    qryDokumentetyp_id: TIntegerField;
    qryDokumentetitel: TWideStringField;
    qryDokumenteocr_text: TWideMemoField;
    qryDokumentemime_type: TWideStringField;
    qryDokumentequelle: TWideStringField;
    qryDokumentedateigroesse_kb: TIntegerField;
    qryDokumentesprache: TWideStringField;
    qryDokumentescan_datum: TSQLTimeStampField;
    qryDokumentecreated_at: TSQLTimeStampField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure SetupConnection;
  protected
  public
    class function GetInstance: TObject;
    procedure OpenDokumente;
    // WIA-Scan (Einzugsscanner) — HP Officejet Pro 8620, kein TWAIN-Treiber mehr
    // verfügbar, deshalb über WIA. Gibt den Dateinamen der gespeicherten JPEG zurück.
    function ScanHP8620: string;
  published

    procedure btnScanClick(Sender: TObject);
  end;

var
  dmDokumente: TdmDokumente;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  DokumenteFrm;

procedure TdmDokumente.btnScanClick(Sender: TObject);
begin
  OpenGui('Scanner');
end;

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

// 1:1 aus C:\Users\weiss\Documents\Embarcadero\Studio\Projekte\tWAIN\Project3.dpr
// (TForm3.BtnScanHPClick) übernommen — Gerätesuche, Duplex-ADF, Transfer unverändert.
// Einzige Änderung: Dateiname jetzt mit Zeitstempel statt fest "scan_hp8620.jpg",
// damit aufeinanderfolgende Scans sich nicht gegenseitig überschreiben.
function TdmDokumente.ScanHP8620: string;
var
  DeviceManager: IDeviceManager;
  DevInfo: IDeviceInfo;
  HPDevice: IDevice;
  Item: IItem;
  Disp: IDispatch;
  ImageFile: IImageFile;
  i: Integer;
begin
  Result := '';
  CoInitialize(nil);
  try
    DeviceManager := CoDeviceManager.Create;

    HPDevice := nil;
    for i := 1 to DeviceManager.DeviceInfos.Count do
    begin
      DevInfo := DeviceManager.DeviceInfos[i];
      if Pos('HP Officejet Pro 8620',
             VarToStr(DevInfo.Properties.Item['Description'].Get_Value)) > 0 then
      begin
        HPDevice := DevInfo.Connect;
        Break;
      end;
    end;

    if HPDevice = nil then
    begin
      ShowMessage('HP 8620 nicht gefunden!','');
      Exit;
    end;

    // Erstes Item (Scanner)
    Item := HPDevice.Items[1];

    // Duplex-ADF aktivieren (Feeder + Duplex)
    Item.Properties.Item['DocumentHandlingSelect'].Set_Value(5);

    // Transfer liefert IDispatch → mit Supports casten
    Disp := Item.Transfer(wiaFormatJPEG);
    if Supports(Disp, IImageFile, ImageFile) then
    begin
      Result := TPath.Combine(ExtractFilePath(ParamStr(0)),
        'scan_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.jpg');
      ImageFile.SaveFile(Result);
    end
    else
    begin
      ShowMessage( 'Transfer liefert kein IImageFile!','');
      Result := '';
    end;
  finally
    CoUninitialize;
  end;
end;

end.
