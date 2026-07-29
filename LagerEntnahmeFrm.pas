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
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvRibbonPanel,
  uFrmGuiTemplate, uFrmModuleTemplate, JvComponentBase;

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
    // Detailseite "Positionen"
    pnlPositionen: TPanel;
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
  LagerEntnahmeDm;

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

end.
