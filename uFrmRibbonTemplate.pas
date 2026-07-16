unit uFrmRibbonTemplate;

// Basisklasse fuer MDI-Child-Formulare MIT Ribbon (Gegenstueck zu TfrmTemplate,
// das keinen Ribbon hat). Leitet von TfrmTemplate ab, ergaenzt TUIRibbon +
// eine eigene ActionList, die per ActionManager-Property verbunden ist
// (siehe frmMain — ohne diese Zuweisung reagiert der Ribbon nicht auf Klicks).
//
// Nutzung: abgeleitetes Formular setzt UIRibbon1.ResourceName und legt eigene
// TAction-Eintraege in RibbonActions an, deren Name exakt dem Command-Name
// in der jeweiligen Ribbon-XML entspricht.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Actions, Vcl.ActnList,
  UIRibbon,
  uFrmModuleTemplate;

type
  TfrmRibbonTemplate = class(TfrmTemplate)
    UIRibbon1: TUIRibbon;
    RibbonActions: TActionList;
  end;

implementation

{$R *.dfm}

end.
