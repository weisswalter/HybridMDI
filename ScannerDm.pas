unit ScannerDm;

// DataModule fuer die Scanner-Anbindung — TRTHeisenberg.
// Buendelt beide Treiberwege: WIA (fuer HP Officejet Pro 8620, kein TWAIN-Treiber
// mehr verfuegbar) und echte TWAIN-Treiber (DelphiTwain, Massimo Magnano).
//
// Die "grossen" Operationen (OpenScanner, spaeter ScanWia/ScanTwain) sind so
// gebaut, dass sie ueber den zentralen MessageHandler (mtModulCall) auch aus
// einem anderen Fenster oder aus Python/C#/C++ ansprechbar sind. Fenster-Interna
// (Combos fuellen, OK-Button) laufen weiterhin direkt in Delphi-Manier.
//
// GERUEST — noch ohne Scan-Logik. WIA-Scan wird spaeter aus DokumenteDm hierher
// gezogen, TWAIN kommt daneben.

interface

uses
  System.SysUtils, System.Classes,
  udmModuleTemplate;

type
  TdmScanner = class(TdmModuleTemplate)
  private
    { Private-Deklarationen }
  public
    class function GetInstance: TObject;
    // Oeffnet das zusammengefuehrte Konfigurationsfenster (2 Tabs:
    // Scannerauswahl inkl. Treiberart WIA/TWAIN, Einstellungen inkl. Scannerfach).
    // Einstiegspunkt fuer OpenGui('Scanner') bzw. mtModulCall TdmScanner.OpenScanner.
    procedure OpenScanner;
    // Fuellt AList mit den Beschreibungen aller per WIA erreichbaren Geraete.
    // Modul-intern, direkt aus der Form aufgerufen. WIA bleibt fuer den HP 8620,
    // fuer den es keinen TWAIN-Treiber mehr gibt.
    procedure EnumWiaDevices(AList: TStrings);
    // Fuellt AList mit den per TWAIN erreichbaren Geraeten (DelphiTwain-Lib).
    // Der Zugriff auf SourceCount laedt bei Bedarf die TWAIN-DSM (TWAINDSM.DLL)
    // und enumeriert die Quellen; ohne installierten TWAIN-Treiber bleibt leer.
    procedure EnumTwainDevices(AList: TStrings);
    // Liest die DocumentHandlingCapabilities (Bitmaske) des WIA-Geraets mit dem
    // 1-basierten Index AWiaIndex. Robust ueber PropertyID 3086 gesucht (nicht
    // ueber Collection-Position), damit geraeteunabhaengig. Verbindet das Geraet
    // dazu kurz. Bits (WIA-Standard): 1=Einzug/Feeder, 2=Flachbett, 4=Duplex.
    function GetWiaDocHandlingCaps(AWiaIndex: Integer): Integer;
    // Scannt per WIA mit Geraet AWiaIndex (1-basiert) und Fach ADocHandlingSelect
    // (1=Einzug, 2=Flachbett, 5=Duplex) und speichert jede Seite (JPEG) via
    // sp_dokument_scan_insert in die dokument-Tabelle (TRTHeisenberg).
    // Published -> auch aus anderem Fenster / Python / C# via mtModulCall aufrufbar.
    procedure ScanWia(AWiaIndex, ADocHandlingSelect: Integer);
  end;

var
  dmScanner: TdmScanner;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs, System.Variants, System.IOUtils, ComObj, ActiveX, WIA_TLB,
  Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DApt, FireDAC.Comp.Client,
  DelphiTwain, DelphiTwain_VCL,
  ScannerFrm;

class function TdmScanner.GetInstance: TObject;
begin
  Result := dmScanner;
end;

procedure TdmScanner.OpenScanner;
begin
  if not Assigned(frmScanner) then
    frmScanner := TfrmScanner.Create(Application);
  frmScanner.Show;
end;

// Enumeration wie in DokumenteDm.ScanHP8620: DeviceManager ueber WIA, alle
// DeviceInfos durchgehen, 'Description'-Property als Anzeigetext. WIA-Collections
// sind 1-basiert. CoInitialize/CoUninitialize lokal, damit unabhaengig vom Aufrufer.
procedure TdmScanner.EnumWiaDevices(AList: TStrings);
var
  DeviceManager: IDeviceManager;
  DevInfo: IDeviceInfo;
  i: Integer;
begin
  AList.Clear;
  CoInitialize(nil);
  try
    DeviceManager := CoDeviceManager.Create;
    for i := 1 to DeviceManager.DeviceInfos.Count do
    begin
      DevInfo := DeviceManager.DeviceInfos[i];
      AList.Add(VarToStr(DevInfo.Properties.Item['Description'].Get_Value));
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TdmScanner.EnumTwainDevices(AList: TStrings);
var
  Twain: TDelphiTwain;
  i: Integer;
begin
  AList.Clear;
  Twain := TDelphiTwain.Create;
  try
    // Zugriff auf SourceCount laedt bei Bedarf TWAINDSM.DLL + Source-Manager
    // und enumeriert die Geraete. Bleibt 0 ohne installierten TWAIN-Treiber.
    for i := 0 to Twain.SourceCount - 1 do
      AList.Add(Twain.Source[i].ProductName + ' (' + Twain.Source[i].Manufacturer + ')');
  finally
    Twain.Free;
  end;
end;

