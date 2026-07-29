unit EinstellungenDm;

// Zentrale Verwaltung ALLER Typ-/Lookup-Tabellen an einem Ort (Walters
// Feedback 27.07.2026: ein eigenes Modul nur fuer Rechnungstyp war "zu viel
// des Guten" -- stattdessen ein Einstellungen-Fenster unter Werkzeuge, das
// alle Typen buendelt, damit die Fach-Module (PersonenFrm etc.) nicht mit
// Typ-Verwaltung ueberfrachtet werden). Ersetzt das verworfene eigenstaendige
// RechnungstypDm/Frm.
//
// 7 unabhaengige Typ-Tabellen, jede als eigener Ribbon-Tab:
//   Personentyp (poolweit, KEIN mandant_id), Rollentyp, Adressentyp,
//   Emailtyp, Telefonnummertyp, Rechnungstyp, Lead-Quelle (alle mandantenbezogen).
// Bestehende Verwaltung in PersonenFrm (Personentyp/Rollentyp/Adressentyp/
// Emailtyp/Telefonnummertyp-Tabs) bleibt bewusst unangetastet -- dieses Modul
// ist ein zusaetzlicher, bequemerer Zugang zu denselben Tabellen, kein Ersatz.

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
  TdmEinstellungen = class(TdmModuleTemplate)
    tblPersonentyp: TFDTable;
    tblRollentyp: TFDTable;
    tblAdressentyp: TFDTable;
    tblEmailtyp: TFDTable;
    tblTelefonnummertyp: TFDTable;
    tblRechnungstyp: TFDTable;
    tblLeadquellentyp: TFDTable;
    dstblPersonentyp: TDataSource;
    dstblRollentyp: TDataSource;
    dstblAdressentyp: TDataSource;
    dstblEmailtyp: TDataSource;
    dstblTelefonnummertyp: TDataSource;
    dstblRechnungstyp: TDataSource;
    dstblLeadquellentyp: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure TypOnNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
  public
    class function GetInstance: TObject;
    procedure OpenEinstellungen;
    // Liefert die DataSource des Tabs mit Index AHeaderIndex (Reihenfolge wie
    // JvRibbonPanel1.Headers in EinstellungenFrm).
    function DataSourceFuerTab(AHeaderIndex: Integer): TDataSource;
  end;

var
  dmEinstellungen: TdmEinstellungen;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  EinstellungenFrm;

class function TdmEinstellungen.GetInstance: TObject;
begin
  Result := dmEinstellungen;
end;

procedure TdmEinstellungen.DataModuleCreate(Sender: TObject);
begin
  tblPersonentyp.Connection      := PGManagerDm.dmPGManager.FDConnection1;
  tblRollentyp.Connection        := PGManagerDm.dmPGManager.FDConnection1;
  tblAdressentyp.Connection      := PGManagerDm.dmPGManager.FDConnection1;
  tblEmailtyp.Connection         := PGManagerDm.dmPGManager.FDConnection1;
  tblTelefonnummertyp.Connection := PGManagerDm.dmPGManager.FDConnection1;
  tblRechnungstyp.Connection     := PGManagerDm.dmPGManager.FDConnection1;
  tblLeadquellentyp.Connection   := PGManagerDm.dmPGManager.FDConnection1;

  tblPersonentyp.UpdateOptions.AutoIncFields      := 'typ_id';
  tblRollentyp.UpdateOptions.AutoIncFields        := 'rolle_id';
  tblAdressentyp.UpdateOptions.AutoIncFields      := 'adressentyp_id';
  tblEmailtyp.UpdateOptions.AutoIncFields         := 'emailtyp_id';
  tblTelefonnummertyp.UpdateOptions.AutoIncFields := 'telefonnummertyp_id';
  tblRechnungstyp.UpdateOptions.AutoIncFields     := 'rechnungstyp_id';
  tblLeadquellentyp.UpdateOptions.AutoIncFields   := 'leadquelle_id';

  // Personentyp ist poolweit (kein mandant_id) -- kein TypOnNewRecord noetig.
  tblRollentyp.OnNewRecord        := TypOnNewRecord;
  tblAdressentyp.OnNewRecord      := TypOnNewRecord;
  tblEmailtyp.OnNewRecord         := TypOnNewRecord;
  tblTelefonnummertyp.OnNewRecord := TypOnNewRecord;
  tblRechnungstyp.OnNewRecord     := TypOnNewRecord;
  tblLeadquellentyp.OnNewRecord   := TypOnNewRecord;
end;

procedure TdmEinstellungen.TypOnNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
end;

function TdmEinstellungen.DataSourceFuerTab(AHeaderIndex: Integer): TDataSource;
begin
  case AHeaderIndex of
    0: Result := dstblPersonentyp;
    1: Result := dstblRollentyp;
    2: Result := dstblAdressentyp;
    3: Result := dstblEmailtyp;
    4: Result := dstblTelefonnummertyp;
    5: Result := dstblRechnungstyp;
    6: Result := dstblLeadquellentyp;
  else
    Result := nil;
  end;
end;

procedure TdmEinstellungen.OpenEinstellungen;
begin
  if not PGManagerDm.dmPGManager.FDConnection1.Connected then
  begin
    ShowMessage('Bitte zuerst im PGManager die Datenbankverbindung herstellen.', '');
    Exit;
  end;

  FMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
  if FMandantId <= 0 then
  begin
    ShowMessage('Bitte zuerst oben im Hauptfenster einen Mandanten w'#228'hlen.', '');
    Exit;
  end;

  tblPersonentyp.Open;   // poolweit, keine Filterung

  tblRollentyp.Filtered := False;
  tblRollentyp.Open;
  tblRollentyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblRollentyp.Filtered := True;

  tblAdressentyp.Filtered := False;
  tblAdressentyp.Open;
  tblAdressentyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblAdressentyp.Filtered := True;

  tblEmailtyp.Filtered := False;
  tblEmailtyp.Open;
  tblEmailtyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblEmailtyp.Filtered := True;

  tblTelefonnummertyp.Filtered := False;
  tblTelefonnummertyp.Open;
  tblTelefonnummertyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblTelefonnummertyp.Filtered := True;

  tblRechnungstyp.Filtered := False;
  tblRechnungstyp.Open;
  tblRechnungstyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblRechnungstyp.Filtered := True;

  tblLeadquellentyp.Filtered := False;
  tblLeadquellentyp.Open;
  tblLeadquellentyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblLeadquellentyp.Filtered := True;

  if not Assigned(frmEinstellungen) then
    frmEinstellungen := TfrmEinstellungen.Create(Application);
  frmEinstellungen.Show;
end;

end.
