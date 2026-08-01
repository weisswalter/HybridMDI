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
  object Splitter1: TSplitter
    Left = 560
    Top = 0
    Width = 5
    Height = 700
  end
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
          ImageIndex = 0
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
          Width = 68
          Height = 15
          Caption = 'Bezeichnung'
        end
        object lblStunden: TLabel
          Left = 8
          Top = 60
          Width = 101
          Height = 15
          Caption = 'Unterrichtsstunden'
        end
        object lblMinTn: TLabel
          Left = 160
          Top = 60
          Width = 68
          Height = 15
          Caption = 'Min. Teilneh.'
        end
        object lblMaxTn: TLabel
          Left = 280
          Top = 60
          Width = 69
          Height = 15
          Caption = 'Max. Teilneh.'
        end
        object lblPreis: TLabel
          Left = 400
          Top = 60
          Width = 68
          Height = 15
          Caption = 'Preis je Teiln.'
        end
        object lblLernziele: TLabel
          Left = 8
          Top = 112
          Width = 46
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
  object rbnKurs: TRibbonPanel
    Left = 565
    Top = 0
    Width = 635
    Height = 700
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    TopPanel.Left = 0
    TopPanel.Top = 0
    TopPanel.Width = 635
    TopPanel.Height = 31
    TopPanel.Align = alTop
    TopPanel.BevelOuter = bvNone
    TopPanel.Caption = 'TopPanel'
    TopPanel.ShowCaption = False
    TopPanel.TabOrder = 1
    TopPanel.DesignSize = (
      635
      31)
    PageControl.Left = -1
    PageControl.Top = 29
    PageControl.Width = 637
    PageControl.Height = 672
    PageControl.Anchors = [akLeft, akTop, akRight, akBottom]
    PageControl.TabOrder = 0
    HeaderButtons = <
      item
        Caption = 'Unterkurse'
        Width = 115
      end
      item
        Caption = 'Kompetenzen'
        Width = 130
      end
      item
        Caption = 'Material'
        Width = 100
      end
      item
        Caption = 'Durchf'#252'hrung'
        Width = 135
      end
      item
        Caption = 'Termine'
        Width = 100
      end
      item
        Caption = 'Teilnehmer'
        Width = 115
      end>
    ActivePageIndex = 3
    DesignSize = (
      635
      700)
    object tsUnterkurse: TTabSheet
      Caption = 'Unterkurse'
      object pnlUnterkurse: TPanel
        Left = 0
        Top = 38
        Width = 637
        Height = 634
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlUnterkurse'
        ShowCaption = False
        TabOrder = 1
        object pnlUnterkurseAdd: TPanel
          Left = 0
          Top = 554
          Width = 637
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
          Width = 637
          Height = 554
          Align = alClient
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
    object tsKompetenzen: TTabSheet
      Caption = 'Kompetenzen'
      object barKompetenzen: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 637
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Gradient.Left = 0
        Gradient.Top = 0
        Gradient.Width = 637
        Gradient.Height = 38
        Gradient.Style = grVertical
        Gradient.StartColor = 16245453
        Gradient.EndColor = 15966336
        Gradient.ExplicitWidth = 0
        Gradient.ExplicitHeight = 0
        Buttons = <
          item
            Action = actKompetenzErster
          end
          item
            Action = actKompetenzZurueck
          end
          item
            Action = actKompetenzWeiter
          end
          item
            Action = actKompetenzLetzter
          end>
      end
      object pnlKompetenzen: TPanel
        Left = 0
        Top = 38
        Width = 637
        Height = 634
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlKompetenzen'
        ShowCaption = False
        TabOrder = 1
        object pnlKompetenzenAdd: TPanel
          Left = 0
          Top = 554
          Width = 637
          Height = 80
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblKompetenz: TLabel
            Left = 8
            Top = 8
            Width = 60
            Height = 15
            Caption = 'Kompetenz'
          end
          object lblRolle: TLabel
            Left = 320
            Top = 8
            Width = 26
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
          Width = 637
          Height = 554
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
    end
    object tsMaterial: TTabSheet
      Caption = 'Material'
      object pnlMaterial: TPanel
        Left = 0
        Top = 0
        Width = 637
        Height = 672
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlMaterial'
        ShowCaption = False
        TabOrder = 0
        ExplicitTop = 38
        ExplicitHeight = 634
        object pnlMaterialAdd: TPanel
          Left = 0
          Top = 552
          Width = 637
          Height = 120
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          ExplicitTop = 514
          object lblArtikel: TLabel
            Left = 8
            Top = 8
            Width = 34
            Height = 15
            Caption = 'Artikel'
          end
          object lblPauschal: TLabel
            Left = 320
            Top = 8
            Width = 87
            Height = 15
            Caption = 'Menge pauschal'
          end
          object lblProTn: TLabel
            Left = 440
            Top = 8
            Width = 71
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
          Top = 38
          Width = 637
          Height = 514
          Align = alClient
          DataSource = dmKurs.dstblMaterial
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
        object RibbonButtonBar1: TRibbonButtonBar
          Left = 0
          Top = 0
          Width = 637
          Height = 38
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 2
          Gradient.Left = 0
          Gradient.Top = 0
          Gradient.Width = 637
          Gradient.Height = 38
          Gradient.Style = grVertical
          Gradient.StartColor = 16245453
          Gradient.EndColor = 15966336
          Gradient.ExplicitWidth = 0
          Gradient.ExplicitHeight = 0
          Buttons = <
            item
              Action = actTagVorher
            end
            item
              Action = actTagNext
              Width = 75
            end
            item
              Action = actHeute
              Width = 70
            end
            item
              Action = actTermineAktualisieren
              Width = 75
            end>
          ExplicitTop = 8
        end
      end
    end
    object tsDurchfuehrung: TTabSheet
      Caption = 'Durchf'#252'hrung'
      object pnlDurchfuehrung: TPanel
        Left = 0
        Top = 0
        Width = 637
        Height = 672
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlDurchfuehrung'
        ShowCaption = False
        TabOrder = 0
        ExplicitTop = 38
        ExplicitHeight = 634
        object pnlDurchfuehrungAdd: TPanel
          Left = 0
          Top = 532
          Width = 637
          Height = 140
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          ExplicitTop = 494
          object lblDfBez: TLabel
            Left = 8
            Top = 8
            Width = 68
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
            Width = 49
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
          Top = 38
          Width = 637
          Height = 494
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
        object RibbonButtonBar2: TRibbonButtonBar
          Left = 0
          Top = 0
          Width = 637
          Height = 38
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 2
          Gradient.Left = 0
          Gradient.Top = 0
          Gradient.Width = 637
          Gradient.Height = 38
          Gradient.Style = grVertical
          Gradient.StartColor = 16245453
          Gradient.EndColor = 15966336
          Gradient.ExplicitWidth = 0
          Gradient.ExplicitHeight = 0
          Buttons = <
            item
              Action = actTagVorher
            end
            item
              Action = actTagNext
              Width = 75
            end
            item
              Action = actHeute
              Width = 70
            end
            item
              Action = actTermineAktualisieren
              Width = 75
            end>
          ExplicitTop = 8
        end
      end
    end
    object tsTermine: TTabSheet
      Caption = 'Termine'
      object barTermine: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 637
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Gradient.Left = 0
        Gradient.Top = 0
        Gradient.Width = 637
        Gradient.Height = 38
        Gradient.Style = grVertical
        Gradient.StartColor = 16245453
        Gradient.EndColor = 15966336
        Gradient.ExplicitWidth = 0
        Gradient.ExplicitHeight = 0
        Buttons = <
          item
            Action = actTagVorher
          end
          item
            Action = actTagNext
            Width = 75
          end
          item
            Action = actHeute
            Width = 70
          end
          item
            Action = actTermineAktualisieren
            Width = 90
          end>
      end
      object pnlTermine: TPanel
        Left = 0
        Top = 38
        Width = 637
        Height = 634
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlTermine'
        ShowCaption = False
        TabOrder = 1
        object pnlTermineAdd: TPanel
          Left = 0
          Top = 494
          Width = 637
          Height = 140
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblStart: TLabel
            Left = 8
            Top = 8
            Width = 139
            Height = 15
            Caption = 'Start (TT.MM.JJJJ HH:MM)'
          end
          object lblDauer: TLabel
            Left = 250
            Top = 8
            Width = 66
            Height = 15
            Caption = 'Dauer (Min.)'
          end
          object lblAnzahl: TLabel
            Left = 350
            Top = 8
            Width = 36
            Height = 15
            Caption = 'Anzahl'
          end
          object lblAbstand: TLabel
            Left = 440
            Top = 8
            Width = 76
            Height = 15
            Caption = 'Abstand (Wo.)'
          end
          object lblThema: TLabel
            Left = 8
            Top = 56
            Width = 37
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
          Width = 637
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
          object lblGanttZoom: TLabel
            Left = 516
            Top = 8
            Width = 87
            Height = 15
            Caption = 'Zoom: 60 px/Std'
          end
          object trkGanttZoom: TTrackBar
            Left = 612
            Top = 1
            Width = 180
            Height = 30
            Max = 200
            Min = 10
            Position = 60
            TabOrder = 0
            TickStyle = tsNone
            OnChange = trkGanttZoomChange
          end
        end
      end
    end
    object tsTeilnehmer: TTabSheet
      Caption = 'Teilnehmer'
      object barTeilnehmer: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 637
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Gradient.Left = 0
        Gradient.Top = 0
        Gradient.Width = 637
        Gradient.Height = 38
        Gradient.Style = grVertical
        Gradient.StartColor = 16245453
        Gradient.EndColor = 15966336
        Gradient.ExplicitWidth = 0
        Gradient.ExplicitHeight = 0
        Buttons = <
          item
            Action = actTeilnehmerErster
          end
          item
            Action = actTeilnehmerZurueck
          end
          item
            Action = actTeilnehmerWeiter
          end
          item
            Action = actTeilnehmerLetzter
          end>
      end
      object pnlTeilnehmer: TPanel
        Left = 0
        Top = 38
        Width = 637
        Height = 634
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlTeilnehmer'
        ShowCaption = False
        TabOrder = 1
        object pnlTeilnehmerAdd: TPanel
          Left = 0
          Top = 554
          Width = 637
          Height = 80
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblPerson: TLabel
            Left = 8
            Top = 8
            Width = 36
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
          Width = 637
          Height = 554
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
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 708
    Top = 464
  end
  object ActionListEdit: TActionList
    Left = 840
    Top = 464
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
  object actlstRechts: TActionList
    Left = 972
    Top = 432
    object actTagVorher: TAction
      Caption = '<'
      OnExecute = ActionRechtsExecute
    end
    object actTagNext: TAction
      Tag = 1
      Caption = '>'
      OnExecute = actTagNextExecute
    end
    object actHeute: TAction
      Tag = 2
      Caption = 'Heute'
      OnExecute = actHeuteExecute
    end
    object actTermineAktualisieren: TAction
      Tag = 3
      Caption = 'Aktualisieren'
      OnExecute = actTermineAktualisierenExecute
    end
    object actKompetenzErster: TAction
      Caption = 'Erster'
      Hint = 'Zur ersten Kompetenz'
      OnExecute = KompetenzNavExecute
    end
    object actKompetenzZurueck: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = KompetenzNavExecute
    end
    object actKompetenzWeiter: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = KompetenzNavExecute
    end
    object actKompetenzLetzter: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = KompetenzNavExecute
    end
    object actTeilnehmerErster: TAction
      Caption = 'Erster'
      Hint = 'Zum ersten Teilnehmer'
      OnExecute = TeilnehmerNavExecute
    end
    object actTeilnehmerZurueck: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = TeilnehmerNavExecute
    end
    object actTeilnehmerWeiter: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = TeilnehmerNavExecute
    end
    object actTeilnehmerLetzter: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = TeilnehmerNavExecute
    end
  end
end
