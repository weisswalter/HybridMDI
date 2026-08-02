object frmKalkulation: TfrmKalkulation
  Left = 0
  Top = 0
  Caption = 'Kalkulation'
  ClientHeight = 700
  ClientWidth = 1250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1250
    Height = 74
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblBez: TLabel
      Left = 8
      Top = 5
      Width = 66
      Height = 15
      Caption = 'Bezeichnung'
    end
    object lblJahr: TLabel
      Left = 250
      Top = 5
      Width = 24
      Height = 15
      Caption = 'Jahr'
    end
    object lblMenge: TLabel
      Left = 320
      Top = 5
      Width = 66
      Height = 15
      Caption = 'Menge / Los'
    end
    object lblArtikel: TLabel
      Left = 400
      Top = 5
      Width = 108
      Height = 15
      Caption = 'Artikel (optional)'
    end
    object edtBez: TEdit
      Left = 8
      Top = 24
      Width = 230
      Height = 23
      TabOrder = 0
    end
    object edtJahr: TEdit
      Left = 250
      Top = 24
      Width = 60
      Height = 23
      TabOrder = 1
      Text = '2026'
    end
    object edtMenge: TEdit
      Left = 320
      Top = 24
      Width = 70
      Height = 23
      TabOrder = 2
      Text = '1'
    end
    object cboArtikel: TDBLookupComboBox
      Left = 400
      Top = 24
      Width = 240
      Height = 23
      KeyField = 'artikel_id'
      ListField = 'anzeige'
      ListSource = dmKalkulation.dsArtikel
      TabOrder = 3
    end
    object btnNeu: TJvNavPanelButtonTop
      Left = 656
      Top = 2
      Width = 90
      Height = 69
      Action = actNeu
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnRechnen: TJvNavPanelButtonTop
      Left = 750
      Top = 2
      Width = 90
      Height = 69
      Action = actRechnen
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnMaterial: TJvNavPanelButtonTop
      Left = 844
      Top = 2
      Width = 100
      Height = 69
      Action = actMaterial
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnFreigeben: TJvNavPanelButtonTop
      Left = 948
      Top = 2
      Width = 90
      Height = 69
      Action = actFreigeben
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnLoeschen: TJvNavPanelButtonTop
      Left = 1042
      Top = 2
      Width = 90
      Height = 69
      Action = actLoeschen
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnNeuLaden: TJvNavPanelButtonTop
      Left = 1136
      Top = 2
      Width = 90
      Height = 69
      Action = actNeuLaden
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 74
    Width = 620
    Height = 626
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object lblSummen: TLabel
      Left = 0
      Top = 590
      Width = 620
      Height = 36
      Align = alBottom
      AutoSize = False
      Caption = ' '
      WordWrap = True
    end
    object dbgrdKalkulation: TDBGrid
      Left = 0
      Top = 0
      Width = 620
      Height = 590
      Align = alClient
      DataSource = dmKalkulation.dsKalkulation
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdKalkulationCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 620
    Top = 74
    Width = 5
    Height = 626
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 625
    Top = 74
    Width = 625
    Height = 626
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object tsPositionen: TTabSheet
      Caption = 'Positionen'
      object barPositionen: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 625
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeuR
            Width = 70
          end
          item
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end
          item
            Action = actLoeschenR
            Width = 75
          end>
      end
      object pnlPositionen: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlPosHinweis: TPanel
          Left = 0
          Top = 0
          Width = 625
          Height = 62
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblPosHinweis: TLabel
            Left = 4
            Top = 2
            Width = 617
            Height = 58
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdPositionen: TDBGrid
          Left = 0
          Top = 62
          Width = 625
          Height = 494
          Align = alClient
          DataSource = dmKalkulation.dsPosition
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsBlatt: TTabSheet
      Caption = 'Blatt'
      object barBlatt: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 625
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <>
      end
      object pnlBlatt: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object dbgrdBlatt: TDBGrid
          Left = 0
          Top = 0
          Width = 625
          Height = 556
          Align = alClient
          DataSource = dmKalkulation.dsBlatt
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsZuschlaege: TTabSheet
      Caption = 'Zuschl'#228'ge'
      object barZuschlaege: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 625
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeuR
            Width = 70
          end
          item
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end
          item
            Action = actLoeschenR
            Width = 75
          end>
      end
      object pnlZuschlaege: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlZuschlagHinweis: TPanel
          Left = 0
          Top = 0
          Width = 625
          Height = 62
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblZuschlagHinweis: TLabel
            Left = 4
            Top = 2
            Width = 617
            Height = 58
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdZuschlag: TDBGrid
          Left = 0
          Top = 62
          Width = 625
          Height = 494
          Align = alClient
          DataSource = dmKalkulation.dsZuschlag
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsKostenarten: TTabSheet
      Caption = 'Kostenarten'
      object barKostenarten: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 625
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeuR
            Width = 70
          end
          item
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end
          item
            Action = actLoeschenR
            Width = 75
          end>
      end
      object pnlKostenarten: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlKostenartUnten: TPanel
          Left = 0
          Top = 466
          Width = 625
          Height = 90
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblKaKonto: TLabel
            Left = 4
            Top = 4
            Width = 120
            Height = 15
            Caption = 'Konto dieser Kostenart'
          end
          object lblKaHinweis: TLabel
            Left = 4
            Top = 52
            Width = 617
            Height = 36
            AutoSize = False
            WordWrap = True
          end
          object cboKaKonto: TDBLookupComboBox
            Left = 4
            Top = 24
            Width = 400
            Height = 23
            DataField = 'konto_id'
            DataSource = dmKalkulation.dsKostenart
            KeyField = 'konto_id'
            ListField = 'anzeige'
            ListSource = dmKalkulation.dsKontoLookup
            TabOrder = 0
          end
        end
        object dbgrdKostenart: TDBGrid
          Left = 0
          Top = 0
          Width = 625
          Height = 466
          Align = alClient
          DataSource = dmKalkulation.dsKostenart
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsKostenstellen: TTabSheet
      Caption = 'Kostenstellen'
      object barKostenstellen: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 625
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeuR
            Width = 70
          end
          item
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end
          item
            Action = actLoeschenR
            Width = 75
          end>
      end
      object pnlKostenstellen: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlKostenstelleHinweis: TPanel
          Left = 0
          Top = 0
          Width = 625
          Height = 52
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblKsHinweis: TLabel
            Left = 4
            Top = 2
            Width = 617
            Height = 48
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdKostenstelle: TDBGrid
          Left = 0
          Top = 52
          Width = 625
          Height = 504
          Align = alClient
          DataSource = dmKalkulation.dsKostenstelle
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsKonten: TTabSheet
      Caption = 'Konten'
      object barKonten: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 625
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeuR
            Width = 70
          end
          item
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end
          item
            Action = actLoeschenR
            Width = 75
          end>
      end
      object pnlKonten: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlKontoHinweis: TPanel
          Left = 0
          Top = 0
          Width = 625
          Height = 52
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblKontoHinweis: TLabel
            Left = 4
            Top = 2
            Width = 617
            Height = 48
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdKonto: TDBGrid
          Left = 0
          Top = 52
          Width = 625
          Height = 504
          Align = alClient
          DataSource = dmKalkulation.dsKonto
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 1
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
    Theme = nptStandard
    Colors.ButtonColorFrom = 16247513
    Colors.ButtonColorTo = 16050326
    Colors.ButtonSelectedColorFrom = 12189695
    Colors.ButtonSelectedColorTo = 4633855
    Colors.ButtonHotColorFrom = 15660791
    Colors.ButtonHotColorTo = 12313087
    Colors.FrameColor = 6045981
    Colors.HeaderColorFrom = 16245453
    Colors.HeaderColorTo = 15966336
    Left = 1000
    Top = 120
  end
  object ActionListEdit: TActionList
    Left = 1000
    Top = 180
    object actNeu: TAction
      Caption = 'Neu anlegen'
      Hint = 'Neue Kalkulation mit den Zuschlagss'#228'tzen des Jahres'
      OnExecute = actNeuExecute
    end
    object actRechnen: TAction
      Caption = 'Rechnen'
      OnExecute = actRechnenExecute
    end
    object actMaterial: TAction
      Caption = 'Material'
      Hint = 'Material aus der St'#252'ckliste des Artikels '#252'bernehmen'
      OnExecute = actMaterialExecute
    end
    object actFreigeben: TAction
      Caption = 'Freigeben'
      OnExecute = actFreigebenExecute
    end
    object actLoeschen: TAction
      Caption = 'L'#246'schen'
      OnExecute = actLoeschenExecute
    end
    object actNeuLaden: TAction
      Caption = 'Neu laden'
      OnExecute = actNeuLadenExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 1000
    Top = 240
    object actNeuR: TAction
      Tag = 0
      Caption = 'Neu'
      OnExecute = ActionRechtsExecute
    end
    object actAendernR: TAction
      Tag = 1
      Caption = #196'ndern'
      OnExecute = ActionRechtsExecute
    end
    object actSpeichernR: TAction
      Tag = 2
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR: TAction
      Tag = 3
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
    object actLoeschenR: TAction
      Tag = 4
      Caption = 'L'#246'schen'
      OnExecute = ActionRechtsExecute
    end
  end
end
