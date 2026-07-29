object frmGuiTemplate: TfrmGuiTemplate
  Left = 0
  Top = 0
  Caption = 'GUI-Vorlage'
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
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 470
    Top = 0
    Width = 5
    Height = 600
  end
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
        Width = 50
        Height = 38
        Action = actErsterL
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
      end
      object btnZurueckStamm: TJvNavPanelButtonTop
        Left = 50
        Top = 0
        Width = 60
        Height = 38
        Action = actZurueckL
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
      end
      object btnWeiterStamm: TJvNavPanelButtonTop
        Left = 110
        Top = 0
        Width = 52
        Height = 38
        Action = actWeiterL
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
      end
      object btnLetzterStamm: TJvNavPanelButtonTop
        Left = 162
        Top = 0
        Width = 60
        Height = 38
        Action = actLetzterL
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
      end
      object btnNeuStamm: TJvNavPanelButtonTop
        Left = 222
        Top = 0
        Width = 31
        Height = 38
        Action = actNeuL
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
      end
      object btnAendernStamm: TJvNavPanelButtonTop
        Left = 253
        Top = 0
        Width = 50
        Height = 38
        Action = actAendernL
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
      end
      object btnSpeichernStamm: TJvNavPanelButtonTop
        Left = 303
        Top = 0
        Width = 64
        Height = 38
        Action = actSpeichernL
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
      end
      object btnAbbrechenStamm: TJvNavPanelButtonTop
        Left = 367
        Top = 0
        Width = 61
        Height = 38
        Action = actAbbrechenL
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
      end
      object btnNeuLadenStamm: TJvNavPanelButtonTop
        Left = 428
        Top = 0
        Width = 61
        Height = 38
        Action = actNeuLadenL
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
      end
    end
    object pnlStammFelder: TPanel
      Left = 0
      Top = 38
      Width = 470
      Height = 562
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
    end
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
