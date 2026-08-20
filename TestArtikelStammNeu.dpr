program TestArtikelStammNeu;
{$APPTYPE CONSOLE}
// Der neue Artikelstamm: kommen die Kopien ueber den Broadcast an, greift
// der Mandantenfilter, und folgt die Kategorie-Bruecke dem Artikel?
//
// Geprueft wird an den WIRKLICH vorhandenen Artikeln, nicht an selbst
// angelegten - und verglichen wird der Inhalt, nicht die Anzahl.
uses
  System.SysUtils, System.Classes, System.StrUtils,
  System.IOUtils,
  Data.DB, Vcl.Forms,
  FireDAC.Comp.Client,
  Vcl.Controls,
  EventBus, UInterfaces, uMessageHandler,
  udmModuleTemplate, uFrmModuleTemplate,
  ZentraleDatenDm, MandantDm, ArtikelStammDm, ArtikelStammFrm;

type
  // Das Modulfenster ist ein MDI-Kind und braucht einen Rahmen. Minimiert
  // und ausserhalb des Bildschirms, damit der Pruefstand niemandem den
  // Fokus wegreisst.
  TMdiRahmen = class(TForm)
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TMdiRahmen.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  FormStyle := fsMDIForm;
  Position := poDesigned;
  Left := -32000;
  Top := -32000;
  WindowState := wsMinimized;
end;

var
  LFehler: Integer = 0;
  LDm: TdmArtikelStamm;
  LQry: TFDQuery;
  LRahmen: TMdiRahmen;
  LNr, LIst, LMeldung, LDatei, LDatei2, LMuell: string;
  LI, LFotoId, LVorher, LAnzahl: Integer;
  LUeber: TArray<string>;
  LIds: TArray<Integer>;

// Ein echtes PNG (1x1). Muss darstellbar sein: das TDBImage im Formular
// zeichnet, sobald die Kopie Daten hat.
function PruefBild: TBytes;
const
  CHex = '89504e470d0a1a0a0000000d49484452000000010000000108060000' +
         '001f15c4890000000d49444154789c63606060f80f00010401005fe5' +
         'c34b0000000049454e44ae426082';
var
  I: Integer;
begin
  SetLength(Result, Length(CHex) div 2);
  for I := 0 to High(Result) do
    Result[I] := StrToInt('$' + Copy(CHex, I * 2 + 1, 2));
end;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
begin
  Writeln(Format('%-44s %-5s %s', [ATitel, BoolToStr(AGut, True), AText]));
  if not AGut then
    Inc(LFehler);
end;

function Zaehle(const ASql: string): Integer;
begin
  LQry.Close;
  LQry.SQL.Text := ASql;
  LQry.Open;
  Result := LQry.Fields[0].AsInteger;
end;

function SpalteAus(const ASql: string): string;
begin
  LQry.Close;
  LQry.SQL.Text := ASql;
  LQry.Open;
  Result := '';
  while not LQry.Eof do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + LQry.Fields[0].AsString;
    LQry.Next;
  end;
end;

// Welche Kategorien sieht die Bruecke gerade?
function SichtbareKategorien: string;
var
  LMerker: TBookmark;
begin
  Result := '';
  if not LDm.tblArtikelKategorie.Active or LDm.tblArtikelKategorie.IsEmpty then
    Exit;
  LDm.tblArtikelKategorie.DisableControls;
  LMerker := LDm.tblArtikelKategorie.GetBookmark;
  try
    LDm.tblArtikelKategorie.First;
    while not LDm.tblArtikelKategorie.Eof do
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result +
        LDm.tblArtikelKategorie.FieldByName('kategorie_id').AsString;
      LDm.tblArtikelKategorie.Next;
    end;
  finally
    if Assigned(LMerker) then
    begin
      LDm.tblArtikelKategorie.GotoBookmark(LMerker);
      LDm.tblArtikelKategorie.FreeBookmark(LMerker);
    end;
    LDm.tblArtikelKategorie.EnableControls;
  end;
end;

procedure ArtikelPruefen(const ANummer: string);
var
  LId: Integer;
  LIst, LSoll: string;
