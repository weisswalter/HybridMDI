unit BaumBedienung;

// Einheitliche Tastaturbedienung fuer alle Baeume im Programm.
//
//   F2    -- Knoten bearbeiten (Inline-Editor des VST)
//   Entf  -- Knoten loeschen
//   Einfg -- neuen Knoten unter dem markierten anlegen
//   Enter/Doppelklick auf einen "+ Neu..."-Platzhalter -- anlegen
//
// Warum ein eigenes Objekt und nicht in jedem Formular derselbe Code:
// Die Baeume sind fachlich voellig verschieden (Stueckliste, Merkmale,
// Bestand, Kursbaukasten), die BEDIENUNG soll aber ueberall gleich sein.
// Dieses Objekt kennt nur die Tasten und ruft die eingehaengten Rueckrufe --
// die Fachlogik und das Schreiben in die Datenbank bleiben im Formular.
//
// Owner ist der Baum selbst, das Objekt stirbt also mit ihm.
//
// Die Rueckrufe liefern eine Zeichenkette zurueck: leer bedeutet Erfolg,
// alles andere ist eine Meldung fuer den Anwender. Damit ist der Aufrufer
// gezwungen, einen Fehlschlag zu behandeln -- ein stilles Verschlucken
// (Aenderung sichtbar, aber nicht gespeichert) faellt so nicht durch.

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Vcl.Dialogs, Vcl.Controls,
  VirtualTrees, VirtualTrees.Types, VirtualTrees.BaseTree,
  BaumKnotenData;

type
  // Liefert '' bei Erfolg, sonst die Meldung fuer den Anwender.
  TKnotenAktion = function(const AKnoten: IBaumKnoten): string of object;
  TKnotenTextAktion = function(const AKnoten: IBaumKnoten;
    const AText: string): string of object;

  TBaumBedienung = class(TComponent)
  private
    FBaum: TVirtualStringTree;
    FAufNeu: TKnotenTextAktion;
    FAufBearbeiten: TKnotenTextAktion;
    FAufLoeschen: TKnotenAktion;
    FNachAenderung: TNotifyEvent;
    FLoeschFrage: Boolean;
    FNeuFrage: string;
    FNeuFragtText: Boolean;

    // OnKeyDown ist ein gewoehnliches VCL-Ereignis (TKeyEvent), kein
    // VST-eigenes -- deshalb Sender: TObject und nicht TBaseVirtualTree.
    FAltKeyDown: TKeyEvent;
    FAltDblClick: TNotifyEvent;
    FAltNewText: TVSTNewTextEvent;

    function KnotenVon(ANode: PVirtualNode): IBaumKnoten;
    function AktuellerKnoten: IBaumKnoten;
    procedure Melden(const AText: string);
    procedure Aendern(const AMeldung: string);

    procedure BaumKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BaumDblClick(Sender: TObject);
    procedure BaumNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
  public
    constructor Create(ABaum: TVirtualStringTree); reintroduce;

    // Loest die Aktionen von aussen aus -- fuer Schaltflaechen, die
    // dasselbe tun sollen wie die Tasten.
    procedure Bearbeiten;
    procedure Loeschen;
    procedure Neu;

    // Anlegen. Der Text ist die Eingabe des Anwenders; ist AufNeu nicht
    // gesetzt, passiert bei Einfg/Platzhalter nichts.
    property AufNeu: TKnotenTextAktion read FAufNeu write FAufNeu;
    // Bearbeiten. Ist der Rueckruf gesetzt, wird der Inline-Editor des VST
    // benutzt und das Ergebnis hierher gereicht.
    property AufBearbeiten: TKnotenTextAktion read FAufBearbeiten
      write FAufBearbeiten;
    property AufLoeschen: TKnotenAktion read FAufLoeschen write FAufLoeschen;
    // Wird nach jeder erfolgreichen Aenderung gerufen -- dort laedt das
    // Formular den Baum neu.
    property NachAenderung: TNotifyEvent read FNachAenderung
      write FNachAenderung;
    // Vor dem Loeschen nachfragen (Vorgabe: ja)
    property LoeschFrage: Boolean read FLoeschFrage write FLoeschFrage;
    // Beschriftung der Eingabeabfrage beim Anlegen
    property NeuFrage: string read FNeuFrage write FNeuFrage;
    // Ob beim Anlegen nach einem Text gefragt wird (Vorgabe: ja).
    // Bei Baeumen, die einen VORHANDENEN Datensatz einhaengen -- etwa der
    // Kursbaukasten, wo ein bestehender Kurs aus einer Auswahlliste kommt --
    // auf False setzen; AufNeu wird dann mit leerem Text gerufen und das
    // Formular holt sich die Angaben selbst.
    property NeuFragtText: Boolean read FNeuFragtText write FNeuFragtText;
  end;

implementation

uses
  System.UITypes;

