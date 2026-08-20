unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, Vcl.ExtCtrls,
  System.IOUtils, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    btnSelectSource: TButton;
    btnCopy: TButton;
    lblSource: TLabel;
    lblTarget: TLabel;
    edtSource: TEdit;
    edtTarget: TEdit;
    btnSelectTarget: TButton;
    ProgressBar1: TProgressBar;
    memLog: TMemo;
    chkAddTxt: TCheckBox;
    procedure btnSelectSourceClick(Sender: TObject);
    procedure btnSelectTargetClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
  private
    function FlattenCopyWithTxt(const SourceDir, TargetDir: string; AddTxtExtension: Boolean): Boolean;
    function ShouldCopyFile(const FileName: string): Boolean;
    function IsExcludedFolder(const FolderName: string): Boolean;
    procedure CollectFilesFlat(const Directory: string; FileList: TStringList);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


const
  // Relevante Dateiendungen für Blazor-Analyse
  RelevantExtensions: array[0..23] of string = (
    '.cs', '.razor', '.cshtml', '.html', '.htm', '.css', '.scss', '.js',
    '.ts', '.json', '.xml', '.config', '.csproj', '.sln', '.razor.css',
    '.razor.js', '.dll', '.exe', '.wasm','.pas', '.dfm', '.dpr','.dpk', '.dproj'
  );

  // Ordner die ignoriert werden sollen
  ExcludedFolders: array[0..10] of string = (
    'bin', 'obj', '.vs', '.vscode', 'node_modules',
    'dist', 'build', 'packages', '.git', '.idea', '.github'
  );

procedure TForm1.btnSelectSourceClick(Sender: TObject);
var
  SelectedDir: string;
begin
  if SelectDirectory('Bitte wählen Sie den Quellordner (Blazor-App)',
    '', SelectedDir) then
  begin
    edtSource.Text := SelectedDir;
    edtTarget.Text := IncludeTrailingPathDelimiter(SelectedDir) + 'Analyse_Flach_TXT';
  end;
end;

procedure TForm1.btnSelectTargetClick(Sender: TObject);
var
  SelectedDir: string;
begin
  if SelectDirectory('Bitte wählen Sie den Zielordner',
    '', SelectedDir) then
  begin
    edtTarget.Text := SelectedDir;
  end;
end;

function TForm1.ShouldCopyFile(const FileName: string): Boolean;
var
  Ext: string;
  I: Integer;
begin
  Result := False;
  Ext := LowerCase(ExtractFileExt(FileName));

  for I := 0 to High(RelevantExtensions) do
  begin
    if Ext = LowerCase(RelevantExtensions[I]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TForm1.IsExcludedFolder(const FolderName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(ExcludedFolders) do
  begin
    if LowerCase(FolderName) = LowerCase(ExcludedFolders[I]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TForm1.CollectFilesFlat(const Directory: string; FileList: TStringList);
var
  SearchRec: TSearchRec;
  FullPath: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Directory) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
          Continue;

        FullPath := IncludeTrailingPathDelimiter(Directory) + SearchRec.Name;

        if (SearchRec.Attr and faDirectory) = faDirectory then
        begin
          if not IsExcludedFolder(SearchRec.Name) then
            CollectFilesFlat(FullPath, FileList);
        end
        else
        begin
          if ShouldCopyFile(FullPath) then
            FileList.Add(FullPath);
        end;

      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

function TForm1.FlattenCopyWithTxt(const SourceDir, TargetDir: string; AddTxtExtension: Boolean): Boolean;
var
  FileList: TStringList;
  I: Integer;
  SourceFile, TargetFile: string;
  BaseName, TargetName: string;
  Counter: Integer;
begin
  Result := True;
  FileList := TStringList.Create;
  try
    memLog.Lines.Add('Scanne Quellordner (inkl. Unterordner)...');
    CollectFilesFlat(SourceDir, FileList);

    if FileList.Count = 0 then
    begin
      memLog.Lines.Add('Keine relevanten Dateien gefunden!');
      Exit;
    end;

    if not DirectoryExists(TargetDir) then
      ForceDirectories(TargetDir);

    ProgressBar1.Max := FileList.Count;
    memLog.Lines.Add(Format('%d relevante Dateien gefunden.', [FileList.Count]));
    memLog.Lines.Add('----------------------------');

    for I := 0 to FileList.Count - 1 do
    begin
      SourceFile := FileList[I];
      BaseName := ExtractFileName(SourceFile);

      // Dateinamen für Ziel festlegen
      if AddTxtExtension then
      begin
        // Originalendung + .txt anhängen
        TargetName := BaseName + '.txt';
      end
      else
      begin
        // Originalendung beibehalten
        TargetName := BaseName;
      end;

      TargetFile := IncludeTrailingPathDelimiter(TargetDir) + TargetName;

      // Prüfen ob Datei bereits existiert -> umbenennen
      Counter := 1;
      while FileExists(TargetFile) do
      begin
        if AddTxtExtension then
        begin
          // Bei Kollision: datei_1.cs.txt, datei_2.cs.txt, ...
          TargetName := ChangeFileExt(BaseName, '') + '_' + IntToStr(Counter) + 
                        ExtractFileExt(BaseName) + '.txt';
        end
        else
        begin
          TargetName := ChangeFileExt(BaseName, '') + '_' + IntToStr(Counter) + 
                        ExtractFileExt(BaseName);
        end;
        TargetFile := IncludeTrailingPathDelimiter(TargetDir) + TargetName;
        Inc(Counter);
      end;

      try
        TFile.Copy(SourceFile, TargetFile, True);
        memLog.Lines.Add('Kopiert: ' + TargetName + '  (aus: ' + ExtractFilePath(SourceFile) + ')');
      except
        on E: Exception do
        begin
          memLog.Lines.Add('FEHLER: ' + BaseName + ' - ' + E.Message);
          Result := False;
        end;
      end;

      ProgressBar1.Position := I + 1;
      Application.ProcessMessages;
    end;

    memLog.Lines.Add('----------------------------');
    memLog.Lines.Add(Format('Fertig: %d Dateien kopiert (flach ohne Ordnerstruktur).',
      [FileList.Count]));
    if AddTxtExtension then
      memLog.Lines.Add('Alle Dateien haben die Endung .txt erhalten!');
  finally
    FileList.Free;
  end;
end;

procedure TForm1.btnCopyClick(Sender: TObject);
begin
  if (edtSource.Text = '') or (edtTarget.Text = '') then
  begin
    ShowMessage('Bitte wählen Sie Quell- und Zielordner aus!');
    Exit;
  end;

  if not DirectoryExists(edtSource.Text) then
  begin
    ShowMessage('Quellordner existiert nicht!');
    Exit;
  end;

  memLog.Clear;
  ProgressBar1.Position := 0;

  Screen.Cursor := crHourGlass;
  try
    memLog.Lines.Add('MODUS: Flache Kopie (ohne Ordnerstruktur)');
    memLog.Lines.Add('Von: ' + edtSource.Text);
    memLog.Lines.Add('Nach: ' + edtTarget.Text);
    memLog.Lines.Add('----------------------------');

    if FlattenCopyWithTxt(edtSource.Text, edtTarget.Text, chkAddTxt.Checked) then
      ShowMessage('Kopiervorgang erfolgreich abgeschlossen!')
    else
      ShowMessage('Kopiervorgang mit Fehlern abgeschlossen (siehe Log).');
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.