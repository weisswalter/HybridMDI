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
  MandantDm;

{$R *.dfm}

procedure TfrmMandantWaehlen.FormShow(Sender: TObject);
var
  LDm: TdmMandant;
  LMandantId, i, LSelectIndex: Integer;
begin
  LDm := TdmMandant(TdmMandant.GetInstance);
  LDm.LoadMandanten;
  cboMandant.Items.Clear;
  LSelectIndex := -1;
  LDm.qryMandant.First;
  while not LDm.qryMandant.Eof do
  begin
    LMandantId := LDm.qryMandant.FieldByName('mandant_id').AsInteger;
    i := cboMandant.Items.AddObject(
      LDm.qryMandant.FieldByName('mandanten_name').AsString,
      TObject(LMandantId));
    if LMandantId = LDm.CurrentMandantId then
      LSelectIndex := i;
    LDm.qryMandant.Next;
  end;
  if cboMandant.Items.Count > 0 then
  begin
    if LSelectIndex < 0 then
      LSelectIndex := 0;
    cboMandant.ItemIndex := LSelectIndex;
  end;
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
