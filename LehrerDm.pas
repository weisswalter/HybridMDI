unit LehrerDm;

// Lehrermodul - DataModule. Aufbau analog MitarbeiterDm (siehe dort fuer die
// allgemeinen Konventionen): zwei lockstep-Tabellen person + person_beziehung,
// gemeinsam bearbeitet, dazu die Uebersichten.
//
// ANSTELLUNGSART wird ABGELEITET, nicht gespeichert (Walters Vorgabe
// 29.07.2026):
//   ist_lehrer und ist_mitarbeiter  -> Lohnmitarbeiter
//   ist_lehrer ohne ist_mitarbeiter -> Honorarlehrer
// Bewusst kein drittes Flag: sonst gaebe es drei Wahrheiten, die auseinander
// laufen koennen. Die Ableitung steht im SQL der Liste, damit sie an genau
// einer Stelle liegt.
//
// Kompetenzen kommen aus person_kompetenz und sind der Gegenpart zu
// kurs_kompetenz mit rolle='lehrer': erst daraus laesst sich beantworten,
// welcher Lehrer einen Kurs ueberhaupt halten darf.

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
  TdmLehrer = class(TdmModuleTemplate)
    // Kopien der Views aus dem zentralen Datenmodul.
    qryLehrer: TFDMemTable;
    dstblLehrer: TDataSource;
    tblPerson: TFDMemTable;
    dstblPerson: TDataSource;
    tblPersonBeziehung: TFDMemTable;
    dstblPersonBeziehung: TDataSource;
    qryKompetenzen: TFDMemTable;
    dstblKompetenzen: TDataSource;
    qryKompetenzAuswahl: TFDMemTable;
    dsKompetenzAuswahl: TDataSource;
    qryKurse: TFDMemTable;
    dstblKurse: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FMandantId: Integer;
    FPersonId: Integer;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    property MandantId: Integer read FMandantId;
    property PersonId: Integer read FPersonId;

    procedure OpenLehrer;
    procedure LadeListe;
    procedure LadeLehrer(APersonId, ABeziehungsId: Integer);

    procedure Bearbeiten;
    procedure Speichern;
    procedure Abbrechen;

    // Kompetenz eintragen. AGueltigBis = 0 heisst unbefristet; ist am
    // Kompetenztyp eine Gueltigkeitsdauer hinterlegt, wird sie aus
    // erworben_am hochgerechnet.
    function KompetenzHinzufuegen(AKompetenzId: Integer;
      AErworbenAm, AGueltigBis: TDate; const ABemerkung: string): string;
    procedure KompetenzEntfernen(APersonKompetenzId: Integer);
  end;

var
  dmLehrer: TdmLehrer;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm, uGridMemo,
  System.Variants,
  Vcl.Dialogs,
  MandantDm,
  LehrerFrm, System.SyncObjs;

var
  GSperreLehrer: TCriticalSection;

class function TdmLehrer.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmLehrer) then
  begin
    GSperreLehrer.Enter;
    try
      if not Assigned(dmLehrer) then
        Application.CreateForm(TdmLehrer, dmLehrer);
    finally
      GSperreLehrer.Leave;
    end;
  end;
  Result := dmLehrer;
end;

procedure TdmLehrer.DataModuleCreate(Sender: TObject);
begin
  // Keine Verbindung und kein Inline-SQL mehr: alle Listen sind Kopien aus
  // dem zentralen Datenmodul. Die frueheren Abfragen stehen jetzt als Views
  // in der Datenbank:
  //   v_lehrer_liste            - Anstellungsart abgeleitet (siehe oben)
  //   v_person_kompetenz_status - Reststatus der Nachweise
  //   v_lehrer_kurs_eignung     - darf dieser Lehrer diesen Kurs halten
  tblPerson.UpdateOptions.AutoIncFields          := 'person_id';
  tblPersonBeziehung.UpdateOptions.AutoIncFields := 'beziehungs_id';
end;

// ── Laden ───────────────────────────────────────────────────────────────────

procedure TdmLehrer.LadeListe;
begin
  TabellenLaden;

  if not qryLehrer.IsEmpty then
    LadeLehrer(qryLehrer.FieldByName('person_id').AsInteger,
               qryLehrer.FieldByName('beziehungs_id').AsInteger)
  else
    LadeLehrer(0, 0);
end;

// Was frueher die Parameter :p und :m der Queries waren, ist jetzt ein
// Filter auf der Kopie im Speicher.
procedure TdmLehrer.LadeLehrer(APersonId, ABeziehungsId: Integer);
begin
  if tblPerson.State in dsEditModes then tblPerson.Cancel;
  if tblPersonBeziehung.State in dsEditModes then tblPersonBeziehung.Cancel;

  FPersonId := APersonId;

  if APersonId <= 0 then
    Exit;

  // Kompetenzen und Kurseignung haengen per MasterSource/MasterFields an
  // qryLehrer (im DFM eingetragen) und ziehen von selbst nach. Hier wird nur
  // noch der Satzzeiger der beiden Stammtabellen mitgefuehrt.
  tblPerson.Locate('person_id', APersonId, []);
  if ABeziehungsId > 0 then
    tblPersonBeziehung.Locate('beziehungs_id', ABeziehungsId, []);
