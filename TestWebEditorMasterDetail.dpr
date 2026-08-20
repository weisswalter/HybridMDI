program TestWebEditorMasterDetail;
{$APPTYPE CONSOLE}
// Zweiter Zeuge fuer denselben Fehler: der WebEditor haengt mit einer
// dreistufigen Kette an ModulFuellen (Seite -> Karten -> Kartentexte).
// Filtert ModulFuellen die Quelltabelle vor dem Kopieren auf den Master,
// enthaelt die Kopie nur die Karten EINER Seite -- beim Wechsel auf die
// naechste Seite bleibt die Kartenliste leer.
//
// Ohne Formular: AlleOeffnen reicht, die Kopplung sitzt in TabellenEinrichten.
uses
  System.SysUtils, System.Classes, System.StrUtils,
  Data.DB, Vcl.Forms,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  ZentraleDatenDm, MandantDm, WebEditorDm;

var
  LDm: TdmWebEditor;
  LFunk: TFDQuery;
  LFehler: Integer = 0;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
begin
  Writeln(Format('%-52s %-5s %s', [ATitel, BoolToStr(AGut, True), AText]));
  if not AGut then
    Inc(LFehler);
end;

function Zaehle(const ASql: string): Integer;
begin
  LFunk.Close;
  LFunk.SQL.Text := ASql;
  LFunk.Open;
  Result := LFunk.Fields[0].AsInteger;
end;

// Eine Seite anwaehlen und pruefen, dass die Karten dazu passen.
procedure SeitePruefen(ASeite: Integer);
var
  LSoll: Integer;
begin
  if not LDm.tblNavbar.Locate('navbarweb_id', ASeite, []) then
  begin
    Sag(Format('Seite %d anwaehlen', [ASeite]), False, 'nicht gefunden');
    Exit;
  end;
  // Die Karten der Seite in der eingestellten Sprache -- v_content_editor
  // fuehrt jede Karte je Sprache einmal, tblContent filtert auf sprache_id.
  LSoll := Zaehle(Format(
    'SELECT count(*) FROM v_content_editor WHERE navbarweb_id=%d AND sprache_id=%d',
    [ASeite, LDm.SpracheId]));
  Sag(Format('Seite %d: Karten %d (soll %d)',
             [ASeite, LDm.tblContent.RecordCount, LSoll]),
      LDm.tblContent.RecordCount = LSoll);
end;

var
  LSeiten: TArray<Integer>;
  LSeite, I, LDurchgang: Integer;
begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;

    LFunk := TFDQuery.Create(nil);
    try
      LFunk.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
      TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;
      TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 1;

      LDm := TdmWebEditor(TdmWebEditor.GetInstance);
      LDm.AlleOeffnen;

      // Die vier Seiten mit den meisten Karten -- unterschiedlich viele,
      // damit ein haengengebliebener Filter sofort auffaellt.
      LFunk.Close;
      LFunk.SQL.Text :=
        'SELECT n.navbarweb_id FROM navbarweb n ' +
        'JOIN contentweb c ON c.navbarweb_id = n.navbarweb_id ' +
        'GROUP BY 1 ORDER BY count(*) DESC LIMIT 4';
      LFunk.Open;
      SetLength(LSeiten, 0);
      while not LFunk.Eof do
      begin
        SetLength(LSeiten, Length(LSeiten) + 1);
        LSeiten[High(LSeiten)] := LFunk.Fields[0].AsInteger;
        LFunk.Next;
      end;

      // Zweimal durch: beim zweiten Durchgang wuerde ein Filter auffallen,
      // der sich beim ersten Wechsel festgesetzt hat.
      for LDurchgang := 1 to 2 do
      begin
        Writeln(Format('--- Durchgang %d ------------------------------', [LDurchgang]));
        for I := 0 to High(LSeiten) do
          SeitePruefen(LSeiten[I]);
      end;

      // Und einmal quer: Kartentexte muessen der gewaehlten Karte folgen.
      LSeite := LSeiten[0];
      LDm.tblNavbar.Locate('navbarweb_id', LSeite, []);
      LDm.tblContent.First;
      if not LDm.tblContent.IsEmpty then
      begin
        Sag('Kartentexte folgen der ersten Karte',
            LDm.tblContentText.RecordCount = Zaehle(Format(
              'SELECT count(*) FROM contentweb_text WHERE contentweb_id=%d ' +
              'AND sprache_id=%d',
              [LDm.tblContent.FieldByName('contentweb_id').AsInteger,
               LDm.SpracheId])));
        LDm.tblContent.Next;
        if not LDm.tblContent.Eof then
          Sag('Kartentexte folgen der zweiten Karte',
              LDm.tblContentText.RecordCount = Zaehle(Format(
                'SELECT count(*) FROM contentweb_text WHERE contentweb_id=%d ' +
                'AND sprache_id=%d',
                [LDm.tblContent.FieldByName('contentweb_id').AsInteger,
                 LDm.SpracheId])));
      end;

      Writeln;
      if LFehler = 0 then
        Writeln('Alles in Ordnung.')
      else
        Writeln(LFehler, ' Pruefung(en) fehlgeschlagen.');
    finally
      LFunk.Free;
    end;
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
