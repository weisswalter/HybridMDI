unit RibbonPanel;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  RibbonPageControl, JvGradient, JvTypes, JvNavPanelButtonTop, JvNavigationPane;

type
  TRibbonPanel = class;

  // ── Event-Typ für Button-Klicks ──────────────────────────────────────
  TRibbonButtonClickEvent = procedure(Sender: TRibbonPanel; AButtonTag: Integer) of object;

  // ── Einzelner Header-Button gekoppelt an ein TabSheet ────────────────
  TRibbonHeaderButton = class(TCollectionItem)
  private
    FCaption: string;
    FVisible: Boolean;
    FWidth: Integer;
    FTabSheet: TTabSheet;

    procedure SetCaption(const Value: string);
    procedure SetVisible(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
    procedure CreateInternalTabSheet;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    // WICHTIG: TabSheet MUSS in PUBLIC stehen (nicht published),
    // um den EReadError beim DFM-Laden zu verhindern!
    property TabSheet: TTabSheet read FTabSheet write FTabSheet;
  published
    property Caption: string read FCaption write SetCaption;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read FWidth write SetWidth default 0;
  end;

  // ── Collection der Header-Buttons ───────────────────────────────────
  TRibbonHeaderButtonCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TRibbonHeaderButton;
    procedure SetItem(Index: Integer; const Value: TRibbonHeaderButton);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TRibbonHeaderButton;
    property Items[Index: Integer]: TRibbonHeaderButton read GetItem write SetItem; default;
  end;

  // ── Das Hauptpanel ───────────────────────────────────────────────────
  TRibbonPanel = class(TPanel)
  private
    FTopPanel: TPanel;
    FHeaderGradient: TJvGradient;
    FPageControl: TRibbonPageControl;
    FHeaderButtons: TRibbonHeaderButtonCollection;
    FActivePageIndex: Integer;
    FOnButtonClick: TRibbonButtonClickEvent;

    FStyleActive: TJvNavPaneStyleManager;
    FStyleInactive: TJvNavPaneStyleManager;
    FActiveTheme: TJvNavPanelTheme;
    FInactiveTheme: TJvNavPanelTheme;

    procedure SetHeaderButtons(const Value: TRibbonHeaderButtonCollection);
    procedure SetActivePageIndex(const Value: Integer);
    procedure SetActiveTheme(const Value: TJvNavPanelTheme);
    procedure SetInactiveTheme(const Value: TJvNavPanelTheme);
    procedure ButtonClickInternal(Sender: TObject);
    procedure ClearGeneratedButtons;
    procedure RebuildButtons;
    procedure ApplyActivePage;
    procedure ApplyHeaderGradientColors;
    procedure ReconnectLoadedTabSheets;
  protected
    procedure Loaded; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property TopPanel: TPanel read FTopPanel;
    property PageControl: TRibbonPageControl read FPageControl;
    property HeaderButtons: TRibbonHeaderButtonCollection read FHeaderButtons write SetHeaderButtons;
    property ActivePageIndex: Integer read FActivePageIndex write SetActivePageIndex default 0;
    // Theme des ausgewaehlten Reiters bzw. der uebrigen Reiter. Der Verlauf
    // hinter der Reiterleiste nimmt die Farben des INAKTIVEN Themes, damit
    // der freie Platz rechts nahtlos an die inaktiven Reiter anschliesst.
    property ActiveTheme: TJvNavPanelTheme read FActiveTheme write SetActiveTheme default nptXPBlue;
    property InactiveTheme: TJvNavPanelTheme read FInactiveTheme write SetInactiveTheme default nptXPSilver;
    property OnButtonClick: TRibbonButtonClickEvent read FOnButtonClick write FOnButtonClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Heisenberg', [TRibbonPanel]);
end;

{ TRibbonHeaderButton }

constructor TRibbonHeaderButton.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FVisible := True;
  FWidth := 0;
  FCaption := 'Tab ' + IntToStr(Index);
  CreateInternalTabSheet;
end;

procedure TRibbonHeaderButton.CreateInternalTabSheet;
var
  LParent: TRibbonPanel;
  LBaseName: string;
  LOwner: TComponent;
begin
  if Assigned(Collection) and (Collection.Owner is TRibbonPanel) then
  begin
    LParent := TRibbonPanel(Collection.Owner);

    // Nicht neu anlegen, wenn Delphi das Formular gerade aus der DFM lädt
    if (csLoading in LParent.ComponentState) then
      Exit;

    if not Assigned(FTabSheet) then
    begin
      if Assigned(LParent.Owner) then
        LOwner := LParent.Owner
      else
        LOwner := LParent;

      FTabSheet := TTabSheet.Create(LOwner);
      FTabSheet.SetSubComponent(True);
      FTabSheet.Caption := FCaption;

      if LParent.Name <> '' then
        LBaseName := LParent.Name
      else
        LBaseName := 'RibbonPanel';

      FTabSheet.Name := LBaseName + '_TabSheet' + IntToStr(Index);

      if Assigned(LParent.PageControl) then
        FTabSheet.PageControl := TPageControl(LParent.PageControl);
    end;
  end;
end;

destructor TRibbonHeaderButton.Destroy;
begin
  if Assigned(FTabSheet) then
  begin
    // Raeumt der Owner (das Formular) gerade ab, gibt er das TabSheet selbst
    // frei. Ein eigenes Free zwingt das PageControl hier zum Neuausrichten,
    // obwohl das Fensterhandle schon weg ist -> "has no parent window".
    if not (Assigned(FTabSheet.Owner) and
            (csDestroying in FTabSheet.Owner.ComponentState)) then
      FTabSheet.Free;
    FTabSheet := nil;
  end;
  inherited Destroy;
end;

procedure TRibbonHeaderButton.Assign(Source: TPersistent);
begin
  if Source is TRibbonHeaderButton then
  begin
    Caption := TRibbonHeaderButton(Source).Caption;
    Visible := TRibbonHeaderButton(Source).Visible;
    Width   := TRibbonHeaderButton(Source).Width;
  end;
  inherited Assign(Source);
end;

function TRibbonHeaderButton.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else
    Result := inherited GetDisplayName;
end;

procedure TRibbonHeaderButton.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    if Assigned(FTabSheet) then
      FTabSheet.Caption := Value;
    Changed(False);
  end;
end;

procedure TRibbonHeaderButton.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if Assigned(FTabSheet) then
      FTabSheet.TabVisible := Value;
    Changed(False);
  end;
end;

procedure TRibbonHeaderButton.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed(False);
  end;
end;

{ TRibbonHeaderButtonCollection }

function TRibbonHeaderButtonCollection.Add: TRibbonHeaderButton;
begin
  Result := TRibbonHeaderButton(inherited Add);
end;

function TRibbonHeaderButtonCollection.GetItem(Index: Integer): TRibbonHeaderButton;
begin
  Result := TRibbonHeaderButton(inherited GetItem(Index));
end;

procedure TRibbonHeaderButtonCollection.SetItem(Index: Integer; const Value: TRibbonHeaderButton);
begin
  inherited SetItem(Index, Value);
end;

procedure TRibbonHeaderButtonCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if GetOwner is TRibbonPanel then
    TRibbonPanel(GetOwner).RebuildButtons;
end;

{ TRibbonPanel }

constructor TRibbonPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  BevelOuter := bvNone;
  ShowCaption := False;
  Width := 400;
  Height := 200;

  // 0. Themes: aktiver Reiter blau, uebrige silbern
  FActiveTheme := nptXPBlue;
  FInactiveTheme := nptXPSilver;
  FStyleActive := TJvNavPaneStyleManager.Create(Self);
  FStyleActive.Theme := FActiveTheme;
  FStyleInactive := TJvNavPaneStyleManager.Create(Self);
  FStyleInactive.Theme := FInactiveTheme;

  // 1. RibbonPageControl
  FPageControl := TRibbonPageControl.Create(Self);
  FPageControl.Name := 'PageControl';
  FPageControl.SetSubComponent(True);
  FPageControl.Parent := Self;
  FPageControl.Align := alNone;
  FPageControl.Left := -1;
  FPageControl.Top := 29;
  FPageControl.Width := Self.Width + 2;
  FPageControl.Height := Self.Height - 28;
  FPageControl.Anchors := [akLeft, akTop, akRight, akBottom];

  // 2. Oberes Panel für die Header-Buttons
  FTopPanel := TPanel.Create(Self);
  FTopPanel.Name := 'TopPanel';
  FTopPanel.SetSubComponent(True);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 31;
  FTopPanel.BevelOuter := bvNone;
  FTopPanel.ShowCaption := False;

  // 3. Farbverlauf im TopPanel
  FHeaderGradient := TJvGradient.Create(Self);
  FHeaderGradient.Parent := FTopPanel;
  FHeaderGradient.Align  := alClient;
  FHeaderGradient.Style  := grVertical;
  ApplyHeaderGradientColors;

  // 4. Header-Buttons Collection
  FHeaderButtons := TRibbonHeaderButtonCollection.Create(Self, TRibbonHeaderButton);

  FTopPanel.BringToFront;
end;

procedure TRibbonPanel.ApplyHeaderGradientColors;
begin
  if not Assigned(FHeaderGradient) or not Assigned(FStyleInactive) then
    Exit;
  FHeaderGradient.StartColor := FStyleInactive.Colors.HeaderColorFrom;
  FHeaderGradient.EndColor   := FStyleInactive.Colors.HeaderColorTo;
end;

procedure TRibbonPanel.SetActiveTheme(const Value: TJvNavPanelTheme);
begin
  if FActiveTheme <> Value then
  begin
    FActiveTheme := Value;
    FStyleActive.Theme := Value;
    Invalidate;
  end;
end;

procedure TRibbonPanel.SetInactiveTheme(const Value: TJvNavPanelTheme);
begin
  if FInactiveTheme <> Value then
  begin
    FInactiveTheme := Value;
    FStyleInactive.Theme := Value;
    ApplyHeaderGradientColors;
    Invalidate;
  end;
end;

destructor TRibbonPanel.Destroy;
begin
  FHeaderButtons.Free;
  inherited Destroy;
end;

procedure TRibbonPanel.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  inherited GetChildren(Proc, Root);
  if Assigned(FHeaderButtons) then
  begin
    for I := 0 to FHeaderButtons.Count - 1 do
    begin
      if Assigned(FHeaderButtons[I].TabSheet) then
        Proc(FHeaderButtons[I].TabSheet);
    end;
  end;
end;

procedure TRibbonPanel.Loaded;
begin
  inherited Loaded;
  ReconnectLoadedTabSheets;
  RebuildButtons;
end;

// Die TabSheets stehen in der DFM als Kinder des RibbonPanels (so meldet sie
// GetChildren beim Schreiben). Der Reader haengt sie deshalb an das Panel und
// nicht an das PageControl, und die Zuordnung zum Collection-Item geht dabei
// verloren, weil TabSheet nicht published ist. Ohne diese Reparatur bleibt
// FTabSheet nil und RebuildButtons erzeugt einen zweiten, leeren Satz Seiten.
procedure TRibbonPanel.ReconnectLoadedTabSheets;
var
  I: Integer;
  LNext: Integer;
  LSheets: array of TTabSheet;
begin
  // Erst einsammeln: das Umhaengen unten veraendert die Controls-Liste.
  SetLength(LSheets, 0);
  for I := 0 to ControlCount - 1 do
    if Controls[I] is TTabSheet then
    begin
      SetLength(LSheets, Length(LSheets) + 1);
      LSheets[High(LSheets)] := TTabSheet(Controls[I]);
    end;

  LNext := 0;
  for I := 0 to FHeaderButtons.Count - 1 do
  begin
    if LNext > High(LSheets) then
      Break;
    if not Assigned(FHeaderButtons[I].TabSheet) then
    begin
      FHeaderButtons[I].TabSheet := LSheets[LNext];
      if Assigned(FPageControl) then
        LSheets[LNext].PageControl := TPageControl(FPageControl);
      Inc(LNext);
    end;
  end;
end;

procedure TRibbonPanel.SetHeaderButtons(const Value: TRibbonHeaderButtonCollection);
begin
  FHeaderButtons.Assign(Value);
  RebuildButtons;
end;

procedure TRibbonPanel.SetActivePageIndex(const Value: Integer);
begin
  if (Value >= 0) and (Value < FHeaderButtons.Count) then
  begin
    FActivePageIndex := Value;
    ApplyActivePage;
  end;
end;

procedure TRibbonPanel.ButtonClickInternal(Sender: TObject);
var
  LIndex: Integer;
begin
  if Sender is TComponent then
  begin
    LIndex := TComponent(Sender).Tag;
    SetActivePageIndex(LIndex);

    if Assigned(FOnButtonClick) then
      FOnButtonClick(Self, LIndex);
  end;
end;

procedure TRibbonPanel.ClearGeneratedButtons;
var
  I: Integer;
  LControl: TControl;
begin
  if not Assigned(FTopPanel) then
    Exit;

  for I := FTopPanel.ControlCount - 1 downto 0 do
  begin
    LControl := FTopPanel.Controls[I];
    if LControl is TJvNavPanelButtonTop then
    begin
      LControl.Parent := nil;
      LControl.Free;
    end;
  end;
end;

procedure TRibbonPanel.ApplyActivePage;
var
  I: Integer;
  LControl: TControl;
begin
  if FHeaderButtons.Count = 0 then
    Exit;

  if FActivePageIndex >= FHeaderButtons.Count then
    FActivePageIndex := FHeaderButtons.Count - 1;
  if FActivePageIndex < 0 then
    FActivePageIndex := 0;

  // 1. Aktiven Reiter hervorheben: er bekommt das aktive Theme, alle anderen
  // das inaktive - so macht es auch das alte TJvRibbonPanel. Ueber Down geht
  // das NICHT: TJvCustomGraphicButton.SetDown verwirft die Zuweisung, solange
  // GroupIndex = 0 ist (Vorgabe), die Reiter blieben dadurch alle gleich.
  for I := 0 to FTopPanel.ControlCount - 1 do
  begin
    LControl := FTopPanel.Controls[I];
    if LControl is TJvNavPanelButtonTop then
    begin
      if LControl.Tag = FActivePageIndex then
        TJvNavPanelButtonTop(LControl).StyleManager := FStyleActive
      else
        TJvNavPanelButtonTop(LControl).StyleManager := FStyleInactive;
    end;
  end;

  // 2. Das native TabSheet im PageControl aktivieren
  if Assigned(FPageControl) then
  begin
    FPageControl.ActivePageIndex := FActivePageIndex;
  end;
end;

procedure TRibbonPanel.RebuildButtons;
var
  I: Integer;
  LBtn: TJvNavPanelButtonTop;
  LSrc: TRibbonHeaderButton;
  LNextLeft: Integer;
  LWidth: Integer;
begin
  ClearGeneratedButtons;

  LNextLeft := 0;
  for I := 0 to FHeaderButtons.Count - 1 do
  begin
    LSrc := FHeaderButtons[I];

    // TabSheet sicherstellen
    if not Assigned(LSrc.TabSheet) then
      LSrc.CreateInternalTabSheet;

    // Sicherstellen, dass das TabSheet dem PageControl zugeordnet ist
    if Assigned(LSrc.TabSheet) and Assigned(FPageControl) then
    begin
      if LSrc.TabSheet.PageControl <> TPageControl(FPageControl) then
        LSrc.TabSheet.PageControl := TPageControl(FPageControl);
    end;

    // Header-Button neu erzeugen
    LBtn := TJvNavPanelButtonTop.Create(Self);
    LBtn.Parent := FTopPanel;
    LBtn.ParentFont := True;
    LBtn.Alignment := taCenter;
    // Reiter werden im inaktiven Theme gezeichnet; der ausgewaehlte hebt
    // sich ueber Down ab (siehe ApplyActivePage).
    LBtn.StyleManager := FStyleInactive;
    LBtn.ParentStyleManager := False;
    LBtn.Visible := LSrc.Visible;
    LBtn.Tag := I;
    LBtn.Caption := LSrc.Caption;
    LBtn.OnClick := ButtonClickInternal;

    if LSrc.Width > 0 then
      LWidth := LSrc.Width
    else
      LWidth := 64;

    LBtn.Left := LNextLeft;
    LBtn.Top := 0;
    LBtn.Width := LWidth;
    LBtn.Height := FTopPanel.Height;
    LBtn.Anchors := [akLeft, akTop, akBottom];

    if LSrc.Visible then
      Inc(LNextLeft, LWidth);
  end;

  ApplyActivePage;
end;

end.
