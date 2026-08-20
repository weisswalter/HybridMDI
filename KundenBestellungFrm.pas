unit KundenBestellungFrm;

// Modul 1: Kunde bestellt bei Hauptperson.
// Links (pnlStamm): Beleg-Kopf -- Kunde (Lookup gegen die Hauptperson-Kunden,
//   siehe dmKundenBestellung.qryPersonAuswahl), Beleg-Nr., Datum, Rechnungstyp
//   (Lookup, Kette Angebot..Rechnung -- belegart selbst ist NICHT wählbar,
//   die kommt fest aus dem Modul), Status, Bemerkung.
// Rechts (rbnpnl1): ein Tab "Positionen" -- Grid ueber beleg_position
//   + kleines Anlage-Panel darunter (Artikel/Leistung waehlen, Menge,
//   Einzelpreis, Button "Position hinzufuegen"). Artikel koennen auch
//   Leistungen sein (siehe beleg_position-CHECK in sql/rechnungstyp_beleg.sql) --
//   die RadioGroup entscheidet, welche der beiden ComboBoxen befuellt/benutzt
//   wird, dmKundenBestellung.AddPosition schreibt genau eines der Felder.

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
  TfrmKundenBestellung = class(TfrmGuiTemplate)
    lblKunde: TLabel;
    cboKunde: TDBLookupComboBox;
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
  frmKundenBestellung: TfrmKundenBestellung;

implementation

{$R *.dfm}

uses
  KundenBestellungDm, uBelegDruck;

function TfrmKundenBestellung.GetStammDataSource: TDataSource;
begin
  Result := dmKundenBestellung.dstblBeleg;
end;

function TfrmKundenBestellung.GetDetailDataSource(AHeaderIndex: Integer): TDataSource;
begin
  Result := dmKundenBestellung.dstblBelegPosition;
end;

procedure TfrmKundenBestellung.FormCreate(Sender: TObject);
begin
  FArtikelListe := TStringList.Create;
  FLeistungListe := TStringList.Create;
  dmKundenBestellung.LadeArtikelAuswahl(FArtikelListe);
  dmKundenBestellung.LadeLeistungAuswahl(FLeistungListe);
  rgArt.ItemIndex := 0;
  cboAuswahl.Items.Assign(FArtikelListe);
end;

procedure TfrmKundenBestellung.FormDestroy(Sender: TObject);
begin
  FArtikelListe.Free;
  FLeistungListe.Free;
end;

procedure TfrmKundenBestellung.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmKundenBestellung := nil;
end;

procedure TfrmKundenBestellung.rgArtClick(Sender: TObject);
begin
  cboAuswahl.ItemIndex := -1;
  if rgArt.ItemIndex = 0 then
    cboAuswahl.Items.Assign(FArtikelListe)
  else
    cboAuswahl.Items.Assign(FLeistungListe);
end;

procedure TfrmKundenBestellung.btnHinzufuegenClick(Sender: TObject);
var
  LMenge, LEinzelpreis: Double;
  LId: Integer;
begin
  if dmKundenBestellung.tblBeleg.IsEmpty then
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
    dmKundenBestellung.AddPosition(LId, 0, LMenge, LEinzelpreis)
  else
    dmKundenBestellung.AddPosition(0, LId, LMenge, LEinzelpreis);

  edtMenge.Clear;
  edtEinzelpreis.Clear;
  cboAuswahl.ItemIndex := -1;
end;



procedure TfrmKundenBestellung.btnVisierenClick(Sender: TObject);
begin
  if dmKundenBestellung.tblBeleg.IsEmpty then
    Exit;
  if MessageDlg('Beleg visieren? Danach l'#228'sst er sich nicht mehr '#228'ndern.',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  memDruckLog.Text := dmKundenBestellung.BelegVisieren;
end;

procedure TfrmKundenBestellung.btnPdfClick(Sender: TObject);
var
  LDruck: TBelegDruck;
  LTex, LPdf, LVorlage: string;
begin
  if dmKundenBestellung.tblBeleg.IsEmpty then
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
        LTex := LDruck.ErzeugeTex(dmKundenBestellung.tblBeleg, dmKundenBestellung.tblBelegPosition,
                  TexMaskieren(dmKundenBestellung.Absender));
        // Die Quelle festhalten: sie friert die Darstellung ein.
        dmKundenBestellung.TexSpeichern(LTex);

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
