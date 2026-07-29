unit MitarbeiterDm;

// Mitarbeiter-Modul: Mitarbeiter sind IMMER Mitarbeiter der Hauptperson des
// Mandanten (Walters Klarstellung 27.07.2026: person_beziehung.ist_mitarbeiter
// bezieht sich ausschliesslich auf die Hauptperson -- kein Firma-Kontextwechsel
// noetig). Haben andere Firmen in der Personenliste (z.B. ein Kunde) eigene
// Mitarbeiter, werden die ueber die generische Beziehung erfasst OHNE das
// ist_mitarbeiter-Flag zu setzen -- das bleibt bewusst der Hauptperson
// vorbehalten und ist hier nicht Gegenstand dieses Moduls.
//
// Analog KlientDm (siehe dort fuer die allgemeinen Konventionen), aber ohne
// eigene Erweiterungstabelle -- die einzige Mitarbeiter-spezifische Angabe
// (die Rolle/der Jobtitel) liegt direkt auf person_beziehung.rolle_id. Zwei
// lockstep-Tabellen (person, person_beziehung), gemeinsam bearbeitet.

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
  TdmMitarbeiter = class(TdmModuleTemplate)
    qryMitarbeiter: TFDQuery;
    dstblMitarbeiterListe: TDataSource;
    tblPerson: TFDTable;
    tblPersonBeziehung: TFDTable;
    dstblPerson: TDataSource;
    dstblPersonBeziehung: TDataSource;
    qryRolleAuswahl: TFDQuery;
    dsRolleAuswahl: TDataSource;
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
    procedure OpenMitarbeiter;
    function HauptpersonVorhanden: Boolean;
    procedure LadeListe;
    procedure LadeMitarbeiter(APersonId, ABeziehungsId: Integer);
    function NeuerMitarbeiter: Integer;  // liefert den neuen person_id
    procedure BearbeitenMitarbeiter;
    procedure SpeichernMitarbeiter;
    procedure AbbrechenMitarbeiter;
  end;

var
  dmMitarbeiter: TdmMitarbeiter;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  MitarbeiterFrm;

class function TdmMitarbeiter.GetInstance: TObject;
begin
  Result := dmMitarbeiter;
end;

procedure TdmMitarbeiter.DataModuleCreate(Sender: TObject);
begin
  qryMitarbeiter.Connection        := PGManagerDm.dmPGManager.FDConnection1;
  tblPerson.Connection             := PGManagerDm.dmPGManager.FDConnection1;
  tblPersonBeziehung.Connection    := PGManagerDm.dmPGManager.FDConnection1;
  qryRolleAuswahl.Connection       := PGManagerDm.dmPGManager.FDConnection1;
  qryEmailUebersicht.Connection    := PGManagerDm.dmPGManager.FDConnection1;
  qryTelefonUebersicht.Connection  := PGManagerDm.dmPGManager.FDConnection1;
  qryAdresseUebersicht.Connection  := PGManagerDm.dmPGManager.FDConnection1;

  tblPerson.UpdateOptions.AutoIncFields          := 'person_id';
  tblPersonBeziehung.UpdateOptions.AutoIncFields := 'beziehungs_id';

  qryMitarbeiter.SQL.Text :=
    'SELECT pb.beziehungs_id, p.person_id, p.vorname, p.nachname_firmenname, ' +
    '  p.titel, p.geburtsdatum, rt.rollen_bezeichnung AS rolle_name ' +
    'FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
    'LEFT JOIN rolle_typ rt ON rt.mandant_id = pb.mandant_id AND rt.rolle_id = pb.rolle_id ' +
    'WHERE pb.mandant_id = :m AND pb.ist_mitarbeiter = true ' +
    '  AND pb.ziel_person_id = (SELECT pm.person_id FROM person_mandant pm ' +
    '                            WHERE pm.mandant_id = :m AND pm.ist_hauptperson = true) ' +
    'ORDER BY p.nachname_firmenname, p.vorname';

  qryRolleAuswahl.SQL.Text :=
    'SELECT rolle_id, rollen_bezeichnung FROM rolle_typ WHERE mandant_id = :m ORDER BY rollen_bezeichnung';

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

function TdmMitarbeiter.HauptpersonId: Integer;
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

