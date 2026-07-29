unit LagerDm;

// DataModule fuer die Lagerverwaltung — TRTHeisenberg PostgreSQL via FireDAC.
//
// Hierarchie: adresse -> adressinfo (optional, Eingang/Stockwerk) -> raum
// -> regal -> lager (der eigentliche Lagerplatz/Barcode-Eintrag).
// raum <-> ausstattung ist m:n (raum_ausstattung) — ein Raum kann mehrere
// Merkmale gleichzeitig haben (Klima, Beamer, kuehlraumtauglich, ...).
//
// adressinfo/raum/ausstattung/regal sind KEINE mandantenbezogenen Daten
// (physische Fakten des Gebaeudes, analog zu adresse selbst) — nur lager
// traegt mandant_id. Alle vier werden deshalb flach (ohne MasterSource an
// tblMandant) geoeffnet, tblRaumAusstattung ist Detail von tblRaum.
//
// Fuer Lookup-Combos mit mehreren sichtbaren Spalten (z.B. "Buero 204,
// Teststr 1") gibt es je einen separaten FDQuery mit CAST-Anzeige-Feld
// (CAST auf varchar noetig, sonst liefert PostgreSQL "text" -> FireDAC-Memo
// -> Combo zeigt "(WIDEMEMO)").

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
  TdmLager = class(TdmModuleTemplate)
    FDConnection: TFDConnection;
    tblMandant: TFDTable;
    tblLager: TFDTable;
    tblAdressinfo: TFDTable;
    tblRaum: TFDTable;
    tblAusstattung: TFDTable;
    tblRaumAusstattung: TFDTable;
    tblRegal: TFDTable;
    tblRegalFach: TFDTable;
    qryAdressen: TFDQuery;
    qryAdressinfoLookup: TFDQuery;
    qryRaumLookup: TFDQuery;
    qryRegalLookup: TFDQuery;
    qryEinheitLookup: TFDQuery;
    dstblMandant: TDataSource;
    dstblLager: TDataSource;
    dstblAdressinfo: TDataSource;
    dstblRaum: TDataSource;
    dstblAusstattung: TDataSource;
    dstblRaumAusstattung: TDataSource;
    dstblRegal: TDataSource;
    dstblRegalFach: TDataSource;
    dsAdressen: TDataSource;
    dsAdressinfoLookup: TDataSource;
    dsRaumLookup: TDataSource;
    dsRegalLookup: TDataSource;
    dsEinheitLookup: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FMandantId: Integer;
    procedure SetupConnection;
    procedure LagerOnNewRecord(DataSet: TDataSet);
    procedure RegalFachOnNewRecord(DataSet: TDataSet);
  public
    class function GetInstance: TObject;
    procedure OpenLager;
  end;

var
  dmLager: TdmLager;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  MandantDm,
  LagerFrm;

procedure TdmLager.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
end;

procedure TdmLager.DataModuleDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TFDDataSet then
      TFDDataSet(Components[I]).Close;
  if FDConnection.Connected then FDConnection.Close;
end;

class function TdmLager.GetInstance: TObject;
begin
  Result := dmLager;
end;

