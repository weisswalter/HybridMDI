program PrjHybridMDI;

uses
  Vcl.Forms,
  // Event-Interfaces (müssen früh geladen sein damit TInterfaceHelper sie im Cache hat)
  uAppEvents in 'uAppEvents.pas',
  // EventBus-Framework
  EventBus in 'EventBus\EventBus.pas',
  EventBus.Core in 'EventBus\EventBus.Core.pas',
  EventBus.Helpers in 'EventBus\EventBus.Helpers.pas',
  EventBus.Subscribers in 'EventBus\EventBus.Subscribers.pas',
  // MDI-Hauptfenster
  uFrmMain in 'uFrmMain.pas' {frmMain},
  // DataModule Python — früh erstellen damit PythonEngine bereit ist
  uDmPython in 'uDmPython.pas' {dmPython: TDataModule},
  // Delphi Module
  uDmKunden in 'uDmKunden.pas' {dmKunden: TDataModule},
  uFrmKunden in 'uFrmKunden.pas' {frmKunden},
  uDmArtikel in 'uDmArtikel.pas' {dmArtikel: TDataModule},
  uFrmArtikel in 'uFrmArtikel.pas' {frmArtikel};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  // Reihenfolge wichtig: MDI-Frame zuerst, dann DataModules
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmPython, dmPython);
  Application.CreateForm(TdmKunden, dmKunden);
  Application.CreateForm(TdmArtikel, dmArtikel);
  Application.Run;
end.
