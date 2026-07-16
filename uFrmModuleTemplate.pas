unit uFrmModuleTemplate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions,
  Vcl.ActnList;

type
  TfrmTemplate = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    ActionList1: TActionList;
    Action1: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    constructor Create(AOwner:TComponent);
  end;

var
  frmTemplate: TfrmTemplate;

implementation

{$R *.dfm}

{ TForm2 }

constructor TfrmTemplate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TfrmTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self.Release;
end;

procedure TfrmTemplate.FormDestroy(Sender: TObject);
begin
  frmTemplate := nil;
end;

end.
