object ConvertForm: TConvertForm
  Left = 0
  Top = 0
  Caption = 'ConvertForm'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object btnConvert: TButton
    Left = 176
    Top = 184
    Width = 75
    Height = 25
    Caption = 'btnConvert'
    TabOrder = 0
    OnClick = btnConvertClick
  end
  object memLog: TMemo
    Left = 288
    Top = 304
    Width = 185
    Height = 89
    Lines.Strings = (
      'memLog')
    TabOrder = 1
  end
  object OpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 336
    Top = 112
  end
end
