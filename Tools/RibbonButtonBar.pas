unit RibbonButtonBar;

// Eigenstaendige Buttonleiste zum Platzieren auf einer Seite (Tabsheet).
//
// Bewusst getrennt vom TRibbonPanel-Header: nicht jede Seite braucht Buttons
// (VirtualStringTree, Gantt), und wo welche gebraucht werden, sollen sie zur
// Seite gehoeren statt zum Ribbon.
//
// Die Buttons werden ausschliesslich ueber Actions gesteuert - die Leiste hat
// absichtlich kein eigenes Klick-Ereignis. Caption, Hint, Enabled, ImageIndex
// und die Ausfuehrung kommen alle von der zugewiesenen Action.
//
// Die Buttons gehoeren der Leiste (Owner = Self) und haben keinen Namen. Damit
// meldet TWinControl.GetChildren sie nicht an den DFM-Writer (der schreibt nur
// Controls, deren Owner das Formular ist) - sie landen also nie in der DFM und
// koennen dort auch nichts kaputt machen.

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.ImgList, Data.DB, JvGradient, JvTypes, JvNavPanelButtonTop, JvNavigationPane;

const
  cDefaultButtonWidth = 64;
  cDefaultBarHeight = 48;
  // Gleiche Werte wie im alten TJvRibbonPanel, damit die Leisten optisch
  // identisch bleiben
  cDefGradientStart = TColor(16245453);
  cDefGradientEnd   = TColor(15966336);