function TdmMitarbeiter.HauptpersonVorhanden: Boolean;
begin
  Result := HauptpersonId > 0;
end;

function TdmMitarbeiter.RolleIdFuer(const ABezeichnung: string): Integer;
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

procedure TdmMitarbeiter.LadeListe;
begin
  qryMitarbeiter.Close;
  qryMitarbeiter.ParamByName('m').AsInteger := FMandantId;
  qryMitarbeiter.Open;
end;

procedure TdmMitarbeiter.LadeMitarbeiter(APersonId, ABeziehungsId: Integer);
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblPersonBeziehung.State in dsEditModes then tblPersonBeziehung.Cancel;
  tblPerson.Locate('person_id', APersonId, []);
  tblPersonBeziehung.Locate('beziehungs_id', ABeziehungsId, []);

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
// noch nicht, muss vor person_beziehung zuerst angelegt werden. Rolle
// bekommt vorlaeufig den generischen Fallback 'Mitarbeiter' (siehe
// sql/mitarbeiter.sql) -- der Anwender waehlt danach ueber die Rolle-Combo
// die tatsaechliche Rolle/den Jobtitel.
function TdmMitarbeiter.NeuerMitarbeiter: Integer;
var
  LQry: TFDQuery;
  LHauptperson, LRolleId: Integer;
begin
  LHauptperson := HauptpersonId;
  if LHauptperson <= 0 then
    raise Exception.Create('Kein Hauptperson fuer diesen Mandanten gefunden.');
  LRolleId := RolleIdFuer('Mitarbeiter');
  if LRolleId <= 0 then
    raise Exception.Create('Rollentyp ''Mitarbeiter'' fehlt in rolle_typ fuer diesen Mandanten.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;

    LQry.SQL.Text := 'INSERT INTO person (typ_id, vorname, nachname_firmenname) ' +
      'VALUES (1, '''', ''Neuer Mitarbeiter'') RETURNING person_id';
    LQry.Open;
    Result := LQry.FieldByName('person_id').AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'INSERT INTO person_mandant (person_id, mandant_id) VALUES (:p, :m)';
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ExecSQL;

    LQry.SQL.Text := 'INSERT INTO person_beziehung (mandant_id, quell_person_id, ziel_person_id, rolle_id, ist_mitarbeiter) ' +
      'VALUES (:m, :p, :h, :r, true) RETURNING beziehungs_id';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('p').AsInteger := Result;
    LQry.ParamByName('h').AsInteger := LHauptperson;
    LQry.ParamByName('r').AsInteger := LRolleId;
    LQry.Open;
    LadeListe;
    LadeMitarbeiter(Result, LQry.FieldByName('beziehungs_id').AsInteger);
    LQry.Close;
  finally
    LQry.Free;
  end;

  BearbeitenMitarbeiter;
end;

procedure TdmMitarbeiter.BearbeitenMitarbeiter;
begin
  if not tblPerson.IsEmpty and not (tblPerson.State in dsEditModes) then
    tblPerson.Edit;
  if not tblPersonBeziehung.IsEmpty and not (tblPersonBeziehung.State in dsEditModes) then
    tblPersonBeziehung.Edit;
end;

procedure TdmMitarbeiter.SpeichernMitarbeiter;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Post;
  if tblPersonBeziehung.State in dsEditModes then
    tblPersonBeziehung.Post;
  LadeListe;
end;

procedure TdmMitarbeiter.AbbrechenMitarbeiter;
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblPersonBeziehung.State in dsEditModes then tblPersonBeziehung.Cancel;
end;

procedure TdmMitarbeiter.OpenMitarbeiter;
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

  tblPersonBeziehung.Filtered := False;
  tblPersonBeziehung.Open;
  tblPersonBeziehung.Filter := Format('mandant_id=%d AND ist_mitarbeiter=True', [FMandantId]);
  tblPersonBeziehung.Filtered := True;

  qryRolleAuswahl.Close;
  qryRolleAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryRolleAuswahl.Open;

  LadeListe;

  if not Assigned(frmMitarbeiter) then
    frmMitarbeiter := TfrmMitarbeiter.Create(Application);
  frmMitarbeiter.Show;
end;

end.
