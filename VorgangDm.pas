unit VorgangDm;

// Vorgang als Ticket.
//
// Geschrieben wird ausschliesslich ueber Datenbankfunktionen:
// fn_vorgang_anlegen, fn_vorgang_speichern, fn_vorgang_weiter,
// fn_vorgang_nachfolger. Gelesen wird aus Kopien der zentralen Tabellen;
// Typ- und Zustandsname haengen als Lookup an tblVorgang, damit die Liste
// ohne Abfrage lesbare Spalten hat.
//
// Die Regeln sitzen in der Datenbank, nicht hier - dieses Modul zeigt sie nur:
//   * die Ticketnummer kommt aus dem Nummernkreis (fn_nummer_ziehen),
//   * erlaubt ist nur, was in vorgang_uebergang steht, je Vorgangstyp,
//   * ein abgeschlossener Vorgang wird nicht wieder geoeffnet - statt dessen
//     ein neuer Vorgang, der auf den alten verweist.
// Siehe sql/vorgang_ticket.sql.

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
  TdmVorgang = class(TdmModuleTemplate)
    tblVorgang: TFDMemTable;
    dstblVorgang: TDataSource;
    // Kopien der Stammtabellen. memZustand und memTyp muessen vor
    // tblVorgang gefuellt sein - ein Lookup oeffnet beim Auswerten seine
    // Quelle (siehe TabellenLaden).
    memTyp: TFDMemTable;
    memZustand: TFDMemTable;
    memUebergang: TFDMemTable;
    tblVerlauf: TFDMemTable;
    dstblVerlauf: TDataSource;
    memVorgangVorgang: TFDMemTable;
    // Im Speicher aufgebaut: die verknuepften Vorgaenge mit Nummer und
    // Bezeichnung. Kommt aus memVorgangVorgang plus tblVorgang.
    tblVerknuepft: TFDMemTable;
    dstblVerknuepft: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblVorgangAfterScroll(DataSet: TDataSet);
  private
    FMandantId: Integer;
    // VerknuepfteFuellen schlaegt in tblVorgang nach. Das bewegt den
    // Satzzeiger und feuert AfterScroll erneut - ohne diese Sperre laeuft
    // sich das Modul beim Oeffnen im Kreis, bis der Stapel voll ist.
    FImNachladen: Boolean;
    procedure TabellenLaden;
    procedure StrukturVerknuepft;
  public
    class function GetInstance: TObject;
    // Einstieg fuer OpenGui('Vorgang') ueber den MessageHandler.
    procedure OpenVorgang;

    procedure TypenFuellen(AItems: TStrings);
    // Die von hier aus erreichbaren Zustaende des aktuellen Vorgangs -
    // gelesen aus memUebergang, nicht geraten.
    procedure SchritteFuellen(AItems: TStrings);

    function AktuelleId: Integer;
    function IstAbgeschlossen: Boolean;

    function Anlegen(ATypId: Integer; const ABezeichnung: string;
      out ANeueId: Integer): string;
    function Speichern(const ABezeichnung, ABeschreibung: string;
      AFaellig: TDateTime): string;
    function Weiter(AZustandId: Integer; const ABemerkung: string): string;
    function Nachfolger(const ABezeichnung: string;
      out ANeueId: Integer): string;

    procedure VerlaufFuellen;
    procedure VerknuepfteFuellen;
  end;

var
  dmVorgang: TdmVorgang;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm,
  Vcl.Dialogs,
  MandantDm,
  VorgangFrm, System.SyncObjs;

var
  GSperreVorgang: TCriticalSection;

class function TdmVorgang.GetInstance: TObject;
begin
  // Doppelte Pruefung wie in den anderen Modulen: der Assigned-Test allein
  // ist nicht threadsicher.
  if not Assigned(dmVorgang) then
  begin
    GSperreVorgang.Enter;
    try
      if not Assigned(dmVorgang) then
        Application.CreateForm(TdmVorgang, dmVorgang);
    finally
      GSperreVorgang.Leave;
    end;
  end;
  Result := dmVorgang;
end;

procedure TdmVorgang.DataModuleCreate(Sender: TObject);
begin
  tblVorgang.AfterScroll := tblVorgangAfterScroll;
end;

