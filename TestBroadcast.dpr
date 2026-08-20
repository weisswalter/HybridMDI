program TestBroadcast;
{$APPTYPE CONSOLE}
// Prueft die neue Kette:
//   ZentraleDatenDm.AlleTabellenLaden  -> postet mtBroadcast('DatenGeladen')
//   TCentralMessageHandler.HandleMessage -> TdmModuleTemplate.AlleBenachrichtigen
//   jedes erzeugte Modul                 -> DatenGeladen
//
// Zwei Testmodule leiten vom Template ab: eines ueberschreibt DatenGeladen
// und holt sich eine Kopie, das andere nicht. Beide muessen den Broadcast
// ueberstehen -- ein Modul ohne die Methode darf ihn nicht zum Absturz
// bringen.
uses
  System.SysUtils, System.Classes, System.StrUtils,
  Data.DB, Vcl.Forms,
  FireDAC.Comp.Client,
  EventBus, UInterfaces, uMessageHandler,
  udmModuleTemplate, ZentraleDatenDm;

type
  // Ein Modul, wie es kuenftig aussehen soll: kein SQL, keine Connection,
  // nur Kopien.
  TdmTestModul = class(TdmModuleTemplate)
  private
    FGerufen: Integer;
  public
    tblArtikel: TFDMemTable;
    tblKategorie: TFDMemTable;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure DatenGeladen; override;
    procedure FGerufenZuruecksetzen;
    property Gerufen: Integer read FGerufen;
  end;

  // Ein Modul, das die Methode NICHT ueberschreibt.
  TdmStillesModul = class(TdmModuleTemplate)
  end;

constructor TdmTestModul.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  tblArtikel := TFDMemTable.Create(Self);
  tblKategorie := TFDMemTable.Create(Self);
end;

destructor TdmTestModul.Destroy;
begin
  inherited;
end;

procedure TdmTestModul.FGerufenZuruecksetzen;
begin
  FGerufen := 0;
end;

procedure TdmTestModul.DatenGeladen;
begin
  Inc(FGerufen);
  Kopiere(tblArtikel, 'artikel');
  Kopiere(tblKategorie, 'kategorie');
end;

var
  LFehler: Integer = 0;
  LModul: TdmTestModul;
  LStill: TdmStillesModul;
  LQry: TFDQuery;
  LEreignis: IMyEvent;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
begin
  Writeln(Format('%-46s %-5s %s', [ATitel, BoolToStr(AGut, True), AText]));
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

function TextAus(const ASql: string): string;
begin
  LQry.Close;
  LQry.SQL.Text := ASql;
  LQry.Open;
  Result := LQry.Fields[0].AsString;
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;

    // Der MessageHandler muss stehen, sonst hoert niemand zu.
    Application.CreateForm(TdmMessageHandler, dmMessageHandler);

    LModul := TdmTestModul.Create(Application);
    LStill := TdmStillesModul.Create(Application);
    Sag('Zwei Module erzeugt', Assigned(LModul) and Assigned(LStill));
    Sag('Vor dem Laden noch nicht gerufen', LModul.Gerufen = 0);

    // Erst die Verteilung allein pruefen, ohne EventBus dazwischen.
    TdmModuleTemplate.AlleBenachrichtigen('DatenGeladen');
    Sag('Verteilung direkt (ohne EventBus)', LModul.Gerufen = 1,
        'gerufen: ' + IntToStr(LModul.Gerufen));
    LModul.FGerufenZuruecksetzen;

    // Das ist der Ausloeser: laedt alles und postet den Broadcast.
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;

    LQry := TFDQuery.Create(nil);
    try
      LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

      Sag('DatenGeladen kam an', LModul.Gerufen = 1,
          'gerufen: ' + IntToStr(LModul.Gerufen));
      Sag('Modul ohne die Methode stoert nicht', True);

      Sag('Kopie artikel gefuellt',
          LModul.tblArtikel.Active and
          (LModul.tblArtikel.RecordCount = Zaehle('SELECT count(*) FROM artikel')),
          Format('%d Saetze', [LModul.tblArtikel.RecordCount]));
      Sag('Kopie kategorie gefuellt',
          LModul.tblKategorie.Active and
          (LModul.tblKategorie.RecordCount = Zaehle('SELECT count(*) FROM kategorie')),
          Format('%d Saetze', [LModul.tblKategorie.RecordCount]));
      Sag('Kopie hat die Spalten der Quelle',
          LModul.tblArtikel.FindField('artikel_nr') <> nil);
      // Eine MemTable hat gar keine Connection - das ist der Punkt.
      // Statt dessen inhaltlich pruefen: steht in der Kopie dasselbe
      // wie in der Datenbank?
      LModul.tblArtikel.First;
      Sag('Inhalt der Kopie stimmt',
          LModul.tblArtikel.FieldByName('artikel_nr').AsString =
            TextAus('SELECT artikel_nr FROM artikel ORDER BY artikel_id LIMIT 1'),
          LModul.tblArtikel.FieldByName('artikel_nr').AsString);

      // Zweiter Broadcast: muss wieder ankommen, ohne dass etwas doppelt wird.
      LEreignis := TMyEvent.Create('DatenGeladen', '', '', '', '', '', '',
        False, mtBroadcast, Now, False, 0, []);
      GlobalEventBus.Post(LEreignis);
      Sag('Zweiter Broadcast kam auch an', LModul.Gerufen = 2,
          'gerufen: ' + IntToStr(LModul.Gerufen));
      Sag('  ... Kopie danach nicht doppelt',
          LModul.tblArtikel.RecordCount = Zaehle('SELECT count(*) FROM artikel'),
          Format('%d Saetze', [LModul.tblArtikel.RecordCount]));

      // Ein freigegebenes Modul darf nicht mehr benachrichtigt werden.
      LStill.Free;
      LEreignis := TMyEvent.Create('DatenGeladen', '', '', '', '', '', '',
        False, mtBroadcast, Now, False, 0, []);
      GlobalEventBus.Post(LEreignis);
      Sag('Nach Freigabe kein Zugriff auf totes Modul', LModul.Gerufen = 3,
          'gerufen: ' + IntToStr(LModul.Gerufen));
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
