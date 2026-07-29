object frmLehrer: TfrmLehrer
  Left = 0
  Top = 0
  Caption = 'Lehrer'
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
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 620
    Height = 700
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object pnlEditButtons: TPanel
      Left = 0
      Top = 0
      Width = 620
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object btnAendern: TJvNavPanelButtonTop
        Left = 0
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
        Left = 90
        Top = 0
        Width = 100
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
        Left = 190
        Top = 0
        Width = 100
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
      object btnNeuLaden: TJvNavPanelButtonTop
        Left = 290
        Top = 0
        Width = 100
        Height = 36
        Action = actNeuLaden
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
    object dbgrdLehrer: TDBGrid
      Left = 0
      Top = 36
      Width = 620
      Height = 260
      Align = alTop
      DataSource = dmLehrer.dstblLehrer
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdLehrerCellClick
    end
    object pnlEditFelder: TPanel
      Left = 0
      Top = 296
      Width = 620
      Height = 404
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object lblVorname: TLabel
        Left = 8
        Top = 12
        Width = 48
        Height = 15
        Caption = 'Vorname'
      end
      object lblNachname: TLabel
        Left = 300
        Top = 12
        Width = 52
        Height = 15
        Caption = 'Nachname'
      end
      object lblTitel: TLabel
        Left = 8
        Top = 60
        Width = 26
        Height = 15
        Caption = 'Titel'
      end
      object lblGeburtsdatum: TLabel
        Left = 300
        Top = 60
        Width = 78
        Height = 15
        Caption = 'Geburtsdatum'
      end
      object lblBeschreibung: TLabel
        Left = 8
        Top = 108
        Width = 74
        Height = 15
        Caption = 'Beschreibung'
      end
      object lblHinweis: TLabel
        Left = 8
        Top = 300
        Width = 600
        Height = 48
        AutoSize = False
        Caption =
          'Lehrer werden im Personenfenster angelegt - dort wird das H'#228'kc'+
          'hen "Lehrer" gesetzt. Mit zus'#228'tzlichem H'#228'kchen "Mitarbeiter"'+
          ' gilt die Person als Lohnmitarbeiter, sonst als Honorarlehrer.'
        WordWrap = True
      end
      object edtVorname: TDBEdit
        Left = 8
        Top = 30
        Width = 280
        Height = 23
        DataField = 'vorname'
        DataSource = dmLehrer.dstblPerson
        TabOrder = 0
      end
      object edtNachname: TDBEdit
        Left = 300
        Top = 30
        Width = 300
        Height = 23
        DataField = 'nachname_firmenname'
        DataSource = dmLehrer.dstblPerson
        TabOrder = 1
      end
      object edtTitel: TDBEdit
        Left = 8
        Top = 78
        Width = 280
        Height = 23
        DataField = 'titel'
        DataSource = dmLehrer.dstblPerson
        TabOrder = 2
      end
      object edtGeburtsdatum: TDBEdit
        Left = 300
        Top = 78
        Width = 150
        Height = 23
        DataField = 'geburtsdatum'
        DataSource = dmLehrer.dstblPerson
        TabOrder = 3
      end
      object memBeschreibung: TDBMemo
        Left = 8
        Top = 126
        Width = 592
        Height = 160
        DataField = 'beschreibung'
        DataSource = dmLehrer.dstblPerson
        TabOrder = 4
      end
    end
  end
  object Splitter1: TSplitter
    Left = 620
    Top = 0
    Width = 5
    Height = 700
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 625
    Top = 0
    Width = 575
    Height = 700
    Align = alClient
    TabOrder = 1
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    Headers = <
      item
        Caption = 'Kompetenzen'
        Width = 130
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
        ContentPanel = pnlKompetenzen
      end
      item
        Caption = 'Kurse'
        Width = 100
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
        ContentPanel = pnlKurse
      end>
    ActivePageIndex = 0
  end
  object pnlKompetenzen: TPanel
    Left = 8
    Top = 780
    Width = 560
    Height = 560
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object pnlKompetenzAdd: TPanel
      Left = 0
      Top = 420
      Width = 560
      Height = 140
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblKompetenz: TLabel
        Left = 8
        Top = 8
        Width = 65
        Height = 15
        Caption = 'Kompetenz'
      end
      object lblErworben: TLabel
        Left = 8
        Top = 56
        Width = 78
        Height = 15
        Caption = 'Erworben am'
      end
      object lblGueltigBis: TLabel
        Left = 140
        Top = 56
        Width = 56
        Height = 15
        Caption = 'G'#252'ltig bis'
      end
      object lblBemerkung: TLabel
        Left = 300
        Top = 56
        Width = 64
        Height = 15
        Caption = 'Bemerkung'
      end
      object cboKompetenz: TDBLookupComboBox
        Left = 8
        Top = 26
        Width = 400
        Height = 23
        KeyField = 'kompetenz_id'
        ListField = 'bezeichnung'
        ListSource = dmLehrer.dsKompetenzAuswahl
        TabOrder = 0
      end
      object dtpErworben: TDateTimePicker
        Left = 8
        Top = 74
        Width = 120
        Height = 23
        Date = 46000.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 1
      end
      object dtpGueltigBis: TDateTimePicker
        Left = 140
        Top = 74
        Width = 120
        Height = 23
        Date = 46000.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 2
      end
      object cbxUnbefristet: TCheckBox
        Left = 140
        Top = 102
        Width = 130
        Height = 17
        Caption = 'unbefristet'
        TabOrder = 3
        OnClick = cbxUnbefristetClick
      end
      object edtBemerkung: TEdit
        Left = 300
        Top = 74
        Width = 250
        Height = 23
        TabOrder = 4
      end
      object btnKompetenzAdd: TButton
        Left = 300
        Top = 102
        Width = 120
        Height = 28
        Caption = 'Hinzuf'#252'gen'
        TabOrder = 5
        OnClick = btnKompetenzAddClick
      end
      object btnKompetenzDel: TButton
        Left = 428
        Top = 102
        Width = 120
        Height = 28
        Caption = 'Entfernen'
        TabOrder = 6
        OnClick = btnKompetenzDelClick
      end
    end
    object dbgrdKompetenzen: TDBGrid
      Left = 0
      Top = 0
      Width = 560
      Height = 420
      Align = alClient
      DataSource = dmLehrer.dstblKompetenzen
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlKurse: TPanel
    Left = 8
    Top = 780
    Width = 560
    Height = 560
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 3
    Visible = False
    object pnlKurseInfo: TPanel
      Left = 0
      Top = 512
      Width = 560
      Height = 48
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblKurseHinweis: TLabel
        Left = 8
        Top = 6
        Width = 540
        Height = 36
        AutoSize = False
        Caption =
          'Spalte "darf_halten": vergleicht die Kompetenzen dieser Person'+
          ' mit den Anforderungen des Kurses (Rolle "lehrer"). Abgelaufene'+
          ' Nachweise z'#228'hlen nicht mit.'
        WordWrap = True
      end
    end
    object dbgrdKurse: TDBGrid
      Left = 0
      Top = 0
      Width = 560
      Height = 512
      Align = alClient
      DataSource = dmLehrer.dstblKurse
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 900
    Top = 640
  end
  object ActionListEdit: TActionList
    Left = 960
    Top = 640
    object actAendern: TAction
      Caption = #196'ndern'
      OnExecute = actAendernExecute
    end
    object actSpeichern: TAction
      Caption = 'Speichern'
      OnExecute = actSpeichernExecute
    end
    object actAbbrechen: TAction
      Caption = 'Abbrechen'
      OnExecute = actAbbrechenExecute
    end
    object actNeuLaden: TAction
      Caption = 'Neu laden'
      OnExecute = actNeuLadenExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 1020
    Top = 640
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
