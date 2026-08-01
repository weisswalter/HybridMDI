unit ArtikelStammDm;

// Artikel-Stammdatenverwaltung — aus TemplateDm dupliziert (siehe dort fuer
// die allgemeinen Konventionen). Stamm = artikel, Detail = artikel_fach
// (Bestand je Regalfach). Zentrale Connection ueber PGManagerDm, wie im
// Template vorgegeben — KEINE eigene TFDConnection.
//
// mandant_id wird (wie bei person/lager) beim Neuanlegen ueber OnNewRecord
// vorbelegt. FMandantId wird in OpenArtikelStamm aus TdmMandant.CurrentMandantId
// uebernommen (wie in LagerDm.OpenLager) -- noetig, seit die Bestand-Baum-
// Neuanlage (Phase 2) echte Mandant-Daten braucht (Hauptperson-Adressen);
// vorher war das ein fester Platzhalter (mandant_id=1), was bei aktivem
// Mandant != TRT (z.B. BMW-Testdaten) zu falschen Ergebnissen fuehren wuerde.

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
  TdmArtikelStamm = class(TdmModuleTemplate)
    tblArtikel: TFDTable;
    tblArtikelFach: TFDTable;
    tblArtikelFoto: TFDTable;
    dstblArtikel: TDataSource;
    dstblArtikelFach: TDataSource;
    dstblArtikelFoto: TDataSource;
    qryBestandBaum: TFDQuery;
    qryStueckliste: TFDQuery;
    dstblStueckliste: TDataSource;
    qryStuecklisteBaum: TFDQuery;
    dsStuecklisteBaum: TDataSource;
    qryArtikelAuswahl: TFDQuery;
    dsArtikelAuswahl: TDataSource;
    qryVariantenBaum: TFDQuery;
    dsVariantenBaum: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblArtikelNewRecord(DataSet: TDataSet);
    procedure tblArtikelFachNewRecord(DataSet: TDataSet);
    procedure tblArtikelFotoNewRecord(DataSet: TDataSet);
    procedure tblArtikelAfterScroll(DataSet: TDataSet);
  private
    // TODO: durch echte Mandantenauswahl ersetzen, sobald es dafuer eine
    // zentrale Stelle gibt (siehe dmMandant) — bis dahin fester Platzhalter,
    // analog zum bisherigen Stand von PersonenDm/LagerDm vor der Umstellung.
    FMandantId: Integer;
    // artikel_foto hat kein Namensfeld. Fuer die Navigation im Fotogitter
    // reicht "Foto 1".."Foto n" -- umgesetzt als Anzeigeformat auf
    // "reihenfolge", ohne Eingriff in die Feldstruktur.
    procedure FotoAnzeigeEinrichten(DataSet: TDataSet);
    procedure FotoBezeichnungGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    // Hilfsabfrage fuer die Varianten-Funktionen. Eine eigene Query je
    // Aufruf, damit die offene Baumabfrage nicht angefasst wird.
    function NeueQuery: TFDQuery;
  public
    class function GetInstance: TObject;
    procedure OpenArtikelStamm;
    // Fuellt qryBestandBaum (fn_lagerort_bestand) fuer den Bestand-Baum neu;
    // wird bei jedem Artikelwechsel automatisch aufgerufen (tblArtikelAfterScroll).
    procedure LadeBestandBaum(AArtikelId: Integer);

    // Stueckliste des aktuellen Artikels (artikel_artikel) -- laeuft wie

    // der Bestand-Baum ueber tblArtikelAfterScroll mit.

    procedure LadeStueckliste(AArtikelId: Integer);
    // Stueckliste als BAUM (fn_artikel_stueckliste, sql/baum_rekursiv.sql).
    // Mehrstufig und selbstbezueglich - eine Abfrage je Ebene waere ein
    // Rundlauf zur Datenbank pro Ebene.
    procedure LadeStuecklisteBaum(AArtikelId: Integer);

    // ── Varianten ───────────────────────────────────────────────────────
    // Merkmalsbaum des Mandanten (Groesse > Deutsch > 50, Farbe, ...).
    // Liegt bewusst NICHT am Artikel: die Auspraegungen werden einmal
    // gepflegt und von allen Artikeln benutzt.
    procedure LadeVariantenBaum;
    // Fuellt eine Stringliste mit allen Auspraegungen (Blaettern) des
    // Mandanten; die ID haengt am Objects-Zeiger -- Muster wie bei
    // FuelleArtikelListe. Fuer die beiden Aequivalenz-ComboBoxen.
    procedure FuelleAuspraegungsListe(AItems: TStrings);
    // Legt einen Knoten an und haengt ihn gleich unter AElternId ein.
    // AElternId = 0 legt ein neues Merkmal auf oberster Ebene an.
    // Rueckgabe: leer bei Erfolg, sonst Klartextmeldung.
    function VarianteAnlegen(const AName: string; AElternId: Integer;
      out ANeueId: Integer): string;
    function VarianteUmbenennen(AVarianteId: Integer;
      const AName: string): string;
    // Loescht nur, wenn keine Kinder und keine Verwendung dranhaengen --
    // sonst risse es Artikelvarianten mit.
    function VarianteLoeschen(AVarianteId: Integer): string;
    // Zwei Auspraegungen als gleichwertig eintragen (46 = L).
    function VarianteGleichsetzen(AIdA, AIdB: Integer): string;
    function AequivalenzAufheben(AIdA, AIdB: Integer): string;
    // Fuellt eine Stringliste mit allen Artikeln des Mandanten, die ID
    // haengt am Objects-Zeiger - Muster wie im Bestand-Baum.
    procedure FuelleArtikelListe(AItems: TStrings);

    // Unterartikel hinzufuegen bzw. Menge aktualisieren.

    // Rueckgabe: leer bei Erfolg, sonst Klartextmeldung.

    function StuecklisteHinzufuegen(AArtikelId, AUnterArtikelId: Integer;

      AMenge: Double): string;

    procedure StuecklisteEntfernen(AArtikelId, AUnterArtikelId: Integer);
    // Manuelles Ein-/Ausbuchen ueber den Bestand-Baum (Phase 2): legt bei
    // Bedarf einen neuen artikel_fach-Satz an (Fach hatte noch keinen
    // Bestand fuer diesen Artikel) oder aktualisiert den vorhandenen.
    // Kapazitaetspruefung passiert VOR dem Aufruf in ArtikelStammFrm (nur
    // Warnung, keine Sperre -- hier wird ungeprueft geschrieben).
    procedure SetBestand(AFachId: Integer; AMenge: Double);
    // Phase 2 (ComboBox-EditLink im Baum statt Rechtsklick-Menue): Adress-
    // Auswahl kommt aus den Adressen der Hauptperson des Mandanten, NICHT aus
    // den schon-als-Lager-markierten Adressen -- das ist der eigentliche
    // Adresspool der Firma. Ohne Hauptperson ist die ganze Neuanlage-Kette
    // gesperrt (Walters Vorgabe).
    function HauptpersonVorhanden(AMandantId: Integer): Boolean;
    procedure LadeHauptpersonAdressen(AMandantId: Integer; AItems: TStrings);
    function NeueAdresseFuerHauptperson(AMandantId: Integer;
      const AStrasse, AHausnummer, APlz, AOrt: string): Integer;
    // Fuer eine BESTEHENDE Hauptperson-Adresse, die noch nie als Lager
    // genutzt wurde (kein lager-Satz vorhanden) -- idempotent.
    procedure EnsureAlsLagerMarkiert(AMandantId, AAdresseId: Integer);
    procedure LadeRaeumeFuerAdresse(AAdresseId: Integer; AItems: TStrings);
    function NeuerRaum(AAdresseId: Integer; const ABezeichnung: string): Integer;
    procedure LadeRegaleFuerRaum(ARaumId: Integer; AItems: TStrings);
    // Legt zusaetzlich automatisch ein erstes Fach an (Walters Vorgabe: ein
    // Regal hat immer mindestens ein Fach).
    function NeuesRegal(ARaumId: Integer; const ABezeichnung: string): Integer;
  end;

