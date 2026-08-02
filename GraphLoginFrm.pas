unit GraphLoginFrm;

// Anmeldung bei Microsoft per Geraetecode — der sichtbare Teil des Verfahrens
// aus MailGraph.pas.
//
// ABLAUF: Das Programm holt bei Microsoft einen kurzen Code. Der Anwender
// tippt ihn auf einer Microsoft-Seite ein und meldet sich dort ganz normal an
// (samt zweitem Faktor, falls die Firma das verlangt). Waehrend er das tut,
// fragt das Programm im Sekundentakt nach, ob es schon geklappt hat.
//
// WARUM EIN EIGENES FENSTER: Der Vorgang dauert und braucht Platz — Code zum
// Ablesen, Link zum Anklicken, Abbruchmoeglichkeit. Im Reiter "Konto" ist
// beides nicht vorhanden. Es ist ein Dialog, kein Modul, deshalb ausnahmsweise
// kein MDI-Child.
//
// WICHTIG ZUM WARTEN: Der Abruf laeuft synchron im Hauptthread (wie der
// Brueckenweg auch). Damit das Fenster waehrend der Wartezeit bedienbar
// bleibt, verarbeitet Warten() Nachrichten. Der Aufrufer sperrt sich
// derweil selbst — sonst koennte man mitten in der Anmeldung einen zweiten
// Abruf starten.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrmGraphLogin = class(TForm)
    lblTitel: TLabel;
    lblErklaerung: TLabel;
    lblCodeText: TLabel;
    edtCode: TEdit;
    btnSeite: TButton;
    btnKopieren: TButton;
    lblStatus: TLabel;
    btnAbbrechen: TButton;
    procedure btnSeiteClick(Sender: TObject);
    procedure btnKopierenClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FUrl: string;
    FAbbruch: Boolean;
  public
    // Die drei Ereignisse, die TGraphMail waehrend der Anmeldung ruft
    procedure CodeAnzeigen(Sender: TObject;
      const AUserCode, AUrl, AHinweis: string);
    procedure Warten(Sender: TObject; ASekunden: Integer;
      var AAbbrechen: Boolean);
    procedure StatusZeigen(Sender: TObject; const AText: string);

    // Fuehrt die ganze Anmeldung durch und liefert die Meldung von
    // TGraphMail ('OK: ...' / 'FEHLER: ...').
    class function Anmelden(AKontoId: Integer): string;
  end;

implementation

{$R *.dfm}

uses
  Winapi.ShellAPI, System.DateUtils, Vcl.Clipbrd,
  MailDm;

class function TfrmGraphLogin.Anmelden(AKontoId: Integer): string;
var
  LFrm: TfrmGraphLogin;
begin
  LFrm := TfrmGraphLogin.Create(Application);
  try
    LFrm.Show;
    LFrm.StatusZeigen(nil, 'Code wird bei Microsoft angefordert ...');
    Application.ProcessMessages;
    Result := dmMail.GraphAnmelden(AKontoId, LFrm.CodeAnzeigen, LFrm.Warten,
      LFrm.StatusZeigen);
  finally
    LFrm.Free;
  end;
end;

procedure TfrmGraphLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Das Fenster wird von Anmelden() freigegeben, nicht von sich selbst —
  // sonst zieht man dem laufenden Vorgang die Ereignisziele weg.
  FAbbruch := True;
  Action := caHide;
end;

procedure TfrmGraphLogin.CodeAnzeigen(Sender: TObject;
  const AUserCode, AUrl, AHinweis: string);
begin
  FUrl := AUrl;
  edtCode.Text := AUserCode;
  if AHinweis <> '' then
    lblErklaerung.Caption := AHinweis
  else
    lblErklaerung.Caption := 'Bitte die Seite ' + AUrl + ' im Browser '#246'ffnen ' +
      'und dort diesen Code eingeben.';
  btnSeite.Enabled := AUrl <> '';
  btnKopieren.Enabled := AUserCode <> '';
  StatusZeigen(nil, 'Warte auf die Anmeldung im Browser ...');
  Application.ProcessMessages;
end;

// Laesst die Zeit verstreichen UND haelt das Fenster bedienbar. Ein blosses
// Sleep wuerde die Oberflaeche fuer die ganze Wartezeit einfrieren — bei bis
// zu 15 Minuten waere das nicht zumutbar.
procedure TfrmGraphLogin.Warten(Sender: TObject; ASekunden: Integer;
  var AAbbrechen: Boolean);
var
  LEnde: TDateTime;
begin
  LEnde := IncSecond(Now, ASekunden);
  while (Now < LEnde) and not FAbbruch do
  begin
    Application.ProcessMessages;
    Sleep(50);
  end;
  AAbbrechen := FAbbruch;
end;

procedure TfrmGraphLogin.StatusZeigen(Sender: TObject; const AText: string);
begin
  lblStatus.Caption := AText;
  lblStatus.Update;
end;

procedure TfrmGraphLogin.btnSeiteClick(Sender: TObject);
begin
  if FUrl = '' then
    Exit;
  ShellExecute(0, 'open', PChar(FUrl), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmGraphLogin.btnKopierenClick(Sender: TObject);
begin
  if edtCode.Text = '' then
    Exit;
  Clipboard.AsText := edtCode.Text;
  StatusZeigen(nil, 'Code in die Zwischenablage kopiert.');
end;

procedure TfrmGraphLogin.btnAbbrechenClick(Sender: TObject);
begin
  FAbbruch := True;
  StatusZeigen(nil, 'Wird abgebrochen ...');
end;

end.
