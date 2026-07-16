unit JvRibbonPanel;

// TJvRibbonPanel — Ausgangsbasis: pnlRibbon aus Unit2/frmMain, aber als
// wiederverwendbare Design-Time-Komponente statt Copy-Paste pro Formular.
//
// Aufbau (1:1 wie Unit2): die Komponente IST das pnlRibbon-Panel und haelt
// intern ein TPageControl (Style tsFlatButtons) mit unsichtbaren Tabs sowie
// eine Header-Leiste mit TJvNavPanelHeader-Buttons darueber.
//
//   Headers: TJvRibbonHeaderCollection   — ein Item = ein Header-Button
//     + genau ein zugehoeriges TTabSheet (wird automatisch angelegt/entfernt).
//   Buttons: TJvRibbonButtonCollection   — ein Item = eine Schaltflaeche
//     (Erster/Neu/Speichern/...), wird auf JEDES Tabsheet dupliziert
//     (identische Leiste pro Reiter, wie aktuell in PersonenFrm von Hand
//     gebaut). Klick liefert OnButtonClick(Sender, ATabIndex, AButtonTag).
//
// Naechster Schritt (17.07., noch offen): echte Design-Time-Collection-Editor-
// Verifikation in RAD Studio, ggf. Actions statt reiner Caption/Tag-Paare.

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.ExtCtrls,
  JvExControls, JvNavigationPane, JvNavPanelButtonTop;

type
  TJvRibbonPanel = class;

  TJvRibbonButtonClickEvent = procedure(Sender: TJvRibbonPanel;
    ATabIndex, AButtonTag: Integer) of object;

  // ── ein Header-Button + sein TabSheet ──────────────────────────────────
  TJvRibbonHeaderItem = class(TCollectionItem)
  private
    FCaption: string;
    FTabSheet: TTabSheet;   // intern verwaltet, nicht published
    FHeaderBtn: TJvNavPanelHeader;
    procedure SetCaption(const Value: string);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    property TabSheet: TTabSheet read FTabSheet;
  published
    property Caption: string read FCaption write SetCaption;
  end;

  TJvRibbonHeaderCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TJvRibbonHeaderItem;
    procedure SetItem(Index: Integer; const Value: TJvRibbonHeaderItem);
  public
    function Add: TJvRibbonHeaderItem;
    property Items[Index: Integer]: TJvRibbonHeaderItem read GetItem write SetItem; default;
  end;

  // ── eine Schaltflaeche, dupliziert auf jedes Tabsheet ──────────────────
  TJvRibbonButtonItem = class(TCollectionItem)
  private
    FCaption: string;
    FActionTag: Integer;
    procedure SetCaption(const Value: string);
    procedure SetActionTag(const Value: Integer);
  protected
    function GetDisplayName: string; override;
  published
    property Caption: string read FCaption write SetCaption;
    // frei waehlbare Kennung, die OnButtonClick zurueckbekommt
    // (analog TNavAktion-Tag in PersonenFrm.BtnNavClick).
    property ActionTag: Integer read FActionTag write SetActionTag default 0;
  end;

  TJvRibbonButtonCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TJvRibbonButtonItem;
    procedure SetItem(Index: Integer; const Value: TJvRibbonButtonItem);
  public
    function Add: TJvRibbonButtonItem;
    property Items[Index: Integer]: TJvRibbonButtonItem read GetItem write SetItem; default;
  end;

  TJvRibbonPanel = class(TCustomPanel)
  private
    FPageControl: TPageControl;
    FHeaderStrip: TPanel;
    FHeaders: TJvRibbonHeaderCollection;
    FButtons: TJvRibbonButtonCollection;
    FActiveTheme: TJvNavPanelTheme;
    FInactiveTheme: TJvNavPanelTheme;
    FStyleActive: TJvNavPaneStyleManager;
    FStyleInactive: TJvNavPaneStyleManager;
    FOnButtonClick: TJvRibbonButtonClickEvent;
    FUpdating: Boolean;
    procedure SetHeaders(const Value: TJvRibbonHeaderCollection);
    procedure SetButtons(const Value: TJvRibbonButtonCollection);
    procedure SetActiveTheme(const Value: TJvNavPanelTheme);
    procedure SetInactiveTheme(const Value: TJvNavPanelTheme);
    procedure HeaderClickInternal(Sender: TObject);
    procedure ButtonClickInternal(Sender: TObject);
    procedure RebuildAll;
    procedure BuildButtonBar(ATab: TTabSheet);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // von aussen aufrufbar: gehoerender Sender eines Klicks (Header oder
    // Button) zu Tabindex/Item aufloesen — z.B. fuer eigene Erweiterungen.
    function TabIndexOf(AHeaderItem: TJvRibbonHeaderItem): Integer;
  published
    property Headers: TJvRibbonHeaderCollection read FHeaders write SetHeaders;
    property Buttons: TJvRibbonButtonCollection read FButtons write SetButtons;
    property ActiveTheme: TJvNavPanelTheme read FActiveTheme write SetActiveTheme default nptXPBlue;
    property InactiveTheme: TJvNavPanelTheme read FInactiveTheme write SetInactiveTheme default nptXPSilver;
    property OnButtonClick: TJvRibbonButtonClickEvent read FOnButtonClick write FOnButtonClick;
    // gaengige TPanel/TWinControl-Properties re-publizieren
    property Align;
    property Anchors;
    property Color;
    property Constraints;
    property Font;
    property ParentColor;
    property ParentFont;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure Register;

