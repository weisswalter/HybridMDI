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
  TdmEinstellungen = class(TdmModuleTemplate)
    tblPersonentyp: TFDMemTable;
    tblRollentyp: TFDMemTable;
    tblAdressentyp: TFDMemTable;
    tblEmailtyp: TFDMemTable;
    tblTelefonnummertyp: TFDMemTable;
    tblRechnungstyp: TFDMemTable;
    tblLeadquellentyp: TFDMemTable;
    tblKompetenztyp: TFDMemTable;
    tblKategorie: TFDMemTable;
    // Einstellungen der Website je Mandant (Shop an/aus, Waehrung, ...)
    memWebEinstellung: TFDMemTable;
    dstblPersonentyp: TDataSource;
    dstblRollentyp: TDataSource;
    dstblAdressentyp: TDataSource;
    dstblEmailtyp: TDataSource;
    dstblTelefonnummertyp: TDataSource;
    dstblRechnungstyp: TDataSource;
    dstblLeadquellentyp: TDataSource;
    dstblKompetenztyp: TDataSource;
    dstblKategorie: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure TypOnNewRecord(DataSet: TDataSet);
    procedure tblKategorieNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    // Holt alle Speichertabellen dieses Moduls aus dem zentralen
    // Datenmodul (geklont) bzw. holt sie notfalls selbst.
    procedure TabellenLaden;
  public
    class function GetInstance: TObject;
    procedure OpenEinstellungen;
    // Liefert die DataSource des Tabs mit Index AHeaderIndex (Reihenfolge wie
    // HeaderButtons in EinstellungenFrm).
    function DataSourceFuerTab(AHeaderIndex: Integer): TDataSource;
    // Alle Reiter schreiben ueber eine Datenbankfunktion. Welche das ist
    // und welche Felder sie bekommt, steht in ReiterInfo - eine Stelle
    // statt neun Speicherroutinen.
    function TypSpeichern(AHeaderIndex: Integer): string;
    function TypLoeschen(AHeaderIndex: Integer): string;
    // Bezeichnung des aktuellen Eintrags - fuer die Rueckfrage
    // vor dem Loeschen.
    function TypBezeichnung(AHeaderIndex: Integer): string;
    function TabelleFuerTab(AHeaderIndex: Integer): string;
    // Der Website-Reiter ist kein Gitter, sondern ein Formular mit
    // festen Schluesseln - deshalb ein eigener Weg statt TypSpeichern.
    function IstWebsiteTab(AHeaderIndex: Integer): Boolean;
    function WebWert(const ASchluessel: string): string;
    function WebWertSetzen(const ASchluessel, AWert: string): string;
  private
    procedure ReiterInfo(AHeaderIndex: Integer;
      out AFunktion, ATabelle, AIdFeld, AFelder: string;
      out AMitMandant: Boolean);
  public
  end;

var
  dmEinstellungen: TdmEinstellungen;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  EinstellungenFrm, System.SyncObjs;

var
  GSperreEinstellungen: TCriticalSection;

class function TdmEinstellungen.GetInstance: TObject;
begin
  // Doppelte Pruefung: der Assigned-Test allein ist nicht threadsicher -
  // zwei Threads koennen beide false sehen und beide eine Instanz anlegen.
  if not Assigned(dmEinstellungen) then
  begin
    GSperreEinstellungen.Enter;
    try
      if not Assigned(dmEinstellungen) then
        Application.CreateForm(TdmEinstellungen, dmEinstellungen);
    finally
      GSperreEinstellungen.Leave;
    end;
  end;
  Result := dmEinstellungen;
end;

