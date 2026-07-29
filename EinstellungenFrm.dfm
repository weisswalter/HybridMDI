object frmEinstellungen: TfrmEinstellungen
  Left = 0
  Top = 0
  Caption = 'Einstellungen'
  ClientHeight = 650
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  TextHeight = 15
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 650
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    Headers = <
      item
        Caption = 'Personentyp'
        Width = 115
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlPersonentyp
      end
      item
        Caption = 'Rollentyp'
        Width = 100
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlRollentyp
      end
      item
        Caption = 'Adressentyp'
        Width = 115
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlAdressentyp
      end
      item
        Caption = 'Emailtyp'
        Width = 95
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlEmailtyp
      end
      item
        Caption = 'Telefonnummertyp'
        Width = 160
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlTelefonnummertyp
      end
      item
        Caption = 'Rechnungstyp'
        Width = 125
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlRechnungstyp
      end
      item
        Caption = 'Lead-Quelle'
        Width = 115
        Actions = ActionListEdit
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end>
        ContentPanel = pnlLeadquellentyp
      end>
    Align = alClient
    TabOrder = 0
  end
  object pnlPersonentyp: TPanel
    Left = 8
    Top = 680
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlPersonentyp'
    ShowCaption = False
    TabOrder = 1
    Visible = False
    object dbgrdPersonentyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblPersonentyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlRollentyp: TPanel
    Left = 8
    Top = 1000
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlRollentyp'
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object dbgrdRollentyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblRollentyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlAdressentyp: TPanel
    Left = 8
    Top = 1320
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlAdressentyp'
    ShowCaption = False
    TabOrder = 3
    Visible = False
    object dbgrdAdressentyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblAdressentyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlEmailtyp: TPanel
    Left = 8
    Top = 1640
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlEmailtyp'
    ShowCaption = False
    TabOrder = 4
    Visible = False
    object dbgrdEmailtyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblEmailtyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlTelefonnummertyp: TPanel
    Left = 8
    Top = 1960
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlTelefonnummertyp'
    ShowCaption = False
    TabOrder = 5
    Visible = False
    object dbgrdTelefonnummertyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblTelefonnummertyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlRechnungstyp: TPanel
    Left = 8
    Top = 2280
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlRechnungstyp'
    ShowCaption = False
    TabOrder = 6
    Visible = False
    object dbgrdRechnungstyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblRechnungstyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlLeadquellentyp: TPanel
    Left = 8
    Top = 2600
    Width = 400
    Height = 300
    BevelOuter = bvNone
    Caption = 'pnlLeadquellentyp'
    ShowCaption = False
    TabOrder = 7
    Visible = False
    object dbgrdLeadquellentyp: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 300
      Align = alClient
      DataSource = dmEinstellungen.dstblLeadquellentyp
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 720
    Top = 552
  end
  object ActionListEdit: TActionList
    Left = 800
    Top = 552
    object actNeu: TAction
      Caption = 'Neu'
      OnExecute = btnNeuClick
    end
    object actSpeichern: TAction
      Caption = 'Speichern'
      OnExecute = btnSpeichernClick
    end
    object actAbbrechen: TAction
      Caption = 'Abbrechen'
      OnExecute = btnAbbrechenClick
    end
  end
end