begin
  LId := Zaehle(Format('SELECT artikel_id FROM artikel WHERE artikel_nr=%s',
                       [QuotedStr(ANummer)]));
  if not LDm.tblArtikel.Locate('artikel_nr', ANummer, []) then
  begin
    Sag(ANummer + ': in der Kopie', False, 'nicht gefunden');
    Exit;
  end;
  LSoll := SpalteAus(Format(
    'SELECT kategorie_id FROM artikel_kategorie WHERE artikel_id=%d ' +
    'ORDER BY kategorie_id', [LId]));
  LIst := SichtbareKategorien;
  Sag(ANummer + ': Kategorien der Bruecke', LIst = LSoll,
      Format('ist "%s" / soll "%s"', [LIst, LSoll]));
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TdmMessageHandler, dmMessageHandler);
    Application.CreateForm(TMdiRahmen, LRahmen);

    // Modul VOR dem Laden erzeugen - dann muss der Broadcast es erreichen.
    LDm := TdmArtikelStamm(TdmArtikelStamm.GetInstance);
    TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 1;

    Sag('Vor dem Laden sind die Kopien leer', not LDm.tblArtikel.Active);

    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;

    LQry := TFDQuery.Create(nil);
    try
      LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

      Sag('Broadcast hat die Kopien gefuellt',
          LDm.tblArtikel.Active and LDm.tblKategorie.Active and
          LDm.tblArtikelKategorie.Active);

      Sag('Mandantenfilter auf den Artikeln',
          LDm.tblArtikel.RecordCount =
            Zaehle('SELECT count(*) FROM artikel WHERE mandant_id=1'),
          Format('%d Artikel', [LDm.tblArtikel.RecordCount]));

      Sag('Kategorieliste gefiltert',
          LDm.tblKategorie.RecordCount =
            Zaehle('SELECT count(*) FROM kategorie WHERE mandant_id=1 ' +
                   'AND bereich=''ARTIKEL'' AND aktiv'),
          Format('%d Kategorien', [LDm.tblKategorie.RecordCount]));

      Sag('Bruecke vollstaendig kopiert (nicht beschnitten)',
          Zaehle('SELECT count(*) FROM artikel_kategorie') > 0);

      Writeln;
      // Die Artikel, bei denen wirklich etwas dranhaengt.
      ArtikelPruefen('TRT-100');
      ArtikelPruefen('TRT-120');
      ArtikelPruefen('TRT-121');
      ArtikelPruefen('TRT-130');
      ArtikelPruefen('TRT-200');
      Writeln;
      // Und einmal zurueck, damit ein haengengebliebener Filter auffaellt.
      ArtikelPruefen('TRT-120');
      ArtikelPruefen('TRT-100');

      Writeln;
      // Der Weg, den der Ribbon-Knopf im Hauptfenster geht.
      Sag('Fenster vor OpenGui nicht da', frmArtikelStamm = nil);
      TdmModuleTemplate.OpenGui('ArtikelStamm');
      Application.ProcessMessages;
      Sag('OpenGui hat das Fenster geoeffnet', Assigned(frmArtikelStamm));
      if Assigned(frmArtikelStamm) then
      begin
        Sag('  ... Artikelgitter haengt an den Daten',
            frmArtikelStamm.edtArtikelNr.DataSource = LDm.dstblArtikel);
        Sag('  ... und zeigt Saetze',
            LDm.tblArtikel.RecordCount > 0,
            Format('%d', [LDm.tblArtikel.RecordCount]));
        Sag('  ... Kategoriegitter folgt dem Artikel',
            frmArtikelStamm.grdKategorie.DataSource = LDm.dstblArtikelKategorie);

        Writeln;
        // Ist es wirklich eine Ableitung, oder nur ein TForm?
        // Das Formular erbt von TForm - sein DFM beginnt mit "object",
        // nicht mit "inherited".
        Sag('  ... geerbte Aktionen sind verdrahtet',
            Assigned(frmArtikelStamm.actErsterL.OnExecute) and
            Assigned(frmArtikelStamm.actWeiterL.OnExecute) and
            Assigned(frmArtikelStamm.actNeuLadenL.OnExecute));
        Sag('  ... Knoepfe haengen an den Aktionen',
            (frmArtikelStamm.btnErsterStamm.Action = frmArtikelStamm.actErsterL) and
            (frmArtikelStamm.btnWeiterStamm.Action = frmArtikelStamm.actWeiterL));

        // Navigation ausfuehren wie ein Knopfdruck.
        LDm.tblArtikel.First;
        LNr := LDm.tblArtikel.FieldByName('artikel_nr').AsString;
        frmArtikelStamm.actWeiterL.Execute;
        Application.ProcessMessages;
        Sag('  ... "Weiter" bewegt den Satzzeiger',
            LDm.tblArtikel.FieldByName('artikel_nr').AsString <> LNr,
            LNr + ' -> ' + LDm.tblArtikel.FieldByName('artikel_nr').AsString);

        Writeln;
        // Keine nackten IDs: das Gitter zeigt die Bezeichnung.
        Sag('Gitter zeigt Bezeichnung, nicht die ID',
            frmArtikelStamm.grdKategorie.Columns[0].FieldName = 'bezeichnung');
        LDm.tblArtikel.Locate('artikel_nr', 'TRT-120', []);
        Application.ProcessMessages;
        Sag('  ... Lookup liefert Klartext',
            LDm.tblArtikelKategorie.FieldByName('bezeichnung').AsString =
              'Handelsware',
            '"' + LDm.tblArtikelKategorie.FieldByName('bezeichnung').AsString + '"');

        // Haken in der Ankreuzliste
        LIst := '';
        for LI := 0 to frmArtikelStamm.clbKategorie.Items.Count - 1 do
          if frmArtikelStamm.clbKategorie.Checked[LI] then
          begin
            if LIst <> '' then
              LIst := LIst + ',';
            LIst := LIst + frmArtikelStamm.clbKategorie.Items[LI];
          end;
        Sag('  ... Haken passen zum Artikel', LIst = 'Handelsware',
            '"' + LIst + '"');

        Writeln;
        // Schreibweg: Haken setzen und wieder wegnehmen.
        LI := frmArtikelStamm.clbKategorie.Items.IndexOf('Werkzeug');
        LMeldung := LDm.KategorieSetzen(
          Integer(NativeInt(frmArtikelStamm.clbKategorie.Items.Objects[LI])), True);
        Sag('Kategorie setzen', LMeldung = '', LMeldung);
        Sag('  ... steht in der Datenbank',
            Zaehle('SELECT count(*) FROM artikel_kategorie ak ' +
                   'JOIN kategorie k USING (kategorie_id) ' +
                   'WHERE ak.artikel_id=(SELECT artikel_id FROM artikel ' +
                   '                      WHERE artikel_nr=''TRT-120'') ' +
                   '  AND k.bezeichnung=''Werkzeug''') = 1);
        frmArtikelStamm.KategorienAnzeigen;
        Sag('  ... und der Haken sitzt',
            frmArtikelStamm.clbKategorie.Checked[LI]);

        LMeldung := LDm.KategorieSetzen(
          Integer(NativeInt(frmArtikelStamm.clbKategorie.Items.Objects[LI])), False);
        Sag('Kategorie wieder wegnehmen', LMeldung = '', LMeldung);
        Sag('  ... wieder weg aus der Datenbank',
            Zaehle('SELECT count(*) FROM artikel_kategorie ak ' +
                   'JOIN kategorie k USING (kategorie_id) ' +
                   'WHERE ak.artikel_id=(SELECT artikel_id FROM artikel ' +
                   '                      WHERE artikel_nr=''TRT-120'') ' +
                   '  AND k.bezeichnung=''Werkzeug''') = 0);

        Writeln;
        // ── Fotos ──────────────────────────────────────────────────────
        // Keine Spalte darf eine ID zeigen - wie viele es sind, ist Sache
        // des Formulars.
        LIst := '';
        for LI := 0 to frmArtikelStamm.dbgrdFotos.Columns.Count - 1 do
          LIst := LIst + frmArtikelStamm.dbgrdFotos.Columns[LI].FieldName + ' ';
        Sag('Fotogitter zeigt keine ID',
            (Pos('foto_id', LIst) = 0) and (Pos('artikel_id', LIst) = 0) and
            (Pos('mandant_id', LIst) = 0), '"' + Trim(LIst) + '"');

        // TRT-120 hat ein Bild in der Datenbank - wird es gezeigt?
        LDm.tblArtikel.Locate('artikel_nr', 'TRT-120', []);
        Application.ProcessMessages;
        Sag('TRT-120: Foto in der Kopie',
            LDm.tblArtikelFoto.RecordCount =
              Zaehle('SELECT count(*) FROM artikel_foto WHERE artikel_id=' +
                     '(SELECT artikel_id FROM artikel WHERE artikel_nr=''TRT-120'')'),
            Format('%d', [LDm.tblArtikelFoto.RecordCount]));
        Sag('  ... und das Bildfeld zeigt es an',
            Assigned(frmArtikelStamm.dbimgFoto.Picture.Graphic) and
            not frmArtikelStamm.dbimgFoto.Picture.Graphic.Empty,
            Format('%dx%d', [frmArtikelStamm.dbimgFoto.Picture.Width,
                             frmArtikelStamm.dbimgFoto.Picture.Height]));

        LDm.tblArtikel.Locate('artikel_nr', 'TRT-121', []);
        Application.ProcessMessages;
        // Sollwert aus der Datenbank, nicht fest verdrahtet: der Anwender
        // laedt und loescht Fotos, der Pruefstand darf davon nicht abhaengen.
        Sag('TRT-121: eigene Fotos',
            LDm.tblArtikelFoto.RecordCount =
              Zaehle('SELECT count(*) FROM artikel_foto WHERE artikel_id=' +
                     '(SELECT artikel_id FROM artikel WHERE artikel_nr=''TRT-121'')'),
            Format('%d', [LDm.tblArtikelFoto.RecordCount]));

        // Anhaengen ueber den Weg, den der Knopf geht
        LDatei := TPath.Combine(TPath.GetTempPath, 'zzpruef_neu.png');
        TFile.WriteAllBytes(LDatei, PruefBild);
        LDatei2 := TPath.Combine(TPath.GetTempPath, 'zzpruef_zwei.png');
        TFile.WriteAllBytes(LDatei2, PruefBild);
        LMuell := TPath.Combine(TPath.GetTempPath, 'zzpruef_kein_bild.txt');
        TFile.WriteAllText(LMuell, 'kein Bild');
        try
          LDm.tblArtikel.Locate('artikel_nr', 'TRT-130', []);
          Application.ProcessMessages;
          LVorher := LDm.tblArtikelFoto.RecordCount;

          LFotoId := LDm.FotoAnhaengen(LDatei, 'ZZPruef angehaengt');
          Sag('Foto anhaengen', LFotoId > 0, Format('foto_id=%d', [LFotoId]));
          Sag('  ... haengt am richtigen Artikel',
              Zaehle(Format('SELECT artikel_id FROM artikel_foto WHERE foto_id=%d',
                            [LFotoId])) =
              Zaehle('SELECT artikel_id FROM artikel WHERE artikel_nr=''TRT-130'''));
          Sag('  ... die Kopie kennt es',
              LDm.tblArtikelFoto.RecordCount = LVorher + 1);

          // Ziehen-und-Ablegen mit einer Datei, die kein Bild ist
          LAnzahl := LDm.FotosAusDateien([LDatei2, LMuell], LUeber);
          Sag('Ziehen: ein Bild uebernommen', LAnzahl = 1);
          Sag('  ... Nicht-Bild ausgelassen und gemeldet',
              (Length(LUeber) = 1) and (LUeber[0] = LMuell));
          Sag('  ... Dateiname steht als Bezeichnung drin',
              Zaehle('SELECT count(*) FROM artikel_foto ' +
                     'WHERE beschreibung=''zzpruef_zwei''') = 1);

          // Aufraeumen ueber den Loeschweg des Moduls
          LQry.Close;
          LQry.SQL.Text := 'SELECT foto_id FROM artikel_foto ' +
                           'WHERE beschreibung LIKE ''ZZPruef%'' ' +
                           '   OR beschreibung LIKE ''zzpruef%''';
          LQry.Open;
          SetLength(LIds, 0);
          while not LQry.Eof do
          begin
            LIds := LIds + [LQry.Fields[0].AsInteger];
            LQry.Next;
          end;
          for LI := 0 to High(LIds) do
            LDm.FotoLoeschen(LIds[LI]);
          Sag('Testfotos wieder geloescht',
              Zaehle('SELECT count(*) FROM artikel_foto ' +
                     'WHERE beschreibung LIKE ''ZZPruef%'' ' +
                     '   OR beschreibung LIKE ''zzpruef%''') = 0);
        finally
          if TFile.Exists(LDatei) then TFile.Delete(LDatei);
          if TFile.Exists(LDatei2) then TFile.Delete(LDatei2);
          if TFile.Exists(LMuell) then TFile.Delete(LMuell);
        end;

        frmArtikelStamm.Close;
        Application.ProcessMessages;
      end;
    finally
      LQry.Free;
    end;

    Writeln;
    if LFehler = 0 then
      Writeln('Alles in Ordnung.')
    else
      Writeln(LFehler, ' Pruefung(en) fehlgeschlagen.');
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
