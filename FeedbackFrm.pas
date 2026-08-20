unit FeedbackFrm;

// Feedback-Dialog (QM-02) — Lob, Kritik, Verbesserungsvorschlag direkt aus
// der Anwendung heraus. Nach dem Muster von GraphLoginFrm: ein eigenstaendiger
// Dialog, per class function aufrufbar, kein MDI-Child.
//
// EIN-ZEILEN-AUFRUF FUER JEDES FORMULAR: FeedbackFrm.TfrmFeedback.Erfassen(
//   'KundenBestellung', AMandantId, APersonId);
// Absichtlich heute Nacht nur an EINER Stelle verdrahtet (Hauptfenster) statt
// in alle 28 Formulare eingebaut — das waere ein Eingriff in 28 einzelne
// Layouts gewesen, den ich nicht unbeaufsichtigt vornehmen wollte. Wo genau
// der Button in jedem Modul stehen soll, ist eine Layoutfrage, keine
// technische.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  FireDAC.Comp.Client;

type
  TfrmFeedback = class(TForm)
    lblTitel: TLabel;
    lblModul: TLabel;
    rgKategorie: TRadioGroup;
    lblText: TLabel;
    memText: TMemo;
    btnAbsenden: TButton;
    btnAbbrechen: TButton;
    procedure btnAbsendenClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
  private
    FModul: string;
    FMandantId: Integer;
    FPersonId: Integer;
  public
    class function Erfassen(const AModul: string; AMandantId: Integer;
      APersonId: Integer = 0): Boolean;
  end;

implementation

{$R *.dfm}

uses
  ZentraleDatenDm;

class function TfrmFeedback.Erfassen(const AModul: string; AMandantId: Integer;
  APersonId: Integer = 0): Boolean;
var
  LFrm: TfrmFeedback;
begin
  Result := False;
  LFrm := TfrmFeedback.Create(nil);
  try
    LFrm.FModul := AModul;
    LFrm.FMandantId := AMandantId;
    LFrm.FPersonId := APersonId;
    LFrm.lblModul.Caption := 'Modul: ' + AModul;
    Result := LFrm.ShowModal = mrOk;
  finally
    LFrm.Free;
  end;
end;

procedure TfrmFeedback.btnAbsendenClick(Sender: TObject);
var
  LQry: TFDQuery;
  LKategorie: string;
begin
  if Trim(memText.Text) = '' then
  begin
    ShowMessage('Bitte einen Text eingeben.');
    Exit;
  end;
  if FMandantId <= 0 then
  begin
    ShowMessage('Kein Mandant gew' + #228 + 'hlt - Feedback kann nicht ' +
      'zugeordnet werden.');
    Exit;
  end;

  case rgKategorie.ItemIndex of
    0: LKategorie := 'lob';
    1: LKategorie := 'kritik';
  else
    LKategorie := 'vorschlag';
  end;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := TdmZentraleDaten(TdmZentraleDaten.GetInstance).Verbindung;
    LQry.SQL.Text :=
      'INSERT INTO feedback (mandant_id, person_id, kategorie, modul, text_inhalt) ' +
      'VALUES (:m, :p, :k, :mo, :t)';
    LQry.ParamByName('m').AsInteger := FMandantId;
    if FPersonId > 0 then
      LQry.ParamByName('p').AsInteger := FPersonId
    else
      LQry.ParamByName('p').Clear;
    LQry.ParamByName('k').AsString := LKategorie;
    LQry.ParamByName('mo').AsString := FModul;
    LQry.ParamByName('t').AsString := memText.Text;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;

  ShowMessage('Danke f' + #252 + 'r die R' + #252 + 'ckmeldung!');
  ModalResult := mrOk;
end;

procedure TfrmFeedback.btnAbbrechenClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
