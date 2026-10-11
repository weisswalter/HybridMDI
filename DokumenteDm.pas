unit DokumenteDm;

// DataModule für Dokumentenverwaltung — TRTHeisenberg PostgreSQL via FireDAC.
// Öffnet die Dokument-Tabelle als live-editierbares Dataset.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.Variants,
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
  Vcl.Forms,
  udmModuleTemplate;

const
  // WIA-Format-GUID JPEG — aus C:\Users\weiss\Documents\Embarcadero\Studio\Projekte\tWAIN\Project3
  wiaFormatJPEG: WideString = '{B96B3CAA-0728-11D3-9D7B-0000F81EF32E}';

type
  TdmDokumente = class(TdmModuleTemplate)
    // Kopie aus dem zentralen Datenmodul. Die frueher persistenten Felder
    // sind bewusst weg: sie deckten nur 10 der 21 Spalten ab, weshalb
    // FieldByName('datei_pfad') im Formular ins Leere lief.
    qryDokumente: TFDMemTable;
    dsDokumente: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure SetupConnection;
    procedure TabellenLaden;
  protected
  public
    class function GetInstance: TObject;
    procedure OpenDokumente;

    // Schreiben ausschliesslich ueber die Datenbankfunktionen.
    function SatzSpeichern: Boolean;
    function SatzLoeschen: Boolean;
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
  Vcl.Dialogs,
  DokumenteFrm, System.SyncObjs, ZentraleDatenDm, uGridMemo;

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
  // Keine eigene Verbindung mehr zu schliessen.
end;

var
  GSperreDokumente: TCriticalSection;

class function TdmDokumente.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmDokumente) then
  begin
    GSperreDokumente.Enter;
    try
      if not Assigned(dmDokumente) then
        Application.CreateForm(TdmDokumente, dmDokumente);
    finally
      GSperreDokumente.Leave;
    end;
  end;
  Result := dmDokumente;
end;

procedure TdmDokumente.SetupConnection;
begin
  // Keine eigene Verbindung mehr: gelesen wird als Kopie aus dem zentralen
  // Datenmodul, geschrieben ueber SatzSpeichern -> fn_dokument_speichern.
  dsDokumente.DataSet := qryDokumente;
end;

function TdmDokumente.SatzSpeichern: Boolean;
var
  LZentral: TdmZentraleDaten;
  LId: Variant;

  function Wert(const AFeld: string): Variant;
  var
    LFeld: TField;
  begin
    LFeld := qryDokumente.FindField(AFeld);
    if not Assigned(LFeld) or LFeld.IsNull then
      Result := Null
    else
      Result := LFeld.AsVariant;
  end;

begin
  Result := False;
  if not qryDokumente.Active then
    Exit;
  if qryDokumente.State in dsEditModes then
    qryDokumente.Post;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  LId := LZentral.SpAufrufen('fn_dokument_speichern',
    [Wert('dokument_id'), Wert('titel'), Wert('typ_id'), Wert('ocr_text'),
     Wert('datei_pfad'), Wert('mime_type'), Wert('quelle'),
     Wert('dateigroesse_kb'), Wert('sprache'), Wert('scan_datum')]);
  if VarIsNull(LId) then
    Exit;

  LZentral.TabelleAuffrischen('dokument');
  TabellenLaden;
  Result := True;
end;

function TdmDokumente.SatzLoeschen: Boolean;
var
  LZentral: TdmZentraleDaten;
begin
  Result := False;
  if not qryDokumente.Active or qryDokumente.IsEmpty then
    Exit;
  if qryDokumente.State in dsEditModes then
    qryDokumente.Cancel;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  LZentral.SpAufrufen('fn_dokument_loeschen',
    [qryDokumente.FieldByName('dokument_id').AsInteger]);
  LZentral.TabelleAuffrischen('dokument');
  TabellenLaden;
  Result := True;
end;

procedure TdmDokumente.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen(
    [Zuordnung(qryDokumente, 'dokument')]);
  // dokument.css/html/inhalt_text/ocr_text sind Postgres 'text' - ohne das
  // haette das Gitter dort nur "(WIDEMEMO)" gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(qryDokumente);
  qryDokumente.IndexFieldNames := 'dokument_id';
end;

procedure TdmDokumente.OpenDokumente;
begin
  try
    TabellenLaden;
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


initialization
  GSperreDokumente := TCriticalSection.Create;

finalization
  GSperreDokumente.Free;

end.
