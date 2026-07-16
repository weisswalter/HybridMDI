object frmMandantNeu: TfrmMandantNeu
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Neuer Mandant'
  ClientHeight = 120
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object lblName: TLabel
    Left = 16
    Top = 16
    Width = 88
    Height = 15
    Caption = 'Mandantenname:'
  end
  object edtName: TEdit
    Left = 16
    Top = 37
    Width = 328
    Height = 23
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 188
    Top = 78
    Width = 75
    Height = 28
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnAbbrechen: TButton
    Left = 269
    Top = 78
    Width = 75
    Height = 28
    Caption = 'Abbrechen'
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
end
