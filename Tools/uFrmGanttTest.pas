unit uFrmGanttTest;

// Probierfenster fuer TGanttPanel.
//
// Das Gantt-Panel wird zur LAUFZEIT erzeugt, nicht im DFM abgelegt. Damit
// laesst sich die Komponente ausprobieren, ohne dass sie vorher ins Package
// aufgenommen und in der IDE installiert sein muss.
//
// Die Beispieldaten bilden Walters Vorgabe nach: oben die Lehrer, darunter
// die Raeume, Balken als gewuenscht oder belegt, und ein Bedarfsband fuer den
// geplanten Kurstermin.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.DateUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  GanttPanel;

type
  TfrmGanttTest = class(TForm)
    pnlOben: TPanel;
    lblDatum: TLabel;
    dtpDatum: TDateTimePicker;
    lblZoom: TLabel;
    trkZoom: TTrackBar;
    btnTagZurueck: TButton;
    btnTagVor: TButton;
    btnBeispiel: TButton;
    btnBedarf: TButton;
    btnLeeren: TButton;
    pnlUnten: TPanel;
    lblStatus: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure dtpDatumChange(Sender: TObject);
    procedure trkZoomChange(Sender: TObject);
    procedure btnTagZurueckClick(Sender: TObject);
    procedure btnTagVorClick(Sender: TObject);
    procedure btnBeispielClick(Sender: TObject);
    procedure btnBedarfClick(Sender: TObject);
    procedure btnLeerenClick(Sender: TObject);
  private
    FGantt: TGanttPanel;
    procedure BeispieldatenLaden;
    procedure GanttBalkenClick(Sender: TObject; AZeile: TGanttZeile;
      ABalken: TGanttBalken);
    procedure GanttZeileClick(Sender: TObject; AZeile: TGanttZeile);
    procedure GanttZeitClick(Sender: TObject; AZeile: TGanttZeile;
      AZeitpunkt: TDateTime);
  end;

var
  frmGanttTest: TfrmGanttTest;

implementation

{$R *.dfm}

procedure TfrmGanttTest.FormCreate(Sender: TObject);
begin
  FGantt := TGanttPanel.Create(Self);
  FGantt.Parent := Self;
  FGantt.Align := alClient;
  FGantt.Datum := Date;
  FGantt.OnBalkenClick := GanttBalkenClick;
  FGantt.OnZeileClick  := GanttZeileClick;
  FGantt.OnZeitClick   := GanttZeitClick;

  dtpDatum.Date := Date;
  trkZoom.Min := 10;
  trkZoom.Max := 200;
  trkZoom.Position := FGantt.PixelProStunde;

  BeispieldatenLaden;
  // Auf den Vormittag springen, sonst steht man am Anfang des Fensters,
  // also 10 Stunden vor Mitternacht des Vortags.
  FGantt.ZeigeZeit(Trunc(Date) + EncodeTime(9, 0, 0, 0));
end;

procedure TfrmGanttTest.BeispieldatenLaden;
var
  LZeile: TGanttZeile;
  LHeute: TDateTime;
