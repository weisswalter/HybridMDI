object frmArtikelStamm: TfrmArtikelStamm
  Left = 0
  Top = 0
  Caption = 'Artikel'
  ClientHeight = 600
  ClientWidth = 1115
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
    Left = 235
    Top = 0
    Width = 5
    Height = 600
    ExplicitLeft = 470
  end
  object pnlStamm: TPanel
    Left = 0
    Top = 0
    Width = 235
    Height = 600
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object pnlStammButtons: TPanel
      Left = 0
      Top = 0
      Width = 235
      Height = 38
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      ExplicitWidth = 353
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
      Width = 235
      Height = 562
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      ExplicitWidth = 352
      DesignSize = (
        235
        562)
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
        Anchors = [akLeft, akTop, akRight]
        DataField = 'artikel_nr'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 0
      end
      object edtArtikelname: TDBEdit
        Left = 16
        Top = 82
        Width = 200
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        DataField = 'artikelname'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 1
      end
      object edtSerienNr: TDBEdit
        Left = 16
        Top = 134
        Width = 200
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        DataField = 'serien_nr'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 2
      end
      object edtModulNr: TDBEdit
        Left = 16
        Top = 190
        Width = 200
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        DataField = 'modul_nr'
        DataSource = dmArtikelStamm.dstblArtikel
        TabOrder = 3
      end
      object memBeschreibung: TDBMemo
        Left = 16
        Top = 251
        Width = 200
        Height = 294
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataField = 'beschreibung'
        DataSource = dmArtikelStamm.dstblArtikel
        ScrollBars = ssVertical
        TabOrder = 4
      end
    end
  end
  object rbnpnl1: TRibbonPanel
    Left = 240
    Top = 0
    Width = 875
    Height = 600
    Align = alClient
    BevelOuter = bvNone
    Caption = 'rbnpnl1'
    ShowCaption = False
    TabOrder = 1
    TopPanel.Left = 0
    TopPanel.Top = 0
    TopPanel.Width = 875
    TopPanel.Height = 31
    TopPanel.Align = alTop
    TopPanel.BevelOuter = bvNone
    TopPanel.Caption = 'TopPanel'
    TopPanel.ShowCaption = False
    TopPanel.TabOrder = 1
    TopPanel.ExplicitWidth = 757
    TopPanel.DesignSize = (
      875
      31)
    PageControl.Left = -1
    PageControl.Top = 29
    PageControl.Width = 877
    PageControl.Height = 572
    PageControl.ActivePage = tsPhotos
    PageControl.Anchors = [akLeft, akTop, akRight, akBottom]
    PageControl.TabOrder = 0
    PageControl.ExplicitWidth = 759
    HeaderButtons = <
      item
        Caption = 'Fotos'
      end
      item
        Caption = 'Bestand'
      end
      item
        Caption = 'St'#252'ckliste'
      end
      item
        Caption = 'Varianten'
      end>
    ExplicitLeft = 358
    ExplicitWidth = 757
    DesignSize = (
      875
      600)
    object tsPhotos: TTabSheet
      Caption = 'Fotos'
      object barFotos: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 877
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        Gradient.Left = 0
        Gradient.Top = 0
        Gradient.Width = 877
        Gradient.Height = 38
        Gradient.Style = grVertical
        Gradient.StartColor = 16245453
        Gradient.EndColor = 15966336
        Gradient.ExplicitWidth = 0
        Gradient.ExplicitHeight = 0
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
        ExplicitWidth = 759
      end
      object pnlFotos: TPanel
        Left = 0
        Top = 38
        Width = 877
        Height = 534
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlFotos'
        ShowCaption = False
        TabOrder = 0
        ExplicitLeft = 7
        ExplicitTop = 15
        object lblFotoBeschr: TLabel
          Left = 7
          Top = 6
          Width = 72
          Height = 15
          Caption = 'Beschreibung'
        end
        object dbimgFoto: TDBImage
          Left = 312
          Top = 32
          Width = 273
          Height = 285
          DataField = 'foto'
          DataSource = dmArtikelStamm.dstblArtikelFoto
          TabOrder = 0
        end
        object btnFotoLaden: TButton
          Left = 616
          Top = 197
          Width = 120
          Height = 25
          Caption = 'Foto laden...'
          TabOrder = 1
          OnClick = btnFotoLadenClick
        end
        object dbgrdFotos: TDBGrid
          Left = 7
          Top = 143
          Width = 250
          Height = 167
          DataSource = dmArtikelStamm.dstblArtikelFoto
          TabOrder = 2
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'reihenfolge'
              Title.Caption = 'Foto'
              Width = 190
              Visible = True
            end>
        end
        object dbmmobeschreibung: TDBMemo
          Left = 7
          Top = 32
          Width = 256
          Height = 92
          DataField = 'beschreibung'
          DataSource = dmArtikelStamm.dstblArtikelFoto
          ScrollBars = ssVertical
          TabOrder = 3
        end
      end
    end
    object tsBestandRP: TTabSheet
      Caption = 'Bestand'
      object pnlBestand: TPanel
        Left = 0
        Top = 0
        Width = 877
        Height = 572
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlBestand'
        ShowCaption = False
        TabOrder = 0
        ExplicitWidth = 759
        object vstBestand: TVirtualStringTree
          Left = 0
          Top = 0
          Width = 877
          Height = 572
          Align = alClient
          Header.AutoSizeIndex = 0
          Header.Height = 15
          Header.MainColumn = -1
          TabOrder = 0
          Touch.InteractiveGestures = [igPan, igPressAndTap]
          Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
          ExplicitWidth = 759
          Columns = <>
        end
      end
    end
    object tsStuecklisteRP: TTabSheet
      Caption = 'St'#252'ckliste'
      object pnlStueckliste: TPanel
        Left = 0
        Top = 0
        Width = 877
        Height = 572
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlStueckliste'
        ShowCaption = False
        TabOrder = 0
        ExplicitWidth = 759
        object pnlStuecklisteAdd: TPanel
          Left = 0
          Top = 0
          Width = 877
          Height = 572
          Align = alClient
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          ExplicitWidth = 759
          object lblUnterArtikel: TLabel
            Left = 8
            Top = 8
            Width = 61
            Height = 15
            Caption = 'Unterartikel'
          end
          object lblStkMenge: TLabel
            Left = 300
            Top = 8
            Width = 37
            Height = 15
            Caption = 'Menge'
          end
          object btnStkAdd: TJvNavPanelButtonTop
            Left = 8
            Top = 50
            Width = 130
            Alignment = taCenter
            Caption = 'Hinzuf'#252'gen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = btnStkAddClick
          end
          object btnStkDel: TJvNavPanelButtonTop
            Left = 144
            Top = 50
            Width = 130
            Alignment = taCenter
            Caption = 'Entfernen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = btnStkDelClick
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
        end
        object vstStueckliste: TVirtualStringTree
          Left = 0
          Top = 0
          Width = 407
          Height = 492
          Header.AutoSizeIndex = 0
          Header.Height = 15
          Header.MainColumn = -1
          TabOrder = 1
          Touch.InteractiveGestures = [igPan, igPressAndTap]
          Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
          Columns = <>
        end
      end
    end
    object tsVarianten: TTabSheet
      Caption = 'Varianten'
      object barVarianten: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 877
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        ButtonWidth = 96
        Buttons = <
          item
            Action = actVarMerkmal
          end
          item
            Action = actVarUnterelement
          end
          item
            Action = actVarGleicheEbene
          end
          item
            Action = actVarLoeschen
          end
          item
            Action = actVarNeuLaden
          end>
      end
      object pnlAequivalenz: TPanel
        Left = 0
        Top = 38
        Width = 877
        Height = 44
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblAequivalenz: TLabel
          Left = 8
          Top = 14
          Width = 62
          Height = 15
          Caption = 'Entspricht:'
        end
        object lblGleich: TLabel
          Left = 342
          Top = 14
          Width = 13
          Height = 15
          Caption = '='
        end
        object cboAequivalenzA: TComboBox
          Left = 76
          Top = 10
          Width = 260
          Height = 23
          Style = csDropDownList
          TabOrder = 0
        end
        object cboAequivalenzB: TComboBox
          Left = 363
          Top = 10
          Width = 260
          Height = 23
          Style = csDropDownList
          TabOrder = 1
        end
        object btnGleichsetzen: TJvNavPanelButtonTop
          Left = 634
          Top = 3
          Width = 110
          Height = 38
          Alignment = taCenter
          Caption = 'Gleichsetzen'
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
        object btnAequivalenzLoesen: TJvNavPanelButtonTop
          Left = 744
          Top = 3
          Width = 110
          Height = 38
          Alignment = taCenter
          Caption = 'Aufheben'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle2
          ParentStyleManager = False
          ImageIndex = 0
        end
      end
      object pnlVarianten: TPanel
        Left = 0
        Top = 82
        Width = 877
        Height = 460
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 2
        object vstVarianten: TVirtualStringTree
          Left = 0
          Top = 0
          Width = 877
          Height = 460
          Align = alClient
          Header.AutoSizeIndex = 0
          Header.Height = 24
          Header.MainColumn = -1
          TabOrder = 0
          Touch.InteractiveGestures = [igPan, igPressAndTap]
          Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
          Columns = <>
        end
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
  object ActionListVarianten: TActionList
    Left = 392
    Top = 552
    object actVarMerkmal: TAction
      Caption = 'Merkmal'
      Hint = 'Neues Merkmal auf oberster Ebene anlegen'
      OnExecute = VariantenAktionExecute
    end
    object actVarUnterelement: TAction
      Tag = 1
      Caption = 'Unterelement'
      Hint = 'Unterelement zum markierten Eintrag anlegen'
      OnExecute = VariantenAktionExecute
    end
    object actVarGleicheEbene: TAction
      Tag = 2
      Caption = 'Gleiche Ebene'
      Hint = 'Neuen Eintrag neben dem markierten anlegen'
      OnExecute = VariantenAktionExecute
    end
    object actVarLoeschen: TAction
      Tag = 3
      Caption = 'L'#246'schen'
      Hint = 'Markierten Eintrag l'#246'schen'
      OnExecute = VariantenAktionExecute
    end
    object actVarNeuLaden: TAction
      Tag = 4
      Caption = 'Neu laden'
      Hint = 'Merkmalsbaum neu laden'
      OnExecute = VariantenAktionExecute
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
  object dlgFoto: TOpenPictureDialog
    Filter = 
      'Bilder (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Alle ' +
      'Dateien (*.*)|*.*'
    Left = 368
    Top = 552
  end
end
