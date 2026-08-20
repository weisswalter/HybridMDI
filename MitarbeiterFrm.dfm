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
          Left = 0
          Top = 0
          Width = 90
          Height = 36
          Action = actNeu
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
          Font.Height = -15
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
          Font.Height = -15
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
          Font.Height = -15
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
        Height = 364
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblVorname: TLabel
          Left = 8
          Top = 8
          Width = 47
          Height = 15
          Caption = 'Vorname'
        end
        object lblNachname: TLabel
          Left = 290
          Top = 8
          Width = 58
          Height = 15
          Caption = 'Nachname'
        end
        object lblTitel: TLabel
          Left = 8
          Top = 60
          Width = 23
          Height = 15
          Caption = 'Titel'
        end
        object lblGeburtsdatum: TLabel
          Left = 290
          Top = 60
          Width = 76
          Height = 15
          Caption = 'Geburtsdatum'
        end
        object lblRolle: TLabel
          Left = 8
          Top = 112
          Width = 26
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
  object JvRibbonPanel1: TRibbonPanel
    Left = 565
    Top = 0
    Width = 435
    Height = 650
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    TopPanel.Left = 0
    TopPanel.Top = 0
    TopPanel.Width = 435
    TopPanel.Height = 31
    TopPanel.Align = alTop
    TopPanel.BevelOuter = bvNone
    TopPanel.Caption = 'TopPanel'
    TopPanel.ShowCaption = False
    TopPanel.TabOrder = 1
    TopPanel.DesignSize = (
      435
      31)
    PageControl.Left = -1
    PageControl.Top = 29
    PageControl.Width = 437
    PageControl.Height = 622
    PageControl.Anchors = [akLeft, akTop, akRight, akBottom]
    PageControl.TabOrder = 0
    HeaderButtons = <
      item
        Caption = 'Kontaktdaten'
        Width = 140
      end>
    DesignSize = (
      435
      650)
    object tsKontaktdaten: TTabSheet
      Caption = 'Kontaktdaten'
      object barKontaktdaten: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 437
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Gradient.Left = 0
        Gradient.Top = 0
        Gradient.Width = 437
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
      end
      object pnlKontaktdaten: TPanel
        Left = 0
        Top = 38
        Width = 437
        Height = 584
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlKontaktdaten'
        ShowCaption = False
        TabOrder = 1
        object dbgrdEmail: TDBGrid
          Left = 0
          Top = 0
          Width = 437
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
          Width = 437
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
          Width = 437
          Height = 364
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
