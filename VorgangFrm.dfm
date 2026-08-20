object frmVorgang: TfrmVorgang
  Left = 0
  Top = 0
  Caption = 'Vorg'#228'nge'
  ClientHeight = 560
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
  OnCreate = FormCreate
  TextHeight = 15
  object pnlOben: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblTyp: TLabel
      Left = 392
      Top = 4
      Width = 24
      Height = 15
      Caption = 'Typ'
    end
    object btnNeu: TJvNavPanelButtonTop
      Left = 4
      Top = 2
      Width = 96
      Height = 46
      Caption = 'Neu'
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnNeuClick
    end
    object btnSpeichern: TJvNavPanelButtonTop
      Left = 100
      Top = 2
      Width = 96
      Height = 46
      Caption = 'Speichern'
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnSpeichernClick
    end
    object btnWeiter: TJvNavPanelButtonTop
      Left = 196
      Top = 2
      Width = 96
      Height = 46
      Caption = 'Weiter'
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnWeiterClick
    end
    object btnNachfolger: TJvNavPanelButtonTop
      Left = 292
      Top = 2
      Width = 96
      Height = 46
      Caption = 'Nachfolger'
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnNachfolgerClick
    end
    object cboTyp: TComboBox
      Left = 392
      Top = 22
      Width = 220
      Height = 23
      Style = csDropDownList
      TabOrder = 0
    end
  end
  object pnlListe: TPanel
    Left = 0
    Top = 52
    Width = 460
    Height = 508
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object grdVorgang: TDBGrid
      Left = 0
      Top = 0
      Width = 460
      Height = 508
      Align = alClient
      DataSource = dmVorgang.dstblVorgang
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'vorgang_nr'
          Title.Caption = 'Nummer'
          Width = 90
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'bezeichnung'
          Title.Caption = 'Bezeichnung'
          Width = 180
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'zustand_bezeichnung'
          Title.Caption = 'Zustand'
          Width = 90
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'faellig_am'
          Title.Caption = 'F'#228'llig'
          Width = 75
          Visible = True
        end>
    end
  end
  object spl1: TSplitter
    Left = 460
    Top = 52
    Width = 4
    Height = 508
  end
  object pnlRechts: TPanel
    Left = 464
    Top = 52
    Width = 536
    Height = 508
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object pnlKopf: TPanel
      Left = 0
      Top = 0
      Width = 536
      Height = 200
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object lblNummer: TLabel
        Left = 8
        Top = 10
        Width = 47
        Height = 15
        Caption = 'Nummer'
      end
      object lblZustand: TLabel
        Left = 176
        Top = 10
        Width = 46
        Height = 15
        Caption = 'Zustand'
      end
      object lblBezeichnung: TLabel
        Left = 8
        Top = 56
        Width = 71
        Height = 15
        Caption = 'Bezeichnung'
      end
      object lblFaellig: TLabel
        Left = 8
        Top = 102
        Width = 32
        Height = 15
        Caption = 'F'#228'llig'
      end
      object lblBeschreibung: TLabel
        Left = 176
        Top = 102
        Width = 76
        Height = 15
        Caption = 'Beschreibung'
      end
      object edtNummer: TEdit
        Left = 8
        Top = 28
        Width = 160
        Height = 23
        ReadOnly = True
        TabOrder = 0
      end
      object edtZustand: TEdit
        Left = 176
        Top = 28
        Width = 350
        Height = 23
        ReadOnly = True
        TabOrder = 1
      end
      object edtBezeichnung: TEdit
        Left = 8
        Top = 74
        Width = 518
        Height = 23
        TabOrder = 2
      end
      object chkFaellig: TCheckBox
        Left = 8
        Top = 122
        Width = 60
        Height = 17
        Caption = 'Termin'
        TabOrder = 3
      end
      object dtFaellig: TDateTimePicker
        Left = 8
        Top = 144
        Width = 160
        Height = 23
        Date = 46600.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 4
      end
      object memBeschreibung: TMemo
        Left = 176
        Top = 120
        Width = 350
        Height = 72
        ScrollBars = ssVertical
        TabOrder = 5
      end
    end
    object pnlSchritt: TPanel
      Left = 0
      Top = 200
      Width = 536
      Height = 60
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblSchritt: TLabel
        Left = 8
        Top = 4
        Width = 96
        Height = 15
        Caption = 'N'#228'chster Schritt'
      end
      object lblBemerkung: TLabel
        Left = 232
        Top = 4
        Width = 66
        Height = 15
        Caption = 'Bemerkung'
      end
      object cboSchritt: TComboBox
        Left = 8
        Top = 24
        Width = 216
        Height = 23
        Style = csDropDownList
        TabOrder = 0
      end
      object edtBemerkung: TEdit
        Left = 232
        Top = 24
        Width = 294
        Height = 23
        TabOrder = 1
      end
    end
    object pnlUnten: TPanel
      Left = 0
      Top = 260
      Width = 536
      Height = 248
      Align = alClient
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object pgcUnten: TPageControl
        Left = 0
        Top = 0
        Width = 536
        Height = 248
        ActivePage = tsVerlauf
        Align = alClient
        TabOrder = 0
        object tsVerlauf: TTabSheet
          Caption = 'Verlauf'
          object grdVerlauf: TDBGrid
            Left = 0
            Top = 0
            Width = 528
            Height = 218
            Align = alClient
            DataSource = dmVorgang.dstblVerlauf
            Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit]
            ReadOnly = True
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -12
            TitleFont.Name = 'Segoe UI'
            TitleFont.Style = []
            Columns = <
              item
                Expanded = False
                FieldName = 'zeitpunkt'
                Title.Caption = 'Wann'
                Width = 130
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'von_bezeichnung'
                Title.Caption = 'Von'
                Width = 100
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'nach_bezeichnung'
                Title.Caption = 'Nach'
                Width = 100
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'bemerkung'
                Title.Caption = 'Bemerkung'
                Width = 180
                Visible = True
              end>
          end
        end
        object tsVerknuepft: TTabSheet
          Caption = 'Verkn'#252'pfte Vorg'#228'nge'
          ImageIndex = 1
          object grdVerknuepft: TDBGrid
            Left = 0
            Top = 0
            Width = 528
            Height = 218
            Align = alClient
            DataSource = dmVorgang.dstblVerknuepft
            Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit]
            ReadOnly = True
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -12
            TitleFont.Name = 'Segoe UI'
            TitleFont.Style = []
            OnDblClick = grdVerknuepftDblClick
            Columns = <
              item
                Expanded = False
                FieldName = 'richtung'
                Title.Caption = 'Richtung'
                Width = 90
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'vorgang_nr'
                Title.Caption = 'Nummer'
                Width = 90
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'bezeichnung'
                Title.Caption = 'Bezeichnung'
                Width = 240
                Visible = True
              end>
          end
        end
      end
    end
  end
end
