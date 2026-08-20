program TestRibbon;
{$APPTYPE CONSOLE}
// Laedt das Hauptfenster, ohne es anzuzeigen, und misst je Schalter die
// tatsaechliche Textbreite mit seiner eigenen Schrift. Gemeldet wird, wo die
// Beschriftung nicht hineinpasst - Schaetzen fuehrt hier zu abgeschnittenen
// Woertern.
uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.ComCtrls,
  Vcl.Controls, JvNavigationPane, JvNavPanelButtonTop,
  uFrmMain;

const
  cRand = 20;   // Luft links und rechts, damit nichts klebt

var
  LF: TfrmMain;
  I, J: Integer;
  LTab: TTabSheet;
  LBtn: TJvNavPanelButtonTop;
  LMess: TBitmap;
  LBreite, LEng: Integer;
begin
  LEng := 0;
  try
    Application.ShowMainForm := False;
    Application.Initialize;
    LF := TfrmMain.Create(nil);
    LMess := TBitmap.Create;
    try
      Writeln('Kopfschalter:');
      for I := 0 to LF.pnlRibbon.ControlCount - 1 do
        if LF.pnlRibbon.Controls[I] is TJvNavPanelHeader then
          with TJvNavPanelHeader(LF.pnlRibbon.Controls[I]) do
          begin
            LMess.Canvas.Font := Font;
            LBreite := LMess.Canvas.TextWidth(Caption);
            Writeln(Format('  Tag=%d %-14s Text=%3d  Breite=%3d  %s',
              [Tag, Caption, LBreite, Width,
               BoolToStr(Width >= LBreite + cRand, True)]));
          end;

      Writeln;
      for I := 0 to LF.pctrRibbon.PageCount - 1 do
      begin
        LTab := LF.pctrRibbon.Pages[I];
        Writeln(Format('%d %s', [I, LTab.Name]));
        for J := 0 to LTab.ControlCount - 1 do
          if LTab.Controls[J] is TJvNavPanelButtonTop then
          begin
            LBtn := TJvNavPanelButtonTop(LTab.Controls[J]);
            LMess.Canvas.Font := LBtn.Font;
            LBreite := LMess.Canvas.TextWidth(LBtn.Caption);
            if LBtn.Width < LBreite + cRand then
            begin
              Inc(LEng);
              Writeln(Format('   ZU ENG  %-20s Text=%3d  Breite=%3d  fehlen %d',
                [LBtn.Caption, LBreite, LBtn.Width,
                 LBreite + cRand - LBtn.Width]));
            end
            else
              Writeln(Format('   ok      %-20s Text=%3d  Breite=%3d',
                [LBtn.Caption, LBreite, LBtn.Width]));
          end;
      end;

      Writeln;
      if LEng = 0 then Writeln('Alle Beschriftungen passen.')
                  else Writeln(LEng, ' Schalter sind zu schmal.');
    finally
      LMess.Free;
      LF.Free;
    end;
  except
    on E: Exception do
      Writeln('FEHLER ', E.ClassName, ': ', E.Message);
  end;
  Halt(0);
end.
