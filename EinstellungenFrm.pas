unit EinstellungenFrm;

// Zentrale Typ-Verwaltung (siehe EinstellungenDm fuer den Hintergrund).
// Aufbau wie in den uebrigen Modulen ueber TRibbonPanel: ein Reiter je
// Typ-Tabelle, jeder Reiter mit EIGENER Buttonleiste (Neu/Speichern/
// Abbrechen) und einem ContentPanel, das das zugehoerige DBGrid traegt.
//
// Die drei Actions sind fuer alle Reiter dieselben; welche Tabelle sie
// treffen, entscheidet dmEinstellungen.DataSourceFuerTab(ActivePageIndex)
// anhand des gerade aktiven Reiters.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Actions, Vcl.ActnList, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  System.UITypes,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmEinstellungen = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actNeu: TAction;
    actSpeichern: TAction;
    actAbbrechen: TAction;
    actLoeschen: TAction;
    JvRibbonPanel1: TRibbonPanel;
    tsPersonentyp: TTabSheet;
    tsRollentyp: TTabSheet;
    tsAdressentyp: TTabSheet;
    tsEmailtyp: TTabSheet;
    tsTelefonnummertyp: TTabSheet;
    tsRechnungstyp: TTabSheet;
    tsLeadquellentyp: TTabSheet;
    tsKompetenztyp: TTabSheet;
    barPersonentyp: TRibbonButtonBar;
    barRollentyp: TRibbonButtonBar;
    barAdressentyp: TRibbonButtonBar;
    barEmailtyp: TRibbonButtonBar;
    barTelefonnummertyp: TRibbonButtonBar;
    barRechnungstyp: TRibbonButtonBar;
    barLeadquellentyp: TRibbonButtonBar;
    barKompetenztyp: TRibbonButtonBar;
    pnlPersonentyp: TPanel;
    dbgrdPersonentyp: TDBGrid;
    pnlRollentyp: TPanel;
    dbgrdRollentyp: TDBGrid;
    pnlAdressentyp: TPanel;
    dbgrdAdressentyp: TDBGrid;
    pnlEmailtyp: TPanel;
    dbgrdEmailtyp: TDBGrid;
    pnlTelefonnummertyp: TPanel;
    dbgrdTelefonnummertyp: TDBGrid;
    pnlRechnungstyp: TPanel;
    dbgrdRechnungstyp: TDBGrid;
    pnlLeadquellentyp: TPanel;
    dbgrdLeadquellentyp: TDBGrid;
    pnlKompetenztyp: TPanel;
    pnlKompetenzHinweis: TPanel;
    lblKompetenzHinweis: TLabel;
    dbgrdKompetenztyp: TDBGrid;
    tsKategorie: TTabSheet;
    barKategorie: TRibbonButtonBar;
    pnlKategorie: TPanel;
    pnlKategorieHinweis: TPanel;
    lblKategorieHinweis: TLabel;
    dbgrdKategorie: TDBGrid;
    tsWebsite: TTabSheet;
    barWebsite: TRibbonButtonBar;
    pnlWebsite: TPanel;
    lblWebsiteHinweis: TLabel;
    chkShopAktiv: TCheckBox;
    lblWaehrung: TLabel;
    edtWaehrung: TEdit;
    lblMwst: TLabel;
    edtMwst: TEdit;
    lblVersand: TLabel;
    edtVersand: TEdit;
    lblVersandFrei: TLabel;
    edtVersandFrei: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnNeuClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure btnAbbrechenClick(Sender: TObject);
    procedure btnLoeschenClick(Sender: TObject);
  private
    procedure WebseiteAnzeigen;
    // Gibt '' zurueck, wenn der Text eine brauchbare Zahl ist, sonst die
    // Meldung. Leere Zahlenfelder haben schon einmal '' in die Datenbank
    // geschrieben und die Sicht beim Programmstart zerlegt.
    function ZahlPruefen(const AFeld, AText: string): string;
  public
  end;

var
  frmEinstellungen: TfrmEinstellungen;

implementation

{$R *.dfm}

uses
  EinstellungenDm;

procedure TfrmEinstellungen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmEinstellungen := nil;
end;

function TfrmEinstellungen.ZahlPruefen(const AFeld, AText: string): string;
var
  LWert: Double;
begin
  if Trim(AText) = '' then
    Result := AFeld + ' darf nicht leer sein.'
  else if not TryStrToFloat(StringReplace(Trim(AText), '.', FormatSettings.DecimalSeparator,
                            [rfReplaceAll]), LWert) then
    Result := AFeld + ': "' + AText + '" ist keine Zahl.'
  else
    Result := '';
end;

