unit LagerEntnahmeDm;

// Modul 3: Lehrer reserviert oder entnimmt Artikel aus dem Lager.
// Strukturell wie KundenBestellungDm/LieferantenBestellungDm (siehe dort fuer
// die allgemeinen Konventionen) -- vorgangsart ist HIER FEST 'Entnahme' (vom
// Modul vorgegeben). Gegenpartei (person_id) ist der Lehrer -- ermittelt ueber
// person_beziehung.ist_lehrer gegen die Hauptperson des aktuellen Mandanten.
// Zusaetzlich zu den anderen beiden Modulen: Positionen koennen als
// "Rueckgabe erwartet" markiert werden (Artikel wird nach Benutzung wieder
// zurueckgestellt, z.B. Werkzeug/Kursmaterial) -- MarkiereRueckgabe setzt
// beleg_position.rueckgegeben_am, sobald der Artikel tatsaechlich
// zurueckkommt.

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

const
  cVorgangsart = 'Entnahme';
  cStandardRechnungstyp = 'Entnahme';

type
  TdmLagerEntnahme = class(TdmModuleTemplate)
    tblBeleg: TFDTable;
    tblBelegPosition: TFDTable;
    dstblBeleg: TDataSource;
    dstblBelegPosition: TDataSource;
    qryPersonAuswahl: TFDQuery;
    dsPersonAuswahl: TDataSource;
    qryRechnungstypAuswahl: TFDQuery;
    dsRechnungstypAuswahl: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure tblBelegNewRecord(DataSet: TDataSet);
    procedure tblBelegPositionNewRecord(DataSet: TDataSet);
  private
    FMandantId: Integer;
    function StandardRechnungstypId: Integer;
  public
    class function GetInstance: TObject;
    procedure OpenLagerEntnahme;
    function HauptpersonVorhanden: Boolean;
    procedure LadeArtikelAuswahl(AItems: TStrings);
    procedure LadeLeistungAuswahl(AItems: TStrings);
    procedure AddPosition(AArtikelId, ALeistungId: Integer;
      AMenge, AEinzelpreis: Double; ARueckgabeErwartet: Boolean = False);
    // Verbucht die tatsaechliche Rueckgabe der aktuellen beleg_position-Zeile
    // (rueckgabe_erwartet=true, rueckgegeben_am noch leer).
    procedure MarkiereRueckgabe;
  end;

var
  dmLagerEntnahme: TdmLagerEntnahme;

implementation

{$R *.dfm}

uses
  Vcl.Forms, Vcl.Dialogs,
  PGManagerDm,
  MandantDm,
  LagerEntnahmeFrm;

class function TdmLagerEntnahme.GetInstance: TObject;
begin
  Result := dmLagerEntnahme;
end;

procedure TdmLagerEntnahme.DataModuleCreate(Sender: TObject);
begin
  tblBeleg.Connection         := PGManagerDm.dmPGManager.FDConnection1;
  tblBelegPosition.Connection := PGManagerDm.dmPGManager.FDConnection1;
  qryPersonAuswahl.Connection := PGManagerDm.dmPGManager.FDConnection1;
  qryRechnungstypAuswahl.Connection := PGManagerDm.dmPGManager.FDConnection1;

  tblBeleg.UpdateOptions.AutoIncFields         := 'beleg_id';
  tblBelegPosition.UpdateOptions.AutoIncFields := 'position_id';

  tblBelegPosition.MasterSource    := dstblBeleg;
  tblBelegPosition.MasterFields    := 'beleg_id';
  tblBelegPosition.IndexFieldNames := 'beleg_id';

  qryPersonAuswahl.SQL.Text :=
    'SELECT p.person_id, p.nachname_firmenname ' +
    'FROM person_beziehung pb ' +
    'JOIN person p ON p.person_id = pb.quell_person_id ' +
    'WHERE pb.mandant_id = :m ' +
    '  AND pb.ist_lehrer = true ' +
    '  AND pb.ziel_person_id = (SELECT pm.person_id FROM person_mandant pm ' +
    '                            WHERE pm.mandant_id = :m AND pm.ist_hauptperson = true) ' +
    'ORDER BY p.nachname_firmenname';

  qryRechnungstypAuswahl.SQL.Text :=
    'SELECT rechnungstyp_id, bezeichnung FROM rechnungstyp ' +
    'WHERE mandant_id = :m AND aktiv = true ' +
    'ORDER BY reihenfolge NULLS LAST, bezeichnung';
end;

