object frmKursAnwesenheit: TfrmKursAnwesenheit
  Left = 0
  Top = 0
  Caption = 'Kurs-Anwesenheit'
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
    object lblVon: TLabel
      Left = 8
      Top = 5
      Width = 20
      Height = 15
      Caption = 'Von'
    end
    object lblBis: TLabel
      Left = 130
      Top = 5
      Width = 15
      Height = 15
      Caption = 'Bis'
    end
    object edtVon: TDateTimePicker
      Left = 8
      Top = 24
      Width = 110
      Height = 23
      Date = 46235.000000000000000000
      Time = 0.000000000000000000
      TabOrder = 0
    end
    object edtBis: TDateTimePicker
      Left = 130
      Top = 24
      Width = 110
      Height = 23
      Date = 46235.000000000000000000
      Time = 0.000000000000000000
      TabOrder = 1
    end
    object lblCoach: TLabel
      Left = 256
      Top = 5
      Width = 36
      Height = 15
      Caption = 'Coach'
    end
    object cboCoach: TDBLookupComboBox
      Left = 256
      Top = 24
      Width = 200
      Height = 23
      KeyField = 'person_id'
      ListField = 'name'
      ListSource = dmKursAnwesenheit.dsCoach
      TabOrder = 2
      OnCloseUp = cboCoachCloseUp
    end
    object btnAlleCoaches: TButton
      Left = 462
      Top = 24
      Width = 80
      Height = 23
      Caption = 'Alle Coaches'
      TabOrder = 3
      OnClick = btnAlleCoachesClick
    end
    object btnLaden: TJvNavPanelButtonTop
      Left = 560
      Top = 2
      Width = 90
      Height = 69
      Action = actLaden
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
    object btnListeErzeugen: TJvNavPanelButtonTop
      Left = 654
      Top = 2
      Width = 110
      Height = 69
      Action = actListeErzeugen
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
    object btnAlleAnwesend: TJvNavPanelButtonTop
      Left = 768
      Top = 2
      Width = 110
      Height = 69
      Action = actAlleAnwesend
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
    object btnAbschliessen: TJvNavPanelButtonTop
      Left = 882
      Top = 2
      Width = 130
      Height = 69
      Action = actAbschliessen
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
    Width = 660
    Height = 626
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object lblStand: TLabel
      Left = 0
      Top = 608
      Width = 660
      Height = 18
      Align = alBottom
      AutoSize = False
      Caption = ' '
      Layout = tlCenter
    end
    object dbgrdTermine: TDBGrid
      Left = 0
      Top = 0
      Width = 660
      Height = 608
      Align = alClient
      DataSource = dmKursAnwesenheit.dsTermine
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdTermineCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 660
    Top = 74
    Width = 5
    Height = 626
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 665
    Top = 74
    Width = 535
    Height = 626
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object tsTeilnehmer: TTabSheet
      Caption = 'Teilnehmer'
      object barTeilnehmer: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 535
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actSpeichernR
            Width = 90
          end
          item
            Action = actAbbrechenR
            Width = 90
          end>
      end
      object pnlTeilnehmer: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlHinweis: TPanel
          Left = 0
          Top = 0
          Width = 535
          Height = 76
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblHinweis: TLabel
            Left = 4
            Top = 2
            Width = 527
            Height = 72
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdTeilnehmer: TDBGrid
          Left = 0
          Top = 76
          Width = 535
          Height = 480
          Align = alClient
          DataSource = dmKursAnwesenheit.dsAnwesenheit
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit]
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
    object actLaden: TAction
      Caption = 'Laden'
      Hint = 'Termine im gew'#228'hlten Zeitraum laden'
      OnExecute = actLadenExecute
    end
    object actListeErzeugen: TAction
      Caption = 'Liste erzeugen'
      Hint = 'Angemeldete Teilnehmer der Durchf'#252'hrung erg'#228'nzen'
      OnExecute = actListeErzeugenExecute
    end
    object actAlleAnwesend: TAction
      Caption = 'Alle anwesend'
      OnExecute = actAlleAnwesendExecute
    end
    object actAbschliessen: TAction
      Caption = 'Stattgefunden'
      Hint = 'Termin als stattgefunden kennzeichnen (z'#228'hlt f'#252'r die Honorarabrechnung)'
      OnExecute = actAbschliessenExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 960
    Top = 240
    object actSpeichernR: TAction
      Tag = 0
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR: TAction
      Tag = 1
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
  end
end