procedure TdmLager.SetupConnection;
begin
  FDConnection.Params.DriverID  := 'PG';
  FDConnection.Params.Database  := 'TRTHeisenberg';
  FDConnection.Params.UserName  := 'postgres';
  FDConnection.Params.Password  := 'postgres';
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('Port=5432');
  FDConnection.LoginPrompt := False;

  tblLager.UpdateOptions.AutoIncFields := 'lager_id';
  tblLager.OnNewRecord := LagerOnNewRecord;

  tblAdressinfo.UpdateOptions.AutoIncFields := 'adressinfo_id';
  tblRaum.UpdateOptions.AutoIncFields := 'raum_id';
  tblAusstattung.UpdateOptions.AutoIncFields := 'ausstattungs_id';
  tblRegal.UpdateOptions.AutoIncFields := 'regal_id';

  // Faecher sind (anders als regal selbst) mandantenbezogen -> Detail von
  // tblRegal (MasterSource/-Fields im DFM, wie bei tblRaumAusstattung),
  // mandant_id wird wie bei tblLager ueber OnNewRecord vorbelegt.
  tblRegalFach.UpdateOptions.AutoIncFields := 'fach_id';
  tblRegalFach.OnNewRecord := RegalFachOnNewRecord;

  // Adress-Lookup (bereits vorhanden fuer Lager, jetzt auch fuer Raum genutzt)
  qryAdressen.Connection := FDConnection;
  qryAdressen.SQL.Text :=
    'SELECT adresse_id, ' +
    '  CAST(COALESCE(strasse, '''') || '' '' || COALESCE(hausnummer, '''') || ' +
    '    '', '' || COALESCE(plz, '''') || '' '' || COALESCE(ort, '''') ' +
    '    AS varchar(300)) AS anzeige ' +
    'FROM adresse ORDER BY strasse, hausnummer';
  dsAdressen.DataSet := qryAdressen;

  // Adressinfo-Lookup: Adresse + Beschreibung in einer Zeile, damit man den
  // Eingang/Stockwerk-Eintrag auch ohne Filterung nach Adresse eindeutig
  // erkennt (z.B. fuer die Raum-Zuordnung).
  qryAdressinfoLookup.Connection := FDConnection;
  qryAdressinfoLookup.SQL.Text :=
    'SELECT ai.adressinfo_id, ' +
    '  CAST(COALESCE(a.strasse, '''') || '' '' || COALESCE(a.hausnummer, '''') || ' +
    '    '', '' || COALESCE(a.ort, '''') || '' '#8212' '' || ai.beschreibung ' +
    '    AS varchar(400)) AS anzeige ' +
    'FROM adressinfo ai JOIN adresse a ON a.adresse_id = ai.adresse_id ' +
    'ORDER BY a.ort, ai.beschreibung';
  dsAdressinfoLookup.DataSet := qryAdressinfoLookup;

  // Raum-Lookup: Raumbezeichnung + Adresse, fuer Regal- und Lager-Zuordnung.
  qryRaumLookup.Connection := FDConnection;
  qryRaumLookup.SQL.Text :=
    'SELECT r.raum_id, ' +
    '  CAST(COALESCE(r.bezeichnung, ''Raum '' || r.raum_id) || '' ('' || ' +
    '    COALESCE(a.strasse, '''') || '' '' || COALESCE(a.hausnummer, '''') || ' +
    '    '', '' || COALESCE(a.ort, '''') || '')'' AS varchar(400)) AS anzeige ' +
    'FROM raum r JOIN adresse a ON a.adresse_id = r.adresse_id ' +
    'ORDER BY a.ort, r.bezeichnung';
  dsRaumLookup.DataSet := qryRaumLookup;

  // Regal-Lookup: Regalbezeichnung + Raum, fuer die Lager-Zuordnung.
  qryRegalLookup.Connection := FDConnection;
  qryRegalLookup.SQL.Text :=
    'SELECT rg.regal_id, ' +
    '  CAST(COALESCE(rg.bezeichnung, ''Regal '' || rg.regal_id) || '' ('' || ' +
    '    COALESCE(r.bezeichnung, ''Raum '' || r.raum_id) || '')'' AS varchar(400)) AS anzeige ' +
    'FROM regal rg JOIN raum r ON r.raum_id = rg.raum_id ' +
    'ORDER BY r.bezeichnung, rg.bezeichnung';
  dsRegalLookup.DataSet := qryRegalLookup;

  // Einheit-Lookup fuer die Fach-Kapazitaet -- mandantenbezogen (PK
  // (mandant_id, einheit_id)), Parameter wird in OpenLager gesetzt.
  qryEinheitLookup.Connection := FDConnection;
  qryEinheitLookup.SQL.Text :=
    'SELECT einheit_id, name FROM einheit ' +
    'WHERE mandant_id = :mandant_id ORDER BY name';
  dsEinheitLookup.DataSet := qryEinheitLookup;
end;

procedure TdmLager.LagerOnNewRecord(DataSet: TDataSet);
begin
  if FMandantId > 0 then
    DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
end;

procedure TdmLager.RegalFachOnNewRecord(DataSet: TDataSet);
begin
  // regal_id kommt automatisch ueber MasterFields, mandant_id explizit wie
  // ueberall sonst (siehe LagerOnNewRecord).
  if FMandantId > 0 then
    DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
end;

procedure TdmLager.OpenLager;
var
  LMandantId: Integer;
begin
  LMandantId := TdmMandant(TdmMandant.GetInstance).CurrentMandantId;
  if LMandantId <= 0 then
  begin
    ShowMessage('Bitte zuerst oben im Hauptfenster einen Mandanten waehlen.', '');
    Exit;
  end;
  FMandantId := LMandantId;

  try
    if not FDConnection.Connected then
      FDConnection.Open;
    tblMandant.Open;
    tblMandant.Locate('mandant_id', LMandantId, []);
    tblLager.Open;      // Detail von tblMandant -> nur Lager des Mandanten

    // adressinfo/raum/ausstattung/regal sind pool-weit (keine mandant_id) ->
    // flach oeffnen, nicht ueber tblMandant gefiltert.
    tblAdressinfo.Open;
    tblRaum.Open;
    tblAusstattung.Open;
    tblRaumAusstattung.Open;  // Detail von tblRaum (raum_id)
    tblRegal.Open;
    tblRegalFach.Open;        // Detail von tblRegal (regal_id)

    qryAdressen.Close;
    qryAdressen.Open;
    qryAdressinfoLookup.Close;
    qryAdressinfoLookup.Open;
    qryRaumLookup.Close;
    qryRaumLookup.Open;
    qryRegalLookup.Close;
    qryRegalLookup.Open;
    qryEinheitLookup.Close;
    qryEinheitLookup.ParamByName('mandant_id').AsInteger := FMandantId;
    qryEinheitLookup.Open;
  except
    on E: Exception do
    begin
      Vcl.Dialogs.ShowMessage('DB-Verbindung fehlgeschlagen:' + sLineBreak + E.Message);
      Exit;
    end;
  end;

  if not Assigned(frmLager) then
    frmLager := TfrmLager.Create(Application);
  frmLager.Show;
end;

end.
