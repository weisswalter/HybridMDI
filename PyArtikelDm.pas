unit PyArtikelDm;

// DataModule für das Artikel-Modul (Python).
// Ruft die Python-Businesslogik auf; die Python-GUI wird per ParentWindow in
// das Delphi-MDI-Child frmPyArtikel eingehaengt (Muster aus ThreadTest\Unit2.pas).

interface

uses
  System.SysUtils, System.Classes,
  udmModuleTemplate;

type
  TdmPyArtikel = class(TdmModuleTemplate)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  public
    class function GetInstance: TObject;
    procedure OpenPyArtikel;
  end;

var
  dmPyArtikel: TdmPyArtikel;

implementation

{$R *.dfm}

uses
  Vcl.Forms,
  PythonDm,
  PyArtikelFrm;

procedure TdmPyArtikel.DataModuleCreate(Sender: TObject);
begin
  // Registrierung übernimmt TdmModuleTemplate.Create (SilentRegisterSubscriberForEvents)
end;

procedure TdmPyArtikel.DataModuleDestroy(Sender: TObject);
begin
  // Deregistrierung übernimmt TdmModuleTemplate.Destroy
end;

class function TdmPyArtikel.GetInstance: TObject;
begin
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

end.