begin
  LHeute := Trunc(dtpDatum.Date);

  FGantt.BeginUpdate;
  try
    FGantt.Leeren;

    // ── Klassen ganz oben: sie sind der Ausgangspunkt der Planung ───────
    FGantt.GruppeHinzufuegen('Klassen / Gruppen');

    LZeile := FGantt.ZeileHinzufuegen('klasse:1', 'Gruppe A - Werkstatt', 1);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := '12 Teilnehmer';
    LZeile.BalkenHinzufuegen('Arbeitstraining',
      LHeute + EncodeTime(8, 0, 0, 0), LHeute + EncodeTime(11, 30, 0, 0), gsBelegt);
    LZeile.BalkenHinzufuegen('Excel Grundlagen',
      LHeute + EncodeTime(13, 0, 0, 0), LHeute + EncodeTime(14, 30, 0, 0), gsGewuenscht);

    LZeile := FGantt.ZeileHinzufuegen('klasse:2', 'Gruppe B - B' + #252 + 'ro', 2);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := '8 Teilnehmer';
    LZeile.BalkenHinzufuegen('Bewerbungscoaching',
      LHeute + EncodeTime(9, 0, 0, 0), LHeute + EncodeTime(12, 0, 0, 0), gsBelegt);

    // ── Lehrer darunter ─────────────────────────────────────────────────
    FGantt.GruppeHinzufuegen('Lehrer');

    LZeile := FGantt.ZeileHinzufuegen('lehrer:5', 'Weiss, Walter', 5);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := 'Kompetenz: Excel, Delphi';
    LZeile.BalkenHinzufuegen('Excel Grundlagen',
      LHeute + EncodeTime(9, 0, 0, 0), LHeute + EncodeTime(12, 0, 0, 0), gsBelegt);
    LZeile.BalkenHinzufuegen('Vorbereitung',
      LHeute + EncodeTime(8, 0, 0, 0), LHeute + EncodeTime(9, 0, 0, 0), gsGewuenscht);

    LZeile := FGantt.ZeileHinzufuegen('lehrer:2', 'Thiel, Wolfgang', 2);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := 'Kompetenz: Excel';
    LZeile.BalkenHinzufuegen('PowerPoint Training',
      LHeute + EncodeTime(13, 0, 0, 0), LHeute + EncodeTime(16, 30, 0, 0), gsBelegt);

    LZeile := FGantt.ZeileHinzufuegen('lehrer:4', 'Rischkau, J' + #252 + 'rgen', 4);
    LZeile.Auswaehlbar := False;   // fehlende Kompetenz: blass gezeichnet
    LZeile.Zusatz := 'Kompetenz fehlt';

    // ── Raeume darunter ─────────────────────────────────────────────────
    FGantt.GruppeHinzufuegen('R' + #228 + 'ume');

    LZeile := FGantt.ZeileHinzufuegen('raum:1', 'Schulungsraum 1', 1);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := 'Beamer fest, 16 Pl' + #228 + 'tze';
    LZeile.BalkenHinzufuegen('Excel Grundlagen',
      LHeute + EncodeTime(9, 0, 0, 0), LHeute + EncodeTime(12, 0, 0, 0), gsBelegt);

    LZeile := FGantt.ZeileHinzufuegen('raum:2', 'Mehrzweckraum', 2);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := 'mobil ausr' + #252 + 'stbar';
    LZeile.BalkenHinzufuegen('Elternabend',
      LHeute + EncodeTime(18, 0, 0, 0), LHeute + EncodeTime(20, 0, 0, 0), gsGewuenscht);

    LZeile := FGantt.ZeileHinzufuegen('raum:3', 'Werkstatt', 3);
    LZeile.Auswaehlbar := False;   // Ausstattung passt nicht
    LZeile.Zusatz := 'kein Beamer, nicht ausr' + #252 + 'stbar';
    LZeile.BalkenHinzufuegen('Wartung',
      LHeute + EncodeTime(7, 0, 0, 0), LHeute + EncodeTime(17, 0, 0, 0), gsGesperrt);

    LZeile := FGantt.ZeileHinzufuegen('raum:4', 'Seminarraum klein', 4);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := '8 Pl' + #228 + 'tze';
    // Doppelbelegung sichtbar machen
    LZeile.BalkenHinzufuegen('Coaching A',
      LHeute + EncodeTime(10, 0, 0, 0), LHeute + EncodeTime(11, 30, 0, 0), gsBelegt);
    LZeile.BalkenHinzufuegen('Coaching B',
      LHeute + EncodeTime(11, 0, 0, 0), LHeute + EncodeTime(12, 0, 0, 0), gsKonflikt);

    // Termin, der ueber Mitternacht laeuft - im Prototyp waere er auf den
    // Tagesanfang zurueckgefallen
    LZeile.BalkenHinzufuegen('Nachtdienst',
      LHeute + EncodeTime(22, 0, 0, 0), LHeute + 1 + EncodeTime(6, 0, 0, 0), gsBelegt);

    // ── Mobiles Inventar: eigene Ressource mit eigener Belegung ─────────
    // Ein Beamer kann nicht in zwei Raeumen gleichzeitig stehen - deshalb
    // eine eigene Zeile und kein blosses Merkmal am Raum.
    FGantt.GruppeHinzufuegen('Ausstattung (mobil)');

    LZeile := FGantt.ZeileHinzufuegen('ausstattung:1', 'Beamer mobil', 1);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := '1 St' + #252 + 'ck vorhanden';
    LZeile.BalkenHinzufuegen('Schulungsraum 1',
      LHeute + EncodeTime(9, 0, 0, 0), LHeute + EncodeTime(12, 0, 0, 0), gsBelegt);

    LZeile := FGantt.ZeileHinzufuegen('ausstattung:2', 'Laptopwagen', 2);
    LZeile.Auswaehlbar := True;
    LZeile.Zusatz := '10 Ger' + #228 + 'te';
    LZeile.BalkenHinzufuegen('Bewerbungscoaching',
      LHeute + EncodeTime(9, 0, 0, 0), LHeute + EncodeTime(12, 0, 0, 0), gsBelegt);
  finally
    FGantt.EndUpdate;
  end;

  lblStatus.Caption := Format('%d Zeilen geladen.', [FGantt.Zeilen.Count]);
end;

procedure TfrmGanttTest.dtpDatumChange(Sender: TObject);
begin
  FGantt.Datum := dtpDatum.Date;
  BeispieldatenLaden;
  FGantt.ZeigeZeit(Trunc(dtpDatum.Date) + EncodeTime(9, 0, 0, 0));
end;

procedure TfrmGanttTest.trkZoomChange(Sender: TObject);
begin
  FGantt.PixelProStunde := trkZoom.Position;
  lblZoom.Caption := Format('Zoom: %d px/Std', [trkZoom.Position]);
end;

// Setzen des Datums loest OnChange aus - dort wird neu geladen und gesprungen.
procedure TfrmGanttTest.btnTagZurueckClick(Sender: TObject);
begin
  dtpDatum.Date := IncDay(dtpDatum.Date, -1);
end;

procedure TfrmGanttTest.btnTagVorClick(Sender: TObject);
begin
  dtpDatum.Date := IncDay(dtpDatum.Date, 1);
end;

procedure TfrmGanttTest.btnBeispielClick(Sender: TObject);
begin
  BeispieldatenLaden;
end;

// Das Bedarfsband: der geplante Kurstermin, quer ueber alle Zeilen. Daran
// sieht man sofort, wer und welcher Raum in genau diesem Fenster frei ist.
procedure TfrmGanttTest.btnBedarfClick(Sender: TObject);
var
  LVon: TDateTime;
begin
  LVon := Trunc(dtpDatum.Date) + EncodeTime(13, 0, 0, 0);
  FGantt.BedarfSetzen(LVon, IncMinute(LVon, 90));
  FGantt.ZeigeZeit(LVon);
  lblStatus.Caption := 'Bedarf 13:00 bis 14:30 gesetzt.';
end;

procedure TfrmGanttTest.btnLeerenClick(Sender: TObject);
begin
  FGantt.Leeren;
  FGantt.BedarfLoeschen;
  lblStatus.Caption := 'Geleert.';
end;

procedure TfrmGanttTest.GanttBalkenClick(Sender: TObject; AZeile: TGanttZeile;
  ABalken: TGanttBalken);
begin
  lblStatus.Caption := Format('Balken "%s" in Zeile "%s"  (%s bis %s)',
    [ABalken.Titel, AZeile.Beschriftung,
     FormatDateTime('dd.mm. hh:nn', ABalken.Von),
     FormatDateTime('hh:nn', ABalken.Bis)]);
end;

procedure TfrmGanttTest.GanttZeileClick(Sender: TObject; AZeile: TGanttZeile);
begin
  if AZeile.IstGruppe or not AZeile.Auswaehlbar then
    Exit;
  // Auswahl umschalten - so waehlt man spaeter den Raum fuer den Kurstermin
  AZeile.Ausgewaehlt := not AZeile.Ausgewaehlt;
  FGantt.Invalidate;
end;

procedure TfrmGanttTest.GanttZeitClick(Sender: TObject; AZeile: TGanttZeile;
  AZeitpunkt: TDateTime);
begin
  lblStatus.Caption := Format('Freie Fl' + #228 + 'che: %s um %s',
    [AZeile.Beschriftung, FormatDateTime('dd.mm. hh:nn', AZeitpunkt)]);
end;

end.