procedure TdmVorgang.TabellenLaden;
begin
  // Reihenfolge ist bindend: ein Lookup-Feld oeffnet beim Auswerten seine
  // Quelltabelle. memTyp und memZustand haengen an tblVorgang, memZustand
  // ausserdem an tblVerlauf.
  TdmZentraleDaten(TdmZentraleDaten.GetInstance).ModulFuellen([
    Zuordnung(memTyp, 'vorgang_typ'),
    Zuordnung(memZustand, 'vorgang_zustand'),
    Zuordnung(memUebergang, 'vorgang_uebergang'),
    Zuordnung(tblVorgang, 'vorgang'),
    Zuordnung(tblVerlauf, 'vorgang_verlauf'),
    Zuordnung(memVorgangVorgang, 'vorgang_vorgang')]);
end;

procedure TdmVorgang.StrukturVerknuepft;
begin
  if tblVerknuepft.Active then
    Exit;
  tblVerknuepft.FieldDefs.Clear;
  tblVerknuepft.FieldDefs.Add('vorgang_id', ftInteger);
  tblVerknuepft.FieldDefs.Add('richtung', ftString, 20);
  tblVerknuepft.FieldDefs.Add('bezug', ftString, 20);
  tblVerknuepft.FieldDefs.Add('vorgang_nr', ftString, 50);
  tblVerknuepft.FieldDefs.Add('bezeichnung', ftString, 200);
  tblVerknuepft.CreateDataSet;
end;

procedure TdmVorgang.OpenVorgang;
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

  TabellenLaden;
  StrukturVerknuepft;

  // Formular zuerst erzeugen: der Filter unten bewegt den Satzzeiger, das
  // feuert tblVorgangAfterScroll, und das fuellt Anzeigen des Formulars.
  if not Assigned(frmVorgang) then
    frmVorgang := TfrmVorgang.Create(Application);

  memTyp.Filter := 'mandant_id = ' + IntToStr(FMandantId) + ' and aktiv = 1';
  memTyp.Filtered := True;
  memZustand.Filter := 'mandant_id = ' + IntToStr(FMandantId);
  memZustand.Filtered := True;

  tblVorgang.Filter := 'mandant_id = ' + IntToStr(FMandantId);
  tblVorgang.Filtered := True;
  tblVorgang.IndexFieldNames := 'vorgang_nr';

  tblVorgangAfterScroll(tblVorgang);   // feuert beim Filtern nicht zuverlaessig
  frmVorgang.Show;
end;

procedure TdmVorgang.tblVorgangAfterScroll(DataSet: TDataSet);
begin
  if FImNachladen then
    Exit;
  FImNachladen := True;
  try
    VerlaufFuellen;
    VerknuepfteFuellen;
    if Assigned(frmVorgang) then
      frmVorgang.SatzAnzeigen;
  finally
    FImNachladen := False;
  end;
end;

function TdmVorgang.AktuelleId: Integer;
begin
  if tblVorgang.Active and not tblVorgang.IsEmpty then
    Result := tblVorgang.FieldByName('vorgang_id').AsInteger
  else
    Result := 0;
end;

function TdmVorgang.IstAbgeschlossen: Boolean;
begin
  Result := False;
  if AktuelleId = 0 then
    Exit;
  if memZustand.Active and
     memZustand.Locate('zustand_id',
       tblVorgang.FieldByName('zustand_id').AsInteger, []) then
    Result := memZustand.FieldByName('ist_abschluss').AsBoolean;
end;

procedure TdmVorgang.TypenFuellen(AItems: TStrings);
var
  LMerker: TBookmark;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    if not memTyp.Active then
      Exit;
    LMerker := memTyp.GetBookmark;
    try
      memTyp.First;
      while not memTyp.Eof do
      begin
        AItems.AddObject(memTyp.FieldByName('bezeichnung').AsString,
          TObject(NativeInt(memTyp.FieldByName('typ_id').AsInteger)));
        memTyp.Next;
      end;
    finally
      if memTyp.BookmarkValid(LMerker) then
        memTyp.GotoBookmark(LMerker);
      memTyp.FreeBookmark(LMerker);
    end;
  finally
    AItems.EndUpdate;
  end;
end;

