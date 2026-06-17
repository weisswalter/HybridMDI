unit uFrmKunden;

// MDI-Child für Kunden. Hat keine Datenbanklogik — nur UI.
// Kommuniziert ausschliesslich via EventBus zurück zum DataModule.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmKunden = class(TForm)
    Panel1: TPanel;
    btnSpeichern: TButton;
    btnSchliessen: TButton;
    lblName: TLabel;
    edtName: TEdit;
    lblNummer: TLabel;
    edtNummer: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSchliessenClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
  end;

var
  frmKunden: TfrmKunden;

implementation

{$R *.dfm}

uses
  EventBus, uAppEvents;

procedure TfrmKunden.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmKunden.btnSchliessenClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmKunden.btnSpeichernClick(Sender: TObject);
begin
  GlobalEventBus.Post(TKundenResultEvent.Create(
    Format('Kunde %s / %s gespeichert', [edtNummer.Text, edtName.Text])
  ));
  Close;
end;

end.
