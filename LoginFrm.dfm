object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Anmeldung'
  ClientHeight = 300
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object lblTitel: TLabel
    Left = 24
    Top = 20
    Width = 100
    Height = 21
    Caption = 'Anmeldung'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblName: TLabel
    Left = 24
    Top = 60
    Width = 78
    Height = 15
    Caption = 'Anmeldename'
  end
  object lblPasswort: TLabel
    Left = 24
    Top = 112
    Width = 50
    Height = 15
    Caption = 'Passwort'
  end
  object lblPasswort2: TLabel
    Left = 24
    Top = 164
    Width = 118
    Height = 15
    Caption = 'Passwort wiederholen'
    Visible = False
  end
  object lblHinweis: TLabel
    Left = 24
    Top = 212
    Width = 392
    Height = 44
    AutoSize = False
    WordWrap = True
  end
  object edtName: TEdit
    Left = 24
    Top = 80
    Width = 392
    Height = 23
    TabOrder = 0
  end
  object edtPasswort: TEdit
    Left = 24
    Top = 132
    Width = 392
    Height = 23
    PasswordChar = '*'
    TabOrder = 1
  end
  object edtPasswort2: TEdit
    Left = 24
    Top = 184
    Width = 392
    Height = 23
    PasswordChar = '*'
    TabOrder = 2
    Visible = False
  end
  object btnOK: TButton
    Left = 240
    Top = 262
    Width = 90
    Height = 30
    Caption = 'Anmelden'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnAbbrechen: TButton
    Left = 336
    Top = 262
    Width = 80
    Height = 30
    Caption = 'Abbrechen'
    Cancel = True
    TabOrder = 4
    OnClick = btnAbbrechenClick
  end
end
