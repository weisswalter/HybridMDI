program TunnelTest;

{
  Prueft den eingebauten SSH-Tunnel gegen den echten Server — ohne GUI.

  Aufruf: TunnelTest <Benutzer> <Server> <Schluesseldatei> [LokalerPort]
}

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Diagnostics,
  uTunnel in '..\uTunnel.pas';

type
  TLauscher = class
    procedure Meldung(Sender: TObject; const AText: string);
  end;

procedure TLauscher.Meldung(Sender: TObject; const AText: string);
begin
  Writeln('  [Tunnel] ' + AText);
end;

var
  LTunnel: TSshTunnel;
  LLauscher: TLauscher;
  LUhr: TStopwatch;
begin
  if ParamCount < 3 then
  begin
    Writeln('Aufruf: TunnelTest <Benutzer> <Server> <Schluessel> [Port]');
    Halt(1);
  end;

  Writeln('== Tunneltest ==');
  Writeln('ssh.exe gefunden: ', BoolToStr(TSshTunnel.SshVorhanden, True));
  Writeln('ssh-Pfad: ', TSshTunnel.SshPfad);
  Writeln('');

  LLauscher := TLauscher.Create;
  LTunnel := TSshTunnel.Create;
  try
    LTunnel.OnMeldung  := LLauscher.Meldung;
    LTunnel.Benutzer   := ParamStr(1);
    LTunnel.Server     := ParamStr(2);
    LTunnel.Schluessel := ParamStr(3);
    if ParamCount >= 4 then
      LTunnel.LokalerPort := StrToIntDef(ParamStr(4), 0);

    Writeln('Freier Port ab 5455: ', TSshTunnel.FreierPort(5455));
    Writeln('');

    LUhr := TStopwatch.StartNew;
    if LTunnel.Oeffnen(15000) then
    begin
      Writeln(Format('OFFEN nach %d ms auf lokalem Port %d',
        [LUhr.ElapsedMilliseconds, LTunnel.LokalerPort]));
      Writeln('Port antwortet: ',
        BoolToStr(TSshTunnel.PortAntwortet(LTunnel.LokalerPort), True));
      Writeln('');
      Writeln('--- Schliessen ---');
      LTunnel.Schliessen;
      Sleep(500);
      Writeln('Port antwortet danach noch: ',
        BoolToStr(TSshTunnel.PortAntwortet(LTunnel.LokalerPort), True));
    end
    else
      Writeln('FEHLER: ', LTunnel.Fehler);
  finally
    LTunnel.Free;
    LLauscher.Free;
  end;
end.
