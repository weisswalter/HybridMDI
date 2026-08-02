object frmGraphLogin: TfrmGraphLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Anmeldung bei Microsoft'
  ClientHeight = 285
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  TextHeight = 15
  object lblTitel: TLabel
    Left = 16
    Top = 16
    Width = 275
    Height = 21
    Caption = 'Anmeldung bei Microsoft (Ger'#228'tecode)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblErklaerung: TLabel
    Left = 16
    Top = 48
    Width = 488
    Height = 50
    AutoSize = False
    Caption =
      'Der Code wird bei Microsoft angefordert. Sobald er hier steht: Se' +
      'ite '#246'ffnen, Code eingeben, anmelden. Dieses Fenster wartet solang' +
      'e.'
    WordWrap = True
  end
  object lblCodeText: TLabel
    Left = 16
    Top = 106
    Width = 71
    Height = 15
    Caption = 'Ger'#228'tecode'
  end
  object lblStatus: TLabel
    Left = 16
    Top = 210
    Width = 488
    Height = 32
    AutoSize = False
    WordWrap = True
  end
  object edtCode: TEdit
    Left = 16
    Top = 126
    Width = 250
    Height = 40
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object btnKopieren: TButton
    Left = 280
    Top = 128
    Width = 110
    Height = 36
    Caption = 'Code kopieren'
    Enabled = False
    TabOrder = 1
    OnClick = btnKopierenClick
  end
  object btnSeite: TButton
    Left = 396
    Top = 128
    Width = 108
    Height = 36
    Caption = 'Seite '#246'ffnen'
    Enabled = False
    TabOrder = 2
    OnClick = btnSeiteClick
  end
  object btnAbbrechen: TButton
    Left = 396
    Top = 248
    Width = 108
    Height = 28
    Caption = 'Abbrechen'
    TabOrder = 3
    OnClick = btnAbbrechenClick
  end
end
