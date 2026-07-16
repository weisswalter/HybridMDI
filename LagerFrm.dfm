object frmLager: TfrmLager
  Left = 0
  Top = 0
  Caption = 'Lager'
  ClientHeight = 640
  ClientWidth = 1100
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
  object pnlButtons: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object btnErster: TJvNavPanelButtonTop
      Left = 0
      Top = 0
      Width = 58
      Height = 38
      Align = alLeft
      Alignment = taCenter
      Caption = 'Erster'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnZurueck: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnWeiter: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnLetzter: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnNeu: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnAendern: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnSpeichern: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnAbbrechen: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object btnNeuLaden: TJvNavPanelButtonTop
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
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
      OnClick = BtnNavClick
    end
    object grdtButtons: TJvGradient
      Left = 526
      Top = 0
      Width = 574
      Height = 38
      Style = grVertical
      StartColor = 16245453
      EndColor = 15966336
    end
  end
  object pnlFelder: TPanel
    Left = 0
    Top = 38
    Width = 1100
    Height = 286
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object lblBarcode: TLabel
      Left = 12
      Top = 8
      Width = 44
      Height = 15
      Caption = 'Barcode'
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
    object lblRaum: TLabel
      Left = 228
      Top = 8
      Width = 31
      Height = 15
      Caption = 'Raum'
    end
    object edtRaum: TJvDBMaskEdit
      Left = 228
      Top = 26
      Width = 70
      Height = 23
      DataField = 'raum_id'
      DataSource = dmLager.dstblLager
      TabOrder = 1
      EditMask = ''
    end
    object lblRegal: TLabel
      Left = 306
      Top = 8
      Width = 31
      Height = 15
      Caption = 'Regal'
    end
    object edtRegal: TJvDBMaskEdit
      Left = 306
      Top = 26
      Width = 70
      Height = 23
      DataField = 'regal_id'
      DataSource = dmLager.dstblLager
      TabOrder = 2
      EditMask = ''
    end
    object lblAdresse: TLabel
      Left = 392
      Top = 8
      Width = 44
      Height = 15
      Caption = 'Adresse'
    end
    object cboAdresse: TJvDBLookupCombo
      Left = 392
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
    object lblBeschreibung: TLabel
      Left = 12
      Top = 60
      Width = 68
      Height = 15
      Caption = 'Beschreibung'
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
    object lblPhoto: TLabel
      Left = 408
      Top = 60
      Width = 33
      Height = 15
      Caption = 'Photo'
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
    object lblQrCode: TLabel
      Left = 604
      Top = 60
      Width = 46
      Height = 15
      Caption = 'QR-Code'
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
    Width = 1100
    Height = 316
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
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 48
    Top = 592
  end
  object dlgBild: TOpenPictureDialog
    Filter =
      'Bilder (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Alle ' +
      'Dateien (*.*)|*.*'
    Left = 128
    Top = 592
  end
end
