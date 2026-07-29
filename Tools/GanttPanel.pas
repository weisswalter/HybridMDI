unit GanttPanel;

// TGanttPanel - Belegungsansicht auf einer Zeitachse.
//
// Ausgangsbasis ist Walters Prototyp (Projekte\gantt\uFrmMain.pas): PaintBox
// mit DrawTimeline/DrawItems. Verallgemeinert wurde:
//   - die Zeitachse rechnet mit DATUM+Zeit statt nur mit der Uhrzeit
//     (TimeOf im Prototyp warf das Datum weg, alles landete auf einem Tag)
//   - Zeilen statt gestapelter Balken: jede Zeile ist eine Ressource
//   - Gruppen: Lehrer zuerst, dann Raeume - Reihenfolge macht der Aufrufer
//   - waagerecht und senkrecht scrollbar
//
// BEWUSST DUMM: die Komponente kennt weder Kurse noch Raeume noch Kompetenzen.
// Sie bekommt Zeilen mit Balken und zeichnet sie. Die Fachlogik - welcher
// Lehrer kann was, welcher Raum hat welche Ausstattung, welcher Mehrzweckraum
// laesst sich mobil ausruesten - gehoert in ein DataModule darueber. Nur so
// laesst sich dieselbe Ansicht fuer Raumbelegung, Lehrerauslastung und
// Anwesenheit verwenden.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.DateUtils, System.Generics.Collections,
  System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Themes;

