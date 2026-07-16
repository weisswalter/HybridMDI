unit LagerFrm;

// MDI-Child: Lagerverwaltung (Tabelle lager, flach — keine Bruecken).
// Buttonleiste im Ribbon-Stil wie PersonenFrm (TJvNavPanelButtonTop +
// TJvGradient), darunter Eingabefelder inkl. Adress-Lookup, Beschreibung,
// Photo und QR-Code (beide als Blob mit Lade-Button), unten das Grid.
// Beschriftungen aus resourcestrings (Buttons ueber ihren Tag).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtDlgs, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Data.DB, Vcl.StdCtrls, Vcl.Mask,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  JvDBControls, JvDBLookup,
  uFrmModuleTemplate;

type
  // Reihenfolge = Tag der Buttons in der Leiste (wie PersonenFrm)
  TLagerAktion = (laErster, laZurueck, laWeiter, laLetzter,
    laNeu, laBearbeiten, laSpeichern, laAbbrechen, laAktualisieren);

  TfrmLager = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    pnlButtons: TPanel;
    btnErster, btnZurueck, btnWeiter, btnLetzter, btnNeu, btnAendern,
    btnSpeichern, btnAbbrechen, btnNeuLaden: TJvNavPanelButtonTop;
    grdtButtons: TJvGradient;
    pnlFelder: TPanel;
    lblBarcode: TLabel;
    edtBarcode: TJvDBMaskEdit;
    lblRaum: TLabel;
    edtRaum: TJvDBMaskEdit;
    lblRegal: TLabel;
    edtRegal: TJvDBMaskEdit;
    lblAdresse: TLabel;
    cboAdresse: TJvDBLookupCombo;
    lblBeschreibung: TLabel;
    memBeschreibung: TDBMemo;
    lblPhoto: TLabel;
    imgPhoto: TDBImage;
    btnPhotoLaden: TButton;
    lblQrCode: TLabel;
    imgQrCode: TDBImage;
    btnQrLaden: TButton;
    grdLager: TDBGrid;
    dlgBild: TOpenPictureDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnNavClick(Sender: TObject);
    procedure btnPhotoLadenClick(Sender: TObject);
    procedure btnQrLadenClick(Sender: TObject);
  private
    procedure SetzeBeschriftungen;
    procedure LadeBild(const AFeld: string);
  public
  end;

var
  frmLager: TfrmLager;

implementation

{$R *.dfm}

uses
  LagerDm;

resourcestring
  SFormCaption      = 'Lager';
  SBtnErster        = 'Erster';
  SBtnZurueck       = 'Zur'#252'ck';
  SBtnWeiter        = 'Weiter';
  SBtnLetzter       = 'Letzter';
  SBtnNeu           = 'Neu';
  SBtnBearbeiten    = #196'ndern';
  SBtnSpeichern     = 'Speichern';
  SBtnAbbrechen     = 'Abbrechen';
  SBtnAktualisieren = 'Neu laden';
  SLblBarcode       = 'Barcode';
  SLblRaum          = 'Raum';
  SLblRegal         = 'Regal';
  SLblAdresse       = 'Adresse';
  SLblBeschreibung  = 'Beschreibung';
  SLblPhoto         = 'Photo';
  SLblQrCode        = 'QR-Code';
  SBtnBildLaden     = 'Bild laden...';

function NavCaption(A: TLagerAktion): string;
begin
  case A of
    laErster:        Result := SBtnErster;
    laZurueck:       Result := SBtnZurueck;
    laWeiter:        Result := SBtnWeiter;
    laLetzter:       Result := SBtnLetzter;
    laNeu:           Result := SBtnNeu;
    laBearbeiten:    Result := SBtnBearbeiten;
    laSpeichern:     Result := SBtnSpeichern;
    laAbbrechen:     Result := SBtnAbbrechen;
    laAktualisieren: Result := SBtnAktualisieren;
  else
    Result := '';
  end;
end;

procedure TfrmLager.FormCreate(Sender: TObject);
begin
  SetzeBeschriftungen;
end;

procedure TfrmLager.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmLager := nil;
end;

procedure TfrmLager.SetzeBeschriftungen;
var
  I: Integer;
begin
  Caption := SFormCaption;
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TJvNavPanelButtonTop then
      TJvNavPanelButtonTop(Components[I]).Caption :=
        NavCaption(TLagerAktion(Components[I].Tag));
  lblBarcode.Caption      := SLblBarcode;
  lblRaum.Caption         := SLblRaum;
  lblRegal.Caption        := SLblRegal;
  lblAdresse.Caption      := SLblAdresse;
  lblBeschreibung.Caption := SLblBeschreibung;
  lblPhoto.Caption        := SLblPhoto;
  lblQrCode.Caption       := SLblQrCode;
  btnPhotoLaden.Caption   := SBtnBildLaden;
  btnQrLaden.Caption      := SBtnBildLaden;
end;

// Ein Handler fuer alle Leisten-Buttons; die Aktion steckt im Tag.
// Ein Dataset, keine Bruecken — Neu ist ein simples Append (mandant_id
// setzt LagerOnNewRecord, lager_id kommt via RETURNING).
procedure TfrmLager.BtnNavClick(Sender: TObject);
var
  LDs: TDataSet;
begin
  LDs := dmLager.dstblLager.DataSet;
  if (LDs = nil) or not LDs.Active then
    Exit;

  case TLagerAktion((Sender as TComponent).Tag) of
    laErster:        LDs.First;
    laZurueck:       LDs.Prior;
    laWeiter:        LDs.Next;
    laLetzter:       LDs.Last;
    laNeu:           LDs.Append;
    laBearbeiten:    if not LDs.IsEmpty then LDs.Edit;
    laSpeichern:     if LDs.State in dsEditModes then LDs.Post;
    laAbbrechen:     if LDs.State in dsEditModes then LDs.Cancel;
    laAktualisieren: if LDs.State = dsBrowse then LDs.Refresh;
  end;
end;

// Bilddatei in ein Blob-Feld des aktuellen Lager-Satzes laden.
// Vcl.Imaging.jpeg/pngimage in uses -> TDBImage zeigt JPG/PNG an.
procedure TfrmLager.LadeBild(const AFeld: string);
begin
  if dmLager.tblLager.IsEmpty and not (dmLager.tblLager.State in dsEditModes) then
    Exit;
  if not dlgBild.Execute then
    Exit;
  if not (dmLager.tblLager.State in dsEditModes) then
    dmLager.tblLager.Edit;
  TBlobField(dmLager.tblLager.FieldByName(AFeld)).LoadFromFile(dlgBild.FileName);
end;

procedure TfrmLager.btnPhotoLadenClick(Sender: TObject);
begin
  LadeBild('photo');
end;

procedure TfrmLager.btnQrLadenClick(Sender: TObject);
begin
  LadeBild('qrcode');
end;

end.
