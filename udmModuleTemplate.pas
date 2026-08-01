unit udmModuleTemplate;

interface

uses
  System.SysUtils, System.Classes, vcl.Dialogs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.Param, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, vcl.Forms,
  Vcl.ExtCtrls,Vcl.Controls, JvComponentBase, System.SyncObjs, JvThread,
  EventBus;

type
  TdmModuleTemplate = class(TDataModule)
    JvThread1: TJvThread;
    procedure JvThread1Execute(Sender: TObject; Params: Pointer);
    procedure JvThread1AfterCreateDialogForm(
      DialogForm: TJvCustomThreadDialogForm);
  private
    { Private-Deklarationen }
    class var FInstance: TdmModuleTemplate;
    class var FLock: TCriticalSection;
    procedure IdFelderHooksEinrichten;
  public
 { Public-Deklarationen }
    class function GetInstance: TdmModuleTemplate;
    // Blendet ID-Felder in der ANZEIGE aus. Die Felder bleiben im Dataset
    // vollstaendig erhalten und sind per Code weiter erreichbar -- nur
    // DB-aware Controls (TDBGrid ohne eigene Spaltendefinition) zeigen sie
    // nicht mehr. Wird fuer jedes Dataset des Moduls automatisch nach dem
    // Oeffnen aufgerufen, siehe IdFelderHooksEinrichten.
    class procedure IdFelderVerbergen(ADataSet: TDataSet);
    class function IstIdFeld(const AFeldName: string): Boolean;
    procedure ShowMessage(A,B:string);
    constructor Create(AOwner:TComponent);
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
  uMessageHandler;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

type
  // Haengt sich in das AfterOpen eines Datasets, ohne einen dort bereits
  // eingetragenen Handler zu verdraengen: der alte wird gemerkt und im
  // Anschluss weiterhin aufgerufen. Owner ist das Dataset selbst, der Hook
  // stirbt also mit ihm.
  TIdFelderHook = class(TComponent)
  private
    FDataSet: TDataSet;
    FAlterHandler: TDataSetNotifyEvent;
    procedure NachDemOeffnen(DataSet: TDataSet);
  public
    constructor Create(ADataSet: TDataSet); reintroduce;
  end;

constructor TIdFelderHook.Create(ADataSet: TDataSet);
begin
  inherited Create(ADataSet);
  FDataSet := ADataSet;
  FAlterHandler := ADataSet.AfterOpen;
  ADataSet.AfterOpen := NachDemOeffnen;
end;

procedure TIdFelderHook.NachDemOeffnen(DataSet: TDataSet);
begin
  TdmModuleTemplate.IdFelderVerbergen(DataSet);
  if Assigned(FAlterHandler) then
    FAlterHandler(DataSet);
end;

{ TdmModuleTemplate }

constructor TdmModuleTemplate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  IdFelderHooksEinrichten;
  GlobalEventBus.SilentRegisterSubscriberForEvents(Self);
end;

class function TdmModuleTemplate.IstIdFeld(const AFeldName: string): Boolean;
var
  LName: string;
begin
  LName := LowerCase(AFeldName);
  Result := (LName = 'id') or LName.EndsWith('_id');
end;

class procedure TdmModuleTemplate.IdFelderVerbergen(ADataSet: TDataSet);
var
  I: Integer;
begin
  if not Assigned(ADataSet) then
    Exit;
  for I := 0 to ADataSet.FieldCount - 1 do
    if IstIdFeld(ADataSet.Fields[I].FieldName) then
      ADataSet.Fields[I].Visible := False;
end;

procedure TdmModuleTemplate.IdFelderHooksEinrichten;
var
  I: Integer;
begin
  // Nach dem inherited Create sind die Komponenten der abgeleiteten
  // Klasse bereits aus der DFM geladen.
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TDataSet then
      TIdFelderHook.Create(TDataSet(Components[I]));
end;

destructor TdmModuleTemplate.Destroy;
begin
  GlobalEventBus.UnregisterForEvents(Self);
  inherited;
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
  TdmModuleTemplate.FLock.Free;

end.
