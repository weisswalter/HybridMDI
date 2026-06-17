unit uDmArtikel;

interface

uses
  System.SysUtils, System.Classes,
  EventBus,
  uAppEvents;

type
  TdmArtikel = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure LoadData;
  public
    [Subscribe(TThreadMode.Main)]
    procedure OnOpenArtikel(AEvent: IOpenArtikelEvent);

    [Subscribe(TThreadMode.Main)]
    procedure OnArtikelResult(AEvent: IArtikelResultEvent);
  end;

var
  dmArtikel: TdmArtikel;

implementation

{$R *.dfm}

uses
  Vcl.Forms,
  uFrmArtikel;

procedure TdmArtikel.DataModuleCreate(Sender: TObject);
begin
  GlobalEventBus.RegisterSubscriberForEvents(Self);
end;

procedure TdmArtikel.DataModuleDestroy(Sender: TObject);
begin
  GlobalEventBus.UnregisterForEvents(Self);
end;

procedure TdmArtikel.LoadData;
begin
  // Geschäftslogik: Artikeldaten laden
end;

procedure TdmArtikel.OnOpenArtikel(AEvent: IOpenArtikelEvent);
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
