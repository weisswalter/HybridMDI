object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Heisenberg'
  ClientHeight = 625
  ClientWidth = 1064
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIForm
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object sbrMain: TJvStatusBar
    Left = 0
    Top = 606
    Width = 1064
    Height = 19
    Panels = <
      item
        Text = 'Kein Mandant gew'#228'hlt'
        Width = 250
      end
      item
        Width = 500
      end>
    ExplicitTop = 598
    ExplicitWidth = 1062
    object prgLaden: TProgressBar
      Left = 260
      Top = 2
      Width = 380
      Height = 15
      TabOrder = 0
      Visible = False
    end
  end
  object pnlRibbon: TPanel
    Left = 0
    Top = 0
    Width = 1064
    Height = 104
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlRibbon'
    Color = 12232890
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    ExplicitWidth = 1062
    object pctrRibbon: TPageControl
      Left = 0
      Top = 0
      Width = 1064
      Height = 104
      ActivePage = tsStammdaten
      Align = alClient
      Style = tsFlatButtons
      TabOrder = 0
      ExplicitWidth = 1062
      object tsDatei: TTabSheet
        AlignWithMargins = True
        Margins.Left = 0
        Margins.Top = 25
        Margins.Right = 0
        Margins.Bottom = 0
        Caption = 'Datei'
        TabVisible = False
        object NavPBtnTopMandantNeu: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 140
          Height = 69
          Action = cmdMandantNeu
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
          ImageIndex = 1
          Images = ilstRibbonLI
        end
        object NavPBtnTopMandantWaehlen: TJvNavPanelButtonTop
          Left = 140
          Top = 0
          Width = 151
          Height = 69
          Action = cmdMandantWaehlen
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
          ImageIndex = 1
          Images = ilstRibbonLI
        end
        object NavPBtnTopAnwesenheit: TJvNavPanelButtonTop
          Left = 291
          Top = 0
          Width = 150
          Height = 69
          Action = cmdAnwesenheit
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
        object NavPBtnTopKursAnwesenheit: TJvNavPanelButtonTop
          Left = 441
          Top = 0
          Width = 170
          Height = 69
          Action = cmdKursAnwesenheit
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
      object tsStammdaten: TTabSheet
        AlignWithMargins = True
        Margins.Left = 0
        Margins.Top = 25
        Margins.Right = 0
        Margins.Bottom = 0
        Caption = 'tsStammdaten'
        ImageIndex = 1
        TabVisible = False
        object jvgrdnt1: TJvGradient
          Left = 1199
          Top = 0
          Width = 20
          Height = 69
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitLeft = 382
          ExplicitWidth = 680
        end
        object NavPBtnTopDok: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 102
          Height = 69
          Action = cmdPersonen
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
          ImageIndex = 6
          Images = ilstRibbonLI
          ExplicitLeft = -20
          ExplicitTop = 6
        end
        object NavPBtnTopKunde: TJvNavPanelButtonTop
          Left = 102
          Top = 0
          Width = 90
          Height = 69
          Action = cmdKunde
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
          Images = ilstRibbonLI
          ExplicitLeft = 466
        end
        object NavPBtnTopKlient: TJvNavPanelButtonTop
          Left = 192
          Top = 0
          Width = 90
          Height = 69
          Action = cmdKlient
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
          ImageIndex = 6
          Images = ilstRibbonLI
          ExplicitLeft = 556
        end
        object NavPBtnTopMitarbeiter: TJvNavPanelButtonTop
          Left = 282
          Top = 0
          Width = 90
          Height = 69
          Action = cmdMitarbeiter
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
          ImageIndex = 7
          Images = ilstRibbonLI
          ExplicitLeft = 946
        end
        object NavPBtnTopLehrer: TJvNavPanelButtonTop
          Left = 372
          Top = 0
          Width = 90
          Height = 69
          Action = cmdLehrer
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
          ImageIndex = 8
          Images = ilstRibbonLI
          ExplicitLeft = 1326
        end
        object NavPBtnTopLohn: TJvNavPanelButtonTop
          Left = 462
          Top = 0
          Width = 90
          Height = 69
          Action = cmdLohn
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
          ImageIndex = 9
          Images = ilstRibbonLI
          ExplicitLeft = 1126
        end
        object NavPBtnTopactCnPrefixWizard: TJvNavPanelButtonTop
          Left = 552
          Top = 0
          Width = 83
          Height = 69
          Action = cmdArtikel
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
          ImageIndex = 5
          Images = ilstRibbonLI
          ExplicitLeft = 392
          ExplicitTop = 3
        end
        object NavPBtnTopLager: TJvNavPanelButtonTop
          Left = 635
          Top = 0
          Width = 90
          Height = 69
          Action = cmdLager
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
          ImageIndex = 5
          Images = ilstRibbonLI
          ExplicitLeft = 376
        end
        object NavPBtnTopAnlagen: TJvNavPanelButtonTop
          Left = 725
          Top = 0
          Width = 90
          Height = 69
          Action = cmdAnlagen
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
          ExplicitLeft = 1216
        end
        object JvNavPanelButtonTop1: TJvNavPanelButtonTop
          Left = 815
          Top = 0
          Width = 102
          Height = 69
          Action = cmdDokumente
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
          ImageIndex = 2
          Images = ilstRibbonLI
          ExplicitLeft = 319
        end
        object btnWebEditor: TJvNavPanelButtonTop
          Left = 917
          Top = 0
          Width = 102
          Height = 69
          Action = cmdWebEditor
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
          ImageIndex = 2
          Images = ilstRibbonLI
          ExplicitLeft = 376
        end
        object NavPBtnTopKurs: TJvNavPanelButtonTop
          Left = 1019
          Top = 0
          Width = 90
          Height = 69
          Action = cmdKurs
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
          ExplicitLeft = 1126
        end
        object NavPBtnTopFeedback: TJvNavPanelButtonTop
          Left = 1109
          Top = 0
          Width = 90
          Height = 69
          Action = cmdFeedback
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
          ExplicitLeft = 1396
        end
        object jvgrdnt2: TJvGradient
          Left = 1199
          Top = 0
          Width = 445
          Height = 69
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitLeft = 376
        end
      end
      object tsWerkzeuge: TTabSheet
        AlignWithMargins = True
        Margins.Left = 0
        Margins.Top = 25
        Margins.Right = 0
        Margins.Bottom = 0
        Caption = 'tsWerkzeuge'
        ImageIndex = 2
        TabVisible = False
        object NavPBtnTopScanner: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 100
          Height = 69
          Action = cmdScanner
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
          ImageIndex = 4
          Images = ilstRibbonLI
        end
        object NavPBtnTopPGManager: TJvNavPanelButtonTop
          Left = 100
          Top = 0
          Width = 112
          Height = 69
          Action = cmdPGManager
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
          ImageIndex = 5
          Images = ilstRibbonLI
        end
        object NavPBtnTopEinstellungen: TJvNavPanelButtonTop
          Left = 212
          Top = 0
          Width = 100
          Height = 69
          Action = cmdEinstellungen
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
        object NavPBtnTopBenutzer: TJvNavPanelButtonTop
          Left = 312
          Top = 0
          Width = 130
          Height = 69
          Action = cmdBenutzer
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
        object jvgrdnt3: TJvGradient
          Left = 442
          Top = 0
          Width = 614
          Height = 69
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitLeft = 376
        end
      end
      object tsBelege: TTabSheet
        AlignWithMargins = True
        Margins.Left = 0
        Margins.Top = 25
        Margins.Right = 0
        Margins.Bottom = 0
        Caption = 'tsBelege'
        ImageIndex = 3
        TabVisible = False
        object NavPBtnTopKundenBestellung: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 135
          Height = 69
          Action = cmdKundenBestellung
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
          ExplicitLeft = 646
        end
        object NavPBtnTopLieferantenBestellung: TJvNavPanelButtonTop
          Left = 135
          Top = 0
          Width = 145
          Height = 69
          Action = cmdLieferantenBestellung
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
          ExplicitLeft = 746
        end
        object NavPBtnTopLagerEntnahme: TJvNavPanelButtonTop
          Left = 280
          Top = 0
          Width = 145
          Height = 69
          Action = cmdLagerEntnahme
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
          ExplicitLeft = 846
        end
        object jvgrdnt4: TJvGradient
          Left = 425
          Top = 0
          Width = 631
          Height = 69
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitLeft = 376
        end
      end
      object tsVorgaenge: TTabSheet
        AlignWithMargins = True
        Margins.Left = 0
        Margins.Top = 25
        Margins.Right = 0
        Margins.Bottom = 0
        Caption = 'tsVorgaenge'
        ImageIndex = 4
        TabVisible = False
        object NavPBtnTopMail: TJvNavPanelButtonTop
          Left = 100
          Top = 0
          Width = 90
          Height = 69
          Action = cmdMail
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
          ExplicitLeft = 1036
        end
        object NavPBtnTopKalkulation: TJvNavPanelButtonTop
          Left = 190
          Top = 0
          Width = 115
          Height = 69
          Action = cmdKalkulation
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
          ExplicitLeft = 1306
        end
        object NavPBtnTopVorgang: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 100
          Height = 69
          Action = cmdVorgang
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
        object jvgrdnt5: TJvGradient
          Left = 305
          Top = 0
          Width = 751
          Height = 69
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitLeft = 376
        end
      end
    end
    object jvnvpnlhdr1: TJvNavPanelHeader
      Left = 4
      Top = 0
      Width = 94
      Height = 31
      Alignment = taCenter
      Caption = 'Datei'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ImageIndex = 0
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = jvnvpnlhdr1Click
    end
    object jvnvpnlhdr2: TJvNavPanelHeader
      Tag = 1
      Left = 98
      Top = 0
      Width = 134
      Height = 31
      Alignment = taCenter
      Caption = 'Stammdaten'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ImageIndex = 0
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = jvnvpnlhdr1Click
    end
    object jvnvpnlhdr3: TJvNavPanelHeader
      Tag = 2
      Left = 232
      Top = 0
      Width = 142
      Height = 31
      Alignment = taCenter
      Caption = 'Werkzeuge'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ImageIndex = 0
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = jvnvpnlhdr1Click
    end
    object jvnvpnlhdr4: TJvNavPanelHeader
      Tag = 3
      Left = 374
      Top = 0
      Width = 130
      Height = 31
      Alignment = taCenter
      Caption = 'Belege'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ImageIndex = 0
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = jvnvpnlhdr1Click
    end
    object jvnvpnlhdr5: TJvNavPanelHeader
      Tag = 4
      Left = 504
      Top = 0
      Width = 170
      Height = 31
      Alignment = taCenter
      Caption = 'Vorg'#228'nge'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ImageIndex = 0
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = jvnvpnlhdr1Click
    end
  end
  object ilstRibbonLI: TJvImageList
    Items = <>
    Height = 32
    Width = 32
    Left = 136
    Top = 280
    Bitmap = {
      494C01010A001800040020002000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000008000000060000000010020000000000000C0
      00000000000000000000000000000000000000000000FAFAF900FAFAF900FAFA
      F900FAFAF900FAFAF900FAF9F900FAF9F900FAF9F900FAF9F900FAF9F900FAFA
      F900FAFAF900FAF9F800FAF9F900FAF9FA00F9FAF900FAF9FA00F8FAF800FAF9
      F900FAFAF900FAFAF900FAFAF900FAF9F900FAFAF900F9FAF900FAFAF900FAF9
      F900FAFAF900FAFAF900F9FAF900FAFAF90000000000FAF9F900FAF9F900FAF8
      F900FAF8F900FAF9F900FAF9F800FAF8F800F9F9F800FAF8F800FBF9F900FAF9
      F900FAF9F900FAF9F900FAF9F900FAF8F900FAF9F900FAF8F900FAF9F900FAF8
      F900FAF9F90000000000FAF9F800FAF9F900FAF9F900FAF9F900FAF9F900FAF8
      F900FAF9F900FAF9F900FAF9F900FAF9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FBF9F900F9F9F900F9FA
      F900FAF9F900F9F9F900FBF9FA00F9FBF900FAF9F900F9FAF900F9F9F900F9F9
      F900F9F9F900F9F9F800F9F9F900FAF9FA00F9F9F900FAF8FA00F7FAF700FBF9
      FA00F9FAF800FBFAF900FAFAF900FAFAF900F9F9F900F9FAF900FBF9F900F9F9
      F900F9F9F900FBF9F900F8FAF900FAF9F900FBF9F900FAF9F800F9F9F700F9F9
      F700FBF7F800F8F9F600F9F8F700FAF8F700F8FAF700F9F9F700FCF8F900F9F9
      F700FAF9F800F9F8F800FAF9F900F9F8F800FAF7F700F9F8F600F9F8F800FAF8
      F700FAF9F700FAF9F800F9F9F600FAF9F800F9F9F700F9F9F700FAF8F900F9F9
      F700F9F9F700FAF7F700FAF9F800FAF9F6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F8FAF900FBF9FA00F9FAF900F7FB
      F800F9F9F900F9F9F900FAF9F900F9FAF900F9F9F900FAF9FA00F9F9F800FAF9
      F900F8FAF800FAF9F900F9F9F800FAF8FA00F8FAF900FCF8FA00F8FAF700FBF9
      FA00FAF9F900F9FAF900F9F9F900FAF9F900F9F9F900F9F9F900FAF9F900F9FA
      F900F9FAF900FBF9F900F9FAF800FAFAF900FAF9F800F9F8F700F9F9F800FAF8
      F800F9F9F800F8F8F600F9FAF700FCF8F900F9F7F700F8F9F700FAF7F800F9F7
      F700FAF7F800F9F9F700F9F8F800FAF8F800F9F8F800F9FAF600F9F8F700FAF7
      F700F9F9F700FBF9F800F9F8F700FBF8F800F9F9F600F8F9F700FAF8F700FAF7
      F800F8F9F800FBF7F700FBF7F800F9F8F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F9F9FA00F9FB
      F800F9FAF900FAF9F900F9F9F900F9F9F800F9FAF900FBF8FA00F8FAF800FAF9
      FA00F9F9F800FAF9FA00F9FAF900F9F9F900FAFAF900FAF9F800F8F9F900FAFA
      F900FBF8F900F8FAF800FAF9F900FBF9F900F9FBF900FAF9F900F9F9F800F8FA
      F800FCF9FA00F9F9F900F8F9F900FBF9F900FAF9F900FAF9F700F9F9F800FBF8
      F800F7F9F700FBF8F700FBF8F800F9FAF600FBF7F800FAF9F800F9F9F700FAF8
      F700FBF8F800F9F9F700F9F9F800FAF9F800FBF8F800F9FAF600FAF7F800F9F9
      F800F9F9F700FAF8F900F8F9F600FAF8F800F9F9F900F9F9F700F8F8F700FBF8
      F700F8FAF700F9F8F600FBF8F900FAF9F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF800F9FAF900FCF8FA00F8FA
      F900F8F9F90000000000F7F9F800FAF9F900F9FAF800FBF9FA00FAFAF900FBF9
      F900F9FAF900FAFAF900FAF8FA00F6F6F600F7F6F700FAF9FA00FBFAF800FAFA
      F900FAF9F900F9FAF900F9FAF800FBF8F900F8FAF800FAF9F900FBF9FA00F8FA
      F800F9F9F900FAF9FA00F8F9F900FAF9F900FAF9F800F9F9F800F8F9F800FCF8
      F900F7F9F700FBF8F800FBF7F900F8FAF600FBF9F900FAF8F800F9F8F700FAF9
      F800FAF8F600F8F5F500572606005F2705006429050058280500FCF6F300FCF8
      F800F9F9F800FAF8F800F8F9F700F9F9F700FAF8F700FAF8F700F7F8F700FBF8
      F800F8FAF700F8F9F700FBF7F800F9F9F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900F8FAF800FAF9F900F9FA
      F900FAF9F900F8F9F900F8F9F800FAF8F900F9F9F900F8F9F900F9F9F800240D
      010034120100A4642900AA642900AE682E00A8662900AB652A00AC6F33002E12
      020015060000F9F8F900F7FAF800FAF8F900F7FAF800F9F9F900FAF8F900F9FA
      F900F8FAF900FBF9F900F8FAF900F9F9F900F9F9F800F9F9F700F9F8F900FAF8
      F700F6F9F700FAF8F700F9F8F800F9F9F700FCF8F700FAF7F700F8F8F7004616
      000091450D00652700006A2D000071310000703201006E2E0000682C00009246
      0F003E180000FBF8F900FAF8F700F9F9F800FBF8F700FAF9F700F9F9F600FAF9
      F800F9F8F800F9F8F700FAF9F900FAF9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900FAFAF900F9FAF800FAF9
      F900EFF2F000CBC0B300C8BFB300C9BFB400C9BDB300C7BEB200C7BEB200C7BE
      B000C5BDB000C7B9B000C4BCB100C8BCB100C6BEB100C6BCB200C8BFB400C7BD
      B200C9BEB300C7BCB100C8BEB100C9BFB200C7BFB200C6BEB100DDCFC800F8F6
      F700F9F9F900F9F9F900FAF9F900F9FAF900FAF9F800F9F9F800F9F8F800F9F8
      F800EEF3EF00CBAB9B00BBAD9600BDA79200BEA99400BDAB9600BEAB9500BEA7
      9400BBAB9500C0AA9800C0AB9900BBAD9500BEA89500BFA89400BBAC9500C0A7
      9500B9A89300BEA99600BEA99600BBA99500C0AA9500C0AB9800C6AC9900F7FB
      F300FAF8F900FAF8F800F8F9F700FAF9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9F900F8FBF800FBF8
      FA00D9CBC70030200F0034201100311F0F00321F100033201000D1C9C100D4CA
      C500C4BBB000D5C3C300D5D2C900E0D5D2005547410034211200CCC9BE00E8DF
      D800D2CBC40033201000341F110032210E0033201000321E0E00301F0E00110B
      0500FBF9F900F8FBF900FAF9FA00F9FAF900F9F9F800F9F9F900F9F9F800F9F8
      F900CCC2AD00431F0C003C1D0B003B1E09003B1D0A003E1C0B00C9D3CD00CED0
      CD00170F0400CAD0CF003C1E0E00150A0500CCD2CE00D2D5D400D1D3D1003A1B
      0900CFD3D400331C09003C1E0A003D1D09003D1F0A003E1E0A003D200A006252
      3200FAF9F900FAF9F800F9F9F900FBF8F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F8FAF900F9FB
      F800D4C3BF0045302200442E20004F3A27004F3827004D352400EEEDEE00523A
      2800F2F4F200FAF6F600F0F4F400FBFAFD007F6E64004C302100F9F4F200FFFC
      FA00F7F5F2004B3522004F3A2500523A2700523A270044301F0042301E002A19
      1000F9F9FA00F9FAF900FAF9F900FAFAF900FAF9F800F9F9F800FAF9F900FAF8
      F800C5BBAC004F2D18004B2B15005B4329005C4228005E3F2800F5FAF9005B3C
      2600F7F9FA00412C16004529150028140800F6F8F800FCFBFC00F6F6F700F9FB
      FB00F3F7F7001F1309005E44280060432A004E2F16004B2E1700492E1500D0C0
      AB00F9F9F900FAF9F900F9F9F700FBF9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F8FAF900FBF9FA00F9FAF800F9FA
      F800F3F0EE006046390062493B0061493B005E4938005F463900F8F8F8005E49
      380063493B005F493800F7F9FB00624939005F493800624B3B00614B3900624B
      3C00604E3B0063483B00604A3800634A390062483B0060493A0059443200160A
      0700F8FAF900FAFAF900FAFAF900FAFAF900FAF9F900F9F9F800FAF9F900F9F9
      F800CDD2CE006D4E36006E4F35006C5036006B4F34006E4F3600F6F9F9006C4E
      34006A492F00523419005B432B00432912006F4F3400684D2D00654129006D51
      350063492B006E5235006E5135006F5136006D5134006F4F3500654A2E00D5CD
      BF00FAF8FA00FAF9F800F9F9F700FAF8F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F8FAF900FBF9FA00F7F9F800FBF9
      FA00EFF1EF00F4F5F200432B2200432A22003C2C1F00402C21003C271D003E2F
      2200442F25003F2E2200422D2100453024003F312300472C240040322300472D
      24003E2F2100452C2300402F22003E2F2100482D23003E2C2000F4F5F5000D01
      0A00F8F9F900FAFAF900FAFAF900FAFAF900FAF9F800FAF9F800F9F9F800FBF9
      F900F3EDEA00D1D3D100300F05002C100400301005002B1005002C0F03003112
      07002E1304002E1104002F1404003114060030140400341405002F1605003613
      05002F130400301205002D1304002F1204002F1205002E110500E0E0E300F7F5
      F400FAF8F800FAF9F800F9F9F700FAF8F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F8FAF800FAF9
      FA00FBF8FA00361B0000011E48000C0403000121420000204200010002000018
      35000522480004233F0001000100301B0B00B8BAC800C36D0400B14D0100AD40
      01009D33010090250000011F430000203F000603030002030B00060E5900B0DE
      FA0006050E00F8FAF900FAF9FA00F9FAF900F9F9F800FAF9F900F8F9F700FBF9
      F900F9F8F800FBFCFA00311A0500B8AFA500B7A8A300ADA59600AB9C8D00A28B
      7900927557005E3317001F1106008E83740083786100180F03000232730021A1
      E2000674B800092F600001578E000D7ABA00243C0F00314A1E0059AE7C00F5F4
      F600F9F9F800FAF8F800F9F9F700FAF8F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9F900F8FAF800F8FA
      F800FDFBFB00E3A053002E81ED00146EE500C88C4D003292D70001010400082C
      55000B2B56000829520028180C0039221300CBD4E900A63A0200C8660800C25E
      0200BA4A0200A736000006244C0005224C0089B7DF008FBEE200B9E1F900BFE7
      FB00F9F9F900FAFAF900FAFAF900FAF9F900FAF9F800FAF9F900F9F9F900FAF8
      F800F9F9F800511F0000D7DAD500CAC8C800CCCFCC00C7CBC90061331000713E
      1A008F685100150B02006F523800896548007A5B3F007459370022AAE6006FE3
      FA001BA8EF000131770056DFF700000626001E480600225F0B005CC398000D16
      0700F8F8F800F9F9F900FAF9F900F9F9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F9FAF900FAF9F900F8FA
      F9004E23040055A5FA001558A3002274E70006020100021E4200000202001136
      6800020304000F3566003B2B1E003E281E00E6ECF800B64A0600FEF3E400F6F5
      F400DBD0CB003B221200113253001F67B400152EB500183FD7002152E9000A05
      0E00F9F8F800FAF9F900F9FAF900FAFAF900FAFAF800FBF8F800F8F9F800FAF8
      F800FBFCFB0098410000CFD9D6008B523000D7DBD7007A4F2A0081512F00794D
      2A00B59786009F8473002C15060049290F0021080100AA7C4800B9BCBB009E4D
      0D0038C0F200B2F0FB0042D5FB0043CAF800165F040076D7BD00286F18004689
      5F00F9F8F800F9F9F800F9F8F900F9F9F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900F9FAF800FAF9F900FAF9
      F9004D23000080C8F80072BCFC0065ABF900E0B5670012376800012447001941
      7A0010427C0011407200493425002A191400100A10001932B800F0F6FB00C0D5
      F300B4C1DA000C0203000F3B6A000E050800A17236004EBEEC004EC4F1002B78
      BA00FAF9F900F8FAF900FAF9FA00F9FAF900F9F9F900FAF8F800F9FAF800FCF7
      F9004120020027150800CEDFDC008E5E4700E0E5E700D5E1DF00D9DFDF00D6DC
      DC0097623B007C4820007E736600473C2A00B1B7B80092847700C5CFD100C885
      2E00CD8C2F00ADBABA00293414001B4C04007CDCC7008EE3E00092E7E4000A15
      0500F7F4F500FAF8F800F9F9F800FBF9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900F9F9F900F8F9F900F9FA
      FA00632601001E6BDE0009123B0087C3F300E6B3630012397400094173001B4C
      880013437B000F457B00D8A36A00000000000B000200D59B5E0012427500113E
      7700194D8600103F78000E3E7300270C040015559B003155DB00B49765000A02
      0D00F9F9FA00F8FBF800FBF9FA00F9FAF900FAF9F800FAF8F900F8F9F800F7F9
      F80060210100CAC2BC00D5E6E700F4F4F700FCF7FB00EEF5F800EDF5F800EBEA
      E800E0E0DA00D3C5BC007B756600ABA29700331B0A0092877900382A13000277
      ED00E5F6F700B5C0C600200C04001D5C080027A62400A0E9E40039A650007BE3
      CC00F5EFF800FBF8F900F8F9F800FAF9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F8FBF80064A6
      EA0053A5E800604F400082C8F9005C9EE5004CA7E300141924000D4585001B54
      9A0014488A00104A8400F4D8AA004B3529003E322500FDD7A900153F74001245
      7B001A4F8C00143F7F00001D2700A63B010091230500A8947D0087716900029B
      FF00F9F9F900F8FAF900F9FAF900FAFAF900F9F9F800F9F9F800FBF8F900F7F9
      F80062210000BCB9AF00D8E6E900DEE6EB00D9EAF000D8ECEF00EAF4F400947D
      6400EBEEEA00D9D5D100241808003E1E0A00573C2200544C360086877B00017E
      F000B0E0F300080706006A3A1D002C733100146B170090DFD60077A495004F2E
      0300FAFAF800FAF9F900FAF9F800FAF9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FBF9FA00F7FAF800FAF4
      F60048741200F6FDF400226806002D6A0E002D770E00348E1100419C1D000B15
      150008314E0019488400F5E3B9006BA3ED00519DE700F5E4B60006060E003680
      C300031110002EA52400C35F0200C25D00002FA22A009A28030000010100ECDD
      E100FBFAFA00FAF9F900F9FAF900FAF9F900F9FAF900F9F9F800FBF8F900F8F9
      F80062240000A4968000D5E8EB00996D500091775D00DDF0F100DBF0F500DEEE
      F300DBEBEF009E999200B4A59C005E483300534A3D00A5ADA900B9BFC400C8D8
      D8003B3830002A1202001F0E000071B2A5009ADDE10089DDD7008E3E01005625
      0400F9F9F800F9F9F700FBF9F900F9F9F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F8FAF900F9F5
      F6000A010A00236308002C620C003B6B12003D761C0037981D00429E250050AB
      31005EBB3A000D4088003889F00013489700061C40002A7AE400193B66006226
      090036A431002CC58D00DB911D0037DAB20024C08000923C030038A3F100F9FA
      F900F9F9FA00FBF9F900F8FAF800FAF9F900FAF9F800F9F9F700FBF7F900F9F9
      F7005A25010075553A00DAECF000E4EFF600E9F2F6009781640097826900A296
      8A00AEBABC00A5A9AA00C2C1BE00502C0D00DBE3E000E2EEEF0019221100E0EC
      F100E0EEF000E4EDF400B1917100B0662300945415007B4316008D410100FEF8
      FA00F9F9F800F8F9F600FAF8F900F9F9F6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900FAFAF900F9FAF900F8F6
      F900120607002A670E00447D2600EFF4E9003A922400379D260041A32B0057B3
      3B006EC04E0094D464004988FA0078C2FA0082C4FA004B91FB00FCEECF004C21
      0400ED941700E39A2E00F0C772005AE3E200E6C72D0035AA4B0000030400F8FB
      F700F9F9F900FAFAF900FAF9F900F9FAF900FAF9F900F9F9F800F9FAF800FAF9
      F9005C2A02003B1F0C00E0EEF1009A694000A16D4500A0754A00A3785000A477
      51009E734A0093693F0098806C00210F0200D5DCD100CDCEC000C8C1AC001F14
      0900A5A48700A98F7300AA916D00C1814300B9723400A3581600883E0300F8F5
      F800FAF9F900F8F9F600FBF7F900F9F9F6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900FAF9F900F8FAF9000F02
      0400235704002C6D11002D811700338F200037972800399F2A0047A83A005BB9
      4E0077B55F004C82DC007EC1FA002A60C1003066C8007CC3F700428BF700F3ED
      E30039BF8500C3741A00EFC87900FFC883001CD088005C8FCF0088390000F9FA
      F900F9FAF900F9FAF900FBF9FA00F9FAF800F9F9F800F9F8F700F8F9F700FBF7
      FA001C1E0E00584D4500E2F1F4006736150071391700E4F4F700E5F3F600E3F2
      F900E2F1F500DCEDEF00D8E5E90063422900533219005234170058381B00280E
      0600998B6F00D9C9C3001C130500CA8D4800BF7A3800CF964D00BC793100FAF8
      F800F9F9F700FBF7F900F8F9F800FAF9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F7FAF8001304
      06001D530100356315003E7B21003392210037A32B003FA4390046B144005FC0
      5C005DA2FA005096FD0085CEF6006FB7F8006EB5F9008ACEF6005499FF005FAA
      FF00F5E1B80048DBB70066DEDC00C077140000000000E5A74900FAF9F900F9F9
      F900F9F9F900F9FAF900FBF8FA00F8FAF800F9F9F900FBF8F800F8FAF800FBF8
      FA001E211C00E0E9F000854A2200764B1D00F3F5F800E5F3F800E4E9E600AB9C
      86009A9B8F009B948A00D7E6EB000B090400C77E3C00C4884200CB8B4300CC8E
      4400C98D4400E8C29700D2985900C68A4200BC743300C78D45006B2F0600FAF9
      F800F8FAF800FBF8F800F8FAF800FBF7F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900FAF9FA00F8FAF800F7F5
      F4001E570300EDFBED0038871D00309827002E922F0044AE3F0046B64D0065C3
      66002961D4007FB7EE00050208000906090003010500020205006FB1F0000D3D
      B400F9E9C700F3DBAD00EECB9300E7BF7900ECB06500893A0200F8FAF800FAF9
      F900FAF9F900FAFAF900F9F9F900FAF9F900FAF9F800FBF9F800FAF9F900F9F8
      F800D0DCDE00DBECF200D3D2C700E9F1F800E5F3F900E8F1FA00E7F4F600E7F3
      F600DEF1F300C2C2BF009E8E7C001E130600DEAC6F00CA8C4600CA8E4600C98F
      4800FAEDDF00E4BC8A00FBE5CF00B97C4200B06D2A00DCAC8300F9F9F900FBF8
      F800F9FAF800FBF8F900F9F9F800FBF9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F8FAF800F9F4
      F60020580400347A190033861F0033932700359D2F003FA33C0045B6500060C2
      630003020600419AF1000202000099CCFB0096CBFD0005000100539DF3000603
      0600F9EBD000F1DBAD00EDCB9600E2BC7800E2A65B00F7F4F300F8F9F900FAF9
      FA00FAF9FA00FAF9F900FAFAF900FBF9F900FAF9F900F9F9F800F9F8F900FAF9
      F800F5F8F600DCE9F200DDEFF300E2EBEF00F5F8F600E3F2F700E5F1F700E2F1
      F400DDEDF100513B2A00F1EFEF00DCA16100DBAA6A00FCF7F400CA8E4600C88D
      4200F9ECE800DDB27900EFD0B000EACDAC00BE7E360078391400F9F9F700FBF9
      F700FBF8F800F9F9F700FAF9F900FAF9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00FAF8F900F7F5
      F7003C92F100428DF2003D8FED004493F1004299F0004F98F90049A0F30064AA
      F900011939000003040086C8F90096CDFA0091CBFC005CA8F3001D84EA00001A
      3D00F7E9CC00F2D9AB00E7C98D00E3B46C008F460200FBFAFA00F9FAF800F9FA
      F900FBF9FA00F9F9F900F9FAF800FBFAF900FAF9F900FAF8F800F9F9F800F9F8
      F800FAF9F60000000000FBF9FA006B370D00CA8C3A00D09C4D00DEB574003F24
      1200261B0E002C251300D29A5200D59A5700F7F4F000D4AD7A00CA904700CC8D
      4400F5E1CC00EED3B500E6BC9300DBA96B00763A1900F9F9F800FAF9F900F9F9
      F700FBF8F800F9F9F700FBF9F900FAF9F6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAF9FA00F9F9F900F9FA
      F900F9FAF900FAF9F900F9FAF900F9FAF9009B430000E9BF7700ECD4A000F6E0
      BF000A3E70000218400001194300072A590002040D0008265400022148000101
      0300F3E2BE00EFCFA300E2BE7800A2460700F8FAF900FAF9F900F9F9F900F9FA
      F900FCF8FA00F8F9F900FAF9F900F9F9F900FAF9F800FAF9F800F9FAF800FAF8
      F800F9F9F900F9FAF600F9F9F900F9F7F6006F341200D1964A00DBA86500E4B8
      8A00EDC4A400EED0B400CF944E00D2985300FCE8CD00F7EBDE00C98E4800CB89
      4400EDD2B300E8BE9700DDAE75007A3F1E00FBF7F800F8F9F700FAF8F900FAF8
      F700F9F8F800F8F9F700FBF8F900FAF8F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900F9F9FA00F9FAF800FAF9
      FA00FAFAF900FAFAF900FAF9F900F8FAF900FBF8F90089480400F9EFC900F0D5
      A800F8E7CA0014315D0001204C0009346E000D3A74000F3A7A0008265900F4F1
      E500EFD4AB00F7ECC50086501700FAF9FA00FAFAF900F8F9F900FBF8FA00F9FA
      F900F9FAF900FBF9F900F9FAF900FAF9FA00F9F9F800FAF8F800F7F9F600F9F9
      F800FBF7F700F8F8F600F8F9F700FAF7F800FAF7F7006A3B0F00D4A16700DCAA
      6C00E4B68800EAC19D00C98D4700CC904A00F6DDC600F1DCC000F2D2B400EECA
      A700E8BD9400D9A97A00783E1700FAF9F800FBF8F900F8FAF700F9F9F800FBF8
      F800F8FAF800FAF7F700FAF9F900FAF8F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900FAF9F900F8FAF800FBFA
      F900F9FAF900F9FAF900FBF9FA00F9FAF900FAF9F900F9FAF800FBFBFD009D50
      1100FAF1D700F3E0C3000F0F11000A316B000D39750005070700F5DFBD00F8F2
      D900A5502000FCFDFD00F7FAF800FAF9FA00FAF9F900F8FAF800FAF9F900FAF9
      F900F8FAF900FBF9FA00F9FAF800FAF9F900F9F9F800FBF9F800F9F9F800F8F9
      F800FAF9F700FAFAF800F9F9F800FAF8F800FAF8F900F9FAF700F4F2F5007A3F
      1700ECD7B800E1B17D00E3B78C00E7BE9100ECC09D00E8C09B00E6BB9300F2E2
      CE0080421D00F9F8F900F8FAF700F9F8F900FBF8F900FAF9F800F8F9F800FBF7
      F800F8F9F700F9F9F800F9F8F800F9F9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9FAF900FAFAF900F9F9F900F9F9
      F900F9F9F900F9FAF800FAF9F900F9FAF900F9FAF800FAF9F900FAFAF900F9FA
      F800F9F8F800F6F6F800834212009E592900A2572A008E481D00F7F9F800FAF8
      F900F9F9F800FAFAF900F8FAF900FCF9FA00F8F9F800F8F9F900FAF8F900F9F9
      F900F9FAF900FBF9FA00FAFAF900FAFAF900F9F9F800FAF7F700F9F8F800F9F7
      F700F9F7F700F9F8F700F9FAF800FAF9F800F9F9F700F9F8F800FAF9F800FAF8
      F800F9FCFB00FBF7EA0082401D00794217007E451A0085411C00F6F5EC00FBFA
      F700FAF7F800F9F7F700FAF8F800F9F9F600F9F9F800FAF8F600F9F9F700FBF8
      F900F9F8F800F9FAF700FAFAF800FAF8F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F9FAF900F9F9F900FAF9
      FA00F8FAF800FAF9FA00F8FAF900F9FAF900F9FAF900FBF9FA00FAF9F900F8FA
      F800FBF9F900FAF9F900FAFAF900F9FAF800FAF9F900FAFAF900F9FAF800FAF9
      FA00F8F9F900FAFAF800F9F9F800FBF8FA00F8FAF900F9FAFA00FAF9FA00F8FA
      F900FAFAF900FAFAF900FAF9F900F9FAF900FAF9F800F9F8F700FAF9F800F9F7
      F700FAF8F800F9F9F700F9F9F800FAF9F700F9F8F700F9F9F700FAF8F700FBF8
      F800F9F9F800F8F9F600FCF7F900FAF9F700F9F9F800FAF8F700F8F9F800FAF8
      F700FAF9F800F8F8F700FCF8F900F9F9F700F9FAF700FAF9F700F9F8F800F9F9
      F700FBF8F900F9F9F700F9F8F900FAF9F8000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900F9FAF900F9FAF900FBF9
      FA00F8FAF900FAF9F900F9F9F900F9FAF900F8FAF800FBF9F900FBF9F900F9FB
      F800F9FAF900FAF9F900FAFAF900F9FAF900FAF9F900F9FAF900F9F9F900FBFA
      F900F9F9F900F9FAF900F8FAF900FAF9FA00F9F9F900F9FAF900FAF9F900EEF4
      FC00EEF4FC00EEF4FC00EFF3FC00F8FAF900FAF9F800FAF9F700FAF9F800F9F8
      F700FAF9F800F9F9F700FAF8F800FAF9F800FAF9F900F9FAF700F9F9F900FAF7
      F800F9F9F800F9F9F600FAF9F900FAF9F800F9F8F700FAF9F800FAF8F800FAF9
      F800FAF9F900FAF9F800FAF7F700F9F9F700FAF8F900F9F8F800F9F9F800EFF3
      FD00EEF4FC00EFF3FC00EEF3FC00F9F9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF900FAFAF900F9FAF900FAFA
      F900F9FAF900FBFAF900FAF9FA00FAFAF900F9FAF900FAFAF900FAFAF900FAFA
      F900FAFAF900FAFAF900FAFAF900FAFAF900FAFAF900F9FAF900FAFAF900FAFA
      F900FAFAF900F9F9FA00F9FAF900FAF9F90000000000FAFAF900FAFAF900EEF4
      FC00EEF3FC00EEF4FD00EEF3FC00EFF5FD00FAF9F900FAF9F800FAF9F800FAF9
      F800F9F8F800F9F9F800FAF9F800FAF9F800FAF9F800FAF9F800F9F9F800FAF8
      F800FAF9F800FAF9F700FAF9F800FAF9F800FAF9F800F9F9F800FAF9F800FAF9
      F800FAF9F800FAF9F800F9F9F800F9F8F800FAF8F700FAF9F800FBF9F800EFF4
      FC00EDF3FC00EEF4FD00EEF3FC00EFF5FD000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFAF9FFF9FAF9FFFAFAF9FFF9F9
      F9FFFAF9F9FFF9FAF9FFF9F9F9FFF9FAF9FFF9F9F9FFF9FAF9FFF9F9F9FFFAFA
      F9FFF9F9F9FFFAFAF9FFF9FAF9FFF8FAF9FFFAFAF9FFFAFAF9FFFAFAF9FFF9FA
      F9FFFAFAF9FFFAFAF9FFFBF8F9FFF9FAF8FFFAF9F9FFFAFAF9FFF9F9F9FFFBFA
      F9FFFAFAF9FFF9FAF9FFFAFAF9FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFDFDFDFFFDFDFCFFFCFDFDFFFCFDFDFFFDFEFEFFFDFEFEFFFDFEFEFFFDFE
      FEFFFEFEFEFFFDFEFEFFFDFEFEFFFDFEFEFFFDFEFEFFFDFEFEFFFDFEFEFFFDFE
      FEFFFDFDFEFFFDFEFEFFFDFEFEFFFDFEFEFFFDFEFDFFFDFDFDFFFDFDFDFFFDFE
      FEFFFDFDFDFFFDFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAF9F9FFFAFAF9FFF9FBF8FFF9FA
      F8FFFAF9F9FFF9FAF9FFFAF9FAFFF9FAF9FFF9F9F9FFF9FAF9FFF9F9FAFFFAF9
      F9FFF9FAF8FFF9FAF9FFF9FAF9FFF9FAF9FFF9FAF9FFF9FAF9FFFAFAF9FFF9FA
      F9FFF9FAF9FFFAFAF9FFFBF9F9FFF8FAF8FFFBF9F9FFF8FAF9FFF9F9F9FFF9FA
      F9FFFAF9F9FFF9FAF9FFFAF9F9FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFEBE9E8FF6350
      3DFF5B4531FF553F2CFF55402AFF553F2AFF57412CFF57402BFF56412CFF5641
      2BFF56412CFF57422DFF59422FFF58432EFF57432EFF57432FFF56412DFF5641
      2DFF55402CFF57422EFF56422DFF56422CFF58422EFF58432EFF58432EFF5743
      2DFF59432EFF604D3BFFCDC9C6FFFCFCFCFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAFAF9FFFBF9FAFFFAFAF8FFF8FC
      F8FFF9F9F8FFFAF9F9FFF9FAF9FFF9FAF9FFFAF9F9FFF9FAF9FFFAF9FAFFF8FA
      F9FFFAFAF9FFFAF9F9FFFAF9FAFFFAFAF9FFF9FAF9FFFAFAF9FFFAFAF9FFF9FA
      F9FFF9F9F9FFFBFAF9FFFBF9FAFFF8FAF9FFFAFAF9FFF9F9F9FFFAF9F9FFF8FA
      F9FFF9F9F9FFF9F9F9FFFAF9F9FFF9FBF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFEFEFFFDFDFDFFFBFBFBFFF7F8F7FFEFEEEEFFCEC9C3FFD9D5D1FFF2F1
      F0FFFAFAF9FFFDFDFDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF543E2AFFEEE9
      E4FFEEE9E3FFEFEBE5FFEFEBE6FFF0ECE7FFEFEBE7FFF0ECE8FFF0ECE9FFF0ED
      E8FFEFECE8FFEFECE7FFF0ECE8FFF0ECE8FFEFECE7FFEEEBE6FFEFEBE7FFF0EC
      E7FFEFEBE6FFF0EBE6FFEFEAE5FFEDE9E3FFECE7E2FFEBE6E1FFEBE6E1FFECE7
      E2FFEDE8E4FFCAC0B6FF7E7267FFAFA79FFFFEFEFEFFFDFDFDFFF9F9F9FFF2F1
      F0FFEFECEAFFEBE7E5FFEAE7E5FFE8E5E3FFE9E6E4FFE8E5E4FFE9E7E5FFE7E5
      E4FFE7E5E4FFE7E5E4FFE7E5E4FFE8E6E5FFEAE9E8FFDDDAD7FFD8D3D0FFD7D3
      CFFFD7D2CFFFD4D0CCFFD5D0CCFFD3CDC9FFD2CCC8FFD4CDC8FFDBD6D3FFDEDA
      D7FFE4E0DEFFF0EFEEFFFDFDFDFFFEFEFEFFFAFAF9FFFAFAF9FFFBF9FAFFF8FB
      F7FFF9F9F8FFFAF9F9FFF9F9F9FFF9FAF9FFF9FAF9FFF9FAF9FFFAF9FAFFF8FA
      F9FFF8FAF8FFFBF7FAFFF8F9F9FFF7F6F6FFFAF7F6FFF9F6F6FFF9F8FAFFF8F9
      F8FFF9FAF9FFFBF9F9FFFAFAFAFFF9F9F8FFFBFAF9FFF9FAF9FFFAF9FAFFF9FA
      F9FFF9F9F9FFF8F9F8FFFBF9F9FFF8FAF8FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFB
      FBFFF6F6F5FFE5E3E1FF9A8779FF424852FF092C59FF207FCDFF103B6EFF1125
      3BFF9B8F82FFE7E4E0FFF8F8F7FFFCFCFCFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF553E28FFEDE7
      E2FFE5DDD5FFE5DDD6FFE4DDD6FFE4DDD5FFE3DCD4FFE3DBD3FFE2DAD3FFE2D9
      D2FFE0D7D0FFDFD6CFFFDFD7D0FFE0D8D0FFE1D8D1FFE2D9D1FFE1D9D0FFE1D8
      CFFFE1D7D0FFE1D8CFFFE0D7CFFFE0D6CEFFE0D6CEFFE0D6CFFFE0D6CFFFE0D7
      CFFFE0D7CFFFD0C6BEFF887C70FFA1978DFFFCFCFCFF655345FF270F00FF2D12
      00FF341803FF371B04FF3A1B05FF401F05FF411F06FF452208FF422107FF622B
      03FF5A2903FF602A03FF401F06FF401B03FF321A01FF3C250DFFC7BCA9FFCAC0
      AEFFC8BEADFFC7BDACFFC8BEADFFC9C1B1FFCAC1B1FFCCC2B2FFCAC2B2FFC9C0
      B0FFC5BBA9FF492303FF9B9088FFFBFBFBFFFAFAF9FFF9FAF9FFF9F9F9FFF9FA
      F9FFF9F9F9FFFBF9F9FFF4F3F1FFF3F2F0FFF3F3F0FFF2F1F0FFF6F3F2FFF1F2
      EEFF431200FFA06722FF88440FFF85410DFF84410EFF85430CFF84440DFF9255
      1AFF3D0E00FFF8F1F1FFF3F1F0FFF1F3EFFFF5F2F0FFF3F2F1FFF7F3F1FFFCF9
      F9FFFBFAFAFFF8FBF8FFF9F9F8FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFCFCFCFFF9F9F9FFEEEDEDFFC3BA
      B4FF756E68FF072443FF1E65A9FF217ECBFF2380CEFF2381CFFF114989FF1248
      88FF072042FF6A5D53FFBCB3ACFFEEEEECFFFAFAF9FFFDFDFDFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF543E27FFEEE9
      E4FFE6E0D9FFE6DFD8FFE6DED7FFE5DED6FFE3DDD5FFE3DCD4FFE2DAD3FFE2DA
      D3FFE2D9D2FFE1D8D1FFE1D8D2FFE2D9D2FFE2DAD2FFE1D9D1FFE3D9D2FFE1DA
      D1FFE1D9D1FFE0D9D0FFE1D9D0FFE0D8D0FFE0D7CFFFE0D7CFFFE0D6CFFFE0D7
      CFFFE1D7CFFFCCC3BBFFA4998FFFB4ACA3FFFBFBFBFF592808FF632F0DFF6B33
      10FF6B320FFF6E3412FF723713FF743915FF773B16FF783D18FF3C1E07FFB757
      15FFAC5010FFA54C08FF4A2507FF743712FF331901FF614E3BFFE4DFD3FFC5A6
      88FFBA977BFFBC916FFFE0D7CAFFE1DACEFFE1DBCFFFE2DCD0FFE2DBD0FFE1DA
      CEFFDFD8CCFF753900FF2B1100FFEDECEBFFFBFAF9FFF9FAF9FFFAF8F8FFF9F9
      F9FFFBFBFBFFAEAAA5FF2F1E0FFF2C1C10FF2F1C0EFF2F1B0FFF321C0FFF3321
      10FF362010FF332111FF3A2413FF382815FF3A2513FF3B2415FF342312FF3620
      12FF371F0FFF311C0FFF2E1B0DFF2E1C0FFF2F1C0FFF2F1D0FFF2F1E10FFA39E
      9BFFFDF8FBFFF8FBF8FFFAFBFAFFFAF9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFBFBFBFFF0F0EFFFB5ABA1FF766F6BFF072142FF2268
      AFFF257CC9FF257ECCFF2580CEFF2481CEFF2583D0FF2483D0FF154C8CFF154C
      8CFF144B8BFF124686FF081E3EFF77665AFFBDB5AEFFF4F4F3FFFAFAFAFFFDFD
      FDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF553F29FFEEEA
      E5FFE6E2DBFFE6E1DAFFE6E0D9FFE5DFD8FFE4DED6FFE4DDD5FFE2DCD4FFE3DB
      D3FFE2DAD3FFE1DAD2FFE2D9D2FFE2DBD3FFE3DAD3FFE2DAD2FFE1DAD1FFE3DA
      D2FFE1DAD1FFE2DAD2FFE1DAD1FFE2DAD1FFE1D9D1FFE0D7CFFFE0D7CFFFE0D6
      CFFFE1D7CFFFCCC2BBFFC1BAB4FFC9C3BEFFFEFEFEFF602C0BFF6B3512FF793D
      18FF773B17FF783D18FF7D4019FF80421BFF86471EFF88491FFF914C14FFBC5D
      17FF180C01FFB6580EFFC05F0FFF82441AFF2C1602FF675644FFF1EEE8FFE075
      29FF2772E7FFD96B17FFE2D1BDFFADA090FFAA9D8CFFA99C8BFFA99D8DFFA99E
      8EFFE6E1D8FF7E3F02FF250E00FFF0EFEEFFFBFAF9FFF8FAF9FFFAFAFAFFF9FA
      F9FFF2F7F3FF3D2114FF3D2714FF382412FF3E2818FF160F0AFF301D0FFF3C28
      19FF3E301EFF48321FFF483223FF4F3E2AFFE4E0DEFFE2DFDFFFE7DEDFFF412D
      1BFF412E1CFF3A281AFFB7B0AEFF302311FF392115FF392615FF3B2314FF3621
      12FFF9F5F9FFF8FBF8FFFBF9FAFFF9F9F8FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFDFDFDFFD0CAC5FF7A746FFF052145FF2574BEFF2173C1FF2379C7FF247B
      C9FF257ECBFF2580CCFF2683CEFF2684CFFF2685D0FF2886D1FF195092FF1A50
      91FFF3EAE1FF124383FF124784FF124685FF051F4AFF877968FFC7C0BAFFF6F6
      F5FFFDFDFDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF523D28FFF0EB
      E7FFE8E4DDFFE7E2DCFFE6E2DBFFE6E0D9FFE5DFD8FFE5DFD7FFE5DED6FFE3DD
      D4FFE3DAD3FFE2D9D2FFE3DBD3FFE3DBD3FFE2DBD3FFE2DAD2FFE3DAD2FFE3DB
      D3FFE3DBD3FFE2DAD2FFE2DAD2FFE0DAD1FFE1DAD1FFE0D8D0FFE0D7CFFFE1D7
      D0FFE2D8D0FFD0C7BEFFE4E1DEFFE5E2DFFFFFFEFEFF60300EFF7A3F1BFF8E4B
      22FF884720FF8A4821FF8E4C24FF914E26FF965228FF653412FFD06C1FFF3517
      05FFECE7E1FF190900FFCF6B13FF49230CFF2D1604FF6F5E4FFFF7F3EDFFA9B8
      CAFF549FE1FF5D99C9FFF3EFE9FFF3F1EBFFF3F2EEFFF4F2EFFFF3F1EDFFF0EF
      EBFFEFECE6FF874203FF220C00FFF5F4F4FFFAF9F9FFFAFAF9FFFAFAF9FFF9F9
      F9FFF1F6F2FF482D1FFF593E2EFF523F29FFF6F5F7FFFDFAFDFF423120FF564C
      47FFF5F7F9FFF6F9FAFF6A5441FFF9F9FBFFFCFAF9FFF9F6F9FFF0EDF1FF6455
      41FF382620FFF4F6F6FFF0EBEFFF5A4B34FFFAFAFAFF543B28FF543C28FF412B
      18FFF6F6F8FFF9FBF9FFF9F9FAFFFAF9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFCFBF8FF2177C5FF2171BFFF2374C1FF2375C3FF2478C5FF247BC7FF257D
      C9FF2680CAFF2782CDFF2884CFFF2885D0FF2988D2FF2B88D2FF1C5396FF1D53
      93FFD2CBC2FFEDE7DDFFEFEAE1FF1C4B86FF164C8CFF184F91FF051E40FFA89C
      8EFFDBD8D3FFFDFDFDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF56402BFFF1EC
      E8FFE9E5DEFFE8E4DEFFE7E2DCFFF7F3EFFFF6F3EFFFF5F3EFFFF5F3EEFFF5F2
      EDFFF3F1ECFFF3EFEBFFF3F0EBFFF3F0EBFFF3EFEBFFF2EFEBFFF3F0ECFFF3F0
      ECFFF3EFEAFFE1DBD2FFE1DAD2FFE2DAD2FFE1DAD2FFE0DAD1FFE1D8D0FFE1D8
      D0FFE2D9D0FFCEC4BBFFF8F8F5FFF5F4F2FFFEFEFEFF4C260EFF8C4B24FF5D35
      18FF97512AFF99542BFF9E582EFFA25D33FFA65E30FF482202FF251204FFEFEA
      E2FFEAE6E0FFE4DFD7FF180D00FF1E0D01FF301B08FF766559FFF8F6F2FF0725
      59FF70B2F0FF6FB9FBFFFAF7EFFFF8F7F3FFF9F7F4FFF8F7F4FFF8F6F3FFF6F6
      F4FFF3F2EEFF954A07FF210B00FFFDFDFCFFFBFAF9FFF9FAF9FFFAFAF9FFF9F9
      F9FFF5F6F6FF251C15FF674C3AFF65533EFF52443AFF644E3CFF5E4D3AFF7261
      48FF7C654FFF7F6B59FF806C59FF81705BFFFAF6F8FF7C6654FF77654EFF715D
      47FF6F5A43FF6D5541FF6A513DFF644E38FF634B36FF5D4734FF59412DFF544B
      46FFF9F9FAFFFAF9F9FFF9FAF9FFFAF9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFE6E8EAFF1F70BFFF2273C0FF2477C3FF2478C4FF257AC6FF267DC9FF267E
      CAFF2882CCFF2883CDFF2987D0FF2A88D1FF2B8AD4FF2C8BD4FF1E5598FF2056
      96FFCDC7BDFFC3BBB1FFB4ADA3FFEDE8E1FF1B508FFF1B5191FF1B5090FF1B50
      8FFFC7C0B6FFE1DEDAFFF4F3F2FFFDFDFDFFFEFEFEFFFEFEFEFF59432DFFF2EE
      EAFFEBE7E1FFEAE6E0FFE8E4DEFFB7AB9DFFB3A799FFB3A89AFFB3A799FFB1A5
      96FFAFA293FFAEA192FFAEA092FFAEA092FFADA091FFAEA091FFAEA091FFAC9E
      8FFFA99C8DFFE2DBD2FFE2DBD3FFE1DBD3FFE3DBD4FFE1DAD2FFE1DAD2FFE2D9
      D2FFE4DAD1FFCCC2B9FFFFFFFFFFFDFDFDFFFEFEFEFF321906FF9B522AFF834C
      29FFA25B33FFA55C33FFA86035FFAC6538FFB66013FFE3DED8FFCDC6BDFFBBB1
      A6FFE4DED8FFDAD2C9FF726457FFF2EBE4FF3A1D05FF6C5F55FFF9F8F5FF0117
      36FF406C97FF09294BFFFFFEF9FFDFDAD3FFDFDAD4FFDFDAD4FFDFDAD4FFDFDB
      D5FFF6F5F2FF964F0EFF1F0A00FFFEFEFEFFFBFAF9FFFAFAF9FFFAFAF9FFF8FA
      F9FFFAF9F9FF0A0000FFFDF7F8FFF8F9F8FFFEF6F8FFFCF7F9FFFCF7F8FFFAFA
      F8FFFDF8F8FFFCF8F8FFFEF7F8FFFBF9F7FFFCF7F8FFFBF8F8FFFEF6F9FFF9FA
      F7FFFEF8F8FFFBF9F8FFFBF6F8FFFBF6F8FFFCF7F8FFFAF7F8FFFBF5F8FF1A0B
      04FFF9F9F9FFF9F9F9FFF9FAF9FFFAFAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFE0E2E7FF2073C0FF2276C2FF2579C4FF257AC6FF257CC8FF277ECAFF2781
      CCFF2884CDFF2985CFFF2B88D1FF2B8AD2FF2C8CD5FF2D8DD6FF20589BFF2258
      98FFD7D1C7FFB3ACA1FFBFBAAFFFE3E0D8FF1E5291FF1E5393FF1E5293FF1F53
      94FFD3CCC2FFDFDCD8FFEDEBE8FFF9F8F8FFFEFEFEFFFEFEFEFF58432EFFF2EE
      EBFFEDE9E4FFEBE8E2FFEAE6E0FFC9C1B7FFC6BEB6FFC6BFB6FFC6BEB5FFC5BC
      B3FFC6BEB4FFC4BCB3FFC6BDB4FFC3BAB1FFC5BBB2FFC6BDB3FFC5BDB3FFC2B9
      AFFFC4BAB0FFE3DCD4FFE3DCD4FFE2DCD4FFE2DBD3FFE2DBD3FFE1DAD2FFE3DB
      D2FFE4DBD2FFC7BEB4FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFF211000FFE89B
      6BFFD88B5FFFAE6337FFB46B3EFFE9853CFF2C261FFFF9F6F3FFF9F7F4FFFDFC
      FDFF2A8CDEFFB2A793FFF6F0EAFFEFE8E1FF2A1706FF665E55FFFCFAF7FF92A8
      B6FF001A3BFF527081FFFCFBF9FFFBFAF8FFFBF9F7FFFAF8F7FFFAF8F6FFF9F7
      F6FFF9F8F6FF944D0EFF1E0B00FFFEFEFEFFFBFAF9FFFAFAF9FFF9FAF9FFF9FB
      F9FFFDFCFCFF3D0C01FF5A2001FF753104FF6C1401FF872701FF140000FF8522
      01FFA84605FFAC5206FFB45304FF933602FF9D3F02FF9C3C02FF863200FF886D
      56FFE5DEDDFFE4DCD7FF932B02FF520A01FF7C1C01FF24130AFF341A0BFF341B
      0CFFFAF8F9FFF9FAF9FFFAF9FAFFFBFAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFDBDEE4FF2075C2FF2378C3FF257AC5FF267CC7FF267FCAFF2782CCFF2883
      CDFF2886D0FF2A88D1FF2C8AD3FF2D8DD4FF2F8FD7FF3090D9FF235A9EFF245A
      9CFFF3ECE6FFCFC9BEFFB5AEA3FFE4E0D9FF205393FF215596FF225698FF2157
      9AFFE6DFD8FFEAE7E5FFF2F0EFFFFAF9F8FFFEFEFEFFFEFEFEFF5A4430FFF3F0
      EDFFEEEBE6FFEDE9E4FFEBE7E2FFE9E5DFFFE9E4DEFFE8E2DCFFE7E2DBFFE7E1
      DAFFE6E1DAFFE6E0D9FFE6E0D9FFE5DFD8FFE5DFD7FFE5DFD7FFE5DED7FFE4DD
      D6FFE3DCD5FFE4DDD5FFE3DCD5FFE3DCD4FFE2DBD3FFE1DAD2FFE3DBD3FFE1DB
      D3FFE5DCD3FFC1B8AEFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF4F3
      F2FF251202FFE0996DFFF6A067FF1F0F02FFF3F0EBFFFAF7F4FFF0EEEAFF4C90
      C7FF3F96E6FF388EE7FFA69A7FFFF2EAE4FF301B08FF6B5C4DFFFEFDFBFFFCFC
      FAFFFEFEFEFFFEFFFEFFFEFDFDFFFDFCFBFFFCFCFAFFFCFBFAFFFCFBFAFFFBFB
      F9FFFBFAF9FF9A4D0EFF200C00FFFFFEFEFFFBFAF9FFFAFAF9FFFAF9F9FFF9FA
      F9FFFBF9F9FF511C02FF8C440DFF2C0C03FF130403FF9A3702FF978271FFBC4B
      02FFBA5A05FFC0630EFFD67916FFBF6814FF4F1300FF6D1F00FFC06A11FFF5F6
      F7FFF6F4F7FFF6F8F7FF987D6DFF952E01FF8D2301FF221007FF4A2D1AFF4027
      11FF978275FFF9FAF9FFF9FAF9FFFAFAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFD6DBE1FF2075C3FF2379C5FF257CC7FF257FC9FF2781CCFF2884CEFF2885
      CFFF2987D2FF2A8AD4FF2E8ED6FF2F90D7FF3194DBFF3295DCFF245B9FFF255D
      9FFF265FA1FF5981ACFFF1ECE1FFEBE8E1FF225697FF23599AFF235A9CFF225A
      9EFFF6F3EDFFF7F4F3FFFAF9F9FFFDFDFDFFFEFEFEFFFEFEFEFF5D4833FFF4F1
      EFFFF0EDEAFFEFEBE7FFEDEAE5FFE9E5E0FFE5E1DBFFE4E0D9FFE4E0DAFFE3E0
      DAFFE2DDD7FFE2DDD6FFE1DCD5FFE3DED6FFE2DDD5FFE1DBD3FFDFDAD3FFE0DA
      D3FFDFDBD4FFDFDAD3FFE0DAD2FFDED8D0FFDED7CFFFE3DBD3FFE2DCD4FFE4DC
      D4FFE6DCD4FFC0B6ADFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFD0CCC6FF35220CFFE9E2DBFFB3AEA7FF257ADEFF2276
      D8FF2677D9FF2576D9FF2576DAFF9A7F5CFF3C2510FFE05E08FFE25C08FFE55E
      08FFE5620BFFE4660FFFE7650BFFE96409FFE86709FFE6690DFFE8650CFFE862
      0CFFEC630AFFDA5B01FF230D00FFFFFEFEFFFBFAF9FFF9FAF9FFF9FAF9FFFAF9
      F9FFF9FAF9FF7D491EFF905016FF934613FF64585DFF9F3C01FFA89A89FFA746
      02FFAF5209FFB96714FFC46919FF2A0A00FFBC5507FFBB5B02FF7D3B0AFFB561
      0AFF9A8D82FFAA4A01FFA54E08FF6F1E00FF160305FFF5F6F5FF5B3E28FF5A3C
      27FFB0A296FFF9FAF9FFFAF9FAFFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFD4D9E0FF1F76C2FF237BC7FF247CC8FF2680CAFF2883CEFF2885CFFF2987
      D3FF2989D5FF2B8AD0FF3092D9FF3193DAFF3396DDFF3397DCFF255D9FFF265E
      9FFF275F9FFF275F9EFF2961A1FF3068AAFF245B9CFF255B9DFF255C9DFF255D
      A0FFFFFFFFFFFDFDFDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF5C4732FFF6F4
      F2FFF2F0ECFFF1EEEAFFEFEBE7FFBAAFA3FFB3A99DFFB2A79AFFB2A79BFFB3A7
      9AFFB2A599FFB1A698FFB1A598FFB0A396FFB0A395FFAFA194FFAEA092FFAEA0
      92FFAFA193FFAEA192FFAEA092FFAEA092FFB0A293FFE4DCD5FFE4DDD5FFE4DD
      D5FFE5DDD5FFC1B7ADFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFF8E7C66FF186DCEFF0D4FAEFF3E9F
      F0FF48A6EDFF42A0EFFF1965BBFF0F50A7FF3E250EFFE96713FFE86817FFEB6B
      1AFFD98D46FF322C26FFEC701CFFEA6A19FFEF7B1DFF312C25FFEE7120FFEC71
      1DFFF0741DFFEF7113FF270D00FFFFFEFEFFFBFAF9FFF9F9F9FFFAFAF9FFF9FA
      F9FFFAF9F9FF684C34FF8E5A21FFF5EAD5FF8EBDF9FF170203FFAA9D8CFFA64D
      05FFB05304FF4E1B04FF672100FFC76200FFF6F8F8FFF6F6EFFFC75D01FF671E
      02FF1E0B00FFB05205FFAA4700FF988572FF0E0804FF867C66FF69513DFFFAFC
      FAFFFBFAFCFFFAFAF9FFFAFAF9FFF9F9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFD2D8E0FF207AC7FF227DC9FF257FCAFF2783CDFF2884D0FF2780C5FF2762
      87FF8ED1EEFF3B7293FF3396DCFF3397DDFF3499DFFF3399DDFF255C9FFF275E
      9FFF275F9FFF2861A0FF2961A2FF2861A2FF285FA0FF275FA0FF265EA0FF2660
      A4FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF5D4933FFF8F5
      F4FFF4F2EFFFF2F0ECFFF0EDE8FFC9C2BBFFC8C2BAFFC8C0B9FFC8C1B8FFC8C1
      B8FFC5BCB2FFC5BCB2FFC4BBB1FFC4BBB0FFC1B8ADFFC1B8AEFFC3BAB0FFC3BA
      AFFFC2B9AEFFC1B6ABFFC1B6ABFFC0B6ACFFC4BAB0FFE5DDD5FFE3DDD5FFE4DD
      D5FFE7E0D7FFC0B6ACFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF4A6D96FF358EE7FF58B6F6FF68C3
      F8FF67C1F7FF5FB8F2FF3F9DEDFF3595EFFF0F294DFF1A0E02FF1F0C00FF2712
      01FF150800FFA59F94FF100905FF1A0F04FF180E05FF9B938CFF231206FF2B14
      05FF301605FF2F170AFFF5F3F1FFFEFEFEFFFBFAF9FFF9FAF9FFFAF9F9FFF9F9
      F8FFF8F8F9FF784010FFF3EADCFF0A0C13FF030520FF8DBEFAFF5D5B5EFF903B
      00FFAF5204FFA64602FFC66204FFC4BDB3FFF7F7F9FFF2F4F5FFCB6700FFBD51
      03FFCE6309FFA74F03FF220000FFFCFBFCFF65442CFFF2F0E7FF20170FFFB46B
      13FFFAF9F9FFF9FAF8FFF9FAF9FFF9F9FAFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFCBD3DBFF217DC9FF237FCAFF2483CCFF2C7AB2FF92D3EEFF98D5F1FF95D4
      F0FF93D3EFFF3D7191FF3599DEFF349ADFFF359ADFFF389DDFFF255EA0FF2760
      A0FF2860A1FF2A61A1FF2961A2FF2861A1FF2961A1FF2861A2FF2760A2FF2661
      A7FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF604B36FFF9F7
      F6FFF6F4F2FFF5F3F1FFF2F0EDFFF0EEEBFFEFEDE9FFEEEBE7FFEEEAE6FFEDEA
      E5FFECE8E3FFEBE7E1FFEAE6DFFFE9E5DFFFE9E4DEFFE8E3DDFFE8E2DCFFE6E1
      DAFFE7E1DAFFE6E0D9FFE6E0D9FFE6E0D8FFE5DFD7FFE4DED6FFE5DDD6FFE4DE
      D7FFE8E2DAFFBBB1A7FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFF033775FF3A96EEFF55AFF5FF6CC6FAFF6DC7
      FAFF6FCAFDFF69C5FAFF5EBBF7FF49A8F0FF3593EEFF063670FFFEFEFEFFFEFE
      FEFF403323FFC0BDB8FFB4B3AFFFB3B2AEFFB5B2ADFFCDC9C5FFFFFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBF9F9FFF9FAF9FFF9FAF9FFFAF9
      FAFFFBFAFBFFA16D25FF253C78FF0A0C25FF97C1FAFF030203FF4364BDFF010A
      2AFFF1E8E8FFCD6C01FFCB6704FF88C5FCFF92C8FBFF76B4F7FF579AE8FFB34C
      02FF240808FFB5ADA2FFEDE9E4FF496AC5FF14236DFF453B36FFB77431FFB573
      2EFFFCF7FBFFF8FAF9FFF9F9FAFFFAFAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFC2CCD5FF237FCBFF2482CDFF2685CFFF2677ABFF9AD6F1FF99D6F1FF98D6
      F2FF98D6F1FF3C7192FF3599DFFF359ADFFF379DE1FF41A4E3FF265EA0FF275F
      A0FF2860A1FF2961A1FF2961A1FF2961A2FF2961A2FF2862A4FF2762A5FF2662
      A9FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF644F3AFFFAF9
      F8FFF8F6F5FFF6F4F2FFF5F2F0FFE8E6E3FFE9E5E2FFE9E5E2FFE7E4E0FFE7E3
      DFFFE6E2DEFFE6E2DEFFE5E0DBFFE3DFD9FFE3DED9FFE3DED7FFE3DDD8FFE0DA
      D3FFE1DBD4FFDFD9D2FFDFD7D2FFE6E0DAFFE5DFD8FFE5DFD8FFE4DED7FFE6DF
      D7FFE8E1DAFFB9B0A6FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFFFFFFFF3891E7FF3F9AEFFF6DC7FAFF6DC7F8FF65B4
      E5FF78CFFDFF69C1F3FF56A5DAFF5FB6F2FF4BA3EFFF3388E4FFECEFF3FFFEFE
      FEFFFFFFFFFF503D2CFF4F3E2CFF4C3A29FF4A3A29FF847768FFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBF9F9FFF9FAF9FFF9FAF9FFFBF9
      FAFFF5F9F8FFB07832FF000007FF97C4F9FF526CEBFF8BBAF7FF81B0FCFF0C05
      1BFF192F5CFFFAF5F2FF7F2602FF375DB5FF3D60B8FF395AB2FF5C92E1FF9E38
      00FFC48844FFC98C4AFF6CA9F8FF92C9FAFF99CEFCFF6AA8EEFFCA863EFFBC7E
      38FFF7F8FAFFFAFAF9FFFBF9FAFFF9F9F8FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFAEBFD0FF2381CDFF2584CFFF2788D1FF237AB2FF9CD8F2FF9CD8F2FF9CD9
      F2FF9DD9F2FF3E7293FF369ADFFF369BE0FF379EE2FF6BC1EEFF265EA2FF275F
      A1FF2861A1FF2961A1FF2962A1FF2961A2FF2862A5FF2763A7FF2664A8FF2665
      ABFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF65513CFFFBFB
      FBFFF9F8F7FFF8F7F5FFF8F6F4FFC6C1BBFFC2BBB3FFC4BCB5FFC3BCB4FFC2BA
      B2FFC0B8AFFFC0B8AEFFC0B7ADFFBFB5ABFFBDB3A8FFBCB2A7FFBBB2A6FFBBAF
      A4FFBBAFA4FFBBAFA3FFB8ADA1FFD0C8BFFFE7E2DBFFE6E0DAFFE5DFD8FFE4DF
      D8FFE8E2DBFFBFB5ABFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFEFF0B3B7CFF2B84EBFF439CF0FF5BB3F6FF73C9FBFF75CBFBFF79CD
      FBFF7ACEFBFF78CCFBFF74C8F8FF6ABEF5FF5BB4F0FF358CEBFF0B54B1FF0F40
      7DFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFAF9FFF9F9F9FFF9F8F9FFF9F9
      F8FFF9FAF9FFC68944FF907964FF92B1F9FF9AC3FAFF9CC4FAFF91B8FDFF866E
      5AFF233E72FFC59553FF5B514FFF7EB7FBFF98CEFAFF7FBBF9FF130F43FFF4F6
      DEFFCC9A5FFF68A2F3FF8AC4F8FF93CFFAFF26449CFF85BDF9FF0B0A2EFFC792
      48FFF8F8F9FFFAFAFAFFFCF8FAFFF8FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF9FB5C7FF2482CEFF2686D0FF288AD3FF277CB6FF9FD9F2FF9ED9F2FFA0DA
      F3FFA0DAF2FF457797FF2F96DFFFA4DDF9FFC0EDFEFF87D8FAFFB8EDFDFF98D4
      F0FF2760A3FF2760A1FF2761A2FF2761A3FF2763A7FF2764A9FF2565ABFF2567
      ADFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF62503DFFFCFC
      FBFFFBFAF9FFFAF9F7FFF9F8F6FFFBFCFAFFFAFBF9FFFAFAF8FFF9F8F6FFF7F7
      F4FFF6F5F2FFF6F4F2FFF4F3F0FFF4F2EFFFF3F1EDFFF2F0ECFFF1EFECFFF1EF
      ECFFF2F0EDFFF3F0EEFFF3F0EEFFF0ECE9FFE9E4DDFFE7E2DCFFE6E1DAFFE6E0
      DAFFE6E0DAFFC1B7ADFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF6B87A3FF328BEDFF2B81E6FF489FF1FF75CBFBFF75CBFBFF7BCFFCFF7CD0
      FCFF7CD1FCFF7ACFFBFF78CCFAFF6FC4F7FF62BAF2FF378AEBFF094D9FFF2E84
      E4FF899AADFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAFAF8FFFAF9F9FFFAFAF9FFFAF9
      F9FFF9FAF8FFD1964DFF0A0908FF75A3E4FF9BC2F9FF8EB6EEFF8AB3F5FFA28B
      72FF100910FFC69B5EFF71A7F4FF8BCCFAFF234BBAFF95D1FBFF78B3F9FFF9F7
      FBFFF5F3F2FF040200FF8EC4FEFF89C0F9FF191004FF8CB6ECFF3972D9FFD6A4
      5FFFF9FAF8FFF9F9FAFFFAF9F9FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF9CB4C9FF2585D0FF2787D2FF298BD4FF277FBDFFA3DBF4FFA0DAF3FFA1DB
      F3FFD8F0FBFF85A2B2FF63CAFDFF64C9FBFF63C9FAFF63C7F9FF63C7F9FF60C6
      FAFFA7E7FCFF77BBE0FF2661A5FF2662A6FF2664A8FF2565ABFF2466ADFF2468
      B0FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF614C38FFFEFD
      FEFFFCFCFBFFFBFBFAFFFAF9F8FFF9F8F7FFF8F6F5FFF6F4F2FFF4F3F0FFF3F1
      EEFFF1EEEBFFEFECE8FFEFEBE7FFEDE9E4FFECE8E2FFEBE6E1FFEAE6E1FFE9E4
      DFFFE8E4DEFFD3CABFFFCDC1B4FFCABEB0FFC7B9ACFFC6B8AAFFC5B8AAFFC5B6
      A8FFC8BBAEFFBAAC9EFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF00254FFF328AEDFF00060FFF4DA3F1FF76CCFAFF000302FF70BAD8FF7ED1
      FDFF7ED2FCFF7DD1FCFF7BD0FCFF000204FF67BFF7FF3B8EECFF001229FF2E81
      E4FF02224AFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBF9F9FFF9FAF9FFF9FAF9FFFAFA
      F9FFF9FAF9FF6B3816FFD5D0C9FFF7F8F7FFCCC0B6FFFCFBFAFFE9E6E4FFDCD7
      D3FFF9F6FAFF7BB8FAFF6CA4F3FF93CFFBFFA2D4FAFF91CEFAFF7FBEFBFF0B0C
      09FFFFF3E5FF192437FF91C9F5FF98D1FAFF95CEFDFF7CBFF5FFF5F3EEFF5F2B
      06FFFAF9F9FFF8FBF8FFFAF9F9FFFAF9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF95AFC5FF2888D2FF288BD4FF298BD7FF1E7ECCFFD1ECF9FFE5F4FCFFD1ED
      FAFFC2E9F9FFBFE8F9FFBFEAF9FF4D7C92FF5EC7FCFF60C5F9FF60C3F9FF5FC2
      F8FF5DC1F8FF59BEF6FF80D9FBFF4B9ACFFF2463AAFF2466ACFF2468AFFF2167
      B3FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF614D38FFFEFE
      FEFFFDFEFDFFFCFCFCFFFBFBFAFFFAF9F8FFF9F8F7FFF8F6F5FFF6F5F3FFF5F4
      F1FFF3F1EEFFF1EFECFFF0EDE8FFEEEBE7FFEDE9E5FFECE8E3FFEBE8E3FFEAE5
      E0FFCBC0B3FFC2B09EFFC1AE9BFFC1AD9AFFBFAB99FFBEA997FFBCA895FFBCA7
      95FFC1AE9DFFC0B1A1FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF0B305EFF338CF1FF081938FF4DA6F5FF7DD1FCFF000302FF63A5BEFF7FD2
      FCFF7FD2FCFF80D2FCFF83D6FFFF000203FF70C5F8FF3E91EBFF041121FF348B
      F2FF062B5EFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAFAF9FFFBF9F9FFF8FAF9FFF8FA
      F8FFFCF8FAFF73431EFF38271EFFCAC3BAFFEAE6E3FFF2F3F0FFE6E0DEFFB8AA
      9FFFCAA97DFF4574DBFF96ABCEFFA4B6D2FF577399FFA4BAD3FF9DB0D0FFCBBE
      A2FF06024AFF203252FF65A4F1FF0B0F15FF101623FF05050EFFF4F4EDFF7041
      1EFFFCF9FAFFF8FAF7FFFAF9FAFFF9F9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF87A6C0FF2A8DD5FFB9E1F7FFCAEDFEFF59C3FAFF58BDF3FFC8EBF8FFBDE6
      F7FFB8E4F7FFB5E2F6FFB0DFF4FFACDEF3FFACE0F6FF4B7A93FF5AC0F7FF59BD
      F6FF57BCF6FF58BBF4FF57B9F3FF54B7F3FF67C7F7FF2C72B4FF2268B2FF2269
      B4FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF624E39FFFEFE
      FEFFFEFEFEFFFDFDFDFFFCFCFCFFFBFBFAFFFAF9F8FFF9F9F7FFF8F7F5FFF7F5
      F4FFF5F3F1FFF3F1EFFFF2F0EDFFF0EDEAFFEFECE8FFEEEBE7FFEDEAE5FFEBE7
      E2FFADA093FFF7F5F4FFF0EDEAFFF0EDEAFFF0EDE9FFEEEBE8FFEEEAE7FFEBE7
      E2FFEBE8E4FFD9D2CBFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFFFF05142EFF0B1D42FF4EABF6FF80D3FDFF487082FF80D4FCFF80D2
      FCFF80D2FCFF80D2FCFF7FD2FCFF111F25FF73C7F9FF4091EBFF07162EFF0210
      28FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF9FAF8FFFBF9FAFFF9FAF9FFF6FB
      F7FFFCF8FAFFFDFAFAFFF1C488FFE7E8E6FFF9F7F8FFB0AB9AFFF1EEEEFF6A5A
      41FFE6D5B9FF050106FF786E71FFE6E4E1FFCECDD3FF675C47FF371E12FFB89E
      83FFEEE9E8FF253C65FF23335FFF1C2F57FF2C4B82FF20305CFFF5D097FFF9FA
      FAFFFBF9FAFFF9FAF9FFF9F9F9FFF9F9F8FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFFFF2C75B1FF5CBFF8FF5BC0F8FF59BEF6FF58BCF6FF54BCF5FF50B8
      F2FFAFDFF5FFAADCF2FFA8DAF2FFA5DAF2FFA1D9F2FF9FD7F0FF9AD7F1FF4172
      8FFF53B9F5FF52B6F3FF53B5F2FF53B5F1FF52B5F2FF4DB1EFFF56B8F3FF3081
      C6FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF64503CFFFEFE
      FEFFFEFEFEFFFEFEFEFFFDFDFDFFFCFCFCFFFBFBFAFFFAF9F8FFF9F8F7FFF8F7
      F6FFF7F5F4FFF6F4F2FFF4F2F0FFF3F1EEFFF1EEEAFFEFEDEAFFEFECE8FFEDEA
      E5FFAC9F93FFFEFEFDFFEEEAE5FFEBE7E2FFE8E5DEFFE7E2DBFFE7E1D9FFE9E5
      DEFF917E70FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFFFF11254EFF102149FF5AB3F7FF82D3FCFF82D3FDFF81D2FDFF80D2
      FDFF80D1FCFF80D1FCFF7ED0FCFF7BCEFCFF76CAFAFF3D8FEAFF0F1E3BFF1423
      4AFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAFAF9FFFAFAF9FFFAF8F9FFF7FB
      F8FFFBF9FAFFFAFAF9FF734723FFE9CB95FF907267FFEEEDEBFFF6F8F9FFDFD2
      C6FFF9F5EEFF492D1AFF624329FF362614FF0F2049FF060406FF7E6348FF1206
      02FFFAF6F6FFB69E82FFFEFDFBFF2E3D60FFF8F7F9FFF1DFB8FF764524FFF9FA
      F9FFFBF9FAFFF9F9F9FFF8F9F8FFF9F9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFF2F5F9FF307AB4FF54B8F3FF52B7F3FF51B7F3FF50B7
      F2FF4FB7F2FF4DB6F2FF9ED7F0FF9ED6F1FF9DD6F1FF9AD5F0FF94D2EEFF92D0
      EDFF8FD0EEFF427491FF4FB2F0FF4DB1EFFF4DB1F0FF4DB0F0FF49AAECFF1D57
      97FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF63503DFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFDFDFDFFFCFCFCFFFBFBFAFFFAF9F8FFF9F8
      F7FFF8F6F5FFF7F5F4FFF5F4F2FFF4F2F0FFF3F0EEFFF1EFEBFFF0EDEAFFEFEB
      E7FFB3A79CFFFEFEFEFFEFECE7FFECE8E3FFE9E5DFFFE8E3DDFFEDEAE6FF7A66
      57FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFF1F2F3FF162A5AFF142A5AFF5AB3F6FF80D3FCFF80D3FDFF80D2FCFF81D2
      FCFF7ACFFBFF7FD0FAFF7DD0FBFF7BCFFAFF3F96E7FF2D7EE1FF172C58FF1123
      4EFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBF9F9FFF9FAF9FFFAF9FAFFF8FA
      F9FFF9FAF9FFF9FAF9FFF9F8F9FFEFD3A8FFEFD1A5FFA48768FFF5EAD8FFDED3
      C0FFF7F0E5FF331E16FFA09488FFCCC5BEFFF1F0F1FFD2CECCFFAC9F97FF593E
      27FFFDF8F5FFBBAC94FFFAF6E4FFA48869FFF7E2C9FFF7EED5FFF9F8F9FFFAF9
      F9FFF9FAFAFFF8FAF9FFF9F8F9FFF9F9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF8EABCBFF2E76B2FF4BB1F0FF4BB2
      F0FF4CB3F0FF4CB3F1FF4DB4F1FF4BB3F2FF8AC7E2FF95D1EFFF90CFEEFF8ECE
      EDFF8BCDEDFF89CAEBFF8CCEEBFF609CC5FF184C8EFFECF2F7FFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF675544FFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFCFCFCFFFBFBFAFFFBF9
      F9FFF9F8F7FFF8F7F5FFF8F6F5FFF6F4F3FFF5F2F0FFF3F1EFFFF2F0ECFFF0EE
      E9FFD1CBC4FFFEFEFEFFF0EEEBFFEDEAE5FFEAE6E1FFF1EDEAFF645144FFFFFF
      FFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFC4C8CCFF152B5AFF1C3E7AFF020A18FF6DCDFFFF1E548DFF010916FF010B
      1AFF020E20FF4399EBFF3890E7FF225EA2FF020B1CFF112959FF18336EFF1226
      52FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFAF9FFF9FAF9FFFAF9F9FFF9FA
      F8FFF9F9F9FFF8FAF9FFFAF9F9FFFCFAFCFFECDBBAFFF1D7B3FFEFDCBAFFBCA5
      92FFF6EBD9FFF5F3EFFF351E13FF7A6854FF806B5FFF6F5F48FF644A36FF6047
      2EFFFCF7EDFFF6F5E9FFA68F73FFF8EFDEFFF5EDD9FFFBFCFDFFFAF9F9FFF9FA
      F9FFF9F9F9FFF9F9F9FFFAF9F9FFF9F9F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFAEC4DDFF266D
      ACFF48ADEDFF49AEEEFF48AFEFFF49AFEEFF4AAFEEFF47ADEEFF65AED7FF8CCC
      EBFF7BBCDFFF1D5892FFFAFBFDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF685543FFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFDFDFDFFFCFDFCFFFBFB
      FAFFFAFAF9FFF9F8F8FFF9F8F6FFF8F6F5FFF6F4F3FFF5F3F1FFF4F2EFFFF2F0
      ECFFF0EEECFFFEFEFEFFF2F0EDFFEFECE8FFF9F7F6FF8A796BFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFFFF10254EFF254E98FF162D69FF020C20FF152C61FF173065FF162E
      62FF172C5BFF192E5EFF193060FF172F62FF172F62FF162F63FF162F64FF0B1C
      3FFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFAF9FFF9FAF9FFFAF9FAFFF9FA
      F9FFF9FAF9FFF9F9F9FFF9F9F9FFF9FAF9FFFDFBFEFFF7F4E8FFF0D8B5FFDDD2
      C2FFCFB9A3FFF4ECDAFF4E3828FF8C7B6AFF95877CFF817361FF6B513EFFF7F4
      F7FFF7EDD9FFF5E6CEFFF5E3CBFFF3F3ECFFFCFAFDFFF8FAF8FFFBF9F9FFF8FA
      F8FFFAFAF9FFF9FAF9FFF9F9FAFFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFD8E3EDFF2767A4FF48ACEDFF48ACEDFF48ACEDFF3C99DCFF245CA2FFF1F4
      F9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF6D5744FFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFDFDFDFFFCFC
      FCFFFBFBFAFFFBFAF9FFFAF8F7FFF8F7F5FFF7F5F4FFF6F4F2FFF6F3F1FFF4F2
      EFFFF6F4F2FFFEFEFEFFF3F1EFFFF5F3F1FF9F938AFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFF0C182AFF173269FF1A356FFF0A1A3CFF305BA4FF2D579FFF2D57
      A0FF183267FF192F61FF193062FF183063FF172F63FF162E62FF0A193AFF050E
      20FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFAF9FFF9FAF9FFFBF9FAFFF8FA
      F8FFFBF9FAFFFAF9F8FFF9FBF9FFFAFAF9FFFAFAF9FFF8F9F8FF8C5B34FFFAF8
      F1FFF4DBB9FFF3DDC0FFF6E5CBFFFCFBFAFFF3F2F4FFF6F6F6FFF7E7D0FFF6E4
      CBFFF4E1C8FFFAF9FAFF935736FFF8FAF8FFFAFAF9FFFAFAF9FFF9FAF9FFF9FA
      F8FFFAFAF9FFFBF9F9FFF9FAF8FFFAFAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFF7599C0FF2160A0FFA6BDD6FFFFFFFFFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF6A5644FFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFDFDFDFFFCFCFBFFFBFAF9FFF9F8F7FFF9F7F6FFF8F6F5FFF7F5F3FFF7F4
      F3FFFDFDFBFFFEFEFEFFF1EEECFFDAD6D1FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFDDE2E5FF17336EFF142D5DFF2D56A0FF2A539AFF1F42
      80FF12264EFF224585FF234A8EFF1D3E79FF081839FF10234AFF5F6878FFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBF9F9FFF9FAF9FFFAF9F9FFFAF8
      F9FFF9F8F9FFF9F9F8FFFBF9F9FFF9FAF8FFFAFAF9FFF9FAF9FFFAF9F9FFFCFB
      FCFF8D5E37FFF9F5F3FFFDF8F8FFF0DAB9FFF1DBBBFFF1DBB9FFFDF9FBFFF7F7
      F6FF925C38FFF8FEFBFFFBF9F9FFF9FAF9FFF9FAF8FFFAF9F8FFF9F9F9FFF8FA
      F8FFFBF9F9FFF9FAF9FFFAFAF9FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF948478FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFB6ACA7FFF2F0EFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFF09162CFF142C62FF1B3771FF295096FF274F
      96FF274F97FF294F93FF214786FF244991FF13275AFF000824FFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAF9F9FFFAF9F9FFF8FBF8FFFAF8
      F9FFF9F9F9FFF7FAF8FFFAF8FAFFF8FAF9FFFBF9FAFFF9FAF9FFF9F9FAFFF9FA
      F9FFFAF9FAFFF8FAF9FFFCF9FBFFF6F7F7FFF8F7FAFFF4F8F6FFFCFBFAFFF9FA
      F9FFFBF9FAFFF8FAF8FFFBF9F9FFF9FAF9FFFBF9F9FFF9FAF8FFFAF9F9FFF9FA
      F8FFFAF9F9FFF9FAF9FFFAFAF9FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFEFEFEFFFEFE
      FEFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFEFEFFFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF7E8692FF0C1A3AFF162E61FF132C
      5EFF122B5AFF152C5CFF122A5BFF0B1E45FF2B3547FFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBF9F9FFFAFAF9FFFAFAF9FFF9FA
      F9FFFAF8F9FFF9FAF9FFF9FAF9FFFBF9FAFFFAF9F9FFF8FAF9FFFBF9F9FFF9FA
      F9FFFAF9F9FFF8FAF9FFF9FAF9FFF9F9FAFFFBF9F9FFF7FAF8FFFAF9F9FFF9FA
      F9FFFAF9FAFFFAFAF9FFFAFAFAFFF9FAF9FFFAF9F9FFF9FAF9FFFAF9F9FFFAFA
      F9FFFAFAF9FFFAFAF9FFFAFAF9FFF9FAF9FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFF
      FFFFF7F8F8FFFDFDFCFFFFFFFFFFFEFEFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFBFAF9FFFAFAF9FFF9FAF9FFFAF9
      F9FFF9FAF9FFF9FAF9FFF8FAF9FFFBF9FAFFFAF9FAFFF8FAF9FFFAFAF9FFFAFA
      F9FFF9F9F9FFF9FAF9FFFAFAF9FFFAFAF9FFFAF8F9FFF9FAF9FFFBF9F9FFF9FA
      F9FFF9F9F9FFFAF9F9FFFAF9FAFFF9FAF9FFFAFAF9FFFAFAF9FFFAFAF9FFECF3
      FCFF737C8BFFE8F1FAFFEFF4FDFF2E3B4CFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFAFAF6FFFAF9F9FFFBF9F9FFF8FA
      F9FFFCF8F9FFFAFAF9FFF5F9F8FFF8F9F8FFFCF7FAFFF6FBF8FFFBF8F9FFFAFA
      F9FFFAF9F8FFF5FBF8FFFCF7FAFFF6FAF8FFFCF9FAFFF6FBF9FFFDF8FAFFF2FB
      F7FFFBF9FAFFF7FAF9FFFBF9FAFFF6FBF9FFFBF9F9FFFAFAF9FFF8FAF9FFF9FA
      F9FFFAF9F9FFFAF9F9FFFAF8F9FFFAFAF8FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFBFCFFFCFBFCFFFCFBFCFFFCFB
      FCFFFCFBFCFFFCFBFCFFFCFBFCFFFCFCFCFFFCFBFCFFFBFBFCFFFBFAFBFFFBFA
      FBFFFAFAFAFFFAF9FAFFFAF9FAFFFAF9F9FFFAF9FAFFF9F9FAFFFAF9FAFFFAF9
      FAFFFAFAFBFFFBFAFBFFFBFBFCFFFBFBFCFFFBFBFCFFFCFBFCFFFCFBFCFFFCFB
      FCFFFBFBFCFFFCFBFCFFFCFCFCFFFCFBFCFFFCFCFCFFFCFBFCFFFCFBFBFFFCFC
      FBFFFCFBFCFFFCFCFBFFFCFCFCFFFCFCFCFFFCFCFCFFFBFBFBFFFAF9F9FFF9F8
      F8FFF8F7F6FFF7F6F6FFF7F6F6FFF8F6F5FFF8F6F6FFF7F6F5FFF8F6F6FFF8F7
      F7FFF9F8F8FFFAF9FAFFFBFBFBFFFCFCFCFFFCFCFBFFFCFCFCFFFCFCFCFFFCFC
      FCFFFCFCFCFFFCFCFBFFFCFCFCFFFCFCFBFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC8CDC9FFACB3ADFFADB3AEFFB7BDB8FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F8F7FFFCF9F8FFFBF9F9FFFBF9
      F9FFFBFAF8FFFBF9F8FFFBF9F7FFF9F7F6FFF4F1F0FFEFEAE8FFEBE7E3FFF2E7
      E0FFAF9683FFB19785FF998578FFDFD4CCFFE7DDD4FFBAABA2FFB29786FFB296
      83FFDACBC0FFEAE5E1FFEFEAE6FFF3EFEDFFF4F2F0FFFAF9F8FFFBF9F8FFFBF9
      F9FFF8F6F4FFFBF9F8FFFCFAFAFFFCF9F8FFFBF8F7FFF9F7F6FFF8F5F4FFFBF8
      F6FFF8F5F3FFFBF9F6FFF9F7F7FFF8F5F5FFF0EDECFFECE4E1FFE4DED9FFA081
      6AFF9F7F6BFFFEFEFCFFFEFEFFFFFEFDFEFFFDFDFDFFFBFEFDFFFEFBF4FFA180
      6AFF907665FFE7DEDDFFE9E6E2FFF2EFEDFFF8F5F4FFFAF8F7FFFBF9F7FFFAF8
      F7FFFBF9F7FFFCF9F8FFFCF9F7FFFBF8F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF021202FF011B01FF01480FFF01BD67FF01BC66FF012401FF021B02FF9DAB
      A0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F5F1FFFAF8F4FFF9F8F4FFFAF8
      F5FFFAF8F5FFF8F5F4FFF1ECEBFFE7DEDAFFDCD2CDFF764928FFA68C78FFFFFF
      FFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFBF3FF794829FFDDD2CCFFE4DCD5FFEEE9E4FFFAF6F3FFFBF8
      F7FFF7F4F1FFF9F7F4FFFBF8F6FFFCF8F5FFFAF7F3FFF7F4F0FFF5F3EFFFFAF7
      F3FFF5F2EFFFFAF6F5FFF2EDEAFFE6DCD8FFD9CFCBFF6D3B13FFFDFDFFFFFDFD
      FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFF7FF6D3B15FFDDD3CAFFE8E0DBFFF8F2F1FFFBF7F6FFF9F6
      F3FFFAF7F3FFF9F6F3FFFBF8F4FFFAF7F3FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF190B
      02FF221101FF251301FF261301FF261301FF271401FF271402FF281503FF2612
      00FF2B1702FF291503FF261402FF241302FF1E0F01FF1C0D01FF150B01FF010D
      00FF011C09FF01AA59FF017B31FF025812FF01520FFF016A22FF01AB5AFF011F
      01FF1A2C1BFFFFFFFFFFFFFFFFFFFFFFFFFFF8F3F0FFF9F6F3FFFBF8F4FFFAF7
      F4FFF7F5F1FFEDE8E4FFE1DAD2FF54280BFFFDF4E5FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFBFF6A3815FFE2DED1FFE8E4DFFFF6F2
      EFFFF4F1EFFFFAF7F3FFFCF7F4FFFCF7F4FFFAF7F3FFF8F3F0FFF6F1EEFFFAF7
      F3FFF4F1EEFFF3EEEBFFE3D9D5FF64381DFFFCF7E9FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF583522FFE4D2CAFFE8DDD6FFF5F0EFFFFAF6
      F5FFFAF7F3FFFCF7F4FFFBF8F4FFFAF7F3FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF1A09
      01FF442E1DFF685240FF553E2CFF553E2BFF543F2BFF553E2CFF69503FFF2A15
      05FF5A4128FFAE9885FF180700FF1E0C01FF1A0901FF0F0501FF111005FF0108
      01FF017127FF006418FF01450AFF020C02FF021002FF003404FF016C1EFF01B5
      62FF011C01FFDEE3E0FFFFFFFFFFFFFFFFFFF2EEEAFFF6F1EDFFF4F0EDFFF1EE
      ECFFEAE3E2FFDBD6CFFF6F3B17FFFCFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF5A3017FFDDD0CCFFE8E1
      DCFFEFE9E8FFF4F1EDFFF4F1EDFFF5F0EDFFF9F7F3FFF5F2EFFFF4F1EEFFF9F5
      F4FFF1EBEAFFE4DBD7FF6A3819FFFDFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFEFE
      FFFFDBCFC7FFFFFEFEFFFFFFFFFFFEFFFFFFD9D1C7FFFFFEFFFFFFFFFFFFFFFE
      FCFFE6E0DEFFFCFEFFFFFFFFFFFFFFFFFFFFFBFDFFFF5B3116FFE3DEDAFFF6F2
      F0FFFBF7F6FFFAF5F2FFFCF7F4FFF9F6F2FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF1808
      01FF4A3421FF755D4CFF5C4430FF5B432FFF5B4430FF5D4430FF79614DFF301B
      09FF61452BFFB19C88FF1B0A01FF3E281AFF211001FF251304FF011401FF01A7
      57FF016E1FFF017523FF01480DFFCBF6DCFFCAF5DBFF013506FF017C27FF0172
      21FF01BD69FF012001FFFFFFFFFFFFFFFFFFF7F4F1FFF9F6F3FFF9F7F3FFEEE8
      E3FFDAD4CDFF643717FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFECD6C8FFEBD7
      CAFFE7E2DFFFF7F4F1FFFBF8F4FFFCF7F4FFFAF7F3FFF9F4F1FFF4F0EFFFF6F2
      F1FFE2DED7FF663919FFFAFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFBFFF0E3
      CEFFEBDDC8FFDAD4C7FFFFFDFFFFFFE7D0FFF0E1CAFFDAD1C7FFFFFAF7FFD6A1
      69FFBF8953FFE0D7D2FFFFFFFFFFFFFFFFFFFFFFFFFFFAFEFCFFE0C6B8FFE9E4
      DFFFF8F4F4FFFCF8F4FFFBF8F4FFFAF7F3FFFEFEFEFFFEFEFEFFFEFEFEFFFDFD
      FEFFFCFCFCFFFCFCFCFFFCFCFCFFFBFCFCFFFCFCFCFFFCFCFCFFFCFDFDFFFCFD
      FDFFFCFCFCFFFCFCFCFFFCFCFCFFFCFCFCFFFCFCFBFFFCFCFBFFFBFCFBFFFCFB
      FBFFFCFCFCFFFCFCFCFFFDFDFCFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF1D0B
      01FF553923FF856B53FF866B52FF8B6F56FF8A6F56FF876B54FF886E55FF321B
      05FF6A4A2CFFB39D88FF1E0B01FF4B3626FF291402FF311B05FF011F02FF0177
      26FF007220FF017324FF00480DFFD8F9E5FFD6F9E5FF013507FF007724FF0074
      20FF00A651FF012401FFFFFFFFFFFFFFFFFFFAF6F1FFFCF6F5FFF4EFEEFFE2D7
      D0FF753C19FFFFFEFFFFFEFEFEFFFFFFFFFFE2D7CFFFE2D7CFFFE0D7CFFFE4D7
      CFFFE2D7CFFFE2D7CFFFE2D7CFFFDFD8CFFFE2D7CFFFE2D7CFFFDFD7D1FFE2D6
      D1FFDFD7D1FFE2D6D1FFDFD7CFFFE1D8D0FFE1D6D1FFD9D3CFFFFEFEFFFFFAE4
      DAFFDDD4CCFFF2EAE7FFFBF7F6FFFDF8F7FFFAF7F3FFF9F5F3FFF5EFEFFFEDE5
      E4FFB99A88FFFAFFFDFFFFFFFFFFFEFEFEFFFFFBF9FF633815FFFFFDFEFF9D78
      61FF754019FFDCC3AFFF76563EFFB29577FF784C37FFD9D1C5FF713B14FFE3D6
      C3FFDAAC73FFFFFFF9FF713A1EFFFFFFFBFFFFFFFFFFFEFEFEFFFEF2EEFFDFD8
      D2FFEEEBE8FFFAF6F5FFFCF8F6FFFAF8F4FFFEFEFEFFF5F4F3FF341500FF3B16
      00FF441C00FF491F02FF421A01FF4E2301FF311702FF5A3B0DFF64400FFF431B
      00FF3D1802FF471F02FF361601FF321100FF010578FF000674FF000576FF0004
      76FF000270FF000270FF000267FF000259FF524B4FFFD5CDC9FFDFDCDAFFDFDC
      D9FFE1DEDDFFF0EEEEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF1F0E
      03FFAC8259FFE5DBCEFFF1EFE6FFF1EFE7FFF0EFE6FFF0EFE7FFF5F3EAFF8E49
      0AFFEDA552FF9E866FFF1B0B01FF3F2919FF231001FF2A1601FF01A35AFF007F
      29FFE0FBECFFDFFCEAFFDFFBEBFFE2FCECFFE0FCECFFDFFCECFFDBFBE9FF031F
      03FF01852CFF002301FFFFFFFFFFFFFFFFFFF8F4F3FFF5F2EFFFE7E2DBFF6C37
      15FFFFFFFFFFFFFFFFFFFFFFFFFF6B3916FF6B3713FF703B16FF6F3A15FF6C3A
      15FF703B16FF6D3B16FF6C3A15FF6E3915FF6E3915FF6F3A15FF6F3A15FF7039
      15FF6F3A15FF6E3915FF6E3915FF6F3A15FF693A15FFE2DED4FFDED7D5FFFEFE
      FEFF593218FFE2DAD6FFF4F1EEFFFAF7F4FFFAF7F3FFF7F4F2FFEEEAE9FFDFD7
      D6FFC9B4A4FFFFFFFFFFFFFFFFFFFFFFFEFFFFFFF5FFFFFFFFFFFFFFFCFF6935
      0DFF906E4AFFFEFFFDFFFAFEFFFF8D6847FF673617FFFFFFFCFFFDFFFFFF572A
      01FF64321BFFFFFFFDFFFFFFFFFF583014FFFEFDFFFFFFFFFFFFFFFEFFFF6B39
      1EFFE6DEDBFFF6F3F1FFFCF8F7FFFBF7F6FFFEFEFEFFFEFDFEFF893301FFA949
      01FFB55412FFB35516FFA23B01FF792A06FF956D29FFFDDA86FFFDD678FFA54C
      12FFE4780AFFAC4D10FF5F2302FF8B3400FF0A20CBFF152EDBFF162EDBFF1830
      D8FF172FD5FF172FD0FF020B8EFF010EACFF4A3524FF83490DFF804810FF7F47
      12FF7F4712FF824812FFD5CDC8FFF6F6F5FFFFFFFFFFFFFFFFFFFFFFFFFF1E0E
      01FFA36F3CFFCFB89FFFD6C5AEFFD9CAB5FFDACCB8FFD8C7B2FFDBCFBCFF8D48
      08FFDF9C4DFF75593CFF1D0C01FF1D0D03FF180A01FF241201FF01BC69FF008D
      31FFEBFEF4FFEBFFF3FFE9FDF2FFEBFFF4FFEBFEF3FFE9FDF2FFE7FEF2FF0220
      03FF019035FF002504FFFFFFFFFFFFFFFFFFF9F3F2FFF0EBE9FFEAD6C4FFFEFD
      FEFFFFFFFFFFFFFFFFFF693616FF9F5722FF9F5520FF97542AFF9A5320FF9256
      27FFA05920FF8C5529FF9E5620FF9E5620FF9E5620FF9E5620FF9E5620FFA055
      21FF9D5420FF9E5522FF9E571EFF9C571FFFA35520FF673717FFDFD7D1FFFFFF
      FFFFFFFFFFFF623717FFEFE5E0FFFAF5F2FFF3F0EEFFF2EEEDFFE3DFE0FF663A
      18FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFDFFFFFFFFFFFFFFFFFFFFFFFE
      FFFFFFFFFFFFD4D1C6FFD9D1CAFFDACFCBFFF0EDEAFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF714E3CFFFFFFFEFFFFFFFFFFFFFFFFFFFDFF
      FEFF532813FFEBE5E4FFF4F1EFFFF3F0EFFFFEFEFEFFFFFFFFFF973F06FF7836
      06FFC66928FFCC6F2DFFFB8002FFC35810FFFFE39FFFFDE7A7FFFEE8A4FFAB5E
      2CFFD6741AFFBB5B1DFF943D09FFA03D02FF1D39E9FF233FF2FF1729CCFF243F
      E9FF203ADFFF1D38DAFF0616BCFF0C22CBFF723E0DFF7B3E12FF793E15FF7A3F
      17FF7C4219FF905220FFE1DAD4FFF7F6F6FFFFFFFFFFFFFFFFFFFFFFFFFF1F0F
      02FFCA8A45FFEDDFCEFFAF6013FFBF731BFFF8F8F1FFCE7E23FFFAF9F3FF964D
      0AFFAA7435FFA18568FFEBE5DCFFEBE7DDFFEAE3DAFFE5D9CAFF09B782FF019B
      3EFFA0BEA6FF9CBAA1FFA0BAA3FFF3FEF7FFF2FEF7FF9EB8A1FF9BB7A1FF0037
      00FF009E40FF013401FFFFFFFFFFFFFFFFFFF7F4F0FFE7E1DCFF6C3A17FFFFFD
      FFFFFFFFFFFFFFFFFFFF6E3B15FF9B5421FF9E5925FFFFF4E5FFA25522FFFFFF
      F9FF99571EFFFFFFF3FF9E5620FF9E5620FF9E5620FF9E5620FF9E5620FF9E56
      20FF9D5621FF9E5721FF9E571EFF9F5A21FF9B5520FF6D3913FFDFD7D3FFFFFF
      FFFFFFFFFFFFFCEBDEFFE6DDD8FFF6F0EFFFFBF7F6FFF6F2F1FFE1DBD6FFFFFF
      FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFEFEFFFFFFFFFFFFFEFFFF6F3F
      17FF9D6429FFE6A055FFE6A153FFCD8A51FF713F1AFFE4D6C9FFDAD2CCFFDAD0
      CAFFDBD3CAFFDBD3CAFFDBD3CAFFE0CFC5FFD7D3CCFFDBD0C7FFFFFFFFFFFFFF
      FEFF5F3720FFE7E0DDFFFAF6F5FFFBF7F6FFFEFEFEFFFEFEFEFFB5500EFFEB83
      2CFFDC7B39FFB74700FF954318FF300E01FFFEEDB5FFFCE8ADFFFFE79DFF824F
      28FF9A572BFFC66625FFD46B22FFA74301FF060B72FF93DBFFFF8AD4FDFF4064
      A0FF2440E6FF203DDFFF162DD8FF213AE2FF814317FF87461AFF88471DFF8848
      1FFF884820FF9F5F2FFFEBE6E1FFFBFBFAFFFFFFFFFFFFFFFFFFFFFFFFFF2211
      02FFD1904BFFF0E1D2FFB46618FFCB8530FFFBFAF4FFF2B558FFFCFBF6FF9C50
      0BFFC88F47FFA97239FFA57139FFA56F37FFA5723AFFA17039FF01440CFF01A6
      49FF00A745FF00A746FF007120FFF7FFF9FFF4FFF8FF004A0AFF01A445FF00A2
      44FF0AE599FF013001FFFFFFFFFFFFFFFFFFF3EEEBFFEED9C8FFFFFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFF6D3713FF6D3B12FF6C3912FF6D3912FF6E3A14FF6D39
      13FF6D3A11FF6F3B14FF6D3912FF6E3A13FF6E3B13FF6D3A12FF6F3B13FF6E3A
      14FF6F3B13FF6E3A14FF6D3912FF6E3A13FF703A15FF6B340BFFDFD7D4FFFFFF
      FFFFFFFFFFFFFFFFFFFF673916FFEEEBE3FFFBF7F6FFF4EDECFF572F0FFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFDFFFFFFFEFFFFE8A249FFE8A8
      4DFFE8A94CFFEAA24AFFE79E4AFFE2984AFFA5642EFFA6632FFF664220FFF4E0
      CEFFF5E1CEFFF8E1CAFFF6E0D0FFFBE5CCFFF3DEC6FFDED1C6FFFFFFFFFFFFFF
      FFFFFEFEFEFFEBE0D9FFF7F3F2FFFBF7F6FFFEFEFEFFFEFEFEFF8E4D23FFF89B
      53FFF28D41FFFFB645FF52230AFFFEF9E5FFCFA15CFF6E8DBCFFF2E6D1FFDDC6
      9FFFA8653DFFDC7F3EFFF9A65DFF2A0D3EFF84CFFCFF76C1F6FF6AB3F0FF6FB6
      F0FF2138D6FF2745E6FF4760FBFF000252FFA69D93FFBBB0A7FF8A4C22FF8C4D
      23FF8C4D23FFA26131FFF2EFEBFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF2512
      03FFD69753FFF1E3D3FFF9F6F0FFF9F5F0FFFBF9F2FFF9F6EFFFFDFCF7FF9F53
      0FFFFAC275FFFBC577FFFCC477FFFCC579FFFCC679FFFDC577FF032F01FF14F7
      B1FF01B24FFF01AF4CFF007922FFFBFFFBFFFAFFFBFF004E0AFF01AE4CFF00A7
      47FF055027FF012E02FFFFFFFFFFFFFFFFFFEDE6E4FF6B3B14FFFDFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFF6D3B17FFFFFEFDFFFFF6EDFFFFF6F0FFFFF6EEFFFFF6
      EEFFFFF5EFFFFFF7EEFFFFF5EFFFFFF7EFFFFFF7EBFFFFF5EEFFFEF5EEFFFFF6
      EEFFFFF7F0FFFFF7EFFFFFF7F0FFFDF5EBFFFDFEFEFF753F1BFFDFD8D4FFFFFF
      FFFFFFFFFFFFFFFFFFFF4F280DFFE7E5DFFFFBF7F6FFEFE7E4FF683717FFFEFE
      FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFDFFFFFBFFFDFFE69F4BFFE8A7
      55FF80460BFF7C421AFF78411BFF7E4213FF9D5C2EFFA8612FFF703E14FFCA8F
      55FFBD804DFFFFEFD6FF543214FF6C3A18FFF6E1D0FFF0DDCEFFFFFFFFFFFFFF
      FFFFFFFEFFFF663A1AFFF4EEEDFFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFF8F79
      68FFAA5E31FFDE7534FFFFE9A5FFFFFBE6FFB48C4CFF2E8CE4FFE3D3B3FFFDF3
      DFFFF6B06FFF5F2C0EFF022265FF03035CFF599FE3FF5499E2FF5499E2FF589D
      E4FF0A1493FF001D7AFF1682C4FFAA580DFFC5BDB8FFC8C2BAFF955526FF9454
      26FF935427FF935325FF2D1500FFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF2813
      03FFC4833EFFE2CEB8FFE4D7C4FFE4D6C3FFE3D6C4FFE3D5C0FFE5DAC9FF9F53
      0EFFFCC77EFFAF6E33FFB37133FFFAD18CFFCB955AFFB47033FFEAB66DFF013C
      01FF25FCC5FF01B551FF01A745FF015808FF015E09FF01AA49FF00AD4BFF1DE7
      A9FF002A00FF01621EFF617461FFFFFFFFFFECE5E2FF5E3C20FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFA79080FFFCFEFFFF653615FFFFFFFEFFF1EAE1FF9475
      5DFF6D381AFF6F3C1CFF703D1CFF6D3A19FF6A3719FF6E3A1BFF6F3B1AFF6C39
      1BFF6A3618FFF1EAE1FFF5E9E4FF603D20FFFEFEFEFF713B15FFFFFEFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFEFFFAFFE6DDDAFFFBF7F6FFE6E2DDFFF4E8DCFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFAFDFDFF7D5F46FF70421BFF713E
      15FF925C2BFFB77938FFB47331FFFFE6D2FFA66835FFAD6C38FF6B3715FF7140
      1EFF74431CFF72431EFF72421DFF754723FFC4A486FFEEDCCEFFFFFFFFFFFFFF
      FFFFFFFFFEFF6D391CFFF0EBE7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFDFEFEFFF8D688FF2C78C5FF0D53B0FF0B499FFF1B6CD4FFDBB5
      69FF623008FF102D3FFF29A4D9FF014E98FF18599EFF3A79D5FF3573D1FF2666
      B9FF004580FF0265ADFF4ACCFBFF564120FF7E7367FF86786AFFA2582CFFA157
      2CFFA0572BFFA25729FF2D1600FFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF2512
      02FFDA9750FFF3E4D4FFB56616FFC3771FFFFCFBF5FFD08125FFFEFCF6FF9F56
      0EFFFCCB85FFA55F14FFD38125FFFDD490FFC08E4DFFD07F24FFE3B471FFFAC5
      79FF014401FF33F7D0FF30F0BCFF19C987FF19CB89FF2EFEC8FF109A68FF0033
      00FF01AB57FF018835FF637363FFFFFFFFFFE7E0DDFFFFFFFDFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFEFEFEFF947A6BFFFFFFFCFFF1E8DEFFF3EEEAFF703A
      1AFFFEFFFFFFFFFFFFFFFFFEFFFFFFFDFFFFFFFFFFFFFFFCFFFF6B3A1AFFFBFF
      FDFF5D351AFFF2E9E0FFF3E9E2FF552C0EFFFDFEFEFFE5D6CDFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF998070FFF9F5F4FFE9E2DEFFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFCFFFEFF653918FFF7E0CCFFEDDED0FFF9F1EAFFF2EA
      DDFFEBDDCBFFF5DDC8FFF6DEC8FFF2E0C9FF825F44FFAA6B31FF683A10FFEDC7
      9DFF784921FF73461FFFF3E5D0FF623510FF4C2104FFF0DCCCFFFFFFFFFFFFFF
      FFFFFFFFFFFFEADAD0FFEEE9E8FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFF113064FF3797EEFF44A2EFFF4CA7ECFF3898EBFF042E
      7DFFB15720FFAF541FFF2BA8E1FF01549FFF094691FF5AA5E9FF66B3F2FF0745
      97FF004782FF0156A0FF012E5FFFA95324FFA55329FFA6562CFFA8592FFFA759
      2EFFA7592DFFA95A2AFF291400FFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF2A16
      04FFDB9A53FFF4E7D6FFB86A19FFCE8732FFFEFDF6FFF7BC60FFFEFCF7FFA45A
      0FFFFED190FFA86016FFF6BF6EFFFED797FFBF8D50FFF6C274FFE4BA7BFFFCCA
      85FFD0791CFF634B09FF004400FF014101FF013701FF013101FF016B24FF01CE
      8FFF01CF91FF01903BFF627262FFFFFFFFFFEDE1D9FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF713B17FFFFFEFEFF7D523CFFF4EAE3FFFDF1
      DDFFFEFEFFFFFCF2E7FFFDF1E6FFF8EEE4FFFFFFFFFFFEFEFEFF563015FFFFFE
      FFFF673513FFF2E7E2FFEFECE3FFFDFCFDFF623519FFFAFAF7FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF683C16FFF9F5F4FFF0E4DBFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF622C13FFFFFDFFFFCDBCAEFF743E20FF70401DFF7643
      17FF6C3D16FFDDCCBFFFFFFDFFFFFDFEFFFFFFFFFAFF5F3613FF713E11FF6942
      24FF734425FF724023FF704220FF6E4020FFF5E4CAFFEDD6C5FFFFFFFEFFFFFF
      FFFFFFFFFFFFFFFFFDFFEEE8E7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFCFCFCFF3797EAFF43A0EDFF57B0F1FF5CB7F4FF53AEEFFF3996
      EAFF001E58FFAA4B0FFF219FDFFF004683FF5DAAEEFF85C7F6FF82C5FAFF6CB6
      EEFF014786FF005BAEFF273B4BFFAB5324FFA85428FFA8572BFFAA582DFFAA59
      2DFFA9592CFFAC5828FF2D1303FFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF2A15
      03FFDC9D57FFF3E6D5FFFBFBF9FFFCFDFAFFFEFCF6FFFCFDFBFFFEFEF7FFA65C
      12FFFED69AFFA45F17FFF8CA79FFFDDB9CFFBE8D55FFF8CB7AFFE4BB7FFFFCD0
      8FFFD17B1FFFA1540CFFEBA85AFFBD610EFF351A01FF01903EFF019E46FF01D5
      9BFF01D295FF012C01FFFFFFFFFFFFFFFFFFF8E7DDFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFEFFFF5D3016FFF7E9E1FFF7EB
      E6FFFFFEFEFFECE5DEFFEDE9DFFFE9E5DDFFECE9DFFFE9E7DFFFE9E9DCFFFDFF
      FDFFDECBB9FFFEFCFEFF673612FFFDFFFEFF50250DFFFFFEFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF6F3D1BFFF9F5F4FFFAE9E2FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF6D3C1EFFFDF4EBFFFFFFFFFFFFFEFFFFE5BA75FFECBF
      7DFFE5BA76FFE7BB7BFF6E3F17FFFFFEFCFF724110FFD18E3FFF6A380FFFB59A
      7CFFB99876FFF4E0C9FF956234FF79451AFF6F3D1BFFFFFBFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFEFFEEE8E7FFFAF6F5FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF082348FF0B2A60FF3E9AEBFF53ACEEFF64C0F7FF68BEF5FF60BAF0FF5BB3
      EFFF3994F2FF72777FFF0986CDFF5194EEFF7CC2F8FF578ED3FF5E98D8FF80C6
      F8FF4B8AE9FF015EB5FF0C3961FFD1A573FFD3A978FFDCB280FFE1B886FFDCAF
      7AFFD9A971FFDCAB74FF6A584DFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF391D
      05FF8C5724FFB89977FFBFA47EFFBEA37CFFBFA47EFFBEA37DFFBEA380FFAA5B
      10FFFEDCA8FFFEDEA8FFFEDDA7FFFEDDA9FFFEDCA5FFFDDCA4FFFDD9A2FFFCD8
      9FFFFCD396FFFCD396FFF2B56DFFC56712FF381E01FF01A34CFF01C883FF01AD
      55FF014508FFFFFFFFFFFFFFFFFFFFFFFFFFF5E6DEFFFEFEFEFFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF4E2712FF623114FFFAFEFFFF6E3916FF6A3B
      17FF613016FF503627FF622C14FF6A3611FFFEFEFEFFFEFEFEFFFFFFF8FFC2AA
      9BFF703B15FF6A3715FFD1C2B3FFFFFFFDFFE8E4E0FFFEFFFFFFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFEFEFEFF6C3D1BFFFAF6F5FFF6E8E2FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF6E3819FFAA693BFF543318FFFBFEFFFFE5B87AFF7542
      1BFFF6DDC3FFF4DECAFF75421FFFEFE0C9FF5F2E06FF7C3F0CFF704010FFFAEC
      DEFF5B2F15FFF5E2CDFF65371CFFF7DCB8FF5C2B08FFD4CBC6FFFEFFFFFFFFFF
      FFFFFFFFFFFFFFFEFDFFF2ECEBFFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FFFF358DE6FF368FEAFF49A3ECFF68BDF6FF70C5F9FF70C5F9FF6DC3F8FF64B9
      F3FF3791EFFF3D90EEFF0A73BBFF5698EDFF7EC8FBFF83CFFDFF80CFFDFF76C1
      F8FF4D8BEAFF0356AFFF02367CFFFFFFFFFFFFFFFFFFFFFFFFFF834B1AFFFEFE
      FFFFFEFEFFFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF3119
      06FFB09279FFEAE0D3FFF8F4E9FFF7F2E9FFF6F1E6FFF7F2E7FFFBF7ECFFAA5C
      11FFFEE3B5FFDFC09CFFE1C4A0FFFEEBC1FFEDD6B9FFE1C5A2FFF5E2C4FFFDDF
      AFFFE1C39EFFDEC099FFF9C47FFFCC6E15FF3C2004FF00D79AFF01D99EFF02D8
      9BFF013602FFFFFFFFFFFFFFFFFFFFFFFFFFEDEBE4FFFFFFFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF693C19FFFFFCF2FF6E3A16FFD18840FF6B3B
      19FF703814FFFFFFFDFFFFFEFDFFFFFEFEFFFFFEFCFFFFFFFBFF753D17FF6B3A
      18FF6A3914FF6F3B17FF6B3C1BFF572A10FFE0D8D2FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF7A5C43FFFBF8F6FFF1ECE8FFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFCFFC88743FFB27237FF9F6330FFF3DBC4FFF4DE
      C8FFF0DFC8FFF4DFCAFFF4DFCAFFF4DFC9FFDDB381FFDDB37EFF693915FFFEF6
      EEFFFFF5EEFFB29784FFFAFFFFFF75431EFFD7A56BFFF1DCCFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7C6B9FFF5F2EEFFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFA1AB
      B8FF328BE9FF0D2239FF58B0EFFF000100FF75CAFBFF74CAFAFF77D0FFFF0000
      00FF3894EDFF3F97F2FF0362ACFF6BB1F6FF000000FF81CFFDFF80CEFDFF0001
      04FF5DA1EFFF024EAAFF00357AFFDB8F4EFFD39154FFCC8546FF260A00FFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF3C24
      10FF4C3524FF534436FF54453AFF554538FF554538FF534336FF554535FFAE5F
      10FFFEE8BEFFAB661AFFD28227FFFEEBC2FFC29464FFD2832AFFE6C9A0FFFEE5
      B8FFD28126FFAE6415FFFBCF91FFD07217FF412507FF016317FF02C68BFF023C
      03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2EFECFF9A8274FFFEFFFDFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF67371CFF6D3B14FFCD872CFFCB7B30FF6E3C
      16FF703B16FF6E3C12FF703B12FF703B12FF703B12FF713C13FF713B15FF6F3A
      14FF6D3914FF6C3911FF9E5924FF7E4217FFE0D5D2FFFEFEFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFEFEFDFFEDE8E3FFFAF7F5FFF0ECE8FFF0E3D9FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFFFF7B4115FF9F6431FFF2DFCEFF9871
      52FF7A421BFF6E472AFF6A472BFF72371AFF744115FFDEB17EFF6E3D17FF6A3E
      1AFFE9C29AFFD8D1CBFFFFFFFDFF855E3DFF7B431AFFFEFEFFFFFFFFFFFFFFFF
      FFFFFEFFFEFF703D1CFFF6F2F1FFFAF7F5FFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FFFF041332FF050D1EFF61B8F4FF020302FF79CCFCFF78CCFBFF7DD8FFFF0002
      02FF3F9CEFFF020F29FF0368B8FF61A7F0FF000000FF82CEFCFF80CDFCFF0102
      04FF5B9FEDFF0453A7FF00346DFFFEFFFFFFFEFEFEFFFEFEFFFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF4F3F2FFF4F3F2FFF4F3F3FFF5F3F3FFF4F3F2FF361A04FFCB731BFFCE72
      16FFFEEBC4FFA9641DFFF6C97CFFFDEEC9FFC19467FFF7CB81FFE5C8A1FFFEEA
      C1FFF7C87AFFAF6317FFFDD79EFFD3751AFF422508FFF0F2F0FFF1F4F2FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F1EDFF6B3A14FFFCFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFCD8236FF69340EFF6A3A16FFFFFF
      FFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFEFFFF6A3114FFA25A25FFE8D8CEFFD9D3CEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF6C4937FFEDECEDFFFBF7F6FFF8F2F1FF663818FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFEFFFFFFFDFEFFFFFDFFFFFAFDF8FFFFFF
      FFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFF6C3814FF6234
      14FFFFFEF6FFEAC39EFFE9CAA8FFD4A870FF714019FFFFFEFEFFFFFFFFFFFFFF
      FFFFFFFEFFFF65391BFFFAF7F5FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FEFF192E60FF0A142DFF66BDF6FF78CCFDFF7ACDFCFF7ACDFCFF79CDFCFF72C8
      FCFF3B82C5FF0C1D3EFF006DC1FF07549DFF6BB3EFFF80CDFAFF81CDFBFF7ECA
      F8FF3574C9FF0B95E0FF003668FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF402207FFCD7117FFCC71
      17FFFEEFCEFFAD6920FFE0B36FFFFEF3D3FFC6996AFFE2B56FFFE6CBA8FFFFF0
      CDFFE0B36AFFAC651BFFFEDFACFFD7781AFF3F250AFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F3EFFFCBAB96FFFDFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF907767FFD58430FFD88434FFFFF8F0FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFAFF9C5724FF723D19FFE1D7D0FFFEFFFEFFFFFF
      FFFFFFFFFFFFFFFFFFFF713E18FFF5F4F2FFFAF7F5FFF6F1EFFF79543DFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFDFF7D3E1BFFFCFF
      FFFFFEFFFCFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFCFFAE9783FFFDFFFDFFFFFE
      FCFFC6B2A3FF713F1BFFB98D5BFFFFFCF6FFFDFCFCFFFFFFFFFFFFFFFFFFFFFF
      FFFFFCFEFFFFF6F2EBFFFBF7F6FFFAF6F5FFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FFFF193063FF204075FF68BEF8FF78CCFDFF78CDFDFF79CDFDFF79CCFCFF4A9C
      EBFF030912FF0E2047FF1491D7FF45C2F0FF1887C3FF084792FF317DD4FF69B2
      EFFF2FBDF6FF1DA4E2FF154B75FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF402206FFCB7218FFC96F
      16FFFEF4D9FFFFF6DCFFFFF5DCFFFEF6DCFFFFF6DCFFFFF6DBFFFEF5DBFFFEF5
      D9FFFFF4D6FFFEF3D6FFFEE6BCFFD67B1DFF41260CFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F5F3FFF8F0ECFF64331FFFFEFE
      FFFFFFFFFFFFFFFFFFFFFEFEFEFF673915FFFFFDEFFFCE832FFFFFFBFFFFFEFE
      FFFFFEFEFFFFFEFEFFFFFCFFFFFFFBFEFFFFFEFEFFFFFEFEFFFFFEFEFFFFFEFE
      FFFFFEFEFFFFFEFEFFFFFFFDFFFF985828FF6E360EFFDFD8D4FFFEFFFFFFFFFF
      FFFFFFFFFFFFFFFFF8FFF0EFE4FFFBF7F6FFFBF7F6FFF9F5F4FFF3EDEEFFFFFE
      F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFCFEFFFFFFFFFFFFFFFFFFFEFD
      FBFFF1E5D5FF481C06FF4A250BFFA18871FFFBFBFCFFFFFEFFFFFFFFFFFFFFFF
      FCFFFFFFFFFFFBFEFEFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFF
      FFFF653E24FFF6F2F1FFFCF8F7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FFFF2C5498FF2B549DFF0F294EFF09203CFF021024FF3D99E6FF041431FF0009
      19FF112B5BFF051430FF1DA3D9FF47C2F4FFF3FAFEFF33BDEDFF2CB9EAFF0257
      A1FFE1FAFEFF33B8EBFFDFE8F0FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4C2909FF6F3B0BFF7741
      10FFB08E63FFB39167FFB29167FFB39268FFB29168FFB29067FFB29068FFB292
      69FFB39168FFB39067FFB28F64FF985C20FF40270DFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F5F4FFF8F7F5FF876B53FFFCFF
      FEFFFFFFFFFFFFFFFFFFFFFFFFFF703915FFD08032FFD17F30FFCF8134FFD07C
      31FFCC7C31FFCC7D2CFFCD7B30FFC87A30FFC4782CFFC67730FFC7782EFFC278
      2DFFC47A35FF9F5A21FF9D5623FFA05922FF743F16FFDFD8D1FFFEFFFFFFFFFF
      FFFFFFFFFFFF6F3B1CFFFCF5F1FFFBF7F6FFFCF9F7FFF8F4F3FFFAF7F5FF663A
      17FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF582611FFF7F3E1FFFFFFFBFFFFFAF7FFF9DFCAFFF3E0CBFFA37F
      67FFFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFF
      FFFF624430FFFBF8F6FFFDF9F9FFFBF8F5FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF173065FF1E3E81FF132A55FF203D79FF172D64FF1A3264FF1B3065FF1A30
      66FF192F66FFE0E0E2FF14A3DFFFEEF8FDFFEEFAFEFFE3F8FEFF5AD3F6FF36C2
      F2FF66D9FDFF0F91D1FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF44250BFFAD8B69FFAE8C
      69FFF2EDE2FFF3EFE3FFF2EDE3FFF2EEE3FFF2EEE2FFF1EDE3FFF2EDE3FFF2EE
      E4FFF1EDE3FFF1EDE3FFF1EDE2FFECE7DDFF432A11FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F4F2FFFAF6F4FFF8F4F1FF6736
      13FFFDFFFFFFFFFFFFFFFFFFFFFF623614FFFFFFFEFFFFFFFFFFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFEFEFEFFFFFFFFFFFBFFFFFF5C331BFFFAFCFBFFFFFFFFFFFFFF
      FFFFA88D7CFFF6F1EFFFFBF7F6FFFBF6F3FFFBF7F6FFF8F4F5FFFBF7F6FFFBF3
      EFFF907862FFFFFFFFFFFFFFFFFFFFFEFFFF755944FFFEFFFFFFFFFEFFFFFEFE
      FEFFFFFFFFFFFEFFFEFF7C4018FF5F300FFFEABE90FF562F0DFF653410FFA17C
      63FFFFFFFEFFFEFEFEFFFCFDFEFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFDFF6C3A
      15FFF7F4F3FFF9F7F6FFFCF8F7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFFFF051329FF203B72FF2D559EFF315BA4FF2D569FFF315CA5FF1A30
      64FF051027FFFFFEFEFFF3F7F9FF27C0EBFF9FE6FCFFCAEFFBFF40C5F4FF29BA
      F0FFBECBD4FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF472B13FF2D1508FF2914
      08FF201007FF1D0E07FF1C0E07FF1D0F08FF1D0E07FF1C0D07FF1C0F08FF1E0F
      07FF1F0F08FF1D0F06FF200F06FF251207FF432A15FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1EEEAFFF3F1EDFFF5F2EFFFF8F3
      F1FF5D3926FFFEFFFEFFFFFFFFFFFEFEFEFF662E14FF6D3B19FF6E3C1AFF723B
      16FF713A16FF6C3B19FF6E3918FF6F3B19FF6F3A18FF6C3D17FF6C3B17FF713B
      16FF723B16FF6F3918FF713B18FF683A19FFFDFCFDFFFFFFFFFFFFFFFFFFFFFE
      FCFFE5D7C5FFF4F0EFFFF4F1EFFFF4F1EEFFF4F1EFFFF3EFEEFFF5F2F0FFF4F0
      EEFFFDE8E0FFFBFFFCFFFFFFFFFFFFFFFFFFFFFEFFFFD0C4B8FFD3C6B8FFD3C6
      B8FFD4C7B9FFD1CABBFFFFECDAFFEBD8BCFF6D3D1CFFEAE0D4FFAB947BFFAA87
      6BFFD5C0B0FFF9FDFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD9C2B8FFF6F3
      F1FFF6F2F1FFF4F1EEFFF4F1EFFFF4F1EFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFFFFFFFF132858FF214082FF2B58A4FF162C5DFF182D5EFF1328
      53FFFFFFFFFFFEFEFEFFFEFEFEFFFFFFFFFF7D9EB6FF003768FF003468FFE9EE
      F2FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2D1D
      16FF412B1DFF715B4DFF4C3729FF4F3A2BFF4F3A2DFF4E392BFF4D3729FF4833
      24FF3F2A1CFF1D0D01FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F4F2FFFAF7F3FFFBF8F4FFF9F8
      F2FFF5F1ECFF8E765DFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFAFFFCFF6841
      2BFFFDF5F5FFF7F3F2FFFBF8F4FFFAF7F3FFFBF7F6FFF7F4F2FFFBF7F6FFF8F4
      F3FFFCF6F5FF56240EFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFDFEFFFEE9D0FF613C13FFFEFDFFFF947760FF5E30
      16FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFEFFFBF1E8FFF8F7
      F6FFFBF7F7FFFAF7F2FFFCF8F7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFFFFFEFF394254FF00051DFF00051CFF67707BFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2C1D
      17FF432D1EFF786254FF6C564AFF6B5749FF6C584AFF6C5549FF6A5548FF5B45
      37FF422E21FF221002FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F5F2FFFBF6F3FFFCF7F5FFFAF7
      F4FFFBF8F4FFF4F0EDFF65361BFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFE
      FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE4D3C8FFE2CDC1FFFDF6
      F5FFFBF8F4FFF6F3EFFFFAF7F3FFFAF5F2FFFBF8F4FFF9F6F4FFFBF7F6FFF6F4
      F0FFFBF7F5FFFDF6F7FF6A3416FFFAFEFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF70533AFF76563DFF6E563DFFFFFF
      FEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCF6FFE3CBC1FFFAF7F7FFFBF7
      F5FFFBF7F6FFFBF6F3FFFCF8F7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF2E1A0CFF251104FF231102FF241204FF231103FF251305FF231103FF2210
      03FF352419FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F4F0FFFAF7F3FFFAF7F3FFFAF7
      F3FFFAF7F3FFFBF7F6FFF3F4EDFF6C3714FFFEFFFEFFFEFFFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6B3916FFF8F9F3FFFBF9F2FFFBF9
      F5FFFAF7F3FFF6F3EFFFFAF7F3FFFAF7F3FFFAF6F5FFF7F4F2FFFAF7F3FFF7F4
      F0FFFBF7F6FFFCF8F7FFF9F7F6FF907865FFE1D1C6FFFFFDFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFEFFFF5E3319FFFFF7EFFFF8F8F6FFFAF7F4FFFAF7
      F3FFFAF7F3FFFAF7F2FFFCF8F7FFFBF7F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F5F2FFFAF7F3FFFAF7F4FFFAF7
      F3FFFAF7F3FFFAF6F5FFFBF7F6FFFBF7F6FFFDF6EEFF6B3E17FFFFFFFDFFFEFF
      FDFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFEFEFFFFFFFEFFFF6E3A1AFFB7A291FFFAF7F3FFFBF7F6FFFAF8F4FFFAF7
      F4FFFAF7F3FFF7F2EFFFFAF7F3FFFCF9F5FFFBF7F6FFF7F4F2FFFBF7F6FFF6F2
      F1FFFBF8F4FFF9F6F2FFFBF7F6FFFBF7F6FFFAF5F4FF6F3816FFFCFFF7FFFFFF
      FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFDFFF0E0D4FF6F3F19FFF6F8EFFFFAF6F5FFFBF7F6FFFBF7F5FFFAF7
      F3FFFBF7F6FFFAF6F5FFFBF8F6FFFCF9F5FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F4F2FFFAF7F3FFFAF7F3FFFAF7
      F3FFFAF7F3FFFAF7F3FFFBF8F4FFFAF7F5FFFBF7F6FFFAF7F5FFF4F3F2FF643B
      22FF703E15FF7C5C46FFFFFEF5FFFFFFFDFFFFFFFDFFFFFFFAFFA88E7DFF6E3E
      17FF713C1CFFF9F7F3FFFAF7F4FFFAF6F5FFFAF7F3FFFBF8F6FFFAF7F3FFF9F7
      F3FFFAF7F3FFF6F2F1FFFAF7F4FFFAF7F4FFFBF7F6FFF7F4F2FFFAF7F3FFF7F4
      F0FFFAF7F3FFFAF8F4FFFBF7F6FFFAF6F5FFFAF6F5FFFBF7F6FFF4F5F4FF6834
      19FF6E3C17FFEFE3D4FFFFFDFFFFFFFEFFFFFFFFFCFFFFFFFDFFB39786FF6F3E
      1AFF563821FFFAF3F6FFF9F7F6FFFAF6F4FFFAF6F5FFFBF7F6FFFAF6F4FFFAF7
      F3FFFBF8F4FFFBF7F6FFFCF9F5FFFBF8F4FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F4F1FFFAF7F3FFFAF7F3FFFAF7
      F3FFFAF7F4FFFBF8F4FFFBF7F5FFFBF7F6FFFAF7F4FFF9F6F3FFFAF6F4FFFAF7
      F5FFFAF7F4FFFAF6F3FFFBF7F1FFFAF6F1FFFBF7F3FFF9F6F2FFFAF7F4FFFAF7
      F3FFF9F6F4FFFBF7F5FFFBF6F3FFFAF7F5FFF9F5F4FFFBF7F5FFFAF7F4FFFAF7
      F4FFFAF7F3FFF5F2EFFFF9F6F3FFFAF7F3FFFBF7F6FFF7F4F1FFFBF7F6FFF6F3
      F0FFFBF7F6FFFAF8F4FFFBF7F6FFFBF7F6FFFCF8F7FFFBF7F6FFFBF7F6FFFBF7
      F6FFFBF7F6FFF8F7F4FFFDF8F4FFF7F6F2FFF8F8F4FFFDF8F1FFFAF9F5FFFBF6
      F7FFFBF7F6FFFBF7F6FFFCF8F7FFFBF7F6FFFAF7F5FFFBF7F6FFFBF7F4FFFAF7
      F3FFFBF7F5FFFBF8F4FFFCF9F6FFFBF8F4FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F4F2FFFBF7F6FFFBF7F5FFFBF7
      F6FFFBF7F6FFFBF7F6FFFBF7F6FFFBF7F6FFFBF7F6FFFBF7F6FFFAF7F6FFFBF8
      F6FFFAF7F3FFFAF7F3FFFAF7F3FFFBF7F6FFFBF7F6FFFAF7F5FFFBF8F5FFFBF7
      F5FFFAF8F4FFFBF6F7FFFBF7F6FFFBF7F6FFFBF7F6FFFBF8F7FFFAF7F4FFFBF8
      F4FFFAF7F4FFF5F2EFFFFAF7F3FFFCF7F4FFFAF7F3FFF6F4F0FFFBF7F6FFF6F3
      F0FFFBF7F6FFFBF8F6FFFBF7F6FFFAF6F5FFFBF7F6FFFBF7F6FFFBF7F6FFFBF7
      F6FFFBF7F6FFFAF7F3FFFBF7F6FFFBF7F6FFFBF7F6FFFAF7F3FFFBF7F6FFFAF6
      F5FFFBF6F7FFFBF7F6FFFBF7F6FFFBF7F6FFFAF7F5FFFBF7F6FFFAF6F4FFFCF7
      F4FFFCF7F3FFFBF6F3FFFCF7F4FFFBF7F6FF424D3E000000000000003E000000
      2800000080000000600000000100010000000000000600000000000000000000
      000000000000000000000000FFFFFF0080000000800004000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000004000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000040000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8000000000000000000000000000000000000000000000000000000000000000
      0000008000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object ActionManager: TActionManager
    LargeImages = ilstRibbonLI
    Images = ilstRibbonSI
    Left = 336
    Top = 272
    StyleName = 'Platform Default'
    object cmdKunden: TAction
      Caption = 'Kunden'
      ImageIndex = 0
      Visible = False
      OnExecute = cmdKundenExecute
    end
    object cmdArtikel: TAction
      Caption = 'Artikel'
      ImageIndex = 1
      OnExecute = cmdArtikelExecute
    end
    object cmdDokumente: TAction
      Caption = 'Dokumente'
      ImageIndex = 2
      OnExecute = cmdDokumenteExecute
    end
    object cmdWebEditor: TAction
      Caption = 'Webinhalte'
      ImageIndex = 2
      OnExecute = cmdWebEditorExecute
    end
    object cmdPersonen: TAction
      Caption = 'Personen'
      ImageIndex = 3
      OnExecute = cmdPersonenExecute
    end
    object cmdLager: TAction
      Caption = 'Lager'
      ImageIndex = 5
      OnExecute = cmdLagerExecute
    end
    object cmdScanner: TAction
      Caption = 'Scanner'
      ImageIndex = 4
      OnExecute = cmdScannerExecute
    end
    object cmdPGManager: TAction
      Caption = 'DB-Manager'
      ImageIndex = 5
      OnExecute = cmdPGManagerExecute
    end
    object cmdMandantNeu: TAction
      Caption = 'Neuer Mandant'
      ImageIndex = 6
      OnExecute = cmdMandantNeuExecute
    end
    object cmdMandantWaehlen: TAction
      Caption = 'Mandant ausw'#228'hlen'
      OnExecute = cmdMandantWaehlenExecute
    end
    object cmdKunde: TAction
      Caption = 'Kunde'
      OnExecute = cmdKundeExecute
    end
    object cmdKlient: TAction
      Caption = 'Klienten'
      OnExecute = cmdKlientExecute
    end
    object cmdKundenBestellung: TAction
      Caption = 'Kd.-Bestellung'
      OnExecute = cmdKundenBestellungExecute
    end
    object cmdLieferantenBestellung: TAction
      Caption = 'Lief.-Bestellung'
      OnExecute = cmdLieferantenBestellungExecute
    end
    object cmdLagerEntnahme: TAction
      Caption = 'Lager-Entnahme'
      OnExecute = cmdLagerEntnahmeExecute
    end
    object cmdEinstellungen: TAction
      Caption = 'Einstellungen'
      OnExecute = cmdEinstellungenExecute
    end
    object cmdMitarbeiter: TAction
      Caption = 'Mitarbeiter'
      OnExecute = cmdMitarbeiterExecute
    end
    object cmdMail: TAction
      Caption = 'E-Mail'
      OnExecute = cmdMailExecute
    end
    object cmdLohn: TAction
      Caption = 'L'#246'hne'
      OnExecute = cmdLohnExecute
    end
    object cmdAnlagen: TAction
      Caption = 'Anlagen'
      OnExecute = cmdAnlagenExecute
    end
    object cmdKalkulation: TAction
      Caption = 'Kalkulation'
      OnExecute = cmdKalkulationExecute
    end
    object cmdFeedback: TAction
      Caption = 'Feedback'
      OnExecute = cmdFeedbackExecute
    end
    object cmdKursAnwesenheit: TAction
      Caption = 'Kurs-Anwesenheit'
      OnExecute = cmdKursAnwesenheitExecute
    end
    object cmdBenutzer: TAction
      Caption = 'Benutzer'
      Hint = 'Zug'#228'nge und Mandantenzuordnung (nur globaler Administrator)'
      OnExecute = cmdBenutzerExecute
    end
    object cmdNotfall: TAction
      Caption = 'Notfallzugang'
      ShortCut = 57415
      Visible = False
      OnExecute = cmdNotfallExecute
    end
    object cmdKurs: TAction
      Caption = 'Kurse'
      OnExecute = cmdKursExecute
    end
    object cmdAnwesenheit: TAction
      Caption = 'Anwesenheit'
      OnExecute = cmdAnwesenheitExecute
    end
    object cmdLehrer: TAction
      Caption = 'Lehrer'
      OnExecute = cmdLehrerExecute
    end
    object cmdVorgang: TAction
      Caption = 'Vorg'#228'nge'
      OnExecute = cmdVorgangExecute
    end
  end
  object ilstRibbonSI: TJvImageList
    Items = <>
    Left = 240
    Top = 272
    Bitmap = {
      494C010107001800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF7F7F7FFFBFBFBFFFCFCFCFFFDFD
      FDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFF9F9F9FFC0BAB6FF061A3AFF7F7165FFF7F7
      F6FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF7F7F7FFFBFBFBFFFCFCFCFFFDFD
      FDFFFDFEFEFFFDFDFDFFFDFDFDFFFDFEFEFFFDFEFEFFFDFEFEFFFDFEFEFFFDFD
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFF8F9F9FFABA097FF081E37FF237BCAFF2781CEFF2783D1FF1A5495FF0E3D
      78FF918478FFF7F7F6FFFEFEFEFFFEFEFEFFF7F7F7FFFBFBFBFFFCFCFCFFA190
      7FFFF3F1EFFFF4F2F0FFF4F1EFFFF4F2F0FFF2F1EEFFF3F1EEFFF4F2EFFFF4F2
      EFFFF7F7F6FFDCD8D4FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF8F8
      F8FFEEEEEDFFEDEDEBFFE9E8E7FFEAE9E8FFE9E8E7FFE4E3E2FFDDDAD8FFDDD9
      D5FFE2E0DDFFEAE8E7FFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFCFCFDFF0126
      58FF2171C3FF2577C5FF267CC9FF2781CDFF2A87D1FF2989D3FF225B9EFFE9E2
      D9FF174B8EFF0C346AFFC4BCB6FFFEFEFEFFF8F8F8FFFBFBFBFFFCFCFCFFA191
      81FFE4DDD6FFE1DBD3FFE2D9D1FFE1D8D0FFE1D8D0FFE0D9D1FFE0D7D0FFDFD5
      CEFFF7F3F0FFB8AFA7FFE1DEDBFFFDFDFDFFFEFEFEFFFEFEFEFFD5D1CFFF6531
      12FF834119FF6E3614FF906440FF8A562FFF6C3413FFD4C6B0FFAB4D34FFE6DF
      D3FFCDC4B4FFE8E1D4FFBDB5AAFFF9F8F8FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF2173
      C4FF2375C3FF267BC8FF2780CBFF2A85CFFF2D8CD4FF2E90D7FF235B9FFFC2BC
      AFFFF6EEDDFF1E5495FF001A3EFFDFDBD7FFF8F8F8FFFBFBFBFFFCFCFCFFA799
      8AFFE6E0D9FFF0EDEAFFEFEBE6FFEFEBE7FFEFECE7FFEEEAE6FFDFD8CFFFDFD7
      CFFFF6F3F0FFE6E3E0FFF4F2F1FFFDFDFDFFFEFEFEFFFEFEFEFFFFFFFFFF9F55
      2DFF98582DFF4B2007FFEAE3DBFFDED7CBFF8E4B20FFEAE0D3FF60ACEAFFF7F6
      F4FFE2DDD6FFF7F5F0FFD9D3CCFFFCFCFCFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF2175
      C6FF257BC8FF267FCBFF2884CFFF2D8BD4FF3192D9FF389BDDFF235C9FFFF6F0
      E3FFF5EEDFFF235A9CFF041835FFF5F3F1FFF8F8F8FFFBFBFBFFFCFCFCFFAB9C
      8EFFE8E3DCFFE6E0D9FFE3DED6FFE2DDD5FFDFDAD2FFE0DBD5FFDFD7CFFFDFD8
      D0FFF6F3F0FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF655D
      54FFD67D48FFF7F3EDFF457DB7FF3780CCFFEDE6DDFFF5EFE8FFFFFFFEFFFEFE
      FCFFFDFDFBFFFDFCFBFFE6E3DFFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF2076
      C7FF257ECAFF2783D0FF2677BBFF4E839BFF379ADFFF50AFE6FF2962A3FF2962
      A4FF2760A1FF265EA2FF041A36FFFEFEFEFFF8F8F8FFFBFBFBFFFCFCFCFFADA0
      93FFEBE7E2FFB2A495FFB1A293FFAFA292FFAC9D8EFFAB9C8CFFA99A88FFE0D9
      D1FFF4F1EDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFFFF0246A7FF5AB6F2FF49A8EDFF003189FFF4B16EFFC4874BFFFEB6
      64FFCD975DFFF7B66FFFE1DEDBFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF2178
      C8FF2684CFFFA5D9F1FFA4D9F2FF50869FFF399DE2FF72C7F2FF2961A4FF2861
      A4FF2761A4FF2662A5FF061F3EFFFEFEFEFFF8F8F8FFFBFBFBFFFCFCFCFFB2A5
      98FFF1EDE9FFE9E4DEFFE8E2DBFFE5E0D9FFE2DAD3FFDED7CFFFDFD7D0FFE1DA
      D3FFF2EEEBFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF012B68FF69C0F7FF73CCFCFF70CAFBFF4AA5F1FF5B728CFFCCC6C2FF3521
      14FFD4CFCBFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF217C
      CAFF2988D3FFA8DCF3FFA7DCF3FF5082A0FF76C4F1FFB0E9FEFF72A8D1FF2561
      A6FF2662A7FF2664AAFF132C4CFFFEFEFEFFF8F8F8FFFBFBFBFFFCFCFCFFB2A5
      98FFF6F5F2FFB4A99EFFA89C8FFFA29588FF9F8E81FF9B8B7BFFD8D0C7FFE0DA
      D3FFE8E4DFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFF
      FFFF09203FFF72CBFAFF79CEFCFF76CCFCFF6EC9FDFF1762BEFFF9FAFBFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF227E
      CBFF2A8AD7FFD9EFF9FFDDF2FCFFC2E9F9FF5690B3FF60C5F9FF60C4F9FF62C2
      F7FF2564A8FF2264ADFF1A3960FFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFB5A9
      9CFFFCFBFAFFF8F6F5FFF2F0EDFFEEEAE5FFEAE4DEFF8A725BFF846951FF7F66
      4EFF8B7865FFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF06132CFF7CD0FBFF7ED1FDFF7BCFFCFF6AC3F7FF0C224DFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFF3F83
      BDFF5DBFF8FF59BEF7FF5FB9EDFFAADDF4FFA3D9F1FFA0D5EFFF4589B3FF57B9
      F4FF54B5F2FF4FB2EFFF265082FFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFB2A7
      9AFFFEFEFEFFFBFBFAFFF7F6F5FFF2F0EDFFEEEAE5FF614A34FFE9E3DBFFE1DA
      D0FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF142F61FF7ED1FEFF43A9F1FF2570BEFF328DE4FF193067FFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFFFFFFFF4598D3FF51B3F1FF4EB3F1FF4DAEE6FF95D0EDFF93CEEBFF93CC
      EAFF1F5B99FFFFFFFFFFFEFEFEFFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFB6AA
      9EFFFEFEFEFFFEFEFEFFFBFAF9FFF7F6F4FFF2EFECFF6E5A48FFEBE6E0FFFBFB
      FBFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFF182E66FF2A4C91FF2F569DFF3059A4FF0F234FFF152A5CFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFFFFFFFF2D73B3FF49ADEEFF1E5995FFFFFFFFFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFC2B8
      ADFFFEFEFEFFFEFEFEFFFEFEFDFFFBFAF9FFF8F6F4FF968575FFFFFFFFFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFF193063FF264789FF23458BFF112656FFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFFDFD
      FDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFFDFD
      FDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF8F8F8FFFBFBFBFFFDFDFDFFFDFD
      FDFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFAFAFFFAFAFAFFFAFAFAFFFBFA
      FAFFF8F7F7FFF4F2F2FFF1F0EEFFD5CAC4FFD2C6C0FFF2F0EEFFF4F2F1FFF8F6
      F6FFFAFAFAFFFAFAFAFFFAFAFAFFFAFAFAFFFAF8F7FFFAF8F7FFFAF9F8FFFAF9
      F7FFF5F3F3FFEFEAE9FFB7A498FFBFA99CFFBEA99CFFC1AFA7FFEFEBE8FFF5F4
      F4FFFAF9F8FFFAF9F7FFFAF9F8FFFAF8F7FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFF837B76FF8980
      7AFF8F8781FF99918DFFA29D99FFA5A09DFFA5A09DFFAEADA9FF001300FF00B0
      5EFF00B060FF011C01FFFFFFFFFFFFFFFFFFFAF7F3FFFAF7F3FFF8F4F3FFE2DB
      D3FF6F3B18FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF532A
      0EFFDDD5CDFFF7F3F2FFFAF7F3FFFAF7F3FFFAF7F3FFFBF8F4FFFAF7F3FFE4DC
      D5FF6A371AFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFF6E39
      19FFE6DFDAFFFBF7F6FFF8F6F2FFFAF7F3FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFF4E4542FF49321FFF5841
      2EFF58402DFF1D0C00FF593F28FF362316FF200F02FF010C01FF016A1DFFA8CB
      B8FF152F16FF00701EFF011E01FFFFFFFFFFFAF7F3FFF8F4F3FFE2D4CDFFFFFE
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFEFFE3D6CEFFF6F3EFFFFBF6F3FFFAF7F3FFFBF7F6FFE6DDD9FFFFFD
      FCFFFFFFFFFFFEFFFFFFE1D5C7FFFFFEF8FFD8CEC3FFECE4DAFFDCD3C8FFFFFF
      FFFFFFFCFDFFE8E1DDFFFBF7F4FFFBF6F3FFFEFEFEFFFEFEFEFFFEFDFEFFFBFB
      FBFFFCFCFCFFFBFBFBFFFCFCFBFFFCFCFCFFFCFCFCFFFDFCFCFFFCFCFCFFFEFD
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFF524743FF60412AFF8B72
      5CFF886F5AFF291300FF875E34FF45301FFF2B1703FF01B762FF003100FFC1D2
      C6FF173818FF003200FF00D27FFFFFFFFFFFFBF6F4FFE5DAD7FFFFFEFFFFFEFE
      FEFFE0D6D0FFE1D6D1FFE2D7D2FFE2D8D0FFE1D7D0FFDFD8D1FFDDD7D0FFE4D6
      D2FFD8D7D0FFFFFEFEFFE2D8CEFFFBF5F4FFFAF7F3FFF3EEEBFFFEFEFFFFFFFF
      FFFFF8FFFEFF5F200AFFB39578FFFEE1C4FF714120FFF3D7ACFFE5D1C0FFFFFD
      FCFFFFFFFFFF795844FFF4F0EFFFFBF6F7FFFEFEFEFF4A1600FFCF4900FFCE41
      00FFC44400FFFCD47BFFE06300FFA32F00FF090E9CFF0E1DC8FF0D1DC7FF0207
      7FFF773F09FF7A430EFF774313FFDCD8D4FFFFFFFFFF594B45FFC88641FFB970
      1AFFB66D19FF422503FF8D6134FF605750FF575048FF019B41FFF2FFF8FFF2FF
      F8FFF0FEF7FFEDFFF7FF03E192FFFFFFFFFFF5EFEEFFFEF3ECFFFFFFFFFF9A55
      20FFFAFFFFFFFFFBFFFFF9FFFBFF9E5620FF9E5521FF9E5620FFFDFEFDFFFEFD
      FEFF9D551EFFFFFFFFFFFFFDFFFFF0E9E6FFFAF5F6FFDEC7BBFFFFFFFFFFFEFE
      FEFFFCFFFCFFFEFEFEFFDBC8B6FFAB9082FFDBD0C6FFFFFFFFFFFFFFFFFFFFFF
      FEFFFEFEFEFFFFFFFFFFDEDDDAFFFBF6F7FFFEFEFEFF481300FFFD8618FFEE8B
      11FFCE9841FFFEEFBAFFF48736FFF87006FF1019A0FF8ED5FFFF1F38E1FF070E
      8EFF783C0FFF89451CFF8A471FFFF5F4F4FFFFFFFFFF5C4E46FFD5944DFFBE78
      28FFBB7627FF452502FFFBC172FFFCC476FFFBC376FF10F2AFFF00AD4BFFCED6
      CCFF194518FF00A949FF012F01FFFFFFFFFFE4E2DAFFFFFFFFFFFFFFFFFF653A
      17FFFFFFFEFFFEFFFDFFFEFFFEFFFEFEFEFFFEFFFEFFFFFFFFFFFEFFFEFFFEFF
      FDFFA28875FFFDFDFDFFFFFFFFFFF1DBCDFFF7F3F2FFFFFDFFFFFFFFFFFFFFFF
      FFFFFDFFFDFFEDA34AFFEBA54BFFE69C4AFFA3612CFFFAE3CAFF753E10FFF4DE
      C6FFEBCFB6FFFFFFFFFF4B2109FFF9F5F4FFFEFEFEFFFEFEFEFF6A4D3CFFDEB0
      65FFBB9540FF787C6BFFA24D0DFF023873FF5799DFFF5696E0FF07167CFF4674
      98FFF7F6F3FF9F5526FFA05525FFFFFFFFFFFFFFFFFF5B4D46FFD29047FFC077
      25FFBD7423FF462604FFFCCA81FFAC6214FFC4751DFFF8C174FF2FFFCDFF00B0
      4BFF00AB48FF19EEB0FF019D4BFFFFFFFFFF6E3E17FFFFFFFFFFFFFFFFFF6738
      11FF917258FFEAE3DBFFFDFFFEFFFCFFFEFFFFFFFEFFFFFFFEFF532B0DFFEEEC
      E3FF4C2A11FFFFFFFFFFFFFFFFFF683317FFF3F0EEFFFAFFFFFFFFFFFFFFFFFF
      FFFFF0D5BEFFF2DFCBFFD4B293FF68411DFFAC6A32FFEAD8B9FFE9C79DFFC69D
      76FFEACFB2FFFFFFFFFFFFFDFFFFF6F3F1FFFEFEFEFFFEFEFEFFFEFEFEFF0F2E
      56FF409DE7FF43A3EFFF533A38FF2192D2FF2562AAFF77C1F4FF00457FFFAC57
      21FFB75D29FFB35C2AFFB25A29FFFFFFFFFFFFFFFFFF605047FFDC9B55FFC57E
      2BFFBC7624FF4A2804FFFDD696FFA86115FFE1B367FFFCCF8DFFD0791DFF9364
      21FF02762BFF009E47FF01CD8BFFFFFFFFFF6D391AFFFFFFFFFFFFFFFFFFFFFD
      FFFFFFFDFFFFF2E8E0FFFFFFF9FF6F3B18FF6C3A17FFFFFCFFFFFDFFFFFFAD9A
      8CFFDAD2CAFFFFFFFFFFFFFFFFFFF7FBF0FFF2EEEDFFFFFFFFFFFFFFFFFFFCFF
      F9FFFCFDFFFFE6BE7AFFE7BB79FFFAFDFEFF6D3C16FFFBDDC2FFF2E0CDFFD8BC
      A3FF824422FFFFFFFFFFFFFFFFFFF3F0EEFFFEFEFEFFFEFEFEFF071D38FF3E9C
      EDFF62BDF7FF68BFF5FF399BEFFF0B76BFFF83C6FAFF8ACCF6FF5491E9FF6B47
      23FFF0EDEBFF412C1CFFFDFDFDFFFEFEFEFFFFFFFFFF645448FF774210FFAE89
      58FFAE8A58FF4C2805FFFEDFACFFFEDCA5FFFDDAA1FFFDDCA8FFFDD79BFFD482
      39FF029E45FF01BA66FFE4EAE5FFFFFFFFFF723E1AFFFEFEFEFFFFFFFFFFFFFB
      F9FFFFF0E4FFC1AC9CFFFFFDFFFFFFFDFEFFFFFFFFFFFFF9F2FFFAFFFDFFFFFB
      FAFFFFFFFFFFFFFFFFFFFFFFFFFFCFB5ABFFF5F1EFFFFFFFFFFFFFFFFFFFC988
      4BFF6D3911FFF2E0CAFFF2DEC8FFF2DFCAFFDAAE7CFFF7DBC5FFF4E1CCFFE9D5
      C8FF532B0EFFFFFFFFFFFFFFFFFFF9F6F5FFFEFEFEFFFEFEFEFF3A9BF0FF5AB5
      F4FF0B141BFF74CBFBFF54ADF4FF024894FF030A0BFF81CFFDFF74B1F4FFD6DE
      E1FFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFF3D250FFF3D25
      10FF40250AFF412003FFFEEAC0FFB06B1CFFDCA85CFFFEE8BFFFD58329FFDC90
      49FF053502FF044105FFFFFFFFFFFFFFFFFFA1836AFFFFFFFFFFFFFFFFFFFDFF
      FBFFD37E2CFFFFFFFBFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFEFFFDFDFEFF9B57
      23FFE0D7D3FFFFFFFFFFFFFFFFFF733F1BFFFAF6F5FFFEFFFDFFFFFFFFFFFEFE
      FEFFE7E5D8FF6C451CFFFCFFFDFFFEFFFCFFF2E9D6FFFFFFFDFFEBC6A2FF7342
      14FFD3CCC2FFFFFFFFFFFEFCFFFFFBF6F7FFFEFEFEFFFEFEFEFF0B1C45FF62BE
      FDFF75CCFCFF72C8FBFF3988DAFF0B7BBDFF147CBEFF499BE4FF31B5EFFFFFFF
      FFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF42240DFFCC7016FFFEF2D2FFAC671EFFA9631CFFFFF2D4FFA65F1AFFDD95
      53FFF3F2F1FFFFFFFFFFFFFFFFFFFFFFFFFFF9F4F4FFFFFFFFFFFFFFFFFFFFFE
      FFFF683712FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6D37
      16FFE7D4C0FFFFFFFFFFFFFFFFFFF5F1EFFFFBF7F6FF653516FFFFFFFFFFFFFF
      FFFFFDFFFEFF856B53FFFFFFF8FFFFFFF8FF6E4318FFFFFFFFFFFFFFFCFFFFFF
      FCFFFFFFFFFFFFFFFFFF673A1BFFFBF7F6FFFEFEFEFFFEFEFEFF00061CFF1021
      45FF1C346DFF1B336AFF182F68FF1A89BAFFE1F4FDFF3CC4F2FF3BC2F6FFFFFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF3F240FFFB59678FFF7F4ECFFF7F4EDFFF7F4EDFFF7F4ECFFF6F3EDFFF4F1
      E8FFF4F3F2FFFFFFFFFFFFFFFFFFFFFFFFFFF8F6F5FF673512FFFFFFFFFFB6A6
      9CFF663A19FF643516FF613916FF633817FF65391AFF623817FF663819FF6639
      18FF713914FFFFFFFFFF743E1BFFFBF7F6FFF8F6F5FFFCF6F5FFFFFFFFFFFFFF
      FFFFFDFFFEFFFFFFFFFFFEFCFFFF603519FF6C5548FFF7DECBFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFF3F8F1FFFBF8F4FFFEFEFEFFFEFEFEFFFEFEFEFF020A
      21FF2A509AFF112658FF94989FFFFEFEFEFFFAFBFCFF9DB2C5FFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF6C5B50FF483121FF483324FF493325FF483425FF3E2819FF6858
      4CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAF7F3FFFBF8F6FF664031FFFFFF
      FFFFFCFFFFFFFFFFFEFFFFFEFFFFFDFFFFFFFDFFFFFFFFFFFCFFFFFFFEFFFFFE
      FFFFFDFFFFFFF9FFFDFFFAF6F5FFFAF7F3FFFAF7F3FFF9F6F3FF5B3D22FFFFFF
      FFFFFFFFFDFFFFFFFFFFFFFFFEFF65300DFF77624DFFF7E0C6FFFFFFFFFFFFFF
      FFFFFFFFFFFFFAF2EFFFFAF7F3FFFAF6F5FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF4F392BFF6F5B4CFF715B4DFF6E594AFF321F10FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAF8F3FFFBF7F6FFF5F4F2FF723D
      1AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFF
      FFFF5E351DFFFBF6F3FFF9F6F2FFFBF6F3FFF9F7F2FFF8F6F2FFFAF7F4FF6436
      17FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF
      FFFFD4C2B4FFFAF7F4FFF9F6F3FFFAF7F5FFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBF8F4FFFBF8F4FFF6F2F0FFFBF7
      F8FFF9F5F0FF6F3816FFFFFFFFFFFFFFFEFFFFFFFEFFFFFEFFFF542910FFFBF6
      F1FFFAF6F4FFF9F6F2FFFBF6F3FFFAF7F4FFFAF7F3FFFAF7F5FFFAF7F3FFFAF7
      F3FFFAFBF4FF6F3E19FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF713F1CFFFBF7
      F6FFFBF8F4FFF9F6F3FFFAF7F3FFFBF8F6FFFEFEFE00FEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAF7F5FFFBF8F5FFF9F6F4FFFAF7
      F5FFFBF8F5FFFAF7F5FFFAF6F4FFFBF7F3FFF9F8F5FFFAF6F3FFF9F7F5FFFBF7
      F6FFFBF7F6FFFAF6F4FFFAF7F3FFFBF7F3FFF9F6F4FFFAF6F5FFFAF7F5FFFAF7
      F5FFFBF7F6FFF9F6F4FFF5F7F5FFFDF6F3FFFDF6F3FFFAF7F3FFFAF6F5FFFAF6
      F5FFFAF7F5FFFBF6F3FFF9F6F4FFF9F6F1FF424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 392
    Top = 488
  end
  object PaneStyle2: TJvNavPaneStyleManager
    Theme = nptXPSilver
    Left = 496
    Top = 488
  end
end
