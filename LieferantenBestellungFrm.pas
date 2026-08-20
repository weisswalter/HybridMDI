unit LieferantenBestellungFrm;

// Modul 2: Hauptperson bestellt bei Lieferant.
// Strukturell identisch zu KundenBestellungFrm (siehe dort) -- Gegenpartei
// ist hier der Lieferant statt der Kunde.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, System.IOUtils, Winapi.ShellAPI, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  uFrmGuiTemplate, uFrmModuleTemplate, JvComponentBase, RibbonPanel, Vcl.Mask,
  System.ImageList, Vcl.ImgList, JvImageList, RibbonButtonBar;

type
  TfrmLieferantenBestellung = class(TfrmGuiTemplate)
    lblLieferant: TLabel;
    cboLieferant: TDBLookupComboBox;
    lblBelegNr: TLabel;
    edtBelegNr: TDBEdit;
    lblBelegDatum: TLabel;
    edtBelegDatum: TDBEdit;
    lblRechnungstyp: TLabel;
    cboRechnungstyp: TDBLookupComboBox;
    lblStatus: TLabel;
    cboStatus: TDBComboBox;
    lblBemerkung: TLabel;
    memBemerkung: TDBMemo;
    // Detailseite "Positionen"
    tsPositionen: TTabSheet;
    // Detailseite "Druck"
    tsDruck: TTabSheet;
    btnVisieren: TJvNavPanelButtonTop;
    btnPdf: TJvNavPanelButtonTop;
    memDruckLog: TMemo;
    dbgrdPositionen: TDBGrid;
    pnlPositionAdd: TPanel;
    rgArt: TRadioGroup;
    lblAuswahl: TLabel;
    cboAuswahl: TComboBox;
    lblMenge: TLabel;
    edtMenge: TEdit;
    lblEinzelpreis: TLabel;
    edtEinzelpreis: TEdit;
    btnHinzufuegen: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rgArtClick(Sender: TObject);
    procedure btnHinzufuegenClick(Sender: TObject);
    procedure btnVisierenClick(Sender: TObject);
    procedure btnPdfClick(Sender: TObject);
  private
    FArtikelListe: TStringList;
    FLeistungListe: TStringList;
  protected
    function GetStammDataSource: TDataSource; override;
    function GetDetailDataSource(AHeaderIndex: Integer): TDataSource; override;
  end;

var
  frmLieferantenBestellung: TfrmLieferantenBestellung;

implementation

{$R *.dfm}

uses
  LieferantenBestellungDm, uBelegDruck;

function TfrmLieferantenBestellung.GetStammDataSource: TDataSource;
begin
  Result := dmLieferantenBestellung.dstblBeleg;
end;

function TfrmLieferantenBestellung.GetDetailDataSource(AHeaderIndex: Integer): TDataSource;
begin
  Result := dmLieferantenBestellung.dstblBelegPosition;
end;

procedure TfrmLieferantenBestellung.FormCreate(Sender: TObject);
begin
  FArtikelListe := TStringList.Create;
  FLeistungListe := TStringList.Create;
  dmLieferantenBestellung.LadeArtikelAuswahl(FArtikelListe);
  dmLieferantenBestellung.LadeLeistungAuswahl(FLeistungListe);
  rgArt.ItemIndex := 0;
  cboAuswahl.Items.Assign(FArtikelListe);
end;

procedure TfrmLieferantenBestellung.FormDestroy(Sender: TObject);
begin
  FArtikelListe.Free;
  FLeistungListe.Free;
end;

procedure TfrmLieferantenBestellung.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmLieferantenBestellung := nil;
end;

procedure TfrmLieferantenBestellung.rgArtClick(Sender: TObject);
begin
  cboAuswahl.ItemIndex := -1;
  if rgArt.ItemIndex = 0 then
    cboAuswahl.Items.Assign(FArtikelListe)
  else
    cboAuswahl.Items.Assign(FLeistungListe);
end;

procedure TfrmLieferantenBestellung.btnHinzufuegenClick(Sender: TObject);
var
  LMenge, LEinzelpreis: Double;
  LId: Integer;
begin
  if dmLieferantenBestellung.tblBeleg.IsEmpty then
  begin
    ShowMessage('Bitte zuerst einen Beleg anlegen oder ausw'#228'hlen.');
    Exit;
  end;
  if cboAuswahl.ItemIndex < 0 then
  begin
    ShowMessage('Bitte einen Artikel bzw. eine Leistung ausw'#228'hlen.');
    Exit;
  end;
  if not TryStrToFloat(edtMenge.Text, LMenge) then
  begin
    ShowMessage('Ung'#252'ltige Menge.');
    Exit;
  end;
  LEinzelpreis := 0;
  if (Trim(edtEinzelpreis.Text) <> '') and not TryStrToFloat(edtEinzelpreis.Text, LEinzelpreis) then
  begin
    ShowMessage('Ung'#252'ltiger Einzelpreis.');
    Exit;
  end;

  LId := Integer(NativeInt(cboAuswahl.Items.Objects[cboAuswahl.ItemIndex]));
  if rgArt.ItemIndex = 0 then
    dmLieferantenBestellung.AddPosition(LId, 0, LMenge, LEinzelpreis)
  else
    dmLieferantenBestellung.AddPosition(0, LId, LMenge, LEinzelpreis);

  edtMenge.Clear;
  edtEinzelpreis.Clear;
  cboAuswahl.ItemIndex := -1;
end;



procedure TfrmLieferantenBestellung.btnVisierenClick(Sender: TObject);
begin
  if dmLieferantenBestellung.tblBeleg.IsEmpty then
    Exit;
  if MessageDlg('Beleg visieren? Danach l'#228'sst er sich nicht mehr '#228'ndern.',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  memDruckLog.Text := dmLieferantenBestellung.BelegVisieren;
end;

procedure TfrmLieferantenBestellung.btnPdfClick(Sender: TObject);
var
  LDruck: TBelegDruck;
  LTex, LPdf, LVorlage: string;
begin
  if dmLieferantenBestellung.tblBeleg.IsEmpty then
    Exit;

  // Vorlage neben der Exe. Spaeter gehoert der Pfad in die Einstellungen -
  // beim Kunden liegt TeX woanders oder gar nicht.
  LVorlage := TPath.Combine(TPath.Combine(
                ExtractFilePath(Application.ExeName), 'vorlagen'), 'beleg.tex');

  Screen.Cursor := crHourGlass;
  try
    try
      LDruck := TBelegDruck.Create(LVorlage);
      try
        LTex := LDruck.ErzeugeTex(dmLieferantenBestellung.tblBeleg, dmLieferantenBestellung.tblBelegPosition,
                  TexMaskieren(dmLieferantenBestellung.Absender));
        // Die Quelle festhalten: sie friert die Darstellung ein.
        dmLieferantenBestellung.TexSpeichern(LTex);

        if LDruck.Kompiliere(LTex, 'beleg', LPdf) then
        begin
          memDruckLog.Text := 'PDF erzeugt: ' + LPdf;
          ShellExecute(0, 'open', PChar(LPdf), nil, nil, SW_SHOWNORMAL);
        end
        else
          memDruckLog.Text := LDruck.Log;
      finally
        LDruck.Free;
      end;
    except
      on E: Exception do
        memDruckLog.Text := E.ClassName + ': ' + E.Message;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
