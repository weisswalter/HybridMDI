object frmArtikel: TfrmArtikel
  Left = 0
  Top = 0
  Caption = 'Artikel'
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
  object lblArtNr: TLabel
    Left = 20
    Top = 20
    Width = 38
    Height = 15
    Caption = 'Art.-Nr.:'
  end
  object edtArtNr: TEdit
    Left = 90
    Top = 16
    Width = 100
    Height = 23
    TabOrder = 1
  end
  object lblBezeichnung: TLabel
    Left = 20
    Top = 56
    Width = 67
    Height = 15
    Caption = 'Bezeichnung:'
  end
  object edtBezeichnung: TEdit
    Left = 90
    Top = 52
    Width = 300
    Height = 23
    TabOrder = 2
  end
  object lblPreis: TLabel
    Left = 20
    Top = 92
    Width = 30
    Height = 15
    Caption = 'Preis:'
  end
  object edtPreis: TEdit
    Left = 90
    Top = 88
    Width = 100
    Height = 23
    TabOrder = 3
  end
end
