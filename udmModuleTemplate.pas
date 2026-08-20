unit udmModuleTemplate;

interface

uses
  System.SysUtils, System.Classes, vcl.Dialogs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.Param, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, vcl.Forms,
  Vcl.ExtCtrls,Vcl.Controls, JvComponentBase, System.SyncObjs, JvThread,
  System.Generics.Collections, System.Rtti,
  EventBus,DataModuleForDelphi;

type
  {$IFDEF DEBUG}
  TdmModuleTemplate = class(TDataModuleForDelphi)
  {$ELSE}
  TdmModuleTemplate = class(TDataModule)
  {$ENDIF}
    JvThread1: TJvThread;
    procedure JvThread1Execute(Sender: TObject; Params: Pointer);
    procedure JvThread1AfterCreateDialogForm(
      DialogForm: TJvCustomThreadDialogForm);
  private
    { Private-Deklarationen }
    class var FInstance: TdmModuleTemplate;
    class var FLock: TCriticalSection;
    // Alle erzeugten Module. Jedes traegt sich im Constructor ein - der
    // laeuft, weil jedes Modul von hier erbt. Damit weiss ein Broadcast,
    // wen es gibt, ohne per RTTI zu suchen und ohne Module zu erzeugen,
    // die noch nie geoeffnet wurden.
    class var FModule: TList<TdmModuleTemplate>;
  public
 { Public-Deklarationen }
    // ── Broadcast ───────────────────────────────────────────────────────
    // Das zentrale Datenmodul hat alle Tabellen geladen. Standard: nichts
    // tun. Ein Modul ueberschreibt das und holt sich hier seine Kopien.
    procedure DatenGeladen; virtual;
    // Ruft AMethode bei jedem erzeugten Modul. Kommt vom MessageHandler
    // (mtBroadcast); die Namensauflösung macht RTTI, damit spaetere
    // Anlaesse (Mandant gewechselt, Verbindung neu) denselben Weg nehmen
    // koennen, ohne dass hier etwas dazukommt.
    class procedure AlleBenachrichtigen(const AMethode: string);

    // Kopie einer Tabelle des zentralen Datenmoduls. Ein Modul arbeitet
    // NUR auf Kopien und hat keine Connection.
    //
    // Das ist die einzige Stelle im ganzen Programm, an der ein Modul das
    // zentrale Datenmodul beruehrt. Wird FireDAC spaeter durch Zeos +
    // VirtualTable ersetzt, wird hier aus CopyDataSet ein Assign - und
    // sonst nirgends etwas.
    // AFilter wird VOR dem Kopieren auf die Quelle gesetzt - dann wandert
    // nur, was das Modul braucht, statt alles zu holen und hinterher
    // wegzufiltern.
    //
    // WICHTIG, damit hier nie wieder der Fehler vom 19.08.2026 landet: In
    // AFilter gehoert nur, was sich waehrend der Arbeit NICHT aendert
    // (mandant_id, bereich, aktiv). Niemals der aktuelle Satz eines
    // Masters - die Kopie enthielte sonst nur die Zeilen EINES Datensatzes,
    // und beim Blaettern waere das Detail leer. Master-Detail filtert im
    // Speicher, nicht beim Kopieren.
    procedure Kopiere(AZiel: TFDMemTable; const AQuelle: string;
      const AFilter: string = '');

    class function GetInstance: TdmModuleTemplate;
    procedure ShowMessage(A,B:string);
    // override, NICHT nur gleichnamig: Application.CreateForm ruft den
    // virtuellen Konstruktor ueber die Klassenreferenz. Ohne override
    // verdeckt diese Methode ihn nur - sie lief bei jedem so erzeugten
    // Modul gar nicht, und weder die EventBus-Anmeldung noch der
    // Eintrag in die Instanzliste fanden statt.
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure DoWork(A,B:string;i_bShowForm: Boolean;pan:TPanel);
    // Zentraler Einstiegspunkt fuer alle Module (ausser frmMain, siehe dort):
    // baut ein TMyEvent (mtModulCall) und postet es an den GlobalEventBus.
    // Ziel ist 'Tdm'+ModulName, Methode 'Open'+ModulName.
    class procedure OpenGui(const ModulName: string);
  end;

var
  dmModuleTemplate: TdmModuleTemplate;

implementation

uses
  uFrmModuleTemplate,
  UInterfaces,
  uMessageHandler,
  ZentraleDatenDm;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmModuleTemplate }

constructor TdmModuleTemplate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GlobalEventBus.SilentRegisterSubscriberForEvents(Self);
  if Assigned(FLock) then
  begin
    FLock.Acquire;
    try
      if FModule = nil then
        FModule := TList<TdmModuleTemplate>.Create;
      FModule.Add(Self);
    finally
      FLock.Release;
    end;
  end;
end;

destructor TdmModuleTemplate.Destroy;
begin
  // Beim Herunterfahren kann die Liste schon weg sein: die Module gehoeren
  // Application und werden nach der finalization dieser Unit freigegeben.
  // Deshalb hier nur anfassen, was es noch gibt (FreeAndNil unten).
  if Assigned(FLock) then
  begin
    FLock.Acquire;
    try
      if Assigned(FModule) then
        FModule.Remove(Self);
    finally
      FLock.Release;
    end;
  end;
  GlobalEventBus.UnregisterForEvents(Self);
  inherited;
end;

// Standard: nichts tun. Ein Modul, das Daten braucht, ueberschreibt das.
procedure TdmModuleTemplate.DatenGeladen;
begin
end;

class procedure TdmModuleTemplate.AlleBenachrichtigen(const AMethode: string);
var
  LKontext: TRttiContext;
  LModul: TdmModuleTemplate;
  LMethode: TRttiMethod;
  LListe: TArray<TdmModuleTemplate>;
