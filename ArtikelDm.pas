unit ArtikelDm;

interface

uses
  System.SysUtils, System.Classes,
  EventBus,
  uAppEvents,
  udmModuleTemplate;

type
  TdmArtikel = class(TdmModuleTemplate)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure LoadData;
  public
    class function GetInstance: TObject;
    procedure OpenArtikel;

    [Subscribe(TThreadMode.Main)]
    procedure OnArtikelResult(AEvent: IArtikelResultEvent);
  end;

var
  dmArtikel: TdmArtikel;

implementation

{$R *.dfm}

uses
  Vcl.Forms,
  ArtikelFrm;

procedure TdmArtikel.DataModuleCreate(Sender: TObject);
begin
  // Registrierung übernimmt TdmModuleTemplate.Create (SilentRegisterSubscriberForEvents)
end;

procedure TdmArtikel.DataModuleDestroy(Sender: TObject);
begin
  // Deregistrierung übernimmt TdmModuleTemplate.Destroy
end;

procedure TdmArtikel.LoadData;
begin
  // Geschäftslogik: Artikeldaten laden
end;

class function TdmArtikel.GetInstance: TObject;
begin
  Result := dmArtikel;
end;

procedure TdmArtikel.OpenArtikel;
var
  LFrm: TfrmArtikel;
begin
  LoadData;
  LFrm := TfrmArtikel.Create(Application);
  LFrm.Show;
end;

procedure TdmArtikel.OnArtikelResult(AEvent: IArtikelResultEvent);
begin
  // Rückmeldung vom Fenster verarbeiten
end;

end.
