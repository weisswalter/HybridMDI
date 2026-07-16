unit KundenDm;

// DataModule für das Kunden-Modul (Delphi).
// Enthält die Geschäftslogik. Zeigt das MDI-Child nur bei Bedarf.

interface

uses
  System.SysUtils, System.Classes,
  EventBus,
  uAppEvents,
  udmModuleTemplate;

type
  TdmKunden = class(TdmModuleTemplate)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure LoadData;
  public
    class function GetInstance: TObject;
    procedure OpenKunden;

    [Subscribe(TThreadMode.Main)]
    procedure OnKundenResult(AEvent: IKundenResultEvent);
  end;

var
  dmKunden: TdmKunden;

implementation

{$R *.dfm}

uses
  Vcl.Forms,
  KundenFrm;

procedure TdmKunden.DataModuleCreate(Sender: TObject);
begin
  // Registrierung übernimmt TdmModuleTemplate.Create (SilentRegisterSubscriberForEvents)
end;

procedure TdmKunden.DataModuleDestroy(Sender: TObject);
begin
  // Deregistrierung übernimmt TdmModuleTemplate.Destroy
end;

procedure TdmKunden.LoadData;
begin
  // Geschäftslogik: Daten aus DB/Service laden
  // frmKunden.SetData(...)
end;

class function TdmKunden.GetInstance: TObject;
begin
  Result := dmKunden;
end;

procedure TdmKunden.OpenKunden;
var
  LFrm: TfrmKunden;
begin
  LoadData;
  LFrm := TfrmKunden.Create(Application);
  LFrm.Show;
end;

procedure TdmKunden.OnKundenResult(AEvent: IKundenResultEvent);
begin
  // Rückmeldung vom Fenster verarbeiten (z.B. in DB speichern)
  // AEvent.ResultText enthält die Daten
end;

end.
