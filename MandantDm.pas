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
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmMandant = class(TdmModuleTemplate)
    // Kopie aus dem zentralen Datenmodul statt eigener Query.
    memMandant: TFDMemTable;
    dsMandant: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FCurrentMandantId: Integer;
    FCurrentMandantName: string;
    procedure SetupConnection;
  public
    class function GetInstance: TObject;
    // Oeffnet qryMandant (Liste aller Mandanten) — von frmMain zum Fuellen
    // der ComboBox genutzt.
    procedure LoadMandanten;
    // Legt einen neuen Mandanten an und gibt dessen mandant_id zurueck.
    function CreateMandant(const AName: string): Integer;
    property CurrentMandantId: Integer read FCurrentMandantId write FCurrentMandantId;
    // Name des aktuell gewaehlten Mandanten — von frmMain fuer die Statuszeile
    // genutzt, damit andere Module nicht extra nachfragen muessen.
    property CurrentMandantName: string read FCurrentMandantName write FCurrentMandantName;
  end;

var
  dmMandant: TdmMandant;

implementation

uses
  System.SyncObjs, System.Variants, ZentraleDatenDm;

{$R *.dfm}

procedure TdmMandant.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
  FCurrentMandantId := 0;
end;

procedure TdmMandant.DataModuleDestroy(Sender: TObject);
begin
   if memMandant.Active then
     memMandant.Close;
end;

var
  GSperreMandant: TCriticalSection;

class function TdmMandant.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmMandant) then
  begin
    GSperreMandant.Enter;
    try
      if not Assigned(dmMandant) then
        Application.CreateForm(TdmMandant, dmMandant);
    finally
      GSperreMandant.Leave;
    end;
  end;
  Result := dmMandant;
end;

procedure TdmMandant.SetupConnection;
begin
  // Keine eigene Verbindung mehr: gelesen wird als Kopie aus dem zentralen
  // Datenmodul, geschrieben ueber dessen SpAufrufen.
  dsMandant.DataSet := memMandant;
end;

procedure TdmMandant.LoadMandanten;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen(
    [Zuordnung(memMandant, 'mandant')]);
  // Die Sortierung stand frueher im ORDER BY der Query.
  memMandant.IndexFieldNames := 'mandanten_name';
end;

function TdmMandant.CreateMandant(const AName: string): Integer;
var
  LZentral: TdmZentraleDaten;
  LId: Variant;
begin
  Result := 0;
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  LId := LZentral.SpAufrufen('fn_mandant_speichern', [Null, AName, False]);
  if VarIsNull(LId) then
    Exit;

  Result := LId;
  LZentral.TabelleAuffrischen('mandant');
  LoadMandanten;
end;


initialization
  GSperreMandant := TCriticalSection.Create;

finalization
  GSperreMandant.Free;

end.
