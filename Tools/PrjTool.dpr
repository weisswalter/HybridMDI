program PrjTool;

uses
  Vcl.Forms,
  bmpMaker in 'bmpMaker.pas' {Form1},
  GanttPanel in 'GanttPanel.pas',
  uFrmGanttTest in 'uFrmGanttTest.pas' {frmGanttTest};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmGanttTest, frmGanttTest);
  Application.Run;
end.
