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
//     Jedes Header-Item hat SEINE EIGENE Buttons-Collection (wie im
//     handgebauten pnlRibbon in PersonenFrm, wo jeder Reiter seine eigene
//     Buttonleiste hat) — keine globale, auf alle Tabs duplizierte Leiste
//     mehr.
//   Headers[i].Buttons: TJvRibbonButtonCollection — ein Item = eine
//     Schaltflaeche (Erster/Neu/Speichern/...) auf GENAU diesem Tabsheet.
//     Klick liefert OnButtonClick(Sender, ATabIndex, AButtonTag).
//   ButtonsVisible: globaler Schalter fuer die gesamte Buttonleiste (alle
//     Tabs) — bei False wird gar keine Leiste angelegt, das Tabsheet
//     beginnt dann ohne Abstand direkt unter den Header-Buttons.

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ActnList,
  // JvTypes wegen TJvGradientStyle (grVertical) — steht NICHT in JvGradient.pas
  JvExControls, JvNavigationPane, JvNavPanelButtonTop, JvGradient, JvTypes,
  // eigenes PageControl: haelt die Tabsheets per Resize auf 0/0/W/H,
  // damit kein Platz fuer die unsichtbare Reiterleiste uebrig bleibt
  RibbonPageControl;

const
  // Farbverlauf-Standardwerte, 1:1 aus PersonenFrm/Unit2/frmMain uebernommen
  // (dort jeweils ein von Hand platzierter TJvGradient neben der Buttonleiste).
  cDefGradientStart = TColor(16245453);
  cDefGradientEnd   = TColor(15966336);

