object frmAnlagen: TfrmAnlagen
  Left = 0
  Top = 0
  Caption = 'Anlageverm'#246'gen'
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
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 74
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblJahr: TLabel
      Left = 8
      Top = 5
      Width = 24
      Height = 15
      Caption = 'Jahr'
    end
    object edtJahr: TEdit
      Left = 8
      Top = 24
      Width = 70
      Height = 23
      TabOrder = 0
      Text = '2026'
    end
    object btnPlan: TJvNavPanelButtonTop
      Left = 96
      Top = 2
      Width = 110
      Height = 69
      Action = actPlan
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
    object btnPlanAlle: TJvNavPanelButtonTop
      Left = 210
      Top = 2
      Width = 110
      Height = 69
      Action = actPlanAlle
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
      Left = 324
      Top = 2
      Width = 90
      Height = 69
      Action = actNeuLaden
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
  object pnlLeft: TPanel
    Left = 0
    Top = 74
    Width = 620
    Height = 626
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object lblKennzahl: TLabel
      Left = 0
      Top = 608
      Width = 620
      Height = 18
      Align = alBottom
      AutoSize = False
      Caption = ' '
      Layout = tlCenter
    end
    object dbgrdAnlagen: TDBGrid
      Left = 0
      Top = 0
      Width = 620
      Height = 608
      Align = alClient
      DataSource = dmAnlagen.dsAnlage
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdAnlagenCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 620
    Top = 74
    Width = 5
    Height = 626
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 625
    Top = 74
    Width = 575
    Height = 626
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object tsPlan: TTabSheet
      Caption = 'Abschreibungsplan'
      object barPlan: TRibbonButtonBar
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
            Action = actNeuR
            Width = 70
          end
          item
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end
          item
            Action = actLoeschenR
            Width = 75
          end>
      end
      object pnlPlan: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlPlanHinweis: TPanel
          Left = 0
          Top = 0
          Width = 575
          Height = 70
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblPlanHinweis: TLabel
            Left = 4
            Top = 2
            Width = 567
            Height = 66
            AutoSize = False
            WordWrap = True
          end
        end
        object dbgrdPlan: TDBGrid
          Left = 0
          Top = 70
          Width = 575
          Height = 486
          Align = alClient
          DataSource = dmAnlagen.dsPlan
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
          ReadOnly = True
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsZuordnung: TTabSheet
      Caption = 'Zuordnung'
      object barZuordnung: TRibbonButtonBar
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
            Action = actAendernR
            Width = 75
          end
          item
            Action = actSpeichernR
            Width = 85
          end
          item
            Action = actAbbrechenR
            Width = 85
          end>
      end
      object pnlZuordnung: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblKonto: TLabel
          Left = 8
          Top = 16
          Width = 130
          Height = 15
          Caption = 'Aktivkonto (z. B. 1500)'
        end
        object lblAufwandKonto: TLabel
          Left = 8
          Top = 72
          Width = 160
          Height = 15
          Caption = 'Aufwandkonto (z. B. 6800)'
        end
        object lblRaum: TLabel
          Left = 8
          Top = 128
          Width = 100
          Height = 15
          Caption = 'Standort (Raum)'
        end
        object lblArtikel: TLabel
          Left = 8
          Top = 184
          Width = 150
          Height = 15
          Caption = 'Herkunft (Artikel)'
        end
        object lblZuordnungHinweis: TLabel
          Left = 8
          Top = 246
          Width = 555
          Height = 70
          AutoSize = False
          WordWrap = True
        end
        object cboKonto: TDBLookupComboBox
          Left = 8
          Top = 36
          Width = 400
          Height = 23
          DataField = 'konto_id'
          DataSource = dmAnlagen.dsAnlage
          KeyField = 'konto_id'
          ListField = 'anzeige'
          ListSource = dmAnlagen.dsKonto
          TabOrder = 0
        end
        object cboAufwandKonto: TDBLookupComboBox
          Left = 8
          Top = 92
          Width = 400
          Height = 23
          DataField = 'aufwand_konto_id'
          DataSource = dmAnlagen.dsAnlage
          KeyField = 'konto_id'
          ListField = 'anzeige'
          ListSource = dmAnlagen.dsKonto
          TabOrder = 1
        end
        object cboRaum: TDBLookupComboBox
          Left = 8
          Top = 148
          Width = 400
          Height = 23
          DataField = 'raum_id'
          DataSource = dmAnlagen.dsAnlage
          KeyField = 'raum_id'
          ListField = 'anzeige'
          ListSource = dmAnlagen.dsRaum
          TabOrder = 2
        end
        object cboArtikel: TDBLookupComboBox
          Left = 8
          Top = 204
          Width = 400
          Height = 23
          DataField = 'artikel_id'
          DataSource = dmAnlagen.dsAnlage
          KeyField = 'artikel_id'
          ListField = 'artikelname'
          ListSource = dmAnlagen.dsArtikel
          TabOrder = 3
        end
      end
    end
    object tsFotos: TTabSheet
      Caption = 'Fotos'
      object pnlFotos: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object lblFotoBeschr: TLabel
          Left = 8
          Top = 6
          Width = 72
          Height = 15
          Caption = 'Beschreibung'
        end
        object dbimgFoto: TDBImage
          Left = 296
          Top = 32
          Width = 271
          Height = 480
          DataField = 'foto'
          DataSource = dmAnlagen.dstblAnlageFoto
          TabOrder = 0
        end
        object dbgrdFotos: TDBGrid
          Left = 8
          Top = 128
          Width = 250
          Height = 384
          DataSource = dmAnlagen.dstblAnlageFoto
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'reihenfolge'
              Title.Caption = 'Foto'
              Width = 190
              Visible = True
            end>
        end
        object dbmmoBeschreibung: TDBMemo
          Left = 8
          Top = 24
          Width = 250
          Height = 96
          DataField = 'beschreibung'
          DataSource = dmAnlagen.dstblAnlageFoto
          ScrollBars = ssVertical
          TabOrder = 2
        end
        object btnFotoLaden: TButton
          Left = 576
          Top = 32
          Width = 120
          Height = 25
          Caption = 'Foto laden...'
          TabOrder = 3
          OnClick = btnFotoLadenClick
        end
        object btnFotoLoeschen: TButton
          Left = 576
          Top = 67
          Width = 120
          Height = 25
          Caption = 'Foto entfernen'
          TabOrder = 4
          OnClick = btnFotoLoeschenClick
        end
      end
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptStandard
    Colors.ButtonColorFrom = 16247513
    Colors.ButtonColorTo = 16050326
    Colors.ButtonSelectedColorFrom = 12189695
    Colors.ButtonSelectedColorTo = 4633855
    Colors.ButtonHotColorFrom = 15660791
    Colors.ButtonHotColorTo = 12313087
    Colors.FrameColor = 6045981
    Colors.HeaderColorFrom = 16245453
    Colors.HeaderColorTo = 15966336
    Left = 960
    Top = 120
  end
  object ActionListEdit: TActionList
    Left = 960
    Top = 180
    object actPlan: TAction
      Caption = 'Plan berechnen'
      Hint = 'Abschreibungsplan der gew'#228'hlten Anlage neu aufbauen'
      OnExecute = actPlanExecute
    end
    object actPlanAlle: TAction
      Caption = 'Alle berechnen'
      OnExecute = actPlanAlleExecute
    end
    object actNeuLaden: TAction
      Caption = 'Neu laden'
      OnExecute = actNeuLadenExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 960
    Top = 240
    object actNeuR: TAction
      Tag = 0
      Caption = 'Neu'
      OnExecute = ActionRechtsExecute
    end
    object actAendernR: TAction
      Tag = 1
      Caption = #196'ndern'
      OnExecute = ActionRechtsExecute
    end
    object actSpeichernR: TAction
      Tag = 2
      Caption = 'Speichern'
      OnExecute = ActionRechtsExecute
    end
    object actAbbrechenR: TAction
      Tag = 3
      Caption = 'Abbrechen'
      OnExecute = ActionRechtsExecute
    end
    object actLoeschenR: TAction
      Tag = 4
      Caption = 'L'#246'schen'
      OnExecute = ActionRechtsExecute
    end
  end
  object dlgFoto: TOpenPictureDialog
    Filter =
      'Bilder (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Alle ' +
      'Dateien (*.*)|*.*'
    Left = 960
    Top = 300
  end
end
