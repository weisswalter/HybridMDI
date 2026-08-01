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
  object JvRibbonPanel1: TRibbonPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 650
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    HeaderButtons = <
      item
        Caption = 'Personentyp'
        Width = 115
      end
      item
        Caption = 'Rollentyp'
        Width = 100
      end
      item
        Caption = 'Adressentyp'
        Width = 115
      end
      item
        Caption = 'Emailtyp'
        Width = 95
      end
      item
        Caption = 'Telefonnummertyp'
        Width = 160
      end
      item
        Caption = 'Rechnungstyp'
        Width = 125
      end
      item
        Caption = 'Lead-Quelle'
        Width = 115
      end>
    object tsPersonentyp: TTabSheet
      Caption = 'Personentyp'
      object barPersonentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlPersonentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlPersonentyp'
        ShowCaption = False
        TabOrder = 1
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
    end
    object tsRollentyp: TTabSheet
      Caption = 'Rollentyp'
      object barRollentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlRollentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlRollentyp'
        ShowCaption = False
        TabOrder = 2
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
    end
    object tsAdressentyp: TTabSheet
      Caption = 'Adressentyp'
      object barAdressentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlAdressentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlAdressentyp'
        ShowCaption = False
        TabOrder = 3
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
    end
    object tsEmailtyp: TTabSheet
      Caption = 'Emailtyp'
      object barEmailtyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlEmailtyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlEmailtyp'
        ShowCaption = False
        TabOrder = 4
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
    end
    object tsTelefonnummertyp: TTabSheet
      Caption = 'Telefonnummertyp'
      object barTelefonnummertyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlTelefonnummertyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlTelefonnummertyp'
        ShowCaption = False
        TabOrder = 5
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
    end
    object tsRechnungstyp: TTabSheet
      Caption = 'Rechnungstyp'
      object barRechnungstyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlRechnungstyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlRechnungstyp'
        ShowCaption = False
        TabOrder = 6
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
    end
    object tsLeadquellentyp: TTabSheet
      Caption = 'Lead-Quelle'
      object barLeadquellentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      end
      object pnlLeadquellentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlLeadquellentyp'
        ShowCaption = False
        TabOrder = 7
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
