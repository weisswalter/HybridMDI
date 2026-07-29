object frmKurs: TfrmKurs
  Left = 0
  Top = 0
  Caption = 'Kurse'
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
    Width = 560
    Height = 700
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object dbgrdKurse: TDBGrid
      Left = 0
      Top = 0
      Width = 560
      Height = 200
      Align = alTop
      DataSource = dmKurs.dstblKurs
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdKurseCellClick
    end
    object pnlEdit: TPanel
      Left = 0
      Top = 200
      Width = 560
      Height = 500
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
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleManager = PaneStyle1
          ParentStyleManager = False
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
        end
      end
      object pnlEditFelder: TPanel
        Left = 0
        Top = 36
        Width = 560
        Height = 464
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblKursNr: TLabel
          Left = 8
          Top = 8
          Width = 44
          Height = 15
          Caption = 'Kurs-Nr.'
        end
        object lblBezeichnung: TLabel
          Left = 160
          Top = 8
          Width = 63
          Height = 15
          Caption = 'Bezeichnung'
        end
        object lblStunden: TLabel
          Left = 8
          Top = 60
          Width = 98
          Height = 15
          Caption = 'Unterrichtsstunden'
        end
        object lblMinTn: TLabel
          Left = 160
          Top = 60
          Width = 71
          Height = 15
          Caption = 'Min. Teilneh.'
        end
        object lblMaxTn: TLabel
          Left = 280
          Top = 60
          Width = 74
          Height = 15
          Caption = 'Max. Teilneh.'
        end
        object lblPreis: TLabel
          Left = 400
          Top = 60
          Width = 83
          Height = 15
          Caption = 'Preis je Teiln.'
        end
        object lblLernziele: TLabel
          Left = 8
          Top = 112
          Width = 47
          Height = 15
          Caption = 'Lernziele'
        end
        object lblBeschreibung: TLabel
          Left = 8
          Top = 280
          Width = 72
          Height = 15
          Caption = 'Beschreibung'
        end
        object edtKursNr: TDBEdit
          Left = 8
          Top = 26
          Width = 140
          Height = 23
          DataField = 'kurs_nr'
          DataSource = dmKurs.dstblKurs
          TabOrder = 0
        end
        object edtBezeichnung: TDBEdit
          Left = 160
          Top = 26
          Width = 380
          Height = 23
          DataField = 'bezeichnung'
          DataSource = dmKurs.dstblKurs
          TabOrder = 1
        end
        object edtStunden: TDBEdit
          Left = 8
          Top = 78
          Width = 140
          Height = 23
          DataField = 'unterrichtsstunden'
          DataSource = dmKurs.dstblKurs
          TabOrder = 2
        end
        object edtMinTn: TDBEdit
          Left = 160
          Top = 78
          Width = 110
          Height = 23
          DataField = 'min_teilnehmer'
          DataSource = dmKurs.dstblKurs
          TabOrder = 3
        end
        object edtMaxTn: TDBEdit
          Left = 280
          Top = 78
          Width = 110
          Height = 23
          DataField = 'max_teilnehmer'
          DataSource = dmKurs.dstblKurs
          TabOrder = 4
        end
        object edtPreis: TDBEdit
          Left = 400
          Top = 78
          Width = 140
          Height = 23
          DataField = 'preis_pro_teilnehmer'
          DataSource = dmKurs.dstblKurs
          TabOrder = 5
        end
        object memLernziele: TDBMemo
          Left = 8
          Top = 130
          Width = 532
          Height = 140
          DataField = 'lernziele'
          DataSource = dmKurs.dstblKurs
          ScrollBars = ssVertical
          TabOrder = 6
        end
        object memBeschreibung: TDBMemo
          Left = 8
          Top = 298
          Width = 532
          Height = 150
          DataField = 'beschreibung'
          DataSource = dmKurs.dstblKurs
          ScrollBars = ssVertical
          TabOrder = 7
        end
      end
    end
  end
  object Splitter1: TSplitter
    Left = 560
    Top = 0
    Width = 5
    Height = 700
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 565
    Top = 0
    Width = 635
    Height = 700
    Align = alClient
    TabOrder = 1
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    Headers = <
      item
        Caption = 'Unterkurse'
        Width = 115
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
        ContentPanel = pnlUnterkurse
      end
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
        Caption = 'Material'
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
        ContentPanel = pnlMaterial
      end
      item
        Caption = 'Durchf'#252'hrung'
        Width = 135
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
        ContentPanel = pnlDurchfuehrung
      end
      item
        Caption = 'Termine'
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
        ContentPanel = pnlTermine
      end
      item
        Caption = 'Teilnehmer'
        Width = 115
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
        ContentPanel = pnlTeilnehmer
      end>
    ActivePageIndex = 0
  end
  object pnlUnterkurse: TPanel
    Left = 8
    Top = 760
    Width = 620
    Height = 560
    BevelOuter = bvNone
    Caption = 'pnlUnterkurse'
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object pnlUnterkurseAdd: TPanel
      Left = 0
      Top = 480
      Width = 620
      Height = 80
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblUnterkurs: TLabel
        Left = 8
        Top = 8
        Width = 51
        Height = 15
        Caption = 'Unterkurs'
      end
      object cboUnterkurs: TDBLookupComboBox
        Left = 8
        Top = 26
        Width = 300
        Height = 23
        KeyField = 'kurs_id'
        ListField = 'bezeichnung'
        ListSource = dmKurs.dsKursAuswahl
        TabOrder = 0
      end
      object cbxPflicht: TCheckBox
        Left = 320
        Top = 28
        Width = 80
        Height = 17
        Caption = 'Pflicht'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object btnUnterkursAdd: TButton
        Left = 410
        Top = 24
        Width = 100
        Height = 25
        Caption = 'Hinzuf'#252'gen'
        TabOrder = 2
        OnClick = btnUnterkursAddClick
      end
      object btnUnterkursDel: TButton
        Left = 516
        Top = 24
        Width = 96
        Height = 25
        Caption = 'Entfernen'
        TabOrder = 3
        OnClick = btnUnterkursDelClick
      end
    end
    object vstUnterkurse: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 620
      Height = 480
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
  object pnlKompetenzen: TPanel
    Left = 8
    Top = 1340
    Width = 620
    Height = 560
    BevelOuter = bvNone
    Caption = 'pnlKompetenzen'
    ShowCaption = False
    TabOrder = 3
    Visible = False
    object pnlKompetenzenAdd: TPanel
      Left = 0
      Top = 480
      Width = 620
      Height = 80
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblKompetenz: TLabel
        Left = 8
        Top = 8
        Width = 62
        Height = 15
        Caption = 'Kompetenz'
      end
      object lblRolle: TLabel
        Left = 320
        Top = 8
        Width = 27
        Height = 15
        Caption = 'Rolle'
      end
      object cboKompetenz: TDBLookupComboBox
        Left = 8
        Top = 26
        Width = 300
        Height = 23
        KeyField = 'kompetenz_id'
        ListField = 'bezeichnung'
        ListSource = dmKurs.dsKompetenzAuswahl
        TabOrder = 0
      end
      object cboRolle: TComboBox
        Left = 320
        Top = 26
        Width = 140
        Height = 23
        Style = csDropDownList
        TabOrder = 1
      end
      object btnKompetenzAdd: TButton
        Left = 470
        Top = 24
        Width = 70
        Height = 25
        Caption = 'Hinzu'
        TabOrder = 2
        OnClick = btnKompetenzAddClick
      end
      object btnKompetenzDel: TButton
        Left = 546
        Top = 24
        Width = 66
        Height = 25
        Caption = 'Weg'
        TabOrder = 3
        OnClick = btnKompetenzDelClick
      end
    end
    object dbgrdKompetenzen: TDBGrid
      Left = 0
      Top = 0
      Width = 620
      Height = 480
      Align = alClient
      DataSource = dmKurs.dstblKompetenzen
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlMaterial: TPanel
    Left = 8
    Top = 1920
    Width = 620
    Height = 560
    BevelOuter = bvNone
    Caption = 'pnlMaterial'
    ShowCaption = False
    TabOrder = 4
    Visible = False
    object pnlMaterialAdd: TPanel
      Left = 0
      Top = 440
      Width = 620
      Height = 120
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblArtikel: TLabel
        Left = 8
        Top = 8
        Width = 36
        Height = 15
        Caption = 'Artikel'
      end
      object lblPauschal: TLabel
        Left = 320
        Top = 8
        Width = 91
        Height = 15
        Caption = 'Menge pauschal'
      end
      object lblProTn: TLabel
        Left = 440
        Top = 8
        Width = 103
        Height = 15
        Caption = 'je Teilnehmer'
      end
      object cboArtikel: TDBLookupComboBox
        Left = 8
        Top = 26
        Width = 300
        Height = 23
        KeyField = 'artikel_id'
        ListField = 'artikelname'
        ListSource = dmKurs.dsArtikelAuswahl
        TabOrder = 0
      end
      object edtPauschal: TEdit
        Left = 320
        Top = 26
        Width = 110
        Height = 23
        TabOrder = 1
        Text = '0'
      end
      object edtProTn: TEdit
        Left = 440
        Top = 26
        Width = 110
        Height = 23
        TabOrder = 2
        Text = '1'
      end
      object cbxRueckgabe: TCheckBox
        Left = 8
        Top = 60
        Width = 150
        Height = 17
        Caption = 'R'#252'ckgabe erwartet'
        TabOrder = 3
      end
      object btnMaterialAdd: TButton
        Left = 170
        Top = 56
        Width = 100
        Height = 25
        Caption = 'Hinzuf'#252'gen'
        TabOrder = 4
        OnClick = btnMaterialAddClick
      end
      object btnMaterialDel: TButton
        Left = 276
        Top = 56
        Width = 96
        Height = 25
        Caption = 'Entfernen'
        TabOrder = 5
        OnClick = btnMaterialDelClick
      end
      object btnEntnahme: TButton
        Left = 400
        Top = 56
        Width = 210
        Height = 25
        Caption = 'Entnahme-Beleg erzeugen'
        TabOrder = 6
        OnClick = btnEntnahmeClick
      end
    end
    object dbgrdMaterial: TDBGrid
      Left = 0
      Top = 0
      Width = 620
      Height = 440
      Align = alClient
      DataSource = dmKurs.dstblMaterial
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlDurchfuehrung: TPanel
    Left = 8
    Top = 2500
    Width = 620
    Height = 560
    BevelOuter = bvNone
    Caption = 'pnlDurchfuehrung'
    ShowCaption = False
    TabOrder = 5
    Visible = False
    object pnlDurchfuehrungAdd: TPanel
      Left = 0
      Top = 420
      Width = 620
      Height = 140
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblDfBez: TLabel
        Left = 8
        Top = 8
        Width = 63
        Height = 15
        Caption = 'Bezeichnung'
      end
      object lblSemester: TLabel
        Left = 320
        Top = 8
        Width = 48
        Height = 15
        Caption = 'Semester'
      end
      object lblLeiter: TLabel
        Left = 8
        Top = 56
        Width = 55
        Height = 15
        Caption = 'Kursleiter'
      end
      object lblRaum: TLabel
        Left = 320
        Top = 56
        Width = 31
        Height = 15
        Caption = 'Raum'
      end
      object edtDfBez: TEdit
        Left = 8
        Top = 26
        Width = 300
        Height = 23
        TabOrder = 0
      end
      object cboSemester: TDBLookupComboBox
        Left = 320
        Top = 26
        Width = 290
        Height = 23
        KeyField = 'semester_id'
        ListField = 'bezeichnung'
        ListSource = dmKurs.dsSemesterAuswahl
        TabOrder = 1
      end
      object cboLeiter: TDBLookupComboBox
        Left = 8
        Top = 74
        Width = 300
        Height = 23
        KeyField = 'person_id'
        ListField = 'nachname_firmenname'
        ListSource = dmKurs.dsLehrerAuswahl
        TabOrder = 2
      end
      object cboRaum: TDBLookupComboBox
        Left = 320
        Top = 74
        Width = 290
        Height = 23
        KeyField = 'raum_id'
        ListField = 'anzeige'
        ListSource = dmKurs.dsRaumAuswahl
        TabOrder = 3
      end
      object btnDfAdd: TButton
        Left = 8
        Top = 106
        Width = 200
        Height = 25
        Caption = 'Durchf'#252'hrung anlegen'
        TabOrder = 4
        OnClick = btnDfAddClick
      end
    end
    object dbgrdDurchfuehrung: TDBGrid
      Left = 0
      Top = 0
      Width = 620
      Height = 420
      Align = alClient
      DataSource = dmKurs.dstblDurchfuehrungen
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdDurchfuehrungCellClick
    end
  end
  object pnlTermine: TPanel
    Left = 8
    Top = 3080
    Width = 620
    Height = 560
    BevelOuter = bvNone
    Caption = 'pnlTermine'
    ShowCaption = False
    TabOrder = 6
    Visible = False
    object pnlTermineAdd: TPanel
      Left = 0
      Top = 420
      Width = 620
      Height = 140
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblStart: TLabel
        Left = 8
        Top = 8
        Width = 108
        Height = 15
        Caption = 'Start (TT.MM.JJJJ HH:MM)'
      end
      object lblDauer: TLabel
        Left = 250
        Top = 8
        Width = 74
        Height = 15
        Caption = 'Dauer (Min.)'
      end
      object lblAnzahl: TLabel
        Left = 350
        Top = 8
        Width = 38
        Height = 15
        Caption = 'Anzahl'
      end
      object lblAbstand: TLabel
        Left = 440
        Top = 8
        Width = 85
        Height = 15
        Caption = 'Abstand (Wo.)'
      end
      object lblThema: TLabel
        Left = 8
        Top = 56
        Width = 39
        Height = 15
        Caption = 'Thema'
      end
      object edtStart: TEdit
        Left = 8
        Top = 26
        Width = 230
        Height = 23
        TabOrder = 0
        OnChange = edtStartChange
      end
      object edtDauer: TEdit
        Left = 250
        Top = 26
        Width = 90
        Height = 23
        TabOrder = 1
        OnChange = edtStartChange
      end
      object edtAnzahl: TEdit
        Left = 350
        Top = 26
        Width = 80
        Height = 23
        TabOrder = 2
      end
      object edtAbstand: TEdit
        Left = 440
        Top = 26
        Width = 90
        Height = 23
        TabOrder = 3
      end
      object edtThema: TEdit
        Left = 8
        Top = 74
        Width = 522
        Height = 23
        TabOrder = 4
      end
      object btnTerminAdd: TButton
        Left = 8
        Top = 106
        Width = 140
        Height = 25
        Caption = 'Einzeltermin'
        TabOrder = 5
        OnClick = btnTerminAddClick
      end
      object btnSerieAdd: TButton
        Left = 154
        Top = 106
        Width = 140
        Height = 25
        Caption = 'Serie anlegen'
        TabOrder = 6
        OnClick = btnSerieAddClick
      end
      object btnTerminDel: TButton
        Left = 300
        Top = 106
        Width = 120
        Height = 25
        Caption = 'Termin l'#246'schen'
        TabOrder = 7
        OnClick = btnTerminDelClick
      end
    end
    object pnlGanttKopf: TPanel
      Left = 0
      Top = 0
      Width = 620
      Height = 32
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblGanttTag: TLabel
        Left = 96
        Top = 8
        Width = 3
        Height = 15
      end
      object btnGanttZurueck: TButton
        Left = 4
        Top = 3
        Width = 40
        Height = 25
        Caption = '<'
        TabOrder = 0
        OnClick = btnGanttZurueckClick
      end
      object btnGanttVor: TButton
        Left = 48
        Top = 3
        Width = 40
        Height = 25
        Caption = '>'
        TabOrder = 1
        OnClick = btnGanttVorClick
      end
      object btnGanttHeute: TButton
        Left = 300
        Top = 3
        Width = 90
        Height = 25
        Caption = 'Heute'
        TabOrder = 2
        OnClick = btnGanttHeuteClick
      end
      object btnGanttAktualisieren: TButton
        Left = 396
        Top = 3
        Width = 110
        Height = 25
        Caption = 'Aktualisieren'
        TabOrder = 3
        OnClick = btnGanttAktualisierenClick
      end
    end
  end
  object pnlTeilnehmer: TPanel
    Left = 8
    Top = 3660
    Width = 620
    Height = 560
    BevelOuter = bvNone
    Caption = 'pnlTeilnehmer'
    ShowCaption = False
    TabOrder = 7
    Visible = False
    object pnlTeilnehmerAdd: TPanel
      Left = 0
      Top = 480
      Width = 620
      Height = 80
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblPerson: TLabel
        Left = 8
        Top = 8
        Width = 38
        Height = 15
        Caption = 'Person'
      end
      object cboPerson: TDBLookupComboBox
        Left = 8
        Top = 26
        Width = 380
        Height = 23
        KeyField = 'person_id'
        ListField = 'anzeige'
        ListSource = dmKurs.dsPersonAuswahl
        TabOrder = 0
      end
      object btnTnAdd: TButton
        Left = 400
        Top = 24
        Width = 100
        Height = 25
        Caption = 'Anmelden'
        TabOrder = 1
        OnClick = btnTnAddClick
      end
      object btnTnDel: TButton
        Left = 506
        Top = 24
        Width = 106
        Height = 25
        Caption = 'Abmelden'
        TabOrder = 2
        OnClick = btnTnDelClick
      end
    end
    object dbgrdTeilnehmer: TDBGrid
      Left = 0
      Top = 0
      Width = 620
      Height = 480
      Align = alClient
      DataSource = dmKurs.dstblTeilnehmer
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
    object actNeu: TAction
      Caption = 'Neu'
      OnExecute = actNeuExecute
    end
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
