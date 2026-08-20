unit uTunnel;

{
  SSH-Tunnel als Teil des Programms.

  ZWECK: Damit eine Exe bei jemandem laufen kann, der keinen Tunnel von Hand
  aufbaut. Das Programm startet `ssh.exe` versteckt als Kindprozess, wartet
  bis der Port antwortet, und beendet ihn beim Schliessen wieder.

  WARUM UEBERHAUPT: Postgres direkt ins Internet zu stellen hiesse, den
  Datenbankport der Welt anzubieten. Der Tunnel verlegt das auf SSH, und der
  Schluessel darf serverseitig nichts als genau diesen einen Port weiter-
  reichen:

    command="/bin/false",no-pty,no-agent-forwarding,no-X11-forwarding,
    permitopen="127.0.0.1:5432" ssh-ed25519 AAAA...

  Ein abhandengekommener Schluessel ist damit kein Serverzugang, sondern nur
  ein Kabel zur Datenbank — und davor steht immer noch die Anmeldung.

  ssh.exe bringt Windows seit 10/1809 selbst mit; es muss nichts
  mitinstalliert werden. Fehlt es doch, sagt das die Fehlermeldung.
}

interface

uses
  Winapi.Windows, Winapi.WinSock, System.SysUtils, System.Classes,
  System.SyncObjs;

type
  TTunnelZustand = (tzAus, tzStartet, tzOffen, tzFehler);

  TTunnelMeldung = procedure(Sender: TObject; const AText: string) of object;

  TSshTunnel = class
  private
    FProzess:      TProcessInformation;
    FLaeuft:       Boolean;
    FZustand:      TTunnelZustand;
    FFehler:       string;
    FLokalerPort:  Integer;
    FZielHost:     string;
    FZielPort:     Integer;
    FBenutzer:     string;
    FServer:       string;
    FServerPort:   Integer;
    FSchluessel:   string;
    FOnMeldung:    TTunnelMeldung;
    procedure Melde(const AText: string);
    function  Kommandozeile: string;
  public
    constructor Create;
    destructor Destroy; override;

    // Baut den Tunnel auf und wartet, bis der lokale Port antwortet.
    // ATimeoutMs begrenzt das Warten; 0 heisst nicht warten.
    function Oeffnen(ATimeoutMs: Integer = 15000): Boolean;
    procedure Schliessen;

    // Sucht ab AAb einen freien lokalen Port. Der Griff daneben war schon
    // einmal teuer: ein belegter Port laesst den Tunnel still scheitern,
    // und die Anwendung landet auf einer ganz anderen Datenbank.
    class function FreierPort(AAb: Integer = 5455): Integer;
    class function PortAntwortet(APort: Integer): Boolean;
    class function SshVorhanden: Boolean;
    class function SshPfad: string;

    property Zustand: TTunnelZustand read FZustand;
    property Fehler: string read FFehler;
    property Laeuft: Boolean read FLaeuft;

    // Verbindungsangaben
    property LokalerPort: Integer read FLokalerPort write FLokalerPort;
    property ZielHost: string read FZielHost write FZielHost;
    property ZielPort: Integer read FZielPort write FZielPort;
    property Benutzer: string read FBenutzer write FBenutzer;
    property Server: string read FServer write FServer;
    property ServerPort: Integer read FServerPort write FServerPort;
    property Schluessel: string read FSchluessel write FSchluessel;

    property OnMeldung: TTunnelMeldung read FOnMeldung write FOnMeldung;
  end;

implementation

uses
  Winapi.Winsock2;

{ TSshTunnel }

constructor TSshTunnel.Create;
begin
  inherited;
  FZustand    := tzAus;
  FZielHost   := '127.0.0.1';
  FZielPort   := 5432;
  FServerPort := 22;
  FLokalerPort := 0;      // 0 = beim Oeffnen einen freien suchen
end;

destructor TSshTunnel.Destroy;
begin
  Schliessen;
  inherited;
end;

procedure TSshTunnel.Melde(const AText: string);
begin
  if Assigned(FOnMeldung) then
    FOnMeldung(Self, AText);
end;

class function TSshTunnel.SshPfad: string;
begin
  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('SystemRoot')) +
            'System32\OpenSSH\ssh.exe';
  if not FileExists(Result) then
    Result := '';
end;

class function TSshTunnel.SshVorhanden: Boolean;
begin
  Result := SshPfad <> '';
end;

// Fragt, ob auf dem Port schon jemand horcht. Wird zweimal gebraucht:
// zum Suchen eines freien Ports und zum Warten auf den fertigen Tunnel.
class function TSshTunnel.PortAntwortet(APort: Integer): Boolean;
var
  LSocket: TSocket;
  LAdresse: TSockAddrIn;
  LDaten: TWSAData;
