unit RibbonPageControl;

// PageControl, dessen Tabsheets die Komponente randlos ausfuellen.
//
// Von Hand gesetzte Left/Top/Width/Height am Tabsheet sehen richtig aus,
// werden aber bei jeder Groessenaenderung des PageControls von der VCL wieder
// ueberschrieben. Der Resize-Handler setzt sie danach erneut.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls;

type
  TRibbonPageControl = class(TPageControl)
  private
    { Private-Deklarationen }
    // SetBounds loest seinerseits eine Neuausrichtung aus, die wieder hier
    // landen wuerde
    FRichtetAus: Boolean;
  protected
    { Protected-Deklarationen }
    procedure Resize; override;
  public
    { Public-Deklarationen }
  published
    { Published-Deklarationen }
  end;

procedure Register;

implementation

procedure TRibbonPageControl.Resize;
var
  I: Integer;
begin
  inherited Resize;

  if FRichtetAus or (csDestroying in ComponentState) then
    Exit;

  FRichtetAus := True;
  try
    for I := 0 to PageCount - 1 do
      if Assigned(Pages[I]) then
      begin
        // alNone, sonst rechnet die VCL die Bounds sofort wieder um und die
        // Zuweisung darunter ist wirkungslos.
        Pages[I].Align := alNone;
        Pages[I].SetBounds(0, 0, Self.Width, Self.Height);
      end;
  finally
    FRichtetAus := False;
  end;
end;

procedure Register;
begin
  RegisterComponents('Heisenberg', [TRibbonPageControl]);
end;

end.
