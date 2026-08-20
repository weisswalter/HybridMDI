unit LoginFrm;

// Anmeldedialog. Laeuft beim Programmstart, BEVOR das Hauptfenster erscheint.
//
// ZWEI BETRIEBSARTEN, damit sich niemand aussperrt:
//   Gibt es noch KEINEN globalen Administrator, zeigt der Dialog die
//   ERSTEINRICHTUNG — man legt den ersten Zugang direkt hier an. Danach
//   verhaelt er sich wie ein normaler Anmeldedialog.
//
// Wer den Dialog abbricht, beendet das Programm — ohne Anmeldung gibt es
// keinen Arbeitskontext. Ausnahme ist der Fall, dass ueberhaupt keine
// Benutzer existieren; dann wird der Dialog gar nicht erst gezeigt (siehe
// TdmBenutzer.AnmeldungErforderlich und Heisenberg.dpr).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrmLogin = class(TForm)
    lblTitel: TLabel;
    lblName: TLabel;
    edtName: TEdit;
    lblPasswort: TLabel;
    edtPasswort: TEdit;
    lblPasswort2: TLabel;
    edtPasswort2: TEdit;
    lblHinweis: TLabel;
    btnOK: TButton;
    btnAbbrechen: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
  private
    FErsteinrichtung: Boolean;
  public
    // True = angemeldet (oder Ersteinrichtung erfolgreich), False = abgebrochen
    class function Anmelden: Boolean;
  end;

implementation

{$R *.dfm}

uses
  BenutzerDm;

class function TfrmLogin.Anmelden: Boolean;
var
  LFrm: TfrmLogin;
begin
  LFrm := TfrmLogin.Create(nil);
  try
    Result := LFrm.ShowModal = mrOk;
  finally
    LFrm.Free;
  end;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  FErsteinrichtung := not dmBenutzer.GibtEsGlobalenAdmin;

  lblPasswort2.Visible := FErsteinrichtung;
  edtPasswort2.Visible := FErsteinrichtung;

  if FErsteinrichtung then
  begin
    Caption := 'Ersteinrichtung';
    lblTitel.Caption := 'Ersten Zugang anlegen';
    lblHinweis.Caption :=
      'Es gibt noch keinen Administrator. Der hier angelegte Zugang wird ' +
      'globaler Administrator im Stammmandanten - er sieht alle Mandanten ' +
      'und kann weitere Benutzer anlegen. Mindestens 8 Zeichen.';
    btnOK.Caption := 'Anlegen';
  end
  else
  begin
    Caption := 'Anmeldung';
    lblTitel.Caption := 'Anmeldung';
    lblHinweis.Caption := '';
    btnOK.Caption := 'Anmelden';
  end;

  edtName.SetFocus;
end;

procedure TfrmLogin.btnOKClick(Sender: TObject);
var
  LMeldung: string;
begin
  if Trim(edtName.Text) = '' then
  begin
    ShowMessage('Bitte einen Anmeldenamen eingeben.');
    edtName.SetFocus;
    Exit;
  end;

  if FErsteinrichtung then
  begin
    if edtPasswort.Text <> edtPasswort2.Text then
    begin
      ShowMessage('Die beiden Passw' + #246 + 'rter stimmen nicht ' + #252 +
        'berein.');
      edtPasswort2.SetFocus;
      Exit;
    end;

    LMeldung := dmBenutzer.ErstenAdminAnlegen(Trim(edtName.Text),
      edtPasswort.Text);
    if LMeldung <> '' then
    begin
      ShowMessage(LMeldung);
      Exit;
    end;

    // Direkt anmelden, damit der Sitzungszustand steht
    LMeldung := dmBenutzer.Anmelden(Trim(edtName.Text), edtPasswort.Text);
    if LMeldung <> '' then
    begin
      ShowMessage(LMeldung);
      Exit;
    end;
    ModalResult := mrOk;
    Exit;
  end;

  LMeldung := dmBenutzer.Anmelden(Trim(edtName.Text), edtPasswort.Text);
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    edtPasswort.Clear;
    edtPasswort.SetFocus;
    Exit;
  end;

  ModalResult := mrOk;
end;

procedure TfrmLogin.btnAbbrechenClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
