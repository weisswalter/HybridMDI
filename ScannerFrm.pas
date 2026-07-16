unit ScannerFrm;

// MDI-Child: zusammengefuehrtes Scanner-Konfigurationsfenster.
// Tab 1 "Scannerauswahl": Treiberart (WIA / TWAIN) + Geraeteliste dazu.
// Tab 2 "Einstellungen":  Scan-Parameter inkl. Scannerfach (Flachbett / Einzug).
//
// Ersetzt inhaltlich die zwei getrennten DelphiTwain-Dialoge
// (DelphiTwain_SelectForm + DelphiTwain_SettingsForm) durch ein einziges Fenster.
//
// GERUEST — Tabs noch leer. Fuell-Logik wird nach dem Vorbild der o.g. Dialoge
// ergaenzt, der eigentliche Scan-Aufruf geht ueber dmScanner (MessageHandler-faehig).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls,
  uFrmModuleTemplate;

type
  TfrmScanner = class(TfrmTemplate)
    pgcScanner: TPageControl;
    tabAuswahl: TTabSheet;
    tabEinstellungen: TTabSheet;
    rgTreiberart: TRadioGroup;
    pnlAuswahlTop: TPanel;
    btnAktualisieren: TButton;
    lstGeraete: TListBox;
    rgScannerfach: TRadioGroup;
    lblFachHinweis: TLabel;
    btnScanStart: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure rgTreiberartClick(Sender: TObject);
    procedure btnAktualisierenClick(Sender: TObject);
    procedure pgcScannerChange(Sender: TObject);
    procedure btnScanStartClick(Sender: TObject);
  private
    { Private-Deklarationen }
    // Fuellt lstGeraete je nach gewaehlter Treiberart (WIA live, TWAIN folgt).
    procedure RefreshDevices;
    // Fuellt rgScannerfach anhand der Capabilities des gewaehlten WIA-Geraets.
    procedure RefreshFach;
  public
    { Public-Deklarationen }
  end;

var
  frmScanner: TfrmScanner;

implementation

uses
  ScannerDm;

{$R *.dfm}

procedure TfrmScanner.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmScanner := nil;
end;

procedure TfrmScanner.FormShow(Sender: TObject);
begin
  RefreshDevices;
end;

procedure TfrmScanner.rgTreiberartClick(Sender: TObject);
begin
  RefreshDevices;
end;

procedure TfrmScanner.btnAktualisierenClick(Sender: TObject);
begin
  RefreshDevices;
end;

procedure TfrmScanner.pgcScannerChange(Sender: TObject);
begin
  if pgcScanner.ActivePage = tabEinstellungen then
    RefreshFach;
end;

procedure TfrmScanner.RefreshFach;
var
  caps, wiaIndex: Integer;
begin
  rgScannerfach.Items.Clear;
  rgScannerfach.Enabled := True;

  // TWAIN-Fach (PaperFeeding pfFlatbed/pfFeeder) kommt im naechsten Schritt.
  if rgTreiberart.ItemIndex = 1 then
  begin
    lblFachHinweis.Caption := 'TWAIN-Fach folgt im naechsten Schritt.';
    rgScannerfach.Enabled := False;
    Exit;
  end;

  if lstGeraete.ItemIndex < 0 then
  begin
    lblFachHinweis.Caption := 'Bitte zuerst im Tab "Scannerauswahl" ein Geraet waehlen.';
    rgScannerfach.Enabled := False;
    Exit;
  end;

  wiaIndex := lstGeraete.ItemIndex + 1; // WIA-Collection ist 1-basiert
  try
    caps := TdmScanner(TdmScanner.GetInstance).GetWiaDocHandlingCaps(wiaIndex);
  except
    on E: Exception do
    begin
      lblFachHinweis.Caption := 'Capabilities konnten nicht gelesen werden: ' + E.Message;
      rgScannerfach.Enabled := False;
      Exit;
    end;
  end;

  lblFachHinweis.Caption :=
    Format('Geraet: %s   (DocumentHandlingCapabilities = %d)',
           [lstGeraete.Items[lstGeraete.ItemIndex], caps]);

  // WIA-Standard-Bits: 1=Einzug/Feeder, 2=Flachbett, 4=Duplex
  if (caps and 2) <> 0 then rgScannerfach.Items.Add('Flachbett');
  if (caps and 1) <> 0 then rgScannerfach.Items.Add('Einzug (ADF)');
  if (caps and 4) <> 0 then rgScannerfach.Items.Add('Duplex (ADF beidseitig)');
  if rgScannerfach.Items.Count = 0 then
    rgScannerfach.Items.Add('Flachbett');
  rgScannerfach.ItemIndex := 0;
end;

procedure TfrmScanner.RefreshDevices;
begin
  lstGeraete.Clear;
  case rgTreiberart.ItemIndex of
    0: // WIA
      try
        TdmScanner(TdmScanner.GetInstance).EnumWiaDevices(lstGeraete.Items);
      except
        on E: Exception do
          lstGeraete.Items.Add('WIA-Fehler: ' + E.Message);
      end;
    1: // TWAIN
      try
        TdmScanner(TdmScanner.GetInstance).EnumTwainDevices(lstGeraete.Items);
        if lstGeraete.Count = 0 then
          lstGeraete.Items.Add('(kein TWAIN-Treiber gefunden)');
      except
        on E: Exception do
          lstGeraete.Items.Add('TWAIN-Fehler: ' + E.Message);
      end;
  end;
end;

procedure TfrmScanner.btnScanStartClick(Sender: TObject);
var
  wiaIndex, sel: Integer;
  fach: string;
begin
  if rgTreiberart.ItemIndex <> 0 then
  begin
    ShowMessage('Scan ist aktuell nur fuer WIA implementiert (TWAIN folgt).');
    Exit;
  end;
  if lstGeraete.ItemIndex < 0 then
  begin
    ShowMessage('Bitte im Tab "Scannerauswahl" ein Geraet waehlen.');
    Exit;
  end;
  if rgScannerfach.ItemIndex < 0 then
  begin
    ShowMessage('Bitte ein Scannerfach waehlen.');
    Exit;
  end;

  wiaIndex := lstGeraete.ItemIndex + 1;   // WIA-Collection ist 1-basiert
  fach := rgScannerfach.Items[rgScannerfach.ItemIndex];
  if Pos('Duplex', fach) > 0 then
    sel := 5
  else if Pos('Einzug', fach) > 0 then
    sel := 1
  else
    sel := 2;   // Flachbett

  TdmScanner(TdmScanner.GetInstance).ScanWia(wiaIndex, sel);
end;

end.
