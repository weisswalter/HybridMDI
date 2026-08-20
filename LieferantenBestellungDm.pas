unit LieferantenBestellungDm;

// Modul 2: Hauptperson bestellt bei Lieferant.
// Strukturell identisch zu KundenBestellungDm (siehe dort fuer die
// allgemeinen Konventionen) -- belegart ist HIER FEST 'Lieferung' (vom
// Modul vorgegeben, in der GUI nicht aenderbar). Gegenpartei (person_id) ist
// der Lieferant -- ermittelt ueber person_beziehung.ist_lieferant gegen die
// Hauptperson des aktuellen Mandanten.

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

const
  cBelegart = 'Lieferung';
  cStandardRechnungstyp = 'Bestellung';

type
  TdmLieferantenBestellung = class(TdmModuleTemplate)
    tblBeleg: TFDMemTable;
    tblBelegPosition: TFDMemTable;
    dstblBeleg: TDataSource;
    dstblBelegPosition: TDataSource;
    // Kopien der Views aus dem zentralen Datenmodul.
    qryPersonAuswahl: TFDMemTable;
    dsPersonAuswahl: TDataSource;
    qryRechnungstypAuswahl: TFDMemTable;
    dsRechnungstypAuswahl: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblBelegNewRecord(DataSet: TDataSet);
    procedure tblBelegPositionNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    function StandardRechnungstypId: Integer;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    procedure OpenLieferantenBestellung;
    function HauptpersonVorhanden: Boolean;
    // Visieren, Briefkopf und Ablage der .tex-Quelle laufen ueber das
    // Datenmodul - das Formular hat keinen Zugriff auf die Datenbank.
    function BelegVisieren: string;
    function Absender: string;
    procedure TexSpeichern(const ATex: string);
    procedure LadeArtikelAuswahl(AItems: TStrings);
    procedure LadeLeistungAuswahl(AItems: TStrings);
    procedure AddPosition(AArtikelId, ALeistungId: Integer;
      AMenge, AEinzelpreis: Double; ARueckgabeErwartet: Boolean = False);
  end;

var
  dmLieferantenBestellung: TdmLieferantenBestellung;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  LieferantenBestellungFrm, System.SyncObjs;

var
  GSperreLieferantenBestellung: TCriticalSection;

class function TdmLieferantenBestellung.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmLieferantenBestellung) then
  begin
    GSperreLieferantenBestellung.Enter;
    try
      if not Assigned(dmLieferantenBestellung) then
        Application.CreateForm(TdmLieferantenBestellung, dmLieferantenBestellung);
    finally
      GSperreLieferantenBestellung.Leave;
    end;
  end;
  Result := dmLieferantenBestellung;
end;

procedure TdmLieferantenBestellung.DataModuleCreate(Sender: TObject);
begin

  tblBeleg.UpdateOptions.AutoIncFields         := 'beleg_id';
  tblBelegPosition.UpdateOptions.AutoIncFields := 'position_id';

  tblBelegPosition.MasterSource    := dstblBeleg;
  tblBelegPosition.MasterFields    := 'beleg_id';
  tblBelegPosition.IndexFieldNames := 'beleg_id';


end;

function TdmLieferantenBestellung.HauptpersonVorhanden: Boolean;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
    'fn_hat_hauptperson', [FMandantId]) = True;
end;

function TdmLieferantenBestellung.StandardRechnungstypId: Integer;
begin
  Result := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufen('fn_rechnungstyp_id',
                [FMandantId, cStandardRechnungstyp]));
end;

procedure TdmLieferantenBestellung.tblBelegNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger  := FMandantId;
  DataSet.FieldByName('belegart').AsString  := cBelegart;
  DataSet.FieldByName('beleg_datum').AsDateTime := Date;
  DataSet.FieldByName('status').AsString       := 'offen';
  DataSet.FieldByName('rechnungstyp_id').AsInteger := StandardRechnungstypId;
end;

procedure TdmLieferantenBestellung.tblBelegPositionNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('position_nr').AsInteger :=
    AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_naechste_position',
      [tblBeleg.FieldByName('beleg_id').AsInteger]));
end;

procedure TdmLieferantenBestellung.LadeArtikelAuswahl(AItems: TStrings);
var
  LMem: TFDMemTable;
begin
  // Liste kommt aus dem Speicher; die Kopie gehoert uns und
  // wird nach dem Durchlauf wieder freigegeben.
  LMem := TdmZentraleDaten(TdmZentraleDaten.GetInstance)
            .KopieHolen('artikel');
  try
    LMem.Filtered := False;
    LMem.Filter := Format('mandant_id = %d', [FMandantId]);
    LMem.Filtered := True;
    LMem.IndexFieldNames := 'artikelname';
    AItems.BeginUpdate;
    try
      AItems.Clear;
      LMem.First;
      while not LMem.Eof do
      begin
        AItems.AddObject(LMem.FieldByName('artikelname').AsString,
          TObject(NativeInt(LMem.FieldByName('artikel_id').AsInteger)));
        LMem.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LMem.Free;
  end;
end;

procedure TdmLieferantenBestellung.LadeLeistungAuswahl(AItems: TStrings);
var
  LMem: TFDMemTable;
