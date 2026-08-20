unit PyKundenDm;

// DataModule für das Kunden-Modul (Python).
// Ruft die Python-Businesslogik auf; die Python-GUI wird per ParentWindow in
// das Delphi-MDI-Child frmPyKunden eingehaengt (Muster aus ThreadTest\Unit2.pas).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmPyKunden = class(TdmModuleTemplate)
  public
    class function GetInstance: TObject;
    procedure OpenPyKunden;
  end;

var
  dmPyKunden: TdmPyKunden;

implementation

{$R *.dfm}

uses
  PythonDm,
  PyKundenFrm, System.SyncObjs, ZentraleDatenDm;



var
  GSperrePyKunden: TCriticalSection;

class function TdmPyKunden.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmPyKunden) then
  begin
    GSperrePyKunden.Enter;
    try
      if not Assigned(dmPyKunden) then
        Application.CreateForm(TdmPyKunden, dmPyKunden);
    finally
      GSperrePyKunden.Leave;
    end;
  end;
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


initialization
  GSperrePyKunden := TCriticalSection.Create;

finalization
  GSperrePyKunden.Free;

end.
