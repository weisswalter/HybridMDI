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
  Eventbus.Core in '..\delphi-event-bus\source\Eventbus.Core.pas',
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
  // Neues, schlankes Anzeigeformular (19.08.2026). Das alte mit Fotos,
  // Bestand, Varianten und Stueckliste liegt als Vorlage unter
  // ArtikelStammFrm.pas.stillgelegt.
  ArtikelStammFrm in 'ArtikelStammFrm.pas' {frmArtikelStamm},
  KundenBestellungDm in 'KundenBestellungDm.pas' {dmKundenBestellung: TDataModule},
  KundenBestellungFrm in 'KundenBestellungFrm.pas' {frmKundenBestellung},
  LieferantenBestellungDm in 'LieferantenBestellungDm.pas' {dmLieferantenBestellung: TDataModule},
  LieferantenBestellungFrm in 'LieferantenBestellungFrm.pas' {frmLieferantenBestellung},
  LagerEntnahmeDm in 'LagerEntnahmeDm.pas' {dmLagerEntnahme: TDataModule},
  VorgangDm in 'VorgangDm.pas' {dmVorgang: TDataModule},
  VorgangFrm in 'VorgangFrm.pas' {frmVorgang},
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
  FeedbackFrm in 'FeedbackFrm.pas' {frmFeedback},
  KursAnwesenheitDm in 'KursAnwesenheitDm.pas' {dmKursAnwesenheit: TDataModule},
  KursAnwesenheitFrm in 'KursAnwesenheitFrm.pas' {frmKursAnwesenheit},
  ZentraleDatenDm in 'ZentraleDatenDm.pas' {dmZentraleDaten: TDataModule},
  WebEditorDm in 'WebEditorDm.pas' {dmWebEditor: TDataModule},
  WebEditorFrm in 'WebEditorFrm.pas' {frmWebEditor},
  BenutzerDm in 'BenutzerDm.pas' {dmBenutzer: TDataModule},
  BenutzerFrm in 'BenutzerFrm.pas' {frmBenutzer},
  LoginFrm in 'LoginFrm.pas' {frmLogin},
  NotfallFrm in 'NotfallFrm.pas' {frmNotfall},
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
  UIRibbon in '..\RibbonFramework\Lib\UIRibbon.pas',
  uFrmGuiTemplate in 'uFrmGuiTemplate.pas' {frmGuiTemplate},
  ArtikelStammDm in 'ArtikelStammDm.pas' {dmArtikelStamm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmZentraleDaten, dmZentraleDaten);

  // frmMain zuerst: Application.CreateForm macht das erste erzeugte TForm zum
  // MainForm, und fsMDIForm wirkt nur am MainForm. Die Datenmodule sind zwar
  // wieder TDataModule und koennen den Platz nicht mehr belegen - die
  // Reihenfolge bleibt trotzdem, weil sie die richtige ist.
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmArtikelStamm, dmArtikelStamm);
  // Das zentrale Datenmodul wird hier nur ERZEUGT (Verbindung), es holt seine
  // Tabellen noch nicht - das passiert weiter unten, wenn frmMain steht und
  // den Fortschritt anzeigen kann.

  TdmMandant.GetInstance;
  // Statuszeile jetzt fuellen: beim FormCreate von frmMain gab es dmMandant
  // noch nicht.
  frmMain.UpdateMandantStatus;

  // Jetzt erst die Tabellen holen: das Fenster steht, der Balken in der
  // Statuszeile zeigt Tabelle fuer Tabelle, was gerade passiert.
  frmMain.Show;
  Application.ProcessMessages;
  dmZentraleDaten.OnLadeFortschritt := frmMain.LadeFortschritt;
  try
    dmZentraleDaten.AlleTabellenLaden;
  finally
    frmMain.LadenFertig;
  end;
  // MessageHandler muss früh erstellen damit er beim EventBus registriert ist
  Application.CreateForm(TdmMessageHandler, dmMessageHandler);
  Application.CreateForm(TdmPython, dmPython);
  // CSharp-Bruecke — MUSS nach dmPython kommen (nutzt dessen Engine)
  Application.CreateForm(TdmCSharp, dmCSharp);
  // Texterkennung: braucht wie dmCSharp die eine PythonEngine
  Application.CreateForm(TdmDokumentOcr, dmDokumentOcr);
  Application.CreateForm(TdmPyKunden, dmPyKunden);
  Application.CreateForm(TdmPyArtikel, dmPyArtikel);
  // Siehe oben in der uses-Liste: EventBus-Demo, Units auskommentiert.
  // Application.CreateForm(TdmKunden, dmKunden);
  // Application.CreateForm(TdmArtikel, dmArtikel);
  Application.CreateForm(TdmDokumente, dmDokumente);
  // Scanner — Application.CreateForm noetig, sonst entfernt der Smart-Linker die
  // Klasse und mtModulCall TdmScanner.OpenScanner findet sie nicht (RTTI-Dispatch)
  Application.CreateForm(TdmScanner, dmScanner);
  Application.CreateForm(TdmPGManager, dmPGManager);
  Application.CreateForm(TdmPersonen, dmPersonen);
  // Lager — CreateForm noetig (RTTI-Dispatch, sonst linkt der Smart-Linker die Klasse weg)
  Application.CreateForm(TdmLager, dmLager);
  // ArtikelStamm wird WEITER OBEN erzeugt, vor AlleTabellenLaden - nur dann
  // erreicht ihn der Broadcast "DatenGeladen". Ein zweites CreateForm hier
  // wuerde eine ZWEITE Instanz anlegen und die globale Variable darauf
  // umhaengen; die erste bekaeme den Broadcast, die zweite waere leer.
  // (Genau das war der Grund fuer die leere Artikelliste am 20.08.2026.)
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
  Application.CreateForm(TdmKursAnwesenheit, dmKursAnwesenheit);
  // WebEditor - CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmWebEditor, dmWebEditor);
  // Kurs — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmKurs, dmKurs);
  // Lehrer - CreateForm noetig (RTTI-Dispatch), sonst linkt der
  // Smart-Linker die Klasse weg und OpenGui findet sie nicht
  Application.CreateForm(TdmLehrer, dmLehrer);
  // Anwesenheit — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmAnwesenheit, dmAnwesenheit);
  // Mitarbeiter — CreateForm noetig (RTTI-Dispatch)
  Application.CreateForm(TdmMitarbeiter, dmMitarbeiter);
  // Benutzer/Anmeldung — CreateForm noetig (RTTI-Dispatch) und ausserdem
  // Voraussetzung fuer die Anmeldepruefung direkt darunter.
  Application.CreateForm(TdmBenutzer, dmBenutzer);

  // ── Anmeldung ────────────────────────────────────────────────────────────
  // Erst NACH allen CreateForm-Aufrufen, weil dmBenutzer und dmPGManager
  // stehen muessen. Gibt es noch KEINEN Benutzer, laeuft das Programm ohne
  // Anmeldung weiter — sonst koennte man sich bei einer frischen Datenbank
  // aussperren. Sobald ein Konto existiert, ist die Anmeldung Pflicht, und
  // ein Abbruch beendet das Programm.
  if dmBenutzer.AnmeldungErforderlich then
    if not TfrmLogin.Anmelden then
      Exit;

  // dokument traegt die PDF-Blobs und ist um Groessenordnungen schwerer als
  // alles andere. Deshalb ganz zum Schluss, wenn der Benutzer schon arbeiten
  // koennte - und nicht als Teil der Startwartezeit.
  try
    dmZentraleDaten.NachladenSchwere;
  finally
    frmMain.LadenFertig;
    dmZentraleDaten.OnLadeFortschritt := nil;
  end;

  Application.Run;
end.