function TdmLagerEntnahme.HauptpersonVorhanden: Boolean;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT 1 FROM person_mandant WHERE mandant_id = :m AND ist_hauptperson = true';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    Result := not LQry.IsEmpty;
  finally
    LQry.Free;
  end;
end;

function TdmLagerEntnahme.StandardRechnungstypId: Integer;
var
  LQry: TFDQuery;
begin
  Result := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT rechnungstyp_id FROM rechnungstyp WHERE mandant_id = :m AND bezeichnung = :b';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.ParamByName('b').AsString := cStandardRechnungstyp;
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.FieldByName('rechnungstyp_id').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TdmLagerEntnahme.tblBelegNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('mandant_id').AsInteger  := FMandantId;
  DataSet.FieldByName('vorgangsart').AsString  := cVorgangsart;
  DataSet.FieldByName('beleg_datum').AsDateTime := Date;
  DataSet.FieldByName('status').AsString       := 'offen';
  DataSet.FieldByName('rechnungstyp_id').AsInteger := StandardRechnungstypId;
end;

procedure TdmLagerEntnahme.tblBelegPositionNewRecord(DataSet: TDataSet);
var
  LQry: TFDQuery;
begin
  DataSet.FieldByName('mandant_id').AsInteger := FMandantId;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT COALESCE(MAX(position_nr),0)+1 AS next_nr FROM beleg_position WHERE beleg_id = :b';
    LQry.ParamByName('b').AsInteger := tblBeleg.FieldByName('beleg_id').AsInteger;
    LQry.Open;
    DataSet.FieldByName('position_nr').AsInteger := LQry.FieldByName('next_nr').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TdmLagerEntnahme.LadeArtikelAuswahl(AItems: TStrings);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT artikel_id, artikelname FROM artikel WHERE mandant_id = :m ORDER BY artikelname';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    AItems.BeginUpdate;
    try
      AItems.Clear;
      while not LQry.Eof do
      begin
        AItems.AddObject(LQry.FieldByName('artikelname').AsString,
          TObject(NativeInt(LQry.FieldByName('artikel_id').AsInteger)));
        LQry.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmLagerEntnahme.LadeLeistungAuswahl(AItems: TStrings);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := PGManagerDm.dmPGManager.FDConnection1;
    LQry.SQL.Text := 'SELECT leistung_id, bezeichnung FROM leistung WHERE mandant_id = :m ORDER BY bezeichnung';
    LQry.ParamByName('m').AsInteger := FMandantId;
    LQry.Open;
    AItems.BeginUpdate;
    try
      AItems.Clear;
      while not LQry.Eof do
      begin
        AItems.AddObject(LQry.FieldByName('bezeichnung').AsString,
          TObject(NativeInt(LQry.FieldByName('leistung_id').AsInteger)));
        LQry.Next;
      end;
    finally
      AItems.EndUpdate;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TdmLagerEntnahme.AddPosition(AArtikelId, ALeistungId: Integer;
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

procedure TdmLagerEntnahme.MarkiereRueckgabe;
begin
  if tblBelegPosition.IsEmpty then
    Exit;
  if not tblBelegPosition.FieldByName('rueckgabe_erwartet').AsBoolean then
  begin
    ShowMessage('F'#252'r diese Position ist keine R'#252'ckgabe erwartet.', '');
    Exit;
  end;
  if not tblBelegPosition.FieldByName('rueckgegeben_am').IsNull then
  begin
    ShowMessage('Diese Position wurde bereits als zur'#252'ckgegeben verbucht.', '');
    Exit;
  end;
  tblBelegPosition.Edit;
  tblBelegPosition.FieldByName('rueckgegeben_am').AsDateTime := Now;
  tblBelegPosition.Post;
end;

procedure TdmLagerEntnahme.OpenLagerEntnahme;
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

  qryPersonAuswahl.Close;
  qryPersonAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryPersonAuswahl.Open;

  qryRechnungstypAuswahl.Close;
  qryRechnungstypAuswahl.ParamByName('m').AsInteger := FMandantId;
  qryRechnungstypAuswahl.Open;

  tblBeleg.Filtered := False;
  tblBeleg.Open;
  tblBeleg.Filter := Format('mandant_id=%d AND vorgangsart=''%s''', [FMandantId, cVorgangsart]);
  tblBeleg.Filtered := True;
  tblBeleg.IndexFieldNames := 'beleg_id';

  tblBelegPosition.Open;

  if not Assigned(frmLagerEntnahme) then
    frmLagerEntnahme := TfrmLagerEntnahme.Create(Application);
  frmLagerEntnahme.Show;
end;

end.
