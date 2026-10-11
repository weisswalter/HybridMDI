unit uGridMemo;

// Memo-Spalten in einem TDBGrid lesbar machen - ohne eigene Gitter-Komponente
// und ohne von TDBGrid abzuleiten.
//
// Warum ueberhaupt: Postgres 'text' kommt bei FireDAC als TWideMemoField an.
// TDBGrid fragt jede Zelle ueber Field.DisplayText, und TBlobField liefert
// dort nur den Platzhalter "(WIDEMEMO)" - nicht den Inhalt. Gemessen mit
// TestGridMemo.
//
// Der Weg hier setzt an genau dieser Stelle an: ein OnGetText am Feld. Das
// Feld bleibt ein Memo, die Daten bleiben vollstaendig, nur die ANZEIGE
// aendert sich. Es wirkt in jedem Steuerelement, das DisplayText benutzt -
// also auch in TDBGrid, ohne dass am Gitter irgendetwas gesetzt wird.
//
// Der andere denkbare Weg - eine FireDAC-MapRule dtWideMemo -> dtWideString,
// die das Feld selbst zu Text macht - wurde ausprobiert und greift an der
// Abfrage nicht: das Feld blieb ein TWideMemoField, mit und ohne SizeMin/
// SizeMax. Ausserdem wuerde er lange Texte beschneiden. Deshalb OnGetText.
//
// Zum BEARBEITEN taugt eine Gitterzelle ohnehin nur bedingt (eine Zeile);
// dafuer gehoert ein TDBMemo an dieselbe DataSource neben das Gitter.

interface

uses
  System.Classes, System.SysUtils, Data.DB;

// Verdrahtet alle Text-Memofelder des Datensatzes. Wirkt sofort, wenn er
// offen ist, und bleibt beim Wiederoeffnen bestehen - das ist der Punkt:
// eine Abfrage mit dynamischen Feldern wirft ihre Felder beim Schliessen weg
// und legt sie beim naechsten Open neu an, samt leerem OnGetText.
// AMaxZeichen = 0 zeigt den ganzen Text in einer Zeile.
procedure MemosLesbarMachen(ADataSet: TDataSet; AMaxZeichen: Integer = 300);

implementation

type
  TMemoAnzeiger = class(TComponent)
  private
    FDataSet: TDataSet;
    FMax: Integer;
    FAlterAfterOpen: TDataSetNotifyEvent;
    procedure FelderVerdrahten;
    procedure NachDemOeffnen(DataSet: TDataSet);
    procedure FeldText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    constructor Anlegen(ADataSet: TDataSet; AMax: Integer);
  end;

constructor TMemoAnzeiger.Anlegen(ADataSet: TDataSet; AMax: Integer);
begin
  // Owner ist der Datensatz: damit verschwindet der Anzeiger mit ihm, und
  // ein zweiter Aufruf findet ihn wieder (siehe MemosLesbarMachen).
  inherited Create(ADataSet);
  FDataSet := ADataSet;
  FMax := AMax;
  FAlterAfterOpen := ADataSet.AfterOpen;
  ADataSet.AfterOpen := NachDemOeffnen;
  if ADataSet.Active then
    FelderVerdrahten;
end;

procedure TMemoAnzeiger.NachDemOeffnen(DataSet: TDataSet);
begin
  FelderVerdrahten;
  // Die Kette nicht abreissen lassen: es kann schon ein Handler dagewesen sein.
  if Assigned(FAlterAfterOpen) then
    FAlterAfterOpen(DataSet);
end;

procedure TMemoAnzeiger.FelderVerdrahten;
var
  I: Integer;
begin
  for I := 0 to FDataSet.FieldCount - 1 do
    // Nur Text-Memos. Ein echter BLOB (Bild, PDF) darf hier nicht landen -
    // AsString wuerde daraus Zeichensalat machen.
    if FDataSet.Fields[I].DataType in [ftMemo, ftWideMemo, ftFmtMemo] then
      FDataSet.Fields[I].OnGetText := FeldText;
end;

procedure TMemoAnzeiger.FeldText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Sender.AsString;
  if not DisplayText then
    Exit;   // beim Bearbeiten/Kopieren der volle Text, ungekuerzt

  // Eine Gitterzeile ist einzeilig: Umbrueche wuerden als Kaestchen stehen.
  Text := StringReplace(Text, sLineBreak, ' ', [rfReplaceAll]);
  Text := StringReplace(Text, #13, ' ', [rfReplaceAll]);
  Text := StringReplace(Text, #10, ' ', [rfReplaceAll]);
  Text := StringReplace(Text, #9,  ' ', [rfReplaceAll]);

  if (FMax > 0) and (Length(Text) > FMax) then
    Text := Copy(Text, 1, FMax) + '...';
end;

procedure MemosLesbarMachen(ADataSet: TDataSet; AMaxZeichen: Integer);
var
  I: Integer;
begin
  if not Assigned(ADataSet) then
    Exit;
  // Zweimal anmelden wuerde die AfterOpen-Kette doppelt fuehren.
  for I := 0 to ADataSet.ComponentCount - 1 do
    if ADataSet.Components[I] is TMemoAnzeiger then
      Exit;
  TMemoAnzeiger.Anlegen(ADataSet, AMaxZeichen);
end;

end.
