program Heisenberg;

uses
  Vcl.Forms,
  uAppEvents in 'uAppEvents.pas',
  UInterfaces,
  uMessageHandler in 'uMessageHandler.pas' {dmMessageHandler: TDataModule},
  udmModuleTemplate in 'udmModuleTemplate.pas' {dmModuleTemplate: TDataModule},
  uFrmModuleTemplate in 'uFrmModuleTemplate.pas' {frmTemplate},
  uFrmGuiTemplate in 'uFrmGuiTemplate.pas' {frmGuiTemplate},
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
  ArtikelStammDm in 'ArtikelStammDm.pas' {dmArtikelStamm: TDataModule},
  ArtikelStammFrm in 'ArtikelStammFrm.pas' {frmArtikelStamm},
  KundenBestellungDm in 'KundenBestellungDm.pas' {dmKundenBestellung: TDataModule},
  KundenBestellungFrm in 'KundenBestellungFrm.pas' {frmKundenBestellung},
  LieferantenBestellungDm in 'LieferantenBestellungDm.pas' {dmLieferantenBestellung: TDataModule},
  LieferantenBestellungFrm in 'LieferantenBestellungFrm.pas' {frmLieferantenBestellung},
  LagerEntnahmeDm in 'LagerEntnahmeDm.pas' {dmLagerEntnahme: TDataModule},
  LagerEntnahmeFrm in 'LagerEntnahmeFrm.pas' {frmLagerEntnahme},
  KlientDm in 'KlientDm.pas' {dmKlient: TDataModule},
  KlientFrm in 'KlientFrm.pas' {frmKlient},
  KundeDm in 'KundeDm.pas' {dmKunde: TDataModule},
  KundeFrm in 'KundeFrm.pas' {frmKunde},
  CSharpDm in 'CSharpDm.pas' {dmCSharp: TDataModule},
  DokumentOcrDm in 'DokumentOcrDm.pas' {dmDokumentOcr: TDataModule},
  BaumKnotenData in 'BaumKnotenData.pas',
  KursDm in 'KursDm.pas' {dmKurs: TDataModule},
  KursFrm in 'KursFrm.pas' {frmKurs},
  AnwesenheitDm in 'AnwesenheitDm.pas' {dmAnwesenheit: TDataModule},
  AnwesenheitFrm in 'AnwesenheitFrm.pas' {frmAnwesenheit},
  LehrerDm in 'LehrerDm.pas' {dmLehrer: TDataModule},
  LehrerFrm in 'LehrerFrm.pas' {frmLehrer},
  MailDm in 'MailDm.pas' {dmMail: TDataModule},
  MailFrm in 'MailFrm.pas' {frmMail},
  MailGraph in 'MailGraph.pas',
  GraphLoginFrm in 'GraphLoginFrm.pas' {frmGraphLogin},
  LohnDm in 'LohnDm.pas' {dmLohn: TDataModule},
  LohnFrm in 'LohnFrm.pas' {frmLohn},
  AnlagenDm in 'AnlagenDm.pas' {dmAnlagen: TDataModule},
  AnlagenFrm in 'AnlagenFrm.pas' {frmAnlagen},
  KalkulationDm in 'KalkulationDm.pas' {dmKalkulation: TDataModule},
  KalkulationFrm in 'KalkulationFrm.pas' {frmKalkulation},
  EinstellungenDm in 'EinstellungenDm.pas' {dmEinstellungen: TDataModule},
  EinstellungenFrm in 'EinstellungenFrm.pas' {frmEinstellungen},
  MitarbeiterDm in 'MitarbeiterDm.pas' {dmMitarbeiter: TDataModule},
  MitarbeiterFrm in 'MitarbeiterFrm.pas' {frmMitarbeiter},
  DokumenteDm in 'DokumenteDm.pas' {dmDokumente: TDataModule},
  DokumenteFrm in 'DokumenteFrm.pas' {frmDokumente},
  ScannerDm in 'ScannerDm.pas' {dmScanner: TDataModule},
  ScannerFrm in 'ScannerFrm.pas' {frmScanner},
  PGManagerDm in 'PGManagerDm.pas' {dmPGManager: TDataModule},
  PGManagerFrm in 'PGManagerFrm.pas' {frmPGManager},
  LagerDm in 'LagerDm.pas' {dmLager: TDataModule},
  LagerFrm in 'LagerFrm.pas' {frmLager},
  UIRibbon in '..\RibbonFramework\Lib\UIRibbon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  // dmMandant zuerst: frmMain.FormCreate greift beim Erzeugen direkt darauf zu
  Application.CreateForm(TdmMandant, dmMandant);
  //Application.CreateForm(TForm3, Form3);
  //AApplication.CreateForm(TForm2, Form2);
  // Reihenfolge wichtig: MDI-Frame zuerst, dann DataModules
  Application.CreateForm(TfrmMain, frmMain);
  // MessageHandler muss früh erstellen damit er beim EventBus registriert ist
  Application.CreateForm(TdmMessageHandler, dmMessageHandler);
  Application.CreateForm(TdmPython, dmPython);
  // CSharp-Bruecke — MUSS nach dmPython kommen (nutzt dessen Engine)
  Application.CreateForm(TdmCSharp, dmCSharp);
  // Texterkennung: braucht wie dmCSharp die eine PythonEngine
  Application.CreateForm(TdmDokumentOcr, dmDokumentOcr);
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
  // ArtikelStamm — CreateForm noetig (RTTI-Dispatch); braucht dmPGManager,
  // das oben bereits erzeugt ist
  Application.CreateForm(TdmArtikelStamm, dmArtikelStamm);
  // Rechnungstyp — CreateForm noetig (RTTI-Dispatch); braucht dmPGManager/dmMandant,
  // die oben bereits erzeugt sind
  // KundenBestellung — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmKundenBestellung, dmKundenBestellung);
  // LieferantenBestellung — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmLieferantenBestellung, dmLieferantenBestellung);
  // LagerEntnahme — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmLagerEntnahme, dmLagerEntnahme);
  // Klient — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmKlient, dmKlient);
  // Kunde — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmKunde, dmKunde);
  // Einstellungen — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmEinstellungen, dmEinstellungen);
  // Mail — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmMail, dmMail);
  // Muss erzeugt werden, auch wenn das Modul nur per RTTI-String aufgerufen
  // wird (OpenGui('Lohn')) — sonst optimiert der Smart-Linker die Klasse samt
  // RTTI weg und HandleMessage findet sie zur Laufzeit nicht.
  Application.CreateForm(TdmLohn, dmLohn);
  Application.CreateForm(TdmAnlagen, dmAnlagen);
  Application.CreateForm(TdmKalkulation, dmKalkulation);
  // Kurs — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmKurs, dmKurs);
  // Lehrer - CreateForm noetig (RTTI-Dispatch), sonst linkt der
  // Smart-Linker die Klasse weg und OpenGui findet sie nicht
  Application.CreateForm(TdmLehrer, dmLehrer);
  // Anwesenheit — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmAnwesenheit, dmAnwesenheit);
  // Mitarbeiter — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmMitarbeiter, dmMitarbeiter);
  Application.Run;
end.