begin
  if not Assigned(FModule) then
    Exit;

  // Erst eine Momentaufnahme ziehen: ein benachrichtigtes Modul koennte
  // seinerseits eines erzeugen oder freigeben, und dann waere die Liste
  // waehrend des Durchlaufs veraendert.
  FLock.Acquire;
  try
    LListe := FModule.ToArray;
  finally
    FLock.Release;
  end;

  LKontext := TRttiContext.Create;
  try
    for LModul in LListe do
    begin
      LMethode := LKontext.GetType(LModul.ClassType).GetMethod(AMethode);
      // Ein Modul, das die Methode nicht kennt, wird uebergangen - der
      // Broadcast darf nicht daran scheitern.
      if Assigned(LMethode) and (Length(LMethode.GetParameters) = 0) then
        LMethode.Invoke(LModul, []);
    end;
  finally
    LKontext.Free;
  end;
end;

procedure TdmModuleTemplate.Kopiere(AZiel: TFDMemTable; const AQuelle: string;
  const AFilter: string);
var
  LQuelle: TFDTable;
  LMaster: TDataSource;
  LFelder: string;
  LAlterFilter: string;
  LWarGefiltert: Boolean;
begin
  if not Assigned(AZiel) then
    raise Exception.Create('Kopiere ohne Zieltabelle.');

  LQuelle := TdmZentraleDaten(TdmZentraleDaten.GetInstance).TabelleFinden(AQuelle);
  if not Assigned(LQuelle) then
    raise Exception.CreateFmt(
      'Tabelle "%s" gibt es im zentralen Datenmodul nicht.', [AQuelle]);
  if not LQuelle.Active then
    LQuelle.Open;

  // Die Quelle gehoert allen Modulen - ihr Filter wird nur geliehen und
  // im finally zurueckgegeben.
  LAlterFilter := LQuelle.Filter;
  LWarGefiltert := LQuelle.Filtered;
  if AFilter <> '' then
  begin
    LQuelle.Filter := AFilter;
    LQuelle.Filtered := True;
  end;

  // Ist das Ziel ein Detail, muss die Kopplung waehrend des Fuellens weg:
  // sonst filtert der Master die gerade angehaengten Saetze sofort wieder
  // heraus. Danach wird sie samt Feldern zurueckgesetzt - MasterFields geht
  // beim Abhaengen verloren.
  LMaster := AZiel.MasterSource;
  LFelder := AZiel.MasterFields;
  AZiel.MasterSource := nil;
  try

  if AZiel.Active then
    AZiel.Close;

  // Bringt das Ziel eigene Felder mit (persistente Felder, etwa weil
  // Lookups daranhaengen), darf coStructure sie nicht ersetzen - das wuerfe
  // die Lookups weg. Dann leer oeffnen und nur die Saetze anhaengen.
  if AZiel.FieldCount > 0 then
  begin
    AZiel.CreateDataSet;
    AZiel.CopyDataSet(LQuelle, [coRestart, coAppend]);
  end
  else
    AZiel.CopyDataSet(LQuelle, [coStructure, coRestart, coAppend]);

  finally
    LQuelle.Filtered := LWarGefiltert;
    LQuelle.Filter := LAlterFilter;

    if Assigned(LMaster) then
    begin
      AZiel.MasterSource := LMaster;
      if AZiel.MasterFields <> LFelder then
        AZiel.MasterFields := LFelder;
    end;
  end;
end;

procedure TdmModuleTemplate.DoWork(A, B: string; i_bShowForm: Boolean;pan:TPanel);
begin
  if i_bShowForm then
  begin
    if not Assigned(frmTemplate) then
      application.CreateForm(TfrmTemplate,frmTemplate);
    frmTemplate.parent := pan;
    frmTemplate.Align :=  alclient;
    frmTemplate.show;
  end;
end;

class function TdmModuleTemplate.GetInstance: TdmModuleTemplate;
begin
  if FInstance = nil then
  begin
    FLock.Acquire;
    try
      if FInstance = nil then
        FInstance := TdmModuleTemplate.Create(Application); // Owner ist Application
    finally
      FLock.Release;
    end;
  end;
  Result := FInstance;
end;

procedure TdmModuleTemplate.JvThread1AfterCreateDialogForm(
  DialogForm: TJvCustomThreadDialogForm);
begin
  self.JvThread1.Suspend;
end;

procedure TdmModuleTemplate.JvThread1Execute(Sender: TObject; Params: Pointer);
begin
   //hier kann der KhanCode rein
end;

procedure TdmModuleTemplate.ShowMessage(A, B: string);
begin
  vcl.dialogs.ShowMessage(a+b) ;
end;

class procedure TdmModuleTemplate.OpenGui(const ModulName: string);
var
  LEvent: IMyEvent;
begin
  LEvent := TMyEvent.Create(
    'Tdm'+ModulName, 'Open'+ModulName, '', '', '', '', '', False, mtModulCall, Now, False, 0, []);
  GlobalEventBus.Post(LEvent);
end;

initialization
  TdmModuleTemplate.FLock := TCriticalSection.Create;

finalization
  // Hier wird NICHTS freigegeben, und das ist Absicht.
  //
  // Die Module gehoeren Application und werden erst nach der finalization
  // dieser Unit abgeraeumt. Ihr Destructor greift dann auf Liste und Sperre
  // zu. Wer sie hier freigibt, bekommt beim Beenden Laufzeitfehler 217 --
  // auch mit FreeAndNil und Assigned-Pruefung, denn der Destructor kommt
  // ueber den EventBus noch an ganz anderen Stellen vorbei.
  //
  // Zwei Zeiger, die beim Prozessende ohnehin verschwinden, sind der
  // billigere Preis als ein Absturz beim Herunterfahren.

end.
