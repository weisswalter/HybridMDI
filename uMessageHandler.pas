unit uMessageHandler;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, Vcl.Forms, EventBus, UInterfaces;

type

  TMyEvent = class(TInterfacedObject, IMyEvent)
  private
    FMessage:     string;
    FSender:      string;
    FTarget:      string;
    FSenderMethod: string;
    FTargetMethod: string;
    FNextTarget:  string;
    FNextMethod:  string;
    FRunInThread: Boolean;
    FMessageType: EMessageType;
    FTimestamp:   TDateTime;
    FShowGui:     Boolean;
    FLogLevel:    Integer;
    FParams:      TArray<TValue>;
  public
    // Routing
    function GetMessage: string;
    function GetSender: string;
    function GetTarget: string;
    function GetSenderMethod: string;
    function GetTargetMethod: string;
    // Fortsetzungskette
    function GetNextTarget: string;
    function GetNextMethod: string;
    // Ausf�hrungskontext
    function GetRunInThread: Boolean;
    function GetMessageType: EMessageType;
    // Meta
    function GetTimestamp: TDateTime;
    function GetShowGui: Boolean;
    function GetLogLevel: Integer;
    // Payload
    function GetParams: TArray<TValue>;

    constructor Create(
      const AMessage:      string;
      const ASender:       string;
      const ATarget:       string;
      const ASenderMethod: string;
      const ATargetMethod: string;
      const ANextTarget:   string;
      const ANextMethod:   string;
      ARunInThread:        Boolean;
      AMessageType:        EMessageType;
      ATimestamp:          TDateTime;
      AShowGui:            Boolean;
      ALogLevel:           Integer;
      const AParams:       TArray<TValue>
    );
  end;


  TCentralMessageHandler = class
  private
    FContext: TRttiContext;
  public
    constructor Create;
    destructor Destroy; override;
    procedure HandleMessage(const AMessage, ASender, ATarget, ASenderMethod,
  ATargetMethod, ANextTarget, ANextMethod: string; ARunInThread: Boolean;
  AMessageType: EMessageType; ATimestamp: TDateTime; AShowGui: Boolean;
  ALogLevel: Integer; const AParams: TArray<TValue>);
    [Subscribe]
    procedure OnMyEvent(AEvent: IMyEvent);
  end;

  TdmMessageHandler = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    MessageHandler: TCentralMessageHandler;
  end;

var
  dmMessageHandler: TdmMessageHandler;

implementation

uses
  Vcl.Dialogs,
  CSharpDm;   // fuer den mtCSharp-Zweig in HandleMessage

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TCentralMessageHandler }

constructor TCentralMessageHandler.Create;
begin
  FContext := TRttiContext.Create;
  GlobalEventBus.RegisterSubscriberForEvents(Self);
end;

destructor TCentralMessageHandler.Destroy;
begin
  GlobalEventBus.UnregisterForEvents(Self);
  FContext.Free;
  inherited;
end;

procedure TCentralMessageHandler.HandleMessage(const AMessage, ASender, ATarget, ASenderMethod,
  ATargetMethod, ANextTarget, ANextMethod: string; ARunInThread: Boolean;
  AMessageType: EMessageType; ATimestamp: TDateTime; AShowGui: Boolean;
  ALogLevel: Integer; const AParams: TArray<TValue>);
var
  RttiType: TRttiType;
  rttiInstanceType: TRttiInstanceType;
  RttiMethod: TRttiMethod;
  Instance: TObject;
  getInstanceMethod: TRttiMethod;
