object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 549
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object btn1: TButton
    Left = 192
    Top = 232
    Width = 75
    Height = 25
    Caption = '32x32'
    TabOrder = 0
    OnClick = btnFromImage32Click
  end
  object btn16: TButton
    Left = 280
    Top = 232
    Width = 75
    Height = 25
    Caption = '16x16'
    TabOrder = 1
    OnClick = btn16Click
  end
  object btnFromImage32: TButton
    Left = 416
    Top = 232
    Width = 129
    Height = 25
    Caption = '32FromImage'
    TabOrder = 2
    OnClick = btn1Click
  end
  object pnl1: TPanel
    Left = 96
    Top = 24
    Width = 113
    Height = 107
    BorderStyle = bsSingle
    Caption = 'pnl1'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 3
    object img: TImage
      Left = 4
      Top = -2
      Width = 105
      Height = 105
      Stretch = True
    end
  end
  object btnFromImage16: TButton
    Left = 416
    Top = 263
    Width = 129
    Height = 25
    TabOrder = 4
    OnClick = btn2Click
  end
  object dlgOpen1: TOpenDialog
    Left = 240
    Top = 120
  end
  object dlgSave1: TSaveDialog
    Left = 152
    Top = 128
  end
end
