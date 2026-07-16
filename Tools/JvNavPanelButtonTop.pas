unit JvNavPanelButtonTop;

// Ableitung von TJvNavPanelButton: Icon OBEN (zentriert), Text darunter
// (zentriert) � statt der im Original fest einprogrammierten Anordnung
// Icon-links/Text-rechts (JvNavigationPane.pas, PaintButton, "X := 4"
// ist hartkodiert, kein Layout-Property vorhanden).
//
// Farben/Hover/Down/Separator-Verhalten 1:1 vom Original uebernommen
// (siehe TJvNavPanelButton.PaintButton) � nur Icon-/Text-Platzierung
// ist anders. StyleManager/Colors/HotTrackFont funktionieren dadurch
// unveraendert weiter, keine Theme-Anbindung geht verloren.
//
// Verwendung: wie TJvNavPanelButton per Code erzeugen (siehe JVCL-Demo,
// TJvNavigationPane wird ebenfalls zur Laufzeit erzeugt), z.B.:
//   Btn := TJvNavPanelButtonTop.Create(Self);
//   Btn.Parent := Page;
//   Btn.Align := alTop;
//   Btn.Images := ilstRibbonLI;
//   Btn.ImageIndex := 0;
//   Btn.Action := cmdKunden;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Math,
  Vcl.Graphics, Vcl.Controls,
  JvNavigationPane, JvJVCLUtils, JvJCLUtils, Vcl.Buttons, JVButton;

type
  TJvNavPanelButtonTop = class(TJvNavPanelButton)
  private
    FPictLeft: Integer;
    FTextLeft: Integer;
    procedure SetPictLeft(const Value: Integer);
    procedure SetTextLeft(const Value: Integer);
  protected
    procedure PaintButton(Canvas: TCanvas); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    // -1 = automatisch zentriert (Standardverhalten). >=0 = fester Abstand
    // in Pixeln von der linken Innenkante (nach dem 4px-Innenabstand).
    property PictLeft: Integer read FPictLeft write SetPictLeft default -1;
    property TextLeft: Integer read FTextLeft write SetTextLeft default -1;
  end;

procedure Register;

implementation

const
  cAlignment: array[TAlignment] of DWORD = (DT_LEFT, DT_RIGHT, DT_CENTER);
  cWordWrap: array[Boolean] of DWORD = (DT_SINGLELINE, DT_WORDBREAK);

// Farbaufhellung fuer Disabled-Text � 1:1 aus dem Original kopiert
// (dort eine lokale Funktion in PaintButton, hier als eigenstaendige
// Funktion, weil wir nicht in dieselbe Methode schreiben).
function ColorBrightness(const AColor: TColor; const AChangeValue: Integer;
  ADestColor: TColor): TColor;
type
  TRGBColor = packed record
    case Boolean of
      True: (Color: TColor);
      False: (r, g, b, a: Byte);
  end;
var
  Rgb, RgbDest: TRGBColor;
begin
  Rgb.Color := ColorToRGB(AColor);
  RgbDest.Color := ColorToRGB(ADestColor);
  Rgb.r := Min(Max(Rgb.r - Round(AChangeValue * (Rgb.r - RgbDest.r) / 100), 0), $FF);
  Rgb.g := Min(Max(Rgb.g - Round(AChangeValue * (Rgb.g - RgbDest.g) / 100), 0), $FF);
  Rgb.b := Min(Max(Rgb.b - Round(AChangeValue * (Rgb.b - RgbDest.b) / 100), 0), $FF);
  Result := Rgb.Color;
end;

constructor TJvNavPanelButtonTop.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPictLeft := -1;
  FTextLeft := -1;
end;

procedure TJvNavPanelButtonTop.SetPictLeft(const Value: Integer);
begin
  if FPictLeft <> Value then
  begin
    FPictLeft := Value;
    Invalidate;
  end;
end;

procedure TJvNavPanelButtonTop.SetTextLeft(const Value: Integer);
begin
  if FTextLeft <> Value then
  begin
    FTextLeft := Value;
    Invalidate;
  end;
end;

