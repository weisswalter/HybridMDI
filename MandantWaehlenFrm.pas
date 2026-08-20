unit MandantWaehlenFrm;

// Modaler Dialog zur Mandantenauswahl. Fuell-Logik 1:1 aus frmMain.RefreshMandantCombo
// uebernommen (TdmMandant.LoadMandanten + qryMandant), nur in ein eigenes Fenster
// verlagert statt fest in frmMain zu sitzen. Der aktuell aktive Mandant
// (TdmMandant.CurrentMandantId) wird beim Oeffnen vorausgewaehlt.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrmMandantWaehlen = class(TForm)
    lblMandant: TLabel;
    cboMandant: TComboBox;
    btnOK: TButton;
    btnAbbrechen: TButton;
    procedure FormShow(Sender: TObject);
  private
    function GetSelectedMandantId: Integer;
    function GetSelectedMandantName: string;
  public
    property SelectedMandantId: Integer read GetSelectedMandantId;
    property SelectedMandantName: string read GetSelectedMandantName;
  end;

implementation

uses
  MandantDm, BenutzerDm;

{$R *.dfm}

// Zeigt NUR die Mandanten, die der angemeldete Benutzer sehen darf. Der
// globale Administrator (Rolle administrator im Stammmandanten) bekommt alle,
// alle anderen genau ihre zugeordneten - das ist die Stelle, an der Walters
// Regel "wer zu Mandant 3 gehoert, kann nur Dinge aus Mandant 3 machen"
// tatsaechlich wirkt.
//
// Ist niemand angemeldet (noch kein Benutzer angelegt), liefert
// LadeErlaubteMandanten alle - dann verhaelt sich der Dialog wie bisher.
procedure TfrmMandantWaehlen.FormShow(Sender: TObject);
var
  LDm: TdmMandant;
  LMandantId, i, LSelectIndex: Integer;
begin
  LDm := TdmMandant(TdmMandant.GetInstance);
  dmBenutzer.LadeErlaubteMandanten(cboMandant.Items);

  LSelectIndex := -1;
  for i := 0 to cboMandant.Items.Count - 1 do
  begin
    LMandantId := Integer(NativeInt(cboMandant.Items.Objects[i]));
    if LMandantId = LDm.CurrentMandantId then
      LSelectIndex := i;
  end;

  if cboMandant.Items.Count > 0 then
  begin
    if LSelectIndex < 0 then
      LSelectIndex := 0;
    cboMandant.ItemIndex := LSelectIndex;
  end
  else
    ShowMessage('F' + #252 + 'r Ihren Zugang ist kein Mandant freigegeben. ' +
      'Bitte an den Administrator wenden.');
end;

function TfrmMandantWaehlen.GetSelectedMandantId: Integer;
begin
  if cboMandant.ItemIndex >= 0 then
    Result := Integer(cboMandant.Items.Objects[cboMandant.ItemIndex])
  else
    Result := 0;
end;

function TfrmMandantWaehlen.GetSelectedMandantName: string;
begin
  if cboMandant.ItemIndex >= 0 then
    Result := cboMandant.Items[cboMandant.ItemIndex]
  else
    Result := '';
end;

end.
