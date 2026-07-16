unit uFrmKundenTemplate;

// Design-Vorlage für frm_kunden.pydfm — NICHT Teil des Heisenberg-Projekts.
// Workflow: hier im Delphi-Form-Designer visuell anpassen, dann exportieren
// lassen (Layout wird nach ..\frm_kunden.pydfm übertragen).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFrmKunden = class(TForm)
    lblTitel: TLabel;
    ListBox1: TListBox;
    btnSchliessen: TButton;
  end;

var
  FrmKunden: TFrmKunden;

implementation

{$R *.dfm}

end.