procedure TdmEinstellungen.DataModuleCreate(Sender: TObject);
begin

  tblPersonentyp.UpdateOptions.AutoIncFields      := 'typ_id';
  tblRollentyp.UpdateOptions.AutoIncFields        := 'rolle_id';
  tblAdressentyp.UpdateOptions.AutoIncFields      := 'adressentyp_id';
  tblEmailtyp.UpdateOptions.AutoIncFields         := 'emailtyp_id';
  tblTelefonnummertyp.UpdateOptions.AutoIncFields := 'telefonnummertyp_id';
  tblRechnungstyp.UpdateOptions.AutoIncFields     := 'rechnungstyp_id';
  tblLeadquellentyp.UpdateOptions.AutoIncFields   := 'leadquelle_id';
  tblKompetenztyp.UpdateOptions.AutoIncFields     := 'kompetenz_id';
  tblKategorie.UpdateOptions.AutoIncFields        := 'kategorie_id';

  // Personentyp ist poolweit (kein mandant_id) -- kein TypOnNewRecord noetig.
  tblRollentyp.OnNewRecord        := TypOnNewRecord;
  tblAdressentyp.OnNewRecord      := TypOnNewRecord;
  tblEmailtyp.OnNewRecord         := TypOnNewRecord;
  tblTelefonnummertyp.OnNewRecord := TypOnNewRecord;
  tblRechnungstyp.OnNewRecord     := TypOnNewRecord;
  tblLeadquellentyp.OnNewRecord   := TypOnNewRecord;
  tblKompetenztyp.OnNewRecord     := TypOnNewRecord;
  tblKategorie.OnNewRecord        := tblKategorieNewRecord;
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
    7: Result := dstblKompetenztyp;
    8: Result := dstblKategorie;
  else
    Result := nil;
  end;
end;

procedure TdmEinstellungen.OpenEinstellungen;
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

  // Speichertabellen kommen aus dem zentralen Datenmodul
  TabellenLaden;

  tblRollentyp.Filtered := False;
  tblRollentyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblRollentyp.Filtered := True;

  tblAdressentyp.Filtered := False;
  tblAdressentyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblAdressentyp.Filtered := True;

  tblEmailtyp.Filtered := False;
  tblEmailtyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblEmailtyp.Filtered := True;

  tblTelefonnummertyp.Filtered := False;
  tblTelefonnummertyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblTelefonnummertyp.Filtered := True;

  tblRechnungstyp.Filtered := False;
  tblRechnungstyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblRechnungstyp.Filtered := True;

  tblLeadquellentyp.Filtered := False;
  tblLeadquellentyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblLeadquellentyp.Filtered := True;

  // Kompetenztypen (Faehigkeiten/Nachweise fuer Lehrer und Kursteilnehmer,
  // siehe kurs_kompetenz und person_kompetenz). gueltigkeit_monate deckt ab,
  // dass viele Nachweise ablaufen.
  tblKompetenztyp.Filtered := False;
  tblKompetenztyp.Filter := Format('mandant_id=%d', [FMandantId]);
  tblKompetenztyp.Filtered := True;

  // Artikelkategorien. bereich trennt sie von spaeteren Kategorien fuer
  // andere Bereiche, die in derselben Tabelle liegen duerfen.
  tblKategorie.Filtered := False;
  tblKategorie.Filter := Format('mandant_id=%d and bereich=''ARTIKEL''',
                                [FMandantId]);
  tblKategorie.Filtered := True;
  tblKategorie.IndexFieldNames := 'sortierung;bezeichnung';

  if not Assigned(frmEinstellungen) then
    frmEinstellungen := TfrmEinstellungen.Create(Application);
  frmEinstellungen.Show;
end;


procedure TdmEinstellungen.tblKategorieNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  DataSet.FieldByName('bereich').AsString := 'ARTIKEL';
  DataSet.FieldByName('aktiv').AsBoolean := True;
  DataSet.FieldByName('sortierung').AsInteger := 0;
end;

// Welche Funktion, welches Schluesselfeld, welche Felder und ob mit
// Mandant - je Reiter eine Zeile. Die Reihenfolge der Felder ist die
// Reihenfolge der Parameter in der Datenbankfunktion.
procedure TdmEinstellungen.ReiterInfo(AHeaderIndex: Integer;
  out AFunktion, ATabelle, AIdFeld, AFelder: string; out AMitMandant: Boolean);