begin
  Result := False;
  if WSAStartup($0202, LDaten) <> 0 then
    Exit;
  try
    LSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if LSocket = INVALID_SOCKET then
      Exit;
    try
      FillChar(LAdresse, SizeOf(LAdresse), 0);
      LAdresse.sin_family := AF_INET;
      LAdresse.sin_port   := htons(APort);
      LAdresse.sin_addr.S_addr := inet_addr('127.0.0.1');
      Result := connect(LSocket, TSockAddr(LAdresse), SizeOf(LAdresse)) = 0;
    finally
      closesocket(LSocket);
    end;
  finally
    WSACleanup;
  end;
end;

class function TSshTunnel.FreierPort(AAb: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := AAb to AAb + 50 do
    if not PortAntwortet(I) then
      Exit(I);
end;

function TSshTunnel.Kommandozeile: string;
begin
  Result := Format('"%s" -N -o ExitOnForwardFailure=yes ' +
    '-o StrictHostKeyChecking=accept-new -o ServerAliveInterval=30 ' +
    '-o ServerAliveCountMax=3 -o BatchMode=yes -L %d:%s:%d',
    [SshPfad, FLokalerPort, FZielHost, FZielPort]);

  if FSchluessel <> '' then
    Result := Result + Format(' -i "%s"', [FSchluessel]);
  if FServerPort <> 22 then
    Result := Result + Format(' -p %d', [FServerPort]);

  Result := Result + Format(' %s@%s', [FBenutzer, FServer]);
end;

function TSshTunnel.Oeffnen(ATimeoutMs: Integer): Boolean;
var
  LStartInfo: TStartupInfo;
  LKommando: string;
  LEnde: Cardinal;
  LExit: Cardinal;
begin
  Result  := False;
  FFehler := '';

  if FLaeuft then
    Exit(True);

  if not SshVorhanden then
  begin
    FFehler := 'ssh.exe wurde nicht gefunden. Der OpenSSH-Client fehlt ' +
      '(Windows-Einstellungen, Optionale Features).';
    FZustand := tzFehler;
    Exit;
  end;
  if (FServer = '') or (FBenutzer = '') then
  begin
    FFehler := 'Server oder Benutzer fehlt.';
    FZustand := tzFehler;
    Exit;
  end;
  if (FSchluessel <> '') and not FileExists(FSchluessel) then
  begin
    FFehler := Format('Schluesseldatei "%s" nicht gefunden.', [FSchluessel]);
    FZustand := tzFehler;
    Exit;
  end;

  if FLokalerPort = 0 then
    FLokalerPort := FreierPort;
  if FLokalerPort = 0 then
  begin
    FFehler := 'Kein freier lokaler Port gefunden.';
    FZustand := tzFehler;
    Exit;
  end;

  FZustand := tzStartet;
  LKommando := Kommandozeile;
  Melde('Tunnel wird aufgebaut auf Port ' + IntToStr(FLokalerPort));

  FillChar(LStartInfo, SizeOf(LStartInfo), 0);
  LStartInfo.cb := SizeOf(LStartInfo);
  LStartInfo.dwFlags := STARTF_USESHOWWINDOW;
  LStartInfo.wShowWindow := SW_HIDE;

  if not CreateProcess(nil, PChar(LKommando), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, LStartInfo, FProzess) then
  begin
    FFehler := 'ssh.exe liess sich nicht starten: ' +
      SysErrorMessage(GetLastError);
    FZustand := tzFehler;
    Exit;
  end;

  FLaeuft := True;

  if ATimeoutMs <= 0 then
  begin
    FZustand := tzOffen;
    Exit(True);
  end;

  // Warten, bis der Port antwortet. Vorher darf sich niemand verbinden —
  // sonst greift die Anwendung ins Leere oder, schlimmer, auf eine lokale
  // Datenbank, die zufaellig auf demselben Port liegt.
  LEnde := GetTickCount + Cardinal(ATimeoutMs);
  while GetTickCount < LEnde do
  begin
    // Ist ssh schon wieder weg, hat es sich beschwert — nicht weiterwarten.
    if GetExitCodeProcess(FProzess.hProcess, LExit) and (LExit <> STILL_ACTIVE) then
    begin
      FFehler := 'ssh.exe hat sich sofort beendet (Rueckgabe ' +
        IntToStr(LExit) + '). Schluessel, Benutzer oder Freigabe pruefen.';
      FZustand := tzFehler;
      Schliessen;
      Exit;
    end;

    if PortAntwortet(FLokalerPort) then
    begin
      FZustand := tzOffen;
      Melde('Tunnel steht.');
      Exit(True);
    end;
    Sleep(150);
  end;

  FFehler := 'Zeitueberschreitung beim Aufbau des Tunnels.';
  FZustand := tzFehler;
  Schliessen;
end;

procedure TSshTunnel.Schliessen;
begin
  if not FLaeuft then
    Exit;
  // Ohne das bleiben ssh-Prozesse stehen und belegen den Port fuer den
  // naechsten Start.
  TerminateProcess(FProzess.hProcess, 0);
  CloseHandle(FProzess.hThread);
  CloseHandle(FProzess.hProcess);
  FLaeuft  := False;
  FZustand := tzAus;
  Melde('Tunnel geschlossen.');
end;

end.
