unit UInterfaces;

interface
uses
   System.Rtti;
type
  EMessageType =(mtMessage, mtModulCall, mtException, mtPython, mtCSharp, mtCPlus, mtJava);
  IMyEvent = interface(IInterface)
    ['{3522E1C5-547F-4AB6-A799-5B3D3574D2FA}']
    // Routing — bei mtModulCall: GetMessage=Klassenname, GetSender=Methodenname
    function GetMessage: string;
    function GetSender: string;
    function GetTarget: string;
    function GetSenderMethod: string;
    function GetTargetMethod: string;
    // Fortsetzungskette — nach Abschluss dieser Aktion
    function GetNextTarget: string;
    function GetNextMethod: string;
    // Ausführungskontext
    function GetRunInThread: Boolean;
    function GetMessageType: EMessageType;
    // Meta
    function GetTimestamp: TDateTime;
    function GetShowGui: Boolean;
    function GetLogLevel: Integer;
    // Payload
    function GetParams: TArray<TValue>;
  end;


implementation

end.
