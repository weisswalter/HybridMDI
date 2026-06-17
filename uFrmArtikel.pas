unit uFrmArtikel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmArtikel = class(TForm)
    Panel1: TPanel;
    btnSpeichern: TButton;
    btnSchliessen: TButton;
    lblArtNr: TLabel;
    edtArtNr: TEdit;
    lblBezeichnung: TLabel;
    edtBezeichnung: TEdit;
    lblPreis: TLabel;
    edtPreis: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSchliessenClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
  end;

var
  frmArtikel: TfrmArtikel;

implementation

{$R *.dfm}

uses
  EventBus, uAppEvents;

procedure TfrmArtikel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmArtikel.btnSchliessenClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmArtikel.btnSpeichernClick(Sender: TObject);
begin
  GlobalEventBus.Post(TArtikelResultEvent.Create(
    Format('Artikel %s / %s / EUR %s gespeichert', [edtArtNr.Text, edtBezeichnung.Text, edtPreis.Text])
  ));
  Close;
end;

end.
