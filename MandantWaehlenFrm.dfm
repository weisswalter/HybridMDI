object frmMandantWaehlen: TfrmMandantWaehlen
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Mandant ausw'#228'hlen'
  ClientHeight = 120
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object lblMandant: TLabel
    Left = 16
    Top = 16
    Width = 51
    Height = 15
    Caption = 'Mandant:'
  end
  object cboMandant: TComboBox
    Left = 16
    Top = 37
    Width = 328
    Height = 23
    Style = csDropDownList
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
