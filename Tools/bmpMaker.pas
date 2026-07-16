unit bmpMaker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TForm1 = class(TForm)
    btn1: TButton;
    dlgOpen1: TOpenDialog;
    btn16: TButton;
    btnFromImage32: TButton;
    dlgSave1: TSaveDialog;
    pnl1: TPanel;
    img: TImage;
    btnFromImage16: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn16Click(Sender: TObject);
    procedure btnFromImage32Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFromImage16Click(Sender: TObject);
  private
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Vcl.Clipbrd;

procedure TForm1.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  OnKeyDown := FormKeyDown;   // WICHTIG!
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('V')) and (Shift = [ssCtrl]) then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
      Img.Picture.Assign(Clipboard);
  end;
end;


procedure TForm1.btn16Click(Sender: TObject);
var
  Png: TPngImage;
  Bmp: TBitmap;
begin
  if dlgOpen1.Execute then
  begin

  Png := TPngImage.Create;
  Bmp := TBitmap.Create;
  try
    Png.LoadFromFile(dlgOpen1.FileName);
    Bmp.SetSize(32, 32);
    Bmp.PixelFormat := pf32bit;
    Bmp.Canvas.StretchDraw(Rect(0, 0, 16, 16), Png);
    Bmp.SaveToFile(ExtractFileName(dlgOpen1.FileName) + '16.bmp');
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

end;


procedure TForm1.btn1Click(Sender: TObject);
var
  Png: TPngImage;
  Bmp: TBitmap;
begin
  if dlgOpen1.Execute then
  begin

  Png := TPngImage.Create;
  Bmp := TBitmap.Create;
  try
    Png.LoadFromFile(dlgOpen1.FileName);
    Bmp.SetSize(32, 32);
    Bmp.PixelFormat := pf32bit;
    Bmp.Canvas.StretchDraw(Rect(0, 0, 32, 32), Png);
    Bmp.SaveToFile(ExtractFileName(dlgOpen1.FileName) + '32.bmp');
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

end;

procedure TForm1.btnFromImage16Click(Sender: TObject);
var
  Bmp: TBitmap;
begin
  if Img.Picture.Graphic = nil then
    raise Exception.Create('Kein Bild vorhanden.');

  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(16, 16);
    Bmp.PixelFormat := pf32bit;

    // Egal ob PNG, JPG oder Bitmap → alles wird gezeichnet
    Bmp.Canvas.StretchDraw(Rect(0, 0, 16, 16), Img.Picture.Graphic);

    if dlgSave1.Execute then
     Bmp.SaveToFile(ExtractFileName(dlgSave1.FileName) + '16.bmp');
  finally
    Bmp.Free;
  end;
end;

procedure TForm1.btnFromImage32Click(Sender: TObject);
var
  Bmp: TBitmap;
begin
  if Img.Picture.Graphic = nil then
    raise Exception.Create('Kein Bild vorhanden.');

  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(32, 32);
    Bmp.PixelFormat := pf32bit;

    // Egal ob PNG, JPG oder Bitmap → alles wird gezeichnet
    Bmp.Canvas.StretchDraw(Rect(0, 0, 32, 32), Img.Picture.Graphic);

    if dlgSave1.Execute then
     Bmp.SaveToFile(ExtractFileName(dlgSave1.FileName) + '32.bmp');
  finally
    Bmp.Free;
  end;
end;

end.
