inherited frmLager: TfrmLager
  Caption = 'Lager'
  ClientHeight = 700
  ClientWidth = 1100
  FormStyle = fsMDIChild
  Visible = True
  StyleElements = [seFont, seClient, seBorder]
  OnCreate = FormCreate
  ExplicitWidth = 1116
  ExplicitHeight = 739
  TextHeight = 15
  object pnlKopf: TPanel [0]
    Left = 0
    Top = 0
    Width = 1100
    Height = 31
    Align = alTop
    BevelOuter = bvNone
    Color = 12232890
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 1098
    object hdrLager: TJvNavPanelHeader
      Left = 4
      Top = 0
      Width = 70
      Height = 31
      Alignment = taCenter
      Caption = 'Lager'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 12232890
      ColorTo = 9532021
      ImageIndex = 0
      StyleManager = PaneStyle2
      ParentStyleManager = False
      OnClick = KopfClick
    end
    object hdrRaeume: TJvNavPanelHeader
      Tag = 1
      Left = 74
      Top = 0
      Width = 74
      Height = 31
      Alignment = taCenter
      Caption = 'R'#228'ume'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 12232890
      ColorTo = 9532021
      ImageIndex = 0
      StyleManager = PaneStyle2
      ParentStyleManager = False
      OnClick = KopfClick
    end
    object hdrRegale: TJvNavPanelHeader
      Tag = 2
      Left = 148
      Top = 0
      Width = 74
      Height = 31
      Alignment = taCenter
      Caption = 'Regale'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 12232890
      ColorTo = 9532021
      ImageIndex = 0
      StyleManager = PaneStyle2
      ParentStyleManager = False
      OnClick = KopfClick
    end
    object hdrAdressinfo: TJvNavPanelHeader
      Tag = 3
      Left = 222
      Top = 0
      Width = 96
      Height = 31
      Alignment = taCenter
      Caption = 'Adressinfo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 12232890
      ColorTo = 9532021
      ImageIndex = 0
      StyleManager = PaneStyle2
      ParentStyleManager = False
      OnClick = KopfClick
    end
    object hdrAusstattung: TJvNavPanelHeader
      Tag = 4
      Left = 318
      Top = 0
      Width = 106
      Height = 31
      Alignment = taCenter
      Caption = 'Ausstattung'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 12232890
      ColorTo = 9532021
      ImageIndex = 0
      StyleManager = PaneStyle2
      ParentStyleManager = False
      OnClick = KopfClick
    end
  end
  object pctrModule: TPageControl [1]
    Left = 0
    Top = 31
    Width = 1100
    Height = 669
    ActivePage = tsAusstattung
    Align = alClient
    Style = tsFlatButtons
    TabHeight = 10
    TabOrder = 1
    ExplicitWidth = 1098
    ExplicitHeight = 661
    object tsLager: TTabSheet
      Margins.Left = 0
      Margins.Top = 25
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = 'Lager'
      TabVisible = False
      object pnlBtnLager: TPanel
        Left = 0
        Top = 0
        Width = 1092
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object btnErsterLager: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Erster'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnZurueckLager: TJvNavPanelButtonTop
          Tag = 1
          Left = 58
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Zur'#252'ck'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnWeiterLager: TJvNavPanelButtonTop
          Tag = 2
          Left = 116
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Weiter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnLetzterLager: TJvNavPanelButtonTop
          Tag = 3
          Left = 174
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Letzter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuLager: TJvNavPanelButtonTop
          Tag = 4
          Left = 232
          Top = 0
          Width = 44
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAendernLager: TJvNavPanelButtonTop
          Tag = 5
          Left = 276
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = #196'ndern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnSpeichernLager: TJvNavPanelButtonTop
          Tag = 6
          Left = 334
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Speichern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAbbrechenLager: TJvNavPanelButtonTop
          Tag = 7
          Left = 398
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Abbrechen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuLadenLager: TJvNavPanelButtonTop
          Tag = 8
          Left = 462
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu laden'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object grdtLager: TJvGradient
          Left = 526
          Top = 0
          Width = 566
          Height = 38
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitWidth = 538
        end
      end
      object pnlFldLager: TPanel
        Left = 0
        Top = 38
        Width = 1092
        Height = 286
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblBarcode: TLabel
          Left = 12
          Top = 8
          Width = 43
          Height = 15
          Caption = 'Barcode'
        end
        object lblRaum: TLabel
          Left = 228
          Top = 8
          Width = 31
          Height = 15
          Caption = 'Raum'
        end
        object lblRegal: TLabel
          Left = 460
          Top = 8
          Width = 29
          Height = 15
          Caption = 'Regal'
        end
        object lblAdresse: TLabel
          Left = 692
          Top = 8
          Width = 41
          Height = 15
          Caption = 'Adresse'
        end
        object lblBeschreibung: TLabel
          Left = 12
          Top = 60
          Width = 72
          Height = 15
          Caption = 'Beschreibung'
        end
        object lblPhoto: TLabel
          Left = 408
          Top = 60
          Width = 32
          Height = 15
          Caption = 'Photo'
        end
        object lblQrCode: TLabel
          Left = 604
          Top = 60
          Width = 49
          Height = 15
          Caption = 'QR-Code'
        end
        object edtBarcode: TJvDBMaskEdit
          Left = 12
          Top = 26
          Width = 200
          Height = 23
          DataField = 'barcode'
          DataSource = dmLager.dstblLager
          TabOrder = 0
          EditMask = ''
        end
        object cboRaum: TJvDBLookupCombo
          Left = 228
          Top = 26
          Width = 220
          Height = 23
          DataField = 'raum_id'
          DataSource = dmLager.dstblLager
          LookupField = 'raum_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsRaumLookup
          TabOrder = 1
        end
        object cboRegal: TJvDBLookupCombo
          Left = 460
          Top = 26
          Width = 220
          Height = 23
          DataField = 'regal_id'
          DataSource = dmLager.dstblLager
          LookupField = 'regal_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsRegalLookup
          TabOrder = 2
        end
        object cboAdresse: TJvDBLookupCombo
          Left = 692
          Top = 26
          Width = 320
          Height = 23
          DataField = 'adresse_id'
          DataSource = dmLager.dstblLager
          LookupField = 'adresse_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsAdressen
          TabOrder = 3
        end
        object memBeschreibung: TDBMemo
          Left = 12
          Top = 78
          Width = 380
          Height = 160
          DataField = 'beschreibung'
          DataSource = dmLager.dstblLager
          TabOrder = 4
        end
        object imgPhoto: TDBImage
          Left = 408
          Top = 78
          Width = 180
          Height = 160
          DataField = 'photo'
          DataSource = dmLager.dstblLager
          Stretch = True
          TabOrder = 5
        end
        object btnPhotoLaden: TButton
          Left = 408
          Top = 244
          Width = 120
          Height = 25
          Caption = 'Bild laden...'
          TabOrder = 6
          OnClick = btnPhotoLadenClick
        end
        object imgQrCode: TDBImage
          Left = 604
          Top = 78
          Width = 180
          Height = 160
          DataField = 'qrcode'
          DataSource = dmLager.dstblLager
          Stretch = True
          TabOrder = 7
        end
        object btnQrLaden: TButton
          Left = 604
          Top = 244
          Width = 120
          Height = 25
          Caption = 'Bild laden...'
          TabOrder = 8
          OnClick = btnQrLadenClick
        end
      end
      object grdLager: TDBGrid
        Left = 0
        Top = 324
        Width = 1092
        Height = 335
        Align = alClient
        DataSource = dmLager.dstblLager
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tsRaeume: TTabSheet
      Margins.Left = 0
      Margins.Top = 25
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = 'R'#228'ume'
      TabVisible = False
      object pnlBtnRaeume: TPanel
        Left = 0
        Top = 0
        Width = 1092
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object btnErsterRaeume: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Erster'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnZurueckRaeume: TJvNavPanelButtonTop
          Tag = 1
          Left = 58
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Zur'#252'ck'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnWeiterRaeume: TJvNavPanelButtonTop
          Tag = 2
          Left = 116
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Weiter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnLetzterRaeume: TJvNavPanelButtonTop
          Tag = 3
          Left = 174
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Letzter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuRaeume: TJvNavPanelButtonTop
          Tag = 4
          Left = 232
          Top = 0
          Width = 44
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAendernRaeume: TJvNavPanelButtonTop
          Tag = 5
          Left = 276
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = #196'ndern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnSpeichernRaeume: TJvNavPanelButtonTop
          Tag = 6
          Left = 334
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Speichern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAbbrechenRaeume: TJvNavPanelButtonTop
          Tag = 7
          Left = 398
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Abbrechen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuLadenRaeume: TJvNavPanelButtonTop
          Tag = 8
          Left = 462
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu laden'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object grdtRaeume: TJvGradient
          Left = 526
          Top = 0
          Width = 566
          Height = 38
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitWidth = 538
        end
      end
      object pnlFldRaeume: TPanel
        Left = 0
        Top = 38
        Width = 1092
        Height = 347
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblRaumAdresse: TLabel
          Left = 12
          Top = 8
          Width = 41
          Height = 15
          Caption = 'Adresse'
        end
        object lblRaumAdressinfo: TLabel
          Left = 344
          Top = 8
          Width = 111
          Height = 15
          Caption = 'Adressinfo (optional)'
        end
        object lblRaumBezeichnung: TLabel
          Left = 12
          Top = 104
          Width = 68
          Height = 15
          Caption = 'Bezeichnung'
        end
        object lblLaenge: TLabel
          Left = 12
          Top = 60
          Width = 54
          Height = 15
          Caption = 'L'#228'nge (m)'
        end
        object lblBreite: TLabel
          Left = 104
          Top = 60
          Width = 52
          Height = 15
          Caption = 'Breite (m)'
        end
        object lblHoehe: TLabel
          Left = 196
          Top = 60
          Width = 51
          Height = 15
          Caption = 'H'#246'he (m)'
        end
        object lblRaumBeschreibung: TLabel
          Left = 344
          Top = 60
          Width = 72
          Height = 15
          Caption = 'Beschreibung'
        end
        object cboRaumAdresse: TJvDBLookupCombo
          Left = 12
          Top = 26
          Width = 320
          Height = 23
          DataField = 'adresse_id'
          DataSource = dmLager.dstblRaum
          LookupField = 'adresse_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsAdressen
          TabOrder = 0
        end
        object cboRaumAdressinfo: TJvDBLookupCombo
          Left = 344
          Top = 26
          Width = 320
          Height = 23
          DataField = 'adressinfo_id'
          DataSource = dmLager.dstblRaum
          LookupField = 'adressinfo_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsAdressinfoLookup
          TabOrder = 1
        end
        object edtRaumBezeichnung: TJvDBMaskEdit
          Left = 12
          Top = 122
          Width = 220
          Height = 23
          DataField = 'bezeichnung'
          DataSource = dmLager.dstblRaum
          TabOrder = 2
          EditMask = ''
        end
        object edtLaenge: TJvDBMaskEdit
          Left = 12
          Top = 78
          Width = 80
          Height = 23
          DataField = 'laenge'
          DataSource = dmLager.dstblRaum
          TabOrder = 3
          EditMask = ''
        end
        object edtBreite: TJvDBMaskEdit
          Left = 104
          Top = 78
          Width = 80
          Height = 23
          DataField = 'breite'
          DataSource = dmLager.dstblRaum
          TabOrder = 4
          EditMask = ''
        end
        object edtHoehe: TJvDBMaskEdit
          Left = 196
          Top = 78
          Width = 80
          Height = 23
          DataField = 'hoehe'
          DataSource = dmLager.dstblRaum
          TabOrder = 5
          EditMask = ''
        end
        object memRaumBeschreibung: TDBMemo
          Left = 344
          Top = 78
          Width = 500
          Height = 67
          DataField = 'beschreibung'
          DataSource = dmLager.dstblRaum
          TabOrder = 6
        end
        object grdRaeume: TDBGrid
          Left = 0
          Top = 168
          Width = 1092
          Height = 179
          Align = alBottom
          DataSource = dmLager.dstblRaum
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 7
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
      object pnlAusstattungBox: TPanel
        Left = 0
        Top = 385
        Width = 1092
        Height = 189
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 2
        ExplicitTop = 228
        object lblAusstattungBox: TLabel
          Left = 12
          Top = 4
          Width = 303
          Height = 15
          Caption = 'Ausstattung dieses Raums (mehrere gleichzeitig m'#246'glich)'
        end
        object pnlBtnRaumAusstattung: TPanel
          Left = 0
          Top = 0
          Width = 1092
          Height = 38
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object btnErsterRaumAusstattung: TJvNavPanelButtonTop
            Left = 0
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Erster'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnZurueckRaumAusstattung: TJvNavPanelButtonTop
            Tag = 1
            Left = 58
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Zur'#252'ck'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnWeiterRaumAusstattung: TJvNavPanelButtonTop
            Tag = 2
            Left = 116
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Weiter'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnLetzterRaumAusstattung: TJvNavPanelButtonTop
            Tag = 3
            Left = 174
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Letzter'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnNeuRaumAusstattung: TJvNavPanelButtonTop
            Tag = 4
            Left = 232
            Top = 0
            Width = 44
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Neu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnAendernRaumAusstattung: TJvNavPanelButtonTop
            Tag = 5
            Left = 276
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = #196'ndern'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnSpeichernRaumAusstattung: TJvNavPanelButtonTop
            Tag = 6
            Left = 334
            Top = 0
            Width = 64
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Speichern'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnAbbrechenRaumAusstattung: TJvNavPanelButtonTop
            Tag = 7
            Left = 398
            Top = 0
            Width = 64
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Abbrechen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnNeuLadenRaumAusstattung: TJvNavPanelButtonTop
            Tag = 8
            Left = 462
            Top = 0
            Width = 64
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Neu laden'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object grdtRaumAusstattung: TJvGradient
            Left = 526
            Top = 0
            Width = 566
            Height = 38
            Style = grVertical
            StartColor = 16245453
            EndColor = 15966336
            ExplicitWidth = 538
          end
        end
        object pnlFldRaumAusstattung: TPanel
          Left = 0
          Top = 38
          Width = 1092
          Height = 34
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 1
          object lblAusstattungHinzu: TLabel
            Left = 12
            Top = 8
            Width = 47
            Height = 15
            Caption = 'Merkmal'
          end
          object cboAusstattungHinzu: TJvDBLookupCombo
            Left = 76
            Top = 6
            Width = 260
            Height = 23
            DataField = 'ausstattungs_id'
            DataSource = dmLager.dstblRaumAusstattung
            LookupField = 'ausstattungs_id'
            LookupDisplay = 'bezeichnung'
            LookupSource = dmLager.dstblAusstattung
            TabOrder = 0
          end
        end
        object grdRaumAusstattung: TDBGrid
          Left = 0
          Top = 94
          Width = 1064
          Height = 91
          DataSource = dmLager.dstblRaumAusstattung
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 2
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsRegale: TTabSheet
      Margins.Left = 0
      Margins.Top = 25
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = 'Regale'
      TabVisible = False
      object pnlBtnRegale: TPanel
        Left = 0
        Top = 0
        Width = 1092
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object btnErsterRegale: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Erster'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnZurueckRegale: TJvNavPanelButtonTop
          Tag = 1
          Left = 58
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Zur'#252'ck'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnWeiterRegale: TJvNavPanelButtonTop
          Tag = 2
          Left = 116
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Weiter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnLetzterRegale: TJvNavPanelButtonTop
          Tag = 3
          Left = 174
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Letzter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuRegale: TJvNavPanelButtonTop
          Tag = 4
          Left = 232
          Top = 0
          Width = 44
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAendernRegale: TJvNavPanelButtonTop
          Tag = 5
          Left = 276
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = #196'ndern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnSpeichernRegale: TJvNavPanelButtonTop
          Tag = 6
          Left = 334
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Speichern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAbbrechenRegale: TJvNavPanelButtonTop
          Tag = 7
          Left = 398
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Abbrechen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuLadenRegale: TJvNavPanelButtonTop
          Tag = 8
          Left = 462
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu laden'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object grdtRegale: TJvGradient
          Left = 526
          Top = 0
          Width = 566
          Height = 38
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitWidth = 538
        end
      end
      object pnlFldRegale: TPanel
        Left = 0
        Top = 38
        Width = 1092
        Height = 120
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblRegalRaum: TLabel
          Left = 12
          Top = 8
          Width = 31
          Height = 15
          Caption = 'Raum'
        end
        object lblRegalBezeichnung: TLabel
          Left = 344
          Top = 8
          Width = 68
          Height = 15
          Caption = 'Bezeichnung'
        end
        object lblRegalBeschreibung: TLabel
          Left = 12
          Top = 60
          Width = 72
          Height = 15
          Caption = 'Beschreibung'
        end
        object cboRegalRaum: TJvDBLookupCombo
          Left = 12
          Top = 26
          Width = 320
          Height = 23
          DataField = 'raum_id'
          DataSource = dmLager.dstblRegal
          LookupField = 'raum_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsRaumLookup
          TabOrder = 0
        end
        object edtRegalBezeichnung: TJvDBMaskEdit
          Left = 344
          Top = 26
          Width = 220
          Height = 23
          DataField = 'bezeichnung'
          DataSource = dmLager.dstblRegal
          TabOrder = 1
          EditMask = ''
        end
        object memRegalBeschreibung: TDBMemo
          Left = 12
          Top = 78
          Width = 500
          Height = 36
          DataField = 'beschreibung'
          DataSource = dmLager.dstblRegal
          TabOrder = 2
        end
      end
      object pnlFaecherBox: TPanel
        Left = 0
        Top = 158
        Width = 1092
        Height = 130
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 2
        object lblFaecherBox: TLabel
          Left = 12
          Top = 4
          Width = 107
          Height = 15
          Caption = 'F'#228'cher dieses Regals'
        end
        object pnlBtnFaecher: TPanel
          Left = 0
          Top = 0
          Width = 1092
          Height = 38
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object btnErsterFaecher: TJvNavPanelButtonTop
            Left = 0
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Erster'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnZurueckFaecher: TJvNavPanelButtonTop
            Tag = 1
            Left = 58
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Zur'#252'ck'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnWeiterFaecher: TJvNavPanelButtonTop
            Tag = 2
            Left = 116
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Weiter'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnLetzterFaecher: TJvNavPanelButtonTop
            Tag = 3
            Left = 174
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Letzter'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnNeuFaecher: TJvNavPanelButtonTop
            Tag = 4
            Left = 232
            Top = 0
            Width = 44
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Neu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnAendernFaecher: TJvNavPanelButtonTop
            Tag = 5
            Left = 276
            Top = 0
            Width = 58
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = #196'ndern'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnSpeichernFaecher: TJvNavPanelButtonTop
            Tag = 6
            Left = 334
            Top = 0
            Width = 64
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Speichern'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnAbbrechenFaecher: TJvNavPanelButtonTop
            Tag = 7
            Left = 398
            Top = 0
            Width = 64
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Abbrechen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object btnNeuLadenFaecher: TJvNavPanelButtonTop
            Tag = 8
            Left = 462
            Top = 0
            Width = 64
            Height = 38
            Align = alLeft
            Alignment = taCenter
            Caption = 'Neu laden'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            StyleManager = PaneStyle1
            ParentStyleManager = False
            ImageIndex = 0
            OnClick = BtnNavClick
          end
          object grdtFaecher: TJvGradient
            Left = 526
            Top = 0
            Width = 566
            Height = 38
            Style = grVertical
            StartColor = 16245453
            EndColor = 15966336
            ExplicitWidth = 538
          end
        end
        object pnlFldFaecher: TPanel
          Left = 0
          Top = 38
          Width = 1092
          Height = 34
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 1
          object lblFaecherBezeichnung: TLabel
            Left = 12
            Top = 10
            Width = 68
            Height = 15
            Caption = 'Bezeichnung'
          end
          object lblFaecherKapazitaet: TLabel
            Left = 272
            Top = 10
            Width = 48
            Height = 15
            Caption = 'Kapazit'#228't'
          end
          object lblFaecherEinheit: TLabel
            Left = 422
            Top = 10
            Width = 36
            Height = 15
            Caption = 'Einheit'
          end
          object edtFaecherBezeichnung: TJvDBMaskEdit
            Left = 100
            Top = 6
            Width = 160
            Height = 23
            DataField = 'bezeichnung'
            DataSource = dmLager.dstblRegalFach
            TabOrder = 0
            EditMask = ''
          end
          object edtFaecherKapazitaet: TJvDBMaskEdit
            Left = 330
            Top = 6
            Width = 80
            Height = 23
            DataField = 'kapazitaet'
            DataSource = dmLager.dstblRegalFach
            TabOrder = 1
            EditMask = ''
          end
          object cboFaecherEinheit: TJvDBLookupCombo
            Left = 470
            Top = 6
            Width = 180
            Height = 23
            DataField = 'einheit_id'
            DataSource = dmLager.dstblRegalFach
            LookupField = 'einheit_id'
            LookupDisplay = 'name'
            LookupSource = dmLager.dsEinheitLookup
            TabOrder = 2
          end
        end
        object grdFaecher: TDBGrid
          Left = 0
          Top = 94
          Width = 1064
          Height = 36
          DataSource = dmLager.dstblRegalFach
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 2
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
      object grdRegale: TDBGrid
        Left = 0
        Top = 408
        Width = 1092
        Height = 251
        DataSource = dmLager.dstblRegal
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 3
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tsAdressinfo: TTabSheet
      Margins.Left = 0
      Margins.Top = 25
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = 'Adressinfo'
      TabVisible = False
      object pnlBtnAdressinfo: TPanel
        Left = 0
        Top = 0
        Width = 1092
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object btnErsterAdressinfo: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Erster'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnZurueckAdressinfo: TJvNavPanelButtonTop
          Tag = 1
          Left = 58
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Zur'#252'ck'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnWeiterAdressinfo: TJvNavPanelButtonTop
          Tag = 2
          Left = 116
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Weiter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnLetzterAdressinfo: TJvNavPanelButtonTop
          Tag = 3
          Left = 174
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Letzter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuAdressinfo: TJvNavPanelButtonTop
          Tag = 4
          Left = 232
          Top = 0
          Width = 44
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAendernAdressinfo: TJvNavPanelButtonTop
          Tag = 5
          Left = 276
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = #196'ndern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnSpeichernAdressinfo: TJvNavPanelButtonTop
          Tag = 6
          Left = 334
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Speichern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAbbrechenAdressinfo: TJvNavPanelButtonTop
          Tag = 7
          Left = 398
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Abbrechen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuLadenAdressinfo: TJvNavPanelButtonTop
          Tag = 8
          Left = 462
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu laden'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object grdtAdressinfo: TJvGradient
          Left = 526
          Top = 0
          Width = 566
          Height = 38
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitWidth = 538
        end
      end
      object pnlFldAdressinfo: TPanel
        Left = 0
        Top = 38
        Width = 1092
        Height = 252
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblAdressinfoAdresse: TLabel
          Left = 12
          Top = 8
          Width = 41
          Height = 15
          Caption = 'Adresse'
        end
        object lblAdressinfoBeschreibung: TLabel
          Left = 12
          Top = 60
          Width = 185
          Height = 15
          Caption = 'Beschreibung (Eingang/Stockwerk)'
        end
        object cboAdressinfoAdresse: TJvDBLookupCombo
          Left = 12
          Top = 26
          Width = 400
          Height = 23
          DataField = 'adresse_id'
          DataSource = dmLager.dstblAdressinfo
          LookupField = 'adresse_id'
          LookupDisplay = 'anzeige'
          LookupSource = dmLager.dsAdressen
          TabOrder = 0
        end
        object memAdressinfoBeschreibung: TDBMemo
          Left = 12
          Top = 78
          Width = 500
          Height = 139
          DataField = 'beschreibung'
          DataSource = dmLager.dstblAdressinfo
          TabOrder = 1
        end
      end
      object grdAdressinfo: TDBGrid
        Left = 0
        Top = 296
        Width = 1092
        Height = 363
        Align = alBottom
        DataSource = dmLager.dstblAdressinfo
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tsAusstattung: TTabSheet
      Margins.Left = 0
      Margins.Top = 25
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = 'Ausstattung'
      TabVisible = False
      object pnlBtnAusstattung: TPanel
        Left = 0
        Top = 0
        Width = 1092
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        ExplicitWidth = 1090
        object btnErsterAusstattung: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Erster'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnZurueckAusstattung: TJvNavPanelButtonTop
          Tag = 1
          Left = 58
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Zur'#252'ck'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnWeiterAusstattung: TJvNavPanelButtonTop
          Tag = 2
          Left = 116
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Weiter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnLetzterAusstattung: TJvNavPanelButtonTop
          Tag = 3
          Left = 174
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Letzter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuAusstattung: TJvNavPanelButtonTop
          Tag = 4
          Left = 232
          Top = 0
          Width = 44
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAendernAusstattung: TJvNavPanelButtonTop
          Tag = 5
          Left = 276
          Top = 0
          Width = 58
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = #196'ndern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnSpeichernAusstattung: TJvNavPanelButtonTop
          Tag = 6
          Left = 334
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Speichern'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnAbbrechenAusstattung: TJvNavPanelButtonTop
          Tag = 7
          Left = 398
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Abbrechen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object btnNeuLadenAusstattung: TJvNavPanelButtonTop
          Tag = 8
          Left = 462
          Top = 0
          Width = 64
          Height = 38
          Align = alLeft
          Alignment = taCenter
          Caption = 'Neu laden'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
          ImageIndex = 0
          OnClick = BtnNavClick
        end
        object grdtAusstattung: TJvGradient
          Left = 526
          Top = 0
          Width = 566
          Height = 38
          Style = grVertical
          StartColor = 16245453
          EndColor = 15966336
          ExplicitWidth = 538
        end
      end
      object grdAusstattung: TDBGrid
        Left = 0
        Top = 38
        Width = 526
        Height = 139
        DataSource = dmLager.dstblAusstattung
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 48
    Top = 640
  end
  object PaneStyle2: TJvNavPaneStyleManager
    Theme = nptXPSilver
    Left = 128
    Top = 640
  end
  object dlgBild: TOpenPictureDialog
    Filter = 
      'Bilder (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Alle ' +
      'Dateien (*.*)|*.*'
    Left = 208
    Top = 640
  end
end
