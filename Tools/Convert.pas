unit Convert;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, System.IOUtils;

type
  TConvertForm = class(TForm)
    btnConvert: TButton;
    memLog: TMemo;
    OpenDialog1: TFileOpenDialog;
    procedure btnConvertClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure ConvertFilesToText(const FileList: TStrings);
  public
    { Public-Deklarationen }
  end;

var
  ConvertForm: TConvertForm;

implementation

{$R *.dfm}

procedure TConvertForm.btnConvertClick(Sender: TObject);
begin
  memLog.Clear;

  // OpenDialog1 ist jetzt die Komponente auf dem Formular
//  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofEnableSizing];
//  OpenDialog1.OptionsEx := [ofExNoPlacesBar];
//  OpenDialog1.Title := 'Wähle die Dateien aus, die in .txt konvertiert werden sollen';
//  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofHideReadOnly];
//  OpenDialog1.Filter := 'Alle Dateien (*.*)|*.*';
  OpenDialog1.Options := [fdoPickFolders];
  if OpenDialog1.Execute then
  begin
    ConvertFilesToText(OpenDialog1.Files);
  end;
end;

procedure TConvertForm.ConvertFilesToText(const FileList: TStrings);
var
  TargetDir: string;

  // HILFSROUTINE: Durchsucht Ordner & Unterordner rekursiv
  procedure ProcessPath(const APath: string);
  var
    SR: TSearchRec;
    DestFile: string;
  begin
    // 1. Ist es eine Datei?
    if FileExists(APath) then
       // Relevante Dateiendungen für ein C#/Blazor-Projekt
    if (Lowercase(ExtractFileExt(APath)) = '.razor') or
     (Lowercase(ExtractFileExt(APath)) = '.cs') or
     (Lowercase(ExtractFileExt(APath)) = '.cshtml') or
     (Lowercase(ExtractFileExt(APath)) = '.razor.css') or
     (Lowercase(ExtractFileExt(APath)) = '.razor.js') or
     (Lowercase(ExtractFileExt(APath)) = '.json') or      // Konfigurationsdateien
     (Lowercase(ExtractFileExt(APath)) = '.config') or
     (Lowercase(ExtractFileExt(APath)) = '.xml') or
     (Lowercase(ExtractFileExt(APath)) = '.csproj') or    // Projektdateien
     (Lowercase(ExtractFileExt(APath)) = '.sln') then     // Lösungsdateien
    begin
      // Zieldateiname bauen (z. B. "bild.png.txt")
      DestFile := TargetDir + ExtractFileName(APath) + '.txt';
      try
        // Direct Copy verhindert alle Enkodierungs-Fehler!
        TFile.Copy(APath, DestFile, True); // True = Überschreiben erlaubt

        memLog.Lines.Add('[OK] Erstellt: ' + ExtractFileName(DestFile));
      except
        on E: Exception do
          memLog.Lines.Add('[FEHLER] bei ' + ExtractFileName(APath) + ': ' + E.Message);
      end;
      Exit;
    end;

    // 2. Ist es ein Ordner? Rekursiv durchsuchen
    if DirectoryExists(APath) then
    begin
      if FindFirst(IncludeTrailingPathDelimiter(APath) + '*.*', faAnyFile, SR) = 0 then
      begin
        try
          repeat
            if (SR.Name = '.') or (SR.Name = '..') then
              Continue;

            ProcessPath(IncludeTrailingPathDelimiter(APath) + SR.Name);
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      end;
    end;
  end;

var
  i: Integer;
begin
  TargetDir := 'C:\Tmp\DeepSeek\Dynamic\';

  if not DirectoryExists(TargetDir) then
    ForceDirectories(TargetDir);

  memLog.Lines.Add('Starte Konvertierung (inkl. Unterordner)...');

  for i := 0 to FileList.Count - 1 do
  begin
    ProcessPath(FileList[i]);
  end;

  memLog.Lines.Add('Fertig! Alle Dateien aus allen Ordnern wurden kopiert.');
end;

end.
