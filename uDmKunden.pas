unit uDmKunden;

// DataModule für das Kunden-Modul (Delphi).
// Enthält die Geschäftslogik. Zeigt das MDI-Child nur bei Bedarf.

interface

uses
  System.SysUtils, System.Classes,
  EventBus,
  uAppEvents;

type
  TdmKunden = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure LoadData;
  public
    [Subscribe(TThreadMode.Main)]
    procedure OnOpenKunden(AEvent: IOpenKundenEvent);

    [Subscribe(TThreadMode.Main)]
    procedure OnKundenResult(AEvent: IKundenResultEvent);
  end;

var
  dmKunden: TdmKunden;

implementation

{$R *.dfm}

uses
  Vcl.Forms,
  uFrmKunden;

procedure TdmKunden.DataModuleCreate(Sender: TObject);
begin
  GlobalEventBus.RegisterSubscriberForEvents(Self);
end;

procedure TdmKunden.DataModuleDestroy(Sender: TObject);
begin
  GlobalEventBus.UnregisterForEvents(Self);
end;

procedure TdmKunden.LoadData;
begin
  // Geschäftslogik: Daten aus DB/Service laden
  // frmKunden.SetData(...)
end;

procedure TdmKunden.OnOpenKunden(AEvent: IOpenKundenEvent);
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
