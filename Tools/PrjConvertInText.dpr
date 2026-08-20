program PrjConvertInText;

uses
  Vcl.Forms,
  Convert in 'Convert.pas' {ConvertForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TConvertForm, ConvertForm);
  Application.Run;
end.
