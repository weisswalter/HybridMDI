unit DataModuleForDelphi;

// Datenmodul mit den Eigenschaften, die der Designer beim Speichern ohnehin
// in die DFM schreibt. Ein TDataModule kennt sie nicht, der Streamer bricht
// dann beim Laden ab ("Ungueltiger Pfad fuer Eigenschaft"). Hier stehen sie
// als reine Ablage: sie werden gelesen und geschrieben, aber nirgends
// ausgewertet - ein Datenmodul hat weder Schrift noch Rand.
//
// WICHTIG bei Objekt-Eigenschaften (Margins, Font): Das Objekt muss im
// Konstruktor entstehen, sonst laeuft der Streamer beim Lesen von
// "Margins.Left" gegen nil. Und der Setter muss ASSIGN benutzen statt den
// Zeiger zu tauschen - sonst haengt die Eigenschaft danach an einem fremden
// Objekt, das jemand anders wieder freigibt.

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.Graphics;

type
  TSimpleMargins = class(TPersistent)
  private
    FLeft, FTop, FRight, FBottom: Integer;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Left: Integer read FLeft write FLeft default 0;
    property Top: Integer read FTop write FTop default 0;
    property Right: Integer read FRight write FRight default 0;
    property Bottom: Integer read FBottom write FBottom default 0;
  end;

  TDataModuleForDelphi = class(TDataModule)
  private
    FExplicitTop: Integer;
    FExplicitLeft: Integer;
    FExplicitHeight: Integer;
    FClientWidth: Integer;
    FStyleElements: TStyleElements;
    FOnCreate: TNotifyEvent;
    FExplicitWidth: Integer;
    FCaption: TCaption;
    FTextHeight: Integer;
    FClientHeight: Integer;
    FMargins: TSimpleMargins;
    FFont: TFont;
    FColor: TColor;
    FParentFont: Boolean;
    FPixelsPerInch: Integer;
    procedure SetMargins(const Value: TSimpleMargins);
    procedure SetFont(const Value: TFont);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property TextHeight: Integer read FTextHeight write FTextHeight;
    property ExplicitHeight: Integer read FExplicitHeight write FExplicitHeight;
    property ExplicitWidth: Integer read FExplicitWidth write FExplicitWidth;
    property ExplicitTop: Integer read FExplicitTop write FExplicitTop;
    property ExplicitLeft: Integer read FExplicitLeft write FExplicitLeft;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property StyleElements: TStyleElements read FStyleElements write FStyleElements;
    property ClientWidth: Integer read FClientWidth write FClientWidth;
    property ClientHeight: Integer read FClientHeight write FClientHeight;
    property Caption: TCaption read FCaption write FCaption;
    property PixelsPerInch: Integer read FPixelsPerInch write FPixelsPerInch;
    property Color: TColor read FColor write FColor default clBtnFace;
    property ParentFont: Boolean read FParentFont write FParentFont default False;
    // Objekt-Eigenschaften: siehe Kopfkommentar.
    property Margins: TSimpleMargins read FMargins write SetMargins;
    property Font: TFont read FFont write SetFont;
  end;

procedure Register;

implementation

{ TSimpleMargins }

procedure TSimpleMargins.Assign(Source: TPersistent);
begin
  if Source is TSimpleMargins then
  begin
    FLeft := TSimpleMargins(Source).Left;
    FTop := TSimpleMargins(Source).Top;
    FRight := TSimpleMargins(Source).Right;
    FBottom := TSimpleMargins(Source).Bottom;
  end
  else
    inherited Assign(Source);
end;

{ TDataModuleForDelphi }

constructor TDataModuleForDelphi.Create(AOwner: TComponent);
begin
  // Vor dem inherited: der geerbte Konstruktor laedt die DFM, und der
  // Streamer greift dabei schon auf Margins/Font zu.
  FMargins := TSimpleMargins.Create;
  FFont := TFont.Create;
  FColor := clBtnFace;
  inherited Create(AOwner);
end;

destructor TDataModuleForDelphi.Destroy;
begin
  inherited Destroy;
  FFont.Free;
  FMargins.Free;
end;

procedure TDataModuleForDelphi.SetMargins(const Value: TSimpleMargins);
begin
  FMargins.Assign(Value);
end;

procedure TDataModuleForDelphi.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure Register;
begin
  RegisterComponents('Heisenberg', [TDataModuleForDelphi]);
end;

end.
