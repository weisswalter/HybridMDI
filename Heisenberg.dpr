program Heisenberg;

uses
  Vcl.Forms,
  // Event-Interfaces und MessageHandler-Interfaces
  uAppEvents in 'uAppEvents.pas',
  UInterfaces,
  uMessageHandler in 'uMessageHandler.pas' {dmMessageHandler: TDataModule},
  // EventBus-Framework
  EventBus ,
  EventBus.Core ,
  EventBus.Helpers ,
  EventBus.Subscribers ,
  // MDI-Hauptfenster
  uFrmMain in 'uFrmMain.pas' {frmMain},
  // DataModule Python — früh erstellen damit PythonEngine bereit ist
  uDmPython in 'uDmPython.pas' {dmPython: TDataModule},
  // Delphi Module
  uDmKunden in 'uDmKunden.pas' {dmKunden: TDataModule},
  uFrmKunden in 'uFrmKunden.pas' {frmKunden},
  uDmArtikel in 'uDmArtikel.pas' {dmArtikel: TDataModule},
  uFrmArtikel in 'uFrmArtikel.pas' {frmArtikel},
  // Dokumente — FireDAC auf TRTHeisenberg PostgreSQL
  uDmDokumente in 'uDmDokumente.pas' {dmDokumente: TDataModule},
  uFrmDokumente in 'uFrmDokumente.pas' {frmDokumente};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  // Reihenfolge wichtig: MDI-Frame zuerst, dann DataModules
  Application.CreateForm(TfrmMain, frmMain);
  // MessageHandler muss früh erstellen damit er beim EventBus registriert ist
  Application.CreateForm(TdmMessageHandler, dmMessageHandler);
  Application.CreateForm(TdmPython, dmPython);
  Application.CreateForm(TdmKunden, dmKunden);
  Application.CreateForm(TdmArtikel, dmArtikel);
  Application.CreateForm(TdmDokumente, dmDokumente);
  Application.Run;
end.