var
  dmArtikelStamm: TdmArtikelStamm;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  ArtikelStammFrm;

class function TdmArtikelStamm.GetInstance: TObject;
begin
  Result := dmArtikelStamm;
end;

procedure TdmArtikelStamm.DataModuleCreate(Sender: TObject);
begin
  tblArtikel.Connection      := PGManagerDm.dmPGManager.FDConnection1;
  tblArtikelFach.Connection  := PGManagerDm.dmPGManager.FDConnection1;
  tblArtikelFoto.Connection  := PGManagerDm.dmPGManager.FDConnection1;
  // Die Felder entstehen erst beim Open neu, deshalb hier nur den Handler
  // eintragen (der ID-Hook der Basisklasse sichert ihn und ruft ihn mit auf).
  tblArtikelFoto.AfterOpen := FotoAnzeigeEinrichten;
  qryBestandBaum.Connection  := PGManagerDm.dmPGManager.FDConnection1;
  qryBestandBaum.SQL.Text    := 'SELECT * FROM fn_lagerort_bestand(:artikel_id)';

  tblArtikel.AfterScroll := tblArtikelAfterScroll;



  qryStueckliste.Connection := PGManagerDm.dmPGManager.FDConnection1;

  qryStuecklisteBaum.Connection := PGManagerDm.dmPGManager.FDConnection1;
  qryArtikelAuswahl.Connection := PGManagerDm.dmPGManager.FDConnection1;
  // EIGENE Liste fuer die Unterartikel-Auswahl. Haengt die Combo an
  // dstblArtikel, wandert beim Auswaehlen der Hauptartikel mit - dann
  // sind Ober- und Unterartikel immer derselbe Satz.
  qryArtikelAuswahl.SQL.Text :=
    'SELECT artikel_id, artikel_nr, artikelname FROM artikel ' +
    'WHERE mandant_id = :m ORDER BY artikelname';

  // Merkmalsbaum des Mandanten -- liefert Ebene und Sortpfad, den Aufbau
  // macht BaueBaumAusEbenen wie beim Stuecklistenbaum.
  qryVariantenBaum.Connection := PGManagerDm.dmPGManager.FDConnection1;
  qryVariantenBaum.SQL.Text := 'SELECT * FROM fn_variante_baum(:m)';
  qryStuecklisteBaum.SQL.Text :=
    'SELECT * FROM fn_artikel_stueckliste(:a)';

  qryStueckliste.SQL.Text :=

    'SELECT aa.unter_artikel_id, aa.menge, aa.position, ' +

    '       a.artikel_nr, a.artikelname, e.name AS einheit ' +

    'FROM artikel_artikel aa ' +

    'JOIN artikel a ON a.artikel_id = aa.unter_artikel_id ' +

    'LEFT JOIN einheit e ON e.mandant_id = aa.mandant_id AND e.einheit_id = aa.einheit_id ' +

    'WHERE aa.artikel_id = :a ORDER BY aa.position NULLS LAST, a.artikelname';



  tblArtikel.UpdateOptions.AutoIncFields     := 'artikel_id';
  tblArtikelFach.UpdateOptions.AutoIncFields := 'artikel_fach_id';
  tblArtikelFoto.UpdateOptions.AutoIncFields := 'foto_id';

  tblArtikelFach.MasterSource     := dstblArtikel;
  tblArtikelFach.MasterFields     := 'artikel_id';
  tblArtikelFach.IndexFieldNames  := 'artikel_id';

  tblArtikelFoto.MasterSource     := dstblArtikel;
  tblArtikelFoto.MasterFields     := 'artikel_id';
  tblArtikelFoto.IndexFieldNames  := 'artikel_id';
