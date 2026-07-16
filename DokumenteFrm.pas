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
  uFrmModuleTemplate, DokumenteDm;

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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnScanClick(Sender: TObject);
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
