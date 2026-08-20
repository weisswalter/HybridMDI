unit KundenDm;

// DataModule für das Kunden-Modul (Delphi).
// Enthält die Geschäftslogik. Zeigt das MDI-Child nur bei Bedarf.

interface

uses
  System.SysUtils, System.Classes,
  EventBus,
  uAppEvents,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmKunden = class(TdmModuleTemplate)
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
  KundenFrm, System.SyncObjs, ZentraleDatenDm;



procedure TdmKunden.LoadData;
begin
  // Geschäftslogik: Daten aus DB/Service laden
  // frmKunden.SetData(...)
end;

var
  GSperreKunden: TCriticalSection;

class function TdmKunden.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmKunden) then
  begin
    GSperreKunden.Enter;
    try
      if not Assigned(dmKunden) then
        Application.CreateForm(TdmKunden, dmKunden);
    finally
      GSperreKunden.Leave;
    end;
  end;
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


initialization
  GSperreKunden := TCriticalSection.Create;

finalization
  GSperreKunden.Free;

end.