begin
  // Liste kommt aus dem Speicher; die Kopie gehoert uns und
  // wird nach dem Durchlauf wieder freigegeben.
  LMem := TdmZentraleDaten(TdmZentraleDaten.GetInstance)
            .KopieHolen('leistung');
  try
    LMem.Filtered := False;
    LMem.Filter := Format('mandant_id = %d', [FMandantId]);
    LMem.Filtered := True;
    LMem.IndexFieldNames := 'bezeichnung';
    AItems.BeginUpdate;
    try
      AItems.Clear;
      LMem.First;
      while not LMem.Eof do
      begin
        AItems.AddObject(LMem.FieldByName('bezeichnung').AsString,
          TObject(NativeInt(LMem.FieldByName('leistung_id').AsInteger)));
        LMem.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LMem.Free;
  end;
end;

procedure TdmLieferantenBestellung.AddPosition(AArtikelId, ALeistungId: Integer;
  AMenge, AEinzelpreis: Double; ARueckgabeErwartet: Boolean = False);
begin
  if tblBeleg.IsEmpty then
    Exit;
  tblBelegPosition.Append;
  if AArtikelId > 0 then
    tblBelegPosition.FieldByName('artikel_id').AsInteger := AArtikelId
  else
    tblBelegPosition.FieldByName('leistung_id').AsInteger := ALeistungId;
  tblBelegPosition.FieldByName('menge').AsFloat := AMenge;
  tblBelegPosition.FieldByName('einzelpreis').AsFloat := AEinzelpreis;
  tblBelegPosition.FieldByName('rueckgabe_erwartet').AsBoolean := ARueckgabeErwartet;
  tblBelegPosition.Post;
end;

procedure TdmLieferantenBestellung.OpenLieferantenBestellung;
begin
  if not TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung.Connected then
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

  if not HauptpersonVorhanden then
  begin
    ShowMessage('F'#252'r diesen Mandanten ist noch keine Hauptperson angelegt.' + sLineBreak +
      'Bitte zuerst im Personen-Modul eine Hauptperson festlegen.', '');
    Exit;
  end;



  tblBeleg.Filtered := False;
  // Speichertabellen kommen aus dem zentralen Datenmodul
  TabellenLaden;
  tblBeleg.Filter := Format('mandant_id=%d AND belegart=''%s''', [FMandantId, cBelegart]);
  tblBeleg.Filtered := True;
  tblBeleg.IndexFieldNames := 'beleg_id';


  if not Assigned(frmLieferantenBestellung) then
    frmLieferantenBestellung := TfrmLieferantenBestellung.Create(Application);
  frmLieferantenBestellung.Show;
end;


procedure TdmLieferantenBestellung.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblBeleg, 'beleg'),
    Zuordnung(tblBelegPosition, 'beleg_position'),
    Zuordnung(qryPersonAuswahl, 'v_beleg_person_auswahl'),
    Zuordnung(qryRechnungstypAuswahl, 'v_rechnungstyp_auswahl')]);
  qryPersonAuswahl.Filtered := False;
  qryPersonAuswahl.Filter := Format('mandant_id = %d', [FMandantId]);
  qryPersonAuswahl.Filtered := True;
  qryRechnungstypAuswahl.Filtered := False;
  qryRechnungstypAuswahl.Filter := Format('mandant_id = %d', [FMandantId]);
  qryRechnungstypAuswahl.Filtered := True;
end;



function TdmLieferantenBestellung.BelegVisieren: string;
var
  LZentral: TdmZentraleDaten;
begin
  Result := '';
  if tblBeleg.IsEmpty then
    Exit('Kein Beleg gew' + #228 + 'hlt.');

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    Result := 'Visiert als ' + VarToStr(LZentral.SpAufrufen('fn_beleg_visieren',
      [tblBeleg.FieldByName('beleg_id').AsInteger, Null]));
  except
    on E: Exception do
      Exit(E.Message);
  end;

  // Nummer, Status und die eingefrorenen Werte kommen aus der Datenbank
  // zurueck - ohne das zeigt die Maske den alten Stand.
  LZentral.TabelleAuffrischen('beleg');
  LZentral.TabelleAuffrischen('beleg_position');
  TabellenLaden;
end;

function TdmLieferantenBestellung.Absender: string;
begin
  // Briefkopf des Mandanten. Steht bewusst nicht im Beleg: eine Firma kann
  // verkauft oder umbenannt werden, den Stand von damals haelt die
  // gespeicherte .tex-Quelle.
  if tblBeleg.IsEmpty then
    Exit('');
  Result := VarToStr(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufen('fn_mandant_absender',
      [tblBeleg.FieldByName('mandant_id').AsInteger]));
end;

procedure TdmLieferantenBestellung.TexSpeichern(const ATex: string);
begin
  if tblBeleg.IsEmpty then
    Exit;
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
    'fn_beleg_tex_speichern',
    [tblBeleg.FieldByName('beleg_id').AsInteger, ATex]);
end;

initialization
  GSperreLieferantenBestellung := TCriticalSection.Create;

finalization
  GSperreLieferantenBestellung.Free;


end.
