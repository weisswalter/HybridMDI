unit PyArtikelDm;

// DataModule für das Artikel-Modul (Python).
// Ruft die Python-Businesslogik auf; die Python-GUI wird per ParentWindow in
// das Delphi-MDI-Child frmPyArtikel eingehaengt (Muster aus ThreadTest\Unit2.pas).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmPyArtikel = class(TdmModuleTemplate)
  public
    class function GetInstance: TObject;
    procedure OpenPyArtikel;
  end;

var
  dmPyArtikel: TdmPyArtikel;

implementation

{$R *.dfm}

uses
  PythonDm,
  PyArtikelFrm, System.SyncObjs, ZentraleDatenDm;



var
  GSperrePyArtikel: TCriticalSection;

class function TdmPyArtikel.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmPyArtikel) then
  begin
    GSperrePyArtikel.Enter;
    try
      if not Assigned(dmPyArtikel) then
        Application.CreateForm(TdmPyArtikel, dmPyArtikel);
    finally
      GSperrePyArtikel.Leave;
    end;
  end;
  Result := dmPyArtikel;
end;

procedure TdmPyArtikel.OpenPyArtikel;
begin
  if not Assigned(frmPyArtikel) then
    frmPyArtikel := TfrmPyArtikel.Create(Application);
  frmPyArtikel.Show;

  PythonDm.dmPython.Engine.ExecString(Format(
    'import importlib, modul_artikel; importlib.reload(modul_artikel); modul_artikel.ModulArtikel().show(%d)',
    [frmPyArtikel.Handle]));
end;


initialization
  GSperrePyArtikel := TCriticalSection.Create;

finalization
  GSperrePyArtikel.Free;

end.
