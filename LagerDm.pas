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
  Winapi.Windows, System.SysUtils, System.Classes, System.Variants,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,
  Vcl.Forms,
  udmModuleTemplate;

type
  TdmLager = class(TdmModuleTemplate)
    tblMandant: TFDMemTable;
    tblLager: TFDMemTable;
    tblAdressinfo: TFDMemTable;
    tblRaum: TFDMemTable;
    tblAusstattung: TFDMemTable;
    tblRaumAusstattung: TFDMemTable;
    tblRegal: TFDMemTable;
    tblRegalFach: TFDMemTable;
    // Lookups: fruher je ein TFDQuery mit Inline-SQL, jetzt Kopien der
    // Views v_*_anzeige aus dem zentralen Datenmodul. Spalten unveraendert
    // (id + anzeige), die Bindungen im Formular bleiben davon unberuehrt.
    memAdressen: TFDMemTable;
    memAdressinfoLookup: TFDMemTable;
    memRaumLookup: TFDMemTable;
    memRegalLookup: TFDMemTable;
    memEinheitLookup: TFDMemTable;
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
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    procedure OpenLager;

    // Schreiben geht ausschliesslich hierueber: der Satz wird aus der
    // MemTable in die passende Datenbankfunktion gereicht. Kein ApplyUpdates,
    // kein direktes Post gegen die Datenbank.
    function SatzSpeichern(ADataSet: TDataSet): Boolean;
    function SatzLoeschen(ADataSet: TDataSet): Boolean;
  end;

var
  dmLager: TdmLager;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  LagerFrm, System.SyncObjs;

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
  // Keine eigene Verbindung mehr zu schliessen - die gehoert dem zentralen
  // Datenmodul und wird von dort verwaltet.
end;

var
  GSperreLager: TCriticalSection;

class function TdmLager.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmLager) then
  begin
    GSperreLager.Enter;
    try
      if not Assigned(dmLager) then
        Application.CreateForm(TdmLager, dmLager);
    finally
      GSperreLager.Leave;
    end;
  end;
  Result := dmLager;
end;

procedure TdmLager.SetupConnection;
begin
  // Keine eigene Verbindung mehr: gelesen wird aus dem zentralen Datenmodul,
  // geschrieben ueber dessen SpAufrufen. Damit gibt es genau eine Connection
  // im Programm statt einer je Modul.

  tblLager.OnNewRecord := LagerOnNewRecord;
  tblRegalFach.OnNewRecord := RegalFachOnNewRecord;

  // AutoIncFields entfaellt - die IDs vergibt jetzt die Datenbankfunktion und
  // liefert sie als Rueckgabewert zurueck.

  dsAdressen.DataSet          := memAdressen;
  dsAdressinfoLookup.DataSet  := memAdressinfoLookup;
  dsRaumLookup.DataSet        := memRaumLookup;
  dsRegalLookup.DataSet       := memRegalLookup;
  dsEinheitLookup.DataSet     := memEinheitLookup;

  // Die frueheren Inline-SQL-Texte der Lookups stehen jetzt als Views in der
  // Datenbank (sql/lager_views_und_sp.sql): v_adresse_anzeige,
  // v_adressinfo_anzeige, v_raum_anzeige, v_regal_anzeige.
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
    // Speicher- UND Lookup-Tabellen kommen aus dem zentralen Datenmodul.
    TabellenLaden;
    tblMandant.Locate('mandant_id', LMandantId, []);

    // einheit ist mandantenbezogen. Frueher filterte das die WHERE-Klausel
    // der Query, jetzt der Filter auf der Kopie - es geht kein zweites Mal
    // zur Datenbank.
    memEinheitLookup.Filter := 'mandant_id = ' + IntToStr(FMandantId);
    memEinheitLookup.Filtered := True;
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


