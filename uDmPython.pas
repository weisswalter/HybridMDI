unit uDmPython;

// Zentrales Python-DataModule.
// Besitzt die PythonEngine, startet den unsichtbaren Host (Anker-Form für delphivcl),
// und leitet Python-Events an die jeweiligen Python-Module weiter.

interface

uses
  System.SysUtils, System.Classes,
  Vcl.ExtCtrls,
  PythonEngine, VarPyth,
  EventBus,
  uAppEvents;

type
  TdmPython = class(TDataModule)
    Timer1: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FEngine: TPythonEngine;
    procedure AddPythonPath(const ADir: string);
  public
    property Engine: TPythonEngine read FEngine;

    [Subscribe(TThreadMode.Main)]
    procedure OnOpenPyKunden(AEvent: IOpenPyKundenEvent);
    [Subscribe(TThreadMode.Main)]
    procedure OnOpenPyArtikel(AEvent: IOpenPyArtikelEvent);
  end;

var
  dmPython: TdmPython;

implementation

{$R *.dfm}

uses
  Winapi.Windows, System.IOUtils;

procedure TdmPython.DataModuleCreate(Sender: TObject);
var
  LPythonDir: string;
begin
  FEngine := TPythonEngine.Create(Self);
  FEngine.AutoLoad := True;
  FEngine.UseLastKnownVersion := True;
  FEngine.LoadDll;

  LPythonDir := TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'Python');
  AddPythonPath(LPythonDir);

  GlobalEventBus.RegisterSubscriberForEvents(Self);

  // Timer damit delphivcl den HiddenHost erst nach vollständiger VCL-Initialisierung anlegt
  Timer1.Interval := 50;
  Timer1.Enabled := True;
end;

procedure TdmPython.DataModuleDestroy(Sender: TObject);
begin
  GlobalEventBus.UnregisterForEvents(Self);
end;

procedure TdmPython.AddPythonPath(const ADir: string);
var
  LSys, LPath: Variant;
begin
  if not FEngine.Initialized then Exit;
  LSys := Import('sys');
  LPath := LSys.path;
  LPath.append(ADir);
end;

procedure TdmPython.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  FEngine.ExecString('import gui_host; gui_host.start_hidden_host()');
end;

procedure TdmPython.OnOpenPyKunden(AEvent: IOpenPyKundenEvent);
begin
  FEngine.ExecString('import importlib, modul_kunden; importlib.reload(modul_kunden); modul_kunden.ModulKunden().show()');
end;

procedure TdmPython.OnOpenPyArtikel(AEvent: IOpenPyArtikelEvent);
begin
  FEngine.ExecString('import importlib, modul_artikel; importlib.reload(modul_artikel); modul_artikel.ModulArtikel().show()');
end;

end.
