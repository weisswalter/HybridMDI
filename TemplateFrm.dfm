object frmVorlage: TfrmVorlage
  Left = 0
  Top = 0
  Caption = 'Vorlage'
  ClientHeight = 600
  ClientWidth = 900
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
  object pnlStamm: TPanel
    Left = 0
    Top = 0
    Width = 470
    Height = 600
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object pnlStammButtons: TPanel
      Left = 0
      Top = 0
      Width = 470
      Height = 38
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object btnErsterStamm: TJvNavPanelButtonTop
        Left = 0
        Top = 0
        Width = 40
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actErsterL
      end
      object btnZurueckStamm: TJvNavPanelButtonTop
        Left = 40
        Top = 0
        Width = 48
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actZurueckL
      end
      object btnWeiterStamm: TJvNavPanelButtonTop
        Left = 88
        Top = 0
        Width = 50
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actWeiterL
      end
      object btnLetzterStamm: TJvNavPanelButtonTop
        Left = 138
        Top = 0
        Width = 50
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actLetzterL
      end
      object btnNeuStamm: TJvNavPanelButtonTop
        Left = 188
        Top = 0
        Width = 31
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actNeuL
      end
      object btnAendernStamm: TJvNavPanelButtonTop
        Left = 219
        Top = 0
        Width = 50
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actAendernL
      end
      object btnSpeichernStamm: TJvNavPanelButtonTop
        Left = 269
        Top = 0
        Width = 64
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actSpeichernL
      end
      object btnAbbrechenStamm: TJvNavPanelButtonTop
        Left = 333
        Top = 0
        Width = 61
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actAbbrechenL
      end
      object btnNeuLadenStamm: TJvNavPanelButtonTop
        Left = 394
        Top = 0
        Width = 61
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        Action = actNeuLadenL
      end
    end
    object pnlStammFelder: TPanel
      Left = 0
      Top = 38
      Width = 470
      Height = 562
      Align = alClient
      BevelOuter = bvNone
      Caption = 'TODO: Stammdaten-Felder'
      ShowCaption = True
      TabOrder = 1
    end
  end
  object Splitter1: TSplitter
    Left = 470
    Top = 0
    Width = 5
    Height = 600
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 475
    Top = 0
    Width = 425
    Height = 600
    Align = alClient
    TabOrder = 1
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    Headers = <
      item
        Caption = 'Reiter 1'
        Actions = ActionListRechts
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
          end
          item
            Action = actWeiterR
          end
          item
            Action = actLetzterR
          end
          item
            Action = actNeuR
          end
          item
            Action = actAendernR
          end
          item
            Action = actSpeichernR
          end
          item
            Action = actAbbrechenR
          end
          item
            Action = actNeuLadenR
          end>
      end>
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 48
    Top = 552
  end
  object PaneStyle2: TJvNavPaneStyleManager
    Theme = nptXPSilver
    Left = 128
    Top = 552
  end
  object ActionListLinks: TActionList
    Left = 208
    Top = 552
    object actErsterL: TAction
      Tag = 0
      Caption = 'Erster'
      OnExecute = ActionLinksExecute
    end
    object actZurueckL: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = ActionLinksExecute
    end
    object actWeiterL: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = ActionLinksExecute
    end
    object actLetzterL: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = ActionLinksExecute
    end
    object actNeuL: TAction
      Tag = 4
      Caption = 'Neu'
      OnExecute = ActionLinksExecute
    end
    object actAendernL: TAction
      Tag = 5
      Caption = #196'ndern'
      OnExecute = ActionLinksExecute
    end
    object actSpeichernL: TAction
      Tag = 6
      Caption = 'Speichern'
      OnExecute = ActionLinksExecute
    end
    object actAbbrechenL: TAction
      Tag = 7
      Caption = 'Abbrechen'
      OnExecute = ActionLinksExecute
    end
    object actNeuLadenL: TAction
      Tag = 8
      Caption = 'Neu laden'
      OnExecute = ActionLinksExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 288
    Top = 552
    object actErsterR: TAction
      Tag = 0
      Caption = 'Erster'
      OnExecute = ActionRechtsExecute
    end
    object actZurueckR: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = ActionRechtsExecute
    end
    object actWeiterR: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = ActionRechtsExecute
    end
    object actLetzterR: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = ActionRechtsExecute
    end
    object actNeuR: TAction
      Tag = 4
      Caption = 'Neu'
      OnExecute = ActionRechtsExecute
    end
    object actAendernR: TAction
      Tag = 5
      Caption = #196'ndern'
      OnExecute = ActionRechtsExecute
    end
    object actSpeichernR: TAction
      Tag = 6
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR: TAction
      Tag = 7
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
    object actNeuLadenR: TAction
      Tag = 8
      Caption = 'Neu laden'
      OnExecute = ActionRechtsExecute
    end
  end
end