implementation

{ TJvRibbonHeaderItem }

constructor TJvRibbonHeaderItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FCaption := Format('Reiter %d', [Index + 1]);
end;

function TJvRibbonHeaderItem.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else
    Result := inherited GetDisplayName;
end;

procedure TJvRibbonHeaderItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed(False);
  end;
end;

{ TJvRibbonHeaderCollection }

function TJvRibbonHeaderCollection.Add: TJvRibbonHeaderItem;
begin
  Result := TJvRibbonHeaderItem(inherited Add);
end;

function TJvRibbonHeaderCollection.GetItem(Index: Integer): TJvRibbonHeaderItem;
begin
  Result := TJvRibbonHeaderItem(inherited GetItem(Index));
end;

procedure TJvRibbonHeaderCollection.SetItem(Index: Integer; const Value: TJvRibbonHeaderItem);
begin
  inherited SetItem(Index, Value);
end;

{ TJvRibbonButtonItem }

function TJvRibbonButtonItem.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else
    Result := inherited GetDisplayName;
end;

procedure TJvRibbonButtonItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed(False);
  end;
end;

procedure TJvRibbonButtonItem.SetActionTag(const Value: Integer);
begin
  if FActionTag <> Value then
  begin
    FActionTag := Value;
    Changed(False);
  end;
end;

{ TJvRibbonButtonCollection }

function TJvRibbonButtonCollection.Add: TJvRibbonButtonItem;
begin
  Result := TJvRibbonButtonItem(inherited Add);
end;

function TJvRibbonButtonCollection.GetItem(Index: Integer): TJvRibbonButtonItem;
begin
  Result := TJvRibbonButtonItem(inherited GetItem(Index));
end;

procedure TJvRibbonButtonCollection.SetItem(Index: Integer; const Value: TJvRibbonButtonItem);
begin
  inherited SetItem(Index, Value);
end;

{ TJvRibbonPanel }

constructor TJvRibbonPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '';
  BevelOuter := bvNone;
  ParentBackground := False;

  FActiveTheme   := nptXPBlue;
  FInactiveTheme := nptXPSilver;

  FStyleActive := TJvNavPaneStyleManager.Create(Self);
  FStyleActive.Theme := FActiveTheme;
  FStyleInactive := TJvNavPaneStyleManager.Create(Self);
  FStyleInactive.Theme := FInactiveTheme;

  FHeaderStrip := TPanel.Create(Self);
  FHeaderStrip.Parent     := Self;
  FHeaderStrip.Align      := alTop;
  FHeaderStrip.Height     := 31;
  FHeaderStrip.BevelOuter := bvNone;
  FHeaderStrip.Caption    := '';

  FPageControl := TPageControl.Create(Self);
  FPageControl.Parent := Self;
  FPageControl.Align  := alClient;
  FPageControl.Style  := tsFlatButtons;

  FHeaders := TJvRibbonHeaderCollection.Create(Self, TJvRibbonHeaderItem);
  FButtons := TJvRibbonButtonCollection.Create(Self, TJvRibbonButtonItem);
end;

destructor TJvRibbonPanel.Destroy;
begin
  FHeaders.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TJvRibbonPanel.Loaded;
begin
  inherited Loaded;
  RebuildAll;
end;

procedure TJvRibbonPanel.SetHeaders(const Value: TJvRibbonHeaderCollection);
begin
  FHeaders.Assign(Value);
  RebuildAll;
end;

procedure TJvRibbonPanel.SetButtons(const Value: TJvRibbonButtonCollection);
begin
  FButtons.Assign(Value);
  RebuildAll;
end;

procedure TJvRibbonPanel.SetActiveTheme(const Value: TJvNavPanelTheme);
begin
  if FActiveTheme <> Value then
  begin
    FActiveTheme := Value;
    FStyleActive.Theme := Value;
  end;
end;

