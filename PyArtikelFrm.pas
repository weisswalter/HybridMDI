unit PyArtikelFrm;

// MDI-Child-Host fuer das Python-Artikel-Fenster.
// Das eigentliche Python-Fenster (frm_artikel.py) wird per ParentWindow in
// dieses Delphi-Fenster eingehaengt (siehe ThreadTest\UHakan.py + Unit2.pas).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uFrmModuleTemplate;

type
  TfrmPyArtikel = class(TfrmTemplate)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  frmPyArtikel: TfrmPyArtikel;

implementation

{$R *.dfm}

procedure TfrmPyArtikel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmPyArtikel := nil;
end;

end.
