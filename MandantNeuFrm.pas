unit MandantNeuFrm;

// Modaler Dialog zum Anlegen eines neuen Mandanten. Kein MDI-Child (bewusst
// kein Modul im ueblichen Sinn — nur ein einfacher Eingabedialog fuer
// TdmMandant.CreateMandant, direkt aus frmMain aufgerufen).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrmMandantNeu = class(TForm)
    lblName: TLabel;
    edtName: TEdit;
    btnOK: TButton;
    btnAbbrechen: TButton;
  private
    function GetMandantenName: string;
  public
    property MandantenName: string read GetMandantenName;
  end;

implementation

{$R *.dfm}

function TfrmMandantNeu.GetMandantenName: string;
begin
  Result := Trim(edtName.Text);
end;

end.
