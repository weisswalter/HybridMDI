unit PythonDm;

// Zentrales Python-DataModule.
// Besitzt die PythonEngine, startet den unsichtbaren Host (Anker-Form für delphivcl),
// und leitet Python-Events an die jeweiligen Python-Module weiter.

interface

uses
  System.SysUtils, System.Classes,
  Vcl.ExtCtrls,
  PythonEngine, VarPyth,
  EventBus,
  udmModuleTemplate;

type
  TdmPython = class(TdmModuleTemplate)
    Timer1: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FEngine: TPythonEngine;
    procedure AddPythonPath(const ADir: string);
  public
    property Engine: TPythonEngine read FEngine;
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

  // Registrierung übernimmt TdmModuleTemplate.Create (SilentRegisterSubscriberForEvents)

  // Timer damit delphivcl den HiddenHost erst nach vollständiger VCL-Initialisierung anlegt
  Timer1.Interval := 50;
  Timer1.Enabled := True;
end;

procedure TdmPython.DataModuleDestroy(Sender: TObject);
begin
  // Deregistrierung übernimmt TdmModuleTemplate.Destroy
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
  FEngine.ExecString('import gui_host; gui_host.StartHiddenHost()');
end;

end.
