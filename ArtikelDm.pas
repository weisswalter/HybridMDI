unit ArtikelDm;

interface

uses
  System.SysUtils, System.Classes,
  EventBus,
  uAppEvents,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmArtikel = class(TdmModuleTemplate)
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
  ArtikelFrm, System.SyncObjs, ZentraleDatenDm;



procedure TdmArtikel.LoadData;
begin
  // Geschäftslogik: Artikeldaten laden
end;

var
  GSperreArtikel: TCriticalSection;

class function TdmArtikel.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmArtikel) then
  begin
    GSperreArtikel.Enter;
    try
      if not Assigned(dmArtikel) then
        Application.CreateForm(TdmArtikel, dmArtikel);
    finally
      GSperreArtikel.Leave;
    end;
  end;
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


initialization
  GSperreArtikel := TCriticalSection.Create;

finalization
  GSperreArtikel.Free;

end.
