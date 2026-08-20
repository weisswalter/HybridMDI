object frmNotfall: TfrmNotfall
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Notfallzugang'
  ClientHeight = 520
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object lblTitel: TLabel
    Left = 24
    Top = 20
    Width = 111
    Height = 21
    Caption = 'Notfallzugang'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblHinweis: TLabel
    Left = 24
    Top = 48
    Width = 592
    Height = 50
    AutoSize = False
    WordWrap = True
  end
  object lblTan: TLabel
    Left = 24
    Top = 108
    Width = 23
    Height = 15
    Caption = 'TAN'
  end
  object lblStand: TLabel
    Left = 24
    Top = 484
    Width = 592
    Height = 28
    AutoSize = False
    WordWrap = True
  end
  object edtTan: TEdit
    Left = 24
    Top = 128
    Width = 380
    Height = 23
    CharCase = ecUpperCase
    TabOrder = 0
  end
  object btnPruefen: TButton
    Left = 416
    Top = 127
    Width = 120
    Height = 26
    Caption = 'Freischalten'
    Default = True
    TabOrder = 1
    OnClick = btnPruefenClick
  end
  object pnlAktionen: TPanel
    Left = 24
    Top = 168
    Width = 592
    Height = 100
    BevelOuter = bvNone
    Enabled = False
    ShowCaption = False
    TabOrder = 2
    object lblAktionen: TLabel
      Left = 0
      Top = 0
      Width = 592
      Height = 30
      AutoSize = False
      Caption = 
        'Vor dem Zur'#252'cksetzen unbedingt eine aktuelle Sicherung ziehen - ' +
        'nur so l'#228'sst sich auch dieser Schritt wieder r'#252'ckg'#228'ngig machen.'
      WordWrap = True
    end
    object btnSicherung: TButton
      Left = 0
      Top = 36
      Width = 200
      Height = 34
      Caption = 'Sicherung jetzt erstellen'
      TabOrder = 0
      OnClick = btnSicherungClick
    end
    object btnWiederherstellen: TButton
      Left = 216
      Top = 36
      Width = 280
      Height = 34
      Caption = 'Auf letzten Sicherungsstand zur'#252'cksetzen'
      TabOrder = 1
      OnClick = btnWiederherstellenClick
    end
  end
  object memProtokoll: TMemo
    Left = 24
    Top = 280
    Width = 592
    Height = 160
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnSchliessen: TButton
    Left = 526
    Top = 450
    Width = 90
    Height = 28
    Cancel = True
    Caption = 'Schliessen'
    TabOrder = 4
    OnClick = btnSchliessenClick
  end
end
