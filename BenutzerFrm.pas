unit BenutzerFrm;

// Benutzerverwaltung — steht nur dem globalen Administrator offen
// (siehe TdmBenutzer.OpenBenutzer).
//   links  Benutzerliste mit Mandanten und Rollen im Klartext
//   rechts TRibbonPanel mit zwei Reitern:
//     "Zugang"    — neuen Benutzer anlegen, Passwort zuruecksetzen, sperren
//     "Mandanten" — genau Walters "dieser kann Personen Mandanten zuordnen"
//
// Wer im STAMMMANDANTEN die Rolle administrator bekommt, wird damit globaler
// Administrator und sieht alle Mandanten. Das steht als Warnung im Reiter,
// weil es die weitreichendste Zuordnung im ganzen Programm ist.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Variants, System.Actions, Vcl.ActnList,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.CheckLst,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  JvExControls, JvButton, JvGradient, JvNavigationPane, JvNavPanelButtonTop,
  RibbonPanel, RibbonPageControl, RibbonButtonBar,
  uFrmModuleTemplate, JvComponentBase;

type
  TfrmBenutzer = class(TfrmTemplate)
    PaneStyle1: TJvNavPaneStyleManager;
    ActionListEdit: TActionList;
    actNeuLaden: TAction;
    actSperren: TAction;
    actEntsperren: TAction;
    pnlTop: TPanel;
    chkAnmeldepflicht: TCheckBox;
    pnlAnmeldeAdressen: TPanel;
    lblAnmeldeAdressen: TLabel;
    clbAnmeldeAdressen: TCheckListBox;
    lblAngemeldet: TLabel;
    btnNeuLaden: TJvNavPanelButtonTop;
    btnSperren: TJvNavPanelButtonTop;
    btnEntsperren: TJvNavPanelButtonTop;
    pnlLeft: TPanel;
    dbgrdBenutzer: TDBGrid;
    Splitter1: TSplitter;
    JvRibbonPanel1: TRibbonPanel;
    tsZugang: TTabSheet;
    tsMandanten: TTabSheet;
    barZugang: TRibbonButtonBar;
    barMandanten: TRibbonButtonBar;
    pnlZugang: TPanel;
    lblNeuName: TLabel;
    edtNeuName: TEdit;
    lblNeuPasswort: TLabel;
    edtNeuPasswort: TEdit;
    lblNeuPerson: TLabel;
    cboNeuPerson: TDBLookupComboBox;
    lblNeuMandant: TLabel;
    cboNeuMandant: TDBLookupComboBox;
    lblNeuRolle: TLabel;
    cboNeuRolle: TComboBox;
    btnAnlegen: TButton;
    lblReset: TLabel;
    edtResetPasswort: TEdit;
    btnReset: TButton;
    lblZugangHinweis: TLabel;
    pnlMandanten: TPanel;
    dbgrdZuordnung: TDBGrid;
    pnlZuordnungAdd: TPanel;
    lblZuMandant: TLabel;
    cboZuMandant: TDBLookupComboBox;
    lblZuRolle: TLabel;
    cboZuRolle: TComboBox;
    btnZuordnen: TButton;
    btnEntfernen: TButton;
    lblMandantenHinweis: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgrdBenutzerCellClick(Column: TColumn);
    procedure actNeuLadenExecute(Sender: TObject);
    procedure actSperrenExecute(Sender: TObject);
    procedure actEntsperrenExecute(Sender: TObject);
    procedure btnAnlegenClick(Sender: TObject);
    procedure chkAnmeldepflichtClick(Sender: TObject);
    procedure clbAnmeldeAdressenClickCheck(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnZuordnenClick(Sender: TObject);
    procedure btnEntfernenClick(Sender: TObject);
  private
    // Waehrend des Nachziehens duerfen die Haken nicht schreiben.
    FStumm: Boolean;
    procedure AnmeldeAdressenAnzeigen;
    function AktuellerBenutzer: Integer;
    function LookupId(ACombo: TDBLookupComboBox): Integer;
  end;

var
  frmBenutzer: TfrmBenutzer;

implementation

{$R *.dfm}

uses
  BenutzerDm;

procedure TfrmBenutzer.FormCreate(Sender: TObject);
begin
  cboNeuRolle.Items.Clear;
  cboNeuRolle.Items.Add('benutzer');
  cboNeuRolle.Items.Add('administrator');
  cboNeuRolle.ItemIndex := 0;

  cboZuRolle.Items.Assign(cboNeuRolle.Items);
  cboZuRolle.ItemIndex := 0;

  if dmBenutzer.Angemeldet then
  begin
    lblAngemeldet.Caption := 'Angemeldet als ' + dmBenutzer.Anzeigename;
    if dmBenutzer.IstGlobalAdmin then
      lblAngemeldet.Caption := lblAngemeldet.Caption +
        ' (globaler Administrator)';
  end
  else
    lblAngemeldet.Caption := 'Kein Benutzer angemeldet - es ist noch kein ' +
      'Zugang eingerichtet.';

  lblZugangHinweis.Caption :=
    'Das Passwort muss mindestens 8 Zeichen haben. Ein zur' + #252 + 'ckgesetztes ' +
    'Passwort muss der Benutzer beim n' + #228 + 'chsten Anmelden selbst ' +
    #228 + 'ndern. Person ist optional - ohne Person ist es ein reines ' +
    'Systemkonto.';

  lblMandantenHinweis.Caption :=
    'ACHTUNG: Wer im STAMMMANDANTEN die Rolle "administrator" erh' + #228 +
    'lt, wird damit GLOBALER Administrator und sieht alle Mandanten. In ' +
    'jedem anderen Mandanten gilt die Rolle nur dort.';

  actNeuLadenExecute(nil);
end;

procedure TfrmBenutzer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ZURUECK auf caFree am 09.08.2026: MDI-Kinder lassen sich
  // nicht verstecken - weder per caHide (VCL wirft) noch per
  // ShowWindow (der MDI-Client zeigt sie wieder an). Mit caNone
  // gingen die Fenster gar nicht mehr zu. Das Wiederoeffnen
  // bleibt damit langsam; ein anderer Weg muss her.
  Action := caFree;
  frmBenutzer := nil;
end;

function TfrmBenutzer.AktuellerBenutzer: Integer;
begin
  if dmBenutzer.qryBenutzer.Active and not dmBenutzer.qryBenutzer.IsEmpty then
    Result := dmBenutzer.qryBenutzer.FieldByName('benutzer_id').AsInteger
  else
    Result := 0;
end;

function TfrmBenutzer.LookupId(ACombo: TDBLookupComboBox): Integer;
begin
  if VarIsNull(ACombo.KeyValue) then
    Result := 0
  else
    Result := ACombo.KeyValue;
end;

procedure TfrmBenutzer.dbgrdBenutzerCellClick(Column: TColumn);
begin
  dmBenutzer.LadeZuordnungen(AktuellerBenutzer);
end;

procedure TfrmBenutzer.actNeuLadenExecute(Sender: TObject);
begin
  dmBenutzer.LadeBenutzer;
  dmBenutzer.LadeZuordnungen(AktuellerBenutzer);
end;

procedure TfrmBenutzer.actSperrenExecute(Sender: TObject);
var
  LMeldung: string;
begin
  if AktuellerBenutzer = 0 then
    Exit;
  LMeldung := dmBenutzer.AktivSetzen(AktuellerBenutzer, False);
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

procedure TfrmBenutzer.actEntsperrenExecute(Sender: TObject);
var
  LMeldung: string;
begin
  if AktuellerBenutzer = 0 then
    Exit;
  LMeldung := dmBenutzer.AktivSetzen(AktuellerBenutzer, True);
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

// Zeigt die E-Mail-Adressen der Person, zu der das gewaehlte Konto gehoert.
// Ein Haken heisst: mit dieser Adresse kann man sich statt mit dem
// Anmeldenamen anmelden.
procedure TfrmBenutzer.AnmeldeAdressenAnzeigen;
var
  LMarkiert: TList<Boolean>;
  I: Integer;
begin
  FStumm := True;
  LMarkiert := TList<Boolean>.Create;
  try
    dmBenutzer.LadeAnmeldeAdressen(clbAnmeldeAdressen.Items, LMarkiert);
    for I := 0 to clbAnmeldeAdressen.Items.Count - 1 do
      if I < LMarkiert.Count then
        clbAnmeldeAdressen.Checked[I] := LMarkiert[I];
  finally
    LMarkiert.Free;
    FStumm := False;
  end;
end;

procedure TfrmBenutzer.clbAnmeldeAdressenClickCheck(Sender: TObject);
var
  I: Integer;
  LMeldung: string;
begin
  if FStumm then
    Exit;
  I := clbAnmeldeAdressen.ItemIndex;
  if I < 0 then
    Exit;

  LMeldung := dmBenutzer.AnmeldeAdresseSetzen(
    Integer(NativeInt(clbAnmeldeAdressen.Items.Objects[I])),
    clbAnmeldeAdressen.Checked[I]);
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    // Anzeige zurueck auf den Stand der Datenbank.
    AnmeldeAdressenAnzeigen;
  end;
end;

procedure TfrmBenutzer.chkAnmeldepflichtClick(Sender: TObject);
var
  LMeldung: string;
begin
  if FStumm then
    Exit;
  LMeldung := dmBenutzer.AnmeldepflichtSetzen(chkAnmeldepflicht.Checked);
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    FStumm := True;
    try
      chkAnmeldepflicht.Checked := dmBenutzer.AnmeldungErforderlich;
    finally
      FStumm := False;
    end;
  end;
end;

procedure TfrmBenutzer.btnAnlegenClick(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := dmBenutzer.BenutzerAnlegen(Trim(edtNeuName.Text),
    edtNeuPasswort.Text, LookupId(cboNeuPerson), LookupId(cboNeuMandant),
    cboNeuRolle.Text);
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    Exit;
  end;
  ShowMessage('Benutzer angelegt.');
  edtNeuName.Clear;
  edtNeuPasswort.Clear;
end;

procedure TfrmBenutzer.btnResetClick(Sender: TObject);
var
  LMeldung: string;
begin
  if AktuellerBenutzer = 0 then
  begin
    ShowMessage('Bitte links einen Benutzer w' + #228 + 'hlen.');
    Exit;
  end;
  LMeldung := dmBenutzer.PasswortZuruecksetzen(AktuellerBenutzer,
    edtResetPasswort.Text);
  if LMeldung <> '' then
  begin
    ShowMessage(LMeldung);
    Exit;
  end;
  ShowMessage('Passwort zur' + #252 + 'ckgesetzt. Der Benutzer muss es beim ' +
    'n' + #228 + 'chsten Anmelden selbst ' + #228 + 'ndern.');
  edtResetPasswort.Clear;
end;

procedure TfrmBenutzer.btnZuordnenClick(Sender: TObject);
var
  LMeldung: string;
begin
  LMeldung := dmBenutzer.MandantZuordnen(AktuellerBenutzer,
    LookupId(cboZuMandant), cboZuRolle.Text);
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

procedure TfrmBenutzer.btnEntfernenClick(Sender: TObject);
var
  LMeldung: string;
begin
  if dmBenutzer.tblBenutzerMandant.IsEmpty then
    Exit;
  if MessageDlg('Diese Zuordnung entfernen?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    Exit;
  LMeldung := dmBenutzer.ZuordnungEntfernen(AktuellerBenutzer,
    dmBenutzer.tblBenutzerMandant.FieldByName('mandant_id').AsInteger);
  if LMeldung <> '' then
    ShowMessage(LMeldung);
end;

end.
