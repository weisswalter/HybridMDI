object frmMitarbeiter: TfrmMitarbeiter
  Left = 0
  Top = 0
  Caption = 'Mitarbeiter'
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
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 650
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object dbgrdMitarbeiter: TDBGrid
      Left = 0
      Top = 0
      Width = 560
      Height = 250
      Align = alTop
      DataSource = dmMitarbeiter.dstblMitarbeiterListe
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdMitarbeiterCellClick
    end
    object pnlEdit: TPanel
      Left = 0
      Top = 250
      Width = 560
      Height = 400
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
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
          Left = 8
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
        end
        object btnAendern: TJvNavPanelButtonTop
          Left = 98
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
        end
        object btnSpeichern: TJvNavPanelButtonTop
          Left = 188
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
        end
        object btnAbbrechen: TJvNavPanelButtonTop
          Left = 278
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
        end
      end
      object pnlEditFelder: TPanel
        Left = 0
        Top = 36
        Width = 560
        Height = 364
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblVorname: TLabel
          Left = 8
          Top = 8
          Width = 42
          Height = 15
          Caption = 'Vorname'
        end
        object lblNachname: TLabel
          Left = 290
          Top = 8
          Width = 53
          Height = 15
          Caption = 'Nachname'
        end
        object lblTitel: TLabel
          Left = 8
          Top = 60
          Width = 25
          Height = 15
          Caption = 'Titel'
        end
        object lblGeburtsdatum: TLabel
          Left = 290
          Top = 60
          Width = 68
          Height = 15
          Caption = 'Geburtsdatum'
        end
        object lblRolle: TLabel
          Left = 8
          Top = 112
          Width = 30
          Height = 15
          Caption = 'Rolle'
        end
        object edtVorname: TDBEdit
          Left = 8
          Top = 26
          Width = 250
          Height = 23
          DataField = 'vorname'
          DataSource = dmMitarbeiter.dstblPerson
          TabOrder = 0
        end
        object edtNachname: TDBEdit
          Left = 290
          Top = 26
          Width = 250
          Height = 23
          DataField = 'nachname_firmenname'
          DataSource = dmMitarbeiter.dstblPerson
          TabOrder = 1
        end
        object edtTitel: TDBEdit
          Left = 8
          Top = 78
          Width = 250
          Height = 23
          DataField = 'titel'
          DataSource = dmMitarbeiter.dstblPerson
          TabOrder = 2
        end
        object edtGeburtsdatum: TDBEdit
          Left = 290
          Top = 78
          Width = 150
          Height = 23
          DataField = 'geburtsdatum'
          DataSource = dmMitarbeiter.dstblPerson
          TabOrder = 3
        end
        object cboRolle: TDBLookupComboBox
          Left = 8
          Top = 130
          Width = 350
          Height = 23
          DataField = 'rolle_id'
          DataSource = dmMitarbeiter.dstblPersonBeziehung
          KeyField = 'rolle_id'
          ListField = 'rollen_bezeichnung'
          ListSource = dmMitarbeiter.dsRolleAuswahl
          TabOrder = 4
        end
      end
    end
  end
  object Splitter1: TSplitter
    Left = 560
    Top = 0
    Width = 5
    Height = 650
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 565
    Top = 0
    Width = 435
    Height = 650
    Align = alClient
    TabOrder = 1
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    Headers = <
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
    ActivePageIndex = 0
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
  object pnlKontaktdaten: TPanel
    Left = 8
    Top = 680
    Width = 400
    Height = 400
    BevelOuter = bvNone
    Caption = 'pnlKontaktdaten'
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object dbgrdEmail: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 110
      Align = alTop
      DataSource = dmMitarbeiter.dstblEmailUebersicht
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
      Width = 400
      Height = 110
      Align = alTop
      DataSource = dmMitarbeiter.dstblTelefonUebersicht
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
      Width = 400
      Height = 180
      Align = alClient
      DataSource = dmMitarbeiter.dstblAdresseUebersicht
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
end
