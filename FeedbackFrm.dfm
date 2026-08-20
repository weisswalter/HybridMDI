object frmFeedback: TfrmFeedback
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Feedback'
  ClientHeight = 360
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object lblTitel: TLabel
    Left = 16
    Top = 16
    Width = 200
    Height = 21
    Caption = 'Lob, Kritik, Vorschlag'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblModul: TLabel
    Left = 16
    Top = 44
    Width = 60
    Height = 15
    Caption = 'Modul: -'
  end
  object lblText: TLabel
    Left = 16
    Top = 178
    Width = 68
    Height = 15
    Caption = 'Ihr Anliegen'
  end
  object rgKategorie: TRadioGroup
    Left = 16
    Top = 72
    Width = 428
    Height = 90
    Caption = 'Art des Feedbacks'
    ItemIndex = 0
    Items.Strings = (
      'Lob'
      'Kritik'
      'Verbesserungsvorschlag')
    TabOrder = 0
  end
  object memText: TMemo
    Left = 16
    Top = 198
    Width = 428
    Height = 110
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object btnAbsenden: TButton
    Left = 264
    Top = 320
    Width = 90
    Height = 30
    Caption = 'Absenden'
    Default = True
    TabOrder = 2
    OnClick = btnAbsendenClick
  end
  object btnAbbrechen: TButton
    Left = 360
    Top = 320
    Width = 84
    Height = 30
    Caption = 'Abbrechen'
    Cancel = True
    TabOrder = 3
    OnClick = btnAbbrechenClick
  end
end
