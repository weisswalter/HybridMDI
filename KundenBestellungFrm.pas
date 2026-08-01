unit KundenBestellungFrm;

// Modul 1: Kunde bestellt bei Hauptperson.
// Links (pnlStamm): Beleg-Kopf -- Kunde (Lookup gegen die Hauptperson-Kunden,
//   siehe dmKundenBestellung.qryPersonAuswahl), Beleg-Nr., Datum, Rechnungstyp
//   (Lookup, Kette Angebot..Rechnung -- vorgangsart selbst ist NICHT wählbar,
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
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  uFrmGuiTemplate, uFrmModuleTemplate, JvComponentBase, RibbonPanel;

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
    btnHinzufuegen: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rgArtClick(Sender: TObject);
    procedure btnHinzufuegenClick(Sender: TObject);
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
  KundenBestellungDm;

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

end.
