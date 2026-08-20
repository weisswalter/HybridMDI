program TestWebsite;
{$APPTYPE CONSOLE}
// Prueft den Website-Reiter im Einstellungsfenster: Werte lesen, Shop ein-
// und ausschalten, Waehrung aendern - und jeweils in der Datenbank
// nachsehen, ob es dort angekommen ist. Stellt den Ausgangszustand wieder her.
// Der MDI-Rahmen startet minimiert und ausserhalb des Bildschirms.
uses
  System.SysUtils, System.Classes, Data.DB, Vcl.Forms, Vcl.Controls,
  FireDAC.Comp.Client,
  ZentraleDatenDm, MandantDm, EinstellungenDm, EinstellungenFrm;

type
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
  LRahmen: TMdiRahmen;
  LDm: TdmEinstellungen;
  LPruef: TFDQuery;
  LFehler: Integer = 0;
  LMeldung, LVorher: string;

procedure Sag(const ATitel: string; AGut: Boolean; const AText: string = '');
var
  LZusatz: string;
begin
  if AText = '' then LZusatz := '' else LZusatz := '   ' + AText;
  Writeln(Format('%-46s %s%s', [ATitel, BoolToStr(AGut, True), LZusatz]));
  if not AGut then Inc(LFehler);
end;

// Liest den Wert unmittelbar aus der Datenbank, nicht aus der Kopie -
// sonst prueft man nur sich selbst.
function AusDerDatenbank(const ASchluessel: string): string;
begin
  LPruef.Close;
  LPruef.SQL.Text :=
    'SELECT fn_mandant_einstellung_lesen(1, ' + QuotedStr(ASchluessel) + ')';
  LPruef.Open;
  Result := LPruef.Fields[0].AsString;
end;

begin
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    Application.CreateForm(TMdiRahmen, LRahmen);
    TdmZentraleDaten(TdmZentraleDaten.GetInstance).AlleTabellenLaden;
    TdmMandant(TdmMandant.GetInstance).CurrentMandantId := 1;

    LPruef := TFDQuery.Create(nil);
    try
      LPruef.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;

      LDm := TdmEinstellungen(TdmEinstellungen.GetInstance);
      LDm.OpenEinstellungen;
      Sag('Fenster offen', Assigned(frmEinstellungen));
      Sag('Website-Reiter ist Nummer 9', LDm.IstWebsiteTab(9));

      LVorher := LDm.WebWert('SHOP_AKTIV');
      Sag('Werte gelesen',
          (LVorher <> '') and (LDm.WebWert('SHOP_WAEHRUNG') <> ''),
          'Shop=' + LVorher + ', Waehrung=' + LDm.WebWert('SHOP_WAEHRUNG') +
          ', MwSt=' + LDm.WebWert('SHOP_MWST'));

      LMeldung := LDm.WebWertSetzen('SHOP_AKTIV', 'true');
      Sag('Shop eingeschaltet',
          (LMeldung = '') and (AusDerDatenbank('SHOP_AKTIV') = 'true') and
          (LDm.WebWert('SHOP_AKTIV') = 'true'), LMeldung);

      LMeldung := LDm.WebWertSetzen('SHOP_AKTIV', 'false');
      Sag('Shop ausgeschaltet',
          (LMeldung = '') and (AusDerDatenbank('SHOP_AKTIV') = 'false'), LMeldung);

      LMeldung := LDm.WebWertSetzen('SHOP_WAEHRUNG', 'ZZZ');
      Sag('Waehrung geaendert',
          (LMeldung = '') and (AusDerDatenbank('SHOP_WAEHRUNG') = 'ZZZ'), LMeldung);
      LDm.WebWertSetzen('SHOP_WAEHRUNG', 'EUR');
      Sag('  ... zurueckgesetzt', AusDerDatenbank('SHOP_WAEHRUNG') = 'EUR');

      // Die Sicht, die die Website liest, muss dasselbe sagen
      LPruef.Close;
      LPruef.SQL.Text := 'SELECT shop_aktiv, waehrung FROM v_shop_einstellung WHERE mandant_id=1';
      LPruef.Open;
      Sag('Sicht der Website stimmt ueberein',
          (not LPruef.Fields[0].AsBoolean) and (LPruef.Fields[1].AsString = 'EUR'));

      // Leerer Wert darf die Sicht nicht mehr zerlegen - genau daran ist
      // das Programm beim Start haengengeblieben.
      LDm.WebWertSetzen('SHOP_MWST', '');
      LPruef.Close;
      LPruef.SQL.Text := 'SELECT mwst FROM v_shop_einstellung WHERE mandant_id=1';
      try
        LPruef.Open;
        Sag('Leerer Wert bringt die Sicht nicht um', True,
            'mwst=' + LPruef.Fields[0].AsString);
      except
        on E: Exception do
          Sag('Leerer Wert bringt die Sicht nicht um', False, E.Message);
      end;
      LDm.WebWertSetzen('SHOP_MWST', '19.0');

      LDm.WebWertSetzen('SHOP_AKTIV', LVorher);
      Sag('Ausgangszustand wiederhergestellt',
          (AusDerDatenbank('SHOP_AKTIV') = LVorher) and
          (AusDerDatenbank('SHOP_MWST') = '19.0'), 'Shop=' + LVorher);
    finally
      LPruef.Free;
    end;

    Writeln;
    if LFehler = 0 then Writeln('Alles in Ordnung.')
                   else Writeln(LFehler, ' Pruefung(en) fehlgeschlagen.');
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
