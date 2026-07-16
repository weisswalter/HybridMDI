program Heisenberg;

uses
  Vcl.Forms,
  uAppEvents in 'uAppEvents.pas',
  UInterfaces,
  uMessageHandler in 'uMessageHandler.pas' {dmMessageHandler: TDataModule},
  udmModuleTemplate in 'udmModuleTemplate.pas' {dmModuleTemplate: TDataModule},
  uFrmModuleTemplate in 'uFrmModuleTemplate.pas' {frmTemplate},
  uFrmRibbonTemplate in 'uFrmRibbonTemplate.pas',
  EventBus,
  EventBus.Core,
  EventBus.Helpers,
  EventBus.Subscribers,
  MandantDm in 'MandantDm.pas' {dmMandant: TDataModule},
  MandantNeuFrm in 'MandantNeuFrm.pas' {frmMandantNeu},
  HeisenbergRibbon in 'Ribbon\HeisenbergRibbon.pas',
  uFrmMain in 'uFrmMain.pas' {frmMain},
  PersonenDm in 'PersonenDm.pas' {dmPersonen: TDataModule},
  PersonenFrm in 'PersonenFrm.pas' {frmPersonen},
  PythonDm in 'PythonDm.pas' {dmPython: TDataModule},
  PyKundenDm in 'PyKundenDm.pas' {dmPyKunden: TDataModule},
  PyKundenFrm in 'PyKundenFrm.pas' {frmPyKunden},
  PyArtikelDm in 'PyArtikelDm.pas' {dmPyArtikel: TDataModule},
  PyArtikelFrm in 'PyArtikelFrm.pas' {frmPyArtikel},
  KundenDm in 'KundenDm.pas' {dmKunden: TDataModule},
  KundenFrm in 'KundenFrm.pas' {frmKunden},
  ArtikelDm in 'ArtikelDm.pas' {dmArtikel: TDataModule},
  ArtikelFrm in 'ArtikelFrm.pas' {frmArtikel},
  DokumenteDm in 'DokumenteDm.pas' {dmDokumente: TDataModule},
  DokumenteFrm in 'DokumenteFrm.pas' {frmDokumente},
  ScannerDm in 'ScannerDm.pas' {dmScanner: TDataModule},
  ScannerFrm in 'ScannerFrm.pas' {frmScanner},
  PGManagerDm in 'PGManagerDm.pas' {dmPGManager: TDataModule},
  PGManagerFrm in 'PGManagerFrm.pas' {frmPGManager},
  LagerDm in 'LagerDm.pas' {dmLager: TDataModule},
  LagerFrm in 'LagerFrm.pas' {frmLager},

  UIRibbon in '..\RibbonFramework\Lib\UIRibbon.pas' {$R *.res},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  // dmMandant zuerst: frmMain.FormCreate greift beim Erzeugen direkt darauf zu
  Application.CreateForm(TdmMandant, dmMandant);
  //AApplication.CreateForm(TForm2, Form2);
  // Reihenfolge wichtig: MDI-Frame zuerst, dann DataModules
  Application.CreateForm(TfrmMain, frmMain);
  // MessageHandler muss früh erstellen damit er beim EventBus registriert ist
  Application.CreateForm(TdmMessageHandler, dmMessageHandler);
  Application.CreateForm(TdmPython, dmPython);
  Application.CreateForm(TdmPyKunden, dmPyKunden);
  Application.CreateForm(TdmPyArtikel, dmPyArtikel);
  Application.CreateForm(TdmKunden, dmKunden);
  Application.CreateForm(TdmArtikel, dmArtikel);
  Application.CreateForm(TdmDokumente, dmDokumente);
  // Scanner — Application.CreateForm noetig, sonst entfernt der Smart-Linker die
  // Klasse und mtModulCall TdmScanner.OpenScanner findet sie nicht (RTTI-Dispatch)
  Application.CreateForm(TdmScanner, dmScanner);
  Application.CreateForm(TdmPGManager, dmPGManager);
  Application.CreateForm(TdmPersonen, dmPersonen);
  // Lager — CreateForm noetig (RTTI-Dispatch, sonst linkt der Smart-Linker die Klasse weg)
  Application.CreateForm(TdmLager, dmLager);
  Application.Run;
end.