type
  // Zustand eines Balkens. Steuert die Vorbelegung der Farbe, siehe StatusFarbe.
  TGanttStatus = (gsGewuenscht, gsBelegt, gsKonflikt, gsGesperrt, gsFrei);

  TGanttBalken = class
  public
    Titel: string;
    Von: TDateTime;
    Bis: TDateTime;
    Status: TGanttStatus;
    // 0 = Farbe aus Status ableiten, sonst Vorrang vor dem Status
    Farbe: TColor;
    // fachliche Kennung, z.B. termin_id - kommt im Klickereignis zurueck
    Kennung: Integer;
    Hinweis: string;
    constructor Create;
  end;

  TGanttZeile = class
  public
    // frei waehlbarer Schluessel des Aufrufers, z.B. 'raum:12'
    Schluessel: string;
    Beschriftung: string;
    // Gruppenkopf ("Lehrer", "Raeume") - hat keine Balken, wird als Band gezeichnet
    IstGruppe: Boolean;
    // Zeile kommt fuer die aktuelle Planung in Frage (z.B. Raum erfuellt die
    // Ausstattungsanforderung, notfalls mit mobilem Inventar)
    Auswaehlbar: Boolean;
    Ausgewaehlt: Boolean;
    // Zusatz rechts neben der Beschriftung, z.B. "mobil ausruestbar"
    Zusatz: string;
    Kennung: Integer;
    Balken: TObjectList<TGanttBalken>;
    constructor Create;
    destructor Destroy; override;
    function BalkenHinzufuegen(const ATitel: string; AVon, ABis: TDateTime;
      AStatus: TGanttStatus): TGanttBalken;
  end;

  TGanttBalkenEvent = procedure(Sender: TObject; AZeile: TGanttZeile;
    ABalken: TGanttBalken) of object;
  TGanttZeileEvent = procedure(Sender: TObject; AZeile: TGanttZeile) of object;
  TGanttZeitEvent = procedure(Sender: TObject; AZeile: TGanttZeile;
    AZeitpunkt: TDateTime) of object;

  TGanttPanel = class(TCustomControl)
  private
    FZeilen: TObjectList<TGanttZeile>;
    FDatum: TDate;
    FStundenVor: Integer;
    FStundenNach: Integer;
    FPixelProStunde: Integer;
    FZeilenHoehe: Integer;
    FKopfHoehe: Integer;
    FBeschriftungsBreite: Integer;
    FBedarfVon: TDateTime;
    FBedarfBis: TDateTime;
    FScrollWaagerecht: TScrollBar;
    FScrollSenkrecht: TScrollBar;
    FVersatzX: Integer;
    FVersatzY: Integer;
    FAktualisierung: Integer;
    FOnBalkenClick: TGanttBalkenEvent;
    FOnZeileClick: TGanttZeileEvent;
    FOnZeitClick: TGanttZeitEvent;

    procedure SetDatum(const Value: TDate);
    procedure SetStundenVor(const Value: Integer);
    procedure SetStundenNach(const Value: Integer);
    procedure SetPixelProStunde(const Value: Integer);
    procedure SetZeilenHoehe(const Value: Integer);
    procedure SetBeschriftungsBreite(const Value: Integer);
    procedure SetBedarf(AVon, ABis: TDateTime);

    function FensterVon: TDateTime;
    function FensterBis: TDateTime;
    function InhaltsBreite: Integer;
    function InhaltsHoehe: Integer;
    function ZeitZuX(AZeit: TDateTime): Integer;
    function XZuZeit(AX: Integer): TDateTime;
    function ZeileBeiY(AY: Integer): Integer;
    function StatusFarbe(AStatus: TGanttStatus): TColor;

    procedure ScrollWaagerecht(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ScrollSenkrecht(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure RollbalkenAnpassen;

    procedure ZeichneKopf;
    procedure ZeichneZeilen;
    procedure ZeichneBedarf;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    // in TControl public - Sichtbarkeit muss erhalten bleiben (H2269)
    procedure MouseWheelHandler(var Message: TMessage); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Aenderungen buendeln - ohne das wird bei jeder Zeile neu gezeichnet
    procedure BeginUpdate;
    procedure EndUpdate;

    procedure Leeren;
    function GruppeHinzufuegen(const ABeschriftung: string): TGanttZeile;
    function ZeileHinzufuegen(const ASchluessel, ABeschriftung: string;
      AKennung: Integer = 0): TGanttZeile;
    function ZeileNach(const ASchluessel: string): TGanttZeile;

    // Der geplante Zeitraum: wird als senkrechtes Band ueber alle Zeilen
    // gelegt. Damit sieht man auf einen Blick, welche Ressource in genau
    // diesem Fenster frei ist - das ist der eigentliche Zweck der Ansicht.
    procedure BedarfSetzen(AVon, ABis: TDateTime);
    procedure BedarfLoeschen;

    // Springt so, dass der Zeitpunkt sichtbar wird
    procedure ZeigeZeit(AZeit: TDateTime);

    property Zeilen: TObjectList<TGanttZeile> read FZeilen;
  published
    property Datum: TDate read FDatum write SetDatum;
    // Fenster ueber den Tag hinaus, Walters Vorgabe: plus/minus 10 Stunden
    property StundenVor: Integer read FStundenVor write SetStundenVor default 10;
    property StundenNach: Integer read FStundenNach write SetStundenNach default 10;
    property PixelProStunde: Integer read FPixelProStunde write SetPixelProStunde default 60;
    property ZeilenHoehe: Integer read FZeilenHoehe write SetZeilenHoehe default 28;
    property BeschriftungsBreite: Integer read FBeschriftungsBreite
      write SetBeschriftungsBreite default 190;

    property OnBalkenClick: TGanttBalkenEvent read FOnBalkenClick write FOnBalkenClick;
    property OnZeileClick: TGanttZeileEvent read FOnZeileClick write FOnZeileClick;
    // Klick auf freie Flaeche einer Zeile - liefert den Zeitpunkt darunter
    property OnZeitClick: TGanttZeitEvent read FOnZeitClick write FOnZeitClick;

    property Align;
    property Anchors;
    property Color;
    property Font;
    property ParentColor;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure Register;

implementation

const
  cFarbeGewuenscht = TColor($00E0D0A0);   // gedecktes Blaugrau
  cFarbeBelegt     = TColor($00C08040);   // kraeftiges Blau
  cFarbeKonflikt   = TColor($004040E0);   // Rot (BGR!)
  cFarbeGesperrt   = TColor($00C0C0C0);
  cFarbeFrei       = TColor($00D0F0D0);
  cFarbeGruppe     = TColor($00E8E0D8);
  cFarbeRaster     = TColor($00DCDCDC);
  cFarbeBedarf     = TColor($0060E0FF);   // Gelb-Orange fuer das Bedarfsband

{ TGanttBalken }

constructor TGanttBalken.Create;
begin
  inherited Create;
  Status := gsBelegt;
  Farbe := 0;
end;

{ TGanttZeile }

constructor TGanttZeile.Create;
begin
  inherited Create;
  Balken := TObjectList<TGanttBalken>.Create(True);
end;

destructor TGanttZeile.Destroy;
begin
  Balken.Free;
  inherited Destroy;
end;

function TGanttZeile.BalkenHinzufuegen(const ATitel: string;
  AVon, ABis: TDateTime; AStatus: TGanttStatus): TGanttBalken;
begin
  Result := TGanttBalken.Create;
  Result.Titel := ATitel;
  Result.Von := AVon;
  Result.Bis := ABis;
  Result.Status := AStatus;
  Balken.Add(Result);
end;

{ TGanttPanel }

constructor TGanttPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  Width := 800;
  Height := 400;
  Color := clWindow;

  FZeilen := TObjectList<TGanttZeile>.Create(True);
  FDatum := Date;
  FStundenVor := 10;
  FStundenNach := 10;
  FPixelProStunde := 60;
  FZeilenHoehe := 28;
  FKopfHoehe := 40;
  FBeschriftungsBreite := 190;

  FScrollWaagerecht := TScrollBar.Create(Self);
  FScrollWaagerecht.Parent := Self;
  FScrollWaagerecht.Kind := sbHorizontal;
  FScrollWaagerecht.Align := alBottom;
  FScrollWaagerecht.OnScroll := ScrollWaagerecht;

  FScrollSenkrecht := TScrollBar.Create(Self);
  FScrollSenkrecht.Parent := Self;
  FScrollSenkrecht.Kind := sbVertical;
  FScrollSenkrecht.Align := alRight;
  FScrollSenkrecht.OnScroll := ScrollSenkrecht;
end;

destructor TGanttPanel.Destroy;
begin
  FZeilen.Free;
  inherited Destroy;
end;

procedure TGanttPanel.BeginUpdate;
begin
  Inc(FAktualisierung);
end;

procedure TGanttPanel.EndUpdate;
begin
  if FAktualisierung > 0 then
    Dec(FAktualisierung);
  if FAktualisierung = 0 then
  begin
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

procedure TGanttPanel.Leeren;
begin
  FZeilen.Clear;
  FVersatzY := 0;
  if FAktualisierung = 0 then
  begin
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

function TGanttPanel.GruppeHinzufuegen(const ABeschriftung: string): TGanttZeile;
begin
  Result := TGanttZeile.Create;
  Result.Beschriftung := ABeschriftung;
  Result.IstGruppe := True;
  FZeilen.Add(Result);
  if FAktualisierung = 0 then
  begin
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

function TGanttPanel.ZeileHinzufuegen(const ASchluessel, ABeschriftung: string;
  AKennung: Integer): TGanttZeile;
begin
  Result := TGanttZeile.Create;
  Result.Schluessel := ASchluessel;
  Result.Beschriftung := ABeschriftung;
  Result.Kennung := AKennung;
  FZeilen.Add(Result);
  if FAktualisierung = 0 then
  begin
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

function TGanttPanel.ZeileNach(const ASchluessel: string): TGanttZeile;
var
  LZeile: TGanttZeile;
begin
  for LZeile in FZeilen do
    if SameText(LZeile.Schluessel, ASchluessel) then
      Exit(LZeile);
  Result := nil;
end;

// ── Zeitfenster und Umrechnung ──────────────────────────────────────────────

function TGanttPanel.FensterVon: TDateTime;
begin
  Result := Trunc(FDatum) - FStundenVor / 24;
end;

function TGanttPanel.FensterBis: TDateTime;
begin
  Result := Trunc(FDatum) + 1 + FStundenNach / 24;
end;

function TGanttPanel.InhaltsBreite: Integer;
begin
  Result := Round((FensterBis - FensterVon) * 24 * FPixelProStunde);
end;

function TGanttPanel.InhaltsHoehe: Integer;
begin
  Result := FZeilen.Count * FZeilenHoehe;
end;

// Anders als im Prototyp mit TimeOf wird hier mit dem vollen TDateTime
// gerechnet - sonst faellt ein Termin, der ueber Mitternacht geht, auf den
// Anfang des Tages zurueck.
function TGanttPanel.ZeitZuX(AZeit: TDateTime): Integer;
begin
  Result := FBeschriftungsBreite
          + Round((AZeit - FensterVon) * 24 * FPixelProStunde)
          - FVersatzX;
end;

function TGanttPanel.XZuZeit(AX: Integer): TDateTime;
begin
  Result := FensterVon
          + (AX - FBeschriftungsBreite + FVersatzX) / (24 * FPixelProStunde);
end;

function TGanttPanel.ZeileBeiY(AY: Integer): Integer;
begin
  if AY < FKopfHoehe then
    Exit(-1);
  Result := (AY - FKopfHoehe + FVersatzY) div FZeilenHoehe;
  if (Result < 0) or (Result >= FZeilen.Count) then
    Result := -1;
end;

function TGanttPanel.StatusFarbe(AStatus: TGanttStatus): TColor;
begin
  case AStatus of
    gsGewuenscht: Result := cFarbeGewuenscht;
    gsBelegt:     Result := cFarbeBelegt;
    gsKonflikt:   Result := cFarbeKonflikt;
    gsGesperrt:   Result := cFarbeGesperrt;
  else
    Result := cFarbeFrei;
  end;
end;

// ── Eigenschaften ───────────────────────────────────────────────────────────

procedure TGanttPanel.SetDatum(const Value: TDate);
begin
  if FDatum <> Value then
  begin
    FDatum := Value;
    FVersatzX := 0;
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

procedure TGanttPanel.SetStundenVor(const Value: Integer);
begin
  if (FStundenVor <> Value) and (Value >= 0) then
  begin
    FStundenVor := Value;
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

procedure TGanttPanel.SetStundenNach(const Value: Integer);
begin
  if (FStundenNach <> Value) and (Value >= 0) then
  begin
    FStundenNach := Value;
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

procedure TGanttPanel.SetPixelProStunde(const Value: Integer);
begin
  if (FPixelProStunde <> Value) and (Value >= 8) and (Value <= 400) then
  begin
    FPixelProStunde := Value;
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

procedure TGanttPanel.SetZeilenHoehe(const Value: Integer);
begin
  if (FZeilenHoehe <> Value) and (Value >= 12) then
  begin
    FZeilenHoehe := Value;
    RollbalkenAnpassen;
    Invalidate;
  end;
end;

procedure TGanttPanel.SetBeschriftungsBreite(const Value: Integer);
begin
  if (FBeschriftungsBreite <> Value) and (Value >= 40) then
  begin
    FBeschriftungsBreite := Value;
    Invalidate;
  end;
end;

procedure TGanttPanel.SetBedarf(AVon, ABis: TDateTime);
begin
  FBedarfVon := AVon;
  FBedarfBis := ABis;
  Invalidate;
end;

procedure TGanttPanel.BedarfSetzen(AVon, ABis: TDateTime);
begin
  SetBedarf(AVon, ABis);
end;

procedure TGanttPanel.BedarfLoeschen;
begin
  SetBedarf(0, 0);
end;

procedure TGanttPanel.ZeigeZeit(AZeit: TDateTime);
var
  LZiel: Integer;
begin
  // Zeitpunkt mittig ins sichtbare Fenster holen
  LZiel := Round((AZeit - FensterVon) * 24 * FPixelProStunde)
         - (ClientWidth - FBeschriftungsBreite) div 2;
  if LZiel < 0 then
    LZiel := 0;
  FVersatzX := LZiel;
  RollbalkenAnpassen;
  Invalidate;
end;

// ── Rollbalken ──────────────────────────────────────────────────────────────

procedure TGanttPanel.RollbalkenAnpassen;
var
  LSichtbarBreite, LSichtbarHoehe: Integer;
begin
  if (csDestroying in ComponentState) or not Assigned(FScrollWaagerecht) then
    Exit;

  LSichtbarBreite := ClientWidth - FBeschriftungsBreite - FScrollSenkrecht.Width;
  if LSichtbarBreite < 0 then
    LSichtbarBreite := 0;
  LSichtbarHoehe := ClientHeight - FKopfHoehe - FScrollWaagerecht.Height;
  if LSichtbarHoehe < 0 then
    LSichtbarHoehe := 0;

  FScrollWaagerecht.Min := 0;
  FScrollWaagerecht.Max := Max(0, InhaltsBreite - LSichtbarBreite);
  FScrollWaagerecht.LargeChange := Max(1, LSichtbarBreite div 2);
  FScrollWaagerecht.SmallChange := FPixelProStunde;
  FScrollWaagerecht.Enabled := FScrollWaagerecht.Max > 0;
  if FVersatzX > FScrollWaagerecht.Max then
    FVersatzX := FScrollWaagerecht.Max;
  FScrollWaagerecht.Position := FVersatzX;

  FScrollSenkrecht.Min := 0;
  FScrollSenkrecht.Max := Max(0, InhaltsHoehe - LSichtbarHoehe);
  FScrollSenkrecht.LargeChange := Max(1, LSichtbarHoehe div 2);
  FScrollSenkrecht.SmallChange := FZeilenHoehe;
  FScrollSenkrecht.Enabled := FScrollSenkrecht.Max > 0;
  if FVersatzY > FScrollSenkrecht.Max then
    FVersatzY := FScrollSenkrecht.Max;
  FScrollSenkrecht.Position := FVersatzY;
end;

procedure TGanttPanel.ScrollWaagerecht(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  FVersatzX := ScrollPos;
  Invalidate;
end;

procedure TGanttPanel.ScrollSenkrecht(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  FVersatzY := ScrollPos;
  Invalidate;
end;

procedure TGanttPanel.Resize;
begin
  inherited Resize;
  RollbalkenAnpassen;
end;

// Mausrad rollt senkrecht, mit Strg waagerecht - so wie man es von
// Kalenderansichten kennt.
procedure TGanttPanel.MouseWheelHandler(var Message: TMessage);
var
  LDelta: Integer;
begin
  LDelta := SmallInt(Message.WParamHi);
  if GetKeyState(VK_CONTROL) < 0 then
  begin
    FVersatzX := FVersatzX - (LDelta div 120) * FPixelProStunde;
    if FVersatzX < 0 then FVersatzX := 0;
    if FVersatzX > FScrollWaagerecht.Max then FVersatzX := FScrollWaagerecht.Max;
    FScrollWaagerecht.Position := FVersatzX;
  end
  else
  begin
    FVersatzY := FVersatzY - (LDelta div 120) * FZeilenHoehe * 2;
    if FVersatzY < 0 then FVersatzY := 0;
    if FVersatzY > FScrollSenkrecht.Max then FVersatzY := FScrollSenkrecht.Max;
    FScrollSenkrecht.Position := FVersatzY;
  end;
  Invalidate;
  Message.Result := 1;
end;

procedure TGanttPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LIndex, I: Integer;
  LZeile: TGanttZeile;
  LBalken: TGanttBalken;
begin
  inherited MouseDown(Button, Shift, X, Y);

  LIndex := ZeileBeiY(Y);
  if LIndex < 0 then
    Exit;
  LZeile := FZeilen[LIndex];

  if Assigned(FOnZeileClick) then
    FOnZeileClick(Self, LZeile);

  if LZeile.IstGruppe or (X < FBeschriftungsBreite) then
    Exit;

  // Balken unter dem Mauszeiger suchen
  for I := 0 to LZeile.Balken.Count - 1 do
  begin
    LBalken := LZeile.Balken[I];
    if (X >= ZeitZuX(LBalken.Von)) and (X <= ZeitZuX(LBalken.Bis)) then
    begin
      if Assigned(FOnBalkenClick) then
        FOnBalkenClick(Self, LZeile, LBalken);
      Exit;
    end;
  end;

  // freie Flaeche: Zeitpunkt melden, damit der Aufrufer dort planen kann
  if Assigned(FOnZeitClick) then
    FOnZeitClick(Self, LZeile, XZuZeit(X));
end;

// ── Zeichnen ────────────────────────────────────────────────────────────────

procedure TGanttPanel.Paint;
begin
  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  ZeichneBedarf;
  ZeichneKopf;
  ZeichneZeilen;
end;

procedure TGanttPanel.ZeichneKopf;
var
  LStunde: TDateTime;
  X: Integer;
  LText: string;
  LTag: Integer;
begin
  Canvas.Brush.Color := clBtnFace;
  Canvas.FillRect(Rect(0, 0, ClientWidth, FKopfHoehe));
  Canvas.Pen.Color := clGray;
  Canvas.MoveTo(0, FKopfHoehe - 1);
  Canvas.LineTo(ClientWidth, FKopfHoehe - 1);

  Canvas.Font.Assign(Font);
  Canvas.Font.Size := 8;
  Canvas.Brush.Style := bsClear;

  LStunde := FensterVon;
  LTag := -1;
  while LStunde <= FensterBis do
  begin
    X := ZeitZuX(LStunde);
    if (X >= FBeschriftungsBreite) and (X <= ClientWidth) then
    begin
      // Datumszeile nur beim Tageswechsel, sonst wird es unlesbar
      if DayOf(LStunde) <> LTag then
      begin
        LTag := DayOf(LStunde);
        Canvas.Font.Style := [fsBold];
        Canvas.TextOut(X + 2, 2, FormatDateTime('ddd dd.mm.', LStunde));
        Canvas.Font.Style := [];
        Canvas.Pen.Color := clGray;
        Canvas.MoveTo(X, 0);
        Canvas.LineTo(X, ClientHeight);
        Canvas.Pen.Color := cFarbeRaster;
      end;
      LText := FormatDateTime('hh', LStunde);
      Canvas.TextOut(X + 2, FKopfHoehe - 16, LText);
    end;
    LStunde := IncHour(LStunde, 1);
  end;

  // Beschriftungsspalte oben links freihalten
  Canvas.Brush.Color := clBtnFace;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, FBeschriftungsBreite, FKopfHoehe));
  Canvas.Pen.Color := clGray;
  Canvas.MoveTo(FBeschriftungsBreite - 1, 0);
  Canvas.LineTo(FBeschriftungsBreite - 1, ClientHeight);
end;

// Senkrechtes Band ueber alle Zeilen: der geplante Zeitraum. Wird VOR den
// Zeilen gezeichnet, damit die Balken darueber liegen.
procedure TGanttPanel.ZeichneBedarf;
var
  X1, X2: Integer;
begin
  if (FBedarfVon = 0) or (FBedarfBis <= FBedarfVon) then
    Exit;
  X1 := ZeitZuX(FBedarfVon);
  X2 := ZeitZuX(FBedarfBis);
  if (X2 < FBeschriftungsBreite) or (X1 > ClientWidth) then
    Exit;
  if X1 < FBeschriftungsBreite then X1 := FBeschriftungsBreite;

  Canvas.Brush.Color := cFarbeBedarf;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(X1, FKopfHoehe, X2, ClientHeight));
end;

procedure TGanttPanel.ZeichneZeilen;
var
  I, J, Y, X1, X2: Integer;
  LZeile: TGanttZeile;
  LBalken: TGanttBalken;
  LText: string;
  LFarbe: TColor;
begin
  Canvas.Font.Assign(Font);

  for I := 0 to FZeilen.Count - 1 do
  begin
    Y := FKopfHoehe + I * FZeilenHoehe - FVersatzY;
    if (Y + FZeilenHoehe < FKopfHoehe) or (Y > ClientHeight) then
      Continue;   // ausserhalb des sichtbaren Bereichs, gar nicht erst zeichnen

    LZeile := FZeilen[I];

    if LZeile.IstGruppe then
    begin
      Canvas.Brush.Color := cFarbeGruppe;
      Canvas.Brush.Style := bsSolid;
      Canvas.FillRect(Rect(0, Y, ClientWidth, Y + FZeilenHoehe));
      Canvas.Font.Style := [fsBold];
      Canvas.Brush.Style := bsClear;
      Canvas.TextOut(6, Y + 5, LZeile.Beschriftung);
      Canvas.Font.Style := [];
      Continue;
    end;

    // Beschriftungsspalte
    Canvas.Brush.Color := Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Rect(0, Y, FBeschriftungsBreite - 1, Y + FZeilenHoehe));

    if LZeile.Ausgewaehlt then
    begin
      Canvas.Brush.Color := cFarbeBedarf;
      Canvas.FillRect(Rect(0, Y, FBeschriftungsBreite - 1, Y + FZeilenHoehe));
    end;

    Canvas.Brush.Style := bsClear;
    // Nicht waehlbare Zeilen blass: sie erfuellen die Anforderung nicht
    if LZeile.Auswaehlbar then
      Canvas.Font.Color := clWindowText
    else
      Canvas.Font.Color := clGrayText;
    Canvas.TextOut(6, Y + 5, LZeile.Beschriftung);
    if LZeile.Zusatz <> '' then
    begin
      Canvas.Font.Size := Font.Size - 1;
      Canvas.Font.Color := clGrayText;
      Canvas.TextOut(6, Y + FZeilenHoehe - 14, LZeile.Zusatz);
      Canvas.Font.Size := Font.Size;
    end;
    Canvas.Font.Color := clWindowText;

    // Zeilentrenner
    Canvas.Pen.Color := cFarbeRaster;
    Canvas.MoveTo(0, Y + FZeilenHoehe - 1);
    Canvas.LineTo(ClientWidth, Y + FZeilenHoehe - 1);

    // Balken
    for J := 0 to LZeile.Balken.Count - 1 do
    begin
      LBalken := LZeile.Balken[J];
      X1 := ZeitZuX(LBalken.Von);
      X2 := ZeitZuX(LBalken.Bis);
      if (X2 < FBeschriftungsBreite) or (X1 > ClientWidth) then
        Continue;
      if X1 < FBeschriftungsBreite then
        X1 := FBeschriftungsBreite;
      if X2 - X1 < 2 then
        X2 := X1 + 2;

      if LBalken.Farbe <> 0 then
        LFarbe := LBalken.Farbe
      else
        LFarbe := StatusFarbe(LBalken.Status);

      Canvas.Brush.Color := LFarbe;
      Canvas.Brush.Style := bsSolid;
      Canvas.Pen.Color := clGray;
      // Gewuenschte Termine gestrichelt, belegte durchgezogen - damit man den
      // Unterschied auch ohne Farbe sieht (Ausdruck, Farbenblindheit)
      if LBalken.Status = gsGewuenscht then
        Canvas.Pen.Style := psDash
      else
        Canvas.Pen.Style := psSolid;
      Canvas.RoundRect(X1, Y + 3, X2, Y + FZeilenHoehe - 4, 5, 5);
      Canvas.Pen.Style := psSolid;

      LText := LBalken.Titel;
      if (LText <> '') and (X2 - X1 > 24) then
      begin
        Canvas.Brush.Style := bsClear;
        Canvas.TextRect(Rect(X1 + 5, Y + 4, X2 - 3, Y + FZeilenHoehe - 5),
          X1 + 5, Y + 5, LText);
      end;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Heisenberg', [TGanttPanel]);
end;

end.
