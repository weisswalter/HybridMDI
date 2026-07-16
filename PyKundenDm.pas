unit PyKundenDm;

// DataModule für das Kunden-Modul (Python).
// Ruft die Python-Businesslogik auf; die Python-GUI wird per ParentWindow in
// das Delphi-MDI-Child frmPyKunden eingehaengt (Muster aus ThreadTest\Unit2.pas).

interface

uses
  System.SysUtils, System.Classes,
  udmModuleTemplate;

type
  TdmPyKunden = class(TdmModuleTemplate)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  public
    class function GetInstance: TObject;
    procedure OpenPyKunden;
  end;

var
  dmPyKunden: TdmPyKunden;

implementation

{$R *.dfm}

uses
  Vcl.Forms,
  PythonDm,
  PyKundenFrm;

procedure TdmPyKunden.DataModuleCreate(Sender: TObject);
begin
  // Registrierung übernimmt TdmModuleTemplate.Create (SilentRegisterSubscriberForEvents)
end;

procedure TdmPyKunden.DataModuleDestroy(Sender: TObject);
begin
  // Deregistrierung übernimmt TdmModuleTemplate.Destroy
end;

class function TdmPyKunden.GetInstance: TObject;
begin
  Result := dmPyKunden;
end;

procedure TdmPyKunden.OpenPyKunden;
begin
  if not Assigned(frmPyKunden) then
    frmPyKunden := TfrmPyKunden.Create(Application);
  frmPyKunden.Show;

  PythonDm.dmPython.Engine.ExecString(Format(
    'import importlib, modul_kunden; importlib.reload(modul_kunden); modul_kunden.ModulKunden().show(%d)',
    [frmPyKunden.Handle]));
end;

end.
