unit TemplateDm;

// Kopiervorlage fuer neue Heisenberg-Module (DataModule-Haelfte).
// Bewusst schlank: 2 TFDTable (Stamm + Detail, Master-Detail gekoppelt) +
// 2 TDataSource. KEINE eigene TFDConnection mehr — die kommt zentral aus
// PGManagerDm.dmPGManager.FDConnection1 (Walters Vorgabe: nur eine
// FDConnection im ganzen Projekt). Fuer komplexere Bruecken-/m:n-Faelle
// (Adresse/Email teilen sich Saetze ueber mehrere Personen) siehe PersonenDm
// als Referenz (StammNeu/StammVerknuepfen-Muster) — hier absichtlich nicht
// mit uebernommen, das ist Sache des jeweiligen Moduls.
//
// TODO beim Duplizieren fuer ein echtes Modul:
//  - tblStamm/tblDetail: TableName, IndexFieldNames setzen (Object Inspector)
//  - tblDetail.MasterFields (DataModuleCreate) ans echte FK-Feld anpassen
//  - AutoIncFields setzen, falls die Tabellen eine SERIAL-PK haben (siehe
//    PersonenDm.SetupConnection fuer das Muster)
//  - ModulName in class function GetInstance / OpenVorlage / OpenGui-Aufrufer
//    konsistent halten (RTTI-Dispatch erwartet 'Tdm'+ModulName)

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,
  udmModuleTemplate;

type
  TdmVorlage = class(TdmModuleTemplate)
    tblStamm: TFDTable;
    tblDetail: TFDTable;
    dstblStamm: TDataSource;
    dstblDetail: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  public
    class function GetInstance: TObject;
    procedure OpenVorlage;
  end;

var
  dmVorlage: TdmVorlage;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  TemplateFrm;

class function TdmVorlage.GetInstance: TObject;
begin
  Result := dmVorlage;
end;

procedure TdmVorlage.DataModuleCreate(Sender: TObject);
begin
  // Zentrale Connection statt eigener TFDConnection (siehe Kommentar oben).
  // Setzt voraus, dass dmPGManager im .dpr VOR dmVorlage erzeugt wird.
  tblStamm.Connection  := PGManagerDm.dmPGManager.FDConnection1;
  tblDetail.Connection := PGManagerDm.dmPGManager.FDConnection1;
  tblDetail.MasterSource := dstblStamm;
  // TODO: tblDetail.MasterFields / IndexFieldNames ans echte FK-Beziehung anpassen
end;

procedure TdmVorlage.OpenVorlage;
begin
  if not PGManagerDm.dmPGManager.FDConnection1.Connected then
  begin
    ShowMessage('Bitte zuerst im PGManager die Datenbankverbindung herstellen.', '');
    Exit;
  end;

  // TODO: tblStamm.TableName / tblDetail.TableName muessen im Object Inspector
  // gesetzt sein, bevor Open funktioniert.
  tblStamm.Open;
  tblDetail.Open;

  if not Assigned(frmVorlage) then
    frmVorlage := TfrmVorlage.Create(Application);
  frmVorlage.Show;
end;

end.
