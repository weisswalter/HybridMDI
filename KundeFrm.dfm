object frmKunde: TfrmKunde
  Left = 0
  Top = 0
  Caption = 'Kunden'
  ClientHeight = 650
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 560
    Top = 0
    Width = 5
    Height = 650
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 650
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object pnlEdit: TPanel
      Left = 0
      Top = 0
      Width = 560
      Height = 650
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      ExplicitTop = 250
      ExplicitHeight = 400
      object pnlEditButtons: TPanel
        Left = 0
        Top = 0
        Width = 560
        Height = 36
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object btnNeu: TJvNavPanelButtonTop
          Left = 0
          Top = 0
          Width = 90
          Height = 36
          Action = actNeu
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
          ExplicitLeft = 8
        end
        object btnAendern: TJvNavPanelButtonTop
          Left = 90
          Top = 0
          Width = 90
          Height = 36
          Action = actAendern
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
          ExplicitLeft = 98
        end
        object btnSpeichern: TJvNavPanelButtonTop
          Left = 180
          Top = 0
          Width = 90
          Height = 36
          Action = actSpeichern
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
          ExplicitLeft = 188
        end
        object btnAbbrechen: TJvNavPanelButtonTop
          Left = 270
          Top = 0
          Width = 90
          Height = 36
          Action = actAbbrechen
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
          ExplicitLeft = 278
        end
      end
      object pnlEditFelder: TPanel
        Left = 0
        Top = 36
        Width = 560
        Height = 614
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        ExplicitHeight = 364
        object lblName: TLabel
          Left = 8
          Top = 8
          Width = 32
          Height = 15
          Caption = 'Name'
        end
        object lblBesitzer: TLabel
          Left = 8
          Top = 60
          Width = 86
          Height = 15
          Caption = 'Kunden-Besitzer'
        end
        object edtName: TDBEdit
          Left = 8
          Top = 26
          Width = 350
          Height = 23
          DataField = 'nachname_firmenname'
          DataSource = dmKunde.dstblPerson
          TabOrder = 0
        end
        object cboBesitzer: TDBLookupComboBox
          Left = 8
          Top = 78
          Width = 350
          Height = 23
          DataField = 'besitzer_person_id'
          DataSource = dmKunde.dstblKunde
          KeyField = 'person_id'
          ListField = 'nachname_firmenname'
          ListSource = dmKunde.dsMitarbeiterAuswahl
          TabOrder = 1
        end
        object dbgrdKunden: TDBGrid
          Left = 0
          Top = 364
          Width = 560
          Height = 250
          Align = alBottom
          DataSource = dmKunde.dstblKundenListe
          TabOrder = 2
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnCellClick = dbgrdKundenCellClick
        end
      end
    end
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 565
    Top = 0
    Width = 435
    Height = 650
    Headers = <
      item
        Caption = 'Kontakte'
        Width = 110
        Actions = ActionListRechts
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
            Width = 75
          end
          item
            Action = actWeiterR
            Width = 70
          end
          item
            Action = actLetzterR
            Width = 75
          end>
        ContentPanel = pnlKontakte
      end
      item
        Caption = 'Kontaktdaten'
        Width = 140
        Actions = ActionListRechts
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
            Width = 75
          end
          item
            Action = actWeiterR
            Width = 70
          end
          item
            Action = actLetzterR
            Width = 75
          end>
        ContentPanel = pnlKontaktdaten
      end>
    Align = alClient
    TabOrder = 1
    object pnlKontaktdaten: TPanel
      Left = 4
      Top = 75
      Width = 427
      Height = 571
      BevelOuter = bvNone
      Caption = 'pnlKontaktdaten'
      ShowCaption = False
      TabOrder = 3
      Visible = False
      object dbgrdEmail: TDBGrid
        Left = 0
        Top = 0
        Width = 427
        Height = 110
        Align = alTop
        DataSource = dmKunde.dstblEmailUebersicht
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
      object dbgrdTelefon: TDBGrid
        Left = 0
        Top = 110
        Width = 427
        Height = 110
        Align = alTop
        DataSource = dmKunde.dstblTelefonUebersicht
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
      object dbgrdAdresse: TDBGrid
        Left = 0
        Top = 220
        Width = 427
        Height = 351
        Align = alClient
        DataSource = dmKunde.dstblAdresseUebersicht
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object pnlKontakte: TPanel
      Left = 4
      Top = 75
      Width = 427
      Height = 571
      BevelOuter = bvNone
      Caption = 'pnlKontakte'
      ShowCaption = False
      TabOrder = 2
      object dbgrdKontakte: TDBGrid
        Left = 0
        Top = 0
        Width = 427
        Height = 571
        Align = alClient
        DataSource = dmKunde.dstblKontakte
        TabOrder = 0
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
    Left = 720
    Top = 552
  end
  object ActionListEdit: TActionList
    Left = 800
    Top = 552
    object actNeu: TAction
      Caption = 'Neu'
      OnExecute = btnNeuClick
    end
    object actAendern: TAction
      Caption = #196'ndern'
      OnExecute = btnAendernClick
    end
    object actSpeichern: TAction
      Caption = 'Speichern'
      OnExecute = btnSpeichernClick
    end
    object actAbbrechen: TAction
      Caption = 'Abbrechen'
      OnExecute = btnAbbrechenClick
    end
  end
  object ActionListRechts: TActionList
    Left = 640
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
  end
end
