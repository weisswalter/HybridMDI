object frmKlient: TfrmKlient
  Left = 0
  Top = 0
  Caption = 'Klienten'
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
    Top = 40
    Width = 5
    Height = 610
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblSemesterFilter: TLabel
      Left = 8
      Top = 13
      Width = 48
      Height = 15
      Caption = 'Semester'
    end
    object cboSemesterFilter: TDBLookupComboBox
      Left = 70
      Top = 8
      Width = 300
      Height = 23
      KeyField = 'semester_id'
      ListField = 'bezeichnung'
      ListSource = dmKlient.dsSemesterAuswahl
      TabOrder = 0
      OnCloseUp = cboSemesterFilterChange
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 40
    Width = 560
    Height = 610
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object pnlEdit: TPanel
      Left = 0
      Top = 0
      Width = 560
      Height = 610
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      ExplicitTop = 220
      ExplicitHeight = 390
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
        Height = 574
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        ExplicitHeight = 354
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
        object lblAbteilung: TLabel
          Left = 8
          Top = 112
          Width = 52
          Height = 15
          Caption = 'Abteilung'
        end
        object lblKunde: TLabel
          Left = 8
          Top = 164
          Width = 71
          Height = 15
          Caption = 'Kundenname'
        end
        object lblLeadquelle: TLabel
          Left = 8
          Top = 216
          Width = 64
          Height = 15
          Caption = 'Lead-Quelle'
        end
        object lblBesitzer: TLabel
          Left = 8
          Top = 268
          Width = 88
          Height = 15
          Caption = 'Klienten-Besitzer'
        end
        object edtVorname: TDBEdit
          Left = 8
          Top = 26
          Width = 250
          Height = 23
          DataField = 'vorname'
          DataSource = dmKlient.dstblPerson
          TabOrder = 0
        end
        object edtNachname: TDBEdit
          Left = 290
          Top = 26
          Width = 250
          Height = 23
          DataField = 'nachname_firmenname'
          DataSource = dmKlient.dstblPerson
          TabOrder = 1
        end
        object edtTitel: TDBEdit
          Left = 8
          Top = 78
          Width = 250
          Height = 23
          DataField = 'titel'
          DataSource = dmKlient.dstblPerson
          TabOrder = 2
        end
        object edtGeburtsdatum: TDBEdit
          Left = 290
          Top = 78
          Width = 150
          Height = 23
          DataField = 'geburtsdatum'
          DataSource = dmKlient.dstblPerson
          TabOrder = 3
        end
        object edtAbteilung: TDBEdit
          Left = 8
          Top = 130
          Width = 250
          Height = 23
          DataField = 'abteilung'
          DataSource = dmKlient.dstblKlient
          TabOrder = 4
        end
        object cboKunde: TDBLookupComboBox
          Left = 8
          Top = 182
          Width = 350
          Height = 23
          DataField = 'kunde_person_id'
          DataSource = dmKlient.dstblKlient
          KeyField = 'person_id'
          ListField = 'nachname_firmenname'
          ListSource = dmKlient.dsKundeAuswahl
          TabOrder = 5
        end
        object cboLeadquelle: TDBLookupComboBox
          Left = 8
          Top = 234
          Width = 250
          Height = 23
          DataField = 'leadquelle_id'
          DataSource = dmKlient.dstblKlient
          KeyField = 'leadquelle_id'
          ListField = 'bezeichnung'
          ListSource = dmKlient.dsLeadquelleAuswahl
          TabOrder = 6
        end
        object cboBesitzer: TDBLookupComboBox
          Left = 8
          Top = 286
          Width = 350
          Height = 23
          DataField = 'besitzer_person_id'
          DataSource = dmKlient.dstblKlient
          KeyField = 'person_id'
          ListField = 'nachname_firmenname'
          ListSource = dmKlient.dsMitarbeiterAuswahl
          TabOrder = 7
        end
        object dbgrdKlienten: TDBGrid
          Left = 0
          Top = 354
          Width = 560
          Height = 220
          Align = alBottom
          DataSource = dmKlient.dstblKlientenListe
          TabOrder = 8
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnCellClick = dbgrdKlientenCellClick
        end
      end
    end
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 565
    Top = 40
    Width = 435
    Height = 610
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
      end
      item
        Caption = 'Semester'
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
        ContentPanel = pnlSemester
      end>
    Align = alClient
    TabOrder = 2
    object pnlSemester: TPanel
      Left = 4
      Top = 75
      Width = 427
      Height = 531
      BevelOuter = bvNone
      Caption = 'pnlSemester'
      ShowCaption = False
      TabOrder = 3
      Visible = False
      object pnlSemesterAdd: TPanel
        Left = 0
        Top = 0
        Width = 427
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object cboSemesterHinzufuegen: TDBLookupComboBox
          Left = 8
          Top = 8
          Width = 200
          Height = 23
          KeyField = 'semester_id'
          ListField = 'bezeichnung'
          ListSource = dmKlient.dsSemesterAuswahl
          TabOrder = 0
        end
        object btnSemesterHinzufuegen: TButton
          Left = 216
          Top = 8
          Width = 85
          Height = 23
          Caption = 'Hinzuf'#252'gen'
          TabOrder = 1
          OnClick = btnSemesterHinzufuegenClick
        end
        object btnSemesterEntfernen: TButton
          Left = 306
          Top = 8
          Width = 85
          Height = 23
          Caption = 'Entfernen'
          TabOrder = 2
          OnClick = btnSemesterEntfernenClick
        end
      end
      object dbgrdSemester: TDBGrid
        Left = 0
        Top = 40
        Width = 427
        Height = 491
        Align = alClient
        DataSource = dmKlient.dstblKlientSemester
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object pnlKontaktdaten: TPanel
      Left = 4
      Top = 75
      Width = 427
      Height = 531
      BevelOuter = bvNone
      Caption = 'pnlKontaktdaten'
      ShowCaption = False
      TabOrder = 2
      object dbgrdEmail: TDBGrid
        Left = 0
        Top = 0
        Width = 427
        Height = 110
        Align = alTop
        DataSource = dmKlient.dstblEmailUebersicht
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
        DataSource = dmKlient.dstblTelefonUebersicht
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
        Height = 311
        Align = alClient
        DataSource = dmKlient.dstblAdresseUebersicht
        TabOrder = 2
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
    object actNeuR: TAction
      Tag = 4
      Caption = 'Neu'
    end
    object actAendernR: TAction
      Tag = 5
      Caption = #196'ndern'
    end
    object actSpeichernR: TAction
      Tag = 6
      Caption = 'Speichern'
    end
    object actAbbrechenR: TAction
      Tag = 7
      Caption = 'Abbrechen'
    end
    object actNeuLadenR: TAction
      Tag = 8
      Caption = 'Neu laden'
    end
  end
end
