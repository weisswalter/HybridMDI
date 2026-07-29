unit KlientDm;

// Klient-Modul: erweitert die bestehende person/person_beziehung-Infrastruktur
// (siehe sql/klient_kunde.sql) um die von Walter vorgelegten CRM-Felder statt
// eine parallele Personenverwaltung zu bauen. Name/E-Mail/Telefon/Adresse/
// Beschreibung sind bereits ueber person/person_email/person_telefonnummer/
// person_adresse (PersonenDm) abgedeckt -- hier nur die Zusatzfelder
// (Titel, Geburtsdatum, Abteilung, Kundenname-Verknuepfung, Lead-Quelle,
// Besitzer) plus die Semester-Zuordnung (Zeitabschnitt-Filter).
//
// tblPerson und tblKlient sind zwei EINFACHE Tabellen (person / klient,
// person_id 1:1), jeweils per Locate auf den aktuell gewaehlten Klienten
// positioniert -- kein Master-Detail, da beide Tabellen unabhaengig editierbar
// bleiben muessen (Bearbeiten/Speichern/Abbrechen wirkt bewusst auf BEIDE
// gleichzeitig, siehe Bearbeiten/Speichern/Abbrechen unten). "Neu" kann nicht
// einfach tblKlient.Append sein (klient.person_id ist NOT NULL FK) -- deshalb
// NeuerKlient als eigene Methode analog ArtikelStammDm.NeueAdresseFuerHauptperson
// (mehrere INSERTs in einer Methode statt TFDTable-Automatik).

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
  TdmKlient = class(TdmModuleTemplate)
    qryKlienten: TFDQuery;
    dstblKlientenListe: TDataSource;
    tblPerson: TFDTable;
    tblKlient: TFDTable;
    dstblPerson: TDataSource;
    dstblKlient: TDataSource;
    qryKundeAuswahl: TFDQuery;
    dsKundeAuswahl: TDataSource;
    qryMitarbeiterAuswahl: TFDQuery;
    dsMitarbeiterAuswahl: TDataSource;
    qryLeadquelleAuswahl: TFDQuery;
    dsLeadquelleAuswahl: TDataSource;
    qrySemesterAuswahl: TFDQuery;
    dsSemesterAuswahl: TDataSource;
    qryKlientSemester: TFDQuery;
    dstblKlientSemester: TDataSource;
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
  public
    class function GetInstance: TObject;
    procedure OpenKlient;
    function HauptpersonVorhanden: Boolean;
    // Liste (links) neu laden, optional auf ein Semester gefiltert
    // (ASemesterId = 0 -> alle Semester, keine Filterung).
    procedure LadeListe(ASemesterId: Integer);
    // Positioniert tblPerson/tblKlient auf den gewaehlten Klienten und laedt
    // die Uebersichts-Grids (E-Mail/Telefon/Adresse/Semester) nach.
    procedure LadeKlient(APersonId, AKlientId: Integer);
    function NeuerKlient: Integer;  // liefert den neuen person_id
    procedure BearbeitenKlient;
    procedure SpeichernKlient;
    procedure AbbrechenKlient;
    procedure FuegeSemesterHinzu(ASemesterId: Integer);
    procedure EntferneSemester(ASemesterId: Integer);
  end;

var
  dmKlient: TdmKlient;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  KlientFrm;

class function TdmKlient.GetInstance: TObject;
begin
  Result := dmKlient;
end;

