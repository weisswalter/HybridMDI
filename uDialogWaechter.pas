unit uDialogWaechter;

// Fuer Konsolen-Pruefstaende: faengt modale Dialoge (ShowMessage,
// MessageDlg) ab, schreibt ihren Text in die Konsole und schliesst sie.
// Ohne das bleibt ein Pruefstand stehen, sobald irgendwo eine Meldung
// kommt - und man sieht nicht einmal, welche.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.ExtCtrls, Vcl.Forms;

type
  TDialogWaechter = class
  private
    FTimer: TTimer;
    procedure Tick(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
  end;

// Startet den Waechter (einmal am Anfang des Pruefstands aufrufen).
procedure WaechterStarten;

implementation

var
  GWaechter: TDialogWaechter;
  GTexte: TStringList;

function KindText(AFenster: HWND; AParam: LPARAM): BOOL; stdcall;
var
  LPuffer: array[0..1023] of Char;
begin
  if GetWindowText(AFenster, LPuffer, Length(LPuffer)) > 0 then
    GTexte.Add(Trim(LPuffer));
  Result := True;
end;

function DialogSuchen(AFenster: HWND; AParam: LPARAM): BOOL; stdcall;
var
  LKlasse: array[0..63] of Char;
  LTitel: array[0..255] of Char;
begin
  Result := True;
  if not IsWindowVisible(AFenster) then
    Exit;
  GetClassName(AFenster, LKlasse, Length(LKlasse));
  if string(LKlasse) <> '#32770' then   // die Fensterklasse jedes Dialogs
    Exit;
  GetWindowText(AFenster, LTitel, Length(LTitel));

  GTexte.Clear;
  EnumChildWindows(AFenster, @KindText, 0);
  Writeln;
  Writeln('  *** MELDUNGSFENSTER "', LTitel, '" ***');
  Writeln('      ', StringReplace(GTexte.Text, sLineBreak, ' | ',
    [rfReplaceAll]));
  Flush(Output);

  // Wegklicken, sonst steht der Pruefstand.
  PostMessage(AFenster, WM_COMMAND, IDOK, 0);
  PostMessage(AFenster, WM_CLOSE, 0, 0);
end;

{ TDialogWaechter }

constructor TDialogWaechter.Create;
begin
  inherited Create;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 300;
  FTimer.OnTimer := Tick;
  FTimer.Enabled := True;
end;

destructor TDialogWaechter.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TDialogWaechter.Tick(Sender: TObject);
begin
  EnumThreadWindows(GetCurrentThreadId, @DialogSuchen, 0);
end;

procedure WaechterStarten;
begin
  if not Assigned(GWaechter) then
    GWaechter := TDialogWaechter.Create;
end;

initialization
  GTexte := TStringList.Create;

finalization
  GTexte.Free;

end.