procedure TdmVorgang.SchritteFuellen(AItems: TStrings);
var
  LTyp, LZustand, LZiel: Integer;
  LMerkerU, LMerkerZ: TBookmark;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    if (AktuelleId = 0) or not (memUebergang.Active and memZustand.Active) then
      Exit;

    LTyp     := tblVorgang.FieldByName('typ_id').AsInteger;
    LZustand := tblVorgang.FieldByName('zustand_id').AsInteger;

    LMerkerU := memUebergang.GetBookmark;
    LMerkerZ := memZustand.GetBookmark;
    try
      memUebergang.First;
      while not memUebergang.Eof do
      begin
        if (memUebergang.FieldByName('typ_id').AsInteger = LTyp) and
           (memUebergang.FieldByName('von_zustand_id').AsInteger = LZustand) then
        begin
          LZiel := memUebergang.FieldByName('nach_zustand_id').AsInteger;
          if memZustand.Locate('zustand_id', LZiel, []) then
            AItems.AddObject(memZustand.FieldByName('bezeichnung').AsString,
              TObject(NativeInt(LZiel)));
        end;
        memUebergang.Next;
      end;
    finally
      if memZustand.BookmarkValid(LMerkerZ) then
        memZustand.GotoBookmark(LMerkerZ);
      memZustand.FreeBookmark(LMerkerZ);
      if memUebergang.BookmarkValid(LMerkerU) then
        memUebergang.GotoBookmark(LMerkerU);
      memUebergang.FreeBookmark(LMerkerU);
    end;
  finally
    AItems.EndUpdate;
  end;
end;

procedure TdmVorgang.VerlaufFuellen;
begin
  if not tblVerlauf.Active then
    Exit;
  // Nur der Verlauf des aktuellen Vorgangs. Filtern statt nachladen: die
  // Kopie liegt ohnehin vollstaendig im Speicher.
  tblVerlauf.Filtered := False;
  tblVerlauf.Filter := 'vorgang_id = ' + IntToStr(AktuelleId);
  tblVerlauf.Filtered := True;
  tblVerlauf.IndexFieldNames := 'zeitpunkt';
end;

procedure TdmVorgang.VerknuepfteFuellen;
var
  LId, LAnderer: Integer;
  LRichtung: string;
  LMerker: TBookmark;

  procedure Zeile(AId: Integer; const ARichtung, ABezug: string);
  begin
    // Nummer und Bezeichnung des anderen Vorgangs stehen in derselben
    // Kopie - kein zweiter Griff zur Datenbank.
    if not tblVorgang.Active then
      Exit;
    tblVerknuepft.Append;
    tblVerknuepft.FieldByName('vorgang_id').AsInteger := AId;
    tblVerknuepft.FieldByName('richtung').AsString := ARichtung;
    tblVerknuepft.FieldByName('bezug').AsString := ABezug;
    if tblVorgang.Locate('vorgang_id', AId, []) then
    begin
      tblVerknuepft.FieldByName('vorgang_nr').AsString :=
        tblVorgang.FieldByName('vorgang_nr').AsString;
      tblVerknuepft.FieldByName('bezeichnung').AsString :=
        tblVorgang.FieldByName('bezeichnung').AsString;
    end;
    tblVerknuepft.Post;
  end;

begin
  StrukturVerknuepft;
  tblVerknuepft.DisableControls;
  try
    tblVerknuepft.EmptyDataSet;
    LId := AktuelleId;
    if (LId = 0) or not memVorgangVorgang.Active then
      Exit;

    // Der Satzzeiger von tblVorgang wird beim Nachschlagen bewegt und muss
    // danach wieder stehen, wo er war - sonst springt die Liste.
    LMerker := tblVorgang.GetBookmark;
    try
      memVorgangVorgang.First;
      while not memVorgangVorgang.Eof do
      begin
        LAnderer := 0;
        LRichtung := '';
        if memVorgangVorgang.FieldByName('von_id').AsInteger = LId then
        begin
          LAnderer := memVorgangVorgang.FieldByName('nach_id').AsInteger;
          LRichtung := 'Nachfolger';
        end
        else if memVorgangVorgang.FieldByName('nach_id').AsInteger = LId then
        begin
          LAnderer := memVorgangVorgang.FieldByName('von_id').AsInteger;
          LRichtung := 'Vorgaenger';
        end;
        if LAnderer > 0 then
          Zeile(LAnderer, LRichtung,
                memVorgangVorgang.FieldByName('bezug').AsString);
        memVorgangVorgang.Next;
      end;
    finally
      if tblVorgang.BookmarkValid(LMerker) then
        tblVorgang.GotoBookmark(LMerker);
      tblVorgang.FreeBookmark(LMerker);
    end;
    tblVerknuepft.First;
  finally
    tblVerknuepft.EnableControls;
  end;
end;

// ---------------------------------------------------------------- Schreiben

function TdmVorgang.Anlegen(ATypId: Integer; const ABezeichnung: string;
  out ANeueId: Integer): string;
var
  LZentral: TdmZentraleDaten;