procedure TdmKlient.DataModuleCreate(Sender: TObject);
begin
  qryKlienten.Connection            := PGManagerDm.dmPGManager.FDConnection1;
  tblPerson.Connection              := PGManagerDm.dmPGManager.FDConnection1;
  tblKlient.Connection              := PGManagerDm.dmPGManager.FDConnection1;
  qryKundeAuswahl.Connection        := PGManagerDm.dmPGManager.FDConnection1;
  qryMitarbeiterAuswahl.Connection  := PGManagerDm.dmPGManager.FDConnection1;
  qryLeadquelleAuswahl.Connection   := PGManagerDm.dmPGManager.FDConnection1;
  qrySemesterAuswahl.Connection     := PGManagerDm.dmPGManager.FDConnection1;
  qryKlientSemester.Connection      := PGManagerDm.dmPGManager.FDConnection1;
  qryEmailUebersicht.Connection     := PGManagerDm.dmPGManager.FDConnection1;
  qryTelefonUebersicht.Connection   := PGManagerDm.dmPGManager.FDConnection1;
  qryAdresseUebersicht.Connection   := PGManagerDm.dmPGManager.FDConnection1;

  tblPerson.UpdateOptions.AutoIncFields := 'person_id';
  tblKlient.UpdateOptions.AutoIncFields := 'klient_id';

  qryKlienten.SQL.Text :=
    'SELECT k.klient_id, p.person_id, p.vorname, p.nachname_firmenname, p.titel, ' +
    '  p.geburtsdatum, k.abteilung, kp.nachname_firmenname AS kunde_name, ' +
    '  lq.bezeichnung AS leadquelle_name, bp.nachname_firmenname AS besitzer_name ' +
    'FROM klient k ' +
    'JOIN person p ON p.person_id = k.person_id ' +
    'LEFT JOIN person kp ON kp.person_id = k.kunde_person_id ' +
    'LEFT JOIN leadquelle_typ lq ON lq.mandant_id = k.mandant_id AND lq.leadquelle_id = k.leadquelle_id ' +
    'LEFT JOIN person bp ON bp.person_id = k.besitzer_person_id ' +
    'WHERE k.mandant_id = :m ' +
    '  AND (:semester_id = 0 OR EXISTS (SELECT 1 FROM klient_semester ks ' +
    '       WHERE ks.klient_id = k.klient_id AND ks.semester_id = :semester_id)) ' +
    'ORDER BY p.nachname_firmenname, p.vorname';

  qryKundeAuswahl.SQL.Text :=
    'SELECT p.person_id, p.nachname_firmenname ' +
    'FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
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

  qryLeadquelleAuswahl.SQL.Text :=
    'SELECT leadquelle_id, bezeichnung FROM leadquelle_typ WHERE mandant_id = :m ORDER BY bezeichnung';

  qrySemesterAuswahl.SQL.Text :=
    'SELECT semester_id, bezeichnung FROM semester WHERE mandant_id = :m ORDER BY von_datum DESC NULLS LAST, bezeichnung';

  qryKlientSemester.SQL.Text :=
    'SELECT ks.semester_id, s.bezeichnung, s.von_datum, s.bis_datum ' +
    'FROM klient_semester ks JOIN semester s ON s.semester_id = ks.semester_id ' +
    'WHERE ks.klient_id = :k ORDER BY s.von_datum DESC NULLS LAST';

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

function TdmKlient.HauptpersonId: Integer;
var
  LQry: TFDQuery;
begin
  Result := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT person_id FROM person_mandant WHERE mandant_id = :m AND ist_hauptperson = true';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.FieldByName('person_id').AsInteger;
  finally
    LQry.Free;
  end;
end;

function TdmKlient.HauptpersonVorhanden: Boolean;
begin
  Result := HauptpersonId > 0;
end;

function TdmKlient.RolleIdFuer(const ABezeichnung: string): Integer;
var
  LQry: TFDQuery;
begin
  Result := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
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

procedure TdmKlient.LadeListe(ASemesterId: Integer);
begin
  qryKlienten.Close;
  qryKlienten.ParamByName('m').AsInteger := FMandantId;
  qryKlienten.ParamByName('semester_id').AsInteger := ASemesterId;
  qryKlienten.Open;
end;

procedure TdmKlient.LadeKlient(APersonId, AKlientId: Integer);
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblKlient.State in dsEditModes then tblKlient.Cancel;
  tblPerson.Locate('person_id', APersonId, []);
  tblKlient.Locate('klient_id', AKlientId, []);

  qryEmailUebersicht.Close;
  qryEmailUebersicht.ParamByName('p').AsInteger := APersonId;
  qryEmailUebersicht.Open;

  qryTelefonUebersicht.Close;
  qryTelefonUebersicht.ParamByName('p').AsInteger := APersonId;
  qryTelefonUebersicht.Open;

  qryAdresseUebersicht.Close;
  qryAdresseUebersicht.ParamByName('p').AsInteger := APersonId;
  qryAdresseUebersicht.Open;

  qryKlientSemester.Close;
  qryKlientSemester.ParamByName('k').AsInteger := AKlientId;
  qryKlientSemester.Open;
end;

// Mehrfach-INSERT statt TFDTable-Automatik (siehe Unit-Kommentar): person
// existiert noch nicht, klient.person_id ist aber NOT NULL FK darauf.
function TdmKlient.NeuerKlient: Integer;
var
  LQry: TFDQuery;
  LHauptperson, LRolleId, LKlientId: Integer;