end;

// ── Stammdaten ──────────────────────────────────────────────────────────────
// Angelegt werden Lehrer NICHT hier: eine Person entsteht im Personenmodul,
// hier wird nur das Haekchen "Lehrer" gesetzt. Das Modul zeigt und pflegt,
// es dupliziert die Personenanlage nicht.

procedure TdmLehrer.Bearbeiten;
begin
  if not tblPerson.IsEmpty then
    tblPerson.Edit;
end;

procedure TdmLehrer.Speichern;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Post;
  if tblPersonBeziehung.State in dsEditModes then
    tblPersonBeziehung.Post;
  LadeListe;
end;

procedure TdmLehrer.Abbrechen;
begin
  if tblPerson.State in dsEditModes then
    tblPerson.Cancel;
  if tblPersonBeziehung.State in dsEditModes then
    tblPersonBeziehung.Cancel;
end;

// ── Kompetenzen ─────────────────────────────────────────────────────────────

function TdmLehrer.KompetenzHinzufuegen(AKompetenzId: Integer;
  AErworbenAm, AGueltigBis: TDate; const ABemerkung: string): string;
var
  LGueltigBis: Variant;
begin
  Result := '';
  if FPersonId <= 0 then
    Exit('Bitte zuerst einen Lehrer w' + #228 + 'hlen.');
  if AKompetenzId <= 0 then
    Exit('Bitte eine Kompetenz w' + #228 + 'hlen.');

  // Ist am Typ eine Gueltigkeitsdauer hinterlegt und kein Enddatum
  // angegeben, rechnet die Datenbank es aus dem Erwerbsdatum hoch - so
  // steht die Regel an einer Stelle und nicht in jeder Maske neu.
  if AGueltigBis > 0 then
    LGueltigBis := AGueltigBis
  else
    LGueltigBis := Null;

  try
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
      'fn_person_kompetenz_setzen',
      [FMandantId, FPersonId, AKompetenzId, AErworbenAm, LGueltigBis,
       ABemerkung]);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance)
      .TabelleAuffrischen('person_kompetenz');
    TabellenLaden;
  except
    on E: Exception do
      if Pos('person_kompetenz_person_id_kompetenz_id_erworben_am_key',
             E.Message) > 0 then
        Result := 'Diese Kompetenz ist mit demselben Erwerbsdatum bereits ' +
                  'eingetragen.'
      else
        Result := E.Message;
  end;

  if Result = '' then
    LadeLehrer(FPersonId, 0);
end;

procedure TdmLehrer.KompetenzEntfernen(APersonKompetenzId: Integer);
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).SpAufrufen(
    'fn_person_kompetenz_loeschen', [APersonKompetenzId]);
  TdmZentraleDaten(TdmZentraleDaten.GetInstance)
    .TabelleAuffrischen('person_kompetenz');
  TabellenLaden;
  LadeLehrer(FPersonId, 0);
end;

// ── Start ───────────────────────────────────────────────────────────────────

procedure TdmLehrer.OpenLehrer;
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

  tblPerson.Filtered := False;
  // Speichertabellen kommen aus dem zentralen Datenmodul
  TabellenLaden;

  tblPersonBeziehung.Filtered := False;
  tblPersonBeziehung.Filter := Format('mandant_id=%d', [FMandantId]);
  tblPersonBeziehung.Filtered := True;


  LadeListe;

  if not Assigned(frmLehrer) then
    frmLehrer := TfrmLehrer.Create(Application);
  frmLehrer.Show;
end;


procedure TdmLehrer.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblPerson, 'person'),
    Zuordnung(tblPersonBeziehung, 'person_beziehung'),
    Zuordnung(qryLehrer, 'v_lehrer_liste'),
    Zuordnung(qryKompetenzen, 'v_person_kompetenz_status'),
    Zuordnung(qryKompetenzAuswahl, 'kompetenz_typ'),
    Zuordnung(qryKurse, 'v_lehrer_kurs_eignung')]);
  // v_person_kompetenz_status.bemerkung ist Postgres 'text' - ohne das
  // haette das Gitter dort nur "(WIDEMEMO)" gezeigt. Siehe uGridMemo.
  MemosLesbarMachen(qryKompetenzen);

  qryLehrer.Filtered := False;
  qryLehrer.Filter := Format('mandant_id = %d', [FMandantId]);
  qryLehrer.Filtered := True;
  qryLehrer.IndexFieldNames := 'nachname_firmenname;vorname';

  qryKompetenzAuswahl.Filtered := False;
  qryKompetenzAuswahl.Filter :=
    Format('mandant_id = %d and aktiv = true', [FMandantId]);
  qryKompetenzAuswahl.Filtered := True;
  qryKompetenzAuswahl.IndexFieldNames := 'bezeichnung';
end;



initialization
  GSperreLehrer := TCriticalSection.Create;

finalization
  GSperreLehrer.Free;

end.