type
  TRibbonButtonBar = class;

  // ── Ein Button der Leiste, gesteuert ueber eine Action ───────────────
  TRibbonBarButton = class(TCollectionItem)
  private
    FAction: TBasicAction;
    FVisible: Boolean;
    FWidth: Integer;
    FButton: TJvNavPanelButtonTop;

    function GetBar: TRibbonButtonBar;
    procedure SetAction(const Value: TBasicAction);
    procedure SetVisible(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;

    // Der erzeugte Button - nur lesend, damit man ihn zur Laufzeit erreicht
    // (z.B. fuer Down). Nicht published: gehoert nicht in die DFM.
    property Button: TJvNavPanelButtonTop read FButton;
  published
    property Action: TBasicAction read FAction write SetAction;
    property Visible: Boolean read FVisible write SetVisible default True;
    // 0 = ButtonWidth der Leiste verwenden
    property Width: Integer read FWidth write SetWidth default 0;
  end;

  // ── Collection der Buttons ──────────────────────────────────────────
  TRibbonBarButtonCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TRibbonBarButton;
    procedure SetItem(Index: Integer; const Value: TRibbonBarButton);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TRibbonBarButton;
    property Items[Index: Integer]: TRibbonBarButton read GetItem write SetItem; default;
  end;

  // ── Die Leiste ──────────────────────────────────────────────────────
  TRibbonButtonBar = class(TPanel)
  private
    FGradient: TJvGradient;
    FButtons: TRibbonBarButtonCollection;
    FImages: TCustomImageList;
    FButtonWidth: Integer;
    FButtonSpacing: Integer;
    FStyle: TJvNavPaneStyleManager;
    FTheme: TJvNavPanelTheme;
    FGradientStartColor: TColor;
    FGradientEndColor: TColor;
    FDataSource: TDataSource;

    procedure SetButtons(const Value: TRibbonBarButtonCollection);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetButtonWidth(const Value: Integer);
    procedure SetButtonSpacing(const Value: Integer);
    procedure SetTheme(const Value: TJvNavPanelTheme);
    procedure SetGradientStartColor(const Value: TColor);
    procedure SetGradientEndColor(const Value: TColor);
    procedure SetDataSource(const Value: TDataSource);
    procedure ApplyGradientColors;
    procedure ClearGeneratedButtons;
    procedure RebuildButtons;
    procedure UpdateButtonBounds;
  protected
    procedure Loaded; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    // Farbverlauf im Hintergrund - fuellt die Leiste ueber die volle Breite
    property Gradient: TJvGradient read FGradient;
    property Buttons: TRibbonBarButtonCollection read FButtons write SetButtons;
    property Images: TCustomImageList read FImages write SetImages;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default cDefaultButtonWidth;
    property ButtonSpacing: Integer read FButtonSpacing write SetButtonSpacing default 0;
    // Theme der Buttons - entspricht dem ActiveTheme des Ribbons
    property Theme: TJvNavPanelTheme read FTheme write SetTheme default nptXPBlue;
    property GradientStartColor: TColor read FGradientStartColor
      write SetGradientStartColor default cDefGradientStart;
    property GradientEndColor: TColor read FGradientEndColor
      write SetGradientEndColor default cDefGradientEnd;
    // Sagt, welche DataSource diese Leiste bedient (Walter, 06.08.2026).
    // Die Buttons feuern weiterhin ausschliesslich ueber ihre Action - die
    // Leiste selbst fuehrt nichts aus. Der Zweck von DataSource ist, dass
    // ein gemeinsamer Action-Handler (z.B. TfrmGuiTemplate.ActionRechtsExecute)
    // ueber TAction.ActionList.Tag die richtige Gruppe findet und dann auf
    // der Ribbon-Seite nach der Leiste mit passendem Tag sucht, um an deren
    // DataSource zu kommen - ohne dass jedes Modul GetDetailDataSource
    // ueberschreiben muss.
    property DataSource: TDataSource read FDataSource write SetDataSource;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Heisenberg', [TRibbonButtonBar]);
end;

{ TRibbonBarButton }

constructor TRibbonBarButton.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FVisible := True;
  FWidth := 0;
end;

function TRibbonBarButton.GetBar: TRibbonButtonBar;
begin
  if Assigned(Collection) and (Collection.Owner is TRibbonButtonBar) then
    Result := TRibbonButtonBar(Collection.Owner)
  else
    Result := nil;
end;

function TRibbonBarButton.GetDisplayName: string;
begin
  if Assigned(FAction) and (FAction is TComponent) then
    Result := TComponent(FAction).Name
  else
    Result := inherited GetDisplayName;
end;

procedure TRibbonBarButton.SetAction(const Value: TBasicAction);
var
  LBar: TRibbonButtonBar;
begin
  if FAction <> Value then
  begin
    LBar := GetBar;
    // Damit die Referenz genullt wird, wenn die Action geloescht wird
    if Assigned(Value) and Assigned(LBar) then
      Value.FreeNotification(LBar);
    FAction := Value;
    Changed(False);
  end;
end;

procedure TRibbonBarButton.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(False);
  end;
end;

procedure TRibbonBarButton.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed(False);
  end;
end;

procedure TRibbonBarButton.Assign(Source: TPersistent);
begin
  if Source is TRibbonBarButton then
  begin
    Action  := TRibbonBarButton(Source).Action;
    Visible := TRibbonBarButton(Source).Visible;
    Width   := TRibbonBarButton(Source).Width;
  end
  else
    inherited Assign(Source);
end;

{ TRibbonBarButtonCollection }

function TRibbonBarButtonCollection.Add: TRibbonBarButton;
begin
  Result := TRibbonBarButton(inherited Add);
end;

function TRibbonBarButtonCollection.GetItem(Index: Integer): TRibbonBarButton;
begin
  Result := TRibbonBarButton(inherited GetItem(Index));
end;

procedure TRibbonBarButtonCollection.SetItem(Index: Integer; const Value: TRibbonBarButton);
begin
  inherited SetItem(Index, Value);
end;

procedure TRibbonBarButtonCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if GetOwner is TRibbonButtonBar then
    TRibbonButtonBar(GetOwner).RebuildButtons;
end;

{ TRibbonButtonBar }

constructor TRibbonButtonBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  BevelOuter := bvNone;
  ShowCaption := False;
  FButtonWidth := cDefaultButtonWidth;
  FButtonSpacing := 0;
  Width := 400;
  Height := cDefaultBarHeight;

  FTheme := nptXPBlue;
  FStyle := TJvNavPaneStyleManager.Create(Self);
  FStyle.Theme := FTheme;
  FGradientStartColor := cDefGradientStart;
  FGradientEndColor := cDefGradientEnd;

  // Zuerst der Verlauf: beide sind TJvGraphicControl, die Zeichenreihenfolge
  // ergibt sich aus der Reihenfolge in Controls - der Verlauf liegt damit
  // hinter den spaeter erzeugten Buttons.
  FGradient := TJvGradient.Create(Self);
  FGradient.Name := 'Gradient';
  FGradient.SetSubComponent(True);
  FGradient.Parent := Self;
  FGradient.Align := alClient;
  FGradient.Style := grVertical;
  ApplyGradientColors;

  FButtons := TRibbonBarButtonCollection.Create(Self, TRibbonBarButton);
end;

procedure TRibbonButtonBar.ApplyGradientColors;
begin
  if not Assigned(FGradient) then
    Exit;
  FGradient.StartColor := FGradientStartColor;
  FGradient.EndColor := FGradientEndColor;
end;

procedure TRibbonButtonBar.SetTheme(const Value: TJvNavPanelTheme);
begin
  if FTheme <> Value then
  begin
    FTheme := Value;
    FStyle.Theme := Value;
    Invalidate;
  end;
end;

procedure TRibbonButtonBar.SetGradientStartColor(const Value: TColor);
begin
  if FGradientStartColor <> Value then
  begin
    FGradientStartColor := Value;
    ApplyGradientColors;
  end;
end;

procedure TRibbonButtonBar.SetGradientEndColor(const Value: TColor);
begin
  if FGradientEndColor <> Value then
  begin
    FGradientEndColor := Value;
    ApplyGradientColors;
  end;
end;

destructor TRibbonButtonBar.Destroy;
begin
  FreeAndNil(FButtons);
  inherited Destroy;
end;

procedure TRibbonButtonBar.Loaded;
begin
  inherited Loaded;
  RebuildButtons;
end;

procedure TRibbonButtonBar.Resize;
begin
  inherited Resize;
  // Die Buttons sind immer so hoch wie die Leiste
  UpdateButtonBounds;
end;

procedure TRibbonButtonBar.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
    if AComponent = FImages then
      SetImages(nil);
    if AComponent = FDataSource then
      FDataSource := nil;
    if Assigned(FButtons) and (AComponent is TBasicAction) then
      for I := 0 to FButtons.Count - 1 do
        if FButtons[I].Action = AComponent then
          FButtons[I].Action := nil;
  end;
end;

procedure TRibbonButtonBar.SetDataSource(const Value: TDataSource);
begin
  if FDataSource <> Value then
  begin
    if Assigned(Value) then
      Value.FreeNotification(Self);
    FDataSource := Value;
  end;
end;

procedure TRibbonButtonBar.SetButtons(const Value: TRibbonBarButtonCollection);
begin
  FButtons.Assign(Value);
  RebuildButtons;
end;

procedure TRibbonButtonBar.SetImages(const Value: TCustomImageList);
begin
  if FImages <> Value then
  begin
    if Assigned(Value) then
      Value.FreeNotification(Self);
    FImages := Value;
    RebuildButtons;
  end;
end;

procedure TRibbonButtonBar.SetButtonWidth(const Value: Integer);
begin
  if (FButtonWidth <> Value) and (Value > 0) then
  begin
    FButtonWidth := Value;
    UpdateButtonBounds;
  end;
end;

procedure TRibbonButtonBar.SetButtonSpacing(const Value: Integer);
begin
  if (FButtonSpacing <> Value) and (Value >= 0) then
  begin
    FButtonSpacing := Value;
    UpdateButtonBounds;
  end;
end;

procedure TRibbonButtonBar.ClearGeneratedButtons;
var
  I: Integer;
  LControl: TControl;
begin
  for I := ControlCount - 1 downto 0 do
  begin
    LControl := Controls[I];
    if LControl is TJvNavPanelButtonTop then
    begin
      LControl.Parent := nil;
      LControl.Free;
    end;
  end;

  if Assigned(FButtons) then
    for I := 0 to FButtons.Count - 1 do
      FButtons[I].FButton := nil;
end;

procedure TRibbonButtonBar.RebuildButtons;
var
  I: Integer;
  LItem: TRibbonBarButton;
  LBtn: TJvNavPanelButtonTop;
begin
  if csDestroying in ComponentState then
    Exit;

  ClearGeneratedButtons;

  for I := 0 to FButtons.Count - 1 do
  begin
    LItem := FButtons[I];

    // Owner = Self und kein Name: bleibt aus der DFM heraus
    LBtn := TJvNavPanelButtonTop.Create(Self);
    LBtn.Parent := Self;
    LBtn.ParentFont := True;
    LBtn.Alignment := taCenter;
    LBtn.StyleManager := FStyle;
    LBtn.ParentStyleManager := False;
    if Assigned(FImages) then
      LBtn.Images := FImages;

    // Die Action liefert Caption, Hint, Enabled, ImageIndex und OnExecute.
    // Deshalb hat die Leiste bewusst kein eigenes Klick-Ereignis.
    if Assigned(LItem.Action) then
      LBtn.Action := LItem.Action;

    // Nach der Action setzen - die schreibt Visible sonst wieder um
    LBtn.Visible := LItem.Visible;

    LItem.FButton := LBtn;
  end;

  UpdateButtonBounds;
end;

procedure TRibbonButtonBar.UpdateButtonBounds;
var
  I: Integer;
  LItem: TRibbonBarButton;
  LLeft: Integer;
  LWidth: Integer;
begin
  if not Assigned(FButtons) or (csDestroying in ComponentState) then
    Exit;

  LLeft := 0;
  for I := 0 to FButtons.Count - 1 do
  begin
    LItem := FButtons[I];
    if not Assigned(LItem.FButton) then
      Continue;

    if LItem.Width > 0 then
      LWidth := LItem.Width
    else
      LWidth := FButtonWidth;

    // Volle Hoehe der Leiste - Leiste und Buttons sind immer gleich hoch
    LItem.FButton.SetBounds(LLeft, 0, LWidth, ClientHeight);

    if LItem.Visible then
      Inc(LLeft, LWidth + FButtonSpacing);
  end;
end;

end.