end;

// Master-Detail belegt artikel_id automatisch vor (MasterFields), mandant_id
// muss wie bei person_typ/adressentyp explizit gesetzt werden.
procedure TdmArtikelStamm.tblArtikelNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
end;

procedure TdmArtikelStamm.tblArtikelFachNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('bestand').AsFloat := 0;
end;

procedure TdmArtikelStamm.tblArtikelFotoNewRecord(DataSet: TDataSet);
begin
  // artikel_id belegt die Master-Detail-Kopplung vor, mandant_id explizit.
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
end;

// artikel_foto hat kein Namensfeld. Statt dafuer persistente Felder oder ein
// berechnetes Feld anzulegen -- beides zwingt FireDAC dazu, KEINE dynamischen
// Felder mehr zu erzeugen, wodurch foto_id verschwindet und AutoIncFields
// scheitert -- bekommt das vorhandene Feld "reihenfolge" nur eine andere
// Darstellung. Der gespeicherte Wert bleibt die Zahl, angezeigt wird
// "Foto 1".."Foto n" bzw. die Beschreibung, wenn eine gepflegt ist.
// ── Varianten ───────────────────────────────────────────────────────────────

function TdmArtikelStamm.NeueQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := PGManagerDm.dmPGManager.FDConnection1;
end;

procedure TdmArtikelStamm.LadeVariantenBaum;
begin
  qryVariantenBaum.Close;
  qryVariantenBaum.ParamByName('m').AsInteger := FMandantId;
  qryVariantenBaum.Open;
end;

