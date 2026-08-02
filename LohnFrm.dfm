object frmLohn: TfrmLohn
  Left = 0
  Top = 0
  Caption = 'L'#246'hne'
  ClientHeight = 700
  ClientWidth = 1200
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
    Width = 1200
    Height = 74
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblJahr: TLabel
      Left = 8
      Top = 5
      Width = 24
      Height = 15
      Caption = 'Jahr'
    end
    object lblMonat: TLabel
      Left = 88
      Top = 5
      Width = 36
      Height = 15
      Caption = 'Monat'
    end
    object edtJahr: TEdit
      Left = 8
      Top = 24
      Width = 70
      Height = 23
      TabOrder = 0
      Text = '2026'
    end
    object cboMonat: TComboBox
      Left = 88
      Top = 24
      Width = 130
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      Items.Strings = (
        'Januar'
        'Februar'
        'M'#228'rz'
        'April'
        'Mai'
        'Juni'
        'Juli'
        'August'
        'September'
        'Oktober'
        'November'
        'Dezember')
    end
    object btnLohnlauf: TJvNavPanelButtonTop
      Left = 236
      Top = 2
      Width = 100
      Height = 69
      Action = actLohnlauf
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
    object btnLohnlaufPerson: TJvNavPanelButtonTop
      Left = 340
      Top = 2
      Width = 100
      Height = 69
      Action = actLohnlaufPerson
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
      Left = 444
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
    object btnFreigeben: TJvNavPanelButtonTop
      Left = 538
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
    object btnAusbezahlt: TJvNavPanelButtonTop
      Left = 632
      Top = 2
      Width = 90
      Height = 69
      Action = actAusbezahlt
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
      Left = 726
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
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 74
    Width = 700
    Height = 626
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object splLeft: TSplitter
      Left = 0
      Top = 200
      Width = 700
      Height = 5
      Cursor = crVSplit
      Align = alTop
    end
    object lblSummen: TLabel
      Left = 0
      Top = 608
      Width = 700
      Height = 18
      Align = alBottom
      AutoSize = False
      Caption = ' '
      Layout = tlCenter
    end
    object dbgrdPersonen: TDBGrid
      Left = 0
      Top = 0
      Width = 700
      Height = 200
      Align = alTop
      DataSource = dmLohn.dsPersonen
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdPersonenCellClick
    end
    object dbgrdPerioden: TDBGrid
      Left = 0
      Top = 205
      Width = 700
      Height = 403
      Align = alClient
      DataSource = dmLohn.dsPerioden
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick]
      ReadOnly = True
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdPeriodenCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 700
    Top = 74
    Width = 5
    Height = 626
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 705
    Top = 74
    Width = 495
    Height = 626
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object tsAbrechnung: TTabSheet
      Caption = 'Abrechnung'
      object barAbrechnung: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <>
      end
      object pnlAbrechnung: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlBeleg: TPanel
          Left = 0
          Top = 0
          Width = 495
          Height = 56
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblBeleg: TLabel
            Left = 4
            Top = 2
            Width = 487
            Height = 52
            AutoSize = False
            Caption = 'Keine Abrechnung gew'#228'hlt.'
            WordWrap = True
          end
        end
        object dbgrdPositionen: TDBGrid
          Left = 0
          Top = 56
          Width = 495
          Height = 500
          Align = alClient
          DataSource = dmLohn.dsPositionen
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
          ReadOnly = True
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsVereinbarung: TTabSheet
      Caption = 'Vereinbarung'
      object barVereinbarung: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
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
      object pnlVereinbarung: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlLohnHinweis: TPanel
          Left = 0
          Top = 0
          Width = 495
          Height = 62
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblLohnHinweis: TLabel
            Left = 4
            Top = 2
            Width = 487
            Height = 58
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdLohn: TDBGrid
          Left = 0
          Top = 62
          Width = 495
          Height = 494
          Align = alClient
          DataSource = dmLohn.dsLohn
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
    object tsZulagen: TTabSheet
      Caption = 'Zulagen'
      object barZulagen: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
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
      object pnlZulagen: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlZulageHinweis: TPanel
          Left = 0
          Top = 0
          Width = 495
          Height = 48
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblZulageHinweis: TLabel
            Left = 4
            Top = 2
            Width = 487
            Height = 44
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdZulage: TDBGrid
          Left = 0
          Top = 48
          Width = 495
          Height = 508
          Align = alClient
          DataSource = dmLohn.dsZulage
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
    object tsAbzuege: TTabSheet
      Caption = 'Abz'#252'ge'
      object barAbzuege: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
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
      object pnlAbzuege: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlAbzugHinweis: TPanel
          Left = 0
          Top = 0
          Width = 495
          Height = 62
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblAbzugHinweis: TLabel
            Left = 4
            Top = 2
            Width = 487
            Height = 58
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdAbzug: TDBGrid
          Left = 0
          Top = 62
          Width = 495
          Height = 494
          Align = alClient
          DataSource = dmLohn.dsAbzug
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
    Left = 960
    Top = 120
  end
  object ActionListEdit: TActionList
    Left = 960
    Top = 180
    object actLohnlauf: TAction
      Caption = 'Lohnlauf'
      Hint = 'Alle Personen des Mandanten f'#252'r den gew'#228'hlten Monat berechnen'
      OnExecute = actLohnlaufExecute
    end
    object actLohnlaufPerson: TAction
      Caption = 'Nur Person'
      Hint = 'Nur die links gew'#228'hlte Person berechnen'
      OnExecute = actLohnlaufPersonExecute
    end
    object actNeuLaden: TAction
      Caption = 'Neu laden'
      OnExecute = actNeuLadenExecute
    end
    object actFreigeben: TAction
      Caption = 'Freigeben'
      Hint = 'Beleg einfrieren - ein weiterer Lohnlauf '#228'ndert ihn nicht mehr'
      OnExecute = actFreigebenExecute
    end
    object actAusbezahlt: TAction
      Caption = 'Ausbezahlt'
      OnExecute = actAusbezahltExecute
    end
    object actLoeschen: TAction
      Caption = 'L'#246'schen'
      OnExecute = actLoeschenExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 960
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
