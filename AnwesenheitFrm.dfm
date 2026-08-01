object frmAnwesenheit: TfrmAnwesenheit
  Left = 0
  Top = 0
  Caption = 'Anwesenheit'
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
    object pnlKopf: TPanel
      Left = 0
      Top = 0
      Width = 620
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblDatum: TLabel
        Left = 8
        Top = 12
        Width = 36
        Height = 15
        Caption = 'Datum'
      end
      object dtpDatum: TDateTimePicker
        Left = 56
        Top = 8
        Width = 130
        Height = 23
        Date = 46000.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 0
        OnChange = dtpDatumChange
      end
      object btnTagZurueck: TButton
        Left = 196
        Top = 7
        Width = 40
        Height = 25
        Caption = '<'
        TabOrder = 1
        OnClick = btnTagZurueckClick
      end
      object btnTagVor: TButton
        Left = 240
        Top = 7
        Width = 40
        Height = 25
        Caption = '>'
        TabOrder = 2
        OnClick = btnTagVorClick
      end
    end
    object pnlKopfButtons: TPanel
      Left = 0
      Top = 40
      Width = 620
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object btnListeErzeugen: TJvNavPanelButtonTop
        Left = 0
        Top = 0
        Width = 130
        Height = 36
        Action = actListeErzeugen
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
      object btnVerdichten: TJvNavPanelButtonTop
        Left = 130
        Top = 0
        Width = 110
        Height = 36
        Action = actVerdichten
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
      object btnFreigeben: TJvNavPanelButtonTop
        Left = 240
        Top = 0
        Width = 110
        Height = 36
        Action = actFreigeben
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
      object btnHeute: TJvNavPanelButtonTop
        Left = 350
        Top = 0
        Width = 90
        Height = 36
        Action = actHeute
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
    object dbgrdTag: TDBGrid
      Left = 0
      Top = 76
      Width = 620
      Height = 624
      Align = alClient
      DataSource = dmAnwesenheit.dstblTag
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdTagCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 620
    Top = 0
    Width = 5
    Height = 700
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 625
    Top = 0
    Width = 575
    Height = 700
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    ActivePageIndex = 0
    HeaderButtons = <
      item
        Caption = 'Check'
        Width = 90
      end
      item
        Caption = 'Stempel'
        Width = 100
      end
      item
        Caption = 'Abwesenheit'
        Width = 130
      end
      item
        Caption = 'Regime'
        Width = 100
      end
      item
        Caption = 'Monat'
        Width = 90
      end>
    object tsCheck: TTabSheet
      Caption = 'Check'
      object barCheck: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 575
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      object pnlCheck: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 2
        object pnlCheckAdd: TPanel
          Left = 0
          Top = 460
          Width = 560
          Height = 100
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblCheckGrund: TLabel
            Left = 8
            Top = 8
            Width = 34
            Height = 15
            Caption = 'Grund'
          end
          object lblFehlminuten: TLabel
            Left = 320
            Top = 8
            Width = 66
            Height = 15
            Caption = 'Fehlminuten'
          end
          object cboCheckGrund: TDBLookupComboBox
            Left = 8
            Top = 26
            Width = 300
            Height = 23
            KeyField = 'art_id'
            ListField = 'bezeichnung'
            ListSource = dmAnwesenheit.dsArtAuswahl
            TabOrder = 0
          end
          object edtFehlminuten: TEdit
            Left = 320
            Top = 26
            Width = 70
            Height = 23
            TabOrder = 1
          end
          object btnAnwesend: TButton
            Left = 8
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Anwesend'
            TabOrder = 2
            OnClick = btnAnwesendClick
          end
          object btnAbwesend: TButton
            Left = 114
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Fehlt'
            TabOrder = 3
            OnClick = btnAbwesendClick
          end
          object btnEntschuldigt: TButton
            Left = 220
            Top = 60
            Width = 110
            Height = 30
            Caption = 'Entschuldigt'
            TabOrder = 4
            OnClick = btnEntschuldigtClick
          end
          object btnAlleAnwesend: TButton
            Left = 400
            Top = 60
            Width = 130
            Height = 30
            Caption = 'Alle anwesend'
            TabOrder = 5
            OnClick = btnAlleAnwesendClick
          end
        end
        object dbgrdCheck: TDBGrid
          Left = 0
          Top = 0
          Width = 560
          Height = 460
          Align = alClient
          DataSource = dmAnwesenheit.dstblCheck
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsStempel: TTabSheet
      Caption = 'Stempel'
      object barStempel: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 575
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      object pnlStempel: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 3
        object pnlStempelAdd: TPanel
          Left = 0
          Top = 460
          Width = 560
          Height = 100
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblStempelZeit: TLabel
            Left = 8
            Top = 8
            Width = 41
            Height = 15
            Caption = 'Uhrzeit'
          end
          object dtpStempelZeit: TDateTimePicker
            Left = 8
            Top = 26
            Width = 100
            Height = 23
            Date = 46000.000000000000000000
            Time = 0.000000000000000000
            Kind = dtkTime
            TabOrder = 0
          end
          object btnKommen: TButton
            Left = 8
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Kommen'
            TabOrder = 1
            OnClick = btnKommenClick
          end
          object btnGehen: TButton
            Left = 114
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Gehen'
            TabOrder = 2
            OnClick = btnGehenClick
          end
          object btnPauseStart: TButton
            Left = 220
            Top = 60
            Width = 110
            Height = 30
            Caption = 'Pause Start'
            TabOrder = 3
            OnClick = btnPauseStartClick
          end
          object btnPauseEnde: TButton
            Left = 336
            Top = 60
            Width = 110
            Height = 30
            Caption = 'Pause Ende'
            TabOrder = 4
            OnClick = btnPauseEndeClick
          end
          object btnStempelDel: TButton
            Left = 452
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Entfernen'
            TabOrder = 5
            OnClick = btnStempelDelClick
          end
        end
        object dbgrdStempel: TDBGrid
          Left = 0
          Top = 0
          Width = 560
          Height = 460
          Align = alClient
          DataSource = dmAnwesenheit.dstblStempel
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsAbwesenheit: TTabSheet
      Caption = 'Abwesenheit'
      object barAbwesenheit: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 575
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      object pnlAbwesenheit: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 4
        object pnlAbwesenheitAdd: TPanel
          Left = 0
          Top = 460
          Width = 560
          Height = 100
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblAbwGrund: TLabel
            Left = 8
            Top = 8
            Width = 34
            Height = 15
            Caption = 'Grund'
          end
          object lblAbwVon: TLabel
            Left = 250
            Top = 8
            Width = 22
            Height = 15
            Caption = 'Von'
          end
          object lblAbwBis: TLabel
            Left = 380
            Top = 8
            Width = 17
            Height = 15
            Caption = 'Bis'
          end
          object cboAbwGrund: TDBLookupComboBox
            Left = 8
            Top = 26
            Width = 230
            Height = 23
            KeyField = 'art_id'
            ListField = 'bezeichnung'
            ListSource = dmAnwesenheit.dsArtAuswahl
            TabOrder = 0
          end
          object dtpAbwVon: TDateTimePicker
            Left = 250
            Top = 26
            Width = 120
            Height = 23
            Date = 46000.000000000000000000
            Time = 0.000000000000000000
            TabOrder = 1
          end
          object dtpAbwBis: TDateTimePicker
            Left = 380
            Top = 26
            Width = 120
            Height = 23
            Date = 46000.000000000000000000
            Time = 0.000000000000000000
            TabOrder = 2
          end
          object cbxHalbtags: TCheckBox
            Left = 510
            Top = 28
            Width = 90
            Height = 17
            Caption = 'Halbtags'
            TabOrder = 3
          end
          object btnAbwAdd: TButton
            Left = 8
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Anlegen'
            TabOrder = 4
            OnClick = btnAbwAddClick
          end
          object btnAbwDel: TButton
            Left = 114
            Top = 60
            Width = 100
            Height = 30
            Caption = 'Entfernen'
            TabOrder = 5
            OnClick = btnAbwDelClick
          end
          object btnAbwGenehmigen: TButton
            Left = 220
            Top = 60
            Width = 120
            Height = 30
            Caption = 'Genehmigen'
            TabOrder = 6
            OnClick = btnAbwGenehmigenClick
          end
        end
        object dbgrdAbwesenheit: TDBGrid
          Left = 0
          Top = 0
          Width = 560
          Height = 460
          Align = alClient
          DataSource = dmAnwesenheit.dstblAbwesenheit
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsRegime: TTabSheet
      Caption = 'Regime'
      object barRegime: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 575
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      object pnlRegime: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 5
        object pnlRegimeAdd: TPanel
          Left = 0
          Top = 440
          Width = 560
          Height = 120
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblRegAb: TLabel
            Left = 8
            Top = 8
            Width = 49
            Height = 15
            Caption = 'Ab Datum'
          end
          object lblRegArt: TLabel
            Left = 140
            Top = 8
            Width = 76
            Height = 15
            Caption = 'Erfassungsart'
          end
          object lblRegRaster: TLabel
            Left = 250
            Top = 8
            Width = 34
            Height = 15
            Caption = 'Raster'
          end
          object lblRegPensum: TLabel
            Left = 420
            Top = 8
            Width = 51
            Height = 15
            Caption = 'Pensum %'
          end
          object lblRegStandort: TLabel
            Left = 8
            Top = 56
            Width = 46
            Height = 15
            Caption = 'Standort'
          end
          object dtpRegAb: TDateTimePicker
            Left = 8
            Top = 26
            Width = 120
            Height = 23
            Date = 46000.000000000000000000
            Time = 0.000000000000000000
            TabOrder = 0
          end
          object cboRegArt: TComboBox
            Left = 140
            Top = 26
            Width = 100
            Height = 23
            Style = csDropDownList
            TabOrder = 1
          end
          object cboRegRaster: TDBLookupComboBox
            Left = 250
            Top = 26
            Width = 160
            Height = 23
            KeyField = 'raster_id'
            ListField = 'bezeichnung'
            ListSource = dmAnwesenheit.dsRasterAuswahl
            TabOrder = 2
          end
          object edtRegPensum: TEdit
            Left = 420
            Top = 26
            Width = 60
            Height = 23
            TabOrder = 3
          end
          object cboRegStandort: TDBLookupComboBox
            Left = 8
            Top = 74
            Width = 300
            Height = 23
            KeyField = 'adresse_id'
            ListField = 'anzeige'
            ListSource = dmAnwesenheit.dsAdresseAuswahl
            TabOrder = 4
          end
          object btnRegAdd: TButton
            Left = 320
            Top = 73
            Width = 100
            Height = 30
            Caption = 'Anlegen'
            TabOrder = 5
            OnClick = btnRegAddClick
          end
          object btnRegBeenden: TButton
            Left = 426
            Top = 73
            Width = 120
            Height = 30
            Caption = 'Beenden'
            TabOrder = 6
            OnClick = btnRegBeendenClick
          end
        end
        object dbgrdRegime: TDBGrid
          Left = 0
          Top = 0
          Width = 560
          Height = 440
          Align = alClient
          DataSource = dmAnwesenheit.dstblRegime
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsMonat: TTabSheet
      Caption = 'Monat'
      object barMonat: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 575
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
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
      object pnlMonat: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 6
        object pnlMonatUnten: TPanel
          Left = 0
          Top = 380
          Width = 560
          Height = 180
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblFerien: TLabel
            Left = 0
            Top = 0
            Width = 560
            Height = 17
            Align = alTop
            Caption = 'Ferienstand'
          end
          object pnlMonatAdd: TPanel
            Left = 0
            Top = 130
            Width = 560
            Height = 50
            Align = alBottom
            BevelOuter = bvNone
            ShowCaption = False
            TabOrder = 0
            object lblFerJahr: TLabel
              Left = 8
              Top = 4
              Width = 24
              Height = 15
              Caption = 'Jahr'
            end
            object lblFerTage: TLabel
              Left = 90
              Top = 4
              Width = 79
              Height = 15
              Caption = 'Anspruch Tage'
            end
            object lblFerUebertrag: TLabel
              Left = 200
              Top = 4
              Width = 50
              Height = 15
              Caption = #220'bertrag'
            end
            object edtFerJahr: TEdit
              Left = 8
              Top = 22
              Width = 70
              Height = 23
              TabOrder = 0
            end
            object edtFerTage: TEdit
              Left = 90
              Top = 22
              Width = 90
              Height = 23
              TabOrder = 1
            end
            object edtFerUebertrag: TEdit
              Left = 200
              Top = 22
              Width = 90
              Height = 23
              TabOrder = 2
            end
            object btnFerSetzen: TButton
              Left = 306
              Top = 20
              Width = 100
              Height = 28
              Caption = 'Setzen'
              TabOrder = 3
              OnClick = btnFerSetzenClick
            end
          end
          object dbgrdFerien: TDBGrid
            Left = 0
            Top = 17
            Width = 560
            Height = 113
            Align = alClient
            DataSource = dmAnwesenheit.dstblFerien
            TabOrder = 1
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -12
            TitleFont.Name = 'Segoe UI'
            TitleFont.Style = []
          end
        end
        object dbgrdMonat: TDBGrid
          Left = 0
          Top = 0
          Width = 560
          Height = 380
          Align = alClient
          DataSource = dmAnwesenheit.dstblMonat
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
    Left = 900
    Top = 640
  end
  object ActionListEdit: TActionList
    Left = 960
    Top = 640
    object actListeErzeugen: TAction
      Caption = 'Liste erzeugen'
      OnExecute = actListeErzeugenExecute
    end
    object actVerdichten: TAction
      Caption = 'Verdichten'
      OnExecute = actVerdichtenExecute
    end
    object actFreigeben: TAction
      Caption = 'Freigeben'
      OnExecute = actFreigebenExecute
    end
    object actHeute: TAction
      Caption = 'Heute'
      OnExecute = actHeuteExecute
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
