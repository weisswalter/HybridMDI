object frmKunden: TfrmKunden
  Left = 0
  Top = 0
  Caption = 'Kunden'
  ClientHeight = 300
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 258
    Width = 500
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnSpeichern: TButton
      Left = 314
      Top = 8
      Width = 80
      Height = 25
      Caption = 'Speichern'
      Default = True
      OnClick = btnSpeichernClick
    end
    object btnSchliessen: TButton
      Left = 406
      Top = 8
      Width = 80
      Height = 25
      Caption = 'Schliessen'
      OnClick = btnSchliessenClick
    end
  end
  object lblNummer: TLabel
    Left = 20
    Top = 20
    Width = 47
    Height = 15
    Caption = 'Nummer:'
  end
  object edtNummer: TEdit
    Left = 90
    Top = 16
    Width = 100
    Height = 23
    TabOrder = 1
  end
  object lblName: TLabel
    Left = 20
    Top = 56
    Width = 35
    Height = 15
    Caption = 'Name:'
  end
  object edtName: TEdit
    Left = 90
    Top = 52
    Width = 300
    Height = 23
    TabOrder = 2
  end
end