type
  TJvRibbonPanel = class;

  TJvRibbonButtonClickEvent = procedure(Sender: TJvRibbonPanel;
    ATabIndex, AButtonTag: Integer) of object;

  // ── eine Schaltflaeche innerhalb der Buttonleiste EINES Tabsheets ──────
  //
  // Zwei Betriebsarten pro Item (siehe BuildButtonBar):
  //  - Action zugewiesen: Caption/Enabled/Hint/OnClick kommen automatisch
  //    von der Action (TJvNavPanelButton unterstuetzt Action bereits nativ,
  //    inkl. ActionChange-Sync) — Caption/ActionTag/OnButtonClick werden
  //    dann NICHT verwendet.
  //  - kein Action zugewiesen: Fallback auf manuelles Caption/ActionTag +
  //    OnButtonClick(Sender, ATabIndex, AButtonTag), wie bisher.
  //  Bewusst KEIN Index-in-ActionList-Ansatz (ActionTag = Listenposition):
  //  ein Umsortieren/Einfuegen in der ActionList wuerde sonst stillschweigend
  //  alle Buttons auf die falsche Action verbiegen.
  TJvRibbonButtonItem = class(TCollectionItem)
  private
    FCaption: string;
    FActionTag: Integer;
    FVisible: Boolean;
    FAction: TContainedAction;
    FWidth: Integer;
    procedure SetCaption(const Value: string);
    procedure SetActionTag(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetAction(const Value: TContainedAction);
    procedure SetWidth(const Value: Integer);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
  published
    // direkte Referenz auf eine TAction (z.B. aus der Actions-Liste des
    // zugehoerigen Header-Items) — wenn gesetzt, steuert sie den Button.
    property Action: TContainedAction read FAction write SetAction;
    property Caption: string read FCaption write SetCaption;
    // frei waehlbare Kennung, die OnButtonClick zurueckbekommt (nur
    // relevant, wenn KEINE Action zugewiesen ist; analog TNavAktion-Tag
    // in PersonenFrm.BtnNavClick).
    property ActionTag: Integer read FActionTag write SetActionTag default 0;
    // Button pro Item ein-/ausblendbar, ohne ihn aus der Collection zu
    // entfernen (z.B. rollenabhaengige Buttons).
    property Visible: Boolean read FVisible write SetVisible default True;
    // Breite dieses Buttons in seiner Buttonleiste — analog
    // TJvRibbonHeaderItem.Width. 0 (Default) = fester Fallback 64px (siehe
    // BuildButtonBar), jeder Wert > 0 ist ein manueller Override (z.B. fuer
    // laengere Beschriftungen wie "Position hinzufügen").
    property Width: Integer read FWidth write SetWidth default 0;
  end;

  TJvRibbonButtonCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TJvRibbonButtonItem;
    procedure SetItem(Index: Integer; const Value: TJvRibbonButtonItem);
  protected
    // Wird vom TCollectionEditor (Object Inspector) bei JEDER Aenderung
    // (Add/Delete/Move sowie Changed() eines Items, z.B. Caption-Aenderung)
    // automatisch aufgerufen. AOwner ist hier das TJvRibbonPanel (wird beim
    // Erzeugen der Collection im TJvRibbonHeaderItem-Konstruktor als Owner
    // durchgereicht, siehe dort) — darueber wird der Rebuild angestossen,
    // den der Headers-Property-Setter (nur bei kompletter Zuweisung, z.B.
    // beim DFM-Laden) nicht abdeckt.
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TJvRibbonButtonItem;
    property Items[Index: Integer]: TJvRibbonButtonItem read GetItem write SetItem; default;
  end;

  // ── ein Header-Button + sein TabSheet + seine eigene Buttonleiste ──────
  TJvRibbonHeaderItem = class(TCollectionItem)
  private
    FCaption: string;
    FTabSheet: TTabSheet;   // intern verwaltet, nicht published
    FHeaderBtn: TJvNavPanelHeader;
    FButtons: TJvRibbonButtonCollection;
    FActions: TActionList;
    FContentPanel: TPanel;
    FWidth: Integer;
    procedure SetCaption(const Value: string);
    procedure SetButtons(const Value: TJvRibbonButtonCollection);
    procedure SetActions(const Value: TActionList);
    procedure SetContentPanel(const Value: TPanel);
    procedure SetWidth(const Value: Integer);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property TabSheet: TTabSheet read FTabSheet;
  published
    property Caption: string read FCaption write SetCaption;
    // Breite des Header-Buttons in der Kopfleiste — je Reiter individuell
    // uebersteuerbar, damit laengere Beschriftungen ("Personentypen") nicht
    // abgeschnitten werden. 0 (Default) = automatisch aus der Textbreite der
    // Caption + 2px berechnet (siehe RebuildAll); jeder Wert > 0 ist ein
    // manueller Override. Left ist bewusst KEINE Property: es wird in
    // RebuildAll immer automatisch aus der Summe der vorherigen Breiten
    // berechnet, eine manuell gesetzte Left-Property wuerde bei jedem
    // Rebuild sofort wieder ueberschrieben.
    property Width: Integer read FWidth write SetWidth default 0;
    // ActionList, aus der die Buttons dieses Tabsheets im Object Inspector
    // ihre Action waehlen (rein organisatorisch — der Action-Property-Editor
    // zeigt zwar ohnehin alle TAction-Komponenten des Formulars an, aber so
    // ist pro Reiter dokumentiert/gebuendelt, welche ActionList "seine" ist).
    property Actions: TActionList read FActions write SetActions;
    // eigene Buttonleiste NUR fuer dieses Tabsheet (nicht mehr global/
    // dupliziert wie zuvor).
    property Buttons: TJvRibbonButtonCollection read FButtons write SetButtons;
    // Design-Time-Inhalt dieses Tabsheets: ein beliebig woanders auf dem
    // Formular gestaltetes TPanel (mit allen Kindkontrollen — Grids, Edits
    // usw. ganz normal im Form-Designer platziert), das RebuildAll hier
    // hinein reparentet (Align=alClient, unterhalb der Buttonleiste). Grund:
    // der TTabSheet selbst entsteht erst zur Laufzeit und ist nicht Teil des
    // DFM-Baums, man kann also nicht direkt hineindesignen — ueber dieses
    // Panel schon, weil es unabhaengig vom Tabsheet als normale DFM-Komponente
    // existiert.
    property ContentPanel: TPanel read FContentPanel write SetContentPanel;
  end;

  TJvRibbonHeaderCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TJvRibbonHeaderItem;
    procedure SetItem(Index: Integer; const Value: TJvRibbonHeaderItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TJvRibbonHeaderItem;
    // GetOwner ist bei TCollection protected und daher aus
    // TJvRibbonHeaderItem.Create (keine Nachfahre von TCollection) nicht
    // erreichbar — dieser oeffentliche Wrapper macht den Owner fuer die
    // Buttons-Unter-Collection jedes Header-Items zugaenglich.
    function PanelOwner: TJvRibbonPanel;
    property Items[Index: Integer]: TJvRibbonHeaderItem read GetItem write SetItem; default;
  end;

  TJvRibbonPanel = class(TCustomPanel)
  private
    FPageControl: TRibbonPageControl;
    FHeaderStrip: TPanel;
    FHeaderGradient: TJvGradient;
    FHeaders: TJvRibbonHeaderCollection;
    FActiveTheme: TJvNavPanelTheme;
    FInactiveTheme: TJvNavPanelTheme;
    FStyleActive: TJvNavPaneStyleManager;
    FStyleInactive: TJvNavPaneStyleManager;
    FOnButtonClick: TJvRibbonButtonClickEvent;
    FUpdating: Boolean;
    FButtonsVisible: Boolean;
    FActivePageIndex: Integer;
    FGradientStartColor: TColor;
    FGradientEndColor: TColor;
    procedure SetHeaders(const Value: TJvRibbonHeaderCollection);
    procedure SetActiveTheme(const Value: TJvNavPanelTheme);
    procedure SetInactiveTheme(const Value: TJvNavPanelTheme);
    procedure SetButtonsVisible(const Value: Boolean);
    procedure SetActivePageIndex(const Value: Integer);
    procedure ApplyActivePage(AIndex: Integer);
    // Uebernimmt HeaderColorFrom/To des INAKTIVEN StyleManagers in den
    // Hintergrundverlauf der Header-Leiste (siehe Konstruktor).
    procedure ApplyHeaderGradientColors;
    // Haengt das ContentPanel eines Header-Items an die richtige Stelle,
    // getrennt nach Laufzeit und Entwurfszeit (siehe Implementierung).
    procedure PlatziereContentPanel(AItem: TJvRibbonHeaderItem; AIndex: Integer);
    procedure HeaderClickInternal(Sender: TObject);
    procedure ButtonClickInternal(Sender: TObject);
    procedure BuildButtonBar(ATab: TTabSheet; AButtons: TJvRibbonButtonCollection; ATag: Integer);
  protected
    procedure Loaded; override;
    // Raeumt haengende Referenzen auf, wenn eine im Object Inspector
    // zugewiesene Action oder ActionList geloescht wird (Buttons-/Headers-
    // Collections sind TCollectionItems, keine TComponents, bekommen also
    // selbst keine Notification — muss hier zentral am Panel abgefangen
    // werden).
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // von aussen aufrufbar: gehoerender Sender eines Klicks (Header oder
    // Button) zu Tabindex/Item aufloesen — z.B. fuer eigene Erweiterungen.
    function TabIndexOf(AHeaderItem: TJvRibbonHeaderItem): Integer;
    // von den Collections (Update-Override) aufgerufen, wenn sich Headers
    // oder eine Buttons-Collection eines Header-Items aendern (Add/Delete/
    // Item-Property) — muss public sein, da die Collection-Klassen keine
    // friend-Deklaration haben.
    procedure RebuildAll;
  published
    property Headers: TJvRibbonHeaderCollection read FHeaders write SetHeaders;
    property ActiveTheme: TJvNavPanelTheme read FActiveTheme write SetActiveTheme default nptXPBlue;
    property InactiveTheme: TJvNavPanelTheme read FInactiveTheme write SetInactiveTheme default nptXPSilver;
    // Globaler Schalter fuer die ganze Buttonleiste (nicht nur einzelne
    // Buttons wie TJvRibbonButtonItem.Visible): False entfernt die Leiste
    // komplett, das Tabsheet beginnt dann ohne Abstand direkt unter den
    // Header-Buttons.
    property ButtonsVisible: Boolean read FButtonsVisible write SetButtonsVisible default True;
    // Farbverlauf, der den freien Platz rechts neben den Buttons jeder
    // Buttonleiste fuellt (Look aus PersonenFrm/Unit2/frmMain). Wirkt beim
    // naechsten Aufbau der Leiste, also beim naechsten Programmstart.
    property GradientStartColor: TColor read FGradientStartColor
      write FGradientStartColor default cDefGradientStart;
    property GradientEndColor: TColor read FGradientEndColor
      write FGradientEndColor default cDefGradientEnd;
    // Zur Entwurfszeit im Object Inspector umschaltbar, um Controls direkt
    // auf dem gewuenschten Tabsheet zu platzieren (die echten TTabSheet-Tabs
    // sind unsichtbar, ein Klick darauf zum Wechseln geht also nicht) —
    // sowie von Code aus zur Laufzeit nutzbar. Wird gespeichert (DFM); die
    // Streaming-Reihenfolge relativ zu Headers ist egal, da RebuildAll
    // (siehe Loaded) den gespeicherten Wert nach dem Aufbau anwendet statt
    // hart auf Index 0 zurueckzuspringen.
    property ActivePageIndex: Integer read FActivePageIndex write SetActivePageIndex default 0;
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

{ TJvRibbonButtonItem }

constructor TJvRibbonButtonItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FVisible := True;
end;

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

procedure TJvRibbonButtonItem.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(False);
  end;
end;

procedure TJvRibbonButtonItem.SetAction(const Value: TContainedAction);
begin
  if FAction <> Value then
  begin
    FAction := Value;
    Changed(False);
  end;
end;

procedure TJvRibbonButtonItem.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed(False);
  end;
end;

{ TJvRibbonButtonCollection }

function TJvRibbonButtonCollection.Add: TJvRibbonButtonItem;
begin
  Result := TJvRibbonButtonItem(inherited Add);
end;

// KEIN automatisches RebuildAll mehr bei jeder Aenderung (Walters
// Entscheidung, 27.07.2026: "in 26 Jahren nie benoetigt" -- der Mechanismus
// war die Ursache fuer wiederholten Datenverlust an ContentPanels, wenn
// der Object Inspector waehrend des Bearbeitens intern Collection-Items per
// Assign neu aufbaut, siehe feedback/project-Memory zu ArtikelStammFrm).
// RebuildAll laeuft jetzt nur noch gezielt: einmal in TJvRibbonPanel.Loaded
// (baut die Tabs beim Start aus den gestreamten Daten) sowie explizit bei
// Theme-/Sichtbarkeits-Aenderungen (SetInactiveTheme/SetButtonsVisible).
// Struktur-Aenderungen an Headers/Buttons zur Entwurfszeit wirken sich erst
// nach dem naechsten Laden/Programmstart sichtbar aus -- das ist der
// bewusst in Kauf genommene Tradeoff fuer Stabilitaet.
procedure TJvRibbonButtonCollection.Update(Item: TCollectionItem);
begin
  inherited;
end;

function TJvRibbonButtonCollection.GetItem(Index: Integer): TJvRibbonButtonItem;
begin
  Result := TJvRibbonButtonItem(inherited GetItem(Index));
end;

procedure TJvRibbonButtonCollection.SetItem(Index: Integer; const Value: TJvRibbonButtonItem);
begin
  inherited SetItem(Index, Value);
end;

{ TJvRibbonHeaderItem }

constructor TJvRibbonHeaderItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FCaption := Format('Reiter %d', [Index + 1]);
  FWidth := 0;  // 0 = automatisch aus Textbreite (siehe Property-Kommentar)
  // Owner der Buttons-Collection ist NICHT dieses Item, sondern (wie bei
  // Headers) das TJvRibbonPanel selbst — geholt ueber PanelOwner der
  // uebergeordneten Headers-Collection. So funktioniert der gleiche
  // Update->RebuildAll-Mechanismus wie bei Headers, nur eine Ebene tiefer.
  FButtons := TJvRibbonButtonCollection.Create(
    TJvRibbonHeaderCollection(ACollection).PanelOwner, TJvRibbonButtonItem);
end;

destructor TJvRibbonHeaderItem.Destroy;
begin
  // Das ContentPanel gehoert dem FORMULAR, nicht diesem Item. Es wird
  // hier nur aus dem Tabsheet geloest, damit es nicht mitzerstoert
  // wird - aber NUR, wenn es ueberhaupt noch lebt. Beim Abbau des
  // Formulars kann es laengst weg sein; der ungeprueste Zugriff war
  // die Absturzstelle im Designer (29.07.2026).
  if Assigned(FContentPanel)
     and not (csDestroying in FContentPanel.ComponentState) then
    FContentPanel.Parent := nil;
  FButtons.Free;
  inherited Destroy;
end;

procedure TJvRibbonHeaderItem.Assign(Source: TPersistent);
begin
  if Source is TJvRibbonHeaderItem then
  begin
    Caption := TJvRibbonHeaderItem(Source).Caption;
    Buttons.Assign(TJvRibbonHeaderItem(Source).Buttons);
    // WICHTIG: Actions/ContentPanel sind reine Komponentenreferenzen, kein
    // Eigentum dieses Items — MUESSEN mitkopiert werden. Der Collection-
    // Editor im Object Inspector verschiebt/fuegt Items intern teils ueber
    // genau solche Assign-Aufrufe ein; fehlt das hier, geht die Referenz
    // beim Verschieben stillschweigend verloren (Feld wird nil), und
    // RebuildAll loest dann ein noch aktiv genutztes ContentPanel nicht
    // mehr rechtzeitig aus dem alten Tabsheet heraus, bevor dieser .Free
    // wird — das zerstoert das Panel samt seinen Kindkontrollen.
    FActions      := TJvRibbonHeaderItem(Source).FActions;
    FContentPanel := TJvRibbonHeaderItem(Source).FContentPanel;
    FWidth        := TJvRibbonHeaderItem(Source).FWidth;
  end
  else
    inherited Assign(Source);
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

procedure TJvRibbonHeaderItem.SetButtons(const Value: TJvRibbonButtonCollection);
begin
  FButtons.Assign(Value);
end;

procedure TJvRibbonHeaderItem.SetActions(const Value: TActionList);
begin
  FActions := Value;
end;

procedure TJvRibbonHeaderItem.SetContentPanel(const Value: TPanel);
begin
  if FContentPanel <> Value then
  begin
    FContentPanel := Value;
    // Loest seit 27.07.2026 KEIN automatisches RebuildAll mehr aus (siehe
    // TJvRibbonHeaderCollection.Update) -- das Reparenting passiert beim
    // naechsten Laden/Programmstart (TJvRibbonPanel.Loaded), nicht mehr
    // sofort zur Entwurfszeit.
    Changed(False);
  end;
end;

procedure TJvRibbonHeaderItem.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed(False);
  end;
end;

{ TJvRibbonHeaderCollection }

function TJvRibbonHeaderCollection.Add: TJvRibbonHeaderItem;
begin
  Result := TJvRibbonHeaderItem(inherited Add);
end;

function TJvRibbonHeaderCollection.PanelOwner: TJvRibbonPanel;
begin
  Result := TJvRibbonPanel(GetOwner);
end;

// Siehe Kommentar an TJvRibbonButtonCollection.Update -- kein automatisches
// RebuildAll mehr, aus denselben Gruenden (Walter, 27.07.2026).
procedure TJvRibbonHeaderCollection.Update(Item: TCollectionItem);
begin
  inherited;
end;

function TJvRibbonHeaderCollection.GetItem(Index: Integer): TJvRibbonHeaderItem;
begin
  Result := TJvRibbonHeaderItem(inherited GetItem(Index));
end;

procedure TJvRibbonHeaderCollection.SetItem(Index: Integer; const Value: TJvRibbonHeaderItem);
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

  FActiveTheme    := nptXPBlue;
  FInactiveTheme  := nptXPSilver;
  FButtonsVisible := True;
  FGradientStartColor := cDefGradientStart;
  FGradientEndColor   := cDefGradientEnd;

  FStyleActive := TJvNavPaneStyleManager.Create(Self);
  FStyleActive.Theme := FActiveTheme;
  FStyleInactive := TJvNavPaneStyleManager.Create(Self);
  FStyleInactive.Theme := FInactiveTheme;

  FHeaderStrip := TPanel.Create(Self.Owner);
  FHeaderStrip.Parent     := Self;
  FHeaderStrip.ParentFont := True;
  FHeaderStrip.Align      := alTop;
  FHeaderStrip.Height     := 31;
  FHeaderStrip.BevelOuter := bvNone;
  FHeaderStrip.Caption    := '';

  // Farbverlauf als Hintergrund der Header-Leiste, damit der freie Platz
  // rechts neben dem letzten Reiter nicht grau absticht. Farben kommen aus
  // dem INAKTIVEN Theme (HeaderColorFrom/To — dieselben Werte, mit denen ein
  // nicht ausgewaehlter TJvNavPanelHeader gezeichnet wird), der Verlauf
  // setzt sich optisch also nahtlos an die inaktiven Reiter an.
  // Wie in BuildButtonBar ZUERST erzeugt + alClient: liegt dadurch im
  // Z-Order unter den spaeter erzeugten Header-Buttons.
  FHeaderGradient := TJvGradient.Create(Self);
  FHeaderGradient.Parent := FHeaderStrip;
  FHeaderGradient.Align  := alClient;
  FHeaderGradient.Style  := grVertical;
  ApplyHeaderGradientColors;

  // TRibbonPageControl statt TPageControl: dessen Resize haelt die Tabsheets
  // auf 0/0/Width/Height, sonst rechnet die VCL bei jeder Groessenaenderung
  // die Reiterleiste wieder heraus (Walter, 29.07.2026).
  FPageControl := TRibbonPageControl.Create(Self);
  FPageControl.Parent := Self;
  FPageControl.Align  := alClient;
  FPageControl.Style  := tsFlatButtons;

  FHeaders := TJvRibbonHeaderCollection.Create(Self, TJvRibbonHeaderItem);
end;

destructor TJvRibbonPanel.Destroy;
begin
  // FreeAndNil, nicht Free: inherited Destroy zerstoert anschliessend
  // die Kindkontrollen, und JEDE davon loest Notification aus. Die
  // prueft Assigned(FHeaders) - nach einem blossen Free ist das Feld
  // aber weiterhin gesetzt und zeigt auf freigegebenen Speicher.
  FreeAndNil(FHeaders);
  inherited Destroy;
end;

procedure TJvRibbonPanel.Loaded;
begin
  inherited Loaded;
  RebuildAll;
end;

procedure TJvRibbonPanel.Notification(AComponent: TComponent; Operation: TOperation);
var
  I, J: Integer;
  LHeader: TJvRibbonHeaderItem;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and Assigned(FHeaders) then
    for I := 0 to FHeaders.Count - 1 do
    begin
      LHeader := FHeaders[I];
      if LHeader.FActions = AComponent then
        LHeader.FActions := nil;
      if LHeader.FContentPanel = AComponent then
        LHeader.FContentPanel := nil;
      for J := 0 to LHeader.Buttons.Count - 1 do
        if LHeader.Buttons[J].FAction = AComponent then
          LHeader.Buttons[J].FAction := nil;
    end;
end;

procedure TJvRibbonPanel.SetHeaders(const Value: TJvRibbonHeaderCollection);
begin
  FHeaders.Assign(Value);
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
    ApplyHeaderGradientColors;  // Hintergrundverlauf zieht mit
    RebuildAll;  // inaktive Header muessen das neue Theme sofort zeigen
  end;
end;


procedure TJvRibbonPanel.PlatziereContentPanel(AItem: TJvRibbonHeaderItem;
  AIndex: Integer);
var
  LRect: TRect;
begin
  if not Assigned(AItem.ContentPanel) then
    Exit;

  if AItem.ContentPanel.Parent <> AItem.FTabSheet then
  begin
    AItem.ContentPanel.Parent  := AItem.FTabSheet;
    AItem.ContentPanel.Align   := alClient;
    AItem.ContentPanel.Visible := True;
  end;
end;

procedure TJvRibbonPanel.ApplyHeaderGradientColors;
begin
  if not Assigned(FHeaderGradient) or not Assigned(FStyleInactive) then
    Exit;
  FHeaderGradient.StartColor := FStyleInactive.Colors.HeaderColorFrom;
  FHeaderGradient.EndColor   := FStyleInactive.Colors.HeaderColorTo;
end;

procedure TJvRibbonPanel.SetButtonsVisible(const Value: Boolean);
begin
  if FButtonsVisible <> Value then
  begin
    FButtonsVisible := Value;
    RebuildAll;
  end;
end;

function TJvRibbonPanel.TabIndexOf(AHeaderItem: TJvRibbonHeaderItem): Integer;
begin
  Result := AHeaderItem.Index;
end;

// Legt an, was noch fehlt (Tabsheets, Header-Buttons, Buttonleisten) und
// aktualisiert Beschriftung/Position — GIBT ABER NICHTS MEHR FREI.
//
// Walters Vorgabe (27.07.2026): "der eigentlich destructall heissen muesste".
// Jedes .Free hier hat frueher oder spaeter fremdes Gut zerstoert: verwaiste
// Tabsheets rissen ContentPanels mit, das pauschale Leeren der Header-Leiste
// und das Wegwerfen der Buttonleisten machte dasselbe eine Ebene tiefer.
// Ausloeser war immer der IDE-Designer, der Collection-Items beim Bearbeiten
// intern per Assign neu aufbaut und dabei FTabSheet/FHeaderBtn verliert.
//
// Ab jetzt gilt: aufbauen ja, aufraeumen nie. Beim echten Programmstart ist
// ohnehin alles frisch (neue Form-Instanz, FTabSheet/FHeaderBtn = nil), da
// entsteht alles genau einmal. Was Walter geloescht haben will, loescht er
// direkt in der DFM-Datei — seine ausdrueckliche Ansage.
procedure TJvRibbonPanel.RebuildAll;
const
  // Tag-Markierung der intern erzeugten Buttonleiste (siehe BuildButtonBar) —
  // daran erkennen wir, ob ein Tabsheet schon eine hat.
  cButtonBarTag = -12345;
var
  I, J: Integer;
  LItem: TJvRibbonHeaderItem;
  LBtn: TJvNavPanelHeader;
  LNextLeft: Integer;
  LWidth: Integer;
  LHasBar: Boolean;
begin
  // ZUR ENTWURFSZEIT PASSIERT HIER GAR NICHTS MEHR (29.07.2026).
  //
  // Vorher hat RebuildAll auch im Designer Tabsheets angelegt und die
  // ContentPanels umgehaengt (ContentPanel.Parent := Self). Tabsheets
  // entstehen aber im Code und stehen NIE im DFM - der Formularspeicher
  // kann ein Panel nicht schreiben, dessen Parent er nicht kennt.
  // Ergebnis: beim Schliessen im Designer verschwanden Panels samt
  // Inhalt aus dem DFM, und die IDE entfernte die zugehoerigen
  // Felddeklarationen gleich mit.
  //
  // Der Preis: im Designer sieht man die Reiter nicht mehr, das
  // Ribbon-Panel bleibt leer. Dafuer fasst der Designer die Panels
  // nicht mehr an und kann nichts mehr verlieren. Zur Laufzeit
  // arbeitet die Komponente unveraendert.
  if FUpdating or (csLoading in ComponentState) then
    Exit;
  FUpdating := True;
  try
    // Bewusst KEIN Align = alLeft fuer die Header-Buttons: bei mehreren
    // alLeft-Geschwistern schiebt sich ein neu hinzugefuegter Sibling vor
    // die aelteren (VCL-Stapelreihenfolge ist dabei kontraintuitiv), das
    // Ergebnis waere "Reiter 3 | Reiter 2 | Reiter 1" statt der gewuenschten
    // Reihenfolge. Stattdessen manuell Left = Summe der bisherigen Breiten
    // je Button setzen — deterministisch, unabhaengig von VCL-Interna.
    LNextLeft := 0;
    for I := 0 to FHeaders.Count - 1 do
    begin
      LItem := FHeaders[I];

      // ── ab hier nur zur LAUFZEIT ────────────────────────────────
      // Tabsheets entstehen im Code und stehen NIE im DFM. Der
      // Formularspeicher kann kein Panel schreiben, dessen Parent er
      // nicht kennt - er laesst es kommentarlos weg. Genau so sind am
      // 29.07.2026 im Designer ContentPanels samt Inhalt verschwunden,
      // und die IDE hat anschliessend die Felddeklarationen aus der
      // .pas entfernt. Die Header-BUTTONS werden weiter unten dagegen
      // auch im Designer gebaut - sie gehoeren der Komponente, stehen
      // ebenfalls nicht im DFM und koennen nichts kaputtmachen.
      if not (csDesigning in ComponentState) then
      begin
        if not Assigned(LItem.FTabSheet) then
        begin
          LItem.FTabSheet := TTabSheet.Create(Self);
          LItem.FTabSheet.PageControl := FPageControl;
        end;
        LItem.FTabSheet.Caption    := LItem.Caption;
        LItem.FTabSheet.TabVisible := False;
        LItem.FTabSheet.PageIndex  := I;

      // Buttonleiste NUR anlegen, wenn dieses Tabsheet noch keine hat —
      // eine bestehende wird nicht mehr weggeworfen und neu gebaut.
      // Konsequenz: Aenderungen an der Buttons-Collection zeigen sich erst
      // beim naechsten Programmstart. Bewusst so (siehe Methodenkommentar).
        LHasBar := False;
        for J := 0 to LItem.FTabSheet.ControlCount - 1 do
          if LItem.FTabSheet.Controls[J].Tag = cButtonBarTag then
          begin
            LHasBar := True;
            Break;
          end;
        if not LHasBar then
          BuildButtonBar(LItem.FTabSheet, LItem.Buttons, cButtonBarTag);

        PlatziereContentPanel(LItem, I);
      end;

      // Header-Button wiederverwenden statt neu erzeugen (frueher wurde die
      // ganze Leiste vorher freigegeben — genau das faellt jetzt weg).
      if Assigned(LItem.FHeaderBtn) then
        LBtn := LItem.FHeaderBtn
      else
      begin
        LBtn := TJvNavPanelHeader.Create(Self);
        LBtn.Parent     := FHeaderStrip;
        LBtn.ParentFont := True;
        LBtn.OnClick    := HeaderClickInternal;
        LItem.FHeaderBtn := LBtn;
      end;
      LBtn.Tag        := I;
      LBtn.Caption    := LItem.Caption;
      LBtn.Alignment  := taCenter;
      LBtn.StyleManager := FStyleInactive;
      LBtn.ParentStyleManager := False;
      // TODO Auto-Breite aus Textbreite: Screen.Canvas.TextWidth loeste
      // denselben E2362-Fehler aus wie LBtn.Canvas (noch ungeklaerte
      // Ursache) — vorerst deaktiviert, fester Fallback 94px.
      if LItem.Width > 0 then
        LWidth := LItem.Width
      else
        LWidth := 94;
      LBtn.Left       := LNextLeft;
      LBtn.Top        := 0;
      LBtn.Width      := LWidth;
      LBtn.Height     := FHeaderStrip.Height;
      LBtn.Anchors    := [akLeft, akTop, akBottom];
      Inc(LNextLeft, LWidth);
    end;

    if FHeaders.Count > 0 then
    begin
      // gemerkten Index anwenden statt hart auf 0 zurueckzuspringen —
      // damit ueberlebt eine im Object Inspector gewaehlte ActivePageIndex
      // einen Rebuild (z.B. durch Aendern von Headers/Buttons) und das
      // erneute Laden des Formulars.
      if (FActivePageIndex < 0) or (FActivePageIndex >= FHeaders.Count) then
        FActivePageIndex := 0;
      ApplyActivePage(FActivePageIndex);
    end;
  finally
    FUpdating := False;
  end;
end;

// Die Buttonleiste EINES Tabsheets aus dessen eigener Buttons-Collection
// aufbauen — analog den 9 TJvNavPanelButtonTop je Tabsheet in PersonenFrm,
// jetzt aber pro Reiter individuell statt global dupliziert.
procedure TJvRibbonPanel.BuildButtonBar(ATab: TTabSheet; AButtons: TJvRibbonButtonCollection; ATag: Integer);
var
  I: Integer;
  LBar: TPanel;
  LBtn: TJvNavPanelButtonTop;
  LSrc: TJvRibbonButtonItem;
  LNextLeft: Integer;
  LWidth: Integer;
  LGrad: TJvGradient;
begin
  // Globaler Schalter: Leiste gar nicht erst anlegen, damit kein Platz
  // dafuer reserviert wird (Tabsheet beginnt dann direkt unter den
  // Header-Buttons, kein toter Abstand).
  if not FButtonsVisible then
    Exit;

  LBar := TPanel.Create(Self);

  LBar.Parent     := ATab;
  LBar.Align      := alTop;
  LBar.Height     := 38;
  LBar.BevelOuter := bvNone;
  LBar.Caption    := '';
  LBar.ParentFont := True;
  // Markierung, damit RebuildAll diese rein interne Leiste sicher von einem
  // User-ContentPanel unterscheiden kann (siehe dortiger Kommentar).
  LBar.Tag        := ATag;

  // Farbverlauf als HINTERGRUND der Leiste (Look aus PersonenFrm grdtStamm/
  // grdtAdr bzw. Unit2/frmMain, wo er bisher von Hand platziert werden musste).
  // ZUERST erzeugen und alClient: dadurch liegt er im Z-Order unter den
  // danach erzeugten Buttons und fuellt immer die volle Leistenbreite — eine
  // Left/Width-Rechnung "rechts neben dem letzten Button" wuerde hier
  // fehlschlagen, weil LBar seine endgueltige Breite erst nach dem Einhaengen
  // ins Tabsheet bekommt.
  LGrad := TJvGradient.Create(Self);
  LGrad.Parent     := LBar;
  LGrad.Align      := alClient;
  LGrad.Style      := grVertical;
  LGrad.StartColor := FGradientStartColor;
  LGrad.EndColor   := FGradientEndColor;

  // Bewusst KEIN Align = alLeft (siehe RebuildAll-Kommentar zu den Header-
  // Buttons): gleiche Stapel-Reihenfolge-Falle. Stattdessen manuell Left =
  // Summe der bisherigen Breiten, deterministisch in Collection-Reihenfolge.
  LNextLeft := 0;
  for I := 0 to AButtons.Count - 1 do
  begin
    LSrc := AButtons[I];
    LBtn := TJvNavPanelButtonTop.Create(Self);
    LBtn.Parent     := LBar;
    LBtn.ParentFont := True;
    LBtn.Alignment  := taCenter;
    LBtn.StyleManager := FStyleActive;
    LBtn.ParentStyleManager := False;
    LBtn.Visible    := LSrc.Visible;

    // TODO Auto-Breite aus Textbreite: siehe TODO im Header-Button-Zweig
    // von RebuildAll (E2362, noch ungeklaert) — vorerst deaktiviert, fester
    // Fallback 64px. LSrc.Width > 0 ueberschreibt das manuell.
    if LSrc.Width > 0 then
      LWidth := LSrc.Width
    else
      LWidth := 64;

    LBtn.Left       := LNextLeft;
    LBtn.Top        := 0;
    LBtn.Width      := LWidth;
    LBtn.Height     := LBar.Height;
    LBtn.Anchors    := [akLeft, akTop, akBottom];
    // unsichtbare Items nehmen trotzdem keinen Platz ein: Left ruecken wir
    // fuer sie einfach nicht weiter
    if LSrc.Visible then
      Inc(LNextLeft, LWidth);

    if Assigned(LSrc.Action) then
      // TJvNavPanelButton unterstuetzt Action nativ (ActionChange-Override,
      // siehe JvNavigationPane.pas) — Caption/Enabled/Hint/OnClick kommen
      // dann automatisch von der Action, Caption/ActionTag werden ignoriert.
      LBtn.Action := LSrc.Action
    else
    begin
      LBtn.Tag     := LSrc.ActionTag;
      LBtn.Caption := LSrc.Caption;
      LBtn.OnClick := ButtonClickInternal;
    end;
  end;
end;

// Schaltet Header-Button-Styles (aktiv/inaktiv) und PageControl synchron um.
// Setzt voraus, dass AIndex gueltig ist UND die Header-Buttons bereits
// gebaut sind (RebuildAll gelaufen) — Aufrufer pruefen das.
procedure TJvRibbonPanel.ApplyActivePage(AIndex: Integer);
var
  I: Integer;
begin
  for I := 0 to FHeaders.Count - 1 do
    if Assigned(FHeaders[I].FHeaderBtn) then
      FHeaders[I].FHeaderBtn.StyleManager := FStyleInactive;
  FHeaders[AIndex].FHeaderBtn.StyleManager := FStyleActive;
  FPageControl.ActivePageIndex := AIndex;

  // Zur Entwurfszeit liegen die ContentPanels nicht in den Tabsheets, sondern
  // direkt auf diesem Panel (siehe PlatziereContentPanel) — das Umschalten
  // der Sichtbarkeit muss deshalb hier von Hand passieren, damit ein Wechsel
  // von ActivePageIndex im Object Inspector den passenden Reiterinhalt zeigt.
  if csDesigning in ComponentState then
    for I := 0 to FHeaders.Count - 1 do
      PlatziereContentPanel(FHeaders[I], I);
end;

// Wird sowohl vom ActivePageIndex-Property (Object Inspector zur
// Entwurfszeit + Code zur Laufzeit) als auch von HeaderClickInternal
// aufgerufen. Der Wert wird IMMER im Feld gemerkt (auch waehrend des
// DFM-Ladens, wenn die Headers-Collection noch leer ist) — die sichtbare
// Umschaltung passiert erst, wenn die Header-Buttons tatsaechlich existieren;
// RebuildAll wendet den gemerkten Wert nach jedem (Neu-)Aufbau an.
procedure TJvRibbonPanel.SetActivePageIndex(const Value: Integer);
begin
  if Value < 0 then
    Exit;
  FActivePageIndex := Value;
  if not (csLoading in ComponentState) and (Value < FHeaders.Count)
    and Assigned(FHeaders[Value].FHeaderBtn) then
    ApplyActivePage(Value);
end;

procedure TJvRibbonPanel.HeaderClickInternal(Sender: TObject);
begin
  SetActivePageIndex((Sender as TJvNavPanelHeader).Tag);
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
