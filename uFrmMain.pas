unit uFrmMain;

// MDI-Hauptfenster. Kennt keine DataModule, keine Subforms — nur Events.
// Alle Aktionen gehen über den GlobalEventBus.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.StdCtrls,
  EventBus,
  uAppEvents,
  UInterfaces,
  uMessageHandler;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    mnuModule: TMenuItem;
    mnuKunden: TMenuItem;
    mnuArtikel: TMenuItem;
    mnuSep1: TMenuItem;
    mnuPyKunden: TMenuItem;
    mnuPyArtikel: TMenuItem;
    procedure mnuKundenClick(Sender: TObject);
    procedure mnuArtikelClick(Sender: TObject);
    procedure mnuPyKundenClick(Sender: TObject);
    procedure mnuPyArtikelClick(Sender: TObject);
    procedure mnuDokumenteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    [Subscribe(TThreadMode.Main)]
    procedure OnKundenResult(AEvent: IKundenResultEvent);
    [Subscribe(TThreadMode.Main)]
    procedure OnArtikelResult(AEvent: IArtikelResultEvent);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  GlobalEventBus.RegisterSubscriberForEvents(Self);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  GlobalEventBus.UnregisterForEvents(Self);
end;

procedure TfrmMain.mnuKundenClick(Sender: TObject);
begin
  GlobalEventBus.Post(TOpenKundenEvent.Create);
end;

procedure TfrmMain.mnuArtikelClick(Sender: TObject);
begin
  GlobalEventBus.Post(TOpenArtikelEvent.Create);
end;

procedure TfrmMain.mnuPyKundenClick(Sender: TObject);
begin
  GlobalEventBus.Post(TOpenPyKundenEvent.Create);
end;

procedure TfrmMain.mnuPyArtikelClick(Sender: TObject);
begin
  GlobalEventBus.Post(TOpenPyArtikelEvent.Create);
end;

procedure TfrmMain.mnuDokumenteClick(Sender: TObject);
var
  LEvent: IMyEvent;
begin
  LEvent := TMyEvent.Create(
    'TdmDokumente', 'OpenDokumente', '', '', '', '', '', False, mtModulCall, Now, False, 0, []);
  GlobalEventBus.Post(LEvent);
end;

procedure TfrmMain.OnKundenResult(AEvent: IKundenResultEvent);
begin
  Caption := 'HybridMDI — ' + AEvent.ResultText;
end;

procedure TfrmMain.OnArtikelResult(AEvent: IArtikelResultEvent);
begin
  Caption := 'HybridMDI — ' + AEvent.ResultText;
end;

end.
