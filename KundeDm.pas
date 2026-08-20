unit KundeDm;

// Kunde-Modul: "Kunde" existiert als Rolle bereits (person_beziehung.ist_kunde,
// siehe sql/rechnungstyp_beleg.sql / KundenBestellungDm) -- dieses Modul ist
// die dazugehoerige Stammdaten-Ansicht (Browse/Filter/Bearbeiten), keine
// zweite parallele Kunde-Definition. Name/E-Mail/Telefon/Adresse kommen
// komplett aus person/person_email/person_telefonnummer/person_adresse
// (PersonenDm) -- hier nur das Zusatzfeld "Kunden-Besitzer" (kunde-
// Erweiterungstabelle) plus die Uebersicht "Kontakte" (verknuepfte Klienten,
// siehe KlientDm).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
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
  TdmKunde = class(TdmModuleTemplate)
    qryKunden: TFDQuery;
    dstblKundenListe: TDataSource;
    tblPerson: TFDMemTable;
    tblKunde: TFDMemTable;
    dstblPerson: TDataSource;
    dstblKunde: TDataSource;
    qryMitarbeiterAuswahl: TFDQuery;
    dsMitarbeiterAuswahl: TDataSource;
    qryKontakte: TFDQuery;
    dstblKontakte: TDataSource;
    qryEmailUebersicht: TFDQuery;
    dstblEmailUebersicht: TDataSource;
    qryTelefonUebersicht: TFDQuery;
    dstblTelefonUebersicht: TDataSource;
    qryAdresseUebersicht: TFDQuery;
    dstblAdresseUebersicht: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FMandantId: Integer;
    function HauptpersonId: Integer;
    function RolleIdFuer(const ABezeichnung: string): Integer;
    // Legt bei Bedarf die fehlende kunde-Erweiterungszeile nach (falls
    // ist_kunde manuell im Personen-Modul gesetzt wurde, ohne je hier
    // angelegt worden zu sein) -- idempotent.
    procedure SicherstelleKundeZeile(APersonId: Integer);
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    procedure OpenKunde;
    function HauptpersonVorhanden: Boolean;
    procedure LadeListe;
    procedure LadeKunde(APersonId: Integer);
    function NeuerKunde: Integer;  // liefert den neuen person_id
    procedure BearbeitenKunde;
    procedure SpeichernKunde;
    procedure AbbrechenKunde;
  end;

var
  dmKunde: TdmKunde;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  KundeFrm, System.SyncObjs;

var
  GSperreKunde: TCriticalSection;

class function TdmKunde.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmKunde) then
  begin
    GSperreKunde.Enter;
    try
      if not Assigned(dmKunde) then
        Application.CreateForm(TdmKunde, dmKunde);
    finally
      GSperreKunde.Leave;
    end;
  end;
  Result := dmKunde;
end;

procedure TdmKunde.DataModuleCreate(Sender: TObject);
begin
  qryKunden.Connection              := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryMitarbeiterAuswahl.Connection  := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryKontakte.Connection            := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryEmailUebersicht.Connection     := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryTelefonUebersicht.Connection   := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
  qryAdresseUebersicht.Connection   := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

  tblPerson.UpdateOptions.AutoIncFields := 'person_id';
  tblKunde.UpdateOptions.AutoIncFields  := 'kunde_id';

  qryKunden.SQL.Text :=
    'SELECT p.person_id, p.nachname_firmenname AS name, ' +
    '  bp.nachname_firmenname AS besitzer_name ' +
    'FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
    'LEFT JOIN kunde ku ON ku.person_id = p.person_id ' +
    'LEFT JOIN person bp ON bp.person_id = ku.besitzer_person_id ' +
    'WHERE pb.mandant_id = :m AND pb.ist_kunde = true ' +
    '  AND pb.ziel_person_id = (SELECT pm.person_id FROM person_mandant pm ' +
    '                            WHERE pm.mandant_id = :m AND pm.ist_hauptperson = true) ' +
    'ORDER BY p.nachname_firmenname';

  qryMitarbeiterAuswahl.SQL.Text :=
    'SELECT p.person_id, p.nachname_firmenname ' +
    'FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
    'WHERE pb.mandant_id = :m AND pb.ist_mitarbeiter = true ' +
    '  AND pb.ziel_person_id = (SELECT pm.person_id FROM person_mandant pm ' +
    '                            WHERE pm.mandant_id = :m AND pm.ist_hauptperson = true) ' +
    'ORDER BY p.nachname_firmenname';

  qryKontakte.SQL.Text :=
    'SELECT p.person_id, p.vorname, p.nachname_firmenname, k.abteilung ' +
    'FROM klient k JOIN person p ON p.person_id = k.person_id ' +
    'WHERE k.kunde_person_id = :p ORDER BY p.nachname_firmenname';

  qryEmailUebersicht.SQL.Text :=
    'SELECT e.email_adresse, et.bezeichnung AS typ ' +
    'FROM person_email pe JOIN emailadresse e ON e.email_id = pe.email_id ' +
    'LEFT JOIN emailtyp et ON et.mandant_id = pe.mandant_id AND et.emailtyp_id = pe.emailtyp_id ' +
    'WHERE pe.person_id = :p';

  qryTelefonUebersicht.SQL.Text :=
    'SELECT t.nummer, tt.bezeichnung AS typ ' +
    'FROM person_telefonnummer pt JOIN telefonnummer t ON t.telefonnummer_id = pt.telefonnummer_id ' +
    'LEFT JOIN telefonnummertyp tt ON tt.mandant_id = pt.mandant_id AND tt.telefonnummertyp_id = pt.telefonnummertyp_id ' +
    'WHERE pt.person_id = :p';

  qryAdresseUebersicht.SQL.Text :=
    'SELECT a.strasse, a.hausnummer, a.plz, a.ort, at.bezeichnung AS typ ' +
    'FROM person_adresse pa JOIN adresse a ON a.adresse_id = pa.adresse_id ' +
    'LEFT JOIN adressentyp at ON at.mandant_id = pa.mandant_id AND at.adressentyp_id = pa.adressentyp_id ' +
    'WHERE pa.person_id = :p';
