unit LagerEntnahmeFrm;

// Modul 3: Lehrer reserviert oder entnimmt Artikel aus dem Lager.
// Strukturell wie KundenBestellungFrm/LieferantenBestellungFrm (siehe dort) --
// Gegenpartei ist hier der Lehrer. Zusaetzlich: Checkbox "Rueckgabe erwartet"
// beim Anlegen einer Position (manche Artikel -- z.B. Werkzeug -- kommen nach
// Benutzung zurueck) und ein Button "Rueckgabe verbuchen" fuer die aktuell im
// Grid selektierte Position (setzt beleg_position.rueckgegeben_am).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, System.IOUtils, Winapi.ShellAPI, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  uFrmGuiTemplate, uFrmModuleTemplate, JvComponentBase, Vcl.Mask, RibbonPanel,
  System.ImageList, Vcl.ImgList, JvImageList, RibbonButtonBar;

type
  TfrmLagerEntnahme = class(TfrmGuiTemplate)
    lblLehrer: TLabel;
    cboLehrer: TDBLookupComboBox;
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
   //  Detailseite "Positionen"
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
    cbxRueckgabe: TCheckBox;
    btnHinzufuegen: TButton;
    btnRueckgabeVerbuchen: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rgArtClick(Sender: TObject);
    procedure btnHinzufuegenClick(Sender: TObject);
    procedure btnVisierenClick(Sender: TObject);
    procedure btnPdfClick(Sender: TObject);
    procedure btnRueckgabeVerbuchenClick(Sender: TObject);
  private
    FArtikelListe: TStringList;
    FLeistungListe: TStringList;
  protected
    function GetStammDataSource: TDataSource; override;
    function GetDetailDataSource(AHeaderIndex: Integer): TDataSource; override;
  end;

var
  frmLagerEntnahme: TfrmLagerEntnahme;

implementation

{$R *.dfm}

uses
  LagerEntnahmeDm, uBelegDruck;

function TfrmLagerEntnahme.GetStammDataSource: TDataSource;
begin
  Result := dmLagerEntnahme.dstblBeleg;
end;

function TfrmLagerEntnahme.GetDetailDataSource(AHeaderIndex: Integer): TDataSource;
begin
  Result := dmLagerEntnahme.dstblBelegPosition;
end;

procedure TfrmLagerEntnahme.FormCreate(Sender: TObject);
begin
  FArtikelListe := TStringList.Create;
  FLeistungListe := TStringList.Create;
  dmLagerEntnahme.LadeArtikelAuswahl(FArtikelListe);
  dmLagerEntnahme.LadeLeistungAuswahl(FLeistungListe);
  rgArt.ItemIndex := 0;
  cboAuswahl.Items.Assign(FArtikelListe);
end;

procedure TfrmLagerEntnahme.FormDestroy(Sender: TObject);
begin
  FArtikelListe.Free;
  FLeistungListe.Free;
end;

procedure TfrmLagerEntnahme.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmLagerEntnahme := nil;
end;

procedure TfrmLagerEntnahme.rgArtClick(Sender: TObject);
begin
  cboAuswahl.ItemIndex := -1;
  if rgArt.ItemIndex = 0 then
    cboAuswahl.Items.Assign(FArtikelListe)
  else
    cboAuswahl.Items.Assign(FLeistungListe);
end;

procedure TfrmLagerEntnahme.btnHinzufuegenClick(Sender: TObject);
var
  LMenge, LEinzelpreis: Double;
  LId: Integer;
begin
  if dmLagerEntnahme.tblBeleg.IsEmpty then
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
    dmLagerEntnahme.AddPosition(LId, 0, LMenge, LEinzelpreis, cbxRueckgabe.Checked)
  else
    dmLagerEntnahme.AddPosition(0, LId, LMenge, LEinzelpreis, cbxRueckgabe.Checked);

  edtMenge.Clear;
  edtEinzelpreis.Clear;
  cboAuswahl.ItemIndex := -1;
  cbxRueckgabe.Checked := False;
end;

procedure TfrmLagerEntnahme.btnRueckgabeVerbuchenClick(Sender: TObject);
begin
  dmLagerEntnahme.MarkiereRueckgabe;
end;



procedure TfrmLagerEntnahme.btnVisierenClick(Sender: TObject);
begin
  if dmLagerEntnahme.tblBeleg.IsEmpty then
    Exit;
  if MessageDlg('Beleg visieren? Danach l'#228'sst er sich nicht mehr '#228'ndern.',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  memDruckLog.Text := dmLagerEntnahme.BelegVisieren;
end;

procedure TfrmLagerEntnahme.btnPdfClick(Sender: TObject);
var
  LDruck: TBelegDruck;
  LTex, LPdf, LVorlage: string;
begin
  if dmLagerEntnahme.tblBeleg.IsEmpty then
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
        LTex := LDruck.ErzeugeTex(dmLagerEntnahme.tblBeleg, dmLagerEntnahme.tblBelegPosition,
                  TexMaskieren(dmLagerEntnahme.Absender));
        // Die Quelle festhalten: sie friert die Darstellung ein.
        dmLagerEntnahme.TexSpeichern(LTex);

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
