unit uFrmArtikelTemplate;

// Design-Vorlage für frm_artikel.pydfm — NICHT Teil des Heisenberg-Projekts.
// Workflow: hier im Delphi-Form-Designer visuell anpassen, dann exportieren
// lassen (Layout wird nach ..\frm_artikel.pydfm übertragen).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFrmArtikel = class(TForm)
    lblTitel: TLabel;
    ListBox1: TListBox;
    btnSchliessen: TButton;
  end;

var
  FrmArtikel: TFrmArtikel;

implementation

{$R *.dfm}

end.