function TdmScanner.GetWiaDocHandlingCaps(AWiaIndex: Integer): Integer;
const
  WIA_DPS_DOCUMENT_HANDLING_CAPABILITIES = 3086;
var
  DeviceManager: IDeviceManager;
  DevInfo: IDeviceInfo;
  Device: IDevice;
  Prop: IProperty;
  j: Integer;
begin
  Result := 0;
  CoInitialize(nil);
  try
    DeviceManager := CoDeviceManager.Create;
    if (AWiaIndex < 1) or (AWiaIndex > DeviceManager.DeviceInfos.Count) then
      Exit;
    DevInfo := DeviceManager.DeviceInfos[AWiaIndex];
    Device := DevInfo.Connect;
    // Property ueber PropertyID suchen, nicht ueber feste Collection-Position
    for j := 1 to Device.Properties.Count do
    begin
      Prop := Device.Properties.Item[j];
      if (Prop <> nil) and (Prop.PropertyID = WIA_DPS_DOCUMENT_HANDLING_CAPABILITIES) then
      begin
        Result := Prop.Get_Value;
        Break;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TdmScanner.ScanWia(AWiaIndex, ADocHandlingSelect: Integer);
const
  WIA_FORMAT_JPEG                  = '{B96B3CAA-0728-11D3-9D7B-0000F81EF32E}';
  WIA_DPS_DOCUMENT_HANDLING_SELECT = 3088;
var
  DeviceManager: IDeviceManager;
  DevInfo: IDeviceInfo;
  Device: IDevice;
  Item: IItem;
  Prop: IProperty;
  Disp: IDispatch;
  ImageFile: IImageFile;
  Conn: TFDConnection;
  SP: TFDStoredProc;
  j, Page: Integer;
  FileName: string;
begin
  CoInitialize(nil);
  Conn := TFDConnection.Create(nil);
  SP   := TFDStoredProc.Create(nil);
  try
    try
      // DB-Verbindung zu TRTHeisenberg (Ziel: dokument via sp_dokument_scan_insert)
      Conn.LoginPrompt := False;
      Conn.Params.Values['DriverID']  := 'PG';
      Conn.Params.Values['Server']    := 'localhost';
      Conn.Params.Values['Port']      := '5432';
      Conn.Params.Values['Database']  := 'TRTHeisenberg';
      Conn.Params.Values['User_Name'] := 'postgres';
      Conn.Params.Values['Password']  := 'postgres';
      Conn.Connected := True;

      SP.Connection := Conn;
      SP.StoredProcName := 'sp_dokument_scan_insert';
      SP.Prepare;

      // Geraet waehlen (1-basierte WIA-Collection)
      DeviceManager := CoDeviceManager.Create;
      if (AWiaIndex < 1) or (AWiaIndex > DeviceManager.DeviceInfos.Count) then
      begin
        Vcl.Dialogs.ShowMessage('Ungueltiges WIA-Geraet.');
        Exit;
      end;
      DevInfo := DeviceManager.DeviceInfos[AWiaIndex];
      Device  := DevInfo.Connect;

      // Fach setzen: DocumentHandlingSelect ueber PropertyID 3088 (robust)
      for j := 1 to Device.Properties.Count do
      begin
        Prop := Device.Properties.Item[j];
        if (Prop <> nil) and (Prop.PropertyID = WIA_DPS_DOCUMENT_HANDLING_SELECT) then
        begin
          Prop.Set_Value(ADocHandlingSelect);
          Break;
        end;
      end;

      // Erstes Scan-Item; Seiten einzeln holen. Bei Einzug/Duplex bis Transfer
      // fehlschlaegt (Stapel-Ende), bei Flachbett (=2) genau eine Seite.
      Item := Device.Items[1];
      Page := 1;
      while True do
      begin
        try
          Disp := Item.Transfer(WIA_FORMAT_JPEG);
        except
          Break;   // keine weitere Seite
        end;

        if not Supports(Disp, IImageFile, ImageFile) then
          Break;

        FileName := TPath.Combine(TPath.GetTempPath,
          Format('heisenberg_scan_%s_%3.3d.jpg',
            [FormatDateTime('yyyymmdd_hhnnss', Now), Page]));
        ImageFile.SaveFile(FileName);
        try
          SP.ParamByName('p_titel').AsString :=
            'Scan ' + FormatDateTime('yyyy-mm-dd hh:nn', Now) + ' Seite ' + IntToStr(Page);
          SP.ParamByName('p_mime_type').AsString        := 'image/jpeg';
          SP.ParamByName('p_quelle').AsString           := 'WIA-Scanner';
          SP.ParamByName('p_dateigroesse_kb').AsInteger := TFile.GetSize(FileName) div 1024;
          SP.ParamByName('p_blob').LoadFromFile(FileName, ftBlob);
          SP.ExecProc;
        finally
          if TFile.Exists(FileName) then
            TFile.Delete(FileName);
        end;

        Inc(Page);
        if ADocHandlingSelect = 2 then   // Flachbett: nur eine Seite
          Break;
      end;

      Vcl.Dialogs.ShowMessage(
        Format('%d Seite(n) gescannt und in dokument gespeichert.', [Page - 1]));
    except
      on E: Exception do
        Vcl.Dialogs.ShowMessage('Scan-Fehler: ' + E.Message);
    end;
  finally
    SP.Free;
    Conn.Free;
    CoUninitialize;
  end;
end;

end.
