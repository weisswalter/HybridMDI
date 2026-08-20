inherited frmGuiTemplate: TfrmGuiTemplate
  Caption = 'GUI-Vorlage'
  ClientHeight = 600
  ClientWidth = 1080
  FormStyle = fsMDIChild
  Visible = True
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 1096
  ExplicitHeight = 639
  TextHeight = 15
  object Splitter1: TSplitter [0]
    Left = 313
    Top = 0
    Width = 5
    Height = 600
    ExplicitLeft = 470
  end
  object pnlStamm: TPanel [1]
    Left = 0
    Top = 0
    Width = 313
    Height = 600
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    ExplicitHeight = 592
    object pnlStammFelder: TPanel
      Left = 0
      Top = 0
      Width = 313
      Height = 600
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      ExplicitHeight = 592
      object rbtnbleft: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 313
        Height = 48
        Align = alTop
        BevelOuter = bvNone
        Caption = 'rbtnbleft'
        ShowCaption = False
        TabOrder = 0
        Gradient.Left = 0
        Gradient.Top = 0
        Gradient.Width = 313
        Gradient.Height = 48
        Gradient.Style = grVertical
        Gradient.StartColor = 16245453
        Gradient.EndColor = 15966336
        Gradient.ExplicitWidth = 0
        Gradient.ExplicitHeight = 0
        Buttons = <
          item
            Action = actErsterL
          end
          item
            Action = actZurueckL
          end
          item
            Action = actWeiterL
          end
          item
            Action = actLetzterL
          end
          item
            Action = actNeuL
          end
          item
            Action = actAendernL
          end
          item
            Action = actSpeichernL
          end
          item
            Action = actAbbrechenL
          end
          item
            Action = actNeuLadenL
          end>
      end
    end
  end
  object rbnpnl1: TRibbonPanel [2]
    Left = 318
    Top = 0
    Width = 762
    Height = 600
    Align = alClient
    BevelOuter = bvNone
    Caption = 'rbnpnl1'
    ShowCaption = False
    TabOrder = 1
    TopPanel.Left = 0
    TopPanel.Top = 0
    TopPanel.Width = 762
    TopPanel.Height = 31
    TopPanel.Align = alTop
    TopPanel.BevelOuter = bvNone
    TopPanel.Caption = 'TopPanel'
    TopPanel.ShowCaption = False
    TopPanel.TabOrder = 1
    TopPanel.ExplicitWidth = 728
    PageControl.Left = -1
    PageControl.Top = 29
    PageControl.Width = 758
    PageControl.Height = 572
    PageControl.Anchors = [akLeft, akTop, akRight, akBottom]
    PageControl.TabOrder = 0
    PageControl.ExplicitWidth = 724
    PageControl.ExplicitHeight = 564
    HeaderButtons = <>
    ExplicitWidth = 728
    ExplicitHeight = 592
    DesignSize = (
      762
      600)
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
  object ActionListRechts1: TActionList
    Tag = 1
    Left = 288
    Top = 552
    object actErsterR1: TAction
      Caption = 'Erster'
      OnExecute = ActionRechtsExecute
    end
    object actZurueckR1: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = ActionRechtsExecute
    end
    object actWeiterR1: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = ActionRechtsExecute
    end
    object actLetzterR1: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = ActionRechtsExecute
    end
    object actNeuR1: TAction
      Tag = 4
      Caption = 'Neu'
      OnExecute = ActionRechtsExecute
    end
    object actAendernR1: TAction
      Tag = 5
      Caption = #196'ndern'
      OnExecute = ActionRechtsExecute
    end
    object actSpeichernR1: TAction
      Tag = 6
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR1: TAction
      Tag = 7
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
    object actNeuLadenR1: TAction
      Tag = 8
      Caption = 'Neu laden'
      OnExecute = ActionRechtsExecute
    end
  end
  object ActionListRechts2: TActionList
    Tag = 2
    Left = 376
    Top = 544
    object actErsterR2: TAction
      Caption = 'Erster'
      OnExecute = ActionRechtsExecute
    end
    object actZurueckR2: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = ActionRechtsExecute
    end
    object actWeiterR2: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = ActionRechtsExecute
    end
    object actLetzterR2: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = ActionRechtsExecute
    end
    object actNeuR2: TAction
      Tag = 4
      Caption = 'Neu'
      OnExecute = ActionRechtsExecute
    end
    object actAendernR2: TAction
      Tag = 5
      Caption = #196'ndern'
      OnExecute = ActionRechtsExecute
    end
    object actSpeichernR2: TAction
      Tag = 6
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR2: TAction
      Tag = 7
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
    object actNeuLadenR2: TAction
      Tag = 8
      Caption = 'Neu laden'
      OnExecute = ActionRechtsExecute
    end
  end
  object ActionListRechts3: TActionList
    Tag = 3
    Left = 472
    Top = 544
    object actErsterR3: TAction
      Caption = 'Erster'
      OnExecute = ActionRechtsExecute
    end
    object actZurueckR3: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = ActionRechtsExecute
    end
    object actWeiterR3: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = ActionRechtsExecute
    end
    object actLetzterR3: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = ActionRechtsExecute
    end
    object actNeuR3: TAction
      Tag = 4
      Caption = 'Neu'
      OnExecute = ActionRechtsExecute
    end
    object actAendernR3: TAction
      Tag = 5
      Caption = #196'ndern'
      OnExecute = ActionRechtsExecute
    end
    object actSpeichernR3: TAction
      Tag = 6
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR3: TAction
      Tag = 7
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
    object actNeuLadenR3: TAction
      Tag = 8
      Caption = 'Neu laden'
      OnExecute = ActionRechtsExecute
    end
  end
end
