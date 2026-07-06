unit uFrmDokumente;

// MDI-Child: Dokumentenverwaltung — Kurztest ob DB-Änderungen auf Blazor-Seite sichtbar.
// JvDBNavigator + JvDBMemo auf ocr_text, TDBGrid für Überblick.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, Vcl.StdCtrls,
  JvDBControls, vcl.Buttons;   // TJvDBNavigator

type
  TfrmDokumente = class(TForm)
    pgcDokumente: TPageControl;
    tabDokumente: TTabSheet;
    pnlTop: TPanel;
    navDokumente: TJvDBNavigator;
    lblHinweis: TLabel;
    pnlGrid: TPanel;
    grdDokumente: TDBGrid;
    pnlMemo: TPanel;
    lblOcrText: TLabel;
    mmoOcrText: TDBMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    procedure SetDataSource(ASource: TDataSource);
  end;

var
  frmDokumente: TfrmDokumente;

implementation

{$R *.dfm}

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