begin
  LHauptperson := HauptpersonId;
  if LHauptperson <= 0 then
    raise Exception.Create('Kein Hauptperson fuer diesen Mandanten gefunden.');
  LRolleId := RolleIdFuer('Klient');
  if LRolleId <= 0 then
    raise Exception.Create('Rollentyp ''Klient'' fehlt in rolle_typ fuer diesen Mandanten.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;

    LQry.SQL.Text := 'INSERT INTO person (typ_id, vorname, nachname_firmenname) ' +
      'VALUES (1, '''', ''Neuer Klient'') RETURNING person_id';
    LQry.Open;
    Result := LQry.FieldByName('person_id').AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'INSERT INTO person_mandant (person_id, mandant_id) VALUES (:p, :m)';
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ExecSQL;

    LQry.SQL.Text := 'INSERT INTO person_beziehung (mandant_id, quell_person_id, ziel_person_id, rolle_id, ist_klient) ' +
      'VALUES (:m, :p, :h, :r, true)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('h').AsInteger := LHauptperson;
    LQry.ParamByName('r').AsInteger := LRolleId;
    LQry.ExecSQL;

    LQry.SQL.Text := 'INSERT INTO klient (person_id, mandant_id) VALUES (:p, :m) RETURNING klient_id';
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    LKlientId := LQry.FieldByName('klient_id').AsInteger;
    LQry.Close;
  finally
    LQry.Free;
  end;

  LadeListe(0);
  LadeKlient(Result, LKlientId);
  BearbeitenKlient;
end;

procedure TdmKlient.BearbeitenKlient;
begin
  if not tblPerson.IsEmpty and not (tblPerson.State in dsEditModes) then
    tblPerson.Edit;
  if not tblKlient.IsEmpty and not (tblKlient.State in dsEditModes) then
    tblKlient.Edit;
end;

procedure TdmKlient.SpeichernKlient;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Post;
  if tblKlient.State in dsEditModes then
    tblKlient.Post;
  LadeListe(0);
end;

procedure TdmKlient.AbbrechenKlient;
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblKlient.State in dsEditModes then tblKlient.Cancel;
end;

procedure TdmKlient.FuegeSemesterHinzu(ASemesterId: Integer);
begin
  if tblKlient.IsEmpty or (ASemesterId <= 0) then
    Exit;
  qryKlientSemester.Close;
  qryKlientSemester.SQL.Text := 'INSERT INTO klient_semester (klient_id, semester_id, mandant_id) ' +
    'VALUES (:k, :s, :m) ON CONFLICT DO NOTHING';
  qryKlientSemester.ParamByName('k').AsInteger := tblKlient.FieldByName('klient_id').AsInteger;
  qryKlientSemester.ParamByName('s').AsInteger := ASemesterId;
  qryKlientSemester.ParamByName('m').AsInteger := FMandantId;
  qryKlientSemester.ExecSQL;

  qryKlientSemester.SQL.Text :=
    'SELECT ks.semester_id, s.bezeichnung, s.von_datum, s.bis_datum ' +
    'FROM klient_semester ks JOIN semester s ON s.semester_id = ks.semester_id ' +
    'WHERE ks.klient_id = :k ORDER BY s.von_datum DESC NULLS LAST';
  qryKlientSemester.ParamByName('k').AsInteger := tblKlient.FieldByName('klient_id').AsInteger;
  qryKlientSemester.Open;
end;

procedure TdmKlient.EntferneSemester(ASemesterId: Integer);
var
  LKlientId: Integer;
begin
  if tblKlient.IsEmpty then
    Exit;
  LKlientId := tblKlient.FieldByName('klient_id').AsInteger;
  qryKlientSemester.Close;
  qryKlientSemester.SQL.Text := 'DELETE FROM klient_semester WHERE klient_id = :k AND semester_id = :s';
  qryKlientSemester.ParamByName('k').AsInteger := LKlientId;
  qryKlientSemester.ParamByName('s').AsInteger := ASemesterId;
  qryKlientSemester.ExecSQL;

  qryKlientSemester.SQL.Text :=
    'SELECT ks.semester_id, s.bezeichnung, s.von_datum, s.bis_datum ' +
    'FROM klient_semester ks JOIN semester s ON s.semester_id = ks.semester_id ' +
    'WHERE ks.klient_id = :k ORDER BY s.von_datum DESC NULLS LAST';
  qryKlientSemester.ParamByName('k').AsInteger := LKlientId;
  qryKlientSemester.Open;
end;

procedure TdmKlient.OpenKlient;
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

  if not HauptpersonVorhanden then
  begin
    ShowMessage('F'#252'r diesen Mandanten ist noch keine Hauptperson angelegt.' + sLineBreak +
      'Bitte zuerst im Personen-Modul eine Hauptperson festlegen.', '');
    Exit;
  end;

  tblPerson.Open;
  tblKlient.Open;

  qryKundeAuswahl.Close;
  qryKundeAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryKundeAuswahl.Open;

  qryMitarbeiterAuswahl.Close;
  qryMitarbeiterAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryMitarbeiterAuswahl.Open;

  qryLeadquelleAuswahl.Close;
  qryLeadquelleAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryLeadquelleAuswahl.Open;

  qrySemesterAuswahl.Close;
  qrySemesterAuswahl.ParamByName('m').AsInteger := FMandantId;
  qrySemesterAuswahl.Open;

  LadeListe(0);

  if not Assigned(frmKlient) then
    frmKlient := TfrmKlient.Create(Application);
  frmKlient.Show;
end;

end.