begin
  AFunktion := ''; ATabelle := ''; AIdFeld := ''; AFelder := '';
  AMitMandant := True;
  case AHeaderIndex of
    0: begin
         AFunktion := 'fn_person_typ_speichern'; ATabelle := 'person_typ';
         AIdFeld := 'typ_id'; AFelder := 'bezeichnung';
         // person_typ gilt poolweit, nicht je Mandant.
         AMitMandant := False;
       end;
    1: begin
         AFunktion := 'fn_rolle_typ_speichern'; ATabelle := 'rolle_typ';
         AIdFeld := 'rolle_id'; AFelder := 'rollen_bezeichnung';
       end;
    2: begin
         AFunktion := 'fn_adressentyp_speichern'; ATabelle := 'adressentyp';
         AIdFeld := 'adressentyp_id'; AFelder := 'bezeichnung';
       end;
    3: begin
         AFunktion := 'fn_emailtyp_speichern'; ATabelle := 'emailtyp';
         AIdFeld := 'emailtyp_id'; AFelder := 'bezeichnung';
       end;
    4: begin
         AFunktion := 'fn_telefonnummertyp_speichern';
         ATabelle := 'telefonnummertyp';
         AIdFeld := 'telefonnummertyp_id'; AFelder := 'bezeichnung';
       end;
    5: begin
         AFunktion := 'fn_rechnungstyp_speichern'; ATabelle := 'rechnungstyp';
         AIdFeld := 'rechnungstyp_id';
         AFelder := 'bezeichnung;reihenfolge;richtung;aktiv;' +
                    'erloes_konto_id;aufwand_konto_id';
       end;
    6: begin
         AFunktion := 'fn_leadquelle_typ_speichern';
         ATabelle := 'leadquelle_typ';
         AIdFeld := 'leadquelle_id'; AFelder := 'bezeichnung';
       end;
    7: begin
         AFunktion := 'fn_kompetenz_typ_speichern';
         ATabelle := 'kompetenz_typ';
         AIdFeld := 'kompetenz_id';
         AFelder := 'bezeichnung;beschreibung;gueltigkeit_monate;quelle;aktiv';
       end;
    8: begin
         AFunktion := 'fn_kategorie_speichern'; ATabelle := 'kategorie';
         AIdFeld := 'kategorie_id';
         AFelder := 'bezeichnung;beschreibung;sortierung;aktiv';
       end;
  end;
end;

// Die Loeschfunktion heisst wie die Tabelle: fn_<tabelle>_loeschen. Ob der
// Eintrag noch verwendet wird, entscheidet die Datenbank ueber ihre
// Fremdschluessel - hier wird nur die Meldung durchgereicht.
function TdmEinstellungen.TypLoeschen(AHeaderIndex: Integer): string;
var
  LDs: TDataSource;
  LFunktion, LTabelle, LIdFeld, LFelder: string;
  LMitMandant: Boolean;
  LId: Integer;
  LZentral: TdmZentraleDaten;