procedure TdmLager.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblAdressinfo, 'adressinfo'),
    Zuordnung(tblAusstattung, 'ausstattung'),
    Zuordnung(tblLager, 'lager'),
    Zuordnung(tblMandant, 'mandant'),
    Zuordnung(tblRaum, 'raum'),
    Zuordnung(tblRaumAusstattung, 'raum_ausstattung'),
    Zuordnung(tblRegal, 'regal'),
    Zuordnung(tblRegalFach, 'regal_fach'),
    // Lookups: Views statt der frueheren Inline-Queries
    Zuordnung(memAdressen, 'v_adresse_anzeige'),
    Zuordnung(memAdressinfoLookup, 'v_adressinfo_anzeige'),
    Zuordnung(memRaumLookup, 'v_raum_anzeige'),
    Zuordnung(memRegalLookup, 'v_regal_anzeige'),
    Zuordnung(memEinheitLookup, 'einheit')]);
end;

// Liefert Null statt eines Wertes, wenn das Feld leer ist - die Funktionen
// erwarten NULL, nicht 0 oder ''.
function FeldWert(ADataSet: TDataSet; const AFeld: string): Variant;
var
  LFeld: TField;
begin
  LFeld := ADataSet.FindField(AFeld);
  if not Assigned(LFeld) or LFeld.IsNull then
    Result := Null
  else
    Result := LFeld.AsVariant;
end;

function TdmLager.SatzSpeichern(ADataSet: TDataSet): Boolean;
var
  LZentral: TdmZentraleDaten;
  LId: Variant;
  LTabelle: string;
begin
  Result := False;
  if not Assigned(ADataSet) or not ADataSet.Active then
    Exit;

  // Der Satz muss im Speicher stehen, bevor die Feldwerte gelesen werden.
  if ADataSet.State in dsEditModes then
    ADataSet.Post;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);

  if ADataSet = tblLager then
  begin
    LTabelle := 'lager';
    LId := LZentral.SpAufrufen('fn_lager_speichern',
      [FeldWert(ADataSet, 'lager_id'), FMandantId,
       FeldWert(ADataSet, 'adresse_id'), FeldWert(ADataSet, 'raum_id'),
       FeldWert(ADataSet, 'regal_id'), FeldWert(ADataSet, 'barcode'),
       FeldWert(ADataSet, 'beschreibung'), FeldWert(ADataSet, 'qrcode'),
       FeldWert(ADataSet, 'photo')]);
  end
  else if ADataSet = tblAdressinfo then
  begin
    LTabelle := 'adressinfo';
    LId := LZentral.SpAufrufen('fn_adressinfo_speichern',
      [FeldWert(ADataSet, 'adressinfo_id'), FeldWert(ADataSet, 'adresse_id'),
       FeldWert(ADataSet, 'beschreibung')]);
  end
  else if ADataSet = tblRaum then
  begin
    LTabelle := 'raum';
    LId := LZentral.SpAufrufen('fn_raum_speichern',
      [FeldWert(ADataSet, 'raum_id'), FeldWert(ADataSet, 'adresse_id'),
       FeldWert(ADataSet, 'adressinfo_id'), FeldWert(ADataSet, 'bezeichnung'),
       FeldWert(ADataSet, 'laenge'), FeldWert(ADataSet, 'breite'),
       FeldWert(ADataSet, 'hoehe'), FeldWert(ADataSet, 'beschreibung'),
       FeldWert(ADataSet, 'max_personen'),
       FeldWert(ADataSet, 'ist_mehrzweck')]);
  end
  else if ADataSet = tblAusstattung then
  begin
    LTabelle := 'ausstattung';
    LId := LZentral.SpAufrufen('fn_ausstattung_speichern',
      [FeldWert(ADataSet, 'ausstattungs_id'), FeldWert(ADataSet, 'bezeichnung'),
       FeldWert(ADataSet, 'ist_mobil'), FeldWert(ADataSet, 'anzahl_mobil')]);
  end
  else if ADataSet = tblRaumAusstattung then
  begin
    LTabelle := 'raum_ausstattung';
    LId := LZentral.SpAufrufen('fn_raum_ausstattung_setzen',
      [FeldWert(ADataSet, 'raum_id'), FeldWert(ADataSet, 'ausstattungs_id')]);
  end
  else if ADataSet = tblRegal then
  begin
    LTabelle := 'regal';
    LId := LZentral.SpAufrufen('fn_regal_speichern',
      [FeldWert(ADataSet, 'regal_id'), FeldWert(ADataSet, 'raum_id'),
       FeldWert(ADataSet, 'bezeichnung'), FeldWert(ADataSet, 'beschreibung')]);
  end
  else if ADataSet = tblRegalFach then
  begin
    LTabelle := 'regal_fach';
    LId := LZentral.SpAufrufen('fn_regal_fach_speichern',
      [FeldWert(ADataSet, 'fach_id'), FMandantId,
       FeldWert(ADataSet, 'regal_id'), FeldWert(ADataSet, 'bezeichnung'),
       FeldWert(ADataSet, 'beschreibung'), FeldWert(ADataSet, 'kapazitaet'),
       FeldWert(ADataSet, 'einheit_id')]);
  end
  else
    raise Exception.Create(
      'Fuer diese Tabelle ist keine Speicherfunktion hinterlegt.');

  if VarIsNull(LId) then
    Exit;

  // Zentralen Stand nachziehen und die Anzeige daraus neu befuellen, damit
  // eine neu vergebene ID auch im Modul steht.
  LZentral.TabelleAuffrischen(LTabelle);
  TabellenLaden;
  Result := True;