procedure TJvRibbonPanel.SetInactiveTheme(const Value: TJvNavPanelTheme);
begin
  if FInactiveTheme <> Value then
  begin
    FInactiveTheme := Value;
    FStyleInactive.Theme := Value;
    RebuildAll;  // inaktive Header muessen das neue Theme sofort zeigen
  end;
end;

function TJvRibbonPanel.TabIndexOf(AHeaderItem: TJvRibbonHeaderItem): Integer;
begin
  Result := AHeaderItem.Index;
end;

// Baut Header-Leiste + Tabsheets + Buttonleisten komplett aus den beiden
// Collections neu auf. Einfach gehalten (kompletter Rebuild statt
// Feindifferenzierung) — bei den ueblichen Groessenordnungen (< 20 Tabs/
// Buttons) unproblematisch, siehe ToDo fuer Feinschliff.
procedure TJvRibbonPanel.RebuildAll;
var
  I: Integer;
  LItem: TJvRibbonHeaderItem;
  LBtn: TJvNavPanelHeader;
begin
  if FUpdating or (csLoading in ComponentState) then
    Exit;
  FUpdating := True;
  try
    // alte Header-Buttons und Tabsheets wegwerfen
    for I := FHeaderStrip.ControlCount - 1 downto 0 do
      FHeaderStrip.Controls[I].Free;
    for I := FPageControl.PageCount - 1 downto 0 do
      FPageControl.Pages[I].Free;

    for I := 0 to FHeaders.Count - 1 do
    begin
      LItem := FHeaders[I];

      LItem.FTabSheet := TTabSheet.Create(Self);
      LItem.FTabSheet.PageControl := FPageControl;
      LItem.FTabSheet.Caption     := LItem.Caption;
      LItem.FTabSheet.TabVisible  := False;

      BuildButtonBar(LItem.FTabSheet);

      LBtn := TJvNavPanelHeader.Create(Self);
      LBtn.Parent     := FHeaderStrip;
      LBtn.Tag        := I;
      LBtn.Caption    := LItem.Caption;
      LBtn.Alignment  := taCenter;
      LBtn.Align      := alLeft;
      LBtn.Width      := 94;
      LBtn.StyleManager := FStyleInactive;
      LBtn.ParentStyleManager := False;
      LBtn.OnClick    := HeaderClickInternal;
      LItem.FHeaderBtn := LBtn;
    end;

    if FHeaders.Count > 0 then
    begin
      FPageControl.ActivePageIndex := 0;
      FHeaders[0].FHeaderBtn.StyleManager := FStyleActive;
    end;
  finally
    FUpdating := False;
  end;
end;

// Eine identische Buttonleiste (aus FButtons) auf das uebergebene Tabsheet
// duplizieren — analog den 9 TJvNavPanelButtonTop je Tabsheet in PersonenFrm.
procedure TJvRibbonPanel.BuildButtonBar(ATab: TTabSheet);
var
  I: Integer;
  LBar: TPanel;
  LBtn: TJvNavPanelButtonTop;
  LSrc: TJvRibbonButtonItem;
begin
  LBar := TPanel.Create(Self);
  LBar.Parent     := ATab;
  LBar.Align      := alTop;
  LBar.Height     := 38;
  LBar.BevelOuter := bvNone;
  LBar.Caption    := '';

  for I := 0 to FButtons.Count - 1 do
  begin
    LSrc := FButtons[I];
    LBtn := TJvNavPanelButtonTop.Create(Self);
    LBtn.Parent     := LBar;
    LBtn.Tag        := LSrc.ActionTag;
    LBtn.Caption    := LSrc.Caption;
    LBtn.Alignment  := taCenter;
    LBtn.Align      := alLeft;
    LBtn.Width      := 64;
    LBtn.StyleManager := FStyleActive;
    LBtn.ParentStyleManager := False;
    LBtn.OnClick    := ButtonClickInternal;
  end;
end;

procedure TJvRibbonPanel.HeaderClickInternal(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FHeaders.Count - 1 do
    FHeaders[I].FHeaderBtn.StyleManager := FStyleInactive;
  (Sender as TJvNavPanelHeader).StyleManager := FStyleActive;
  FPageControl.ActivePageIndex := (Sender as TJvNavPanelHeader).Tag;
end;

procedure TJvRibbonPanel.ButtonClickInternal(Sender: TObject);
var
  LTabIndex: Integer;
begin
  if Assigned(FOnButtonClick) then
  begin
    LTabIndex := ((Sender as TControl).Parent.Parent as TTabSheet).PageIndex;
    FOnButtonClick(Self, LTabIndex, (Sender as TComponent).Tag);
  end;
end;

procedure Register;
begin
  RegisterComponents('Heisenberg', [TJvRibbonPanel]);
end;

end.