begin
  Result := EmptyStr;
  ReiterInfo(AHeaderIndex, LFunktion, LTabelle, LIdFeld, LFelder, LMitMandant);
  if LTabelle = '' then
    Exit('F' + #252 + 'r diesen Reiter ist kein Loeschweg hinterlegt.');

  LDs := DataSourceFuerTab(AHeaderIndex);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active or
     LDs.DataSet.IsEmpty then
    Exit('Kein Eintrag gew' + #228 + 'hlt.');

  // Eine angefangene Eingabe ist noch nirgends - die wird nur verworfen.
  if LDs.DataSet.State in dsEditModes then
  begin
    LDs.DataSet.Cancel;
    Exit;
  end;

  LId := LDs.DataSet.FieldByName(LIdFeld).AsInteger;
  if LId = 0 then
    Exit;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    LZentral.SpAufrufen('fn_' + LTabelle + '_loeschen', [LId]);
    LZentral.TabelleAuffrischen(LTabelle);
    TabellenLaden;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmEinstellungen.TypBezeichnung(AHeaderIndex: Integer): string;
var
  LDs: TDataSource;
  LFunktion, LTabelle, LIdFeld, LFelder: string;
  LMitMandant: Boolean;
  LFeld: TField;
begin
  Result := EmptyStr;
  ReiterInfo(AHeaderIndex, LFunktion, LTabelle, LIdFeld, LFelder, LMitMandant);
  LDs := DataSourceFuerTab(AHeaderIndex);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active or
     LDs.DataSet.IsEmpty or (LFelder = '') then
    Exit;
  // Das erste Feld der Liste ist immer die Bezeichnung.
  LFeld := LDs.DataSet.FindField(LFelder.Split([';'])[0]);
  if Assigned(LFeld) then
    Result := LFeld.AsString;
end;

function TdmEinstellungen.IstWebsiteTab(AHeaderIndex: Integer): Boolean;
begin
  Result := AHeaderIndex = 9;
end;

function TdmEinstellungen.WebWert(const ASchluessel: string): string;
begin
  Result := '';
  if not memWebEinstellung.Active then
    Exit;
  // Locate statt eigener Abfrage: die Kopie liegt vollstaendig im Speicher.
  if memWebEinstellung.Locate('mandant_id;schluessel',
       VarArrayOf([FMandantId, ASchluessel]), []) then
    Result := memWebEinstellung.FieldByName('wert').AsString;
end;

function TdmEinstellungen.WebWertSetzen(const ASchluessel,
  AWert: string): string;
var
  LZentral: TdmZentraleDaten;
begin
  Result := EmptyStr;
  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    LZentral.SpAufrufen('fn_mandant_einstellung_setzen',
      [FMandantId, ASchluessel, AWert, Null]);
    LZentral.TabelleAuffrischen('mandant_einstellung');
    TabellenLaden;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmEinstellungen.TabelleFuerTab(AHeaderIndex: Integer): string;
var
  LF, LId, LFelder: string;
  LMit: Boolean;
begin
  ReiterInfo(AHeaderIndex, LF, Result, LId, LFelder, LMit);
end;

// Der Kern des Fensters: die eingegebene Zeile geht an die Funktion der
// Datenbank, nicht in die Speichertabelle. Die ist eine Kopie aus dem
// zentralen Datenmodul und kaeme nie in der Datenbank an - genau daran
// haben die Typ-Reiter bis hierher stillschweigend gescheitert.
function TdmEinstellungen.TypSpeichern(AHeaderIndex: Integer): string;
var
  LDs: TDataSource;
  LMenge: TDataSet;
  LFunktion, LTabelle, LIdFeld, LFelder: string;
  LMitMandant: Boolean;
  LNamen: TArray<string>;
  LWerte: array of Variant;
  LFeld: TField;
  I, LVersatz, LId: Integer;
  LZentral: TdmZentraleDaten;
begin
  Result := EmptyStr;
  ReiterInfo(AHeaderIndex, LFunktion, LTabelle, LIdFeld, LFelder, LMitMandant);
  if LFunktion = '' then
    Exit('F' + #252 + 'r diesen Reiter ist kein Speicherweg hinterlegt.');

  LDs := DataSourceFuerTab(AHeaderIndex);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit('Die Tabelle ist nicht geladen.');
  LMenge := LDs.DataSet;
  if LMenge.IsEmpty and not (LMenge.State in dsEditModes) then
    Exit('Kein Eintrag gew' + #228 + 'hlt.');

  LNamen := LFelder.Split([';']);
  LVersatz := 1;
  if LMitMandant then
    Inc(LVersatz);
  SetLength(LWerte, Length(LNamen) + LVersatz);

  // Werte einsammeln, solange der Satz noch offen ist.
  LId := LMenge.FieldByName(LIdFeld).AsInteger;
  LWerte[0] := LId;
  if LMitMandant then
    LWerte[1] := FMandantId;
  for I := 0 to High(LNamen) do
  begin
    LFeld := LMenge.FindField(LNamen[I]);
    if (LFeld = nil) or LFeld.IsNull then
      LWerte[I + LVersatz] := Null
    else
      LWerte[I + LVersatz] := LFeld.Value;
  end;

  // Die Eingabe in der Kopie verwerfen: geschrieben wird gleich ueber die
  // Funktion, und danach wird die Kopie ohnehin neu geholt.
  if LMenge.State in dsEditModes then
    LMenge.Cancel;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    LId := AlsZahl(LZentral.SpAufrufen(LFunktion, LWerte));
    LZentral.TabelleAuffrischen(LTabelle);
    TabellenLaden;
    LMenge.Locate(LIdFeld, LId, []);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

procedure TdmEinstellungen.TabellenLaden;
begin
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(tblAdressentyp, 'adressentyp'),
    Zuordnung(tblEmailtyp, 'emailtyp'),
    Zuordnung(tblKompetenztyp, 'kompetenz_typ'),
    Zuordnung(tblLeadquellentyp, 'leadquelle_typ'),
    Zuordnung(tblPersonentyp, 'person_typ'),
    Zuordnung(tblRechnungstyp, 'rechnungstyp'),
    Zuordnung(tblRollentyp, 'rolle_typ'),
    Zuordnung(tblTelefonnummertyp, 'telefonnummertyp'),
    Zuordnung(tblKategorie, 'kategorie'),
    Zuordnung(memWebEinstellung, 'mandant_einstellung')]);
end;



initialization
  GSperreEinstellungen := TCriticalSection.Create;

finalization
  GSperreEinstellungen.Free;

end.