procedure TdmArtikelStamm.FuelleAuspraegungsListe(AItems: TStrings);
var
  LQry: TFDQuery;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    LQry := NeueQuery;
    try
      // Nur Blaetter: zwischen Gruppen ("Deutsch = Englisch") waere
      // Gleichheit sinnlos.
      LQry.SQL.Text :=
        'SELECT variante_id, pfad, aequivalenzen FROM fn_variante_baum(:m) ' +
        'WHERE NOT hat_kinder AND aktiv ORDER BY sortpfad';
      LQry.ParamByName('m').AsInteger := FMandantId;
      LQry.Open;
      while not LQry.Eof do
      begin
        // Der Pfad statt nur des Namens: "50" allein ist mehrdeutig,
        // "Groesse > Deutsch > 50" nicht.
        AItems.AddObject(LQry.FieldByName('pfad').AsString,
          TObject(LQry.FieldByName('variante_id').AsInteger));
        LQry.Next;
      end;
    finally
      LQry.Free;
    end;
  finally
    AItems.EndUpdate;
  end;
end;

function TdmArtikelStamm.VarianteAnlegen(const AName: string;
  AElternId: Integer; out ANeueId: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := EmptyStr;
  ANeueId := 0;
  if Trim(AName) = '' then
    Exit('Bitte eine Bezeichnung eingeben.');

  LQry := NeueQuery;
  try
    try
      LQry.SQL.Text := 'SELECT fn_variante_anlegen(:m, :n, :e) AS neu';
      LQry.ParamByName('m').AsInteger := FMandantId;
      LQry.ParamByName('n').AsString := Trim(AName);
      // 0 heisst "oberste Ebene" -- die Funktion erwartet dafuer NULL.
      if AElternId > 0 then
        LQry.ParamByName('e').AsInteger := AElternId
      else
        LQry.ParamByName('e').Clear;
      LQry.Open;
      ANeueId := LQry.FieldByName('neu').AsInteger;
    except
      // Zyklus- und Namenspruefung liegen als Trigger in der Datenbank.
      // Deren Meldungen sind bereits fuer Menschen geschrieben.
      on E: Exception do
        Result := E.Message;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmArtikelStamm.VarianteUmbenennen(AVarianteId: Integer;
  const AName: string): string;
var
  LQry: TFDQuery;
begin
  Result := EmptyStr;
  if Trim(AName) = '' then
    Exit('Bitte eine Bezeichnung eingeben.');

  LQry := NeueQuery;
  try
    try
      LQry.SQL.Text := 'UPDATE variante SET name = :n WHERE variante_id = :v';
      LQry.ParamByName('n').AsString := Trim(AName);
      LQry.ParamByName('v').AsInteger := AVarianteId;
      LQry.ExecSQL;
    except
      on E: Exception do
        Result := E.Message;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmArtikelStamm.VarianteLoeschen(AVarianteId: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := EmptyStr;
  LQry := NeueQuery;
  try
    try
      // Erst pruefen, dann loeschen: ein ON DELETE CASCADE auf
      // variante_variante wuerde stillschweigend den ganzen Ast mitnehmen.
      LQry.SQL.Text :=
        'SELECT (SELECT count(*) FROM variante_variante ' +
        '         WHERE nach_id = :v AND bezug = ''child'') AS kinder, ' +
        '       (SELECT count(*) FROM artikel_variante_wert ' +
        '         WHERE variante_id = :v2) AS benutzt';
      LQry.ParamByName('v').AsInteger := AVarianteId;
      LQry.ParamByName('v2').AsInteger := AVarianteId;
      LQry.Open;

      if LQry.FieldByName('kinder').AsInteger > 0 then
        Exit('Der Eintrag hat noch Unterelemente. Diese zuerst entfernen.');
      if LQry.FieldByName('benutzt').AsInteger > 0 then
        Exit('Der Eintrag wird von Artikelvarianten verwendet.');

      LQry.Close;
      LQry.SQL.Text := 'DELETE FROM variante WHERE variante_id = :v';
      LQry.ParamByName('v').AsInteger := AVarianteId;
      LQry.ExecSQL;
    except
      on E: Exception do
        Result := E.Message;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmArtikelStamm.VarianteGleichsetzen(AIdA, AIdB: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := EmptyStr;
  LQry := NeueQuery;
  try
    try
      LQry.SQL.Text := 'SELECT fn_variante_gleichsetzen(:m, :a, :b)';
      LQry.ParamByName('m').AsInteger := FMandantId;
      LQry.ParamByName('a').AsInteger := AIdA;
      LQry.ParamByName('b').AsInteger := AIdB;
      LQry.Open;
    except
      on E: Exception do
        Result := E.Message;
    end;
  finally
    LQry.Free;
  end;
end;

function TdmArtikelStamm.AequivalenzAufheben(AIdA, AIdB: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := EmptyStr;
  LQry := NeueQuery;
  try
    try
      // Beide Richtungen loeschen: erfasst wurde nur eine, welche ist
      // von aussen nicht erkennbar.
      LQry.SQL.Text :=
        'DELETE FROM variante_variante ' +
        ' WHERE bezug = ''aequivalenz'' ' +
        '   AND ((von_id = :a AND nach_id = :b) ' +
        '     OR (von_id = :b2 AND nach_id = :a2))';
      LQry.ParamByName('a').AsInteger := AIdA;
      LQry.ParamByName('b').AsInteger := AIdB;
      LQry.ParamByName('a2').AsInteger := AIdA;
      LQry.ParamByName('b2').AsInteger := AIdB;
      LQry.ExecSQL;
    except
      on E: Exception do
        Result := E.Message;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmArtikelStamm.FotoAnzeigeEinrichten(DataSet: TDataSet);
var
  LFeld: TField;
begin
  LFeld := DataSet.FindField('reihenfolge');
  if Assigned(LFeld) then
    LFeld.OnGetText := FotoBezeichnungGetText;
end;

procedure TdmArtikelStamm.FotoBezeichnungGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
var
  LNr: Integer;
  LBeschreibung: string;
begin
  if not DisplayText then
  begin
    // Beim Bearbeiten/Kopieren die nackte Zahl liefern
    Text := Sender.AsString;
    Exit;
  end;

  LBeschreibung := Trim(Sender.DataSet.FieldByName('beschreibung').AsString);
  if LBeschreibung <> '' then
  begin
    LBeschreibung := StringReplace(LBeschreibung, #13#10, ' ', [rfReplaceAll]);
    LBeschreibung := StringReplace(LBeschreibung, #10, ' ', [rfReplaceAll]);
    if Length(LBeschreibung) > 40 then
      LBeschreibung := Copy(LBeschreibung, 1, 37) + '...';
    Text := LBeschreibung;
    Exit;
  end;

  LNr := Sender.AsInteger;
  if LNr <= 0 then
    LNr := Sender.DataSet.RecNo;
  Text := Format('Foto %d', [LNr]);
end;

// Haelt den Bestand-Baum (Fotos-Pendant fuer die Bestand-Seite) synchron zum
// gerade angezeigten Artikel -- feuert bei jeder Navigation (Erster/Weiter/...)
// auf tblArtikel.
procedure TdmArtikelStamm.tblArtikelAfterScroll(DataSet: TDataSet);
begin
  if DataSet.IsEmpty then
    Exit;
  LadeBestandBaum(DataSet.FieldByName('artikel_id').AsInteger);

  LadeStueckliste(DataSet.FieldByName('artikel_id').AsInteger);
  LadeStuecklisteBaum(DataSet.FieldByName('artikel_id').AsInteger);
end;

procedure TdmArtikelStamm.LadeBestandBaum(AArtikelId: Integer);
begin
  qryBestandBaum.Close;
  qryBestandBaum.ParamByName('artikel_id').AsInteger := AArtikelId;
  qryBestandBaum.Open;
end;

// Locate sucht innerhalb des Master-Detail-gefilterten tblArtikelFach (nur
// Faecher des AKTUELLEN Artikels) nach fach_id -- Append fuellt artikel_id
// automatisch (MasterFields), mandant_id ueber tblArtikelFachNewRecord.
procedure TdmArtikelStamm.SetBestand(AFachId: Integer; AMenge: Double);
begin
  if tblArtikel.IsEmpty then
    Exit;

  if not tblArtikelFach.Locate('fach_id', AFachId, []) then
  begin
    tblArtikelFach.Append;
    tblArtikelFach.FieldByName('fach_id').AsInteger := AFachId;
  end
  else if not (tblArtikelFach.State in dsEditModes) then
    tblArtikelFach.Edit;
  tblArtikelFach.FieldByName('bestand').AsFloat := AMenge;
  tblArtikelFach.Post;

  // Baum neu laden, damit die Aenderung sofort sichtbar wird.
  LadeBestandBaum(tblArtikel.FieldByName('artikel_id').AsInteger);
end;

function TdmArtikelStamm.HauptpersonVorhanden(AMandantId: Integer): Boolean;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT 1 FROM person_mandant WHERE mandant_id = :m AND ist_hauptperson = true';
    LQry.ParamByName('m').AsInteger := AMandantId;
    LQry.Open;
    Result := not LQry.IsEmpty;
  finally
    LQry.Free;
  end;
end;

// Fuellt AItems mit den Adressen der Hauptperson (Objects[] traegt die
// adresse_id, damit der Aufrufer sie ohne erneute Abfrage zurueckbekommt).
procedure TdmArtikelStamm.LadeHauptpersonAdressen(AMandantId: Integer; AItems: TStrings);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text :=
      'SELECT a.adresse_id, ' +
      '  CAST(COALESCE(a.strasse, '''') || '' '' || COALESCE(a.hausnummer, '''') || ' +
      '    '', '' || COALESCE(a.plz, '''') || '' '' || COALESCE(a.ort, '''') ' +
      '    AS varchar(300)) AS anzeige ' +
      'FROM adresse a ' +
      'JOIN person_adresse pa ON pa.adresse_id = a.adresse_id ' +
      'WHERE pa.mandant_id = :m ' +
      '  AND pa.person_id = (SELECT pm.person_id FROM person_mandant pm ' +
      '                       WHERE pm.mandant_id = :m AND pm.ist_hauptperson = true) ' +
      'ORDER BY a.ort, a.strasse';
    LQry.ParamByName('m').AsInteger := AMandantId;
    LQry.Open;
    AItems.BeginUpdate;
    try
      AItems.Clear;
      while not LQry.Eof do
      begin
        AItems.AddObject(LQry.FieldByName('anzeige').AsString,
          TObject(NativeInt(LQry.FieldByName('adresse_id').AsInteger)));
        LQry.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LQry.Free;
  end;
end;

// Legt eine neue Adresse an, verknuepft sie mit der Hauptperson und markiert
// sie gleich als Lager -- sonst wuerde sie nie in fn_lagerort_bestand
// auftauchen (die Function filtert auf adresse_id IN lager).
function TdmArtikelStamm.NeueAdresseFuerHauptperson(AMandantId: Integer;
  const AStrasse, AHausnummer, APlz, AOrt: string): Integer;
var
  LQry: TFDQuery;
  LHauptpersonId: Integer;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;

    LQry.SQL.Text := 'SELECT person_id FROM person_mandant WHERE mandant_id = :m AND ist_hauptperson = true';
    LQry.ParamByName('m').AsInteger := AMandantId;
    LQry.Open;
    if LQry.IsEmpty then
      raise Exception.Create('Kein Hauptperson fuer diesen Mandanten gefunden.');
    LHauptpersonId := LQry.FieldByName('person_id').AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'INSERT INTO adresse (strasse, hausnummer, plz, ort) ' +
      'VALUES (:s, :h, :p, :o) RETURNING adresse_id';
    LQry.ParamByName('s').AsString := AStrasse;
    LQry.ParamByName('h').AsString := AHausnummer;
    LQry.ParamByName('p').AsString := APlz;
    LQry.ParamByName('o').AsString := AOrt;
    LQry.Open;
    Result := LQry.FieldByName('adresse_id').AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'INSERT INTO person_adresse (person_id, adresse_id, mandant_id) VALUES (:pid, :aid, :m)';
    LQry.ParamByName('pid').AsInteger := LHauptpersonId;
    LQry.ParamByName('aid').AsInteger := Result;
    LQry.ParamByName('m').AsInteger := AMandantId;
    LQry.ExecSQL;

    LQry.SQL.Text := 'INSERT INTO lager (mandant_id, adresse_id, beschreibung) VALUES (:m, :aid, :b)';
    LQry.ParamByName('m').AsInteger := AMandantId;
    LQry.ParamByName('aid').AsInteger := Result;
    LQry.ParamByName('b').AsString := 'Automatisch angelegt beim Ablegen im Bestand-Baum';
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TdmArtikelStamm.EnsureAlsLagerMarkiert(AMandantId, AAdresseId: Integer);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT 1 FROM lager WHERE mandant_id = :m AND adresse_id = :a';
    LQry.ParamByName('m').AsInteger := AMandantId;
    LQry.ParamByName('a').AsInteger := AAdresseId;
    LQry.Open;
    if LQry.IsEmpty then
    begin
      LQry.Close;
      LQry.SQL.Text := 'INSERT INTO lager (mandant_id, adresse_id, beschreibung) VALUES (:m, :a, :b)';
      LQry.ParamByName('m').AsInteger := AMandantId;
      LQry.ParamByName('a').AsInteger := AAdresseId;
      LQry.ParamByName('b').AsString := 'Automatisch angelegt beim Ablegen im Bestand-Baum';
      LQry.ExecSQL;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmArtikelStamm.LadeRaeumeFuerAdresse(AAdresseId: Integer; AItems: TStrings);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT raum_id, bezeichnung FROM raum WHERE adresse_id = :a ORDER BY bezeichnung';
    LQry.ParamByName('a').AsInteger := AAdresseId;
    LQry.Open;
    AItems.BeginUpdate;
    try
      AItems.Clear;
      while not LQry.Eof do
      begin
        AItems.AddObject(LQry.FieldByName('bezeichnung').AsString,
          TObject(NativeInt(LQry.FieldByName('raum_id').AsInteger)));
        LQry.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LQry.Free;
  end;
end;

// raum ist pool-weit ohne mandant_id (physische Gebaeudefakten, siehe
// project_heisenberg_db_schema) -- adressinfo_id bleibt hier bewusst leer
// (kein Eingang zugeordnet), passt zum bestehenden Fallback in BaueBestandBaum.
function TdmArtikelStamm.NeuerRaum(AAdresseId: Integer; const ABezeichnung: string): Integer;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'INSERT INTO raum (adresse_id, bezeichnung) VALUES (:a, :b) RETURNING raum_id';
    LQry.ParamByName('a').AsInteger := AAdresseId;
    LQry.ParamByName('b').AsString := ABezeichnung;
    LQry.Open;
    Result := LQry.FieldByName('raum_id').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TdmArtikelStamm.LadeRegaleFuerRaum(ARaumId: Integer; AItems: TStrings);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT regal_id, bezeichnung FROM regal WHERE raum_id = :r ORDER BY bezeichnung';
    LQry.ParamByName('r').AsInteger := ARaumId;
    LQry.Open;
    AItems.BeginUpdate;
    try
      AItems.Clear;
      while not LQry.Eof do
      begin
        AItems.AddObject(LQry.FieldByName('bezeichnung').AsString,
          TObject(NativeInt(LQry.FieldByName('regal_id').AsInteger)));
        LQry.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LQry.Free;
  end;
end;

// regal ist ebenfalls pool-weit; regal_fach dagegen mandantenbezogen (Walters
// Vorgabe von der Lager-Modul-Erweiterung) -- deshalb FMandantId hier.
// Legt zugleich ein erstes Fach an ("ein Regal hat mindestens ein Fach").
function TdmArtikelStamm.NeuesRegal(ARaumId: Integer; const ABezeichnung: string): Integer;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'INSERT INTO regal (raum_id, bezeichnung) VALUES (:r, :b) RETURNING regal_id';
    LQry.ParamByName('r').AsInteger := ARaumId;
    LQry.ParamByName('b').AsString := ABezeichnung;
    LQry.Open;
    Result := LQry.FieldByName('regal_id').AsInteger;
    LQry.Close;

    LQry.SQL.Text := 'INSERT INTO regal_fach (mandant_id, regal_id, bezeichnung) VALUES (:m, :r, :b)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('r').AsInteger := Result;
    LQry.ParamByName('b').AsString := 'Fach 1';
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TdmArtikelStamm.OpenArtikelStamm;
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

  tblArtikel.Open;
  tblArtikelFach.Open;
  tblArtikelFoto.Open;

  // WICHTIG: Form zuerst erzeugen -- FormCreate verdrahtet
  // qryBestandBaum.AfterOpen (siehe ArtikelStammFrm). Der manuelle
  // AfterScroll-Aufruf muss danach kommen, sonst laeuft LadeBestandBaum ins
  // Leere (AfterOpen noch nil) und FBestandWurzeln bleibt nil -> Crash beim
  // ersten Anzeigen des Bestand-Tabs.
  if not Assigned(frmArtikelStamm) then
    frmArtikelStamm := TfrmArtikelStamm.Create(Application);

  qryArtikelAuswahl.Close;
  qryArtikelAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryArtikelAuswahl.Open;

  tblArtikelAfterScroll(tblArtikel);  // AfterScroll feuert bei Open nicht von selbst

  // Merkmalsbaum haengt am Mandanten, nicht am Artikel -- einmal beim
  // Oeffnen laden reicht. Erst NACH dem Erzeugen des Formulars, sonst ist
  // der AfterOpen-Handler noch nicht gesetzt und der Baum bleibt leer.
  frmArtikelStamm.VariantenNeuLaden;

  frmArtikelStamm.Show;
end;



procedure TdmArtikelStamm.LadeStueckliste(AArtikelId: Integer);

begin

  qryStueckliste.Close;

  qryStueckliste.ParamByName('a').AsInteger := AArtikelId;

  qryStueckliste.Open;

end;

procedure TdmArtikelStamm.FuelleArtikelListe(AItems: TStrings);
begin
  AItems.Clear;
  if not qryArtikelAuswahl.Active then
    Exit;
  qryArtikelAuswahl.First;
  while not qryArtikelAuswahl.Eof do
  begin
    AItems.AddObject(
      qryArtikelAuswahl.FieldByName('artikelname').AsString,
      TObject(NativeInt(qryArtikelAuswahl.FieldByName('artikel_id').AsInteger)));
    qryArtikelAuswahl.Next;
  end;
end;

procedure TdmArtikelStamm.LadeStuecklisteBaum(AArtikelId: Integer);
begin
  qryStuecklisteBaum.Close;
  if AArtikelId <= 0 then
    Exit;
  qryStuecklisteBaum.ParamByName('a').AsInteger := AArtikelId;
  qryStuecklisteBaum.Open;
end;



// Der CHECK in artikel_artikel faengt nur die direkte Selbstreferenz ab.

// Mehrstufige Zyklen (A->B->C->A) prueft der Trigger aus

// sql/artikel_artikel_zyklus_trigger.sql -- dessen Fehler wird hier in eine

// verstaendliche Meldung uebersetzt.

function TdmArtikelStamm.StuecklisteHinzufuegen(AArtikelId, AUnterArtikelId: Integer;

  AMenge: Double): string;

var

  LQry: TFDQuery;

begin

  Result := EmptyStr;

  if AArtikelId = AUnterArtikelId then

    Exit('Ein Artikel kann nicht sein eigener Bestandteil sein.');

  LQry := TFDQuery.Create(nil);

  try

    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;

    LQry.SQL.Text :=

      'INSERT INTO artikel_artikel (mandant_id, artikel_id, unter_artikel_id, menge, position) ' +

      'VALUES (:m, :a, :u, :menge, ' +

      '  (SELECT COALESCE(MAX(position),0)+1 FROM artikel_artikel WHERE artikel_id = :a2)) ' +

      'ON CONFLICT (artikel_id, unter_artikel_id) DO UPDATE SET menge = :menge2';

    LQry.ParamByName('m').AsInteger := FMandantId;

    LQry.ParamByName('a').AsInteger := AArtikelId;

    LQry.ParamByName('u').AsInteger := AUnterArtikelId;

    LQry.ParamByName('menge').AsFloat := AMenge;

    LQry.ParamByName('a2').AsInteger := AArtikelId;

    LQry.ParamByName('menge2').AsFloat := AMenge;

    try

      LQry.ExecSQL;

    except

      on E: Exception do

        if Pos('zyklus', LowerCase(E.Message)) > 0 then

          Result := 'Das ergaebe eine Ringbeziehung: der Unterartikel enthaelt ' +

                    'diesen Artikel bereits (direkt oder ueber mehrere Ebenen).'

        else

          Result := E.Message;

    end;

  finally

    LQry.Free;

  end;

  if Result = EmptyStr then
  begin
    LadeStueckliste(AArtikelId);
    // Der Baum haengt immer am aktuell gewaehlten Hauptartikel -
    // eingehaengt wurde vielleicht mehrere Ebenen tiefer.
    if tblArtikel.Active and not tblArtikel.IsEmpty then
      LadeStuecklisteBaum(tblArtikel.FieldByName('artikel_id').AsInteger);
  end;

end;



procedure TdmArtikelStamm.StuecklisteEntfernen(AArtikelId, AUnterArtikelId: Integer);

var

  LQry: TFDQuery;

begin

  LQry := TFDQuery.Create(nil);

  try

    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;

    LQry.SQL.Text := 'DELETE FROM artikel_artikel WHERE artikel_id = :a AND unter_artikel_id = :u';

    LQry.ParamByName('a').AsInteger := AArtikelId;

    LQry.ParamByName('u').AsInteger := AUnterArtikelId;

    LQry.ExecSQL;

  finally

    LQry.Free;

  end;

  LadeStueckliste(AArtikelId);
  // Der Baum haengt immer am aktuell gewaehlten Hauptartikel -
  // eingehaengt wurde vielleicht mehrere Ebenen tiefer.
  if tblArtikel.Active and not tblArtikel.IsEmpty then
    LadeStuecklisteBaum(tblArtikel.FieldByName('artikel_id').AsInteger);
end;



end.
