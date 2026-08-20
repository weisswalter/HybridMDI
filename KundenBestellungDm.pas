unit KundenBestellungDm;

// Modul 1: Kunde bestellt bei Hauptperson.
// Generischer Beleg/Beleg-Position-Unterbau (siehe sql/rechnungstyp_beleg.sql),
// belegart ist HIER FEST 'Bestellung' -- wird vom Modul vorgegeben und ist
// in der GUI nicht änderbar (Walters Vorgabe). Gegenpartei (person_id) ist der
// Kunde -- ermittelt über person_beziehung.ist_kunde gegen die Hauptperson des
// aktuellen Mandanten (siehe HauptpersonVorhanden/LadePersonAuswahl, Muster
// wie ArtikelStammDm.HauptpersonVorhanden).
// Artikel/Leistung als Positions-Ziel (Artikel koennen auch Leistungen sein,
// siehe beleg_position.CHECK) -- Auswahl passiert im Frm ueber zwei getrennt
// befuellte ComboBoxen (Muster wie ArtikelStammDm.LadeHauptpersonAdressen),
// AddPosition schreibt genau eines der beiden Felder.

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
  cBelegart = 'Bestellung';
  cStandardRechnungstyp = 'Bestellung';

type
  TdmKundenBestellung = class(TdmModuleTemplate)
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
    procedure OpenKundenBestellung;
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
  dmKundenBestellung: TdmKundenBestellung;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  KundenBestellungFrm, System.SyncObjs;

var
  GSperreKundenBestellung: TCriticalSection;

class function TdmKundenBestellung.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmKundenBestellung) then
  begin
    GSperreKundenBestellung.Enter;
    try
      if not Assigned(dmKundenBestellung) then
        Application.CreateForm(TdmKundenBestellung, dmKundenBestellung);
    finally
      GSperreKundenBestellung.Leave;
    end;
  end;
  Result := dmKundenBestellung;
end;

procedure TdmKundenBestellung.DataModuleCreate(Sender: TObject);
begin

  tblBeleg.UpdateOptions.AutoIncFields         := 'beleg_id';
  tblBelegPosition.UpdateOptions.AutoIncFields := 'position_id';

  tblBelegPosition.MasterSource    := dstblBeleg;
  tblBelegPosition.MasterFields    := 'beleg_id';
  tblBelegPosition.IndexFieldNames := 'beleg_id';


end;

function TdmKundenBestellung.HauptpersonVorhanden: Boolean;
begin
  Result := TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
    'fn_hat_hauptperson', [FMandantId]) = True;
end;

function TdmKundenBestellung.StandardRechnungstypId: Integer;
begin
  Result := AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .SpAufrufen('fn_rechnungstyp_id',
                [FMandantId, cStandardRechnungstyp]));
end;

procedure TdmKundenBestellung.tblBelegNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger  := FMandantId;
  DataSet.FieldByName('belegart').AsString  := cBelegart;
  DataSet.FieldByName('beleg_datum').AsDateTime := Date;
  DataSet.FieldByName('status').AsString       := 'offen';
  DataSet.FieldByName('rechnungstyp_id').AsInteger := StandardRechnungstypId;
end;

// position_nr per eigener Abfrage ermitteln statt ueber das Master-Dataset zu
// iterieren (das steckt waehrend NewRecord selbst schon im Insert, ein
// First/Next darauf waere riskant) -- Muster wie an anderer Stelle ueblich.
procedure TdmKundenBestellung.tblBelegPositionNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('position_nr').AsInteger :=
    AlsZahl(TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_naechste_position',
      [tblBeleg.FieldByName('beleg_id').AsInteger]));
end;

procedure TdmKundenBestellung.LadeArtikelAuswahl(AItems: TStrings);
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

procedure TdmKundenBestellung.LadeLeistungAuswahl(AItems: TStrings);
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

// Genau EINS von AArtikelId/ALeistungId muss > 0 sein (Aufrufer waehlt ueber
// die RadioGroup Artikel/Leistung, siehe KundenBestellungFrm).
procedure TdmKundenBestellung.AddPosition(AArtikelId, ALeistungId: Integer;
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

procedure TdmKundenBestellung.OpenKundenBestellung;
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


  if not Assigned(frmKundenBestellung) then
    frmKundenBestellung := TfrmKundenBestellung.Create(Application);
  frmKundenBestellung.Show;
end;


procedure TdmKundenBestellung.TabellenLaden;
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



function TdmKundenBestellung.BelegVisieren: string;
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

function TdmKundenBestellung.Absender: string;
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

procedure TdmKundenBestellung.TexSpeichern(const ATex: string);
begin
  if tblBeleg.IsEmpty then
    Exit;
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
    'fn_beleg_tex_speichern',
    [tblBeleg.FieldByName('beleg_id').AsInteger, ATex]);
end;

initialization
  GSperreKundenBestellung := TCriticalSection.Create;

finalization
  GSperreKundenBestellung.Free;


end.
