unit DokumenteFrm;

// MDI-Child: Dokumentenverwaltung — Kurztest ob DB-Änderungen auf Blazor-Seite sichtbar.
// JvDBNavigator + JvDBMemo auf ocr_text, TDBGrid für Überblick.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, Vcl.StdCtrls,
  JvDBControls, vcl.Buttons,   // TJvDBNavigator
  Vcl.ExtDlgs,
  JvExControls, JvButton, JvNavigationPane, JvNavPanelButtonTop,
  uFrmModuleTemplate, DokumenteDm, DokumentOcrDm;

type
  TfrmDokumente = class(TfrmTemplate)
    pgcDokumente: TPageControl;
    tabDokumente: TTabSheet;
    pnlTop: TPanel;
    navDokumente: TJvDBNavigator;
    lblHinweis: TLabel;
    pnlGrid: TPanel;
    grdDokumente: TDBGrid;
    pnlMemo: TPanel;
    btnScan: TButton;
    TabSheet1: TTabSheet;
    DBImage1: TDBImage;
    Splitter1: TSplitter;
    Panel1: TPanel;
    lblOcrText: TLabel;
    mmoOcrText: TDBMemo;
    btnOcr: TJvNavPanelButtonTop;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnScanClick(Sender: TObject);
    procedure btnOcrClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    procedure SetDataSource(ASource: TDataSource);
  end;

var
  frmDokumente: TfrmDokumente;

implementation

{$R *.dfm}




procedure TfrmDokumente.btnScanClick(Sender: TObject);
begin
  inherited;
  dmDokumente.btnScanClick(Sender);
end;

procedure TfrmDokumente.FormShow(Sender: TObject);
begin
  inherited;
  // Ohne EasyOCR waere der Klick nur eine Fehlermeldung -- dann lieber
  // gar nicht erst anbieten.
  btnOcr.Enabled := Assigned(dmDokumentOcr) and dmDokumentOcr.OcrVerfuegbar;
  if not btnOcr.Enabled then
    btnOcr.Hint := 'EasyOCR ist nicht installiert (pip install easyocr)';
end;

// Liest eine Datei ein, erkennt den Text und schreibt Ergebnis samt
// Dokumentart in den aktuellen Datensatz.
procedure TfrmDokumente.btnOcrClick(Sender: TObject);
var
  LDlg: TOpenDialog;
  LErgebnis: TOcrErgebnis;
  LTypId: Integer;
  LDs: TDataSet;
  LMeldung: string;
begin
  LDs := dmDokumente.qryDokumente;
  if not Assigned(LDs) or not LDs.Active then
  begin
    MessageDlg('Es ist keine Dokumentliste geoeffnet.', mtInformation,
      [mbOK], 0);
    Exit;
  end;

  LDlg := TOpenDialog.Create(Self);
  try
    LDlg.Title := 'Dokument fuer die Texterkennung waehlen';
    LDlg.Filter := 'Dokumente|*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.pdf|' +
                   'Alle Dateien|*.*';
    LDlg.Options := LDlg.Options + [ofFileMustExist];
    if not LDlg.Execute then
      Exit;

    // Der erste Aufruf laedt das Sprachmodell und dauert einige Sekunden --
    // ohne Sanduhr sieht das aus, als haenge das Programm.
    Screen.Cursor := crHourGlass;
    try
      LErgebnis := dmDokumentOcr.DokumentLesen(LDlg.FileName);
    finally
      Screen.Cursor := crDefault;
    end;

    if not LErgebnis.Erfolg then
    begin
      MessageDlg('Die Texterkennung ist fehlgeschlagen:' + sLineBreak +
        LErgebnis.Fehler, mtWarning, [mbOK], 0);
      Exit;
    end;

    LTypId := dmDokumentOcr.TypIdZuKategorie(
      dmDokumente.FDConnection, LErgebnis.Kategorie);

    if LDs.State in dsEditModes then
      LDs.Post;
    LDs.Append;
    try
      dmDokumentOcr.InDatensatzSchreiben(LDs, LErgebnis, LTypId);
      LDs.FieldByName('datei_pfad').AsString := LDlg.FileName;
      LDs.FieldByName('quelle').AsString := 'OCR';
      LDs.Post;
    except
      LDs.Cancel;
      raise;
    end;

    LMeldung := Format('Erkannt als: %s'#13#10'%s',
      [LErgebnis.KategorieText, LErgebnis.Begruendung]);
    if not LErgebnis.KategorieSicher then
      LMeldung := LMeldung + sLineBreak + sLineBreak +
        'Die Zuordnung ist unsicher — die Dokumentart wurde deshalb ' +
        'nicht gesetzt.';
    if LErgebnis.Betrag > 0 then
      LMeldung := LMeldung + sLineBreak +
        Format('Betrag: %.2f %s', [LErgebnis.Betrag, LErgebnis.Waehrung]);
    if LErgebnis.Datum <> '' then
      LMeldung := LMeldung + sLineBreak + 'Datum: ' + LErgebnis.Datum;
    if LErgebnis.RechnungsNr <> '' then
      LMeldung := LMeldung + sLineBreak + 'Nummer: ' + LErgebnis.RechnungsNr;

    MessageDlg(LMeldung, mtInformation, [mbOK], 0);
  finally
    LDlg.Free;
  end;
end;

procedure TfrmDokumente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmDokumente := nil;
end;


procedure TfrmDokumente.SetDataSource(ASource: TDataSource);
begin
  navDokumente.DataSource  := ASource;
  grdDokumente.DataSource  := ASource;
  mmoOcrText.DataSource    := ASource;
  mmoOcrText.DataField     := 'ocr_text';
end;





end.