procedure TJvNavPanelButtonTop.PaintButton(Canvas: TCanvas);
var
  R, TempRect: TRect;
  X, Y: Integer;
  HasImage: Boolean;
begin
  R := ClientRect;

  // Hintergrund/Hover/Down � unveraendert wie im Original
  if HotTrack and (bsMouseInside in MouseStates) then
  begin
    if bsMouseDown in MouseStates then
      GradientFillRect(Canvas, R, Colors.ButtonSelectedColorTo, Colors.ButtonSelectedColorFrom, fdTopToBottom, 32)
    else
      GradientFillRect(Canvas, R, Colors.ButtonHotColorFrom, Colors.ButtonHotColorTo, fdTopToBottom, 32);
  end
  else if Down then
    GradientFillRect(Canvas, R, Colors.ButtonSelectedColorFrom, Colors.ButtonSelectedColorTo, fdTopToBottom, 32)
  else if bsMouseDown in MouseStates then
    GradientFillRect(Canvas, R, Colors.ButtonSelectedColorTo, Colors.ButtonSelectedColorFrom, fdTopToBottom, 32)
  else
    GradientFillRect(Canvas, ClientRect, Colors.ButtonColorFrom, Colors.ButtonColorTo, fdTopToBottom, 32);

  InflateRect(R, -4, -4);

  // Icon oben; horizontal zentriert, ausser PictLeft ist explizit gesetzt
  HasImage := Assigned(Images) and (ImageIndex >= 0);
  if HasImage then
  begin
    if FPictLeft >= 0 then
      X := R.Left + FPictLeft
    else
      X := R.Left + (R.Right - R.Left - Images.Width) div 2;
    Y := R.Top;
    Images.Draw(Canvas, X, Y, ImageIndex);
    Inc(R.Top, Images.Height + 4);   // Text-Bereich beginnt unterhalb des Icons
  end;

  // Text zentriert unter dem Icon (statt rechts daneben wie im Original)
  if Caption <> '' then
  begin
    if HotTrack and (bsMouseInside in MouseStates) and not (bsMouseDown in MouseStates) then
      Canvas.Font := HotTrackFont
    else
      Canvas.Font := Font;
    SetBkMode(Canvas.Handle, TRANSPARENT);

    if not Enabled then
      Canvas.Font.Color := ColorBrightness(Font.Color, 75,
        Canvas.Pixels[(R.Right - R.Left) div 2, (R.Bottom - R.Top) div 2]);

    // TextLeft: fester Abstand von links, statt automatischer Ausrichtung
    if FTextLeft >= 0 then
      R.Left := ClientRect.Left + 4 + FTextLeft;

    TempRect := R;
//    DrawText(Canvas, Caption, Length(Caption), TempRect,
//      DT_CALCRECT or DT_CENTER or cWordWrap[WordWrap]);
//    if WordWrap then
//      OffsetRect(R, 0, ((R.Bottom - R.Top) - (TempRect.Bottom - TempRect.Top)) div 2);
//    DrawText(Canvas, Caption, Length(Caption), R,
//      DT_CENTER or cWordWrap[WordWrap]);
    DrawText(Canvas, Caption, Length(Caption), TempRect,
     DT_CALCRECT or cAlignment[Alignment] or cWordWrap[WordWrap] or DT_VCENTER);
    if WordWrap then
     OffsetRect(R, 0, ((R.Bottom - R.Top) - (TempRect.Bottom - TempRect.Top)) div 2);
    DrawText(Canvas, Caption, Length(Caption), R,
      cAlignment[Alignment] or cWordWrap[WordWrap] or DT_VCENTER);
  end;

  // Trennlinie � unveraendert wie im Original
  if Colors.ButtonSeparatorColor <> clNone then
  begin
    Canvas.Pen.Color := Colors.ButtonSeparatorColor;
    if Align = alBottom then
    begin
      Canvas.MoveTo(0, 0);
      Canvas.LineTo(Width + 1, 0);
    end
    else
    begin
      Canvas.MoveTo(0, ClientHeight - 1);
      Canvas.LineTo(Width + 1, ClientHeight - 1);
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Heisenberg', [TJvNavPanelButtonTop]);
end;

end.