begin
  Result := EmptyStr;
  ANeueId := 0;
  if ATypId <= 0 then
    Exit('Bitte einen Vorgangstyp w' + #228 + 'hlen.');
  if Trim(ABezeichnung) = '' then
    Exit('Bitte eine Bezeichnung eingeben.');

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    ANeueId := AlsZahl(LZentral.SpAufrufen('fn_vorgang_anlegen',
      [FMandantId, ATypId, Trim(ABezeichnung)]));
    LZentral.TabelleAuffrischen('vorgang');
    LZentral.TabelleAuffrischen('vorgang_verlauf');
    LZentral.TabelleAuffrischen('nummernkreis');
    TabellenLaden;
    tblVorgang.Locate('vorgang_id', ANeueId, []);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmVorgang.Speichern(const ABezeichnung, ABeschreibung: string;
  AFaellig: TDateTime): string;
var
  LZentral: TdmZentraleDaten;
  LFaellig: Variant;
  LId: Integer;
begin
  Result := EmptyStr;
  LId := AktuelleId;
  if LId = 0 then
    Exit('Kein Vorgang gew' + #228 + 'hlt.');

  if AFaellig > 0 then
    LFaellig := AFaellig
  else
    LFaellig := Null;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    // Nummer, Typ und Zustand aendert die Funktion bewusst nicht; ist der
    // Vorgang abgeschlossen, laesst der Trigger den Schreibvorgang nicht zu.
    LZentral.SpAufrufen('fn_vorgang_speichern',
      [LId, Trim(ABezeichnung), ABeschreibung, Null, Null, LFaellig]);
    LZentral.TabelleAuffrischen('vorgang');
    TabellenLaden;
    tblVorgang.Locate('vorgang_id', LId, []);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmVorgang.Weiter(AZustandId: Integer;
  const ABemerkung: string): string;
var
  LZentral: TdmZentraleDaten;
  LId: Integer;
  LBemerkung: Variant;
begin
  Result := EmptyStr;
  LId := AktuelleId;
  if LId = 0 then
    Exit('Kein Vorgang gew' + #228 + 'hlt.');
  if AZustandId <= 0 then
    Exit('Bitte den n' + #228 + 'chsten Schritt w' + #228 + 'hlen.');

  if Trim(ABemerkung) = '' then
    LBemerkung := Null
  else
    LBemerkung := ABemerkung;

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    // Ob der Schritt erlaubt ist, entscheidet vorgang_uebergang in der
    // Datenbank - die Meldung von dort ist bereits fuer Menschen geschrieben.
    LZentral.SpAufrufen('fn_vorgang_weiter', [LId, AZustandId, Null, LBemerkung]);
    LZentral.TabelleAuffrischen('vorgang');
    LZentral.TabelleAuffrischen('vorgang_verlauf');
    TabellenLaden;
    tblVorgang.Locate('vorgang_id', LId, []);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TdmVorgang.Nachfolger(const ABezeichnung: string;
  out ANeueId: Integer): string;
var
  LZentral: TdmZentraleDaten;
  LAlt: Integer;
begin
  Result := EmptyStr;
  ANeueId := 0;
  LAlt := AktuelleId;
  if LAlt = 0 then
    Exit('Kein Vorgang gew' + #228 + 'hlt.');
  if Trim(ABezeichnung) = '' then
    Exit('Bitte eine Bezeichnung f' + #252 + 'r den neuen Vorgang eingeben.');

  LZentral := TdmZentraleDaten(TdmZentraleDaten.GetInstance);
  try
    ANeueId := AlsZahl(LZentral.SpAufrufen('fn_vorgang_nachfolger',
      [LAlt, Trim(ABezeichnung)]));
    LZentral.TabelleAuffrischen('vorgang');
    LZentral.TabelleAuffrischen('vorgang_verlauf');
    LZentral.TabelleAuffrischen('vorgang_vorgang');
    LZentral.TabelleAuffrischen('nummernkreis');
    TabellenLaden;
    tblVorgang.Locate('vorgang_id', ANeueId, []);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

initialization
  // Persistente Felder im DFM brauchen ihre Klassen im Klassenregister;
  // zur Laufzeit meldet sie sonst niemand an (siehe ArtikelStammDm).
  RegisterClasses([TIntegerField, TWideStringField, TWideMemoField,
                   TDateField, TSQLTimeStampField, TBooleanField]);
  GSperreVorgang := TCriticalSection.Create;

finalization
  GSperreVorgang.Free;

end.