constructor TBaumBedienung.Create(ABaum: TVirtualStringTree);
begin
  inherited Create(ABaum);
  FBaum := ABaum;
  FLoeschFrage := True;
  FNeuFragtText := True;
  FNeuFrage := 'Bezeichnung:';

  // Vorhandene Handler merken und weiterhin aufrufen -- die Baeume haben
  // teilweise schon eigene (z.B. Doppelklick zum Bearbeiten im Bestand).
  FAltKeyDown := ABaum.OnKeyDown;
  FAltDblClick := ABaum.OnDblClick;
  FAltNewText := ABaum.OnNewText;

  ABaum.OnKeyDown := BaumKeyDown;
  ABaum.OnDblClick := BaumDblClick;
  ABaum.OnNewText := BaumNewText;

  // Ohne toEditable feuert der Inline-Editor nie.
  ABaum.TreeOptions.MiscOptions :=
    ABaum.TreeOptions.MiscOptions + [TVTMiscOption.toEditable];
end;

function TBaumBedienung.KnotenVon(ANode: PVirtualNode): IBaumKnoten;
begin
  Result := nil;
  if Assigned(ANode) then
    Result := FBaum.GetInterfaceFromNodeData<IBaumKnoten>(ANode);
end;

function TBaumBedienung.AktuellerKnoten: IBaumKnoten;
begin
  Result := KnotenVon(FBaum.FocusedNode);
end;

procedure TBaumBedienung.Melden(const AText: string);
begin
  if AText <> '' then
    MessageDlg(AText, mtWarning, [mbOK], 0);
end;

procedure TBaumBedienung.Aendern(const AMeldung: string);
begin
  // Fehlschlag zeigen und NICHT neu laden -- so bleibt sichtbar, dass
  // nichts passiert ist.
  if AMeldung <> '' then
  begin
    Melden(AMeldung);
    Exit;
  end;
  if Assigned(FNachAenderung) then
    FNachAenderung(Self);
end;

procedure TBaumBedienung.Bearbeiten;
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := AktuellerKnoten;
  if (LKnoten = nil) or LKnoten.IstPlatzhalter then
    Exit;
  if not Assigned(FAufBearbeiten) then
    Exit;
  // Der Inline-Editor liefert das Ergebnis an OnNewText, dort geht es
  // weiter an AufBearbeiten.
  FBaum.EditNode(FBaum.FocusedNode, 0);
end;

procedure TBaumBedienung.Loeschen;
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := AktuellerKnoten;
  if (LKnoten = nil) or LKnoten.IstPlatzhalter then
    Exit;
  if not Assigned(FAufLoeschen) then
    Exit;

  if FLoeschFrage then
    if MessageDlg('"' + LKnoten.Spalte[0] + '" wirklich entfernen?',
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

  Aendern(FAufLoeschen(LKnoten));
end;

procedure TBaumBedienung.Neu;
var
  LKnoten: IBaumKnoten;
  LText: string;
begin
  if not Assigned(FAufNeu) then
    Exit;
  LKnoten := AktuellerKnoten;   // darf nil sein -- dann oberste Ebene

  LText := '';
  if FNeuFragtText then
  begin
    if not InputQuery('Neuer Eintrag', FNeuFrage, LText) then
      Exit;
    if Trim(LText) = '' then
      Exit;
    LText := Trim(LText);
  end;

  Aendern(FAufNeu(LKnoten, LText));
end;

procedure TBaumBedienung.BaumKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F2:
      begin
        Bearbeiten;
        Key := 0;
      end;
    VK_DELETE:
      begin
        // Waehrend des Bearbeitens loescht Entf Zeichen, nicht den Knoten.
        if not FBaum.IsEditing then
        begin
          Loeschen;
          Key := 0;
        end;
      end;
    VK_INSERT:
      begin
        Neu;
        Key := 0;
      end;
    VK_RETURN:
      begin
        // Auf einem Platzhalter legt Enter an, sonst nichts veraendern.
        if (AktuellerKnoten <> nil) and AktuellerKnoten.IstPlatzhalter then
        begin
          Neu;
          Key := 0;
        end;
      end;
  end;

  // Nur weiterreichen, wenn wir die Taste nicht selbst verbraucht haben.
  if (Key <> 0) and Assigned(FAltKeyDown) then
    FAltKeyDown(Sender, Key, Shift);
end;

procedure TBaumBedienung.BaumDblClick(Sender: TObject);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := AktuellerKnoten;
  if (LKnoten <> nil) and LKnoten.IstPlatzhalter and Assigned(FAufNeu) then
  begin
    Neu;
    Exit;
  end;
  // Kein Platzhalter: den urspruenglichen Handler weiterarbeiten lassen
  if Assigned(FAltDblClick) then
    FAltDblClick(Sender);
end;

procedure TBaumBedienung.BaumNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: string);
var
  LKnoten: IBaumKnoten;
begin
  LKnoten := KnotenVon(Node);
  if (LKnoten <> nil) and Assigned(FAufBearbeiten)
     and not LKnoten.IstPlatzhalter then
  begin
    Aendern(FAufBearbeiten(LKnoten, NewText));
    Exit;
  end;
  if Assigned(FAltNewText) then
    FAltNewText(Sender, Node, Column, NewText);
end;

end.