end;

function TdmKunde.HauptpersonId: Integer;
var
  LQry: TFDQuery;
begin
  Result := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT person_id FROM person_mandant WHERE mandant_id = :m AND ist_hauptperson = true';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.FieldByName('person_id').AsInteger;
  finally
    LQry.Free;
  end;
end;

function TdmKunde.HauptpersonVorhanden: Boolean;
begin
  Result := HauptpersonId > 0;
end;

function TdmKunde.RolleIdFuer(const ABezeichnung: string): Integer;
var
  LQry: TFDQuery;
begin
  Result := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'SELECT rolle_id FROM rolle_typ WHERE mandant_id = :m AND rollen_bezeichnung = :b';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('b').AsString := ABezeichnung;
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.FieldByName('rolle_id').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TdmKunde.SicherstelleKundeZeile(APersonId: Integer);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text := 'INSERT INTO kunde (person_id, mandant_id) VALUES (:p, :m) ' +
      'ON CONFLICT (person_id) DO NOTHING';
    LQry.ParamByName('p').AsInteger := APersonId;
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TdmKunde.LadeListe;
begin
  qryKunden.Close;
  qryKunden.ParamByName('m').AsInteger := FMandantId;
  qryKunden.Open;
end;

procedure TdmKunde.LadeKunde(APersonId: Integer);
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblKunde.State in dsEditModes then tblKunde.Cancel;

  SicherstelleKundeZeile(APersonId);

  tblPerson.Locate('person_id', APersonId, []);
  tblKunde.Locate('person_id', APersonId, []);

  qryKontakte.Close;
  qryKontakte.ParamByName('p').AsInteger := APersonId;
  qryKontakte.Open;

  qryEmailUebersicht.Close;
  qryEmailUebersicht.ParamByName('p').AsInteger := APersonId;
  qryEmailUebersicht.Open;

  qryTelefonUebersicht.Close;
  qryTelefonUebersicht.ParamByName('p').AsInteger := APersonId;
  qryTelefonUebersicht.Open;

  qryAdresseUebersicht.Close;
  qryAdresseUebersicht.ParamByName('p').AsInteger := APersonId;
  qryAdresseUebersicht.Open;
end;

// Mehrfach-INSERT wie TdmKlient.NeuerKlient (siehe dort): person existiert
// noch nicht, muss vor person_beziehung/kunde zuerst angelegt werden.
function TdmKunde.NeuerKunde: Integer;
var
  LQry: TFDQuery;
  LHauptperson, LRolleId: Integer;
begin
  LHauptperson := HauptpersonId;
  if LHauptperson <= 0 then
    raise Exception.Create('Kein Hauptperson fuer diesen Mandanten gefunden.');
  LRolleId := RolleIdFuer('Kunde');
  if LRolleId <= 0 then
    raise Exception.Create('Rollentyp ''Kunde'' fehlt in rolle_typ fuer diesen Mandanten.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

    LQry.SQL.Text := 'INSERT INTO person (typ_id, nachname_firmenname) ' +
      'VALUES (2, ''Neuer Kunde'') RETURNING person_id';
    LQry.Open;
    Result := LQry.FieldByName('person_id').AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'INSERT INTO person_mandant (person_id, mandant_id) VALUES (:p, :m)';
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ExecSQL;

    LQry.SQL.Text := 'INSERT INTO person_beziehung (mandant_id, quell_person_id, ziel_person_id, rolle_id, ist_kunde) ' +
      'VALUES (:m, :p, :h, :r, true)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('h').AsInteger := LHauptperson;
    LQry.ParamByName('r').AsInteger := LRolleId;
    LQry.ExecSQL;

    LQry.SQL.Text := 'INSERT INTO kunde (person_id, mandant_id) VALUES (:p, :m)';
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;

  LadeListe;
  LadeKunde(Result);
  BearbeitenKunde;
end;

procedure TdmKunde.BearbeitenKunde;
begin
  if not tblPerson.IsEmpty and not (tblPerson.State in dsEditModes) then
    tblPerson.Edit;
  if not tblKunde.IsEmpty and not (tblKunde.State in dsEditModes) then
    tblKunde.Edit;
end;

procedure TdmKunde.SpeichernKunde;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Post;
  if tblKunde.State in dsEditModes then
    tblKunde.Post;
  LadeListe;
end;

procedure TdmKunde.AbbrechenKunde;
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblKunde.State in dsEditModes then tblKunde.Cancel;
end;

procedure TdmKunde.OpenKunde;
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

  // Speichertabellen kommen aus dem zentralen Datenmodul
  TabellenLaden;

  qryMitarbeiterAuswahl.Close;
  qryMitarbeiterAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryMitarbeiterAuswahl.Open;

  LadeListe;

  if not Assigned(frmKunde) then
    frmKunde := TfrmKunde.Create(Application);
  frmKunde.Show;
end;


procedure TdmKunde.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblKunde, 'kunde'),
    Zuordnung(tblPerson, 'person')]);
end;



initialization
  GSperreKunde := TCriticalSection.Create;

finalization
  GSperreKunde.Free;

end.
