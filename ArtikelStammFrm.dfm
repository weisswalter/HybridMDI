object frmArtikelStamm: TfrmArtikelStamm
  Left = 0
  Top = 0
  Caption = 'Artikel'
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
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
        Width = 41
        Height = 38
        Action = actErsterL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
      end
      object btnZurueckStamm: TJvNavPanelButtonTop
        Left = 41
        Top = 0
        Width = 47
        Height = 38
        Action = actZurueckL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        ExplicitLeft = 35
        ExplicitTop = 6
      end
      object btnWeiterStamm: TJvNavPanelButtonTop
        Left = 88
        Top = 0
        Width = 46
        Height = 38
        Action = actWeiterL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
      end
      object btnLetzterStamm: TJvNavPanelButtonTop
        Left = 134
        Top = 0
        Width = 50
        Height = 38
        Action = actLetzterL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
      end
      object btnNeuStamm: TJvNavPanelButtonTop
        Left = 184
        Top = 0
        Width = 29
        Height = 38
        Action = actNeuL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
      end
      object btnAendernStamm: TJvNavPanelButtonTop
        Left = 213
        Top = 0
        Width = 50
        Height = 38
        Action = actAendernL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        ExplicitLeft = 253
        ExplicitTop = 6
      end
      object btnSpeichernStamm: TJvNavPanelButtonTop
        Left = 263
        Top = 0
        Width = 64
        Height = 38
        Action = actSpeichernL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        ExplicitLeft = 303
        ExplicitTop = 6
      end
      object btnAbbrechenStamm: TJvNavPanelButtonTop
        Left = 327
        Top = 0
        Width = 71
        Height = 38
        Action = actAbbrechenL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        ExplicitLeft = 326
      end
      object btnNeuLadenStamm: TJvNavPanelButtonTop
        Left = 398
        Top = 0
        Width = 61
        Height = 38
        Action = actNeuLadenL
        Align = alLeft
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        ExplicitLeft = 428
        ExplicitTop = 6
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
      object lblArtikelNr: TLabel
        Left = 16
        Top = 12
        Width = 55
        Height = 15
        Caption = 'Artikel-Nr.'
      end
      object lblArtikelname: TLabel
        Left = 16
        Top = 64
        Width = 64
        Height = 15
        Caption = 'Artikelname'
      end
      object lblSerienNr: TLabel
        Left = 16
        Top = 116
        Width = 53
        Height = 15
        Caption = 'Serien-Nr.'
      end
      object lblModulNr: TLabel
        Left = 16
        Top = 172
        Width = 56
        Height = 15
        Caption = 'Modul-Nr.'
      end
      object lblBeschreibung: TLabel
        Left = 16
        Top = 230
        Width = 72
        Height = 15
        Caption = 'Beschreibung'
      end
      object edtArtikelNr: TDBEdit
        Left = 16
        Top = 30
        Width = 200
        Height = 23
        DataField = 'artikel_nr'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 0
      end
      object edtArtikelname: TDBEdit
        Left = 16
        Top = 82
        Width = 200
        Height = 23
        DataField = 'artikelname'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 1
      end
      object edtSerienNr: TDBEdit
        Left = 16
        Top = 134
        Width = 200
        Height = 23
        DataField = 'serien_nr'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 2
      end
      object edtModulNr: TDBEdit
        Left = 16
        Top = 190
        Width = 200
        Height = 23
        DataField = 'modul_nr'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 3
      end
      object memBeschreibung: TDBMemo
        Left = 16
        Top = 251
        Width = 200
        Height = 238
        DataField = 'beschreibung'
        DataSource = dmArtikelStamm.dstblArtikel
        ScrollBars = ssVertical
        TabOrder = 4
      end
    end
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 475
    Top = 0
    Width = 425
    Height = 600
    Headers = <
      item
        Caption = 'Fotos'
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
        ContentPanel = pnlFotos
      end
      item
        Caption = 'Bestand'
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
        ContentPanel = pnlBestand
      end
      item
        Caption = 'St'#252'ckliste'
        Width = 110
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
        ContentPanel = pnlStueckliste
      end>
    ActivePageIndex = 1
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -7
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object pnlFotos: TPanel
      Left = 4
      Top = 75
      Width = 417
      Height = 521
      BevelOuter = bvNone
      Caption = 'pnlFotos'
      ShowCaption = False
      TabOrder = 2
      Visible = False
      object pnlFotoKopf: TPanel
        Left = 0
        Top = 0
        Width = 417
        Height = 90
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object lblFotoBeschr: TLabel
          Left = 8
          Top = 8
          Width = 43
          Height = 10
          Caption = 'Beschreibung'
        end
        object btnFotoLaden: TButton
          Left = 8
          Top = 58
          Width = 120
          Height = 25
          Caption = 'Foto laden...'
          TabOrder = 0
          OnClick = btnFotoLadenClick
        end
        object memFotoBeschr: TDBMemo
          Left = 136
          Top = 8
          Width = 256
          Height = 46
          DataField = 'beschreibung'
          DataSource = dmArtikelStamm.dstblArtikelFoto
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
      object dbgrdFotos: TDBGrid
        Left = 0
        Top = 90
        Width = 417
        Height = 150
        Align = alTop
        DataSource = dmArtikelStamm.dstblArtikelFoto
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -7
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
      end
      object dbimgFoto: TDBImage
        Left = 0
        Top = 240
        Width = 417
        Height = 281
        Align = alClient
        DataField = 'foto'
        DataSource = dmArtikelStamm.dstblArtikelFoto
        TabOrder = 2
      end
    end
    object pnlBestand: TPanel
      Left = 4
      Top = 75
      Width = 417
      Height = 521
      BevelOuter = bvNone
      Caption = 'pnlBestand'
      ShowCaption = False
      TabOrder = 3
      object vstBestand: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 417
        Height = 521
        Align = alClient
        DefaultNodeHeight = 14
        Header.AutoSizeIndex = 0
        Header.Height = 10
        Header.MainColumn = -1
        TabOrder = 0
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <>
      end
    end
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
  object ActionListRechts: TActionList
    Left = 288
    Top = 552
    object actErsterR: TAction
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
  object pnlStueckliste: TPanel

    Left = 8

    Top = 1440

    Width = 400

    Height = 400

    BevelOuter = bvNone

    Caption = 'pnlStueckliste'

    ShowCaption = False

    TabOrder = 4

    Visible = False

    object pnlStuecklisteAdd: TPanel

      Left = 0

      Top = 320

      Width = 400

      Height = 80

      Align = alBottom

      BevelOuter = bvNone

      ShowCaption = False

      TabOrder = 0

      object lblUnterArtikel: TLabel

        Left = 8

        Top = 8

        Width = 68

        Height = 15

        Caption = 'Unterartikel'

      end

      object lblStkMenge: TLabel

        Left = 300

        Top = 8

        Width = 39

        Height = 15

        Caption = 'Menge'

      end

      object cboUnterArtikel: TDBLookupComboBox

        Left = 8

        Top = 26

        Width = 280

        Height = 23

        KeyField = 'artikel_id'

        ListField = 'artikelname'

        ListSource = dmArtikelStamm.dsArtikelAuswahl

        TabOrder = 0

      end

      object edtStkMenge: TEdit

        Left = 300

        Top = 26

        Width = 90

        Height = 23

        TabOrder = 1

        Text = '1'

      end

      object btnStkAdd: TButton

        Left = 8

        Top = 52

        Width = 130

        Height = 25

        Caption = 'Hinzuf'#252'gen'

        TabOrder = 2

        OnClick = btnStkAddClick

      end

      object btnStkDel: TButton

        Left = 144

        Top = 52

        Width = 130

        Height = 25

        Caption = 'Entfernen'

        TabOrder = 3

        OnClick = btnStkDelClick

      end

    end

    object vstStueckliste: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 400
      Height = 320
      Align = alClient
      DefaultNodeHeight = 14
      Header.AutoSizeIndex = 0
      Header.Height = 10
      Header.MainColumn = -1
      TabOrder = 1
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <>
    end

  end

  object dlgFoto: TOpenPictureDialog
    Filter = 
      'Bilder (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Alle ' +
      'Dateien (*.*)|*.*'
    Left = 368
    Top = 552
  end
end
