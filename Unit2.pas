unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvGradient, JvExControls, JvButton,
  JvNavigationPane, JvNavPanelButtonTop, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    pnlRibbon: TPanel;
    pctrModule: TPageControl;
    tsDatei: TTabSheet;
    Adressen: TJvNavPanelHeader;
    jvnvpnlhdr2: TJvNavPanelHeader;
    jvnvpnlhdr3: TJvNavPanelHeader;
    pnl1: TPanel;
    NavPBtnTopMandantNeu: TJvNavPanelButtonTop;
    NavPBtnTopMandantWaehlen: TJvNavPanelButtonTop;
    jvgrdnt2: TJvGradient;
    JvNavPanelButtonTop1: TJvNavPanelButtonTop;
    NavPBtnTopMandantNeu1: TJvNavPanelButtonTop;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
