object frmDokumente: TfrmDokumente
  Left = 0
  Top = 0
  Caption = 'Dokumentenverwaltung  TRTHeisenberg'
  ClientHeight = 560
  ClientWidth = 1112
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object pgcDokumente: TPageControl
    Left = 0
    Top = 0
    Width = 1112
    Height = 560
    ActivePage = tabDokumente
    Align = alClient
    TabOrder = 0
    object tabDokumente: TTabSheet
      Caption = 'Dokumente'
      object Splitter1: TSplitter
        Left = 0
        Top = 260
        Width = 1104
        Height = 5
        Cursor = crVSplit
        Align = alTop
        ExplicitLeft = 40
        ExplicitTop = 271
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1104
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblHinweis: TLabel
          Left = 480
          Top = 10
          Width = 346
          Height = 13
          Caption = #195'nderungen hier Navigator Post Blazor-Seite neu laden zum Pr'#252'fen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGrayText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object navDokumente: TJvDBNavigator
          Left = 4
          Top = 6
          Width = 360
          Height = 28
          TabOrder = 0
        end
        object btnScan: TButton
          Left = 374
          Top = 6
          Width = 100
          Height = 28
          Caption = 'Scannen'
          TabOrder = 1
          OnClick = btnScanClick
        end
        object btnOcr: TJvNavPanelButtonTop
          Left = 480
          Top = 3
          Width = 130
          Height = 34
          Alignment = taCenter
          Caption = 'Texterkennung'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          ImageIndex = 0
          OnClick = btnOcrClick
        end
      end
      object pnlGrid: TPanel
        Left = 0
        Top = 40
        Width = 1104
        Height = 220
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object grdDokumente: TDBGrid
          Left = 0
          Top = 0
          Width = 1104
          Height = 220
          Align = alClient
          DataSource = dmDokumente.dsDokumente
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'dokument_id'
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'typ_id'
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'titel'
              Width = 120
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'ocr_text'
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'mime_type'
              Width = 120
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'quelle'
              Width = 120
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'dateigroesse_kb'
              Width = 64
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'sprache'
              Width = 64
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'scan_datum'
              Width = 64
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'created_at'
              Width = 64
              Visible = True
            end>
        end
      end
      object pnlMemo: TPanel
        Left = 0
        Top = 265
        Width = 1104
        Height = 265
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitTop = 260
        ExplicitHeight = 270
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 1104
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          Caption = 'Panel1'
          ShowCaption = False
          TabOrder = 0
          ExplicitTop = 2
          object lblOcrText: TLabel
            Left = 4
            Top = 4
            Width = 100
            Height = 15
            Caption = 'OCR-Text / Inhalt:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object mmoOcrText: TDBMemo
          AlignWithMargins = True
          Left = 3
          Top = 26
          Width = 1098
          Height = 236
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 1
          WordWrap = False
          ExplicitLeft = 4
          ExplicitTop = 47
          ExplicitWidth = 881
          ExplicitHeight = 210
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      ImageIndex = 1
      object DBImage1: TDBImage
        Left = 0
        Top = 0
        Width = 1104
        Height = 530
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 352
        ExplicitTop = 184
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
    end
  end
end