// Holt die gespeicherten Werte in die Eingabefelder. Wird beim Oeffnen und
// nach jedem Speichern gerufen.
procedure TfrmEinstellungen.WebseiteAnzeigen;
begin
  chkShopAktiv.Checked := SameText(dmEinstellungen.WebWert('SHOP_AKTIV'), 'true');
  edtWaehrung.Text     := dmEinstellungen.WebWert('SHOP_WAEHRUNG');
  edtMwst.Text         := dmEinstellungen.WebWert('SHOP_MWST');
  edtVersand.Text      := dmEinstellungen.WebWert('SHOP_VERSAND');
  edtVersandFrei.Text  := dmEinstellungen.WebWert('SHOP_VERSANDFREI');
end;

// Beim Anzeigen die gespeicherten Werte in die Felder holen. Ohne das
// standen die Zahlenfelder leer da, der Haken sah aus wie nicht gesetzt -
// und ein Speichern schrieb die leeren Felder in die Datenbank.
procedure TfrmEinstellungen.FormShow(Sender: TObject);
begin
  WebseiteAnzeigen;
end;

procedure TfrmEinstellungen.btnNeuClick(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmEinstellungen.DataSourceFuerTab(JvRibbonPanel1.ActivePageIndex);
  if (LDs = nil) or (LDs.DataSet = nil) or not LDs.DataSet.Active then
    Exit;
  LDs.DataSet.Append;
end;

procedure TfrmEinstellungen.btnSpeichernClick(Sender: TObject);
var
  LMeldung: string;
begin
  // Der Website-Reiter ist ein Formular mit festen Schluesseln, kein
  // Gitter - der eine Sonderweg ist hier billiger als ihn in TypSpeichern
  // hineinzubiegen.
  if dmEinstellungen.IstWebsiteTab(JvRibbonPanel1.ActivePageIndex) then
  begin
    // Erst pruefen, dann schreiben. Ein leeres Zahlenfeld wuerde als ''
    // gespeichert, und daran ist die Sicht v_shop_einstellung beim naechsten
    // Programmstart zerbrochen.
    LMeldung := ZahlPruefen('Mehrwertsteuer', edtMwst.Text);
    if LMeldung = '' then
      LMeldung := ZahlPruefen('Versandkosten', edtVersand.Text);
    if LMeldung = '' then
      LMeldung := ZahlPruefen('Versandfrei ab', edtVersandFrei.Text);
    if (LMeldung = '') and (Trim(edtWaehrung.Text) = '') then
      LMeldung := 'Bitte eine W' + #228 + 'hrung angeben.';
    if LMeldung <> '' then
    begin
      MessageDlg(LMeldung, mtWarning, [mbOK], 0);
      Exit;
    end;

    for var LPaar in TArray<TPair<string, string>>.Create(
      TPair<string, string>.Create('SHOP_AKTIV',
        BoolToStr(chkShopAktiv.Checked, True).ToLower),
      TPair<string, string>.Create('SHOP_WAEHRUNG', Trim(edtWaehrung.Text)),
      TPair<string, string>.Create('SHOP_MWST', Trim(edtMwst.Text)),
      TPair<string, string>.Create('SHOP_VERSAND', Trim(edtVersand.Text)),
      TPair<string, string>.Create('SHOP_VERSANDFREI', Trim(edtVersandFrei.Text))) do
    begin
      LMeldung := dmEinstellungen.WebWertSetzen(LPaar.Key, LPaar.Value);
      if LMeldung <> '' then
        Break;
    end;
    if LMeldung <> '' then
      MessageDlg(LMeldung, mtWarning, [mbOK], 0);
    WebseiteAnzeigen;
    Exit;
  end;

  // Jeder andere Reiter geht ueber eine Datenbankfunktion. Ein Post auf die
  // Speichertabelle bliebe im Arbeitsspeicher stehen - die Tabellen sind
  // Kopien aus dem zentralen Datenmodul.
  LMeldung := dmEinstellungen.TypSpeichern(JvRibbonPanel1.ActivePageIndex);
  if LMeldung <> '' then
    MessageDlg(LMeldung, mtWarning, [mbOK], 0);
end;

procedure TfrmEinstellungen.btnAbbrechenClick(Sender: TObject);
var
  LDs: TDataSource;
begin
  LDs := dmEinstellungen.DataSourceFuerTab(JvRibbonPanel1.ActivePageIndex);
  if (LDs = nil) or (LDs.DataSet = nil) then
    Exit;
  if LDs.DataSet.State in dsEditModes then
    LDs.DataSet.Cancel;
end;

procedure TfrmEinstellungen.btnLoeschenClick(Sender: TObject);
var
  LMeldung, LName: string;
begin
  LName := dmEinstellungen.TypBezeichnung(JvRibbonPanel1.ActivePageIndex);
  if LName = '' then
    Exit;
  // Rueckfrage: geloescht wird sofort in der Datenbank, ein Zurueck gibt es
  // nicht.
  if MessageDlg('"' + LName + '" wirklich l' + #246 + 'schen?',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  LMeldung := dmEinstellungen.TypLoeschen(JvRibbonPanel1.ActivePageIndex);
  if LMeldung <> '' then
    MessageDlg(LMeldung, mtWarning, [mbOK], 0);
end;

end.
