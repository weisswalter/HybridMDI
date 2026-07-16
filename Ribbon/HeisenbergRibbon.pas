unit HeisenbergRibbon;

// *****************************************************************************
// * This is an automatically generated source file for UI Element definition  *
// * resource symbols and values. Please do not modify manually.               *
// *****************************************************************************

interface

{$R 'HeisenbergRibbon.res'}

uses
  Generics.Collections, SysUtils, UIRibbon;

const
  cmdGroupMandant = 2;
  cmdMandantNeu = 3;
  cmdMandantNeu_LabelTitle_RESID = 196;
  IDC_CMD_TABMODULE = 10000;
  IDC_CMD_TABMODULE_LabelTitle_RESID = 200;
  cmdGroupModule = 4;
  cmdKunden = 5;
  cmdKunden_LabelTitle_RESID = 210;
  cmdArtikel = 6;
  cmdArtikel_LabelTitle_RESID = 220;
  cmdDokumente = 7;
  cmdDokumente_LabelTitle_RESID = 230;
  cmdPersonen = 8;
  cmdPersonen_LabelTitle_RESID = 240;
  cmdTabTools = 9;
  cmdTabTools_LabelTitle_RESID = 245;
  cmdGroupTools = 10;
  cmdScanner = 11;
  cmdScanner_LabelTitle_RESID = 260;
  cmdPGManager = 12;
  cmdPGManager_LabelTitle_RESID = 270;
  InternalCmd2_LabelTitle_RESID = 60001;

implementation

function RegisterRibbonElements(): TRibbonMarkupElementList;
begin
  Result := TRibbonMarkupElementList.Create('APPLICATION');
  Result.Add(TRibbonMarkupElement.Create('cmdGroupMandant', 2, -1, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdMandantNeu', 3, 196, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('IDC_CMD_TABMODULE', 10000, 200, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdGroupModule', 4, -1, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdKunden', 5, 210, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdArtikel', 6, 220, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdDokumente', 7, 230, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdPersonen', 8, 240, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdTabTools', 9, 245, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdGroupTools', 10, -1, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdScanner', 11, 260, -1, -1, -1));
  Result.Add(TRibbonMarkupElement.Create('cmdPGManager', 12, 60001, -1, -1, -1));
end;

initialization

  RegisterRibbonElements();

end.