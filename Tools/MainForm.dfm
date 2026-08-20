object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Blazor App Analyzer - FLACHE Kopie mit .txt'
  ClientHeight = 480
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object lblSource: TLabel
    Left = 24
    Top = 24
    Width = 60
    Height = 13
    Caption = 'Quellordner:'
  end
  object lblTarget: TLabel
    Left = 24
    Top = 64
    Width = 52
    Height = 13
    Caption = 'Zielordner:'
  end
  object btnSelectSource: TButton
    Left = 600
    Top = 19
    Width = 75
    Height = 25
    Caption = 'Durchsuchen'
    TabOrder = 0
    OnClick = btnSelectSourceClick
  end
  object btnSelectTarget: TButton
    Left = 600
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Durchsuchen'
    TabOrder = 1
    OnClick = btnSelectTargetClick
  end
  object btnCopy: TButton
    Left = 296
    Top = 130
    Width = 113
    Height = 33
    Caption = 'Kopieren starten'
    TabOrder = 2
    OnClick = btnCopyClick
  end
  object edtSource: TEdit
    Left = 104
    Top = 21
    Width = 481
    Height = 21
    TabOrder = 3
  end
  object edtTarget: TEdit
    Left = 104
    Top = 61
    Width = 481
    Height = 21
    TabOrder = 4
  end
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 178
    Width = 651
    Height = 17
    TabOrder = 5
  end
  object memLog: TMemo
    Left = 24
    Top = 210
    Width = 651
    Height = 241
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object chkAddTxt: TCheckBox
    Left = 24
    Top = 104
    Width = 250
    Height = 17
    Caption = '.txt an alle Dateien anh'#195#164'ngen (f'#195#188'r Upload)'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
end