end;

function TdmLager.SatzLoeschen(ADataSet: TDataSet): Boolean;
var
  LZentral: TdmZentraleDaten;
  LTabelle: string;
begin
  Result := False;
  if not Assigned(ADataSet) or not ADataSet.Active or ADataSet.IsEmpty then
    Exit;
  if ADataSet.State in dsEditModes then
    ADataSet.Cancel;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);

  if ADataSet = tblLager then
  begin
    LTabelle := 'lager';
    LZentral.SpAufrufen('fn_lager_loeschen',
      [FeldWert(ADataSet, 'lager_id'), FMandantId]);
  end
  else if ADataSet = tblAdressinfo then
  begin
    LTabelle := 'adressinfo';
    LZentral.SpAufrufen('fn_adressinfo_loeschen',
      [FeldWert(ADataSet, 'adressinfo_id')]);
  end
  else if ADataSet = tblRaum then
  begin
    LTabelle := 'raum';
    LZentral.SpAufrufen('fn_raum_loeschen', [FeldWert(ADataSet, 'raum_id')]);
  end
  else if ADataSet = tblAusstattung then
  begin
    LTabelle := 'ausstattung';
    LZentral.SpAufrufen('fn_ausstattung_loeschen',
      [FeldWert(ADataSet, 'ausstattungs_id')]);
  end
  else if ADataSet = tblRaumAusstattung then
  begin
    LTabelle := 'raum_ausstattung';
    LZentral.SpAufrufen('fn_raum_ausstattung_loeschen',
      [FeldWert(ADataSet, 'raum_id'), FeldWert(ADataSet, 'ausstattungs_id')]);
  end
  else if ADataSet = tblRegal then
  begin
    LTabelle := 'regal';
    LZentral.SpAufrufen('fn_regal_loeschen', [FeldWert(ADataSet, 'regal_id')]);
  end
  else if ADataSet = tblRegalFach then
  begin
    LTabelle := 'regal_fach';
    LZentral.SpAufrufen('fn_regal_fach_loeschen',
      [FeldWert(ADataSet, 'fach_id'), FMandantId]);
  end
  else
    raise Exception.Create(
      'Fuer diese Tabelle ist keine Loeschfunktion hinterlegt.');

  LZentral.TabelleAuffrischen(LTabelle);
  TabellenLaden;
  Result := True;
end;



initialization
  GSperreLager := TCriticalSection.Create;

finalization
  GSperreLager.Free;

end.