begin
  case AMessageType of
    mtMessage: showmessage(Amessage);
    mtModulCall:
    begin
      for RttiType in FContext.GetTypes do
      begin
        if RttiType.Name = AMessage then
        begin
          for rttiMethod in rttiType.GetMethods do
          begin
            if SameText(rttiMethod.Name, ASender) then
            begin
              // Pr�fen, ob GetInstance existiert
              getInstanceMethod := rttiType.GetMethod('GetInstance');
              if Assigned(getInstanceMethod) then
              begin
                // Singleton-Instanz holen
                instance := getInstanceMethod.Invoke(rttiType.AsInstance.MetaclassType, []).AsObject;
                // Methode aufrufen
                rttiMethod.Invoke(instance, AParams);
                Exit;
              end
              else
                raise Exception.CreateFmt('Klasse %s hat keine GetInstance-Methode.', [AMessage]);
            end;
          end;
        end;
      end;
      raise Exception.CreateFmt('Module or Method not found: %s.%s', [AMessage, ASender]);
    end;
    // C#-Seite ueber die Python-Bruecke (BridgePOC-Muster, siehe CSharpDm):
    //   AMessage = Name des Python-Moduls (z.B. 'mail_caller')
    //   ASender  = Name der Funktion darin (z.B. 'fetch_inbox')
    //   AParams  = Argumente, nur Standardtypen (TValueToPyLiteral)
    // Analog zu mtModulCall, nur dass die Arbeit in C# statt in Delphi passiert.
    mtCSharp:
      TdmCSharp(TdmCSharp.GetInstance).Call(AMessage, ASender, AParams);
    mtException:  raise Exception.CreateFmt('Es ist ein Fehler aufgetreten: %s.%s', [AMessage, ASender]);
  end;
end;

procedure TCentralMessageHandler.OnMyEvent(AEvent: IMyEvent);
begin
 // handleMessage(AEvent.GetMessage, AEvent.GetSender , AEvent.GetTimestamp, AEvent.GetShowGui, AEvent.GetLogLevel, AEvent.GetMessageType, AEvent.GetParams);
handleMessage(
  AEvent.GetMessage,
  AEvent.GetSender,
  AEvent.GetTarget,
  AEvent.GetSenderMethod,
  AEvent.GetTargetMethod,
  AEvent.GetNextTarget,
  AEvent.GetNextMethod,
  AEvent.GetRunInThread,
  AEvent.GetMessageType,
  AEvent.GetTimestamp,
  AEvent.GetShowGui,
  AEvent.GetLogLevel,
  AEvent.GetParams
);
 end;





{ TMyEvent }

//constructor TMyEvent.Create(
//�����  AParams: Integer);
//begin
// // FMessage := AMessage;
//end;


function TMyEvent.GetMessage: string;
begin
  Result := FMessage;
end;

function TMyEvent.GetSender: string;
begin
  Result := FSender;
end;

function TMyEvent.GetSenderMethod: string;
begin
  Result := FSenderMethod;
end;

function TMyEvent.GetTarget: string;
begin
  Result := FTarget;
end;

function TMyEvent.GetTargetMethod: string;
begin
  Result := FTargetMethod;
end;

function TMyEvent.GetTimestamp: TDateTime;
begin
  Result := FTimestamp;
end;

function TMyEvent.GetParams: TArray<TValue>;
begin
  Result := FParams;
end;

function TMyEvent.GetRunInThread: Boolean;
begin
  Result := FRunInThread;
end;

function TMyEvent.GetShowGui: Boolean;
begin
  Result := FShowGui;
end;

constructor TMyEvent.Create(const AMessage, ASender, ATarget, ASenderMethod,
  ATargetMethod, ANextTarget, ANextMethod: string; ARunInThread: Boolean;
  AMessageType: EMessageType; ATimestamp: TDateTime; AShowGui: Boolean;
  ALogLevel: Integer; const AParams: TArray<TValue>);
begin
  FMessage     := AMessage;
  FSender      := ASender;
  FTarget      := ATarget;
  FSenderMethod := ASenderMethod;
  FTargetMethod := ATargetMethod;
  FNextTarget  := ANextTarget;
  FNextMethod  := ANextMethod;
  FRunInThread := ARunInThread;
  FTimestamp   := ATimestamp;
  FShowGui     := AShowGui;
  FLogLevel    := ALogLevel;
  FMessageType := AMessageType;
  FParams      := AParams;
end;



function TMyEvent.GetLogLevel: integer;
begin
  Result := FLogLevel;
end;

function TMyEvent.GetMessageType: EMessageType;
begin
  Result := FMessageType;
end;

function TMyEvent.GetNextMethod: string;
begin
  Result := FNextMethod;
end;

function TMyEvent.GetNextTarget: string;
begin
  Result := FNextTarget
end;

{ TdmMessageHandler }

procedure TdmMessageHandler.DataModuleCreate(Sender: TObject);
begin
  MessageHandler := TCentralMessageHandler.Create;
end;

procedure TdmMessageHandler.DataModuleDestroy(Sender: TObject);
begin
  MessageHandler.Free;
end;

end.

